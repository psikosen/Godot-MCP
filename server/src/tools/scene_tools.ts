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

interface ConfigureCsgShapeParams {
  node_path: string;
  properties: Record<string, unknown>;
  transaction_id?: string;
}

interface GridMapPosition {
  x: number;
  y: number;
  z: number;
}

interface GridMapPaintCell {
  position?: GridMapPosition;
  x?: number;
  y?: number;
  z?: number;
  item: number;
  orientation?: number;
}

interface PaintGridMapCellsParams {
  node_path: string;
  cells: GridMapPaintCell[];
  transaction_id?: string;
}

interface GridMapClearCell {
  position?: GridMapPosition;
  x?: number;
  y?: number;
  z?: number;
}

interface ClearGridMapCellsParams {
  node_path: string;
  cells: GridMapClearCell[];
  transaction_id?: string;
}

interface ConfigureMaterialResourceParams {
  resource_path: string;
  material_type?: string;
  resource_name?: string;
  metadata?: Record<string, unknown>;
  material_properties?: Record<string, unknown>;
  shader_code?: string;
  shader_path?: string;
  shader_parameters?: Record<string, unknown>;
  glslang_shader?: {
    code?: string;
    path?: string;
    metadata?: Record<string, unknown>;
    parameters?: Record<string, unknown>;
  };
  lightmapper_rd?: {
    texture_slots?: Record<string, unknown>;
    scalar_parameters?: Record<string, unknown>;
    [key: string]: unknown;
  };
  meshoptimizer?: {
    lod_meshes?: Array<{
      mesh_path?: string;
      resource_path?: string;
      path?: string;
      screen_ratio?: number;
      ratio?: number;
      [key: string]: unknown;
    }>;
    [key: string]: unknown;
  };
  [key: string]: unknown;
}

const physicsPropertiesSchema = z
  .record(z.any())
  .refine((props) => Object.keys(props).length > 0, {
    message: 'At least one property must be provided',
  });

const csgPropertiesSchema = z
  .record(z.any())
  .refine((props) => Object.keys(props).length > 0, {
    message: 'At least one property must be provided',
  });

const gridMapPositionSchema = z.object({
  x: z.number().int().describe('Grid cell X coordinate'),
  y: z.number().int().describe('Grid cell Y coordinate'),
  z: z.number().int().describe('Grid cell Z coordinate'),
});

const gridMapPaintCellSchema = z
  .object({
    position: gridMapPositionSchema.optional(),
    x: z.number().int().optional(),
    y: z.number().int().optional(),
    z: z.number().int().optional(),
    item: z.number().int().describe('MeshLibrary item ID to place in the cell'),
    orientation: z.number().int().optional().describe('Optional cell orientation index'),
  })
  .superRefine((value, ctx) => {
    const hasPositionObject = value.position !== undefined;
    const hasComponents = value.x !== undefined && value.y !== undefined && value.z !== undefined;
    if (!hasPositionObject && !hasComponents) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide either a position object or explicit x, y, z coordinates',
      });
    }
  });

const gridMapClearCellSchema = z
  .object({
    position: gridMapPositionSchema.optional(),
    x: z.number().int().optional(),
    y: z.number().int().optional(),
    z: z.number().int().optional(),
  })
  .superRefine((value, ctx) => {
    const hasPositionObject = value.position !== undefined;
    const hasComponents = value.x !== undefined && value.y !== undefined && value.z !== undefined;
    if (!hasPositionObject && !hasComponents) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide either a position object or explicit x, y, z coordinates',
      });
    }
  });

const materialValueSchema = z.union([
  z.string(),
  z.number(),
  z.boolean(),
  z.array(z.any()),
  z.record(z.any()),
  z.null(),
]);

const glslangShaderSchema = z
  .object({
    code: z.string().min(1).optional().describe('Inline shader code emitted from glslang'),
    path: z.string().min(1).optional().describe('Path to a saved Shader resource'),
    metadata: z.record(z.any()).optional().describe('Metadata captured during glslang compilation'),
    parameters: z.record(materialValueSchema).optional().describe('Shader parameter overrides produced by the compiler'),
  })
  .catchall(z.any())
  .partial();

const lightmapperSchema = z
  .object({
    texture_slots: z
      .record(materialValueSchema)
      .optional()
      .describe('Texture slot overrides generated by lightmapper_rd outputs'),
    scalar_parameters: z
      .record(materialValueSchema)
      .optional()
      .describe('Scalar parameters (e.g., intensity) generated by lightmapper_rd'),
  })
  .catchall(z.any())
  .partial();

const meshoptimizerSchema = z
  .object({
    lod_meshes: z
      .array(
        z
          .object({
            mesh_path: z.string().optional(),
            resource_path: z.string().optional(),
            path: z.string().optional(),
            screen_ratio: z.number().optional(),
            ratio: z.number().optional(),
          })
          .catchall(z.any())
          .partial(),
      )
      .optional()
      .describe('LOD mesh references produced by meshoptimizer decimation'),
  })
  .catchall(z.any())
  .partial();

const configureMaterialResourceSchema = z
  .object({
    resource_path: z
      .string()
      .min(1, 'Resource path is required')
      .describe('Path to the material resource (e.g., res://materials/brick.tres)'),
    material_type: z
      .string()
      .optional()
      .describe('Material class to instantiate when creating a new resource (e.g., ShaderMaterial)'),
    resource_name: z.string().optional().describe('Optional Resource.resource_name to assign'),
    metadata: z.record(z.any()).optional().describe('Resource metadata key/value pairs to persist'),
    material_properties: z
      .record(materialValueSchema)
      .optional()
      .describe('Dictionary of Material property overrides to apply'),
    shader_code: z.string().optional().describe('Inline shader code to assign when using ShaderMaterial'),
    shader_path: z.string().optional().describe('Path to an existing Shader resource to assign'),
    shader_parameters: z
      .record(materialValueSchema)
      .optional()
      .describe('Shader parameter overrides to apply after assignment'),
    glslang_shader: glslangShaderSchema.optional().describe('Structured glslang compilation payload'),
    lightmapper_rd: lightmapperSchema.optional().describe('Lightmapper output payload (textures, scalars, metadata)'),
    meshoptimizer: meshoptimizerSchema.optional().describe('Meshoptimizer LOD metadata and resource references'),
  })
  .catchall(z.any());

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

const formatCsgResponse = (result: CommandResult): string => {
  const nodePath = (result.node_path as string) ?? 'unknown node';
  const requestedPath = (result.requested_path as string) ?? nodePath;
  const nodeType = (result.node_type as string) ?? 'CSGShape';
  const dimension = (result.dimension as string) ?? 'unknown';
  const status = (result.status as string) ?? 'pending';
  const transactionId = result.transaction_id ? ` (transaction ${result.transaction_id})` : '';
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  if (changes.length === 0) {
    return `No CSG properties changed for ${nodeType} at ${nodePath} (${dimension})${transactionId} [${status}]`;
  }

  const changeLines = changes
    .map((change) => {
      const property = change.property ?? 'property';
      const newValue = formatVariant(change.new_value ?? change.parsed_value ?? change.input_value);
      const oldValue = formatVariant(change.old_value ?? '');
      const newType = change.new_type ? ` [${change.new_type}]` : '';
      const oldType = change.old_type ? ` [${change.old_type}]` : '';
      return `- ${property}${newType}: ${oldValue}${oldType} -> ${newValue}`;
    })
    .join('\n');

  return `Updated CSG ${nodeType} at ${nodePath} (${dimension}) from ${requestedPath}${transactionId} [${status}]\n${changeLines}`;
};

const formatMaterialResponse = (result: CommandResult): string => {
  const resourcePath = (result.resource_path as string) ?? 'res://unknown.tres';
  const materialType = (result.material_type as string) ?? 'Material';
  const status = (result.status as string) ?? 'pending';
  const created = Boolean(result.created_new);
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  if (changes.length === 0) {
    return `${materialType} at ${resourcePath} required no changes (${status}).`;
  }

  const changeLines = changes.map((change) => {
    if (!change || typeof change !== 'object') {
      return '- Applied material change.';
    }

    const typedChange = change as Record<string, unknown>;
    const type = (typedChange.type as string) ?? 'change';
    if (type === 'material_created') {
      const createdType = (typedChange.material_type as string) ?? materialType;
      return `- Created material of type ${createdType}`;
    }

    const identifier =
      (typedChange.property as string) ??
      (typedChange.parameter as string) ??
      (typedChange.material_type as string) ??
      type;

    const oldValue = formatVariant(typedChange.old_value ?? '∅');
    const newValue = formatVariant(typedChange.new_value ?? '');
    const resourceRef = (typedChange.resource_path as string) ?? '';
    const resourceSuffix = resourceRef ? ` (${resourceRef})` : '';

    return `- ${type}: ${identifier}${resourceSuffix} — ${oldValue} -> ${newValue}`;
  });

  const prefix = created ? 'Created' : 'Updated';
  return `${prefix} ${materialType} at ${resourcePath} [${status}]\n${changeLines.join('\n')}`;
};

const positionToString = (position: any): string => {
  if (position && typeof position === 'object') {
    const x = (position.x ?? position.X ?? position[0]) ?? '?';
    const y = (position.y ?? position.Y ?? position[1]) ?? '?';
    const z = (position.z ?? position.Z ?? position[2]) ?? '?';
    return `(${x}, ${y}, ${z})`;
  }

  return String(position ?? '(unknown position)');
};

const formatGridMapResponse = (
  action: 'paint' | 'clear',
  result: CommandResult,
): string => {
  const nodePath = (result.node_path as string) ?? 'unknown node';
  const requestedPath = (result.requested_path as string) ?? nodePath;
  const nodeType = (result.node_type as string) ?? 'GridMap';
  const status = (result.status as string) ?? 'pending';
  const transactionId = result.transaction_id ? ` (transaction ${result.transaction_id})` : '';
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  if (changes.length === 0) {
    const verb = action === 'paint' ? 'updated' : 'cleared';
    return `No GridMap cells ${verb} for ${nodeType} at ${nodePath}${transactionId} [${status}]`;
  }

  const changeLines = changes
    .map((change) => {
      const position = positionToString(change.position);
      if (action === 'paint') {
        const item = formatVariant(change.item);
        const orientation = formatVariant(change.orientation ?? 0);
        const previousItem = formatVariant(change.previous_item ?? change.previousItem ?? 'none');
        const previousOrientation = formatVariant(change.previous_orientation ?? change.previousOrientation ?? 0);
        return `- ${position}: ${previousItem}/${previousOrientation} -> ${item}/${orientation}`;
      }

      const clearedItem = formatVariant(change.cleared_item ?? change.previous_item ?? 'none');
      const previousOrientation = formatVariant(change.previous_orientation ?? change.previousOrientation ?? 0);
      return `- ${position}: removed item ${clearedItem} (orientation ${previousOrientation})`;
    })
    .join('\n');

  const actionVerb = action === 'paint' ? 'Painted' : 'Cleared';
  return `${actionVerb} ${changes.length} GridMap cell${changes.length === 1 ? '' : 's'} on ${nodeType} at ${nodePath} from ${requestedPath}${transactionId} [${status}]\n${changeLines}`;
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

  {
    name: 'configure_csg_shape',
    description: 'Update CSG nodes with undo/redo aware property changes',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CSG node to configure (e.g. "/root/Level/CSGCombiner3D")'),
      properties: csgPropertiesSchema.describe('Dictionary of CSG properties to update'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple edits'),
    }),
    execute: async ({ node_path, properties, transaction_id }: ConfigureCsgShapeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_csg_shape', {
          node_path,
          properties,
          transaction_id,
        });

        return formatCsgResponse(result);
      } catch (error) {
        throw new Error(`Failed to configure CSG shape: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'configure_material_resource',
    description:
      'Create or update material resources, wiring glslang shader code, lightmapper_rd textures, and meshoptimizer metadata',
    parameters: configureMaterialResourceSchema,
    execute: async (params: ConfigureMaterialResourceParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_material_resource', params);
        return formatMaterialResponse(result);
      } catch (error) {
        throw new Error(`Failed to configure material resource: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'paint_gridmap_cells',
    description: 'Fill GridMap cells with MeshLibrary items using undo/redo aware transactions',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the GridMap node (e.g. "/root/Level/GridMap")'),
      cells: z.array(gridMapPaintCellSchema)
        .min(1, 'At least one cell must be provided')
        .describe('Array of cell definitions including coordinates, item id, and optional orientation'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier when batching cell edits'),
    }),
    execute: async ({ node_path, cells, transaction_id }: PaintGridMapCellsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('paint_gridmap_cells', {
          node_path,
          cells,
          transaction_id,
        });

        return formatGridMapResponse('paint', result);
      } catch (error) {
        throw new Error(`Failed to paint GridMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'clear_gridmap_cells',
    description: 'Clear GridMap cells back to empty space with undo/redo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the GridMap node (e.g. "/root/Level/GridMap")'),
      cells: z.array(gridMapClearCellSchema)
        .min(1, 'At least one cell position must be provided')
        .describe('Array of cell positions to clear (either position objects or x/y/z components)'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier when batching cell clears'),
    }),
    execute: async ({ node_path, cells, transaction_id }: ClearGridMapCellsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('clear_gridmap_cells', {
          node_path,
          cells,
          transaction_id,
        });

        return formatGridMapResponse('clear', result);
      } catch (error) {
        throw new Error(`Failed to clear GridMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
