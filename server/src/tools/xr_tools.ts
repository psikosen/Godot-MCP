import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { getGodotConnection } from '../utils/godot_connection.js';

const xrSettingsEntrySchema = z
  .object({
    path: z
      .string()
      .min(1)
      .describe('ProjectSettings path to update (e.g. xr/openxr/rendering).'),
    value: z.any().describe('Value written to the provided ProjectSettings path.'),
  })
  .strict();

const xrSettingsSchema = z.union([
  z.array(xrSettingsEntrySchema).min(1).describe('Explicit array of { path, value } entries.'),
  z
    .record(z.any())
    .describe('Dictionary where keys map directly to ProjectSettings paths.'),
]);

export const xrTools: MCPTool[] = [
  {
    name: 'list_xr_interfaces',
    description: 'Enumerate available XR interfaces and their initialization state.',
    parameters: z.object({}),
    async execute(): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('list_xr_interfaces', {});
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'initialize_xr_interface',
    description: 'Initialize a specific XR interface and optionally promote it to the primary interface.',
    parameters: z.object({
      interface_name: z
        .string()
        .min(1)
        .describe('XR interface name as reported by Godot (e.g. OpenXR, WebXR).'),
      make_primary: z
        .boolean()
        .optional()
        .describe('Set the XR interface as the primary interface after initialization.'),
      start_session: z
        .boolean()
        .optional()
        .describe('Request the interface to start a session when supported.'),
    }),
    async execute({ interface_name, make_primary, start_session }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = {
        interface_name,
      };

      if (make_primary !== undefined) {
        payload.make_primary = make_primary;
      }

      if (start_session !== undefined) {
        payload.start_session = start_session;
      }

      const result = await godot.sendCommand<CommandResult>('initialize_xr_interface', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'shutdown_xr_interface',
    description: 'Shut down an XR interface and end its active session if one is running.',
    parameters: z.object({
      interface_name: z
        .string()
        .min(1)
        .describe('XR interface name that should be stopped.'),
    }),
    async execute({ interface_name }): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('shutdown_xr_interface', {
        interface_name,
      });
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'save_xr_project_settings',
    description: 'Persist XR-specific ProjectSettings entries, enabling deterministic editor setup.',
    parameters: z.object({
      settings: xrSettingsSchema,
      save: z
        .boolean()
        .optional()
        .describe('When true (default), ProjectSettings.save() is invoked after applying changes.'),
    }),
    async execute({ settings, save }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = { settings };

      if (save !== undefined) {
        payload.save = save;
      }

      const result = await godot.sendCommand<CommandResult>('save_xr_project_settings', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
