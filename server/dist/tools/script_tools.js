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
/**
 * Definition for script tools - operations that manipulate GDScript files
 */
export var scriptTools = [
    {
        name: 'create_script',
        description: 'Create a new GDScript file in the project',
        parameters: z.object({
            script_path: z.string()
                .describe('Path where the script will be saved (e.g. "res://scripts/player.gd")'),
            content: z.string()
                .describe('Content of the script'),
            node_path: z.string().optional()
                .describe('Path to a node to attach the script to (optional)'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, attachMessage, error_1;
            var script_path = _b.script_path, content = _b.content, node_path = _b.node_path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('create_script', {
                                script_path: script_path,
                                content: content,
                                node_path: node_path,
                            })];
                    case 2:
                        result = _c.sent();
                        attachMessage = node_path
                            ? " and attached to node at ".concat(node_path)
                            : '';
                        return [2 /*return*/, "Created script at ".concat(result.script_path).concat(attachMessage)];
                    case 3:
                        error_1 = _c.sent();
                        throw new Error("Failed to create script: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'edit_script',
        description: 'Edit an existing GDScript file',
        parameters: z.object({
            script_path: z.string()
                .describe('Path to the script file to edit (e.g. "res://scripts/player.gd")'),
            content: z.string()
                .describe('New content of the script'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, error_2;
            var script_path = _b.script_path, content = _b.content;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('edit_script', {
                                script_path: script_path,
                                content: content,
                            })];
                    case 2:
                        _c.sent();
                        return [2 /*return*/, "Updated script at ".concat(script_path)];
                    case 3:
                        error_2 = _c.sent();
                        throw new Error("Failed to edit script: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'get_script',
        description: 'Get the content of a GDScript file',
        parameters: z.object({
            script_path: z.string().optional()
                .describe('Path to the script file (e.g. "res://scripts/player.gd")'),
            node_path: z.string().optional()
                .describe('Path to a node with a script attached'),
        }).refine(function (data) { return data.script_path !== undefined || data.node_path !== undefined; }, {
            message: "Either script_path or node_path must be provided",
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_3;
            var script_path = _b.script_path, node_path = _b.node_path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_script', {
                                script_path: script_path,
                                node_path: node_path,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Script at ".concat(result.script_path, ":\n\n```gdscript\n").concat(result.content, "\n```")];
                    case 3:
                        error_3 = _c.sent();
                        throw new Error("Failed to get script: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'create_script_template',
        description: 'Generate a GDScript template with common boilerplate',
        parameters: z.object({
            class_name: z.string().optional()
                .describe('Optional class name for the script'),
            extends_type: z.string().default('Node')
                .describe('Base class that this script extends (e.g. "Node", "Node2D", "Control")'),
            include_ready: z.boolean().default(true)
                .describe('Whether to include the _ready() function'),
            include_process: z.boolean().default(false)
                .describe('Whether to include the _process() function'),
            include_input: z.boolean().default(false)
                .describe('Whether to include the _input() function'),
            include_physics: z.boolean().default(false)
                .describe('Whether to include the _physics_process() function'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var template;
            var class_name = _b.class_name, extends_type = _b.extends_type, include_ready = _b.include_ready, include_process = _b.include_process, include_input = _b.include_input, include_physics = _b.include_physics;
            return __generator(this, function (_c) {
                template = '';
                // Add class_name if provided
                if (class_name) {
                    template += "class_name ".concat(class_name, "\n");
                }
                // Add extends
                template += "extends ".concat(extends_type, "\n\n");
                // Add common lifecycle methods
                if (include_ready) {
                    template += "func _ready():\n\tpass\n\n";
                }
                if (include_process) {
                    template += "func _process(delta):\n\tpass\n\n";
                }
                if (include_physics) {
                    template += "func _physics_process(delta):\n\tpass\n\n";
                }
                if (include_input) {
                    template += "func _input(event):\n\tpass\n\n";
                }
                // Remove trailing newlines
                template = template.trimEnd();
                return [2 /*return*/, "Generated GDScript template:\n\n```gdscript\n".concat(template, "\n```")];
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
];
//# sourceMappingURL=script_tools.js.map