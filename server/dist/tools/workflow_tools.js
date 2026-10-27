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
import { spawn } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
export var vector2 = z.union([
    z.object({ x: z.number(), y: z.number() }),
    z.tuple([z.number(), z.number()]),
]);
export var send = function (command, params) {
    return getGodotConnection().sendCommand(command, params);
};
export var fail = function (what, error) {
    throw new Error("Failed to ".concat(what, ": ").concat(error.message));
};
// Runs Godot in its own process (export, tests, game frames): doing it inside the editor would
// block every other MCP call until it finished.
// code is a string when the run did not exit by itself ("timed out after 30s"); Godot keeps
// running after a script error, so a crashed test only ends at the timeout.
export function runGodot(executable, args, timeoutMs) {
    return new Promise(function (resolve) {
        var child = spawn(executable, args, { stdio: ['ignore', 'pipe', 'pipe'] });
        var output = '';
        var timedOut = false;
        var collect = function (chunk) { output = (output + chunk.toString()).slice(-20000); };
        child.stdout.on('data', collect);
        child.stderr.on('data', collect);
        var timer = setTimeout(function () { timedOut = true; child.kill(); }, timeoutMs);
        child.on('error', function (error) { clearTimeout(timer); resolve({ code: -1, output: error.message }); });
        child.on('close', function (code) { clearTimeout(timer); resolve({ code: timedOut ? "timed out after ".concat(timeoutMs / 1000, "s") : code, output: output }); });
    });
}
export var godotProblems = function (output, limit) {
    if (limit === void 0) { limit = 12; }
    return output.split('\n')
        .filter(function (line) { return !line.startsWith('{') && /SCRIPT ERROR|^ERROR:|Parse Error|^FAIL|not ok/.test(line); })
        .slice(0, limit);
};
// Repository root (dist/tools -> ../..), where the addon to install into new projects lives.
var REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', '..');
export var workflowTools = [
    {
        name: 'describe_class',
        description: 'Godot class reference: properties (type = default), methods, signals and enums for an engine class or a project class_name. Use filter to keep it short.',
        parameters: z.object({
            class_name: z.string().describe('e.g. "CharacterBody2D", "Tween", or a project class_name'),
            filter: z.string().optional().describe('Only members whose name contains this text'),
            sections: z.array(z.enum(['properties', 'methods', 'signals', 'constants'])).optional()
                .describe('Default: properties, methods, signals'),
            inherited: z.boolean().optional().describe('Include members from parent classes (default false)'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, parts, _i, _a, section, lines, error_1;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('describe_class', args)];
                    case 1:
                        r = _b.sent();
                        parts = ["".concat(r.class).concat(r.script ? " (".concat(r.script, ")") : '', " inherits ").concat(r.inherits.join(' < ') || 'nothing')];
                        for (_i = 0, _a = ['properties', 'methods', 'signals', 'constants']; _i < _a.length; _i++) {
                            section = _a[_i];
                            lines = r[section];
                            if (lines)
                                parts.push("".concat(section, " (").concat(lines.length, "):").concat(lines.length ? "\n  ".concat(lines.join('\n  ')) : ' none'));
                        }
                        return [2 /*return*/, parts.join('\n')];
                    case 2:
                        error_1 = _b.sent();
                        return [2 /*return*/, fail('describe class', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'search_project',
        description: 'Search project text files (.gd, .tscn, .tres, .gdshader, ...) for text or a regex; returns file:line: text. Skips res://addons unless include_addons.',
        parameters: z.object({
            query: z.string().min(1).describe('Text to find (or a regular expression with regex: true)'),
            regex: z.boolean().optional(),
            case_sensitive: z.boolean().optional(),
            extensions: z.array(z.string()).optional().describe('e.g. [".gd"]'),
            include_addons: z.boolean().optional(),
            max_results: z.number().int().min(1).max(1000).optional().describe('Default 100'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, matches, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('search_project', args)];
                    case 1:
                        r = _a.sent();
                        matches = r.matches;
                        if (matches.length === 0)
                            return [2 /*return*/, "No matches in ".concat(r.files_searched, " file(s).")];
                        return [2 /*return*/, "".concat(matches.join('\n')).concat(r.truncated ? '\n(more matches not shown; raise max_results or narrow the query)' : '')];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('search project', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'replace_in_script',
        description: 'Replace an exact piece of text in a .gd or .gdshader file (much cheaper than rewriting the file with edit_script). Reports compile errors.',
        parameters: z.object({
            script_path: z.string().describe('res:// path'),
            find: z.string().min(1).describe('Exact text to replace, including indentation; must be unique unless replace_all'),
            replace: z.string().describe('Replacement text'),
            replace_all: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('replace_in_script', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Replaced ".concat(r.replacements, " occurrence(s) in ").concat(r.script_path)];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('replace in script', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'list_signal_connections',
        description: 'List a node\'s signal connections in the open scene (outgoing and incoming) and its signal names.',
        parameters: z.object({
            node_path: z.string().describe('e.g. "/root/Player"'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, out, inc, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('list_signal_connections', args)];
                    case 1:
                        r = _a.sent();
                        out = r.outgoing;
                        inc = r.incoming;
                        return [2 /*return*/, [
                                "".concat(r.node_path),
                                "outgoing: ".concat(out.length ? "\n  ".concat(out.join('\n  ')) : 'none'),
                                "incoming: ".concat(inc.length ? "\n  ".concat(inc.join('\n  ')) : 'none'),
                                "signals: ".concat(r.signals.join(', ')),
                            ].join('\n')];
                    case 2:
                        error_4 = _a.sent();
                        return [2 /*return*/, fail('list signal connections', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'disconnect_signal',
        description: 'Remove a signal connection (undo-aware).',
        parameters: z.object({
            source_path: z.string(),
            signal_name: z.string(),
            target_path: z.string(),
            method_name: z.string(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('disconnect_signal', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Disconnected ".concat(r.source_path, ".").concat(r.signal_name, " -> ").concat(r.target_path, ".").concat(r.method_name, " [").concat(r.status, "]")];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('disconnect signal', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'manage_autoloads',
        description: 'List, add or remove autoload singletons (global nodes such as a GameState script).',
        parameters: z.object({
            action: z.enum(['list', 'add', 'remove']),
            name: z.string().optional().describe('Autoload name (a valid identifier), for add/remove'),
            path: z.string().optional().describe('res:// .gd or .tscn file, for add'),
            overwrite: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, list, verb, error_6;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('manage_autoloads', args)];
                    case 1:
                        r = _a.sent();
                        list = r.autoloads
                            .map(function (a) { return "".concat(a.name, " = ").concat(a.path).concat(a.global ? '' : ' (not global)'); });
                        verb = r.action === 'add' ? "Added ".concat(args.name, ". ") : r.action === 'remove' ? "Removed ".concat(args.name, ". ") : '';
                        return [2 /*return*/, "".concat(verb, "Autoloads:").concat(list.length ? "\n  ".concat(list.join('\n  ')) : ' none')];
                    case 2:
                        error_6 = _a.sent();
                        return [2 /*return*/, fail('manage autoloads', error_6)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'configure_game_settings',
        description: 'Set common project settings: game name, main scene, icon, window size, stretch, background color, texture filter, gravity, physics engine (Jolt), physics rate and interpolation, renderer, vsync, HDR output, layer names. With no arguments, shows the current values.',
        parameters: z.object({
            game_name: z.string().optional(),
            main_scene: z.string().optional().describe('res:// scene the game starts with'),
            icon: z.string().optional().describe('res:// image for the window and app icon'),
            window_width: z.number().int().optional(),
            window_height: z.number().int().optional(),
            stretch_mode: z.enum(['disabled', 'canvas_items', 'viewport']).optional(),
            stretch_aspect: z.enum(['ignore', 'keep', 'keep_width', 'keep_height', 'expand']).optional(),
            clear_color: z.any().optional().describe('Background color, e.g. "#87ceeb"'),
            texture_filter: z.enum(['nearest', 'linear']).optional().describe('"nearest" for pixel art'),
            gravity_2d: z.number().optional(),
            gravity_3d: z.number().optional(),
            physics_engine_3d: z.enum(['default', 'jolt', 'godot']).optional().describe('jolt is faster and steadier for most 3D games'),
            physics_ticks_per_second: z.number().int().min(1).max(1000).optional(),
            max_physics_steps_per_frame: z.number().int().min(1).max(100).optional(),
            physics_interpolation: z.boolean().optional().describe('Smooth motion between physics steps on high refresh screens'),
            renderer: z.enum(['forward_plus', 'mobile', 'gl_compatibility']).optional().describe('Takes effect after an editor restart'),
            vsync: z.enum(['disabled', 'enabled', 'adaptive', 'mailbox']).optional(),
            hdr_output: z.boolean().optional().describe('Request HDR output on HDR screens (Godot 4.7+)'),
            layer_names: z.record(z.record(z.string())).optional()
                .describe('e.g. {"2d_physics": {"1": "world", "2": "player"}}; kinds: 2d_physics, 3d_physics, 2d_render, 3d_render, 2d_navigation, 3d_navigation, avoidance'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, changes, current, error_7;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('configure_game_settings', args)];
                    case 1:
                        r = _a.sent();
                        changes = r.changes.map(function (c) { return "".concat(c.setting, ": ").concat(c.previous, " -> ").concat(c.value); });
                        current = Object.entries(r.current).map(function (_a) {
                            var k = _a[0], v = _a[1];
                            return "".concat(k, "=").concat(JSON.stringify(v));
                        }).join(', ');
                        return [2 /*return*/, "".concat(changes.length ? "Changed:\n  ".concat(changes.join('\n  '), "\n") : '', "Current: ").concat(current)];
                    case 2:
                        error_7 = _a.sent();
                        return [2 /*return*/, fail('configure game settings', error_7)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'set_control_layout',
        description: 'Lay out a UI Control: anchor preset (full_rect, center, top_right, bottom_wide, ...), margin, size, position, minimum size, size flags. Undo-aware.',
        parameters: z.object({
            node_path: z.string(),
            preset: z.enum(['top_left', 'top_right', 'bottom_left', 'bottom_right', 'center_left', 'center_top', 'center_right',
                'center_bottom', 'center', 'left_wide', 'top_wide', 'right_wide', 'bottom_wide', 'vcenter_wide', 'hcenter_wide', 'full_rect']).optional(),
            margin: z.number().int().optional().describe('Gap from the anchored edges, in pixels'),
            size: vector2.optional(),
            position: vector2.optional(),
            min_size: vector2.optional(),
            size_flags_horizontal: z.enum(['fill', 'expand_fill', 'shrink_begin', 'shrink_center', 'shrink_end']).optional(),
            size_flags_vertical: z.enum(['fill', 'expand_fill', 'shrink_begin', 'shrink_center', 'shrink_end']).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_8;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('set_control_layout', args)];
                    case 1:
                        r = _a.sent();
                        if (r.status === 'no_change')
                            return [2 /*return*/, "".concat(args.node_path, " already has this layout.")];
                        return [2 /*return*/, "Laid out ".concat(r.node_path, " [").concat(r.status, "]: ").concat(r.changes.join('; '))];
                    case 2:
                        error_8 = _a.sent();
                        return [2 /*return*/, fail('set control layout', error_8)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_inherited_scene',
        description: 'Create a scene that inherits another (Godot\'s "New Inherited Scene"), e.g. enemy variants. Opens it unless open is false.',
        parameters: z.object({
            base_scene: z.string().describe('res:// scene to inherit from'),
            path: z.string().describe('res:// .tscn path for the new scene'),
            open: z.boolean().optional(),
            overwrite: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_9;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_inherited_scene', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Created ".concat(r.path, " inheriting ").concat(r.base_scene).concat(r.opened ? ' (now the open scene)' : '')];
                    case 2:
                        error_9 = _a.sent();
                        return [2 /*return*/, fail('create inherited scene', error_9)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'save_branch_as_scene',
        description: 'Save a node and its children as a new scene file (Godot\'s "Save Branch as Scene") and, unless replace is false, put an instance of it in their place.',
        parameters: z.object({
            node_path: z.string().describe('Root of the branch, e.g. "/root/Level/Enemy"'),
            path: z.string().describe('res:// .tscn path for the new scene'),
            replace: z.boolean().optional().describe('Replace the branch with an instance (default true)'),
            overwrite: z.boolean().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_10;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('save_branch_as_scene', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Saved ".concat(args.node_path, " as ").concat(r.path).concat(r.replaced ? "; ".concat(r.node_path, " is now an instance of it") : '')];
                    case 2:
                        error_10 = _a.sent();
                        return [2 /*return*/, fail('save branch as scene', error_10)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'capture_scene_image',
        description: 'Take a picture of the open scene (scripts do not run, so it shows the scene as built). 2D: centered on center at zoom; 3D: from camera_path or the first Camera3D. Needs the editor window (not --headless).',
        parameters: z.object({
            width: z.number().int().min(64).max(2048).optional().describe('Default 960'),
            height: z.number().int().min(64).max(2048).optional().describe('Default 540'),
            center: vector2.optional().describe('2D: world point at the middle of the picture'),
            zoom: z.number().min(0.05).max(20).optional().describe('2D: above 1 zooms in'),
            camera_path: z.string().optional().describe('A Camera2D or Camera3D in the scene to look through'),
            show_helpers: z.boolean().optional().describe('Also draw editor-only helpers: collision shapes, rays, markers'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_11;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('capture_scene_image', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, {
                                content: [
                                    { type: 'image', data: r.image_base64, mimeType: 'image/png' },
                                    { type: 'text', text: "".concat(r.width, "x").concat(r.height, " picture of the open scene") },
                                ],
                            }];
                    case 2:
                        error_11 = _a.sent();
                        return [2 /*return*/, fail('capture scene image', error_11)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'export_project',
        description: 'Export the game (macOS, Windows, Linux or Web) with Godot\'s export templates. Uses the named preset or creates one for the platform. Default output: res://builds/<platform>/.',
        parameters: z.object({
            platform: z.enum(['macos', 'windows', 'linux', 'web']).optional(),
            preset: z.string().optional().describe('Existing preset name from export_presets.cfg'),
            output_path: z.string().optional().describe('res:// or absolute file path'),
            debug: z.boolean().optional().describe('Debug build (default release)'),
            timeout_seconds: z.number().int().min(10).max(1800).optional().describe('Default 300'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var plan, error_12, _a, code, output, size, errors, notes;
            var _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        _d.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('prepare_export', { platform: args.platform, preset: args.preset, output_path: args.output_path })];
                    case 1:
                        plan = _d.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        error_12 = _d.sent();
                        return [2 /*return*/, fail('prepare export', error_12)];
                    case 3: return [4 /*yield*/, runGodot(plan.executable, [
                            '--headless', '--path', plan.project_dir,
                            args.debug ? '--export-debug' : '--export-release', plan.preset, plan.output_path,
                        ], ((_b = args.timeout_seconds) !== null && _b !== void 0 ? _b : 300) * 1000)];
                    case 4:
                        _a = _d.sent(), code = _a.code, output = _a.output;
                        size = 0;
                        try {
                            size = statSync(plan.output_path).size;
                        }
                        catch ( /* not written */_e) { /* not written */ }
                        if (code !== 0 || size === 0) {
                            errors = output.split('\n')
                                .filter(function (line) { return !line.startsWith('{') && !line.trim().startsWith('at:') && /error|cannot|failed|missing|invalid/i.test(line); })
                                .slice(-8).join('\n');
                            throw new Error("Export \"".concat(plan.preset, "\" failed (exit ").concat(code, ").\n").concat(errors || output.slice(-1500)));
                        }
                        notes = (_c = plan.notes) !== null && _c !== void 0 ? _c : [];
                        return [2 /*return*/, "Exported \"".concat(plan.preset, "\" (").concat(plan.platform, ") to ").concat(plan.output_path, " (").concat((size / 1048576).toFixed(1), " MB)").concat(notes.length ? "\nNote: ".concat(notes.join('; ')) : '')];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to export the project, which runs Godot in a separate process and writes the build files.',
        },
    },
    {
        name: 'get_script_outline',
        description: 'Outline a .gd script with line numbers: extends, signals, exports, vars, consts, enums, funcs, inner classes. Read this before get_script on long files.',
        parameters: z.object({
            script_path: z.string().describe('res:// path of a .gd file'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_13;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_script_outline', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.script_path, " (").concat(r.line_count, " lines)\n").concat(r.outline.join('\n'))];
                    case 2:
                        error_13 = _a.sent();
                        return [2 /*return*/, fail('outline script', error_13)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'move_project_file',
        description: 'Move or rename one project file (with its .import/.uid) and rewrite references to it in scenes, resources, scripts and project.godot.',
        parameters: z.object({
            from_path: z.string().describe('res:// path now'),
            to_path: z.string().describe('res:// path after the move (same extension)'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, refs, error_14;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('move_project_file', args)];
                    case 1:
                        r = _a.sent();
                        refs = r.updated_references;
                        return [2 /*return*/, "Moved ".concat(r.from_path, " to ").concat(r.to_path, ". ").concat(refs.length ? "Updated references in: ".concat(refs.join(', ')) : 'No files referred to it by path.')];
                    case 2:
                        error_14 = _a.sent();
                        return [2 /*return*/, fail('move project file', error_14)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'configure_particles_2d',
        description: 'Create a CPUParticles2D (pass parent_path) or configure an existing CPU/GPUParticles2D (node_path) from a preset (dust, sparkle, rain, snow, confetti, burst) plus overrides. One undo step.',
        parameters: z.object({
            node_path: z.string().optional().describe('Existing particles node to configure'),
            parent_path: z.string().optional().describe('Create a new CPUParticles2D under this node'),
            node_name: z.string().optional(),
            preset: z.enum(['dust', 'sparkle', 'rain', 'snow', 'confetti', 'burst']).optional(),
            position: vector2.optional(),
            amount: z.number().int().min(1).max(10000).optional(),
            lifetime: z.number().min(0.01).max(600).optional(),
            one_shot: z.boolean().optional(),
            explosiveness: z.number().min(0).max(1).optional(),
            emitting: z.boolean().optional(),
            local_coords: z.boolean().optional(),
            direction: vector2.optional(),
            spread: z.number().min(0).max(180).optional(),
            gravity: vector2.optional(),
            velocity_min: z.number().optional(),
            velocity_max: z.number().optional(),
            scale_min: z.number().min(0).optional(),
            scale_max: z.number().min(0).optional(),
            color: z.any().optional().describe('Start color, e.g. "#ffd27f"'),
            color_end: z.any().optional().describe('Color at the end of each particle\'s life (fade with alpha 0)'),
            hue_variation: z.number().min(0).max(1).optional(),
            emission_shape: z.enum(['point', 'sphere', 'rectangle']).optional(),
            emission_radius: z.number().min(0).optional(),
            emission_rect_extents: vector2.optional(),
            texture: z.string().optional().describe('res:// image for each particle (default: a square)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_15;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('configure_particles_2d', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.created ? 'Created' : 'Configured', " ").concat(r.type, " ").concat(r.node_path).concat(r.preset ? " (".concat(r.preset, ")") : '', " [").concat(r.status, "]: ").concat(r.changed.join(', '))];
                    case 2:
                        error_15 = _a.sent();
                        return [2 /*return*/, fail('configure particles', error_15)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'manage_translations',
        description: 'Game text in several languages: set_entries writes keys to a translation CSV (keys x locales) and registers the imported files; set_fallback sets the fallback locale; list shows locales and keys. Use tr("KEY") in scripts or the key as Label text.',
        parameters: z.object({
            action: z.enum(['list', 'set_entries', 'set_fallback']),
            csv_path: z.string().optional().describe('Default res://translations/strings.csv'),
            entries: z.record(z.record(z.string())).optional().describe('{"MENU_START": {"en": "Start", "es": "Empezar"}}'),
            locale: z.string().optional().describe('For set_fallback, e.g. "en"'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, keys, error_16;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('manage_translations', args)];
                    case 1:
                        r = _a.sent();
                        keys = r.keys;
                        return [2 /*return*/, "".concat(r.csv_path, ": locales ").concat(r.locales.join(', ') || 'none', "; ").concat(r.key_count, " key(s)").concat(keys.length ? " (".concat(keys.join(', ')).concat(Number(r.key_count) > keys.length ? ', ...' : '', ")") : '', "; registered ").concat(r.registered.length, " translation file(s); fallback ").concat(r.fallback)];
                    case 2:
                        error_16 = _a.sent();
                        return [2 /*return*/, fail('manage translations', error_16)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'select_in_editor',
        description: 'Select a node in the Godot editor and show it in the Inspector, so the person at the editor sees what you mean. With no node_path, returns the current selection.',
        parameters: z.object({
            node_path: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, selected, error_17;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('select_in_editor', args)];
                    case 1:
                        r = _a.sent();
                        selected = r.selected;
                        return [2 /*return*/, selected.length ? "Selected: ".concat(selected.join(', ')) : 'Nothing is selected.'];
                    case 2:
                        error_17 = _a.sent();
                        return [2 /*return*/, fail('select in editor', error_17)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'run_game_tests',
        description: 'Run GDScript test scripts (scripts that extend SceneTree, e.g. res://tests/*.gd) headless, one Godot process each, and report pass/fail. PASS/FAIL or ok/not ok lines are counted; SCRIPT ERRORs and a non-zero exit fail the script.',
        parameters: z.object({
            tests: z.array(z.string()).optional().describe('res:// test scripts; default: every SceneTree script in tests_dir'),
            tests_dir: z.string().optional().describe('Default res://tests'),
            timeout_seconds: z.number().int().min(5).max(1800).optional().describe('Per script, default 120'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var paths, error_18, tests, lines, failed, _i, tests_1, test_1, started, _a, code, output, passes, problems, ok;
            var _b, _c, _d, _e;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        _f.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_runtime_paths', args.tests ? {} : { tests_dir: (_b = args.tests_dir) !== null && _b !== void 0 ? _b : 'res://tests' })];
                    case 1:
                        paths = _f.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        error_18 = _f.sent();
                        return [2 /*return*/, fail('find tests', error_18)];
                    case 3:
                        tests = (_c = args.tests) !== null && _c !== void 0 ? _c : paths.tests;
                        if (tests.length === 0)
                            return [2 /*return*/, "No test scripts (extends SceneTree) found in ".concat((_d = args.tests_dir) !== null && _d !== void 0 ? _d : 'res://tests', ".")];
                        lines = [];
                        failed = 0;
                        _i = 0, tests_1 = tests;
                        _f.label = 4;
                    case 4:
                        if (!(_i < tests_1.length)) return [3 /*break*/, 7];
                        test_1 = tests_1[_i];
                        started = Date.now();
                        return [4 /*yield*/, runGodot(paths.executable, ['--headless', '--path', paths.project_dir, '--fixed-fps', '60', '--script', test_1], ((_e = args.timeout_seconds) !== null && _e !== void 0 ? _e : 120) * 1000)];
                    case 5:
                        _a = _f.sent(), code = _a.code, output = _a.output;
                        passes = output.split('\n').filter(function (line) { return /^(PASS|ok)\b/.test(line); }).length;
                        problems = godotProblems(output);
                        ok = code === 0 && !problems.some(function (line) { return /SCRIPT ERROR|^FAIL|not ok|Parse Error/.test(line); });
                        if (!ok)
                            failed += 1;
                        lines.push("".concat(ok ? 'PASS' : 'FAIL', " ").concat(test_1, ": ").concat(passes, " passed, ").concat(problems.length, " problem(s), ").concat(typeof code === 'string' ? code : "exit ".concat(code), ", ").concat(((Date.now() - started) / 1000).toFixed(1), "s"));
                        lines.push.apply(lines, problems.map(function (line) { return "  ".concat(line.trim().slice(0, 200)); }));
                        _f.label = 6;
                    case 6:
                        _i++;
                        return [3 /*break*/, 4];
                    case 7: return [2 /*return*/, "".concat(tests.length - failed, "/").concat(tests.length, " test script(s) passed\n").concat(lines.join('\n'))];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to run the project\'s test scripts in a separate headless Godot process.',
        },
    },
    {
        name: 'capture_game_frame',
        description: 'Run a scene for some frames in a real game window (scripts run, so HUDs and movement are live), optionally holding input actions, and return the last frame as a picture. Briefly opens a window.',
        parameters: z.object({
            scene: z.string().optional().describe('res:// scene; default the main scene'),
            frames: z.number().int().min(1).max(3600).optional().describe('Frames to run at 60 fps before the picture (default 60)'),
            hold: z.array(z.object({
                action: z.string().describe('Input action, e.g. "move_right"'),
                from_frame: z.number().int().min(0),
                to_frame: z.number().int().min(0),
            })).max(20).optional().describe('Input to hold while it runs'),
            width: z.number().int().min(64).max(3840).optional(),
            height: z.number().int().min(64).max(2160).optional(),
            timeout_seconds: z.number().int().min(5).max(600).optional().describe('Default 60'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var paths, error_19, scene, _a, defaultWidth, defaultHeight, png, holds, _b, code, output, data, problems;
            var _c, _d, _e, _f, _g, _h, _j;
            return __generator(this, function (_k) {
                switch (_k.label) {
                    case 0:
                        _k.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_runtime_paths', {})];
                    case 1:
                        paths = _k.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        error_19 = _k.sent();
                        return [2 /*return*/, fail('find the game', error_19)];
                    case 3:
                        scene = (_c = args.scene) !== null && _c !== void 0 ? _c : paths.main_scene;
                        if (!scene)
                            throw new Error('No scene given and the project has no main scene');
                        _a = paths.window, defaultWidth = _a[0], defaultHeight = _a[1];
                        png = path.join(tmpdir(), "godot-mcp-frame-".concat(process.pid, "-").concat(Date.now(), ".png"));
                        holds = ((_d = args.hold) !== null && _d !== void 0 ? _d : []).map(function (h) { return "".concat(h.action, ":").concat(h.from_frame, ":").concat(h.to_frame); });
                        return [4 /*yield*/, runGodot(paths.executable, __spreadArray([
                                '--path', paths.project_dir, '--fixed-fps', '60', '--resolution',
                                "".concat((_e = args.width) !== null && _e !== void 0 ? _e : defaultWidth, "x").concat((_f = args.height) !== null && _f !== void 0 ? _f : defaultHeight),
                                '--script', 'res://addons/godot_mcp/runtime/run_scene.gd', '--', scene, String((_g = args.frames) !== null && _g !== void 0 ? _g : 60), png
                            ], holds, true), ((_h = args.timeout_seconds) !== null && _h !== void 0 ? _h : 60) * 1000)];
                    case 4:
                        _b = _k.sent(), code = _b.code, output = _b.output;
                        if (!existsSync(png)) {
                            throw new Error("The game did not produce a frame (exit ".concat(code, ").\n").concat(godotProblems(output).join('\n') || output.slice(-1200)));
                        }
                        data = readFileSync(png).toString('base64');
                        rmSync(png, { force: true });
                        problems = godotProblems(output);
                        return [2 /*return*/, {
                                content: [
                                    { type: 'image', data: data, mimeType: 'image/png' },
                                    { type: 'text', text: "".concat(scene, " after ").concat((_j = args.frames) !== null && _j !== void 0 ? _j : 60, " frame(s)").concat(problems.length ? "\nErrors while running:\n".concat(problems.join('\n')) : '') },
                                ],
                            }];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to run the game in a window to take a picture of it.',
        },
    },
    {
        name: 'create_project',
        description: 'Create a new Godot project folder with a main scene and the Godot MCP addon installed and enabled, ready to open in the editor.',
        parameters: z.object({
            path: z.string().describe('Absolute folder for the new project (must not exist or be empty)'),
            name: z.string().min(1).describe('Game name'),
            dimension: z.enum(['2d', '3d']).optional().describe('Main scene root: Node2D or Node3D (default 2d)'),
            renderer: z.enum(['gl_compatibility', 'mobile', 'forward_plus']).optional().describe('Default gl_compatibility (runs everywhere)'),
            window_width: z.number().int().min(64).max(7680).optional(),
            window_height: z.number().int().min(64).max(4320).optional(),
            install_mcp: z.boolean().optional().describe('Copy and enable the Godot MCP addon (default true)'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var target, version, _a, renderer, feature, install, is3d, quoted, projectFile;
            var _b, _c, _d, _e;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        target = path.resolve(args.path);
                        if (!path.isAbsolute(args.path))
                            throw new Error('path must be absolute');
                        if (existsSync(target) && readdirSync(target).length > 0)
                            throw new Error("".concat(target, " already exists and is not empty"));
                        version = '4.4';
                        _f.label = 1;
                    case 1:
                        _f.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, send('get_runtime_paths', {})];
                    case 2:
                        version = (_f.sent()).godot_version;
                        return [3 /*break*/, 4];
                    case 3:
                        _a = _f.sent();
                        return [3 /*break*/, 4];
                    case 4:
                        renderer = (_b = args.renderer) !== null && _b !== void 0 ? _b : 'gl_compatibility';
                        feature = { gl_compatibility: 'GL Compatibility', mobile: 'Mobile', forward_plus: 'Forward Plus' }[renderer];
                        install = (_c = args.install_mcp) !== null && _c !== void 0 ? _c : true;
                        is3d = args.dimension === '3d';
                        quoted = JSON.stringify(args.name);
                        projectFile = __spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray([
                            '; Engine configuration file.', '', 'config_version=5', '', '[application]', '',
                            "config/name=".concat(quoted),
                            'run/main_scene="res://main.tscn"',
                            "config/features=PackedStringArray(\"".concat(version, "\", \"").concat(feature, "\")"),
                            ''
                        ], (install ? ['[autoload]', '', 'MCPAutoload="*res://autoload_mcp_server.gd"', ''] : []), true), [
                            '[display]', '',
                            "window/size/viewport_width=".concat((_d = args.window_width) !== null && _d !== void 0 ? _d : 1280),
                            "window/size/viewport_height=".concat((_e = args.window_height) !== null && _e !== void 0 ? _e : 720)
                        ], false), (is3d ? [] : ['window/stretch/mode="canvas_items"']), true), [
                            ''
                        ], false), (install ? ['[editor_plugins]', '', 'enabled=PackedStringArray("res://addons/godot_mcp/plugin.cfg")', ''] : []), true), [
                            '[rendering]', '',
                            "renderer/rendering_method=\"".concat(renderer, "\"")
                        ], false), (renderer === 'gl_compatibility' ? ['renderer/rendering_method.mobile="gl_compatibility"'] : []), true), [
                            '',
                        ], false).join('\n');
                        mkdirSync(target, { recursive: true });
                        writeFileSync(path.join(target, 'project.godot'), projectFile);
                        writeFileSync(path.join(target, 'main.tscn'), "[gd_scene format=3]\n\n[node name=\"Main\" type=\"".concat(is3d ? 'Node3D' : 'Node2D', "\"]\n"));
                        writeFileSync(path.join(target, '.gitignore'), '.godot/\n');
                        if (install) {
                            cpSync(path.join(REPO_ROOT, 'addons', 'godot_mcp'), path.join(target, 'addons', 'godot_mcp'), {
                                recursive: true,
                                filter: function (source) { return !/_test\.gd|command_handler_minimal/.test(source); },
                            });
                            cpSync(path.join(REPO_ROOT, 'autoload_mcp_server.gd'), path.join(target, 'autoload_mcp_server.gd'));
                        }
                        return [2 /*return*/, "Created ".concat(args.name, " at ").concat(target, " (").concat(is3d ? '3D' : '2D', ", ").concat(feature).concat(install ? ', Godot MCP addon enabled' : '', "). Open it in Godot: godot --path \"").concat(target, "\" --editor")];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to create a new Godot project folder outside the current project.',
        },
    },
];
//# sourceMappingURL=workflow_tools.js.map