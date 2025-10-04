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
 * Definition for scene tools - operations that manipulate Godot scenes
 */
export var sceneTools = [
    {
        name: 'create_scene',
        description: 'Create a new empty scene with optional root node type',
        parameters: z.object({
            path: z.string()
                .describe('Path where the new scene will be saved (e.g. "res://scenes/new_scene.tscn")'),
            root_node_type: z.string().optional()
                .describe('Type of root node to create (e.g. "Node2D", "Node3D", "Control"). Defaults to "Node" if not specified'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_1;
            var path = _b.path, _c = _b.root_node_type, root_node_type = _c === void 0 ? "Node" : _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('create_scene', { path: path, root_node_type: root_node_type })];
                    case 2:
                        result = _d.sent();
                        return [2 /*return*/, "Created new scene at ".concat(result.scene_path, " with root node type ").concat(result.root_node_type)];
                    case 3:
                        error_1 = _d.sent();
                        throw new Error("Failed to create scene: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'save_scene',
        description: 'Save the current scene to disk',
        parameters: z.object({
            path: z.string().optional()
                .describe('Path where the scene will be saved (e.g. "res://scenes/main.tscn"). If not provided, uses current scene path.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_2;
            var path = _b.path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('save_scene', { path: path })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Saved scene to ".concat(result.scene_path)];
                    case 3:
                        error_2 = _c.sent();
                        throw new Error("Failed to save scene: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'open_scene',
        description: 'Open a scene in the editor',
        parameters: z.object({
            path: z.string()
                .describe('Path to the scene file to open (e.g. "res://scenes/main.tscn")'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_3;
            var path = _b.path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('open_scene', { path: path })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Opened scene at ".concat(result.scene_path)];
                    case 3:
                        error_3 = _c.sent();
                        throw new Error("Failed to open scene: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'get_current_scene',
        description: 'Get information about the currently open scene',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_current_scene', {})];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, "Current scene: ".concat(result.scene_path, "\nRoot node: ").concat(result.root_node_name, " (").concat(result.root_node_type, ")")];
                    case 3:
                        error_4 = _a.sent();
                        throw new Error("Failed to get current scene: ".concat(error_4.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'get_project_info',
        description: 'Get information about the current Godot project',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, godotVersion, output, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_project_info', {})];
                    case 2:
                        result = _a.sent();
                        godotVersion = "".concat(result.godot_version.major, ".").concat(result.godot_version.minor, ".").concat(result.godot_version.patch);
                        output = "Project Name: ".concat(result.project_name, "\n");
                        output += "Project Version: ".concat(result.project_version, "\n");
                        output += "Project Path: ".concat(result.project_path, "\n");
                        output += "Godot Version: ".concat(godotVersion, "\n");
                        if (result.current_scene) {
                            output += "Current Scene: ".concat(result.current_scene);
                        }
                        else {
                            output += "No scene is currently open";
                        }
                        return [2 /*return*/, output];
                    case 3:
                        error_5 = _a.sent();
                        throw new Error("Failed to get project info: ".concat(error_5.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'create_resource',
        description: 'Create a new resource in the project',
        parameters: z.object({
            resource_type: z.string()
                .describe('Type of resource to create (e.g. "ImageTexture", "AudioStreamMP3", "StyleBoxFlat")'),
            resource_path: z.string()
                .describe('Path where the resource will be saved (e.g. "res://resources/style.tres")'),
            properties: z.record(z.any()).optional()
                .describe('Dictionary of property values to set on the resource'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_6;
            var resource_type = _b.resource_type, resource_path = _b.resource_path, _c = _b.properties, properties = _c === void 0 ? {} : _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('create_resource', {
                                resource_type: resource_type,
                                resource_path: resource_path,
                                properties: properties,
                            })];
                    case 2:
                        result = _d.sent();
                        return [2 /*return*/, "Created ".concat(resource_type, " resource at ").concat(result.resource_path)];
                    case 3:
                        error_6 = _d.sent();
                        throw new Error("Failed to create resource: ".concat(error_6.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'begin_scene_transaction',
        description: 'Begin a new scene transaction to batch multiple operations before committing',
        parameters: z.object({
            action_name: z.string().optional()
                .describe('Optional action name used for the Godot Undo/Redo history entry'),
            transaction_id: z.string().optional()
                .describe('Optional transaction identifier. A new one is generated if omitted.'),
            metadata: z.record(z.any()).optional()
                .describe('Optional metadata dictionary persisted with the transaction'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_7;
            var action_name = _b.action_name, transaction_id = _b.transaction_id, metadata = _b.metadata;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('begin_scene_transaction', {
                                action_name: action_name,
                                transaction_id: transaction_id,
                                metadata: metadata,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Began scene transaction ".concat(result.transaction_id, " (").concat(result.action_name, ")")];
                    case 3:
                        error_7 = _c.sent();
                        throw new Error("Failed to begin scene transaction: ".concat(error_7.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'commit_scene_transaction',
        description: 'Commit a previously started scene transaction',
        parameters: z.object({
            transaction_id: z.string()
                .describe('Identifier of the transaction to commit'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_8;
            var transaction_id = _b.transaction_id;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('commit_scene_transaction', {
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Committed scene transaction ".concat(result.transaction_id)];
                    case 3:
                        error_8 = _c.sent();
                        throw new Error("Failed to commit scene transaction: ".concat(error_8.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'rollback_scene_transaction',
        description: 'Rollback a pending or committed scene transaction',
        parameters: z.object({
            transaction_id: z.string()
                .describe('Identifier of the transaction to rollback'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_9;
            var transaction_id = _b.transaction_id;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('rollback_scene_transaction', {
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Rolled back scene transaction ".concat(result.transaction_id, " [").concat(result.status, "]")];
                    case 3:
                        error_9 = _c.sent();
                        throw new Error("Failed to rollback scene transaction: ".concat(error_9.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'list_scene_transactions',
        description: 'List currently registered scene transaction identifiers',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, transactions, error_10;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_scene_transactions', {})];
                    case 2:
                        result = _b.sent();
                        transactions = (_a = result.transactions) !== null && _a !== void 0 ? _a : [];
                        if (transactions.length === 0) {
                            return [2 /*return*/, 'No active scene transactions'];
                        }
                        return [2 /*return*/, "Active scene transactions:\n".concat(transactions.join('\n'))];
                    case 3:
                        error_10 = _b.sent();
                        throw new Error("Failed to list scene transactions: ".concat(error_10.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
];
//# sourceMappingURL=scene_tools.js.map