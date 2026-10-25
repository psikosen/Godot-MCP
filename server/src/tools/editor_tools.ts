import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

interface ExecuteEditorScriptParams {
  code: string;
}

export const editorTools: MCPTool[] = [
  {
    name: 'execute_editor_script',
    description: 'Executes arbitrary GDScript code in the Godot editor',
    parameters: z.object({
      code: z.string()
        .describe('GDScript code to execute in the editor context'),
    }),
    execute: async ({ code }: ExecuteEditorScriptParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand('execute_editor_script', { code });
        
        // Format output for display
        let outputText = 'Script executed successfully';
        
        if (result.output && Array.isArray(result.output) && result.output.length > 0) {
          outputText += '\n\nOutput:\n' + result.output.join('\n');
        }
        
        if (result.result !== undefined && result.result !== null) {
          outputText += '\n\nResult:\n' + JSON.stringify(result.result, null, 2);
        }
        
        return outputText;
      } catch (error) {
        throw new Error(`Script execution failed: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to execute arbitrary editor scripts within Godot.',
    },
  },
  {
    name: 'run_godot_headless',
    description: 'Launch the Godot editor binary in headless mode and capture its output.',
    parameters: z.object({
      run_target: z
        .string()
        .optional()
        .describe('Optional scene or script target passed to --run.'),
      binary_path: z
        .string()
        .optional()
        .describe('Override path to the Godot executable (defaults to the running editor).'),
      additional_args: z
        .array(z.string())
        .optional()
        .describe('Additional command-line arguments appended to the headless run.'),
      capture_stderr: z
        .boolean()
        .optional()
        .describe('Include stderr output in the captured log (default true).'),
      no_window: z
        .boolean()
        .optional()
        .describe('Pass --no-window alongside --headless (default true).'),
      max_frames: z
        .number()
        .int()
        .min(1)
        .max(36000)
        .optional()
        .describe('With run_target: quit after this many frames (default 600) so a scene that never quits cannot hang the editor. Ignored if additional_args has --quit or --quit-after.'),
    }),
    execute: async ({
      run_target,
      binary_path,
      additional_args,
      capture_stderr,
      no_window,
      max_frames,
    }: {
      run_target?: string;
      binary_path?: string;
      additional_args?: string[];
      capture_stderr?: boolean;
      no_window?: boolean;
      max_frames?: number;
    }): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {};

      if (run_target) payload.run_target = run_target;
      if (binary_path) payload.binary_path = binary_path;
      if (additional_args) payload.additional_args = additional_args;
      if (capture_stderr !== undefined) payload.capture_stderr = capture_stderr;
      if (no_window !== undefined) payload.no_window = no_window;
      if (max_frames !== undefined) payload.max_frames = max_frames;

      const result = await godot.sendCommand<CommandResult>('run_godot_headless', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to execute headless Godot runs from the editor environment.',
    },
  },
  {
    name: 'capture_editor_profile',
    description: 'Capture CPU, rendering, and memory metrics from the running Godot editor.',
    parameters: z.object({
      include_rendering: z
        .boolean()
        .optional()
        .describe('Include rendering statistics (default true).'),
      include_objects: z
        .boolean()
        .optional()
        .describe('Include object and resource counts (default true).'),
      include_memory: z
        .boolean()
        .optional()
        .describe('Include memory usage metrics (default true).'),
      include_gpu: z
        .boolean()
        .optional()
        .describe('Include GPU timing metrics when available (default true).'),
    }),
    execute: async ({
      include_rendering,
      include_objects,
      include_memory,
      include_gpu,
    }: {
      include_rendering?: boolean;
      include_objects?: boolean;
      include_memory?: boolean;
      include_gpu?: boolean;
    }): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {};
      if (include_rendering !== undefined) payload.include_rendering = include_rendering;
      if (include_objects !== undefined) payload.include_objects = include_objects;
      if (include_memory !== undefined) payload.include_memory = include_memory;
      if (include_gpu !== undefined) payload.include_gpu = include_gpu;

      const result = await godot.sendCommand<CommandResult>('capture_editor_profile', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_editor_plugins',
    description: 'List Godot editor plugins in the current project and whether each is enabled (read-only).',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('manage_editor_plugins', { action: 'list' });
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'manage_editor_plugins',
    description: 'Enable or disable Godot editor plugins within the current project (admin). Use list_editor_plugins to only list.',
    parameters: z
      .object({
        action: z
          .enum(['list', 'enable', 'disable'])
          .default('list')
          .describe('Operation to perform on the plugin registry.'),
        plugins: z
          .array(z.string())
          .optional()
          .describe('Plugin configuration paths or names when enabling/disabling.'),
        persist: z
          .boolean()
          .optional()
          .describe('Persist editor plugin changes to project.godot.'),
      })
      .refine(data => (data.action === 'list' ? true : Array.isArray(data.plugins) && data.plugins.length > 0), {
        message: 'At least one plugin must be provided when enabling or disabling.',
        path: ['plugins'],
      }),
    execute: async ({
      action,
      plugins,
      persist,
    }: {
      action?: 'list' | 'enable' | 'disable';
      plugins?: string[];
      persist?: boolean;
    }): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {};

      if (action) {
        payload.action = action;
      }

      if (plugins) {
        payload.plugins = plugins;
      }

      if (persist !== undefined) {
        payload.persist = persist;
      }

      const result = await godot.sendCommand<CommandResult>('manage_editor_plugins', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to change enabled Godot editor plugins.',
    },
  },
  {
    name: 'snapshot_scene_state',
    description: 'Capture a structured snapshot of the currently edited scene tree for review.',
    parameters: z.object({
      include_internal: z
        .boolean()
        .optional()
        .describe('Include properties beginning with _ and other internal data.'),
      include_resources: z
        .boolean()
        .optional()
        .describe('Include resource metadata such as scripts and materials (default true).'),
      max_properties_per_node: z
        .number()
        .int()
        .nonnegative()
        .max(512)
        .optional()
        .describe('Limit the number of properties captured per node (default 32).'),
      node_limit: z
        .number()
        .int()
        .nonnegative()
        .optional()
        .describe('Maximum number of nodes to snapshot (0 means all).'),
      max_depth: z
        .number()
        .int()
        .positive()
        .max(64)
        .optional()
        .describe('Maximum depth in the scene tree to traverse (default 3).'),
    }),
    execute: async ({
      include_internal,
      include_resources,
      max_properties_per_node,
      node_limit,
      max_depth,
    }: {
      include_internal?: boolean;
      include_resources?: boolean;
      max_properties_per_node?: number;
      node_limit?: number;
      max_depth?: number;
    }): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {};
      if (include_internal !== undefined) payload.include_internal = include_internal;
      if (include_resources !== undefined) payload.include_resources = include_resources;
      if (max_properties_per_node !== undefined) payload.max_properties_per_node = max_properties_per_node;
      if (node_limit !== undefined) payload.node_limit = node_limit;
      if (max_depth !== undefined) payload.max_depth = max_depth;

      const result = await godot.sendCommand<CommandResult>('snapshot_scene_state', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
];