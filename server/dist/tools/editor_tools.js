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
export var editorTools = [
    {
        name: 'execute_editor_script',
        description: 'Executes arbitrary GDScript code in the Godot editor',
        parameters: z.object({
            code: z.string()
                .describe('GDScript code to execute in the editor context'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, outputText, error_1;
            var code = _b.code;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('execute_editor_script', { code: code })];
                    case 2:
                        result = _c.sent();
                        outputText = 'Script executed successfully';
                        if (result.output && Array.isArray(result.output) && result.output.length > 0) {
                            outputText += '\n\nOutput:\n' + result.output.join('\n');
                        }
                        if (result.result) {
                            outputText += '\n\nResult:\n' + JSON.stringify(result.result, null, 2);
                        }
                        return [2 /*return*/, outputText];
                    case 3:
                        error_1 = _c.sent();
                        throw new Error("Script execution failed: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to execute arbitrary editor scripts within Godot.',
        },
    },
    {
        name: 'run_godot_headless',
        description: 'Launch the Godot editor binary in headless mode and capture its output.',
        parameters: z.object({
            run_target: z
                .string()
                .optional()
                .describe('Optional scene or script target passed to --run.'),
            binary_path: z
                .string()
                .optional()
                .describe('Override path to the Godot executable (defaults to the running editor).'),
            additional_args: z
                .array(z.string())
                .optional()
                .describe('Additional command-line arguments appended to the headless run.'),
            capture_stderr: z
                .boolean()
                .optional()
                .describe('Include stderr output in the captured log (default true).'),
            no_window: z
                .boolean()
                .optional()
                .describe('Pass --no-window alongside --headless (default true).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result;
            var run_target = _b.run_target, binary_path = _b.binary_path, additional_args = _b.additional_args, capture_stderr = _b.capture_stderr, no_window = _b.no_window;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (run_target)
                            payload.run_target = run_target;
                        if (binary_path)
                            payload.binary_path = binary_path;
                        if (additional_args)
                            payload.additional_args = additional_args;
                        if (capture_stderr !== undefined)
                            payload.capture_stderr = capture_stderr;
                        if (no_window !== undefined)
                            payload.no_window = no_window;
                        return [4 /*yield*/, godot.sendCommand('run_godot_headless', payload)];
                    case 1:
                        result = _c.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to execute headless Godot runs from the editor environment.',
        },
    },
    {
        name: 'capture_editor_profile',
        description: 'Capture CPU, rendering, and memory metrics from the running Godot editor.',
        parameters: z.object({
            include_rendering: z
                .boolean()
                .optional()
                .describe('Include rendering statistics (default true).'),
            include_objects: z
                .boolean()
                .optional()
                .describe('Include object and resource counts (default true).'),
            include_memory: z
                .boolean()
                .optional()
                .describe('Include memory usage metrics (default true).'),
            include_gpu: z
                .boolean()
                .optional()
                .describe('Include GPU timing metrics when available (default true).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result;
            var include_rendering = _b.include_rendering, include_objects = _b.include_objects, include_memory = _b.include_memory, include_gpu = _b.include_gpu;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (include_rendering !== undefined)
                            payload.include_rendering = include_rendering;
                        if (include_objects !== undefined)
                            payload.include_objects = include_objects;
                        if (include_memory !== undefined)
                            payload.include_memory = include_memory;
                        if (include_gpu !== undefined)
                            payload.include_gpu = include_gpu;
                        return [4 /*yield*/, godot.sendCommand('capture_editor_profile', payload)];
                    case 1:
                        result = _c.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'manage_editor_plugins',
        description: 'List, enable, or disable Godot editor plugins within the current project.',
        parameters: z
            .object({
            action: z
                .enum(['list', 'enable', 'disable'])
                .default('list')
                .describe('Operation to perform on the plugin registry.'),
            plugins: z
                .array(z.string())
                .optional()
                .describe('Plugin configuration paths or names when enabling/disabling.'),
            persist: z
                .boolean()
                .optional()
                .describe('Persist editor plugin changes to project.godot.'),
        })
            .refine(function (data) { return (data.action === 'list' ? true : Array.isArray(data.plugins) && data.plugins.length > 0); }, {
            message: 'At least one plugin must be provided when enabling or disabling.',
            path: ['plugins'],
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result;
            var action = _b.action, plugins = _b.plugins, persist = _b.persist;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (action) {
                            payload.action = action;
                        }
                        if (plugins) {
                            payload.plugins = plugins;
                        }
                        if (persist !== undefined) {
                            payload.persist = persist;
                        }
                        return [4 /*yield*/, godot.sendCommand('manage_editor_plugins', payload)];
                    case 1:
                        result = _c.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'admin',
            escalationPrompt: 'Request approval to change enabled Godot editor plugins.',
        },
    },
    {
        name: 'snapshot_scene_state',
        description: 'Capture a structured snapshot of the currently edited scene tree for review.',
        parameters: z.object({
            include_internal: z
                .boolean()
                .optional()
                .describe('Include properties beginning with _ and other internal data.'),
            include_resources: z
                .boolean()
                .optional()
                .describe('Include resource metadata such as scripts and materials (default true).'),
            max_properties_per_node: z
                .number()
                .int()
                .nonnegative()
                .optional()
                .describe('Limit the number of properties captured per node (default 32).'),
            node_limit: z
                .number()
                .int()
                .nonnegative()
                .optional()
                .describe('Maximum number of nodes to snapshot (0 means all).'),
            max_depth: z
                .number()
                .int()
                .positive()
                .optional()
                .describe('Maximum depth in the scene tree to traverse (default 3).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result;
            var include_internal = _b.include_internal, include_resources = _b.include_resources, max_properties_per_node = _b.max_properties_per_node, node_limit = _b.node_limit, max_depth = _b.max_depth;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (include_internal !== undefined)
                            payload.include_internal = include_internal;
                        if (include_resources !== undefined)
                            payload.include_resources = include_resources;
                        if (max_properties_per_node !== undefined)
                            payload.max_properties_per_node = max_properties_per_node;
                        if (node_limit !== undefined)
                            payload.node_limit = node_limit;
                        if (max_depth !== undefined)
                            payload.max_depth = max_depth;
                        return [4 /*yield*/, godot.sendCommand('snapshot_scene_state', payload)];
                    case 1:
                        result = _c.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=editor_tools.js.map