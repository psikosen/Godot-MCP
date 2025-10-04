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
 * Definition for node tools - operations that manipulate nodes in the scene tree
 */
export var nodeTools = [
    {
        name: 'create_node',
        description: 'Create a new node in the Godot scene tree',
        parameters: z.object({
            parent_path: z.string()
                .describe('Path to the parent node where the new node will be created (e.g. "/root", "/root/MainScene")'),
            node_type: z.string()
                .describe('Type of node to create (e.g. "Node2D", "Sprite2D", "Label")'),
            node_name: z.string()
                .describe('Name for the new node'),
            transaction_id: z.string().optional()
                .describe('Optional transaction identifier to batch multiple scene operations before committing'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_1, error_1;
            var _c;
            var parent_path = _b.parent_path, node_type = _b.node_type, node_name = _b.node_name, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('create_node', {
                                parent_path: parent_path,
                                node_type: node_type,
                                node_name: node_name,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_1 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        return [2 /*return*/, "Created ".concat(node_type, " node named \"").concat(node_name, "\" at ").concat(result.node_path, " [").concat(status_1, "]")];
                    case 3:
                        error_1 = _d.sent();
                        throw new Error("Failed to create node: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'delete_node',
        description: 'Delete a node from the Godot scene tree',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node to delete (e.g. "/root/MainScene/Player")'),
            transaction_id: z.string().optional()
                .describe('Optional transaction identifier to batch multiple scene operations before committing'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_2, error_2;
            var _c;
            var node_path = _b.node_path, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('delete_node', { node_path: node_path, transaction_id: transaction_id })];
                    case 2:
                        result = _d.sent();
                        status_2 = (_c = result === null || result === void 0 ? void 0 : result.status) !== null && _c !== void 0 ? _c : 'committed';
                        return [2 /*return*/, "Deleted node at ".concat(node_path, " [").concat(status_2, "]")];
                    case 3:
                        error_2 = _d.sent();
                        throw new Error("Failed to delete node: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'update_node_property',
        description: 'Update a property of a node in the Godot scene tree',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node to update (e.g. "/root/MainScene/Player")'),
            property: z.string()
                .describe('Name of the property to update (e.g. "position", "text", "modulate")'),
            value: z.any()
                .describe('New value for the property'),
            transaction_id: z.string().optional()
                .describe('Optional transaction identifier to batch multiple scene operations before committing'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_3, error_3;
            var _c;
            var node_path = _b.node_path, property = _b.property, value = _b.value, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('update_node_property', {
                                node_path: node_path,
                                property: property,
                                value: value,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_3 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        return [2 /*return*/, "Updated property \"".concat(property, "\" of node at ").concat(node_path, " to ").concat(JSON.stringify(value), " [").concat(status_3, "]")];
                    case 3:
                        error_3 = _d.sent();
                        throw new Error("Failed to update node property: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'get_node_properties',
        description: 'Get all properties of a node in the Godot scene tree',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node to inspect (e.g. "/root/MainScene/Player")'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, formattedProperties, error_4;
            var node_path = _b.node_path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_node_properties', { node_path: node_path })];
                    case 2:
                        result = _c.sent();
                        formattedProperties = Object.entries(result.properties)
                            .map(function (_a) {
                            var key = _a[0], value = _a[1];
                            return "".concat(key, ": ").concat(JSON.stringify(value));
                        })
                            .join('\n');
                        return [2 /*return*/, "Properties of node at ".concat(node_path, ":\n\n").concat(formattedProperties)];
                    case 3:
                        error_4 = _c.sent();
                        throw new Error("Failed to get node properties: ".concat(error_4.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_nodes',
        description: 'List all child nodes under a parent node in the Godot scene tree',
        parameters: z.object({
            parent_path: z.string()
                .describe('Path to the parent node (e.g. "/root", "/root/MainScene")'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, formattedChildren, error_5;
            var parent_path = _b.parent_path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_nodes', { parent_path: parent_path })];
                    case 2:
                        result = _c.sent();
                        if (result.children.length === 0) {
                            return [2 /*return*/, "No child nodes found under ".concat(parent_path)];
                        }
                        formattedChildren = result.children
                            .map(function (child) { return "".concat(child.name, " (").concat(child.type, ") - ").concat(child.path); })
                            .join('\n');
                        return [2 /*return*/, "Children of node at ".concat(parent_path, ":\n\n").concat(formattedChildren)];
                    case 3:
                        error_5 = _c.sent();
                        throw new Error("Failed to list nodes: ".concat(error_5.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
];
//# sourceMappingURL=node_tools.js.map