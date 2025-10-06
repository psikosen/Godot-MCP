import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

/**
 * Type definitions for scene tool parameters
 */
interface SaveSceneParams {
  path?: string;
}

interface OpenSceneParams {
  path: string;
}

interface CreateSceneParams {
  path: string;
  root_node_type?: string;
}

interface BeginSceneTransactionParams {
  action_name?: string;
  transaction_id?: string;
  metadata?: Record<string, any>;
}

interface CommitSceneTransactionParams {
  transaction_id: string;
}

interface RollbackSceneTransactionParams {
  transaction_id: string;
}

interface CreateResourceParams {
  resource_type: string;
  resource_path: string;
  properties?: Record<string, any>;
}

interface ConfigurePhysicsNodeParams {
  node_path: string;
  properties: Record<string, unknown>;
  transaction_id?: string;
}

const physicsPropertiesSchema = z
  .record(z.any())
  .refine((props) => Object.keys(props).length > 0, {
    message: 'At least one property must be provided',
  });

const formatVariant = (value: unknown): string => {
  if (value === null || value === undefined) {
    return 'null';
  }

  if (typeof value === 'object') {
    try {
      return JSON.stringify(value);
    } catch (error) {
      return String(value);
    }
  }

  return String(value);
};

const formatPhysicsResponse = (
  kind: 'body' | 'area' | 'joint',
  result: CommandResult,
): string => {
  const nodePath = (result.node_path as string) ?? 'unknown node';
  const nodeType = (result.node_type as string) ?? 'UnknownNode';
  const dimension = (result.dimension as string) ?? 'unknown';
  const status = (result.status as string) ?? 'pending';
  const transactionId = result.transaction_id ? ` (transaction ${result.transaction_id})` : '';
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  if (changes.length === 0) {
    return `No ${kind} properties changed for ${nodeType} at ${nodePath} (${dimension})${transactionId}; status=${status}`;
  }

  const changeLines = changes
    .map((change) => {
      const property = change.property ?? 'property';
      const newValue = formatVariant(change.new_value ?? change.parsed_value ?? change.input_value);
      const previousValue = formatVariant(change.old_value ?? '');
      const newType = change.new_type ? ` [${change.new_type}]` : '';
      return `- ${property}${newType}: ${previousValue} -> ${newValue}`;
    })
    .join('\n');

  return `Updated ${kind} ${nodeType} at ${nodePath} (${dimension})${transactionId} [${status}]\n${changeLines}`;
};

/**
 * Definition for scene tools - operations that manipulate Godot scenes
 */
export const sceneTools: MCPTool[] = [
  {
    name: 'create_scene',
    description: 'Create a new empty scene with optional root node type',
    parameters: z.object({
      path: z.string()
        .describe('Path where the new scene will be saved (e.g. "res://scenes/new_scene.tscn")'),
      root_node_type: z.string().optional()
        .describe('Type of root node to create (e.g. "Node2D", "Node3D", "Control"). Defaults to "Node" if not specified'),
    }),
    execute: async ({ path, root_node_type = "Node" }: CreateSceneParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('create_scene', { path, root_node_type });
        return `Created new scene at ${result.scene_path} with root node type ${result.root_node_type}`;
      } catch (error) {
        throw new Error(`Failed to create scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'save_scene',
    description: 'Save the current scene to disk',
    parameters: z.object({
      path: z.string().optional()
        .describe('Path where the scene will be saved (e.g. "res://scenes/main.tscn"). If not provided, uses current scene path.'),
    }),
    execute: async ({ path }: SaveSceneParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('save_scene', { path });
        return `Saved scene to ${result.scene_path}`;
      } catch (error) {
        throw new Error(`Failed to save scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'open_scene',
    description: 'Open a scene in the editor',
    parameters: z.object({
      path: z.string()
        .describe('Path to the scene file to open (e.g. "res://scenes/main.tscn")'),
    }),
    execute: async ({ path }: OpenSceneParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('open_scene', { path });
        return `Opened scene at ${result.scene_path}`;
      } catch (error) {
        throw new Error(`Failed to open scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'get_current_scene',
    description: 'Get information about the currently open scene',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('get_current_scene', {});
        
        return `Current scene: ${result.scene_path}\nRoot node: ${result.root_node_name} (${result.root_node_type})`;
      } catch (error) {
        throw new Error(`Failed to get current scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },

  {
    name: 'get_project_info',
    description: 'Get information about the current Godot project',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('get_project_info', {});
        
        const godotVersion = `${result.godot_version.major}.${result.godot_version.minor}.${result.godot_version.patch}`;
        
        let output = `Project Name: ${result.project_name}\n`;
        output += `Project Version: ${result.project_version}\n`;
        output += `Project Path: ${result.project_path}\n`;
        output += `Godot Version: ${godotVersion}\n`;
        
        if (result.current_scene) {
          output += `Current Scene: ${result.current_scene}`;
        } else {
          output += "No scene is currently open";
        }
        
        return output;
      } catch (error) {
        throw new Error(`Failed to get project info: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },

  {
    name: 'create_resource',
    description: 'Create a new resource in the project',
    parameters: z.object({
      resource_type: z.string()
        .describe('Type of resource to create (e.g. "ImageTexture", "AudioStreamMP3", "StyleBoxFlat")'),
      resource_path: z.string()
        .describe('Path where the resource will be saved (e.g. "res://resources/style.tres")'),
      properties: z.record(z.any()).optional()
        .describe('Dictionary of property values to set on the resource'),
    }),
    execute: async ({ resource_type, resource_path, properties = {} }: CreateResourceParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('create_resource', {
          resource_type,
          resource_path,
          properties,
        });
        
        return `Created ${resource_type} resource at ${result.resource_path}`;
      } catch (error) {
        throw new Error(`Failed to create resource: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'begin_scene_transaction',
    description: 'Begin a new scene transaction to batch multiple operations before committing',
    parameters: z.object({
      action_name: z.string().optional()
        .describe('Optional action name used for the Godot Undo/Redo history entry'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier. A new one is generated if omitted.'),
      metadata: z.record(z.any()).optional()
        .describe('Optional metadata dictionary persisted with the transaction'),
    }),
    execute: async ({ action_name, transaction_id, metadata }: BeginSceneTransactionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('begin_scene_transaction', {
          action_name,
          transaction_id,
          metadata,
        });

        return `Began scene transaction ${result.transaction_id} (${result.action_name})`;
      } catch (error) {
        throw new Error(`Failed to begin scene transaction: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'commit_scene_transaction',
    description: 'Commit a previously started scene transaction',
    parameters: z.object({
      transaction_id: z.string()
        .describe('Identifier of the transaction to commit'),
    }),
    execute: async ({ transaction_id }: CommitSceneTransactionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('commit_scene_transaction', {
          transaction_id,
        });

        return `Committed scene transaction ${result.transaction_id}`;
      } catch (error) {
        throw new Error(`Failed to commit scene transaction: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'rollback_scene_transaction',
    description: 'Rollback a pending or committed scene transaction',
    parameters: z.object({
      transaction_id: z.string()
        .describe('Identifier of the transaction to rollback'),
    }),
    execute: async ({ transaction_id }: RollbackSceneTransactionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('rollback_scene_transaction', {
          transaction_id,
        });

        return `Rolled back scene transaction ${result.transaction_id} [${result.status}]`;
      } catch (error) {
        throw new Error(`Failed to rollback scene transaction: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'list_scene_transactions',
    description: 'List currently registered scene transaction identifiers',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_scene_transactions', {});

        const transactions = (result.transactions as string[]) ?? [];
        if (transactions.length === 0) {
          return 'No active scene transactions';
        }

        return `Active scene transactions:\n${transactions.join('\n')}`;
      } catch (error) {
        throw new Error(`Failed to list scene transactions: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },

  {
    name: 'configure_physics_body',
    description: 'Update PhysicsBody2D/3D nodes with undo/redo aware property changes',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the physics body node (e.g. "/root/MainScene/Player")'),
      properties: physicsPropertiesSchema.describe('Dictionary of physics properties to update'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple edits'),
    }),
    execute: async ({ node_path, properties, transaction_id }: ConfigurePhysicsNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_physics_body', {
          node_path,
          properties,
          transaction_id,
        });

        return formatPhysicsResponse('body', result);
      } catch (error) {
        throw new Error(`Failed to configure physics body: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'configure_physics_area',
    description: 'Update Area2D/Area3D monitoring and collision settings with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Area2D/Area3D node'),
      properties: physicsPropertiesSchema.describe('Dictionary of area properties to update'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple edits'),
    }),
    execute: async ({ node_path, properties, transaction_id }: ConfigurePhysicsNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_physics_area', {
          node_path,
          properties,
          transaction_id,
        });

        return formatPhysicsResponse('area', result);
      } catch (error) {
        throw new Error(`Failed to configure physics area: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'configure_physics_joint',
    description: 'Update Joint2D/Joint3D connections and limits with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the joint node to update'),
      properties: physicsPropertiesSchema.describe('Dictionary of joint properties to update'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple edits'),
    }),
    execute: async ({ node_path, properties, transaction_id }: ConfigurePhysicsNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_physics_joint', {
          node_path,
          properties,
          transaction_id,
        });

        return formatPhysicsResponse('joint', result);
      } catch (error) {
        throw new Error(`Failed to configure physics joint: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
