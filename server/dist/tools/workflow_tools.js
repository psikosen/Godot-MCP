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
import { spawn } from 'node:child_process';
import { statSync } from 'node:fs';
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
var vector2 = z.union([
    z.object({ x: z.number(), y: z.number() }),
    z.tuple([z.number(), z.number()]),
]);
var send = function (command, params) {
    return getGodotConnection().sendCommand(command, params);
};
var fail = function (what, error) {
    throw new Error("Failed to ".concat(what, ": ").concat(error.message));
};
// Runs Godot's command-line export in its own process: an export inside the editor would block
// every other MCP call until it finished.
function runExport(executable, args, timeoutMs) {
    return new Promise(function (resolve) {
        var child = spawn(executable, args, { stdio: ['ignore', 'pipe', 'pipe'] });
        var output = '';
        var collect = function (chunk) { output = (output + chunk.toString()).slice(-20000); };
        child.stdout.on('data', collect);
        child.stderr.on('data', collect);
        var timer = setTimeout(function () { child.kill(); output += "\nStopped after ".concat(timeoutMs / 1000, "s."); }, timeoutMs);
        child.on('error', function (error) { clearTimeout(timer); resolve({ code: -1, output: error.message }); });
        child.on('close', function (code) { clearTimeout(timer); resolve({ code: code, output: output }); });
    });
}
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
            old_text: z.string().min(1).describe('Exact text to replace, including indentation; must be unique unless replace_all'),
            new_text: z.string().describe('Replacement text'),
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
        description: 'Set common project settings: game name, main scene, window size, stretch, background color, texture filter, gravity, layer names. With no arguments, shows the current values.',
        parameters: z.object({
            game_name: z.string().optional(),
            main_scene: z.string().optional().describe('res:// scene the game starts with'),
            window_width: z.number().int().optional(),
            window_height: z.number().int().optional(),
            stretch_mode: z.enum(['disabled', 'canvas_items', 'viewport']).optional(),
            stretch_aspect: z.enum(['ignore', 'keep', 'keep_width', 'keep_height', 'expand']).optional(),
            clear_color: z.any().optional().describe('Background color, e.g. "#87ceeb"'),
            texture_filter: z.enum(['nearest', 'linear']).optional().describe('"nearest" for pixel art'),
            gravity_2d: z.number().optional(),
            gravity_3d: z.number().optional(),
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
                    case 3: return [4 /*yield*/, runExport(plan.executable, [
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
];
//# sourceMappingURL=workflow_tools.js.map