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