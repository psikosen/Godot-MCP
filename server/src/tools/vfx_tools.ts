import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { fail, send } from './workflow_tools.js';

const vector = z.union([
  z.object({ x: z.number(), y: z.number(), z: z.number().optional() }),
  z.array(z.number()).min(2).max(3),
]);

export const vfxTools: MCPTool[] = [
  {
    name: 'build_vfx_effect',
    description: 'One-call layered effect: explosion, hit_impact, muzzle_flash, magic_burst, fire or sparks. Core flash, sparks (sub-emitters where they fit), smoke, a light pop, optional camera shake; 2D or 3D. Plays when the game runs; play() fires it again. Undo-aware.',
    parameters: z.object({
      preset: z.enum(['explosion', 'hit_impact', 'muzzle_flash', 'magic_burst', 'fire', 'sparks']),
      dimension: z.enum(['3d', '2d']).optional().describe('Default 3d'),
      parent_path: z.string().optional(),
      name: z.string().optional(),
      position: vector.optional(),
      direction: vector.optional().describe('Where it points: a surface normal (wall hit), a gun barrel. Default up; muzzle -Z, right in 2D'),
      scale: z.number().min(0.05).max(100).optional().describe('Size multiplier (default 1: about a 3 m explosion, 2D at 64 px per meter)'),
      color: z.any().optional().describe('Tint, e.g. "#40a0ff" for a blue explosion'),
      loop: z.boolean().optional().describe('Repeat instead of one burst (fire loops by default)'),
      light: z.boolean().optional().describe('Default true'),
      camera_shake: z.boolean().optional().describe('Default true for explosion'),
      autoplay: z.boolean().optional().describe('Default true: plays when it enters the game'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('build_vfx_effect', args);
        const subs = r.sub_emitters as string[];
        const extras = [r.light ? 'light pop' : '', r.camera_shake ? 'camera shake' : '', r.loop ? 'looping' : ''].filter(Boolean);
        return `${r.preset} (${r.dimension}) at ${r.node_path} [${r.status}]: ${(r.layers as string[]).join(', ')}`
          + (subs.length ? `; sub-emitters ${subs.join(', ')}` : '') + (extras.length ? `; ${extras.join(', ')}` : '')
          + `. Plays when the game runs; call play() on it to fire again. Tune a layer with configure_particles_3d (3D).`
          + ((r.notes as string[] | undefined) ?? []).map(note => `\nNote: ${note}`).join('');
      } catch (error) {
        return fail('build VFX effect', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'build_pixel_vfx',
    description: 'Pixel-art 2D effect drawn live by a shader: hard colour bands on a real pixel grid, stepped frames. One-shots: explosion, lightning, heal, slash, impact, poof, slam. Loops: tornado, vortex, fireball, beam, portal, shield, flame. element or color recolours it. Optional light and camera shake. Plays when the game runs; play() fires it again. Undo-aware.',
    parameters: z.object({
      preset: z.enum(['tornado', 'explosion', 'lightning', 'vortex', 'heal', 'slash', 'impact', 'poof', 'slam', 'fireball', 'beam', 'portal', 'shield', 'flame']),
      element: z.enum(['fire', 'ice', 'lightning', 'wind', 'dark', 'holy', 'nature', 'arcane', 'poison', 'water', 'blood', 'earth', 'plasma', 'steel'])
        .optional().describe('Colours (default per preset: wind tornado, fire explosion, ...); fire + tornado makes a firestorm'),
      color: z.any().optional().describe('Any colour instead of an element, e.g. "#40a0ff"'),
      parent_path: z.string().optional(),
      name: z.string().optional(),
      position: vector.optional().describe('Ground effects (tornado, lightning, heal, slam, flame) stand on this point; beam starts here'),
      pixel_scale: z.number().int().min(1).max(16).optional().describe('Screen pixels per art pixel (default 4)'),
      flip: z.boolean().optional().describe('Face left (slash, fireball and beam face right)'),
      light: z.boolean().optional().describe('A PointLight2D that pops or glows with the effect (default on for glowing presets)'),
      camera_shake: z.boolean().optional().describe('Default on for explosion, lightning, impact and slam'),
      autoplay: z.boolean().optional().describe('Default true: plays when it enters the game'),
      replay_every: z.number().min(0).optional().describe('Seconds between replays of a one-shot (0 plays once)'),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('build_pixel_vfx', args);
        const [w, h] = r.canvas as number[];
        const extras = [r.light ? 'light' : '', r.camera_shake ? 'camera shake' : '', r.loop ? 'looping' : 'one-shot'].filter(Boolean);
        return `${r.element} ${r.preset} at ${r.node_path} [${r.status}]: ${w}x${h} art pixels at ${r.pixel_scale}x, ${r.frames} frames at ${r.fps} fps; ${extras.join(', ')}.`
          + ` Plays when the game runs; play() fires it again. Colours: ${(r.ramps as string[]).map(slot => `FX material ${slot}_ramp`).join(', ')}.`
          + ' See it move: capture_scene_image with filmstrip.';
      } catch (error) {
        return fail('build pixel VFX', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
];
