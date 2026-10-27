import { copyFileSync, existsSync, mkdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { fail, godotProblems, runGodot, send, vector2 } from './workflow_tools.js';

export const vector3 = z.union([
  z.object({ x: z.number(), y: z.number(), z: z.number() }),
  z.tuple([z.number(), z.number(), z.number()]),
]);
const layerList = z.array(z.union([z.string(), z.number().int().min(1).max(32)])).max(32);
const IMPORTABLE = ['.png', '.jpg', '.jpeg', '.webp', '.svg', '.wav', '.ogg', '.mp3', '.ttf', '.otf', '.woff2',
  '.glb', '.gltf', '.obj', '.fbx', '.csv', '.json', '.txt'];

const status = (r: CommandResult) => `[${r.status}]`;

export const builderTools: MCPTool[] = [
  {
    name: 'check_project',
    description: 'Project health check: missing main scene or autoload files, scene/resource links to missing files, scripts that do not compile, input actions used in scripts but not defined.',
    parameters: z.object({
      include_addons: z.boolean().optional().describe('Also check res://addons (default false)'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('check_project', args);
        const issues = r.issues as string[];
        if (issues.length === 0) return 'No problems found.';
        return `${r.error_count} error(s), ${r.warning_count} warning(s):\n${issues.join('\n')}`;
      } catch (error) {
        return fail('check project', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'find_unused_files',
    description: 'List project files (images, sounds, fonts, models, scenes, resources, scripts) that no scene, resource, script or project setting refers to. Paths built at runtime are not seen; review before deleting.',
    parameters: z.object({
      include_addons: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('find_unused_files', args);
        const unused = r.unused as string[];
        return unused.length ? `${unused.length} unused file(s), ${r.total}:\n${unused.join('\n')}` : 'Every file is referenced.';
      } catch (error) {
        return fail('find unused files', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'replace_in_project',
    description: 'Find and replace across project files (default .gd). Previews by default; pass dry_run false to apply. Changed scripts are compile-checked.',
    parameters: z.object({
      find: z.string().min(1),
      replace: z.string(),
      regex: z.boolean().optional().describe('find is a regular expression; replace may use $1'),
      extensions: z.array(z.string()).optional().describe('Default [".gd"]'),
      include_addons: z.boolean().optional(),
      dry_run: z.boolean().optional().describe('Default true: only report what would change'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('replace_in_project', args);
        const files = r.files as string[];
        const errors = r.compile_errors as string[];
        if (files.length === 0) return 'No matches.';
        return `${r.dry_run ? 'Would change' : 'Changed'} ${files.length} file(s) (file: matches):\n${files.join('\n')}`
          + (errors.length ? `\nScripts that no longer compile:\n${errors.join('\n')}` : '');
      } catch (error) {
        return fail('replace in project', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'set_collision_layers',
    description: 'Set a body\'s or area\'s collision layer and mask by layer names (from Project Settings > Layer Names) or numbers. With neither, shows them by name.',
    parameters: z.object({
      node_path: z.string(),
      layers: layerList.optional().describe('What it is, e.g. ["player"]'),
      mask: layerList.optional().describe('What it collides with, e.g. ["world", "enemies"]'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('set_collision_layers', args);
        const names = (list: unknown) => (list as string[]).join(', ') || 'none';
        return `${r.node_path} ${status(r)}: layers ${names(r.layers)}; mask ${names(r.mask)}`;
      } catch (error) {
        return fail('set collision layers', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'fit_collision_shape',
    description: 'Size a body\'s or area\'s collision shape to its visible art (Sprite2D, AnimatedSprite2D, Polygon2D; 3D meshes, CSG, sprites). Creates the CollisionShape when missing. Undo-aware.',
    parameters: z.object({
      node_path: z.string().describe('The physics body or area'),
      shape: z.enum(['rectangle', 'circle', 'capsule', 'box', 'sphere']).optional().describe('2D: rectangle (default), circle, capsule; 3D: box (default), sphere, capsule'),
      padding: z.number().optional().describe('Grow (or shrink, if negative) the fitted bounds, in pixels or meters'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('fit_collision_shape', args);
        return `${r.created ? 'Created' : 'Resized'} ${r.node_path} as ${r.shape} size ${r.size} at ${r.position} ${status(r)}`;
      } catch (error) {
        return fail('fit collision shape', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_canvas_shader',
    description: 'Give a 2D node or Control a ready-made shader effect: outline (textured sprites), flash (hit flash), dissolve, wave (sway), grayscale. Writes res://shaders/<effect>.gdshader once and assigns a ShaderMaterial.',
    parameters: z.object({
      node_path: z.string(),
      effect: z.enum(['outline', 'flash', 'dissolve', 'wave', 'grayscale']),
      uniforms: z.record(z.any()).optional().describe('e.g. {"outline_color": "#000000", "width": 2} or {"amount": 1}'),
      shader_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_canvas_shader', args);
        return `${r.effect} on ${r.node_path} ${status(r)} using ${r.shader_path}; uniforms: ${(r.uniforms as string[]).join(', ')}. Animate one with update_node_property "material:shader_parameter/<name>" or a tween.`;
      } catch (error) {
        return fail('create canvas shader', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'generate_sfx',
    description: 'Synthesize a retro sound effect (jump, coin, hit, explosion, laser, powerup, blip, footstep) and save it as a WAV in the project. Use pitch/variation/seed for different takes.',
    parameters: z.object({
      preset: z.enum(['jump', 'coin', 'hit', 'explosion', 'laser', 'powerup', 'blip', 'footstep']),
      path: z.string().optional().describe('Default res://audio/sfx/<preset>.wav'),
      pitch: z.number().min(0.25).max(4).optional().describe('1 = normal, 2 = an octave up'),
      variation: z.number().min(0).max(1).optional().describe('Random pitch change, 0..1'),
      volume: z.number().min(0).max(1).optional().describe('Default 0.8'),
      seed: z.number().int().optional(),
      overwrite: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('generate_sfx', args);
        return `Saved ${r.preset} sound (${r.seconds}s) to ${r.path}.${r.imported === false ? ' Godot is still importing it; wait a moment before using it.' : ''} Play it with an AudioStreamPlayer (author_audio_stream_player).`;
      } catch (error) {
        return fail('generate sound effect', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'paint_tilemap_ascii',
    description: 'Paint a TileMapLayer from text rows, one character per cell, e.g. rows ["#####", "#...#"] with legend {"#": {"source_id": 0, "atlas_coords": [1, 0]}, ".": "erase"}. Spaces leave cells unchanged. One undo step.',
    parameters: z.object({
      node_path: z.string().describe('A TileMapLayer with a TileSet'),
      rows: z.array(z.string()).min(1).max(1000),
      legend: z.record(z.union([
        z.literal('erase'),
        z.object({ source_id: z.number().int().min(0), atlas_coords: vector2, alternative: z.number().int().min(0).optional() }),
      ])),
      origin: vector2.optional().describe('Cell of the first character (default 0,0)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('paint_tilemap_ascii', args);
        return `Painted ${r.cells} cell(s) from ${r.rows} row(s) on ${r.node_path} ${status(r)}`;
      } catch (error) {
        return fail('paint tilemap', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'build_blockout_3d',
    description: 'Block out a 3D level: boxes, spheres, cylinders and capsules with colored materials and (by default) static collision, grouped under one node. One undo step.',
    parameters: z.object({
      parent_path: z.string().optional().describe('Default "/root"'),
      name: z.string().optional().describe('Group node name (default "Blockout")'),
      blocks: z.array(z.object({
        name: z.string().optional(),
        shape: z.enum(['box', 'sphere', 'cylinder', 'capsule']).optional(),
        position: vector3.optional(),
        size: vector3.optional().describe('Box size; sphere/cylinder/capsule use x as diameter and y as height'),
        rotation_degrees: vector3.optional(),
        color: z.any().optional(),
        collision: z.boolean().optional().describe('StaticBody3D with a matching shape (default true)'),
      })).min(1).max(500),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('build_blockout_3d', args);
        return `Built ${r.blocks} block(s) under ${r.node_path} (${r.materials} material(s)) ${status(r)}`;
      } catch (error) {
        return fail('build 3D blockout', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'setup_2d_lighting',
    description: 'Mood lighting for 2D: a CanvasModulate darkens the level (not separate CanvasLayers such as a HUD or sky), PointLight2D glows light it back up (shared soft radial texture, optional shadows). Updates an existing CanvasModulate. One undo step.',
    parameters: z.object({
      parent_path: z.string().optional().describe('Default "/root"'),
      darkness: z.any().optional().describe('Ambient color, e.g. "#3a3f5c" (dark blue night)'),
      lights: z.array(z.object({
        name: z.string().optional(),
        position: vector2,
        color: z.any().optional().describe('Default warm "#ffd9a0"'),
        energy: z.number().min(0).max(16).optional(),
        radius: z.number().min(4).max(4096).optional().describe('Pixels, default 160'),
        shadows: z.boolean().optional().describe('Cast shadows from LightOccluder2D nodes'),
      })).max(64).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('setup_2d_lighting', args);
        const lights = r.lights as string[];
        return `Lighting under ${r.parent_path} ${status(r)}: darkness ${r.darkness}${lights.length ? `, lights ${lights.join(', ')}` : ''}`;
      } catch (error) {
        return fail('set up 2D lighting', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'profile_game',
    description: 'Run a scene in a game window for some frames (optionally holding inputs) and report frame and physics time, draw calls, objects drawn, node count and memory. Briefly opens a window.',
    parameters: z.object({
      scene: z.string().optional().describe('res:// scene; default the main scene'),
      frames: z.number().int().min(30).max(36000).optional().describe('Default 300 (about 5 seconds)'),
      hold: z.array(z.object({
        action: z.string(),
        from_frame: z.number().int().min(0),
        to_frame: z.number().int().min(0),
      })).max(20).optional(),
      timeout_seconds: z.number().int().min(10).max(1200).optional().describe('Default 120'),
    }),
    execute: async (args: { scene?: string; frames?: number; hold?: Array<{ action: string; from_frame: number; to_frame: number }>; timeout_seconds?: number }): Promise<string> => {
      let paths: CommandResult;
      try {
        paths = await send('get_runtime_paths', {});
      } catch (error) {
        return fail('find the game', error);
      }
      const scene = args.scene ?? (paths.main_scene as string);
      if (!scene) throw new Error('No scene given and the project has no main scene');
      const frames = args.frames ?? 300;
      const holds = (args.hold ?? []).map(h => `${h.action}:${h.from_frame}:${h.to_frame}`);
      const { code, output } = await runGodot(paths.executable as string, [
        '--path', paths.project_dir as string, '--script', 'res://addons/godot_mcp/runtime/run_scene.gd',
        '--', scene, String(frames), '-', '--profile', ...holds,
      ], (args.timeout_seconds ?? 120) * 1000);
      const line = output.split('\n').find(l => l.startsWith('PROFILE_RESULT '));
      if (!line) throw new Error(`The game did not report (exit ${code}).\n${godotProblems(output).join('\n') || output.slice(-1200)}`);
      const p = JSON.parse(line.slice('PROFILE_RESULT '.length));
      const stat = (key: string, unit = '') => p[key] ? `${p[key].avg}${unit} avg, ${p[key].max}${unit} max` : 'n/a';
      const problems = godotProblems(output);
      return [
        `${scene}, ${frames} frames: ${Math.round(p.fps)} fps at the end (capped by vsync)`,
        `frame time ${stat('frame_ms', 'ms')}; physics ${stat('physics_ms', 'ms')}`,
        `draw calls ${stat('draw_calls')}; objects drawn ${stat('objects')}; nodes ${stat('nodes')}; static memory ${p.memory_mb} MB`,
        ...(problems.length ? [`errors while running:\n${problems.join('\n')}`] : []),
      ].join('\n');
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to run the game in a window to measure its performance.',
    },
  },
  {
    name: 'import_asset_files',
    description: 'Copy files from this computer (images, sounds, fonts, 3D models, data) into the project, where Godot imports them. Default target res://assets/<file name>.',
    parameters: z.object({
      files: z.array(z.object({
        source: z.string().describe('Absolute path on this computer'),
        target: z.string().optional().describe('res:// path; default res://assets/<file name>'),
      })).min(1).max(100),
      overwrite: z.boolean().optional(),
    }),
    execute: async (args: { files: Array<{ source: string; target?: string }>; overwrite?: boolean }): Promise<string> => {
      let projectDir: string;
      try {
        projectDir = (await send('get_runtime_paths', {})).project_dir as string;
      } catch (error) {
        return fail('find the project', error);
      }
      const root = path.resolve(projectDir);
      const plan = args.files.map(({ source, target }) => {
        const from = path.resolve(source);
        const extension = path.extname(from).toLowerCase();
        if (!path.isAbsolute(source)) throw new Error(`source must be an absolute path: ${source}`);
        if (!existsSync(from) || !statSync(from).isFile()) throw new Error(`Not a file: ${source}`);
        if (!IMPORTABLE.includes(extension)) throw new Error(`${path.basename(from)}: ${extension || 'no extension'} is not an importable asset (${IMPORTABLE.join(' ')})`);
        const resPath = target ?? `res://assets/${path.basename(from)}`;
        if (!resPath.startsWith('res://') || path.extname(resPath).toLowerCase() !== extension) {
          throw new Error(`target must be a res:// path with the same extension: ${resPath}`);
        }
        const to = path.resolve(root, resPath.slice('res://'.length));
        const lower = path.relative(root, to).toLowerCase().replace(/\\/g, '/');
        if (to === root || !to.startsWith(root + path.sep) || /^(addons\/godot_mcp|project-manager|\.godot)(\/|$)/.test(lower) || lower === 'project.godot') {
          throw new Error(`target must stay inside the project and away from MCP files: ${resPath}`);
        }
        if (existsSync(to) && !args.overwrite) throw new Error(`${resPath} already exists (pass overwrite true)`);
        return { from, to, resPath };
      });
      for (const { from, to } of plan) {
        mkdirSync(path.dirname(to), { recursive: true });
        copyFileSync(from, to);
      }
      await send('rescan_filesystem', { paths: plan.map(p => p.resPath) }).catch(() => undefined);
      return `Imported ${plan.length} file(s):\n${plan.map(p => p.resPath).join('\n')}`;
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to copy files from this computer into the Godot project.',
    },
  },
];
