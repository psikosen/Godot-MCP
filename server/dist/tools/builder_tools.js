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
import { copyFileSync, existsSync, mkdirSync, statSync } from 'node:fs';
import path from 'node:path';
import { z } from 'zod';
import { fail, godotProblems, runGodot, send, vector2 } from './workflow_tools.js';
export var vector3 = z.union([
    z.object({ x: z.number(), y: z.number(), z: z.number() }),
    z.tuple([z.number(), z.number(), z.number()]),
]);
var layerList = z.array(z.union([z.string(), z.number().int().min(1).max(32)])).max(32);
var IMPORTABLE = ['.png', '.jpg', '.jpeg', '.webp', '.svg', '.wav', '.ogg', '.mp3', '.ttf', '.otf', '.woff2',
    '.glb', '.gltf', '.obj', '.fbx', '.csv', '.json', '.txt'];
var status = function (r) { return "[".concat(r.status, "]"); };
export var builderTools = [
    {
        name: 'check_project',
        description: 'Project health check: missing main scene or autoload files, scene/resource links to missing files, scripts that do not compile, input actions used in scripts but not defined.',
        parameters: z.object({
            include_addons: z.boolean().optional().describe('Also check res://addons (default false)'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, issues, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('check_project', args)];
                    case 1:
                        r = _a.sent();
                        issues = r.issues;
                        if (issues.length === 0)
                            return [2 /*return*/, 'No problems found.'];
                        return [2 /*return*/, "".concat(r.error_count, " error(s), ").concat(r.warning_count, " warning(s):\n").concat(issues.join('\n'))];
                    case 2:
                        error_1 = _a.sent();
                        return [2 /*return*/, fail('check project', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'find_unused_files',
        description: 'List project files (images, sounds, fonts, models, scenes, resources, scripts) that no scene, resource, script or project setting refers to. Paths built at runtime are not seen; review before deleting.',
        parameters: z.object({
            include_addons: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, unused, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('find_unused_files', args)];
                    case 1:
                        r = _a.sent();
                        unused = r.unused;
                        return [2 /*return*/, unused.length ? "".concat(unused.length, " unused file(s), ").concat(r.total, ":\n").concat(unused.join('\n')) : 'Every file is referenced.'];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('find unused files', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'replace_in_project',
        description: 'Find and replace across project files (default .gd). Previews by default; pass dry_run false to apply. Changed scripts are compile-checked.',
        parameters: z.object({
            find: z.string().min(1),
            replace: z.string(),
            regex: z.boolean().optional().describe('find is a regular expression; replace may use $1'),
            extensions: z.array(z.string()).optional().describe('Default [".gd"]'),
            include_addons: z.boolean().optional(),
            dry_run: z.boolean().optional().describe('Default true: only report what would change'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, files, errors, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('replace_in_project', args)];
                    case 1:
                        r = _a.sent();
                        files = r.files;
                        errors = r.compile_errors;
                        if (files.length === 0)
                            return [2 /*return*/, 'No matches.'];
                        return [2 /*return*/, "".concat(r.dry_run ? 'Would change' : 'Changed', " ").concat(files.length, " file(s) (file: matches):\n").concat(files.join('\n'))
                                + (errors.length ? "\nScripts that no longer compile:\n".concat(errors.join('\n')) : '')];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('replace in project', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'set_collision_layers',
        description: 'Set a body\'s or area\'s collision layer and mask by layer names (from Project Settings > Layer Names) or numbers. With neither, shows them by name.',
        parameters: z.object({
            node_path: z.string(),
            layers: layerList.optional().describe('What it is, e.g. ["player"]'),
            mask: layerList.optional().describe('What it collides with, e.g. ["world", "enemies"]'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, names, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('set_collision_layers', args)];
                    case 1:
                        r = _a.sent();
                        names = function (list) { return list.join(', ') || 'none'; };
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ": layers ").concat(names(r.layers), "; mask ").concat(names(r.mask))];
                    case 2:
                        error_4 = _a.sent();
                        return [2 /*return*/, fail('set collision layers', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'fit_collision_shape',
        description: 'Size a body\'s or area\'s collision shape to its visible art (Sprite2D, AnimatedSprite2D, Polygon2D; 3D meshes, CSG, sprites). Creates the CollisionShape when missing. Undo-aware.',
        parameters: z.object({
            node_path: z.string().describe('The physics body or area'),
            shape: z.enum(['rectangle', 'circle', 'capsule', 'box', 'sphere']).optional().describe('2D: rectangle (default), circle, capsule; 3D: box (default), sphere, capsule'),
            padding: z.number().optional().describe('Grow (or shrink, if negative) the fitted bounds, in pixels or meters'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('fit_collision_shape', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.created ? 'Created' : 'Resized', " ").concat(r.node_path, " as ").concat(r.shape, " size ").concat(r.size, " at ").concat(r.position, " ").concat(status(r))];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('fit collision shape', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_canvas_shader',
        description: 'Give a 2D node or Control a ready-made shader effect: outline (textured sprites), flash (hit flash), dissolve, wave (sway), grayscale. Writes res://shaders/<effect>.gdshader once and assigns a ShaderMaterial.',
        parameters: z.object({
            node_path: z.string(),
            effect: z.enum(['outline', 'flash', 'dissolve', 'wave', 'grayscale']),
            uniforms: z.record(z.any()).optional().describe('e.g. {"outline_color": "#000000", "width": 2} or {"amount": 1}'),
            shader_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_6;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_canvas_shader', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.effect, " on ").concat(r.node_path, " ").concat(status(r), " using ").concat(r.shader_path, "; uniforms: ").concat(r.uniforms.join(', '), ". Animate one with update_node_property \"material:shader_parameter/<name>\" or a tween.")];
                    case 2:
                        error_6 = _a.sent();
                        return [2 /*return*/, fail('create canvas shader', error_6)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'generate_sfx',
        description: 'Synthesize a retro sound effect (jump, coin, hit, explosion, laser, powerup, blip, footstep) and save it as a WAV in the project. Use pitch/variation/seed for different takes.',
        parameters: z.object({
            preset: z.enum(['jump', 'coin', 'hit', 'explosion', 'laser', 'powerup', 'blip', 'footstep']),
            path: z.string().optional().describe('Default res://audio/sfx/<preset>.wav'),
            pitch: z.number().min(0.25).max(4).optional().describe('1 = normal, 2 = an octave up'),
            variation: z.number().min(0).max(1).optional().describe('Random pitch change, 0..1'),
            volume: z.number().min(0).max(1).optional().describe('Default 0.8'),
            seed: z.number().int().optional(),
            overwrite: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_7;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('generate_sfx', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Saved ".concat(r.preset, " sound (").concat(r.seconds, "s) to ").concat(r.path, ".").concat(r.imported === false ? ' Godot is still importing it; wait a moment before using it.' : '', " Play it with an AudioStreamPlayer (author_audio_stream_player).")];
                    case 2:
                        error_7 = _a.sent();
                        return [2 /*return*/, fail('generate sound effect', error_7)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'paint_tilemap_ascii',
        description: 'Paint a TileMapLayer from text rows, one character per cell, e.g. rows ["#####", "#...#"] with legend {"#": {"source_id": 0, "atlas_coords": [1, 0]}, ".": "erase"}. Spaces leave cells unchanged. One undo step.',
        parameters: z.object({
            node_path: z.string().describe('A TileMapLayer with a TileSet'),
            rows: z.array(z.string()).min(1).max(1000),
            legend: z.record(z.union([
                z.literal('erase'),
                z.object({ source_id: z.number().int().min(0), atlas_coords: vector2, alternative: z.number().int().min(0).optional() }),
            ])),
            origin: vector2.optional().describe('Cell of the first character (default 0,0)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_8;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('paint_tilemap_ascii', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Painted ".concat(r.cells, " cell(s) from ").concat(r.rows, " row(s) on ").concat(r.node_path, " ").concat(status(r))];
                    case 2:
                        error_8 = _a.sent();
                        return [2 /*return*/, fail('paint tilemap', error_8)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'build_blockout_3d',
        description: 'Block out a 3D level: boxes, spheres, cylinders and capsules with colored materials and (by default) static collision, grouped under one node. One undo step.',
        parameters: z.object({
            parent_path: z.string().optional().describe('Default "/root"'),
            name: z.string().optional().describe('Group node name (default "Blockout")'),
            blocks: z.array(z.object({
                name: z.string().optional(),
                shape: z.enum(['box', 'sphere', 'cylinder', 'capsule']).optional(),
                position: vector3.optional(),
                size: vector3.optional().describe('Box size; sphere/cylinder/capsule use x as diameter and y as height'),
                rotation_degrees: vector3.optional(),
                color: z.any().optional(),
                collision: z.boolean().optional().describe('StaticBody3D with a matching shape (default true)'),
            })).min(1).max(500),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_9;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('build_blockout_3d', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Built ".concat(r.blocks, " block(s) under ").concat(r.node_path, " (").concat(r.materials, " material(s)) ").concat(status(r))];
                    case 2:
                        error_9 = _a.sent();
                        return [2 /*return*/, fail('build 3D blockout', error_9)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'setup_2d_lighting',
        description: 'Mood lighting for 2D: a CanvasModulate darkens the level (not separate CanvasLayers such as a HUD or sky), PointLight2D glows light it back up (shared soft radial texture, optional shadows). Updates an existing CanvasModulate. One undo step.',
        parameters: z.object({
            parent_path: z.string().optional().describe('Default "/root"'),
            darkness: z.any().optional().describe('Ambient color, e.g. "#3a3f5c" (dark blue night)'),
            lights: z.array(z.object({
                name: z.string().optional(),
                position: vector2,
                color: z.any().optional().describe('Default warm "#ffd9a0"'),
                energy: z.number().min(0).max(16).optional(),
                radius: z.number().min(4).max(4096).optional().describe('Pixels, default 160'),
                shadows: z.boolean().optional().describe('Cast shadows from LightOccluder2D nodes'),
            })).max(64).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, lights, error_10;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('setup_2d_lighting', args)];
                    case 1:
                        r = _a.sent();
                        lights = r.lights;
                        return [2 /*return*/, "Lighting under ".concat(r.parent_path, " ").concat(status(r), ": darkness ").concat(r.darkness).concat(lights.length ? ", lights ".concat(lights.join(', ')) : '')];
                    case 2:
                        error_10 = _a.sent();
                        return [2 /*return*/, fail('set up 2D lighting', error_10)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'profile_game',
        description: 'Run a scene in a game window for some frames (optionally holding inputs) and report frame and physics time, draw calls, objects drawn, node count and memory. Briefly opens a window.',
        parameters: z.object({
            scene: z.string().optional().describe('res:// scene; default the main scene'),
            frames: z.number().int().min(30).max(36000).optional().describe('Default 300 (about 5 seconds)'),
            hold: z.array(z.object({
                action: z.string(),
                from_frame: z.number().int().min(0),
                to_frame: z.number().int().min(0),
            })).max(20).optional(),
            timeout_seconds: z.number().int().min(10).max(1200).optional().describe('Default 120'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var paths, error_11, scene, frames, holds, _a, code, output, line, p, stat, problems;
            var _b, _c, _d, _e;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        _f.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_runtime_paths', {})];
                    case 1:
                        paths = _f.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        error_11 = _f.sent();
                        return [2 /*return*/, fail('find the game', error_11)];
                    case 3:
                        scene = (_b = args.scene) !== null && _b !== void 0 ? _b : paths.main_scene;
                        if (!scene)
                            throw new Error('No scene given and the project has no main scene');
                        frames = (_c = args.frames) !== null && _c !== void 0 ? _c : 300;
                        holds = ((_d = args.hold) !== null && _d !== void 0 ? _d : []).map(function (h) { return "".concat(h.action, ":").concat(h.from_frame, ":").concat(h.to_frame); });
                        return [4 /*yield*/, runGodot(paths.executable, __spreadArray([
                                '--path', paths.project_dir, '--script', 'res://addons/godot_mcp/runtime/run_scene.gd',
                                '--', scene, String(frames), '-', '--profile'
                            ], holds, true), ((_e = args.timeout_seconds) !== null && _e !== void 0 ? _e : 120) * 1000)];
                    case 4:
                        _a = _f.sent(), code = _a.code, output = _a.output;
                        line = output.split('\n').find(function (l) { return l.startsWith('PROFILE_RESULT '); });
                        if (!line)
                            throw new Error("The game did not report (exit ".concat(code, ").\n").concat(godotProblems(output).join('\n') || output.slice(-1200)));
                        p = JSON.parse(line.slice('PROFILE_RESULT '.length));
                        stat = function (key, unit) {
                            if (unit === void 0) { unit = ''; }
                            return p[key] ? "".concat(p[key].avg).concat(unit, " avg, ").concat(p[key].max).concat(unit, " max") : 'n/a';
                        };
                        problems = godotProblems(output);
                        return [2 /*return*/, __spreadArray([
                                "".concat(scene, ", ").concat(frames, " frames: ").concat(Math.round(p.fps), " fps at the end (capped by vsync)"),
                                "frame time ".concat(stat('frame_ms', 'ms'), "; physics ").concat(stat('physics_ms', 'ms')),
                                "draw calls ".concat(stat('draw_calls'), "; objects drawn ").concat(stat('objects'), "; nodes ").concat(stat('nodes'), "; static memory ").concat(p.memory_mb, " MB")
                            ], (problems.length ? ["errors while running:\n".concat(problems.join('\n'))] : []), true).join('\n')];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to run the game in a window to measure its performance.',
        },
    },
    {
        name: 'import_asset_files',
        description: 'Copy files from this computer (images, sounds, fonts, 3D models, data) into the project, where Godot imports them. Default target res://assets/<file name>.',
        parameters: z.object({
            files: z.array(z.object({
                source: z.string().describe('Absolute path on this computer'),
                target: z.string().optional().describe('res:// path; default res://assets/<file name>'),
            })).min(1).max(100),
            overwrite: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var projectDir, error_12, root, plan, _i, plan_1, _a, from, to;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_runtime_paths', {})];
                    case 1:
                        projectDir = (_b.sent()).project_dir;
                        return [3 /*break*/, 3];
                    case 2:
                        error_12 = _b.sent();
                        return [2 /*return*/, fail('find the project', error_12)];
                    case 3:
                        root = path.resolve(projectDir);
                        plan = args.files.map(function (_a) {
                            var source = _a.source, target = _a.target;
                            var from = path.resolve(source);
                            var extension = path.extname(from).toLowerCase();
                            if (!path.isAbsolute(source))
                                throw new Error("source must be an absolute path: ".concat(source));
                            if (!existsSync(from) || !statSync(from).isFile())
                                throw new Error("Not a file: ".concat(source));
                            if (!IMPORTABLE.includes(extension))
                                throw new Error("".concat(path.basename(from), ": ").concat(extension || 'no extension', " is not an importable asset (").concat(IMPORTABLE.join(' '), ")"));
                            var resPath = target !== null && target !== void 0 ? target : "res://assets/".concat(path.basename(from));
                            if (!resPath.startsWith('res://') || path.extname(resPath).toLowerCase() !== extension) {
                                throw new Error("target must be a res:// path with the same extension: ".concat(resPath));
                            }
                            var to = path.resolve(root, resPath.slice('res://'.length));
                            var lower = path.relative(root, to).toLowerCase().replace(/\\/g, '/');
                            if (to === root || !to.startsWith(root + path.sep) || /^(addons\/godot_mcp|project-manager|\.godot)(\/|$)/.test(lower) || lower === 'project.godot') {
                                throw new Error("target must stay inside the project and away from MCP files: ".concat(resPath));
                            }
                            if (existsSync(to) && !args.overwrite)
                                throw new Error("".concat(resPath, " already exists (pass overwrite true)"));
                            return { from: from, to: to, resPath: resPath };
                        });
                        for (_i = 0, plan_1 = plan; _i < plan_1.length; _i++) {
                            _a = plan_1[_i], from = _a.from, to = _a.to;
                            mkdirSync(path.dirname(to), { recursive: true });
                            copyFileSync(from, to);
                        }
                        return [4 /*yield*/, send('rescan_filesystem', { paths: plan.map(function (p) { return p.resPath; }) }).catch(function () { return undefined; })];
                    case 4:
                        _b.sent();
                        return [2 /*return*/, "Imported ".concat(plan.length, " file(s):\n").concat(plan.map(function (p) { return p.resPath; }).join('\n'))];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to copy files from this computer into the Godot project.',
        },
    },
];
//# sourceMappingURL=builder_tools.js.map