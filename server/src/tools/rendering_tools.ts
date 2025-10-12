import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

const dictionarySchema = z.record(z.any());

const materialVariantSchema = z
  .object({
    source_material: z
      .string()
      .min(1, 'source_material is required')
      .describe('Path to the source Material resource (e.g. "res://materials/base_material.tres").'),
    overrides: dictionarySchema
      .optional()
      .describe('Dictionary of Material property overrides applied to the duplicated resource.'),
    shader_parameters: dictionarySchema
      .optional()
      .describe('Shader parameter overrides applied when the material is a ShaderMaterial.'),
    texture_overrides: dictionarySchema
      .optional()
      .describe('Texture slot overrides where keys map to property names and values are resource paths or dictionaries.'),
    save_path: z
      .string()
      .optional()
      .describe('Optional destination path for saving the generated material variant.'),
    resource_name: z
      .string()
      .optional()
      .describe('Optional Resource.resource_name assigned to the material variant.'),
    metadata: dictionarySchema
      .optional()
      .describe('Metadata key/value pairs persisted via Resource.set_meta on the new material.'),
  })
  .describe('Clone a material resource with property, shader parameter, and texture overrides.');

const shaderPreviewSchema = z
  .object({
    shader_code: z
      .string()
      .optional()
      .describe('Inline Godot shading language source code to compile for diagnostics.'),
    shader_path: z
      .string()
      .optional()
      .describe('Path to an existing Shader resource to compile.'),
  })
  .refine(value => Boolean(value.shader_code) || Boolean(value.shader_path), {
    message: 'Provide shader_code or shader_path',
    path: ['shader_code'],
  })
  .describe('Compile shader code and return uniform metadata without writing any resources.');

const unwrapUv2Schema = z
  .object({
    mesh_path: z
      .string()
      .optional()
      .describe('Mesh resource path to unwrap (e.g. "res://meshes/building.mesh").'),
    node_path: z
      .string()
      .optional()
      .describe('MeshInstance3D node path to unwrap (e.g. "/root/MainScene/Building").'),
    texel_size: z
      .number()
      .positive()
      .optional()
      .describe('Texel size hint passed to ArrayMesh.lightmap_unwrap (default 0.2).'),
    save_path: z
      .string()
      .optional()
      .describe('Optional resource path where the unwrapped ArrayMesh will be saved.'),
  })
  .refine(value => Boolean(value.mesh_path) || Boolean(value.node_path), {
    message: 'Provide mesh_path or node_path',
    path: ['mesh_path'],
  })
  .describe('Unwrap UV2 coordinates for a mesh resource or MeshInstance3D node.');

const optimizeLodsSchema = z
  .object({
    mesh_path: z
      .string()
      .optional()
      .describe('Mesh resource path used as the LOD source (e.g. "res://meshes/vehicle.mesh").'),
    node_path: z
      .string()
      .optional()
      .describe('MeshInstance3D node path providing the source mesh.'),
    lods: z
      .array(z.number().positive().max(1.0))
      .optional()
      .describe('Array of triangle ratios (0-1] determining how many triangles to keep per generated LOD.'),
    save_paths: z
      .array(z.string())
      .optional()
      .describe('Optional array of resource paths matching lods where generated meshes should be saved.'),
  })
  .refine(value => Boolean(value.mesh_path) || Boolean(value.node_path), {
    message: 'Provide mesh_path or node_path',
    path: ['mesh_path'],
  })
  .describe('Generate simplified meshes for multiple LOD levels and optionally assign or save them.');

const environmentCommonSchema = z.object({
  environment_path: z
    .string()
    .optional()
    .describe('Environment resource path to configure (e.g. "res://environment/main_env.tres").'),
  world_environment: z
    .string()
    .optional()
    .describe('WorldEnvironment node path whose Environment resource should be configured.'),
  node_path: z
    .string()
    .optional()
    .describe('Alias for world_environment when referencing a WorldEnvironment node.'),
  properties: dictionarySchema
    .optional()
    .describe('Direct Environment property overrides (e.g. { background_mode: 2 }).'),
  ambient_light: dictionarySchema
    .optional()
    .describe('Ambient light overrides (color, energy, sky_contribution).'),
  fog: dictionarySchema
    .optional()
    .describe('Fog overrides including color, density, height, and sun scattering parameters.'),
  sun: dictionarySchema
    .optional()
    .describe('Sun preview overrides mapped to fog sun properties (color, amount, scatter).'),
  sky: dictionarySchema
    .optional()
    .describe('Sky overrides including { path, custom_fov, rotation, energy }.'),
});

const configureEnvironmentSchema = environmentCommonSchema
  .extend({
    transaction_id: z
      .string()
      .optional()
      .describe('Optional existing transaction identifier used to batch environment changes.'),
    save: z
      .boolean()
      .optional()
      .describe('Persist the Environment resource immediately when true (default true for committed transactions).'),
  })
  .refine(value => Boolean(value.environment_path) || Boolean(value.world_environment) || Boolean(value.node_path), {
    message: 'Provide environment_path or world_environment/node_path',
    path: ['environment_path'],
  })
  .describe('Configure Environment properties, ambient light, fog, sky, and sun scattering settings with undo support.');

const previewSunSchema = environmentCommonSchema
  .extend({
    apply: z
      .boolean()
      .optional()
      .describe('When true, forward the overrides to configure_environment for immediate application.'),
  })
  .refine(value => Boolean(value.environment_path) || Boolean(value.world_environment) || Boolean(value.node_path), {
    message: 'Provide environment_path or world_environment/node_path',
    path: ['environment_path'],
  })
  .describe('Preview fog sun scattering overrides and optionally apply them to the Environment resource.');

const formatMaterialVariantResponse = (result: CommandResult): string => {
  const source = (result.source_material as string) ?? 'res://unknown.tres';
  const saved = Boolean(result.saved);
  const savePath = (result.save_path as string) ?? '';
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  const header = `Material variant created from ${source}${saved ? ` (saved to ${savePath})` : ''}`;
  if (changes.length === 0) {
    return `${header}\nNo material overrides were necessary.`;
  }

  const changeLines = changes.map(change => {
    if (!change || typeof change !== 'object') {
      return '- Applied material override.';
    }

    const typed = change as Record<string, unknown>;
    const type = (typed.type as string) ?? 'property';
    if (type === 'texture') {
      return `- Set ${typed.property ?? 'texture'} to ${(typed.value as string) ?? 'resource'}`;
    }
    if (type === 'shader_parameter') {
      return `- Shader parameter ${typed.parameter ?? 'uniform'} -> ${typed.value}`;
    }
    return `- ${typed.property ?? 'property'} -> ${typed.value}`;
  });

  return `${header}\n${changeLines.join('\n')}`;
};

const formatShaderPreviewResponse = (result: CommandResult): string => {
  const uniformCount = Array.isArray(result.uniforms) ? (result.uniforms as any[]).length : 0;
  const mode = result.shader_mode ?? 'unknown';
  const defaultTextures = Array.isArray(result.default_textures) ? (result.default_textures as any[]) : [];

  const sections: string[] = [`Shader mode: ${mode}`, `Uniforms detected: ${uniformCount}`];
  if (defaultTextures.length > 0) {
    const lines = defaultTextures.map(texture => {
      const name = texture.name ?? 'uniform';
      const type = texture.type ?? 'Texture';
      const path = texture.resource_path ?? 'in-memory';
      return `- ${name} (${type}) -> ${path}`;
    });
    sections.push('Default textures:');
    sections.push(lines.join('\n'));
  }

  return sections.join('\n');
};

const formatUnwrapResponse = (result: CommandResult): string => {
  const surfaceCount = typeof result.surface_count === 'number' ? (result.surface_count as number) : undefined;
  const texelSize = typeof result.texel_size === 'number' ? (result.texel_size as number) : undefined;
  const saved = Boolean(result.saved);
  const savePath = (result.save_path as string) ?? '';

  const parts = [
    surfaceCount !== undefined ? `${surfaceCount} surfaces unwrapped` : 'UV2 unwrap complete',
    texelSize !== undefined ? `texel_size=${texelSize}` : undefined,
    saved ? `saved to ${savePath}` : undefined,
  ].filter(Boolean);

  return parts.join(' | ');
};

const formatLodResponse = (result: CommandResult): string => {
  const lods = Array.isArray(result.lods) ? (result.lods as any[]) : [];
  if (lods.length === 0) {
    return 'No LOD meshes were generated.';
  }

  const lines = lods.map((lod, index) => {
    const ratio = typeof lod.ratio === 'number' ? (lod.ratio as number).toFixed(2) : 'ratio';
    const surfaces = typeof lod.surface_count === 'number' ? `${lod.surface_count} surfaces` : 'surfaces unknown';
    const savePath = typeof lod.save_path === 'string' && lod.save_path.length > 0 ? ` -> ${lod.save_path}` : '';
    return `LOD ${index + 1}: ratio ${ratio}, ${surfaces}${savePath}`;
  });

  return ['Generated LOD meshes:', ...lines].join('\n');
};

const formatEnvironmentResponse = (result: CommandResult): string => {
  const envPath = (result.environment_path as string) ?? 'Environment';
  const status = (result.status as string) ?? 'updated';
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  if (changes.length === 0) {
    return `${envPath} ${status} with no property changes.`;
  }

  const lines = changes.map(change => {
    if (!change || typeof change !== 'object') {
      return '- Environment property updated.';
    }

    const typed = change as Record<string, unknown>;
    const property = (typed.property as string) ?? 'property';
    const value = typed.value ?? typed.new_value ?? typed.parsed_value;
    return `- ${property} -> ${value}`;
  });

  return [`${envPath} ${status}:`, ...lines].join('\n');
};

const formatSunPreviewResponse = (result: CommandResult): string => {
  const environmentPath = (result.environment_path as string) ?? 'Environment';
  const current = (result.current as Record<string, unknown>) ?? {};
  const preview = (result.preview as Record<string, unknown>) ?? {};

  const lines: string[] = [`Sun preview for ${environmentPath}:`];
  for (const key of Object.keys(preview)) {
    const before = current[key];
    const after = preview[key];
    if (before === after) {
      lines.push(`- ${key}: ${after}`);
    } else {
      lines.push(`- ${key}: ${before} -> ${after}`);
    }
  }

  if (lines.length === 1) {
    lines.push('- No overrides supplied; current values returned.');
  }

  return lines.join('\n');
};

export const renderingTools: MCPTool<any>[] = [
  {
    name: 'generate_material_variant',
    description: 'Clone a material resource and apply property, shader parameter, and texture overrides.',
    parameters: materialVariantSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('generate_material_variant', args);
      return formatMaterialVariantResponse(result);
    },
  },
  {
    name: 'compile_shader_preview',
    description: 'Compile Godot shader code to surface uniform metadata and default textures without saving resources.',
    parameters: shaderPreviewSchema,
    metadata: {
      requiredRole: 'read',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('compile_shader_preview', args);
      return formatShaderPreviewResponse(result);
    },
  },
  {
    name: 'unwrap_lightmap_uv2',
    description: 'Generate UV2 lightmap coordinates for a mesh resource or MeshInstance3D using ArrayMesh.lightmap_unwrap.',
    parameters: unwrapUv2Schema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('unwrap_lightmap_uv2', args);
      return formatUnwrapResponse(result);
    },
  },
  {
    name: 'optimize_mesh_lods',
    description: 'Generate simplified meshes for LOD ratios and optionally assign the first level to a MeshInstance3D.',
    parameters: optimizeLodsSchema,
    metadata: {
      requiredRole: 'edit',
      escalationPrompt: 'Approve mesh LOD generation for the requested asset.',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('optimize_mesh_lods', args);
      return formatLodResponse(result);
    },
  },
  {
    name: 'configure_environment',
    description: 'Update Environment properties including ambient light, fog, sky, and sun scattering with undo support.',
    parameters: configureEnvironmentSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('configure_environment', args);
      return formatEnvironmentResponse(result);
    },
  },
  {
    name: 'preview_environment_sun_settings',
    description: 'Preview fog sun scattering overrides and optionally apply them through configure_environment.',
    parameters: previewSunSchema,
    metadata: {
      requiredRole: 'read',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('preview_environment_sun_settings', args);
      return formatSunPreviewResponse(result);
    },
  },
];
