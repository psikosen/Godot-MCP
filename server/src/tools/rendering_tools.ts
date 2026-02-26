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

const proceduralPlanetSchema = z
  .object({
    texture_width: z.number().int().min(64).max(4096).optional().describe('Generated texture width (default 1024).'),
    texture_height: z.number().int().min(32).max(4096).optional().describe('Generated texture height (default 512).'),
    radius: z.number().positive().optional().describe('Sphere radius used for the generated planet mesh (default 1.0).'),
    radial_segments: z.number().int().min(8).max(512).optional().describe('Sphere mesh radial segments (default 96).'),
    rings: z.number().int().min(8).max(256).optional().describe('Sphere mesh rings/latitudinal subdivisions (default 64).'),
    seed: z.number().int().optional().describe('Deterministic seed for the elevation and humidity noise fields.'),
    base_frequency: z.number().positive().optional().describe('Base frequency for spherical 3D noise sampling (default 2.2).'),
    octaves: z.number().int().min(1).max(12).optional().describe('Fractal octave count used for layered terrain noise (default 6).'),
    lacunarity: z.number().min(1).max(4).optional().describe('Frequency multiplier between octaves (default 2.0).'),
    persistence: z.number().min(0.05).max(1).optional().describe('Amplitude multiplier between octaves (default 0.5).'),
    sea_level: z.number().min(-0.95).max(0.95).optional().describe('Sea level threshold in normalized elevation space [-1, 1] (default 0).'),
    roughness: z.number().min(0).max(1).optional().describe('Material roughness value for the generated planet material (default 0.95).'),
    metallic: z.number().min(0).max(1).optional().describe('Material metallic value for the generated planet material (default 0).'),
    specular_intensity: z.number().min(0).max(1).optional().describe('Specular strength applied to water regions (default 0.8).'),
    normal_strength: z.number().min(0).max(40).optional().describe('Normal map intensity derived from the generated elevation map (default 5).'),
    create_node: z.boolean().optional().describe('Create a MeshInstance3D in the currently edited scene (default true).'),
    parent_path: z.string().optional().describe('Parent node path used when create_node is true (default "/root").'),
    node_name: z.string().optional().describe('MeshInstance3D name used when creating the planet node (default "ProceduralPlanet").'),
    save_mesh_path: z.string().optional().describe('Optional path for saving the generated SphereMesh resource.'),
    save_material_path: z.string().optional().describe('Optional path for saving the generated StandardMaterial3D resource.'),
    save_albedo_path: z.string().optional().describe('Optional path for saving the generated albedo texture/image.'),
    save_height_path: z.string().optional().describe('Optional path for saving the generated height texture/image.'),
    save_normal_path: z.string().optional().describe('Optional path for saving the generated normal texture/image.'),
    save_specular_path: z.string().optional().describe('Optional path for saving the generated specular texture/image.'),
  })
  .describe('Generate a procedural planet from seamless spherical noise, biome color bands, and optional scene/resource output.');

const proceduralPlanetOceanSchema = z
  .object({
    mesh_mode: z
      .enum(['planet_shell', 'single_tile'])
      .optional()
      .describe('Ocean mesh mode: full spherical shell for planets or a single tile for editor blockouts (default planet_shell).'),
    ocean_radius: z.number().positive().optional().describe('Sphere radius when mesh_mode is planet_shell (default 1.03).'),
    radial_segments: z.number().int().min(8).max(512).optional().describe('Sphere radial segments when mesh_mode is planet_shell.'),
    rings: z.number().int().min(8).max(256).optional().describe('Sphere rings when mesh_mode is planet_shell.'),
    tile_size: z.number().positive().optional().describe('Plane size when mesh_mode is single_tile (default 2.0).'),
    tile_subdivide_width: z.number().int().min(1).max(256).optional().describe('Plane subdivisions on width when mesh_mode is single_tile.'),
    tile_subdivide_depth: z.number().int().min(1).max(256).optional().describe('Plane subdivisions on depth when mesh_mode is single_tile.'),
    wave_scale: z.number().positive().optional().describe('Noise scale controlling wave pattern size.'),
    wave_speed: z.number().min(0).optional().describe('Animation speed multiplier for wave motion.'),
    wave_height: z.number().min(0).optional().describe('Vertex displacement amplitude for waves.'),
    foam_strength: z.number().min(0).max(2).optional().describe('Strength of crest/foam highlights.'),
    fresnel_power: z.number().positive().optional().describe('Fresnel exponent for edge reflectance.'),
    depth_absorption: z.number().positive().optional().describe('View-depth color blend factor between deep and shallow water.'),
    roughness: z.number().min(0).max(1).optional().describe('Water material roughness.'),
    metallic: z.number().min(0).max(1).optional().describe('Water material metallic value.'),
    alpha: z.number().min(0).max(1).optional().describe('Water alpha/transparency value.'),
    seed: z.number().optional().describe('Noise seed offset for wave field variation.'),
    deep_color: dictionarySchema.optional().describe('Deep water color as dictionary (r,g,b,a).'),
    shallow_color: dictionarySchema.optional().describe('Shallow water color as dictionary (r,g,b,a).'),
    foam_color: dictionarySchema.optional().describe('Foam highlight color as dictionary (r,g,b,a).'),
    create_node: z.boolean().optional().describe('Create a MeshInstance3D in the currently edited scene (default true).'),
    planet_node_path: z.string().optional().describe('Optional planet node path to align the ocean shell transform.'),
    parent_path: z.string().optional().describe('Optional parent path for the generated ocean node.'),
    node_name: z.string().optional().describe('Node name when create_node is true (default PlanetOcean).'),
    save_shader_path: z.string().optional().describe('Optional path for saving the generated Shader resource.'),
    save_material_path: z.string().optional().describe('Optional path for saving the generated ShaderMaterial resource.'),
  })
  .describe('Generate animated procedural ocean shading inspired by Shadertoy-style wave fields for planets or single editor tiles.');

const createPlanetShellSchema = z
  .object({
    radius: z.number().positive().optional(),
    radial_segments: z.number().int().min(8).max(512).optional(),
    rings: z.number().int().min(8).max(256).optional(),
    color: dictionarySchema.optional(),
    roughness: z.number().min(0).max(1).optional(),
    metallic: z.number().min(0).max(1).optional(),
    create_node: z.boolean().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    save_mesh_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Create a simple planet shell mesh and material with optional scene instancing and resource saving.');

const createOceanTileSchema = z
  .object({
    tile_size: z.number().positive().optional(),
    tile_subdivide_width: z.number().int().min(1).max(256).optional(),
    tile_subdivide_depth: z.number().int().min(1).max(256).optional(),
    wave_scale: z.number().positive().optional(),
    wave_speed: z.number().min(0).optional(),
    wave_height: z.number().min(0).optional(),
    foam_strength: z.number().min(0).max(2).optional(),
    fresnel_power: z.number().positive().optional(),
    depth_absorption: z.number().positive().optional(),
    roughness: z.number().min(0).max(1).optional(),
    metallic: z.number().min(0).max(1).optional(),
    alpha: z.number().min(0).max(1).optional(),
    seed: z.number().optional(),
    deep_color: dictionarySchema.optional(),
    shallow_color: dictionarySchema.optional(),
    foam_color: dictionarySchema.optional(),
    create_node: z.boolean().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    save_shader_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Create a single procedural animated ocean tile suitable for editor blockouts.');

const triplanarTerrainSchema = z
  .object({
    node_path: z.string().min(1),
    rock_texture_path: z.string().optional(),
    grass_texture_path: z.string().optional(),
    snow_texture_path: z.string().optional(),
    texture_scale: z.number().positive().optional(),
    snow_height: z.number().min(0).max(1).optional(),
    blend_softness: z.number().min(0.01).max(0.5).optional(),
    roughness: z.number().min(0).max(1).optional(),
    metallic: z.number().min(0).max(1).optional(),
    save_shader_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Apply a triplanar terrain ShaderMaterial to a MeshInstance3D.');

const cloudLayerSchema = z
  .object({
    cloud_radius: z.number().positive().optional(),
    radial_segments: z.number().int().min(8).max(512).optional(),
    rings: z.number().int().min(8).max(256).optional(),
    cloud_density: z.number().min(0).max(1).optional(),
    cloud_scale: z.number().positive().optional(),
    cloud_speed: z.number().min(0).optional(),
    cloud_alpha: z.number().min(0).max(1).optional(),
    cloud_color: dictionarySchema.optional(),
    create_node: z.boolean().optional(),
    planet_node_path: z.string().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    save_shader_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Generate a lightweight procedural cloud shell for a planet.');

const atmosphereGlowSchema = z
  .object({
    radius: z.number().positive().optional(),
    radial_segments: z.number().int().min(8).max(512).optional(),
    rings: z.number().int().min(8).max(256).optional(),
    glow_color: dictionarySchema.optional(),
    fresnel_power: z.number().positive().optional(),
    intensity: z.number().min(0).optional(),
    alpha: z.number().min(0).max(1).optional(),
    create_node: z.boolean().optional(),
    planet_node_path: z.string().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    save_shader_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Create a simple fresnel atmosphere glow shell around a planet.');

const craterScatterSchema = z
  .object({
    count: z.number().int().min(1).max(2048).optional(),
    planet_radius: z.number().positive().optional(),
    crater_min_radius: z.number().positive().optional(),
    crater_max_radius: z.number().positive().optional(),
    crater_depth: z.number().min(0.05).max(1).optional(),
    seed: z.number().int().optional(),
    crater_color: dictionarySchema.optional(),
    create_node: z.boolean().optional(),
    planet_node_path: z.string().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
  })
  .describe('Scatter simple crater proxy meshes across a spherical surface.');

const ringSystemSchema = z
  .object({
    inner_radius: z.number().positive().optional(),
    outer_radius: z.number().positive().optional(),
    alpha: z.number().min(0).max(1).optional(),
    banding: z.number().min(0).max(1).optional(),
    seed: z.number().optional(),
    ring_color: dictionarySchema.optional(),
    tilt_degrees: z.union([z.number(), dictionarySchema, z.array(z.number())]).optional(),
    create_node: z.boolean().optional(),
    planet_node_path: z.string().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    save_shader_path: z.string().optional(),
    save_material_path: z.string().optional(),
  })
  .describe('Create a ring system plane with radial mask and subtle procedural banding.');

const starfieldSkyboxSchema = z
  .object({
    width: z.number().int().min(64).max(4096).optional(),
    height: z.number().int().min(32).max(2048).optional(),
    star_count: z.number().int().min(1).max(200000).optional(),
    seed: z.number().int().optional(),
    background_top: dictionarySchema.optional(),
    background_bottom: dictionarySchema.optional(),
    apply_to_environment: z.boolean().optional(),
    environment_path: z.string().optional(),
    world_environment: z.string().optional(),
    node_path: z.string().optional(),
    save_image_path: z.string().optional(),
    save_material_path: z.string().optional(),
    save_sky_path: z.string().optional(),
    save_environment_path: z.string().optional(),
    save_environment: z.boolean().optional(),
  })
  .describe('Generate a procedural starfield panorama sky and optionally apply it to an Environment.');

const moonProxySchema = z
  .object({
    radius: z.number().positive().optional(),
    distance: z.number().positive().optional(),
    orbit_speed_deg_per_sec: z.number().optional(),
    inclination_degrees: z.number().optional(),
    color: dictionarySchema.optional(),
    create_node: z.boolean().optional(),
    planet_node_path: z.string().optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
  })
  .describe('Create a moon mesh with an orbit pivot proxy for lightweight planetary setups.');

const planetPresetQuickstartSchema = z
  .object({
    preset: z.enum(['earthlike', 'desert', 'ice', 'lava']).optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    planet_radius: z.number().positive().optional(),
    include_moon: z.boolean().optional(),
  })
  .describe('Generate a minimal preset planet setup including shell, ocean, clouds, atmosphere, and optional moon.');

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

const formatProceduralPlanetResponse = (result: CommandResult): string => {
  const seed = typeof result.seed === 'number' ? result.seed : 'auto';
  const nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
  const elevationRange = (result.elevation_range as Record<string, unknown>) ?? {};
  const minElevation = typeof elevationRange.min === 'number' ? elevationRange.min.toFixed(3) : 'n/a';
  const maxElevation = typeof elevationRange.max === 'number' ? elevationRange.max.toFixed(3) : 'n/a';

  const lines = [`Procedural planet generated (seed=${seed}).`, `Elevation range: ${minElevation} -> ${maxElevation}`];
  if (nodePath.length > 0) {
    lines.push(`Scene node: ${nodePath}`);
  }

  const savedPaths = (result.saved_paths as Record<string, unknown>) ?? {};
  const savedEntries = Object.entries(savedPaths).filter(([, value]) => typeof value === 'string' && (value as string).length > 0);
  if (savedEntries.length > 0) {
    lines.push('Saved resources:');
    for (const [key, value] of savedEntries) {
      lines.push(`- ${key}: ${value as string}`);
    }
  }

  return lines.join('\n');
};

const formatProceduralOceanResponse = (result: CommandResult): string => {
  const nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
  const meshMode = typeof result.mesh_mode === 'string' ? result.mesh_mode : 'planet_shell';
  const radius = typeof result.ocean_radius === 'number' ? result.ocean_radius : undefined;
  const tileSize = typeof result.tile_size === 'number' ? result.tile_size : undefined;

  const lines = [`Procedural ocean generated (${meshMode}).`];
  if (radius !== undefined && meshMode === 'planet_shell') {
    lines.push(`Ocean radius: ${radius}`);
  }
  if (tileSize !== undefined && meshMode === 'single_tile') {
    lines.push(`Tile size: ${tileSize}`);
  }
  if (nodePath.length > 0) {
    lines.push(`Scene node: ${nodePath}`);
  }

  const savedPaths = (result.saved_paths as Record<string, unknown>) ?? {};
  const savedEntries = Object.entries(savedPaths).filter(([, value]) => typeof value === 'string' && (value as string).length > 0);
  if (savedEntries.length > 0) {
    lines.push('Saved resources:');
    for (const [key, value] of savedEntries) {
      lines.push(`- ${key}: ${value as string}`);
    }
  }
  return lines.join('\n');
};

const formatSimpleNodeResponse = (label: string, result: CommandResult): string => {
  const lines = [label];
  const nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
  const rootPath = typeof result.root_path === 'string' ? result.root_path : '';
  const pivotPath = typeof result.pivot_path === 'string' ? result.pivot_path : '';
  if (nodePath.length > 0) {
    lines.push(`Scene node: ${nodePath}`);
  }
  if (rootPath.length > 0) {
    lines.push(`Root node: ${rootPath}`);
  }
  if (pivotPath.length > 0) {
    lines.push(`Pivot node: ${pivotPath}`);
  }

  const savedPaths = (result.saved_paths as Record<string, unknown>) ?? {};
  const savedEntries = Object.entries(savedPaths).filter(([, value]) => typeof value === 'string' && (value as string).length > 0);
  if (savedEntries.length > 0) {
    lines.push('Saved resources:');
    for (const [key, value] of savedEntries) {
      lines.push(`- ${key}: ${value as string}`);
    }
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
  {
    name: 'generate_procedural_planet',
    description: 'Generate a seamless procedural planet mesh/material using spherical fractal noise and optional biome texture exports.',
    parameters: proceduralPlanetSchema,
    metadata: {
      requiredRole: 'edit',
      escalationPrompt: 'Approve procedural planet generation and optional scene/resource writes.',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('generate_procedural_planet', args);
      return formatProceduralPlanetResponse(result);
    },
  },
  {
    name: 'generate_procedural_planet_ocean',
    description: 'Generate animated ocean shader/material for planetary shells or single water tiles in the editor.',
    parameters: proceduralPlanetOceanSchema,
    metadata: {
      requiredRole: 'edit',
      escalationPrompt: 'Approve procedural ocean generation and optional scene/resource writes.',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('generate_procedural_planet_ocean', args);
      return formatProceduralOceanResponse(result);
    },
  },
  {
    name: 'create_planet_shell',
    description: 'Create a basic planet shell mesh/material with optional scene instancing and resource saving.',
    parameters: createPlanetShellSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('create_planet_shell', args);
      return formatSimpleNodeResponse('Planet shell created.', result);
    },
  },
  {
    name: 'create_ocean_tile',
    description: 'Create a single procedural ocean tile for editor-level testing and blockouts.',
    parameters: createOceanTileSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('create_ocean_tile', args);
      return formatProceduralOceanResponse(result);
    },
  },
  {
    name: 'apply_triplanar_terrain_material',
    description: 'Apply a triplanar terrain material to a MeshInstance3D node.',
    parameters: triplanarTerrainSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('apply_triplanar_terrain_material', args);
      return formatSimpleNodeResponse('Triplanar terrain material applied.', result);
    },
  },
  {
    name: 'generate_planet_cloud_layer',
    description: 'Generate a procedural cloud shell mesh/material for a planet.',
    parameters: cloudLayerSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('generate_planet_cloud_layer', args);
      return formatSimpleNodeResponse('Planet cloud layer generated.', result);
    },
  },
  {
    name: 'create_planet_atmosphere_glow',
    description: 'Create a fresnel-based atmosphere glow shell around a planet.',
    parameters: atmosphereGlowSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('create_planet_atmosphere_glow', args);
      return formatSimpleNodeResponse('Planet atmosphere glow created.', result);
    },
  },
  {
    name: 'scatter_craters_on_sphere',
    description: 'Scatter crater proxy meshes across a spherical planet surface.',
    parameters: craterScatterSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('scatter_craters_on_sphere', args);
      return formatSimpleNodeResponse('Craters scattered on sphere.', result);
    },
  },
  {
    name: 'create_ring_system',
    description: 'Create a procedural ring system around a planet.',
    parameters: ringSystemSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('create_ring_system', args);
      return formatSimpleNodeResponse('Ring system created.', result);
    },
  },
  {
    name: 'generate_starfield_skybox',
    description: 'Generate a procedural starfield skybox panorama and optionally apply it to Environment settings.',
    parameters: starfieldSkyboxSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('generate_starfield_skybox', args);
      return formatSimpleNodeResponse('Starfield skybox generated.', result);
    },
  },
  {
    name: 'create_moon_proxy',
    description: 'Create a moon mesh with orbit pivot metadata for quick planetary setups.',
    parameters: moonProxySchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('create_moon_proxy', args);
      return formatSimpleNodeResponse('Moon proxy created.', result);
    },
  },
  {
    name: 'planet_preset_quickstart',
    description: 'Build a compact preset planet setup with shell, ocean, clouds, atmosphere, and optional moon.',
    parameters: planetPresetQuickstartSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const godot = getGodotConnection();
      const result = await godot.sendCommand('planet_preset_quickstart', args);
      return formatSimpleNodeResponse('Planet preset created.', result);
    },
  },
];
