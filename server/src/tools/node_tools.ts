import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

/**
 * Type definitions for node tool parameters
 */
interface CreateNodeParams {
  parent_path: string;
  node_type: string;
  node_name: string;
  transaction_id?: string;
}

interface DeleteNodeParams {
  node_path: string;
  transaction_id?: string;
}

interface UpdateNodePropertyParams {
  node_path: string;
  property: string;
  value: any;
  transaction_id?: string;
}

interface GetNodePropertiesParams {
  node_path: string;
}

interface ListNodesParams {
  parent_path: string;
}

interface DuplicateNodeParams {
  source_path: string;
  parent_path?: string;
  new_name?: string;
  duplicate_groups?: boolean;
  duplicate_signals?: boolean;
  duplicate_scripts?: boolean;
  use_instantiation?: boolean;
  transaction_id?: string;
}

interface ReparentNodeParams {
  node_path: string;
  new_parent_path: string;
  keep_global_transform?: boolean;
  new_name?: string;
  child_index?: number;
  transaction_id?: string;
}

interface MoveNodeInParentParams {
  node_path: string;
  index: number;
  transaction_id?: string;
}

interface InstantiateSceneParams {
  scene_path: string;
  parent_path?: string;
  node_name?: string;
  transaction_id?: string;
}

interface QueryNodesParams {
  root_path?: string;
  name_contains?: string;
  node_type?: string;
  group_name?: string;
  include_root?: boolean;
  include_internal?: boolean;
  max_results?: number;
}

interface BulkUpdateNodePropertiesParams {
  node_path: string;
  properties: Record<string, unknown>;
  transaction_id?: string;
}

interface BatchCreateNodesParams {
  parent_path?: string;
  nodes: Array<{
    node_type: string;
    node_name?: string;
    properties?: Record<string, unknown>;
  }>;
  transaction_id?: string;
}

interface BatchDeleteNodesParams {
  node_paths: string[];
  transaction_id?: string;
}

interface SetNodeScriptParams {
  node_path: string;
  script_path: string;
  create_script?: boolean;
  extends_type?: string;
  transaction_id?: string;
}

interface ClearNodeScriptParams {
  node_path: string;
  transaction_id?: string;
}

interface SetNodeOwnerRecursiveParams {
  node_path: string;
  owner_path?: string;
  include_root?: boolean;
  transaction_id?: string;
}

interface PaintTileMapCells2DParams {
  node_path: string;
  layer?: number;
  cells: Array<{
    position?: { x: number; y: number } | [number, number];
    coords?: { x: number; y: number } | [number, number];
    x?: number;
    y?: number;
    source_id: number;
    atlas_coords?: { x: number; y: number } | [number, number];
    alternative_tile?: number;
  }>;
  transaction_id?: string;
}

interface ClearTileMapCells2DParams {
  node_path: string;
  layer?: number;
  cells: Array<
    | { position?: { x: number; y: number } | [number, number]; coords?: { x: number; y: number } | [number, number]; x?: number; y?: number }
    | { x: number; y: number }
    | [number, number]
  >;
  transaction_id?: string;
}

interface ConfigureCamera2DFollowParams {
  node_path: string;
  zoom?: { x?: number; y?: number } | [number, number];
  offset?: { x?: number; y?: number } | [number, number];
  enabled?: boolean;
  ignore_rotation?: boolean;
  position_smoothing_enabled?: boolean;
  position_smoothing_speed?: number;
  rotation_smoothing_enabled?: boolean;
  rotation_smoothing_speed?: number;
  drag_enabled?: { horizontal?: boolean; vertical?: boolean };
  drag_margins?: { left?: number; right?: number; top?: number; bottom?: number };
  drag_offsets?: { horizontal?: number; vertical?: number };
  transaction_id?: string;
}

interface ConfigureParallax2DParams {
  node_path: string;
  scroll_scale?: { x?: number; y?: number } | [number, number];
  scroll_offset?: { x?: number; y?: number } | [number, number];
  autoscroll?: { x?: number; y?: number } | [number, number];
  repeat_size?: { x?: number; y?: number } | [number, number];
  follow_viewport?: boolean;
  ignore_camera_scroll?: boolean;
  transaction_id?: string;
}

interface ConfigureAnimatedSprite2DParams {
  node_path: string;
  sprite_frames_path?: string;
  animation?: string;
  autoplay?: string;
  speed_scale?: number;
  centered?: boolean;
  offset?: { x?: number; y?: number } | [number, number];
  flip_h?: boolean;
  flip_v?: boolean;
  frame?: number;
  frame_progress?: number;
  transaction_id?: string;
}

interface ConfigureSprite2DParams {
  node_path: string;
  texture_path?: string;
  centered?: boolean;
  offset?: { x?: number; y?: number } | [number, number];
  flip_h?: boolean;
  flip_v?: boolean;
  hframes?: number;
  vframes?: number;
  frame?: number;
  frame_coords?: { x?: number; y?: number } | [number, number];
  region_enabled?: boolean;
  region_filter_clip_enabled?: boolean;
  region_rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  modulate?: unknown;
  self_modulate?: unknown;
  transaction_id?: string;
}

interface ConfigureCharacterBody2DControllerParams {
  node_path: string;
  up_direction?: { x?: number; y?: number } | [number, number];
  motion_mode?: number;
  floor_stop_on_slope?: boolean;
  floor_constant_speed?: boolean;
  floor_block_on_wall?: boolean;
  floor_snap_length?: number;
  floor_max_angle?: number;
  wall_min_slide_angle?: number;
  max_slides?: number;
  safe_margin?: number;
  slide_on_ceiling?: boolean;
  platform_on_leave?: number;
  platform_floor_layers?: number;
  platform_wall_layers?: number;
  transaction_id?: string;
}

interface ConfigureArea2DSensorParams {
  node_path: string;
  monitoring?: boolean;
  monitorable?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  priority?: number;
  gravity_space_override?: number;
  gravity_point?: boolean;
  gravity_point_center?: { x?: number; y?: number } | [number, number];
  gravity_point_unit_distance?: number;
  gravity_direction?: { x?: number; y?: number } | [number, number];
  gravity?: number;
  linear_damp_space_override?: number;
  linear_damp?: number;
  angular_damp_space_override?: number;
  angular_damp?: number;
  transaction_id?: string;
}

interface FillTileMapRect2DParams {
  node_path: string;
  layer?: number;
  origin?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  clear?: boolean;
  source_id?: number;
  atlas_coords?: { x?: number; y?: number } | [number, number];
  alternative_tile?: number;
  transaction_id?: string;
}

interface RenameNodeParams {
  node_path: string;
  new_name: string;
  transaction_id?: string;
}

interface NodeGroupParams {
  node_path: string;
  group_name: string;
  persistent?: boolean;
  transaction_id?: string;
}

interface RemoveNodeGroupParams extends NodeGroupParams {
  persistent?: boolean;
}

interface ListNodeGroupsParams {
  node_path: string;
}

interface ListNodesInGroupParams {
  group_name: string;
}

interface ConfigureCamera2DLimitsParams {
  node_path: string;
  transaction_id?: string;
  limits?: {
    enabled?: boolean;
    draw_limits?: boolean;
    smoothed?: boolean;
    left?: number;
    right?: number;
    top?: number;
    bottom?: number;
  };
  smoothing?: {
    position_enabled?: boolean;
    position_speed?: number;
    rotation_enabled?: boolean;
    rotation_speed?: number;
  };
}

const hasConfigurationEntries = (value: Record<string, unknown> | undefined): value is Record<string, unknown> =>
  !!value && Object.values(value).some(entry => entry !== undefined);

interface ThemeOverrideParams {
  node_path: string;
  override_type: 'color' | 'constant' | 'font' | 'font_size' | 'stylebox' | 'icon';
  override_name: string;
  value?: unknown;
  resource_path?: string;
  transaction_id?: string;
}

interface WireSignalHandlerParams {
  source_path: string;
  signal_name: string;
  target_path: string;
  method_name: string;
  script_path?: string;
  create_script?: boolean;
  arguments?: string[];
  binds?: unknown[];
  deferred?: boolean;
  one_shot?: boolean;
  reference_counted?: boolean;
  transaction_id?: string;
}

interface LayoutUiGridParams {
  container_path: string;
  columns?: number;
  horizontal_gap?: number;
  vertical_gap?: number;
  cell_size?: { x?: number; y?: number } | [number, number];
  size_flags?: { horizontal?: number; vertical?: number };
  transaction_id?: string;
}

interface ValidateAccessibilityParams {
  root_path?: string;
  include_hidden?: boolean;
  max_depth?: number;
}

const camera2DLimitsSchema = z
  .object({
    enabled: z.boolean().optional().describe('Enable or disable Camera2D limits.'),
    draw_limits: z.boolean().optional().describe('Toggle visualization of Camera2D limits in the editor.'),
    smoothed: z.boolean().optional().describe('Enable smoothing when the camera hits configured limits.'),
    left: z.number().int().optional().describe('Left boundary in pixels.'),
    right: z.number().int().optional().describe('Right boundary in pixels.'),
    top: z.number().int().optional().describe('Top boundary in pixels.'),
    bottom: z.number().int().optional().describe('Bottom boundary in pixels.'),
  })
  .refine(value => Object.values(value).some(entry => entry !== undefined), {
    message: 'Provide at least one limit property to update.',
  });

const camera2DSmoothingSchema = z
  .object({
    position_enabled: z.boolean().optional().describe('Enable position smoothing for Camera2D.'),
    position_speed: z
      .number()
      .nonnegative()
      .optional()
      .describe('Smoothing speed used when moving towards the target position.'),
    rotation_enabled: z.boolean().optional().describe('Enable rotation smoothing for Camera2D.'),
    rotation_speed: z
      .number()
      .nonnegative()
      .optional()
      .describe('Smoothing speed used when rotating towards the target angle.'),
  })
  .refine(value => Object.values(value).some(entry => entry !== undefined), {
    message: 'Provide at least one smoothing property to update.',
  });

/**
 * Definition for node tools - operations that manipulate nodes in the scene tree
 */
export const nodeTools: MCPTool[] = [
  {
    name: 'create_node',
    description: 'Create a new node in the Godot scene tree',
    parameters: z.object({
      parent_path: z.string()
        .describe('Path to the parent node where the new node will be created (e.g. "/root", "/root/MainScene")'),
      node_type: z.string()
        .describe('Type of node to create (e.g. "Node2D", "Sprite2D", "Label")'),
      node_name: z.string()
        .describe('Name for the new node'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ parent_path, node_type, node_name, transaction_id }: CreateNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('create_node', {
          parent_path,
          node_type,
          node_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        return `Created ${node_type} node named "${node_name}" at ${result.node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to create node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'delete_node',
    description: 'Delete a node from the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to delete (e.g. "/root/MainScene/Player")'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ node_path, transaction_id }: DeleteNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('delete_node', { node_path, transaction_id });
        const status = (result?.status as string) ?? 'committed';
        return `Deleted node at ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to delete node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'update_node_property',
    description: 'Update a property of a node in the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to update (e.g. "/root/MainScene/Player")'),
      property: z.string()
        .describe('Name of the property to update (e.g. "position", "text", "modulate")'),
      value: z.any()
        .describe('New value for the property'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ node_path, property, value, transaction_id }: UpdateNodePropertyParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('update_node_property', {
          node_path,
          property,
          value,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        return `Updated property "${property}" of node at ${node_path} to ${JSON.stringify(value)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to update node property: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'get_node_properties',
    description: 'Get all properties of a node in the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to inspect (e.g. "/root/MainScene/Player")'),
    }),
    execute: async ({ node_path }: GetNodePropertiesParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('get_node_properties', { node_path });
        
        // Format properties for display
        const formattedProperties = Object.entries(result.properties)
          .map(([key, value]) => `${key}: ${JSON.stringify(value)}`)
          .join('\n');
        
        return `Properties of node at ${node_path}:\n\n${formattedProperties}`;
      } catch (error) {
        throw new Error(`Failed to get node properties: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },

  {
    name: 'list_nodes',
    description: 'List all child nodes under a parent node in the Godot scene tree',
    parameters: z.object({
      parent_path: z.string()
        .describe('Path to the parent node (e.g. "/root", "/root/MainScene")'),
    }),
    execute: async ({ parent_path }: ListNodesParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('list_nodes', { parent_path });
        
        if (result.children.length === 0) {
          return `No child nodes found under ${parent_path}`;
        }
        
        // Format children for display
        const formattedChildren = result.children
          .map((child: any) => `${child.name} (${child.type}) - ${child.path}`)
          .join('\n');
        
        return `Children of node at ${parent_path}:\n\n${formattedChildren}`;
      } catch (error) {
        throw new Error(`Failed to list nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'duplicate_node',
    description: 'Duplicate an existing node subtree with configurable copy flags',
    parameters: z.object({
      source_path: z.string()
        .describe('Path to the node that should be duplicated'),
      parent_path: z.string().optional()
        .describe('Optional target parent path (defaults to the source parent)'),
      new_name: z.string().optional()
        .describe('Optional name for the duplicated node'),
      duplicate_groups: z.boolean().optional()
        .describe('Copy group membership (default true)'),
      duplicate_signals: z.boolean().optional()
        .describe('Copy signal connections (default true)'),
      duplicate_scripts: z.boolean().optional()
        .describe('Copy attached scripts (default true)'),
      use_instantiation: z.boolean().optional()
        .describe('Use scene instantiation semantics when duplicating subtrees'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      source_path,
      parent_path,
      new_name,
      duplicate_groups,
      duplicate_signals,
      duplicate_scripts,
      use_instantiation,
      transaction_id,
    }: DuplicateNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('duplicate_node', {
          source_path,
          parent_path,
          new_name,
          duplicate_groups,
          duplicate_signals,
          duplicate_scripts,
          use_instantiation,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const resolvedPath = (result.node_path as string) ?? source_path;
        const resolvedName = (result.node_name as string) ?? new_name ?? 'copy';
        return `Duplicated ${source_path} as ${resolvedName} at ${resolvedPath} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to duplicate node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'reparent_node',
    description: 'Move a node to a different parent with optional rename and index control',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to move'),
      new_parent_path: z.string()
        .describe('Path to the new parent node'),
      keep_global_transform: z.boolean().optional()
        .describe('Preserve global transform while reparenting (default true)'),
      new_name: z.string().optional()
        .describe('Optional new node name when moved under the new parent'),
      child_index: z.number().int().min(0).optional()
        .describe('Optional index in the new parent child list'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      new_parent_path,
      keep_global_transform,
      new_name,
      child_index,
      transaction_id,
    }: ReparentNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('reparent_node', {
          node_path,
          new_parent_path,
          keep_global_transform,
          new_name,
          child_index,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} is already at the requested parent and ordering.`;
        }

        const resolvedPath = (result.node_path as string) ?? node_path;
        const resolvedParent = (result.new_parent_path as string) ?? new_parent_path;
        const resolvedIndex = result.new_index ?? child_index ?? 'auto';
        return `Reparented ${resolvedPath} to ${resolvedParent} at index ${resolvedIndex} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to reparent node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'move_node_in_parent',
    description: 'Reorder a node within its current parent',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should be reordered'),
      index: z.number().int().min(0)
        .describe('Target index in the parent child array'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, index, transaction_id }: MoveNodeInParentParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('move_node_in_parent', {
          node_path,
          index,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} is already at index ${result.index ?? index}.`;
        }

        const resolvedPath = (result.node_path as string) ?? node_path;
        const resolvedIndex = result.index ?? index;
        return `Moved ${resolvedPath} to index ${resolvedIndex} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to move node in parent: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'instantiate_scene',
    description: 'Instantiate a PackedScene and add it under a parent node',
    parameters: z.object({
      scene_path: z.string()
        .describe('PackedScene resource path (e.g. "res://scenes/enemy.tscn")'),
      parent_path: z.string().optional()
        .describe('Optional parent node path (defaults to "/root")'),
      node_name: z.string().optional()
        .describe('Optional name for the instantiated root node'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ scene_path, parent_path, node_name, transaction_id }: InstantiateSceneParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('instantiate_scene', {
          scene_path,
          parent_path,
          node_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const resolvedPath = (result.node_path as string) ?? `${parent_path ?? '/root'}/${node_name ?? 'Instance'}`;
        return `Instantiated ${scene_path} at ${resolvedPath} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to instantiate scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'query_nodes',
    description: 'Search scene nodes by name, type, and group filters',
    parameters: z.object({
      root_path: z.string().optional()
        .describe('Optional root path to search from (defaults to "/root")'),
      name_contains: z.string().optional()
        .describe('Match nodes whose names contain this text (case-insensitive)'),
      node_type: z.string().optional()
        .describe('Match nodes by class name (supports inherited classes)'),
      group_name: z.string().optional()
        .describe('Match nodes in a specific group'),
      include_root: z.boolean().optional()
        .describe('Include the root node in the query evaluation (default true)'),
      include_internal: z.boolean().optional()
        .describe('Include internal children in traversal (default false)'),
      max_results: z.number().int().min(1).max(5000).optional()
        .describe('Maximum number of matched nodes to return (default 500)'),
    }),
    execute: async ({
      root_path,
      name_contains,
      node_type,
      group_name,
      include_root,
      include_internal,
      max_results,
    }: QueryNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('query_nodes', {
          root_path,
          name_contains,
          node_type,
          group_name,
          include_root,
          include_internal,
          max_results,
        });

        const nodes = (result.nodes as Array<Record<string, unknown>>) ?? [];
        const count = Number(result.count ?? nodes.length);
        const target = (result.root_path as string) ?? root_path ?? '/root';
        if (nodes.length === 0) {
          return `No nodes matched the query under ${target}.`;
        }

        const lines = nodes
          .map(node => `${node.name} (${node.type}) - ${node.path}`)
          .join('\n');
        const truncated = Boolean(result.truncated);
        return `Query matched ${count} node(s) under ${target}${truncated ? ' (truncated)' : ''}:\n${lines}`;
      } catch (error) {
        throw new Error(`Failed to query nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'bulk_update_node_properties',
    description: 'Apply multiple node property updates in one undo-aware operation',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to update'),
      properties: z.record(z.any())
        .refine(value => Object.keys(value).length > 0, {
          message: 'Provide at least one property update.',
        })
        .describe('Property map where keys are property paths (e.g. "position.x")'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, properties, transaction_id }: BulkUpdateNodePropertiesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('bulk_update_node_properties', {
          node_path,
          properties,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Bulk update on ${node_path} had no effective property changes.`;
        }

        const changes = (result.changes as Array<Record<string, unknown>>) ?? [];
        return `Bulk updated ${node_path} with ${changes.length} property change(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to bulk update node properties: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'batch_create_nodes',
    description: 'Create multiple child nodes in one undo-aware operation',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path where all nodes should be created (defaults to "/root")'),
      nodes: z.array(z.object({
        node_type: z.string()
          .describe('Godot node type such as Node2D, Node3D, Label, etc.'),
        node_name: z.string().optional()
          .describe('Optional preferred node name; the server will resolve conflicts.'),
        properties: z.record(z.any()).optional()
          .describe('Optional property map applied to the node after instantiation.'),
      })).min(1)
        .describe('List of nodes to create'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ parent_path, nodes, transaction_id }: BatchCreateNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('batch_create_nodes', {
          parent_path,
          nodes,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const count = Number(result.count ?? (Array.isArray(result.created_nodes) ? result.created_nodes.length : nodes.length));
        const resolvedParent = (result.parent_path as string) ?? parent_path ?? '/root';
        return `Batch created ${count} node(s) under ${resolvedParent} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to batch create nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'batch_delete_nodes',
    description: 'Delete multiple nodes in one undo-aware operation',
    parameters: z.object({
      node_paths: z.array(z.string()).min(1)
        .describe('Node paths to delete'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_paths, transaction_id }: BatchDeleteNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('batch_delete_nodes', {
          node_paths,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const deletedCount = Number(result.deleted_count ?? 0);
        const skipped = Array.isArray(result.skipped_descendants) ? result.skipped_descendants.length : 0;
        return `Batch deleted ${deletedCount} node(s) [${status}]${skipped > 0 ? `; skipped ${skipped} descendant duplicates` : ''}`;
      } catch (error) {
        throw new Error(`Failed to batch delete nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_node_script',
    description: 'Assign a script resource to a node with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Node path to receive the script'),
      script_path: z.string()
        .describe('Script resource path in the project (res://...)'),
      create_script: z.boolean().optional()
        .describe('Create the script file if it does not exist'),
      extends_type: z.string().optional()
        .describe('Extends type used when creating a new script'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      script_path,
      create_script,
      extends_type,
      transaction_id,
    }: SetNodeScriptParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_node_script', {
          node_path,
          script_path,
          create_script,
          extends_type,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} already uses script ${script_path}.`;
        }
        return `Assigned script ${script_path} to ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set node script: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'clear_node_script',
    description: 'Remove the assigned script from a node',
    parameters: z.object({
      node_path: z.string()
        .describe('Node path whose script should be cleared'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, transaction_id }: ClearNodeScriptParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('clear_node_script', {
          node_path,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} does not have an assigned script.`;
        }
        return `Cleared script from ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to clear node script: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_node_owner_recursive',
    description: 'Set owner for a node subtree so edits persist in the scene file',
    parameters: z.object({
      node_path: z.string()
        .describe('Root node of the subtree to update'),
      owner_path: z.string().optional()
        .describe('Owner node path (defaults to "/root")'),
      include_root: z.boolean().optional()
        .describe('Whether to apply owner changes to the root node itself (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      owner_path,
      include_root,
      transaction_id,
    }: SetNodeOwnerRecursiveParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_node_owner_recursive', {
          node_path,
          owner_path,
          include_root,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changedCount = Number(result.changed_count ?? 0);
        if (status === 'no_change') {
          return `Node ownership under ${node_path} already matches ${result.owner_path ?? owner_path ?? '/root'}.`;
        }
        return `Updated owner for ${changedCount} node(s) under ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set node owner recursively: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'paint_tilemap_cells_2d',
    description: 'Paint TileMapLayer or TileMap cells for 2D level authoring',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to a TileMapLayer or TileMap node'),
      layer: z.number().int().min(0).optional()
        .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
      cells: z.array(z.object({
        position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        x: z.number().optional(),
        y: z.number().optional(),
        source_id: z.number().int(),
        atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        alternative_tile: z.number().int().optional(),
      })).min(1)
        .describe('Cell paint operations'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, layer, cells, transaction_id }: PaintTileMapCells2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('paint_tilemap_cells_2d', {
          node_path,
          layer,
          cells,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `Tile paint on ${node_path} produced no effective changes.`;
        }
        return `Painted ${changed} TileMap cell(s) on ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to paint TileMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'clear_tilemap_cells_2d',
    description: 'Clear TileMapLayer or TileMap cells for 2D level authoring',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to a TileMapLayer or TileMap node'),
      layer: z.number().int().min(0).optional()
        .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
      cells: z.array(z.union([
        z.object({
          position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
          coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
          x: z.number().optional(),
          y: z.number().optional(),
        }),
        z.tuple([z.number(), z.number()]),
      ])).min(1)
        .describe('Cell coordinates to clear'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, layer, cells, transaction_id }: ClearTileMapCells2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('clear_tilemap_cells_2d', {
          node_path,
          layer,
          cells,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `Tile clear on ${node_path} produced no effective changes.`;
        }
        return `Cleared ${changed} TileMap cell(s) on ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to clear TileMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_camera2d_follow',
    description: 'Configure Camera2D follow behavior for 2D gameplay',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Camera2D node'),
      zoom: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      enabled: z.boolean().optional(),
      ignore_rotation: z.boolean().optional(),
      position_smoothing_enabled: z.boolean().optional(),
      position_smoothing_speed: z.number().optional(),
      rotation_smoothing_enabled: z.boolean().optional(),
      rotation_smoothing_speed: z.number().optional(),
      drag_enabled: z.object({ horizontal: z.boolean().optional(), vertical: z.boolean().optional() }).optional(),
      drag_margins: z.object({ left: z.number().optional(), right: z.number().optional(), top: z.number().optional(), bottom: z.number().optional() }).optional(),
      drag_offsets: z.object({ horizontal: z.number().optional(), vertical: z.number().optional() }).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCamera2DFollowParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_camera2d_follow', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Camera2D at ${args.node_path} already matches requested follow settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Camera2D follow on ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Camera2D follow: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_parallax_2d',
    description: 'Configure Parallax2D scrolling properties for layered backgrounds',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Parallax2D node'),
      scroll_scale: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      scroll_offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      autoscroll: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      repeat_size: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      follow_viewport: z.boolean().optional(),
      ignore_camera_scroll: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureParallax2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_parallax_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Parallax2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Parallax2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Parallax2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_animated_sprite_2d',
    description: 'Configure AnimatedSprite2D resources and playback-related properties',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the AnimatedSprite2D node'),
      sprite_frames_path: z.string().optional()
        .describe('Optional SpriteFrames resource path (res://...)'),
      animation: z.string().optional()
        .describe('Animation name from the SpriteFrames resource'),
      autoplay: z.string().optional()
        .describe('Autoplay animation name'),
      speed_scale: z.number().optional(),
      centered: z.boolean().optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      flip_h: z.boolean().optional(),
      flip_v: z.boolean().optional(),
      frame: z.number().int().optional(),
      frame_progress: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureAnimatedSprite2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_animated_sprite_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `AnimatedSprite2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured AnimatedSprite2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure AnimatedSprite2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_sprite_2d',
    description: 'Configure Sprite2D texture and rendering properties',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Sprite2D node'),
      texture_path: z.string().optional()
        .describe('Texture2D resource path (res://...) or empty string to clear'),
      centered: z.boolean().optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      flip_h: z.boolean().optional(),
      flip_v: z.boolean().optional(),
      hframes: z.number().int().min(1).optional(),
      vframes: z.number().int().min(1).optional(),
      frame: z.number().int().min(0).optional(),
      frame_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
      region_enabled: z.boolean().optional(),
      region_filter_clip_enabled: z.boolean().optional(),
      region_rect: z.union([
        z.object({
          position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          x: z.number().optional(),
          y: z.number().optional(),
          width: z.number().optional(),
          height: z.number().optional(),
        }),
        z.tuple([z.number(), z.number(), z.number(), z.number()]),
      ]).optional(),
      modulate: z.any().optional(),
      self_modulate: z.any().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureSprite2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_sprite_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Sprite2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Sprite2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Sprite2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_characterbody2d_controller',
    description: 'Configure CharacterBody2D movement/controller properties for 2D platformers',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody2D node'),
      up_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      motion_mode: z.number().int().optional(),
      floor_stop_on_slope: z.boolean().optional(),
      floor_constant_speed: z.boolean().optional(),
      floor_block_on_wall: z.boolean().optional(),
      floor_snap_length: z.number().optional(),
      floor_max_angle: z.number().optional(),
      wall_min_slide_angle: z.number().optional(),
      max_slides: z.number().int().min(1).optional(),
      safe_margin: z.number().nonnegative().optional(),
      slide_on_ceiling: z.boolean().optional(),
      platform_on_leave: z.number().int().optional(),
      platform_floor_layers: z.number().int().optional(),
      platform_wall_layers: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCharacterBody2DControllerParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_characterbody2d_controller', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `CharacterBody2D at ${args.node_path} already matches requested controller settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured CharacterBody2D controller at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure CharacterBody2D controller: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_area2d_sensor',
    description: 'Configure Area2D sensor/field behavior for triggers and environmental effects',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Area2D node'),
      monitoring: z.boolean().optional(),
      monitorable: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      priority: z.number().optional(),
      gravity_space_override: z.number().int().optional(),
      gravity_point: z.boolean().optional(),
      gravity_point_center: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      gravity_point_unit_distance: z.number().optional(),
      gravity_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      gravity: z.number().optional(),
      linear_damp_space_override: z.number().int().optional(),
      linear_damp: z.number().optional(),
      angular_damp_space_override: z.number().int().optional(),
      angular_damp: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureArea2DSensorParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_area2d_sensor', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Area2D at ${args.node_path} already matches requested sensor settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Area2D sensor at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Area2D sensor: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'fill_tilemap_rect_2d',
    description: 'Fill or clear a rectangular TileMap region for rapid 2D level layout',
    parameters: z
      .object({
        node_path: z.string()
          .describe('Path to a TileMapLayer or TileMap node'),
        layer: z.number().int().min(0).optional()
          .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
        origin: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
          .describe('Rectangle origin in cell coordinates'),
        size: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
          .describe('Rectangle size in cell units'),
        rect: z.union([
          z.object({
            position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            x: z.number().optional(),
            y: z.number().optional(),
            width: z.number().optional(),
            height: z.number().optional(),
          }),
          z.tuple([z.number(), z.number(), z.number(), z.number()]),
        ]).optional()
          .describe('Alternative rectangle descriptor'),
        clear: z.boolean().optional()
          .describe('Clear cells instead of painting tile values'),
        source_id: z.number().int().optional()
          .describe('Tile source id (required unless clear=true)'),
        atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        alternative_tile: z.number().int().optional(),
        transaction_id: z.string().optional(),
      })
      .superRefine((value, ctx) => {
        if (!value.rect && (!value.origin || !value.size)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide either rect or both origin and size.',
            path: ['rect'],
          });
        }
        if (!value.clear && value.source_id === undefined) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'source_id is required unless clear=true.',
            path: ['source_id'],
          });
        }
      }),
    execute: async (args: FillTileMapRect2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('fill_tilemap_rect_2d', args);
        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `TileMap fill on ${args.node_path} produced no effective changes.`;
        }
        return `${args.clear ? 'Cleared' : 'Filled'} ${changed} TileMap cell(s) on ${args.node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to fill TileMap rect: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'rename_node',
    description: 'Rename an existing node while preserving undo history',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should be renamed (e.g. "/root/MainScene/Player")'),
      new_name: z.string()
        .min(1)
        .describe('New name for the node'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, new_name, transaction_id }: RenameNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('rename_node', {
          node_path,
          new_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node at ${node_path} already has the name "${new_name}".`;
        }

        const previousName = (result.previous_name as string) ?? node_path.split('/').pop() ?? node_path;
        return `Renamed node ${previousName} to ${result.new_name} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to rename node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'add_node_to_group',
    description: 'Add a node to a Godot group with optional persistence for scene saving',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should join the group (e.g. "/root/MainScene/Enemy")'),
      group_name: z.string()
        .min(1)
        .describe('Group name to assign (case-sensitive)'),
      persistent: z.boolean().optional()
        .describe('Whether the membership should be stored in the scene file (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, group_name, persistent, transaction_id }: NodeGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('add_node_to_group', {
          node_path,
          group_name,
          persistent,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'already_member') {
          return `Node at ${node_path} is already in group "${group_name}".`;
        }

        return `Added node ${node_path} to group "${group_name}" [${status}]`;
      } catch (error) {
        throw new Error(`Failed to add node to group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'remove_node_from_group',
    description: 'Remove a node from a Godot group with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node whose group membership should be removed'),
      group_name: z.string()
        .min(1)
        .describe('Group name to remove from the node'),
      persistent: z.boolean().optional()
        .describe('Whether undo should restore the membership as persistent (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, group_name, persistent, transaction_id }: RemoveNodeGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('remove_node_from_group', {
          node_path,
          group_name,
          persistent,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'not_member') {
          return `Node at ${node_path} is not part of group "${group_name}".`;
        }

        return `Removed node ${node_path} from group "${group_name}" [${status}]`;
      } catch (error) {
        throw new Error(`Failed to remove node from group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_camera2d_limits',
    description:
      'Adjust Camera2D limit bounds, smoothing, and editor visualization using undo-aware transactions.',
    parameters: z
      .object({
        node_path: z
          .string()
          .describe('Path to the Camera2D node that should be configured (e.g. "/root/MainScene/Camera2D")'),
        transaction_id: z
          .string()
          .optional()
          .describe('Optional scene transaction identifier used to batch operations before committing.'),
        limits: camera2DLimitsSchema.optional(),
        smoothing: camera2DSmoothingSchema.optional(),
      })
      .superRefine((value, ctx) => {
        const hasLimits = value.limits !== undefined;
        const hasSmoothing = value.smoothing !== undefined;
        if (!hasLimits && !hasSmoothing) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide limits or smoothing properties to update.',
            path: ['limits'],
          });
        }
      }),
    execute: async ({ node_path, transaction_id, limits, smoothing }: ConfigureCamera2DLimitsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const payload: Record<string, unknown> = { node_path };
        if (transaction_id) {
          payload.transaction_id = transaction_id;
        }
        if (hasConfigurationEntries(limits)) {
          payload.limits = limits;
        }
        if (hasConfigurationEntries(smoothing)) {
          payload.smoothing = smoothing;
        }

        const result = await godot.sendCommand<CommandResult>('configure_camera2d_limits', payload);

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Camera2D at ${node_path} already matches the requested configuration.`;
        }

        const changeSummary = Array.isArray(result.changes)
          ? (result.changes as Array<Record<string, unknown>>)
              .map(change => `${change.property}: ${JSON.stringify(change.value)}`)
              .join(', ')
          : undefined;

        const suffix = changeSummary && changeSummary.length > 0 ? ` (${changeSummary})` : '';
        return `Configured Camera2D limits for ${result.node_path ?? node_path} [${status}]${suffix}`;
      } catch (error) {
        throw new Error(`Failed to configure Camera2D limits: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
      escalationPrompt:
        'The assistant is requesting to modify Camera2D boundaries and smoothing. Approve if the scene should adopt these camera constraints.',
    },
  },
  {
    name: 'create_theme_override',
    description: 'Create or update a Control theme override with undo support.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the Control node that should receive the theme override.'),
      override_type: z
        .enum(['color', 'constant', 'font', 'font_size', 'stylebox', 'icon'])
        .describe('Type of override to apply.'),
      override_name: z
        .string()
        .describe('Theme item name such as "font_color", "panel", or "normal".'),
      value: z
        .any()
        .optional()
        .describe('Override value. Colors accept HTML strings or RGBA dictionaries; resource overrides accept paths.'),
      resource_path: z
        .string()
        .optional()
        .describe('Resource path for font, icon, or stylebox overrides when different from `value`.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      node_path,
      override_type,
      override_name,
      value,
      resource_path,
      transaction_id,
    }: ThemeOverrideParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('create_theme_override', {
          node_path,
          override_type,
          override_name,
          value,
          resource_path,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const appliedValue = result.value ?? result.applied_value ?? value;
        const valueDescription = appliedValue === undefined ? 'inherit' : JSON.stringify(appliedValue);
        const resolvedName = (result.override_name as string) ?? override_name;
        const resolvedType = (result.override_type as string) ?? override_type;
        const resolvedPath = (result.node_path as string) ?? node_path;
        return `Theme override ${resolvedName} (${resolvedType}) applied to ${resolvedPath} [${status}] -> ${valueDescription}`;
      } catch (error) {
        throw new Error(`Failed to create theme override: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'wire_signal_handler',
    description: 'Connect a signal between nodes and generate method stubs when needed.',
    parameters: z.object({
      source_path: z
        .string()
        .describe('Node emitting the signal (e.g. "/root/Main/StartButton").'),
      signal_name: z
        .string()
        .describe('Name of the signal to connect (e.g. "pressed").'),
      target_path: z
        .string()
        .describe('Node that should receive the callback.'),
      method_name: z
        .string()
        .describe('Method to invoke on the target node when the signal fires.'),
      script_path: z
        .string()
        .optional()
        .describe('Optional script resource to assign before connecting the signal.'),
      create_script: z
        .boolean()
        .optional()
        .describe('Create a new script at `script_path` if none is assigned.'),
      arguments: z
        .array(z.string())
        .optional()
        .describe('Argument names to include in the generated stub.'),
      binds: z
        .array(z.any())
        .optional()
        .describe('Optional values to bind to the signal connection.'),
      deferred: z
        .boolean()
        .optional()
        .describe('Connect the signal in deferred mode.'),
      one_shot: z
        .boolean()
        .optional()
        .describe('Connect the signal in one-shot mode.'),
      reference_counted: z
        .boolean()
        .optional()
        .describe('Use reference-counted connections that disconnect when either side is freed.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      source_path,
      signal_name,
      target_path,
      method_name,
      script_path,
      create_script,
      arguments: argumentNames,
      binds,
      deferred,
      one_shot,
      reference_counted,
      transaction_id,
    }: WireSignalHandlerParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('wire_signal_handler', {
          source_path,
          signal_name,
          target_path,
          method_name,
          script_path,
          create_script,
          arguments: argumentNames,
          binds,
          deferred,
          one_shot,
          reference_counted,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const stubInfo = result.stub_created ? 'stub generated' : 'existing method';
        return `Connected ${signal_name} on ${source_path} -> ${method_name} [${status}; ${stubInfo}]`;
      } catch (error) {
        throw new Error(`Failed to wire signal handler: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'layout_ui_grid',
    description: 'Arrange Control children into a grid layout with consistent spacing.',
    parameters: z.object({
      container_path: z
        .string()
        .describe('Path to the container Control whose children should be arranged.'),
      columns: z
        .number()
        .int()
        .min(1)
        .optional()
        .describe('Number of columns to use (default 2).'),
      horizontal_gap: z
        .number()
        .optional()
        .describe('Horizontal spacing between columns in pixels.'),
      vertical_gap: z
        .number()
        .optional()
        .describe('Vertical spacing between rows in pixels.'),
      cell_size: z
        .union([
          z.object({ x: z.number().optional(), y: z.number().optional() }),
          z.tuple([z.number(), z.number()]),
        ])
        .optional()
        .describe('Uniform cell size expressed as `{ x, y }` or `[width, height]`.'),
      size_flags: z
        .object({ horizontal: z.number().optional(), vertical: z.number().optional() })
        .optional()
        .describe('Override size flags for child controls.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      container_path,
      columns,
      horizontal_gap,
      vertical_gap,
      cell_size,
      size_flags,
      transaction_id,
    }: LayoutUiGridParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('layout_ui_grid', {
          container_path,
          columns,
          horizontal_gap,
          vertical_gap,
          cell_size,
          size_flags,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const updated = Array.isArray(result.updated_nodes) ? result.updated_nodes.length : 0;
        return `Applied grid layout to ${container_path} (${updated} controls) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to layout UI grid: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'validate_accessibility',
    description: 'Scan Control nodes for accessibility gaps such as missing focus or descriptions.',
    parameters: z.object({
      root_path: z
        .string()
        .optional()
        .describe('Root node to scan (defaults to the edited scene root).'),
      include_hidden: z
        .boolean()
        .optional()
        .describe('Include hidden controls in the scan.'),
      max_depth: z
        .number()
        .int()
        .nonnegative()
        .optional()
        .describe('Limit the traversal depth (0 means unlimited).'),
    }),
    execute: async ({ root_path, include_hidden, max_depth }: ValidateAccessibilityParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('validate_accessibility', {
          root_path,
          include_hidden,
          max_depth,
        });

        const issueCount = Number(result.issue_count ?? result.issues?.length ?? 0);
        const scanned = Number(result.scanned_count ?? 0);
        const target = root_path ?? 'scene';
        return `Accessibility scan for ${target} inspected ${scanned} controls and found ${issueCount} issues.`;
      } catch (error) {
        throw new Error(`Failed to validate accessibility: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_node_groups',
    description: 'List all groups assigned to a specific node',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node whose groups should be listed'),
    }),
    execute: async ({ node_path }: ListNodeGroupsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_node_groups', { node_path });
        const groups = (result.groups as string[]) ?? [];
        if (groups.length === 0) {
          return `Node at ${node_path} is not assigned to any groups.`;
        }

        return `Groups for node ${node_path}:\n${groups.join('\n')}`;
      } catch (error) {
        throw new Error(`Failed to list node groups: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_nodes_in_group',
    description: 'Enumerate all nodes in the currently edited scene that belong to a specific group',
    parameters: z.object({
      group_name: z.string()
        .min(1)
        .describe('Group name to query'),
    }),
    execute: async ({ group_name }: ListNodesInGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_nodes_in_group', { group_name });
        const nodes = (result.nodes as Array<Record<string, unknown>>) ?? [];
        if (nodes.length === 0) {
          return `No nodes found in group "${group_name}".`;
        }

        const formatted = nodes
          .map(node => `${node.name} (${node.type}) - ${node.path}`)
          .join('\n');

        return `Nodes in group "${group_name}":\n${formatted}`;
      } catch (error) {
        throw new Error(`Failed to list nodes in group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
];
