import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { fail, send, vector2 } from './workflow_tools.js';
import { editableNote } from './feature_tools.js';

const status = (r: CommandResult) => `[${r.status}]`;

export const polishTools: MCPTool[] = [
  {
    name: 'create_ragdoll',
    description: 'Make a 3D character fall like a ragdoll (Skeleton3D > Create Physical Skeleton): a PhysicalBoneSimulator3D with a capsule PhysicalBone3D per bone, mass spread by bone length. Fingers and tiny bones are skipped. Start it in game with physical_bones_start_simulation(). Undo-aware.',
    parameters: z.object({
      skeleton_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
      joint_type: z.enum(['pin', 'cone', 'hinge']).optional().describe('Default pin (like the editor)'),
      total_mass: z.number().positive().optional().describe('kg for the whole body (default 70)'),
      thickness: z.number().min(0.1).max(10).optional().describe('Capsule radius multiplier (default 1)'),
      skip_fingers: z.boolean().optional().describe('Default true'),
      min_length: z.number().min(0).optional().describe('Skip bones shorter than this, in meters (default 0.03)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_ragdoll', args);
        const bones = r.bones as string[];
        return `${r.node_path} ${status(r)}: ${bones.length} physical bones (${r.joint_type} joints, ${r.total_mass} kg), ${r.skipped} bones skipped\n${bones.join(', ')}`
          + `\nStart it in a script: get_node("${String(r.node_path).replace(/^\/root\/?/, '')}").physical_bones_start_simulation()${editableNote(r)}`;
      } catch (error) {
        return fail('create ragdoll', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'add_screen_effect',
    description: 'Add a full-screen effect on its own CanvasLayer (works over 2D and 3D): vignette, damage_flash (animate amount), crt, pixelate, chromatic_aberration, grayscale, blur (pause menus), color_grade. Effects stack in call order. Undo-aware.',
    parameters: z.object({
      effect: z.enum(['vignette', 'damage_flash', 'crt', 'pixelate', 'chromatic_aberration', 'grayscale', 'blur', 'color_grade']),
      parent_path: z.string().optional(),
      uniforms: z.record(z.any()).optional().describe('e.g. {"strength": 0.8} or {"pixel_size": 6}'),
      enabled: z.boolean().optional().describe('false adds it hidden, to show later'),
      layer: z.number().int().min(-128).max(128).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('add_screen_effect', args);
        return `${r.effect} at ${r.node_path} (layer ${r.layer}) ${status(r)}; uniforms: ${(r.uniforms as string[]).join(', ')}.`
          + ` Change one with update_node_property on ${r.rect_path} "material:shader_parameter/<name>".`;
      } catch (error) {
        return fail('add screen effect', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'setup_day_night_cycle',
    description: 'Loop a full day with no script: an AnimationPlayer turns the sun, fades its energy and color, and shifts a ProceduralSkyMaterial\'s colors from sunrise to noon, sunset and night. Uses the scene\'s DirectionalLight3D and WorldEnvironment under parent_path, or makes them. Undo-aware.',
    parameters: z.object({
      parent_path: z.string().optional().describe('A 3D node that holds (or will hold) the sun and environment; default /root'),
      day_length: z.number().min(1).max(86400).optional().describe('Seconds for a full day (default 120)'),
      sun_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('setup_day_night_cycle', args);
        const created = r.created as string[];
        return `${r.node_path} ${status(r)}: ${r.day_length}s day, animates ${(r.tracks as string[]).join(', ')}`
          + `${created.length ? `; created ${created.join(', ')}` : ''}${r.sky ? '' : '; sky not animated (the environment has no ProceduralSkyMaterial)'}`;
      } catch (error) {
        return fail('set up day/night cycle', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'convert_to_multimesh',
    description: 'Merge many MeshInstance3D copies of the same mesh (trees, rocks, fence posts) into one MultiMeshInstance3D each: one draw call instead of hundreds. Copies with children (collision) or scripts are left alone. Undo-aware.',
    parameters: z.object({
      parent_path: z.string(),
      recursive: z.boolean().optional().describe('Also look inside child nodes (default: direct children only)'),
      min_count: z.number().int().min(2).optional().describe('Only merge meshes used at least this often (default 2)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('convert_to_multimesh', args);
        const skipped = r.skipped as string[];
        return `Merged ${r.nodes_removed} meshes into ${r.multimeshes} MultiMesh node(s) ${status(r)}:\n${(r.merged as string[]).join('\n')}`
          + (skipped.length ? `\nLeft alone: ${skipped.join(', ')}` : '');
      } catch (error) {
        return fail('convert to MultiMesh', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'configure_texture_import',
    description: 'Set how images import, then reimport them: preset pixel_art (lossless, no mipmaps, sharp), ui, 3d (VRAM compressed with mipmaps) or normal_map, plus compress, mipmaps, size_limit. Takes files and folders.',
    parameters: z.object({
      paths: z.array(z.string()).min(1).describe('res:// images or folders'),
      preset: z.enum(['pixel_art', 'ui', '3d', 'normal_map']).optional(),
      compress: z.enum(['lossless', 'lossy', 'vram', 'uncompressed', 'basis']).optional(),
      mipmaps: z.boolean().optional(),
      size_limit: z.number().int().min(0).max(16384).optional().describe('Largest side in pixels; 0 = no limit'),
      normal_map: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('configure_texture_import', args);
        const skipped = r.skipped as string[];
        const options = Object.entries(r.options as Record<string, unknown>).map(([k, v]) => `${k}=${v}`).join(', ');
        return `Reimported ${r.changed} image(s) with ${options}`
          + ((r.files as string[]).length ? `:\n${(r.files as string[]).join('\n')}` : '')
          + (skipped.length ? `\nSkipped: ${skipped.join(', ')}` : '')
          + (r.preset === 'pixel_art' ? '\nFor crisp pixels also set configure_game_settings texture_filter "nearest".' : '');
      } catch (error) {
        return fail('configure texture import', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_audio_randomizer',
    description: 'Combine sound files into an AudioStreamRandomizer so footsteps, hits and shots vary in pitch, volume and take each time they play. Saves a .tres and can assign it to an AudioStreamPlayer (2D/3D).',
    parameters: z.object({
      sounds: z.array(z.string()).min(1).max(64).describe('res:// audio files'),
      pitch_variation: z.number().min(0).max(24).optional().describe('Semitones of random pitch (default 1)'),
      volume_variation: z.number().min(0).max(40).optional().describe('dB of random volume (default 2)'),
      mode: z.enum(['random_no_repeat', 'random', 'sequential']).optional(),
      save_path: z.string().optional(),
      player_path: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_audio_randomizer', args);
        return `Saved ${r.save_path}: ${r.sounds} sound(s), ${r.mode}, pitch ±${r.pitch_variation} semitones, volume ±${r.volume_variation} dB`
          + (r.player_path ? `; assigned to ${r.player_path} ${status(r)}` : '');
      } catch (error) {
        return fail('create audio randomizer', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'generate_placeholder_art',
    description: 'Draw simple PNG sprites for prototyping: circle, square, rounded_square, triangle, diamond, star, heart, capsule, character (with eyes), coin, tile (beveled), crate, arrow. Antialiased, with optional outline; saved and imported.',
    parameters: z.object({
      sprites: z.array(z.object({
        shape: z.enum(['circle', 'square', 'rounded_square', 'triangle', 'diamond', 'star', 'heart', 'capsule', 'character', 'coin', 'tile', 'crate', 'arrow']),
        name: z.string().optional().describe('File name without .png'),
        size: z.union([z.number().int().min(4).max(512), vector2]).optional().describe('Pixels: 64 or [32, 48]'),
        color: z.any().optional(),
        outline_color: z.any().optional(),
        outline_width: z.number().min(0).max(32).optional(),
      }).strict()).min(1).max(32),
      folder: z.string().optional().describe('Default res://art/placeholder'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('generate_placeholder_art', args);
        return `Made ${(r.files as string[]).length} sprite(s):\n${(r.files as string[]).join('\n')}`;
      } catch (error) {
        return fail('generate placeholder art', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
];
