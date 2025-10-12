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