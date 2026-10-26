import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { fail, send } from './workflow_tools.js';
import { vector3 } from './builder_tools.js';
import { editableNote } from './feature_tools.js';

const status = (r: CommandResult) => `[${r.status}]`;

// One readable block for inspect_model and configure_model_import.
const modelSummary = (r: CommandResult) => {
  const lines = [`${r.model_path} imports as ${r.import_as}${r.root ? `, root ${r.root}` : ''}`];
  const meshes = r.meshes as Array<Record<string, unknown>>;
  if (meshes.length) {
    lines.push('Meshes: ' + meshes.map(m => m.collision
      ? `${m.path} (collision ${m.collision})`
      : `${m.path}${m.skinned ? ' (skinned)' : ''} [${(m.materials as string[]).join(', ')}]`).join('; '));
  }
  const skeletons = r.skeletons as Array<Record<string, unknown>>;
  if (skeletons.length) lines.push('Skeletons: ' + skeletons.map(s => `${s.path} (${s.bones} bones, ${s.humanoid} match humanoid names)`).join('; '));
  const animations = r.animations as Array<Record<string, unknown>>;
  if (animations.length) lines.push('Animations: ' + animations.map(a => `${a.name} ${a.length}s loop ${a.loop}`).join('; '));
  const settings = Object.entries(r.settings as Record<string, unknown>);
  if (settings.length) lines.push('Import settings: ' + settings.map(([k, v]) => `${k}=${JSON.stringify(v)}`).join(', '));
  return lines.join('\n');
};

export const assetTools: MCPTool[] = [
  {
    name: 'inspect_model',
    description: 'Show what a 3D model file (.glb, .gltf, .fbx, .blend, .obj, .dae) holds after import: meshes and materials, skeletons, animations with length and loop, and its import settings. Use before configure_model_import.',
    parameters: z.object({
      model_path: z.string().describe('res:// model file'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        return modelSummary(await send('inspect_model', args));
      } catch (error) {
        return fail('inspect model', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'configure_model_import',
    description: 'Change how Godot imports a 3D model, then reimport it: root node type and scale, collision bodies on its meshes, looping animations, a humanoid bone map (so Mixamo/VRM/Unreal-style rigs share animations), importing as an animation library, extracting materials to files, lightmap UVs.',
    parameters: z.object({
      model_path: z.string(),
      import_as: z.enum(['scene', 'animation_library']).optional().describe('animation_library: the file loads as animations for add_animation_library'),
      root_type: z.string().optional().describe('e.g. CharacterBody3D, RigidBody3D, StaticBody3D'),
      root_name: z.string().optional(),
      root_scale: z.number().positive().optional(),
      collision: z.object({
        shape: z.enum(['trimesh', 'convex', 'decompose', 'box', 'sphere', 'cylinder', 'capsule', 'auto', 'none']).optional().describe('Default trimesh (exact, for static level art)'),
        body: z.enum(['static', 'rigid', 'area']).optional().describe('Default static'),
        meshes: z.array(z.string()).optional().describe('Mesh names or paths from inspect_model; default all'),
      }).strict().optional(),
      loop: z.union([z.boolean(), z.array(z.string())]).optional().describe('true loops every animation, false none, or a list of names'),
      loop_mode: z.enum(['linear', 'pingpong']).optional(),
      humanoid: z.boolean().optional().describe('Map the skeleton to Godot\'s humanoid profile; do it for the character and for each animation file'),
      extract_materials_to: z.string().optional().describe('res:// folder; materials become editable .tres files'),
      lightmap_uv: z.boolean().optional().describe('Generate UV2 for baked lightmaps'),
      animation_fps: z.number().int().min(1).max(240).optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('configure_model_import', args);
        const changed = r.changed as string[];
        return `Reimported.${changed.length ? ` ${changed.join('; ')}.` : ''}\n${modelSummary(r)}`;
      } catch (error) {
        return fail('configure model import', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'add_animation_library',
    description: 'Add animations to an AnimationPlayer from an AnimationLibrary file or a model (a model imported as animation_library is shared, a scene model is copied in). Reports how many tracks find their bones, so a skeleton mismatch shows at once. Undo-aware.',
    parameters: z.object({
      player_path: z.string(),
      source: z.string().describe('res:// .res/.tres library, or a .glb/.fbx model with animations'),
      library_name: z.string().optional().describe('Default: the file name; play as "<library>/<animation>"'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('add_animation_library', args);
        const unresolved = r.unresolved_examples as string[];
        return `Library "${r.library_name}" on ${r.player_path} ${status(r)}: ${(r.animations as string[]).join(', ')}`
          + `${r.embedded_copy ? ' (copied into the scene; import the file as animation_library to share it instead)' : ''}`
          + `\nTracks that find their node or bone: ${r.tracks_resolved}/${r.tracks_total}`
          + (unresolved.length ? `\nNot found, e.g.: ${unresolved.join(', ')} (retarget both models with configure_model_import humanoid)` : '')
          + editableNote(r);
      } catch (error) {
        return fail('add animation library', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'generate_mesh_collision',
    description: 'Collision that follows a 3D mesh\'s real shape (like Mesh > Create Collision Shape): trimesh (exact, static only), convex, simplified_convex, or multiple_convex (for moving bodies). Works on one MeshInstance3D or all meshes under a node; meshes not under a body get a StaticBody3D. Undo-aware.',
    parameters: z.object({
      node_path: z.string(),
      shape: z.enum(['trimesh', 'convex', 'simplified_convex', 'multiple_convex']).optional().describe('Default trimesh'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('generate_mesh_collision', args);
        return `${r.shape} collision ${status(r)}:\n${(r.created as string[]).join('\n')}`;
      } catch (error) {
        return fail('generate mesh collision', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'sprite_to_polygon',
    description: 'Trace a Sprite2D\'s visible pixels into a polygon (like the Sprite2D menu): collision (CollisionPolygon2D, in a new StaticBody2D unless the sprite is already under a body), occluder (LightOccluder2D for 2D shadows) or polygon (textured Polygon2D). Uses the region or current frame. Undo-aware.',
    parameters: z.object({
      node_path: z.string(),
      output: z.enum(['collision', 'occluder', 'polygon']).optional().describe('Default collision'),
      simplify: z.number().min(0).max(32).optional().describe('Pixels of error allowed; higher = fewer points (default 2)'),
      grow: z.number().int().min(-16).max(16).optional().describe('Grow or shrink the shape, in pixels'),
      alpha_threshold: z.number().min(0).max(1).optional().describe('Pixels above this alpha count (default 0.1)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('sprite_to_polygon', args);
        return `${r.output}: ${r.polygons} polygon(s) ${status(r)}\n${(r.created as string[]).join('\n')}`;
      } catch (error) {
        return fail('trace sprite', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'bake_csg',
    description: 'Turn a CSG blockout into a plain mesh plus trimesh collision (Godot 4.4+), so it runs fast in the game. Replaces the CSG node unless keep_csg. Undo-aware.',
    parameters: z.object({
      node_path: z.string().describe('The outermost CSG node'),
      collision: z.boolean().optional().describe('Default true'),
      keep_csg: z.boolean().optional(),
      save_mesh_to: z.string().optional().describe('res://...res to keep the mesh out of the scene file'),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('bake_csg', args);
        return `Baked ${r.node_path} ${status(r)}: ${r.triangles} triangles${r.collision ? ', with collision' : ''}`
          + `${r.csg_removed ? '; CSG removed' : '; CSG kept'}${r.mesh_path ? `; mesh saved to ${r.mesh_path}` : ''}`;
      } catch (error) {
        return fail('bake CSG', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'generate_terrain_3d',
    description: 'Generate rolling 3D terrain from noise: a mesh colored by height (sand, grass, rock, snow) with HeightMapShape3D collision, optional island shape and water plane. Mesh and shape are saved as .res files.',
    parameters: z.object({
      parent_path: z.string().optional(),
      size: z.number().min(2).max(4096).optional().describe('Width in meters (default 64)'),
      resolution: z.number().int().min(2).max(512).optional().describe('Cells per side (default 64)'),
      height: z.number().min(0).max(1000).optional().describe('Highest point in meters (default 8)'),
      frequency: z.number().min(0.0001).max(1).optional().describe('Higher = more, smaller hills (default 0.02)'),
      octaves: z.number().int().min(1).max(9).optional().describe('Detail layers (default 4)'),
      seed: z.number().int().optional(),
      island: z.boolean().optional().describe('Fade to sea level at the edges'),
      water_level: z.number().min(0).max(1).optional().describe('Add a water plane at this fraction of height'),
      position: vector3.optional(),
      name: z.string().optional(),
      save_dir: z.string().optional().describe('Default res://terrain'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('generate_terrain_3d', args);
        const range = r.height_range as number[];
        return `${r.node_path} ${status(r)}: ${r.size} m, ${r.cells}x${r.cells} cells, heights ${range[0]}..${range[1]} m`
          + `${r.water ? ', with water' : ''}\nSaved ${r.mesh_path} and ${r.shape_path}`;
      } catch (error) {
        return fail('generate terrain', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'generate_ui_theme',
    description: 'Make a whole UI Theme from a primary and a background color: buttons (hover, pressed, disabled, focus), panels, popups, tooltips, text fields, sliders, progress bars, tabs, check boxes, optional font. Saves a .tres and by default sets it as the project theme.',
    parameters: z.object({
      primary: z.any().optional().describe('Button and accent color, e.g. "#4c8bf5"'),
      background: z.any().optional().describe('Panel color; dark or light decides the text color'),
      text: z.any().optional(),
      corner_radius: z.number().int().min(0).max(64).optional(),
      border_width: z.number().int().min(0).max(8).optional(),
      font_size: z.number().int().min(8).max(96).optional(),
      font_path: z.string().optional().describe('res:// .ttf/.otf/.woff2'),
      save_path: z.string().optional().describe('Default res://ui/theme.tres'),
      apply_to_project: z.boolean().optional().describe('Default true: Project Settings > GUI > Theme > Custom'),
      node_path: z.string().optional().describe('Also set it on this Control'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('generate_ui_theme', args);
        const applied = r.applied_to as string[];
        return `Saved ${r.save_path} (${r.dark ? 'dark' : 'light'}, font size ${r.font_size})${applied.length ? `; applied to ${applied.join(', ')}` : ''}`;
      } catch (error) {
        return fail('generate UI theme', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
];
