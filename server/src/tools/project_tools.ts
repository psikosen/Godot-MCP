import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { projectIndexer } from '../utils/project_indexer.js';
import { getGodotConnection } from '../utils/godot_connection.js';

const ENTRY_LIMIT = 5000;

const inputEventSchema = z.object({
  type: z.string()
    .describe('Input event type such as InputEventKey, key, InputEventMouseButton, mouse_button, etc.'),
}).passthrough();

export const projectTools: MCPTool[] = [
  {
    name: 'refresh_project_index',
    description: 'Refresh the cached project structure index and return summary statistics.',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const snapshot = await projectIndexer.refresh();
      return JSON.stringify({
        generated_at: snapshot.generatedAt,
        stats: snapshot.stats,
        root_entries: snapshot.root,
      }, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'query_project_index',
    description: 'Query the cached project index using glob-style patterns.',
    parameters: z.object({
      pattern: z.union([
        z.string(),
        z.array(z.string()).min(1),
      ]).describe('Glob pattern or list of patterns (supports * and **).'),
      include_directories: z.boolean()
        .optional()
        .describe('Whether to include directories in the results (default true).'),
      limit: z.number()
        .int()
        .positive()
        .max(ENTRY_LIMIT)
        .optional()
        .describe('Maximum number of entries to return (default 200, max 5000).'),
    }),
    execute: async ({
      pattern,
      include_directories,
      limit,
    }: {
      pattern: string | string[];
      include_directories?: boolean;
      limit?: number;
    }): Promise<string> => {
      const patterns = Array.isArray(pattern) ? pattern : [pattern];
      const matches = await projectIndexer.query(patterns, {
        includeDirectories: include_directories ?? true,
        limit,
      });

      return JSON.stringify({
        patterns,
        count: matches.length,
        matches,
      }, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_input_actions',
    description: 'List all configured input actions from the Godot project settings.',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_input_actions', {});
        return JSON.stringify(result, null, 2);
      } catch (error) {
        throw new Error(`Failed to list input actions: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_audio_buses',
    description: 'Inspect the project audio bus layout including routing, volume, and effects.',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_audio_buses', {});
        return JSON.stringify(result, null, 2);
      } catch (error) {
        throw new Error(`Failed to list audio buses: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'add_input_action',
    description: 'Create or overwrite a Godot input action with optional default events.',
    parameters: z.object({
      action_name: z.string()
        .describe('Name of the input action to create or overwrite.'),
      deadzone: z.number()
        .min(0)
        .max(1)
        .optional()
        .describe('Optional custom deadzone value (default 0.5).'),
      overwrite: z.boolean()
        .optional()
        .describe('Whether to overwrite an existing action with the same name (default false).'),
      persistent: z.boolean()
        .optional()
        .describe('Persist changes to project.godot immediately (default true).'),
      events: z.array(inputEventSchema)
        .optional()
        .describe('Optional array of input events to register with the action.'),
    }),
    execute: async ({ action_name, deadzone, overwrite, persistent, events }): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('add_input_action', {
          action_name,
          deadzone,
          overwrite,
          persistent,
          events,
        });

        return `Created/updated input action "${result.action_name}" with ${(result.events as unknown[])?.length ?? 0} event(s).`;
      } catch (error) {
        throw new Error(`Failed to add input action: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'remove_input_action',
    description: 'Remove a Godot input action from the project settings.',
    parameters: z.object({
      action_name: z.string()
        .describe('Name of the input action to remove.'),
      persistent: z.boolean()
        .optional()
        .describe('Persist changes to project.godot immediately (default true).'),
    }),
    execute: async ({ action_name, persistent }): Promise<string> => {
      const godot = getGodotConnection();

      try {
        await godot.sendCommand('remove_input_action', {
          action_name,
          persistent,
        });

        return `Removed input action "${action_name}".`;
      } catch (error) {
        throw new Error(`Failed to remove input action: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'add_input_event_to_action',
    description: 'Register an additional event on an existing Godot input action.',
    parameters: z.object({
      action_name: z.string()
        .describe('Name of the input action to modify.'),
      event: inputEventSchema
        .describe('Input event definition that should be added to the action.'),
      persistent: z.boolean()
        .optional()
        .describe('Persist changes to project.godot immediately (default true).'),
    }),
    execute: async ({ action_name, event, persistent }): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('add_input_event_to_action', {
          action_name,
          event,
          persistent,
        });

        return `Added event to action "${result.action_name}".`;
      } catch (error) {
        throw new Error(`Failed to add input event: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'remove_input_event_from_action',
    description: 'Remove an event from a Godot input action by index or matching fields.',
    parameters: z.object({
      action_name: z.string()
        .describe('Name of the input action to modify.'),
      event_index: z.number()
        .int()
        .nonnegative()
        .optional()
        .describe('Index of the event to remove (0-based).'),
      event: inputEventSchema.optional()
        .describe('Event description to match for removal when index is not provided.'),
      persistent: z.boolean()
        .optional()
        .describe('Persist changes to project.godot immediately (default true).'),
    }).refine(data => data.event_index !== undefined || data.event !== undefined, {
      message: 'Either event_index or event must be provided to identify the input event to remove.',
      path: ['event_index'],
    }),
    execute: async ({ action_name, event_index, event, persistent }): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('remove_input_event_from_action', {
          action_name,
          event_index,
          event,
          persistent,
        });

        return `Removed event from action "${result.action_name}".`;
      } catch (error) {
        throw new Error(`Failed to remove input event: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
