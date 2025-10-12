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
];
//# sourceMappingURL=rendering_tools.js.map