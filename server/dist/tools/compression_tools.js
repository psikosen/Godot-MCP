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
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
var compressionSettingsSchema = z
    .record(z.any())
    .refine(function (value) { return Object.keys(value).length > 0; }, {
    message: 'Provide at least one setting key/value to apply.',
})
    .describe('Dictionary of compression options scoped to the selected platform.');
export var compressionTools = [
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
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var platform = _b.platform, settings = _b.settings, save = _b.save;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = {
                                platform: platform,
                                settings: settings,
                            };
                            if (save !== undefined) {
                                payload.save = save;
                            }
                            return [4 /*yield*/, godot.sendCommand('configure_texture_compression', payload)];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
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
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, result;
                var paths = _b.paths;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('batch_reimport_textures', { paths: paths })];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
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
                .refine(function (value) { return Object.keys(value).length > 0; }, {
                message: 'Provide at least one option when defining a preset.',
            })
                .describe('Importer option key/value pairs (e.g. { compress/mode: "Lossless" }).'),
            save: z
                .boolean()
                .optional()
                .describe('Persist the preset immediately when true (default).'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var preset_name = _b.preset_name, importer = _b.importer, options = _b.options, save = _b.save;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = {
                                preset_name: preset_name,
                                importer: importer,
                                options: options,
                            };
                            if (save !== undefined) {
                                payload.save = save;
                            }
                            return [4 /*yield*/, godot.sendCommand('create_texture_import_preset', payload)];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'list_texture_compression_settings',
        description: 'Return the currently configured compression presets and import settings exposed by the project.',
        parameters: z.object({}),
        execute: function () {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('list_texture_compression_settings', {})];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'read',
        },
    },
];
//# sourceMappingURL=compression_tools.js.map