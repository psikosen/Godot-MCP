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

/**
 * Definition for node tools - operations that manipulate nodes in the scene tree
 */
export const nodeTools: MCPTool[] = [
  {
    name: 'create_node',
    description: 'Create a new node in the Godot scene tree',
    capability: {
      role: 'write',
      escalationMessage: 'Adds a new node instance to the active scene tree.',
    },
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
  },

  {
    name: 'delete_node',
    description: 'Delete a node from the Godot scene tree',
    capability: {
      role: 'admin',
      escalationMessage: 'Removes an existing node and its children from the scene tree.',
    },
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
  },

  {
    name: 'update_node_property',
    description: 'Update a property of a node in the Godot scene tree',
    capability: {
      role: 'write',
      escalationMessage: 'Mutates serialized properties on nodes inside the scene tree.',
    },
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
  },

  {
    name: 'get_node_properties',
    description: 'Get all properties of a node in the Godot scene tree',
    capability: {
      role: 'read',
      escalationMessage: 'Reads properties from a node without modifying project state.',
    },
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
  },

  {
    name: 'list_nodes',
    description: 'List all child nodes under a parent node in the Godot scene tree',
    capability: {
      role: 'read',
      escalationMessage: 'Enumerates child nodes beneath a parent path.',
    },
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
  },
];
