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
import { fail, send, vector2 } from './workflow_tools.js';
import { editableNote } from './feature_tools.js';
var status = function (r) { return "[".concat(r.status, "]"); };
export var polishTools = [
    {
        name: 'create_ragdoll',
        description: 'Make a 3D character fall like a ragdoll (Skeleton3D > Create Physical Skeleton): a PhysicalBoneSimulator3D with a capsule PhysicalBone3D per bone, mass spread by bone length. Fingers and tiny bones are skipped. Start it in game with physical_bones_start_simulation(). Undo-aware.',
        parameters: z.object({
            skeleton_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
            joint_type: z.enum(['pin', 'cone', 'hinge']).optional().describe('Default pin (like the editor)'),
            total_mass: z.number().positive().optional().describe('kg for the whole body (default 70)'),
            thickness: z.number().min(0.1).max(10).optional().describe('Capsule radius multiplier (default 1)'),
            skip_fingers: z.boolean().optional().describe('Default true'),
            min_length: z.number().min(0).optional().describe('Skip bones shorter than this, in meters (default 0.03)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, bones, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_ragdoll', args)];
                    case 1:
                        r = _a.sent();
                        bones = r.bones;
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ": ").concat(bones.length, " physical bones (").concat(r.joint_type, " joints, ").concat(r.total_mass, " kg), ").concat(r.skipped, " bones skipped\n").concat(bones.join(', '))
                                + "\nStart it in a script: get_node(\"".concat(String(r.node_path).replace(/^\/root\/?/, ''), "\").physical_bones_start_simulation()").concat(editableNote(r))];
                    case 2:
                        error_1 = _a.sent();
                        return [2 /*return*/, fail('create ragdoll', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'add_screen_effect',
        description: 'Add a full-screen effect on its own CanvasLayer (works over 2D and 3D): vignette, damage_flash (animate amount), crt, pixelate, chromatic_aberration, grayscale, blur (pause menus), color_grade. Effects stack in call order. Undo-aware.',
        parameters: z.object({
            effect: z.enum(['vignette', 'damage_flash', 'crt', 'pixelate', 'chromatic_aberration', 'grayscale', 'blur', 'color_grade']),
            parent_path: z.string().optional(),
            uniforms: z.record(z.any()).optional().describe('e.g. {"strength": 0.8} or {"pixel_size": 6}'),
            enabled: z.boolean().optional().describe('false adds it hidden, to show later'),
            layer: z.number().int().min(-128).max(128).optional().describe('Default 100 draws over HUDs too; pass one below your HUD\'s layer (HUDs are usually 1) to keep the UI crisp'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('add_screen_effect', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.effect, " at ").concat(r.node_path, " (layer ").concat(r.layer, ") ").concat(status(r), "; uniforms: ").concat(r.uniforms.join(', '), ".")
                                + " Change one with update_node_property on ".concat(r.rect_path, " \"material:shader_parameter/<name>\".")];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('add screen effect', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'setup_day_night_cycle',
        description: 'Loop a full day with no script: an AnimationPlayer turns the sun, fades its energy and color, and shifts a ProceduralSkyMaterial\'s colors from sunrise to noon, sunset and night. Uses the scene\'s DirectionalLight3D and WorldEnvironment under parent_path, or makes them. Undo-aware.',
        parameters: z.object({
            parent_path: z.string().optional().describe('A 3D node that holds (or will hold) the sun and environment; default /root'),
            day_length: z.number().min(1).max(86400).optional().describe('Seconds for a full day (default 120)'),
            start_time: z.number().min(0).max(1).optional().describe('Where the day starts: 0 sunrise, 0.12 morning, 0.25 noon, 0.5 sunset, 0.75 midnight'),
            sun_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, created, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('setup_day_night_cycle', args)];
                    case 1:
                        r = _a.sent();
                        created = r.created;
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ": ").concat(r.day_length, "s day from ").concat(r.start_time, ", animates ").concat(r.tracks.join(', '))
                                + "".concat(created.length ? "; created ".concat(created.join(', ')) : '').concat(r.sky ? '' : '; sky not animated (the environment has no ProceduralSkyMaterial)')];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('set up day/night cycle', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'convert_to_multimesh',
        description: 'Merge many MeshInstance3D copies of the same mesh (trees, rocks, fence posts) into one MultiMeshInstance3D each: one draw call instead of hundreds. Copies with children (collision) or scripts are left alone. Undo-aware.',
        parameters: z.object({
            parent_path: z.string(),
            recursive: z.boolean().optional().describe('Also look inside child nodes (default: direct children only)'),
            min_count: z.number().int().min(2).optional().describe('Only merge meshes used at least this often (default 2)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, skipped, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('convert_to_multimesh', args)];
                    case 1:
                        r = _a.sent();
                        skipped = r.skipped;
                        return [2 /*return*/, "Merged ".concat(r.nodes_removed, " meshes into ").concat(r.multimeshes, " MultiMesh node(s) ").concat(status(r), ":\n").concat(r.merged.join('\n'))
                                + (skipped.length ? "\nLeft alone: ".concat(skipped.join(', ')) : '')];
                    case 2:
                        error_4 = _a.sent();
                        return [2 /*return*/, fail('convert to MultiMesh', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'configure_texture_import',
        description: 'Set how images import, then reimport them: preset pixel_art (lossless, no mipmaps, sharp), ui, 3d (VRAM compressed with mipmaps) or normal_map, plus compress, mipmaps, size_limit. Takes files and folders.',
        parameters: z.object({
            paths: z.array(z.string()).min(1).describe('res:// images or folders'),
            preset: z.enum(['pixel_art', 'ui', '3d', 'normal_map']).optional(),
            compress: z.enum(['lossless', 'lossy', 'vram', 'uncompressed', 'basis']).optional(),
            mipmaps: z.boolean().optional(),
            size_limit: z.number().int().min(0).max(16384).optional().describe('Largest side in pixels; 0 = no limit'),
            normal_map: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, skipped, options, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('configure_texture_import', args)];
                    case 1:
                        r = _a.sent();
                        skipped = r.skipped;
                        options = Object.entries(r.options).map(function (_a) {
                            var k = _a[0], v = _a[1];
                            return "".concat(k, "=").concat(v);
                        }).join(', ');
                        return [2 /*return*/, "Reimported ".concat(r.changed, " image(s) with ").concat(options)
                                + (r.files.length ? ":\n".concat(r.files.join('\n')) : '')
                                + (skipped.length ? "\nSkipped: ".concat(skipped.join(', ')) : '')
                                + (r.preset === 'pixel_art' ? '\nFor crisp pixels also set configure_game_settings texture_filter "nearest".' : '')];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('configure texture import', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_audio_randomizer',
        description: 'Combine sound files into an AudioStreamRandomizer so footsteps, hits and shots vary in pitch, volume and take each time they play. Saves a .tres and can assign it to an AudioStreamPlayer (2D/3D).',
        parameters: z.object({
            sounds: z.array(z.string()).min(1).max(64).describe('res:// audio files'),
            pitch_variation: z.number().min(0).max(24).optional().describe('Semitones of random pitch (default 1)'),
            volume_variation: z.number().min(0).max(40).optional().describe('dB of random volume (default 2)'),
            mode: z.enum(['random_no_repeat', 'random', 'sequential']).optional(),
            save_path: z.string().optional(),
            player_path: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_6;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_audio_randomizer', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Saved ".concat(r.save_path, ": ").concat(r.sounds, " sound(s), ").concat(r.mode, ", pitch \u00B1").concat(r.pitch_variation, " semitones, volume \u00B1").concat(r.volume_variation, " dB")
                                + (r.player_path ? "; assigned to ".concat(r.player_path, " ").concat(status(r)) : '')];
                    case 2:
                        error_6 = _a.sent();
                        return [2 /*return*/, fail('create audio randomizer', error_6)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'generate_placeholder_art',
        description: 'Draw simple PNG sprites for prototyping: circle, square, rounded_square, triangle, diamond, star, heart, capsule, character (with eyes), coin, tile (beveled), crate, arrow. Antialiased, with optional outline; saved and imported.',
        parameters: z.object({
            sprites: z.array(z.object({
                shape: z.enum(['circle', 'square', 'rounded_square', 'triangle', 'diamond', 'star', 'heart', 'capsule', 'character', 'coin', 'tile', 'crate', 'arrow']),
                name: z.string().optional().describe('File name without .png'),
                size: z.union([z.number().int().min(4).max(512), vector2]).optional().describe('Pixels: 64 or [32, 48]'),
                color: z.any().optional(),
                outline_color: z.any().optional(),
                outline_width: z.number().min(0).max(32).optional(),
            }).strict()).min(1).max(32),
            folder: z.string().optional().describe('Default res://art/placeholder'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_7;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('generate_placeholder_art', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Made ".concat(r.files.length, " sprite(s):\n").concat(r.files.join('\n')).concat(r.imported === false ? '\nGodot is still importing them; wait a moment before using them.' : '')];
                    case 2:
                        error_7 = _a.sent();
                        return [2 /*return*/, fail('generate placeholder art', error_7)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
];
//# sourceMappingURL=polish_tools.js.map