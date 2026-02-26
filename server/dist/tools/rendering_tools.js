var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
var dictionarySchema = z.record(z.any());
var materialVariantSchema = z
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
var shaderPreviewSchema = z
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
    .refine(function (value) { return Boolean(value.shader_code) || Boolean(value.shader_path); }, {
    message: 'Provide shader_code or shader_path',
    path: ['shader_code'],
})
    .describe('Compile shader code and return uniform metadata without writing any resources.');
var unwrapUv2Schema = z
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
    .refine(function (value) { return Boolean(value.mesh_path) || Boolean(value.node_path); }, {
    message: 'Provide mesh_path or node_path',
    path: ['mesh_path'],
})
    .describe('Unwrap UV2 coordinates for a mesh resource or MeshInstance3D node.');
var optimizeLodsSchema = z
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
    .refine(function (value) { return Boolean(value.mesh_path) || Boolean(value.node_path); }, {
    message: 'Provide mesh_path or node_path',
    path: ['mesh_path'],
})
    .describe('Generate simplified meshes for multiple LOD levels and optionally assign or save them.');
var environmentCommonSchema = z.object({
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
var configureEnvironmentSchema = environmentCommonSchema
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
    .refine(function (value) { return Boolean(value.environment_path) || Boolean(value.world_environment) || Boolean(value.node_path); }, {
    message: 'Provide environment_path or world_environment/node_path',
    path: ['environment_path'],
})
    .describe('Configure Environment properties, ambient light, fog, sky, and sun scattering settings with undo support.');
var previewSunSchema = environmentCommonSchema
    .extend({
    apply: z
        .boolean()
        .optional()
        .describe('When true, forward the overrides to configure_environment for immediate application.'),
})
    .refine(function (value) { return Boolean(value.environment_path) || Boolean(value.world_environment) || Boolean(value.node_path); }, {
    message: 'Provide environment_path or world_environment/node_path',
    path: ['environment_path'],
})
    .describe('Preview fog sun scattering overrides and optionally apply them to the Environment resource.');
var proceduralPlanetSchema = z
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
var proceduralPlanetOceanSchema = z
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
var createPlanetShellSchema = z
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
var createOceanTileSchema = z
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
var triplanarTerrainSchema = z
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
var cloudLayerSchema = z
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
var atmosphereGlowSchema = z
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
var craterScatterSchema = z
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
var ringSystemSchema = z
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
var starfieldSkyboxSchema = z
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
var moonProxySchema = z
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
var planetPresetQuickstartSchema = z
    .object({
    preset: z.enum(['earthlike', 'desert', 'ice', 'lava']).optional(),
    parent_path: z.string().optional(),
    node_name: z.string().optional(),
    planet_radius: z.number().positive().optional(),
    include_moon: z.boolean().optional(),
})
    .describe('Generate a minimal preset planet setup including shell, ocean, clouds, atmosphere, and optional moon.');
var formatMaterialVariantResponse = function (result) {
    var _a, _b;
    var source = (_a = result.source_material) !== null && _a !== void 0 ? _a : 'res://unknown.tres';
    var saved = Boolean(result.saved);
    var savePath = (_b = result.save_path) !== null && _b !== void 0 ? _b : '';
    var changes = Array.isArray(result.changes) ? result.changes : [];
    var header = "Material variant created from ".concat(source).concat(saved ? " (saved to ".concat(savePath, ")") : '');
    if (changes.length === 0) {
        return "".concat(header, "\nNo material overrides were necessary.");
    }
    var changeLines = changes.map(function (change) {
        var _a, _b, _c, _d, _e;
        if (!change || typeof change !== 'object') {
            return '- Applied material override.';
        }
        var typed = change;
        var type = (_a = typed.type) !== null && _a !== void 0 ? _a : 'property';
        if (type === 'texture') {
            return "- Set ".concat((_b = typed.property) !== null && _b !== void 0 ? _b : 'texture', " to ").concat((_c = typed.value) !== null && _c !== void 0 ? _c : 'resource');
        }
        if (type === 'shader_parameter') {
            return "- Shader parameter ".concat((_d = typed.parameter) !== null && _d !== void 0 ? _d : 'uniform', " -> ").concat(typed.value);
        }
        return "- ".concat((_e = typed.property) !== null && _e !== void 0 ? _e : 'property', " -> ").concat(typed.value);
    });
    return "".concat(header, "\n").concat(changeLines.join('\n'));
};
var formatShaderPreviewResponse = function (result) {
    var _a;
    var uniformCount = Array.isArray(result.uniforms) ? result.uniforms.length : 0;
    var mode = (_a = result.shader_mode) !== null && _a !== void 0 ? _a : 'unknown';
    var defaultTextures = Array.isArray(result.default_textures) ? result.default_textures : [];
    var sections = ["Shader mode: ".concat(mode), "Uniforms detected: ".concat(uniformCount)];
    if (defaultTextures.length > 0) {
        var lines = defaultTextures.map(function (texture) {
            var _a, _b, _c;
            var name = (_a = texture.name) !== null && _a !== void 0 ? _a : 'uniform';
            var type = (_b = texture.type) !== null && _b !== void 0 ? _b : 'Texture';
            var path = (_c = texture.resource_path) !== null && _c !== void 0 ? _c : 'in-memory';
            return "- ".concat(name, " (").concat(type, ") -> ").concat(path);
        });
        sections.push('Default textures:');
        sections.push(lines.join('\n'));
    }
    return sections.join('\n');
};
var formatUnwrapResponse = function (result) {
    var _a;
    var surfaceCount = typeof result.surface_count === 'number' ? result.surface_count : undefined;
    var texelSize = typeof result.texel_size === 'number' ? result.texel_size : undefined;
    var saved = Boolean(result.saved);
    var savePath = (_a = result.save_path) !== null && _a !== void 0 ? _a : '';
    var parts = [
        surfaceCount !== undefined ? "".concat(surfaceCount, " surfaces unwrapped") : 'UV2 unwrap complete',
        texelSize !== undefined ? "texel_size=".concat(texelSize) : undefined,
        saved ? "saved to ".concat(savePath) : undefined,
    ].filter(Boolean);
    return parts.join(' | ');
};
var formatLodResponse = function (result) {
    var lods = Array.isArray(result.lods) ? result.lods : [];
    if (lods.length === 0) {
        return 'No LOD meshes were generated.';
    }
    var lines = lods.map(function (lod, index) {
        var ratio = typeof lod.ratio === 'number' ? lod.ratio.toFixed(2) : 'ratio';
        var surfaces = typeof lod.surface_count === 'number' ? "".concat(lod.surface_count, " surfaces") : 'surfaces unknown';
        var savePath = typeof lod.save_path === 'string' && lod.save_path.length > 0 ? " -> ".concat(lod.save_path) : '';
        return "LOD ".concat(index + 1, ": ratio ").concat(ratio, ", ").concat(surfaces).concat(savePath);
    });
    return __spreadArray(['Generated LOD meshes:'], lines, true).join('\n');
};
var formatEnvironmentResponse = function (result) {
    var _a, _b;
    var envPath = (_a = result.environment_path) !== null && _a !== void 0 ? _a : 'Environment';
    var status = (_b = result.status) !== null && _b !== void 0 ? _b : 'updated';
    var changes = Array.isArray(result.changes) ? result.changes : [];
    if (changes.length === 0) {
        return "".concat(envPath, " ").concat(status, " with no property changes.");
    }
    var lines = changes.map(function (change) {
        var _a, _b, _c;
        if (!change || typeof change !== 'object') {
            return '- Environment property updated.';
        }
        var typed = change;
        var property = (_a = typed.property) !== null && _a !== void 0 ? _a : 'property';
        var value = (_c = (_b = typed.value) !== null && _b !== void 0 ? _b : typed.new_value) !== null && _c !== void 0 ? _c : typed.parsed_value;
        return "- ".concat(property, " -> ").concat(value);
    });
    return __spreadArray(["".concat(envPath, " ").concat(status, ":")], lines, true).join('\n');
};
var formatSunPreviewResponse = function (result) {
    var _a, _b, _c;
    var environmentPath = (_a = result.environment_path) !== null && _a !== void 0 ? _a : 'Environment';
    var current = (_b = result.current) !== null && _b !== void 0 ? _b : {};
    var preview = (_c = result.preview) !== null && _c !== void 0 ? _c : {};
    var lines = ["Sun preview for ".concat(environmentPath, ":")];
    for (var _i = 0, _d = Object.keys(preview); _i < _d.length; _i++) {
        var key = _d[_i];
        var before = current[key];
        var after = preview[key];
        if (before === after) {
            lines.push("- ".concat(key, ": ").concat(after));
        }
        else {
            lines.push("- ".concat(key, ": ").concat(before, " -> ").concat(after));
        }
    }
    if (lines.length === 1) {
        lines.push('- No overrides supplied; current values returned.');
    }
    return lines.join('\n');
};
var formatProceduralPlanetResponse = function (result) {
    var _a, _b;
    var seed = typeof result.seed === 'number' ? result.seed : 'auto';
    var nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
    var elevationRange = (_a = result.elevation_range) !== null && _a !== void 0 ? _a : {};
    var minElevation = typeof elevationRange.min === 'number' ? elevationRange.min.toFixed(3) : 'n/a';
    var maxElevation = typeof elevationRange.max === 'number' ? elevationRange.max.toFixed(3) : 'n/a';
    var lines = ["Procedural planet generated (seed=".concat(seed, ")."), "Elevation range: ".concat(minElevation, " -> ").concat(maxElevation)];
    if (nodePath.length > 0) {
        lines.push("Scene node: ".concat(nodePath));
    }
    var savedPaths = (_b = result.saved_paths) !== null && _b !== void 0 ? _b : {};
    var savedEntries = Object.entries(savedPaths).filter(function (_a) {
        var value = _a[1];
        return typeof value === 'string' && value.length > 0;
    });
    if (savedEntries.length > 0) {
        lines.push('Saved resources:');
        for (var _i = 0, savedEntries_1 = savedEntries; _i < savedEntries_1.length; _i++) {
            var _c = savedEntries_1[_i], key = _c[0], value = _c[1];
            lines.push("- ".concat(key, ": ").concat(value));
        }
    }
    return lines.join('\n');
};
var formatProceduralOceanResponse = function (result) {
    var _a;
    var nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
    var meshMode = typeof result.mesh_mode === 'string' ? result.mesh_mode : 'planet_shell';
    var radius = typeof result.ocean_radius === 'number' ? result.ocean_radius : undefined;
    var tileSize = typeof result.tile_size === 'number' ? result.tile_size : undefined;
    var lines = ["Procedural ocean generated (".concat(meshMode, ").")];
    if (radius !== undefined && meshMode === 'planet_shell') {
        lines.push("Ocean radius: ".concat(radius));
    }
    if (tileSize !== undefined && meshMode === 'single_tile') {
        lines.push("Tile size: ".concat(tileSize));
    }
    if (nodePath.length > 0) {
        lines.push("Scene node: ".concat(nodePath));
    }
    var savedPaths = (_a = result.saved_paths) !== null && _a !== void 0 ? _a : {};
    var savedEntries = Object.entries(savedPaths).filter(function (_a) {
        var value = _a[1];
        return typeof value === 'string' && value.length > 0;
    });
    if (savedEntries.length > 0) {
        lines.push('Saved resources:');
        for (var _i = 0, savedEntries_2 = savedEntries; _i < savedEntries_2.length; _i++) {
            var _b = savedEntries_2[_i], key = _b[0], value = _b[1];
            lines.push("- ".concat(key, ": ").concat(value));
        }
    }
    return lines.join('\n');
};
var formatSimpleNodeResponse = function (label, result) {
    var _a;
    var lines = [label];
    var nodePath = typeof result.created_node_path === 'string' ? result.created_node_path : '';
    var rootPath = typeof result.root_path === 'string' ? result.root_path : '';
    var pivotPath = typeof result.pivot_path === 'string' ? result.pivot_path : '';
    if (nodePath.length > 0) {
        lines.push("Scene node: ".concat(nodePath));
    }
    if (rootPath.length > 0) {
        lines.push("Root node: ".concat(rootPath));
    }
    if (pivotPath.length > 0) {
        lines.push("Pivot node: ".concat(pivotPath));
    }
    var savedPaths = (_a = result.saved_paths) !== null && _a !== void 0 ? _a : {};
    var savedEntries = Object.entries(savedPaths).filter(function (_a) {
        var value = _a[1];
        return typeof value === 'string' && value.length > 0;
    });
    if (savedEntries.length > 0) {
        lines.push('Saved resources:');
        for (var _i = 0, savedEntries_3 = savedEntries; _i < savedEntries_3.length; _i++) {
            var _b = savedEntries_3[_i], key = _b[0], value = _b[1];
            lines.push("- ".concat(key, ": ").concat(value));
        }
    }
    return lines.join('\n');
};
export var renderingTools = [
    {
        name: 'generate_material_variant',
        description: 'Clone a material resource and apply property, shader parameter, and texture overrides.',
        parameters: materialVariantSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_material_variant', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatMaterialVariantResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'compile_shader_preview',
        description: 'Compile Godot shader code to surface uniform metadata and default textures without saving resources.',
        parameters: shaderPreviewSchema,
        metadata: {
            requiredRole: 'read',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('compile_shader_preview', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatShaderPreviewResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'unwrap_lightmap_uv2',
        description: 'Generate UV2 lightmap coordinates for a mesh resource or MeshInstance3D using ArrayMesh.lightmap_unwrap.',
        parameters: unwrapUv2Schema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('unwrap_lightmap_uv2', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatUnwrapResponse(result)];
                    }
                });
            });
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
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('optimize_mesh_lods', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatLodResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'configure_environment',
        description: 'Update Environment properties including ambient light, fog, sky, and sun scattering with undo support.',
        parameters: configureEnvironmentSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('configure_environment', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatEnvironmentResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'preview_environment_sun_settings',
        description: 'Preview fog sun scattering overrides and optionally apply them through configure_environment.',
        parameters: previewSunSchema,
        metadata: {
            requiredRole: 'read',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('preview_environment_sun_settings', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSunPreviewResponse(result)];
                    }
                });
            });
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
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_procedural_planet', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatProceduralPlanetResponse(result)];
                    }
                });
            });
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
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_procedural_planet_ocean', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatProceduralOceanResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'create_planet_shell',
        description: 'Create a basic planet shell mesh/material with optional scene instancing and resource saving.',
        parameters: createPlanetShellSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('create_planet_shell', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Planet shell created.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'create_ocean_tile',
        description: 'Create a single procedural ocean tile for editor-level testing and blockouts.',
        parameters: createOceanTileSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('create_ocean_tile', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatProceduralOceanResponse(result)];
                    }
                });
            });
        },
    },
    {
        name: 'apply_triplanar_terrain_material',
        description: 'Apply a triplanar terrain material to a MeshInstance3D node.',
        parameters: triplanarTerrainSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('apply_triplanar_terrain_material', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Triplanar terrain material applied.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'generate_planet_cloud_layer',
        description: 'Generate a procedural cloud shell mesh/material for a planet.',
        parameters: cloudLayerSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_planet_cloud_layer', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Planet cloud layer generated.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'create_planet_atmosphere_glow',
        description: 'Create a fresnel-based atmosphere glow shell around a planet.',
        parameters: atmosphereGlowSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('create_planet_atmosphere_glow', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Planet atmosphere glow created.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'scatter_craters_on_sphere',
        description: 'Scatter crater proxy meshes across a spherical planet surface.',
        parameters: craterScatterSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('scatter_craters_on_sphere', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Craters scattered on sphere.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'create_ring_system',
        description: 'Create a procedural ring system around a planet.',
        parameters: ringSystemSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('create_ring_system', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Ring system created.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'generate_starfield_skybox',
        description: 'Generate a procedural starfield skybox panorama and optionally apply it to Environment settings.',
        parameters: starfieldSkyboxSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_starfield_skybox', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Starfield skybox generated.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'create_moon_proxy',
        description: 'Create a moon mesh with orbit pivot metadata for quick planetary setups.',
        parameters: moonProxySchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('create_moon_proxy', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Moon proxy created.', result)];
                    }
                });
            });
        },
    },
    {
        name: 'planet_preset_quickstart',
        description: 'Build a compact preset planet setup with shell, ocean, clouds, atmosphere, and optional moon.',
        parameters: planetPresetQuickstartSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('planet_preset_quickstart', args)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, formatSimpleNodeResponse('Planet preset created.', result)];
                    }
                });
            });
        },
    },
];
//# sourceMappingURL=rendering_tools.js.map