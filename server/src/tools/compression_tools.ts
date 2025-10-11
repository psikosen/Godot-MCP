import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { getGodotConnection } from '../utils/godot_connection.js';

const compressionSettingsSchema = z
  .record(z.any())
  .refine((value) => Object.keys(value).length > 0, {
    message: 'Provide at least one setting key/value to apply.',
  })
  .describe('Dictionary of compression options scoped to the selected platform.');

export const compressionTools: MCPTool[] = [
  {
    name: 'configure_texture_compression',
    description: 'Update GPU texture compression presets for a specific platform and optionally persist the changes.',
    parameters: z.object({
      platform: z
        .string()
        .min(1)
        .describe('Platform segment appended to rendering/textures/vram_compression/<platform>.'),
      settings: compressionSettingsSchema,
      save: z
        .boolean()
        .optional()
        .describe('Persist settings to project.godot when true (default).'),
    }),
    async execute({ platform, settings, save }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = {
        platform,
        settings,
      };

      if (save !== undefined) {
        payload.save = save;
      }

      const result = await godot.sendCommand<CommandResult>('configure_texture_compression', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'batch_reimport_textures',
    description: 'Trigger a batch reimport for a list of textures, applying the latest compression presets.',
    parameters: z.object({
      paths: z
        .array(z.string().min(1))
        .min(1)
        .describe('Array of texture resource paths to reimport.'),
    }),
    async execute({ paths }): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('batch_reimport_textures', { paths });
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'create_texture_import_preset',
    description: 'Register a reusable texture import preset for ASTC/KTX/WebP workflows.',
    parameters: z.object({
      preset_name: z
        .string()
        .min(1)
        .describe('Human-readable preset identifier stored under import/presets/<importer>.'),
      importer: z
        .string()
        .min(1)
        .default('texture')
        .describe('Importer name to namespace the preset under (texture by default).'),
      options: z
        .record(z.any())
        .refine((value) => Object.keys(value).length > 0, {
          message: 'Provide at least one option when defining a preset.',
        })
        .describe('Importer option key/value pairs (e.g. { compress/mode: "Lossless" }).'),
      save: z
        .boolean()
        .optional()
        .describe('Persist the preset immediately when true (default).'),
    }),
    async execute({ preset_name, importer, options, save }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = {
        preset_name,
        importer,
        options,
      };

      if (save !== undefined) {
        payload.save = save;
      }

      const result = await godot.sendCommand<CommandResult>('create_texture_import_preset', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'list_texture_compression_settings',
    description: 'Return the currently configured compression presets and import settings exposed by the project.',
    parameters: z.object({}),
    async execute(): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('list_texture_compression_settings', {});
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
];
