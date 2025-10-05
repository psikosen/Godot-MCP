import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

interface NavigationDimensionParams {
  dimension?: '2d' | '3d' | 'both';
}

interface BakeNavigationRegionParams {
  node_path: string;
  on_thread?: boolean;
}

interface NavigationMutationParams {
  node_path: string;
  properties: Record<string, unknown>;
  transaction_id?: string;
}

/**
 * Utility to format a vector dictionary into readable string output.
 */
function formatVector(value: Record<string, unknown> | undefined): string {
  if (!value) {
    return 'n/a';
  }

  const keys = Object.keys(value);
  if (keys.includes('x')) {
    const coords = keys.map(key => `${key}: ${value[key]}`).join(', ');
    return `{ ${coords} }`;
  }

  return JSON.stringify(value);
}

/**
 * Utility to format navigation region summaries.
 */
function formatNavigationRegions(regions: any[]): string {
  if (!regions || regions.length === 0) {
    return 'No navigation regions found.';
  }

  return regions
    .map(region => {
      const details = [
        `Path: ${region.node_path}`,
        `Dimension: ${region.dimension}`,
        `Enabled: ${region.enabled}`,
        `Layers: ${region.navigation_layers}`,
        `Travel Cost: ${region.travel_cost}`,
        `Enter Cost: ${region.enter_cost}`,
        `Edge Connections: ${region.use_edge_connections}`,
      ];

      if (region.resource) {
        const resource = region.resource as Record<string, unknown>;
        details.push(
          'Resource:',
          `  Path: ${resource.resource_path || '<local>'}`,
          `  Vertex Count: ${resource.vertex_count}`,
          `  Polygon Count: ${resource.polygon_count}`,
        );

        if ('agent_radius' in resource) {
          details.push(
            `  Agent Radius: ${resource.agent_radius}`,
            `  Cell Size: ${resource.cell_size}`,
            `  Cell Height: ${resource.cell_height}`,
          );
        }
      }

      return details.join('\n');
    })
    .join('\n\n');
}

/**
 * Utility to format navigation agent summaries.
 */
function formatNavigationAgents(agents: any[]): string {
  if (!agents || agents.length === 0) {
    return 'No navigation agents found.';
  }

  return agents
    .map(agent => {
      const details = [
        `Path: ${agent.node_path}`,
        `Dimension: ${agent.dimension}`,
        `Radius: ${agent.radius}`,
        `Max Speed: ${agent.max_speed}`,
        `Max Acceleration: ${agent.max_acceleration}`,
        `Avoidance Enabled: ${agent.avoidance_enabled}`,
        `Max Neighbors: ${agent.max_neighbors}`,
        `Neighbor Max Distance: ${agent.neighbor_max_distance}`,
        `Target Position: ${formatVector(agent.target_position)}`,
        `Current Position: ${formatVector(agent.position)}`,
        `Velocity: ${formatVector(agent.velocity)}`,
      ];

      if ('height' in agent) {
        details.push(`Height: ${agent.height}`);
      }

      details.push(
        `Path Desired Distance: ${agent.path_desired_distance}`,
        `Target Desired Distance: ${agent.target_desired_distance}`,
      );

      return details.join('\n');
    })
    .join('\n\n');
}

/**
 * Navigation-focused MCP tools that align with Godot's navigation modules.
 */
export const navigationTools: MCPTool[] = [
  {
    name: 'list_navigation_maps',
    description: 'List navigation regions in the active scene with summary details.',
    parameters: z
      .object({
        dimension: z.enum(['2d', '3d', 'both']).optional()
          .describe('Filter regions by dimension (2d, 3d, or both). Defaults to both.'),
      })
      .default({}),
    execute: async ({ dimension = 'both' }: NavigationDimensionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_navigation_maps', {
          dimension,
        });

        const summary = formatNavigationRegions(result.regions ?? []);
        return `Navigation regions (${dimension}):\n\n${summary}`;
      } catch (error) {
        throw new Error(`Failed to list navigation regions: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_navigation_agents',
    description: 'Inspect navigation agents in the active scene and view avoidance parameters.',
    parameters: z
      .object({
        dimension: z.enum(['2d', '3d', 'both']).optional()
          .describe('Filter agents by dimension (2d, 3d, or both). Defaults to both.'),
      })
      .default({}),
    execute: async ({ dimension = 'both' }: NavigationDimensionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_navigation_agents', {
          dimension,
        });

        const summary = formatNavigationAgents(result.agents ?? []);
        return `Navigation agents (${dimension}):\n\n${summary}`;
      } catch (error) {
        throw new Error(`Failed to list navigation agents: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'bake_navigation_region',
    description: 'Trigger baking for a NavigationRegion2D or NavigationRegion3D.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the navigation region node (e.g. "/root/Main/NavigationRegion3D").'),
      on_thread: z
        .boolean()
        .optional()
        .describe('If true (default), baking occurs on a worker thread.'),
    }),
    execute: async ({ node_path, on_thread = true }: BakeNavigationRegionParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('bake_navigation_region', {
          node_path,
          on_thread,
        });

        const dimension = String(result.dimension ?? 'unknown');
        return `Started ${dimension.toUpperCase()} navigation bake for ${result.node_path} (threaded: ${result.on_thread}).`;
      } catch (error) {
        throw new Error(`Failed to bake navigation region: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'update_navigation_region',
    description: 'Update properties on a navigation region node with undo/redo support.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the NavigationRegion2D/3D node to modify.'),
      properties: z
        .record(z.any())
        .describe('Dictionary of property names to new values.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing scene transaction identifier to batch changes.'),
    }),
    execute: async ({ node_path, properties, transaction_id }: NavigationMutationParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('update_navigation_region', {
          node_path,
          properties,
          transaction_id,
        });

        const status = result.status ?? 'committed';
        return `Updated navigation region ${result.node_path} (${status}). Properties: ${Object.keys(properties).join(', ')}`;
      } catch (error) {
        throw new Error(`Failed to update navigation region: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'update_navigation_resource',
    description: 'Modify the NavigationPolygon or NavigationMesh resource attached to a region.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the navigation region whose resource should be edited.'),
      properties: z
        .record(z.any())
        .describe('Dictionary of resource property names to new values.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing scene transaction identifier to batch changes.'),
    }),
    execute: async ({ node_path, properties, transaction_id }: NavigationMutationParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('update_navigation_resource', {
          node_path,
          properties,
          transaction_id,
        });

        const status = String(result.status ?? 'committed');
        const dimension = String(result.dimension ?? 'unknown');
        return `Updated ${dimension.toUpperCase()} navigation resource for ${result.node_path} (${status}).`;
      } catch (error) {
        throw new Error(`Failed to update navigation resource: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'update_navigation_agent',
    description: 'Adjust NavigationAgent2D/3D parameters with undo/redo support.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the NavigationAgent2D/3D node to modify.'),
      properties: z
        .record(z.any())
        .describe('Dictionary of agent property names to new values.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing scene transaction identifier to batch changes.'),
    }),
    execute: async ({ node_path, properties, transaction_id }: NavigationMutationParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('update_navigation_agent', {
          node_path,
          properties,
          transaction_id,
        });

        const status = String(result.status ?? 'committed');
        const dimension = String(result.dimension ?? 'unknown');
        return `Updated ${dimension.toUpperCase()} navigation agent ${result.node_path} (${status}). Properties: ${Object.keys(properties).join(', ')}`;
      } catch (error) {
        throw new Error(`Failed to update navigation agent: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
