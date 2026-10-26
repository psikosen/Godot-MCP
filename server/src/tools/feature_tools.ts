import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { fail, send, vector2 } from './workflow_tools.js';
import { vector3 } from './builder_tools.js';

const status = (r: CommandResult) => `[${r.status}]`;
const point = z.union([vector2, vector3]);
const boneAxis = z.enum(['+x', '-x', '+y', '-y', '+z', '-z']);
export const editableNote = (r: CommandResult) => {
  const opened = (r.editable_children as string[] | undefined) ?? [];
  return opened.length ? `\nTurned on Editable Children for ${opened.join(', ')} so the change saves` : '';
};

export const featureTools: MCPTool[] = [
  {
    name: 'describe_skeleton',
    description: 'Show a Skeleton3D\'s bone tree (finds the skeleton under a model node too), its modifiers, and arm/leg chains (root, middle, end) ready for setup_ik_chain.',
    parameters: z.object({
      node_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('describe_skeleton', args);
        const limbs = (r.limbs as Array<Record<string, string>>).map(l => `${l.root} > ${l.middle} > ${l.end}`);
        const modifiers = r.modifiers as string[];
        return `${r.skeleton_path}: ${r.bone_count} bones\n${r.outline}`
          + (limbs.length ? `\nLimbs: ${limbs.join('; ')}` : '')
          + (modifiers.length ? `\nModifiers: ${modifiers.join(', ')}` : '');
      } catch (error) {
        return fail('describe skeleton', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'setup_ik_chain',
    description: 'Add inverse kinematics (Godot 4.6+) so bone chains reach for targets: two_bone for arms and legs (only end_bone needed), fabrik/ccdik/jacobian for longer chains, spline to follow a Path3D. Creates a Marker3D target per chain unless target_path is given, and for two_bone a pole marker the knee or elbow bends toward; move the markers to pose the limb. Undo-aware.',
    parameters: z.object({
      skeleton_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
      solver: z.enum(['two_bone', 'fabrik', 'ccdik', 'jacobian', 'spline']).optional().describe('Default two_bone'),
      chains: z.array(z.object({
        end_bone: z.string().describe('e.g. "LeftHand" or "mixamorig:LeftFoot"'),
        root_bone: z.string().optional().describe('two_bone: default is the grandparent of end_bone; other solvers: required'),
        middle_bone: z.string().optional().describe('two_bone only; default is the parent of end_bone'),
        target_path: z.string().optional().describe('A 3D node to reach for; default creates "<end_bone>Target"'),
        pole_path: z.string().optional().describe('two_bone: a 3D node the knee or elbow points at; default creates "<middle_bone>Pole"'),
        path_3d: z.string().optional().describe('spline: the Path3D the chain follows'),
      }).strict()).min(1).max(16),
      max_iterations: z.number().int().min(1).max(1000).optional().describe('fabrik, ccdik, jacobian'),
      influence: z.number().min(0).max(1).optional(),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('setup_ik_chain', args);
        const chains = (r.chains as Array<Record<string, string>>).map(c =>
          `${[c.root, c.middle, c.end].filter(Boolean).join(' > ')} -> ${c.target ?? c.path_3d}${c.pole ? ` (pole ${c.pole})` : ''}`);
        return `${r.solver} ${r.node_path} ${status(r)}:\n${chains.join('\n')}`;
      } catch (error) {
        return fail('set up IK chain', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'add_bone_constraint',
    description: 'Make one bone follow something: aim (point at a node or bone, Godot 4.5+), copy_transform (copy another bone or node\'s position/rotation/scale, 4.5+), look_at (smoothly turn toward a node, with optional delay, 4.4+). Undo-aware.',
    parameters: z.object({
      skeleton_path: z.string(),
      type: z.enum(['aim', 'copy_transform', 'look_at']),
      bone: z.string().describe('The bone that moves, e.g. "Head"'),
      target_path: z.string().optional().describe('A 3D node to follow'),
      target_bone: z.string().optional().describe('Or a bone to follow (aim, copy_transform)'),
      forward_axis: boneAxis.optional().describe('Bone axis that points at the target (aim, look_at); default +y, the way Godot bones point'),
      amount: z.number().min(0).max(1).optional().describe('aim, copy_transform: blend 0..1 (default 1)'),
      copy: z.array(z.enum(['position', 'rotation', 'scale'])).optional().describe('copy_transform: default all three'),
      relative: z.boolean().optional().describe('copy_transform: copy relative to the rest pose'),
      duration: z.number().min(0).max(10).optional().describe('look_at: seconds to turn (0 = instant)'),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('add_bone_constraint', args);
        return `${r.type} ${r.node_path} ${status(r)}: bone ${r.bone} follows ${r.target}`;
      } catch (error) {
        return fail('add bone constraint', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'setup_spring_bones',
    description: 'Make hair, tails, ears, capes or antennas jiggle and swing with SpringBoneSimulator3D (Godot 4.4+). One chain per root..end bone run; optional collision spheres on bones (e.g. head, chest) keep hair out of the body. Undo-aware.',
    parameters: z.object({
      skeleton_path: z.string(),
      chains: z.array(z.object({
        root_bone: z.string(),
        end_bone: z.string(),
        stiffness: z.number().min(0).max(4).optional().describe('How hard it springs back (Godot default 1)'),
        drag: z.number().min(0).max(1).optional().describe('Air resistance; higher settles faster'),
        gravity: z.number().min(0).max(10).optional().describe('Pull down, in m/s2'),
        gravity_direction: vector3.optional(),
        radius: z.number().min(0).max(1).optional().describe('Bone thickness for collisions, in meters'),
        extend_end_bone: z.boolean().optional().describe('Default true: let the last bone swing too'),
      }).strict()).min(1).max(32),
      colliders: z.array(z.object({
        bone: z.string(),
        radius: z.number().min(0.001).max(100).optional(),
        offset: vector3.optional(),
      }).strict()).max(32).optional(),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('setup_spring_bones', args);
        const colliders = r.colliders as string[];
        return `${r.node_path} ${status(r)}:\n${(r.chains as string[]).join('\n')}`
          + (colliders.length ? `\nColliders: ${colliders.join(', ')}` : '');
      } catch (error) {
        return fail('set up spring bones', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'set_stencil_effect',
    description: 'Outline a 3D object, or show it through walls (xray), with the stencil buffer (Godot 4.5+). Works on one MeshInstance3D or every mesh under a model node; each surface gets its own material copy. effect none removes it. Undo-aware.',
    parameters: z.object({
      node_path: z.string(),
      effect: z.enum(['outline', 'xray', 'none']).optional().describe('Default outline'),
      color: z.any().optional().describe('e.g. "#ffcc33"'),
      thickness: z.number().min(0).max(1).optional().describe('outline width in meters (default 0.02)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('set_stencil_effect', args);
        const skipped = r.skipped as string[];
        return `${r.effect} on ${r.node_path}: ${r.surfaces} surface(s) ${status(r)}`
          + (skipped.length ? `; skipped: ${skipped.join(', ')}` : '')
          + editableNote(r);
      } catch (error) {
        return fail('set stencil effect', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_spatial_shader',
    description: 'Give a 3D mesh or CSG shape a ready-made shader: toon (cel shading), rim_glow (glowing edges), hologram, dissolve (animate progress 0..1), wind_sway (grass and leaves). Writes res://shaders/<effect>_3d.gdshader once and sets material_override.',
    parameters: z.object({
      node_path: z.string(),
      effect: z.enum(['toon', 'rim_glow', 'hologram', 'dissolve', 'wind_sway']),
      uniforms: z.record(z.any()).optional().describe('e.g. {"albedo": "#d08050", "bands": 3} or {"glow_color": "#33ccff"}'),
      shader_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_spatial_shader', args);
        return `${r.effect} on ${r.node_path} ${status(r)} using ${r.shader_path}; uniforms: ${(r.uniforms as string[]).join(', ')}. Animate one with update_node_property "material_override:shader_parameter/<name>".${editableNote(r)}`;
      } catch (error) {
        return fail('create spatial shader', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'add_touch_controls',
    description: 'Add phone and tablet controls on a CanvasLayer: a VirtualJoystick bound to move actions (Godot 4.7+) and round TouchScreenButtons bound to input actions (bottom right). The layer shows only on touch screens unless show_on_desktop. Undo-aware.',
    parameters: z.object({
      parent_path: z.string().optional().describe('Default /root'),
      joystick: z.boolean().optional().describe('Default true; false for buttons only (any Godot 4)'),
      joystick_actions: z.object({ left: z.string(), right: z.string(), up: z.string(), down: z.string() }).partial().strict().optional()
        .describe('Default ui_left, ui_right, ui_up, ui_down'),
      joystick_mode: z.enum(['fixed', 'dynamic', 'following']).optional().describe('dynamic (default) appears where the thumb lands'),
      joystick_size: z.number().min(60).max(500).optional(),
      buttons: z.array(z.object({
        action: z.string(),
        label: z.string().optional(),
        position: vector2.optional().describe('Pixels; default is a row in the bottom right'),
        name: z.string().optional(),
      }).strict()).max(8).optional(),
      button_size: z.number().min(32).max(400).optional().describe('Pixels, default 96'),
      show_on_desktop: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('add_touch_controls', args);
        const undefinedActions = r.undefined_actions as string[];
        return `${r.node_path} ${status(r)}: ${r.joystick ? 'joystick, ' : ''}buttons ${(r.buttons as string[]).join(', ') || 'none'}`
          + (undefinedActions.length ? `\nNot defined yet (add with add_input_action): ${undefinedActions.join(', ')}` : '');
      } catch (error) {
        return fail('add touch controls', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'set_accessibility_info',
    description: 'Set screen-reader names and descriptions on UI Controls (Godot 4.5+). auto_fill_root names every button, slider or field under it that has no text and no name yet, from its tooltip or node name. Pair with validate_accessibility. Undo-aware.',
    parameters: z.object({
      entries: z.array(z.object({
        node_path: z.string(),
        name: z.string().optional(),
        description: z.string().optional(),
      }).strict()).max(200).optional(),
      auto_fill_root: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('set_accessibility_info', args);
        const applied = r.applied as string[];
        return applied.length ? `Set ${applied.length} ${status(r)}:\n${applied.join('\n')}${editableNote(r)}` : 'Nothing to set: every interactive control already has text or a name.';
      } catch (error) {
        return fail('set accessibility info', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_path',
    description: 'Create a Path2D or Path3D (from the parent type) through points, for patrol routes, rails, rivers or camera tracks. smooth rounds the corners; closed makes a loop. Undo-aware.',
    parameters: z.object({
      parent_path: z.string().optional(),
      points: z.array(point).min(2).max(1000).describe('[[x, y], ...] for 2D or [[x, y, z], ...] for 3D'),
      smooth: z.boolean().optional(),
      closed: z.boolean().optional(),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_path', args);
        return `${r.type} ${r.node_path} ${status(r)}: ${r.points} points, length ${r.length}`;
      } catch (error) {
        return fail('create path', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'place_along_path',
    description: 'Place copies of a scene along a Path2D or Path3D (coins on an arc, fence posts, torches down a corridor) by count or spacing, turned to follow the path. Copies go in one container under the path. Undo-aware.',
    parameters: z.object({
      path_path: z.string(),
      scene_path: z.string().describe('res:// scene to copy; 2D root for Path2D, 3D root for Path3D'),
      count: z.number().int().min(1).max(500).optional().describe('Default 10, evenly spread'),
      spacing: z.number().positive().optional().describe('Distance between copies (instead of count)'),
      align: z.boolean().optional().describe('Default true: turn each copy along the path'),
      name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('place_along_path', args);
        return `Placed ${r.count} under ${r.node_path} ${status(r)} (path length ${r.path_length})`;
      } catch (error) {
        return fail('place along path', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'build_mesh_library',
    description: 'Make a GridMap MeshLibrary from a scene (or open-scene node) whose children are MeshInstance3D tiles, like Scene > Export As > MeshLibrary. StaticBody3D children give collision; NavigationRegion3D children give navmesh. Optionally assigns it to a GridMap.',
    parameters: z.object({
      source: z.string().describe('res://tiles.tscn, or a node path like /root/Tiles'),
      save_path: z.string().describe('res://.../tiles.tres (or .meshlib)'),
      gridmap_path: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('build_mesh_library', args);
        return `Saved ${r.save_path} with ${(r.items as string[]).length} item(s): ${(r.items as string[]).join(', ')}`
          + (r.gridmap_path ? `\nAssigned to ${r.gridmap_path} ${status(r)}` : '');
      } catch (error) {
        return fail('build mesh library', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
];
