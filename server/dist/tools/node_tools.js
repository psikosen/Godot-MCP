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
var hasConfigurationEntries = function (value) {
    return !!value && Object.values(value).some(function (entry) { return entry !== undefined; });
};
var camera2DLimitsSchema = z
    .object({
    enabled: z.boolean().optional().describe('Enable or disable Camera2D limits.'),
    draw_limits: z.boolean().optional().describe('Toggle visualization of Camera2D limits in the editor.'),
    smoothed: z.boolean().optional().describe('Enable smoothing when the camera hits configured limits.'),
    left: z.number().int().optional().describe('Left boundary in pixels.'),
    right: z.number().int().optional().describe('Right boundary in pixels.'),
    top: z.number().int().optional().describe('Top boundary in pixels.'),
    bottom: z.number().int().optional().describe('Bottom boundary in pixels.'),
})
    .refine(function (value) { return Object.values(value).some(function (entry) { return entry !== undefined; }); }, {
    message: 'Provide at least one limit property to update.',
});
var camera2DSmoothingSchema = z
    .object({
    position_enabled: z.boolean().optional().describe('Enable position smoothing for Camera2D.'),
    position_speed: z
        .number()
        .nonnegative()
        .optional()
        .describe('Smoothing speed used when moving towards the target position.'),
    rotation_enabled: z.boolean().optional().describe('Enable rotation smoothing for Camera2D.'),
    rotation_speed: z
        .number()
        .nonnegative()
        .optional()
        .describe('Smoothing speed used when rotating towards the target angle.'),
})
    .refine(function (value) { return Object.values(value).some(function (entry) { return entry !== undefined; }); }, {
    message: 'Provide at least one smoothing property to update.',
});
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
    {
        name: 'duplicate_node',
        description: 'Duplicate an existing node subtree with configurable copy flags',
        parameters: z.object({
            source_path: z.string()
                .describe('Path to the node that should be duplicated'),
            parent_path: z.string().optional()
                .describe('Optional target parent path (defaults to the source parent)'),
            new_name: z.string().optional()
                .describe('Optional name for the duplicated node'),
            duplicate_groups: z.boolean().optional()
                .describe('Copy group membership (default true)'),
            duplicate_signals: z.boolean().optional()
                .describe('Copy signal connections (default true)'),
            duplicate_scripts: z.boolean().optional()
                .describe('Copy attached scripts (default true)'),
            use_instantiation: z.boolean().optional()
                .describe('Use scene instantiation semantics when duplicating subtrees'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_4, resolvedPath, resolvedName, error_6;
            var _c, _d, _e, _f;
            var source_path = _b.source_path, parent_path = _b.parent_path, new_name = _b.new_name, duplicate_groups = _b.duplicate_groups, duplicate_signals = _b.duplicate_signals, duplicate_scripts = _b.duplicate_scripts, use_instantiation = _b.use_instantiation, transaction_id = _b.transaction_id;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('duplicate_node', {
                                source_path: source_path,
                                parent_path: parent_path,
                                new_name: new_name,
                                duplicate_groups: duplicate_groups,
                                duplicate_signals: duplicate_signals,
                                duplicate_scripts: duplicate_scripts,
                                use_instantiation: use_instantiation,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _g.sent();
                        status_4 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        resolvedPath = (_d = result.node_path) !== null && _d !== void 0 ? _d : source_path;
                        resolvedName = (_f = (_e = result.node_name) !== null && _e !== void 0 ? _e : new_name) !== null && _f !== void 0 ? _f : 'copy';
                        return [2 /*return*/, "Duplicated ".concat(source_path, " as ").concat(resolvedName, " at ").concat(resolvedPath, " [").concat(status_4, "]")];
                    case 3:
                        error_6 = _g.sent();
                        throw new Error("Failed to duplicate node: ".concat(error_6.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'reparent_node',
        description: 'Move a node to a different parent with optional rename and index control',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node to move'),
            new_parent_path: z.string()
                .describe('Path to the new parent node'),
            keep_global_transform: z.boolean().optional()
                .describe('Preserve global transform while reparenting (default true)'),
            new_name: z.string().optional()
                .describe('Optional new node name when moved under the new parent'),
            child_index: z.number().int().min(0).optional()
                .describe('Optional index in the new parent child list'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_5, resolvedPath, resolvedParent, resolvedIndex, error_7;
            var _c, _d, _e, _f, _g;
            var node_path = _b.node_path, new_parent_path = _b.new_parent_path, keep_global_transform = _b.keep_global_transform, new_name = _b.new_name, child_index = _b.child_index, transaction_id = _b.transaction_id;
            return __generator(this, function (_h) {
                switch (_h.label) {
                    case 0:
                        godot = getGodotConnection();
                        _h.label = 1;
                    case 1:
                        _h.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('reparent_node', {
                                node_path: node_path,
                                new_parent_path: new_parent_path,
                                keep_global_transform: keep_global_transform,
                                new_name: new_name,
                                child_index: child_index,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _h.sent();
                        status_5 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_5 === 'no_change') {
                            return [2 /*return*/, "Node ".concat(node_path, " is already at the requested parent and ordering.")];
                        }
                        resolvedPath = (_d = result.node_path) !== null && _d !== void 0 ? _d : node_path;
                        resolvedParent = (_e = result.new_parent_path) !== null && _e !== void 0 ? _e : new_parent_path;
                        resolvedIndex = (_g = (_f = result.new_index) !== null && _f !== void 0 ? _f : child_index) !== null && _g !== void 0 ? _g : 'auto';
                        return [2 /*return*/, "Reparented ".concat(resolvedPath, " to ").concat(resolvedParent, " at index ").concat(resolvedIndex, " [").concat(status_5, "]")];
                    case 3:
                        error_7 = _h.sent();
                        throw new Error("Failed to reparent node: ".concat(error_7.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'move_node_in_parent',
        description: 'Reorder a node within its current parent',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node that should be reordered'),
            index: z.number().int().min(0)
                .describe('Target index in the parent child array'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_6, resolvedPath, resolvedIndex, error_8;
            var _c, _d, _e, _f;
            var node_path = _b.node_path, index = _b.index, transaction_id = _b.transaction_id;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('move_node_in_parent', {
                                node_path: node_path,
                                index: index,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _g.sent();
                        status_6 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_6 === 'no_change') {
                            return [2 /*return*/, "Node ".concat(node_path, " is already at index ").concat((_d = result.index) !== null && _d !== void 0 ? _d : index, ".")];
                        }
                        resolvedPath = (_e = result.node_path) !== null && _e !== void 0 ? _e : node_path;
                        resolvedIndex = (_f = result.index) !== null && _f !== void 0 ? _f : index;
                        return [2 /*return*/, "Moved ".concat(resolvedPath, " to index ").concat(resolvedIndex, " [").concat(status_6, "]")];
                    case 3:
                        error_8 = _g.sent();
                        throw new Error("Failed to move node in parent: ".concat(error_8.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'instantiate_scene',
        description: 'Instantiate a PackedScene and add it under a parent node',
        parameters: z.object({
            scene_path: z.string()
                .describe('PackedScene resource path (e.g. "res://scenes/enemy.tscn")'),
            parent_path: z.string().optional()
                .describe('Optional parent node path (defaults to "/root")'),
            node_name: z.string().optional()
                .describe('Optional name for the instantiated root node'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_7, resolvedPath, error_9;
            var _c, _d;
            var scene_path = _b.scene_path, parent_path = _b.parent_path, node_name = _b.node_name, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('instantiate_scene', {
                                scene_path: scene_path,
                                parent_path: parent_path,
                                node_name: node_name,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_7 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        resolvedPath = (_d = result.node_path) !== null && _d !== void 0 ? _d : "".concat(parent_path !== null && parent_path !== void 0 ? parent_path : '/root', "/").concat(node_name !== null && node_name !== void 0 ? node_name : 'Instance');
                        return [2 /*return*/, "Instantiated ".concat(scene_path, " at ").concat(resolvedPath, " [").concat(status_7, "]")];
                    case 3:
                        error_9 = _e.sent();
                        throw new Error("Failed to instantiate scene: ".concat(error_9.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'query_nodes',
        description: 'Search scene nodes by name, type, and group filters',
        parameters: z.object({
            root_path: z.string().optional()
                .describe('Optional root path to search from (defaults to "/root")'),
            name_contains: z.string().optional()
                .describe('Match nodes whose names contain this text (case-insensitive)'),
            node_type: z.string().optional()
                .describe('Match nodes by class name (supports inherited classes)'),
            group_name: z.string().optional()
                .describe('Match nodes in a specific group'),
            include_root: z.boolean().optional()
                .describe('Include the root node in the query evaluation (default true)'),
            include_internal: z.boolean().optional()
                .describe('Include internal children in traversal (default false)'),
            max_results: z.number().int().min(1).max(5000).optional()
                .describe('Maximum number of matched nodes to return (default 500)'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, nodes, count, target, lines, truncated, error_10;
            var _c, _d, _e, _f;
            var root_path = _b.root_path, name_contains = _b.name_contains, node_type = _b.node_type, group_name = _b.group_name, include_root = _b.include_root, include_internal = _b.include_internal, max_results = _b.max_results;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('query_nodes', {
                                root_path: root_path,
                                name_contains: name_contains,
                                node_type: node_type,
                                group_name: group_name,
                                include_root: include_root,
                                include_internal: include_internal,
                                max_results: max_results,
                            })];
                    case 2:
                        result = _g.sent();
                        nodes = (_c = result.nodes) !== null && _c !== void 0 ? _c : [];
                        count = Number((_d = result.count) !== null && _d !== void 0 ? _d : nodes.length);
                        target = (_f = (_e = result.root_path) !== null && _e !== void 0 ? _e : root_path) !== null && _f !== void 0 ? _f : '/root';
                        if (nodes.length === 0) {
                            return [2 /*return*/, "No nodes matched the query under ".concat(target, ".")];
                        }
                        lines = nodes
                            .map(function (node) { return "".concat(node.name, " (").concat(node.type, ") - ").concat(node.path); })
                            .join('\n');
                        truncated = Boolean(result.truncated);
                        return [2 /*return*/, "Query matched ".concat(count, " node(s) under ").concat(target).concat(truncated ? ' (truncated)' : '', ":\n").concat(lines)];
                    case 3:
                        error_10 = _g.sent();
                        throw new Error("Failed to query nodes: ".concat(error_10.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'bulk_update_node_properties',
        description: 'Apply multiple node property updates in one undo-aware operation',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node to update'),
            properties: z.record(z.any())
                .refine(function (value) { return Object.keys(value).length > 0; }, {
                message: 'Provide at least one property update.',
            })
                .describe('Property map where keys are property paths (e.g. "position.x")'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_8, changes, error_11;
            var _c, _d;
            var node_path = _b.node_path, properties = _b.properties, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('bulk_update_node_properties', {
                                node_path: node_path,
                                properties: properties,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_8 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_8 === 'no_change') {
                            return [2 /*return*/, "Bulk update on ".concat(node_path, " had no effective property changes.")];
                        }
                        changes = (_d = result.changes) !== null && _d !== void 0 ? _d : [];
                        return [2 /*return*/, "Bulk updated ".concat(node_path, " with ").concat(changes.length, " property change(s) [").concat(status_8, "]")];
                    case 3:
                        error_11 = _e.sent();
                        throw new Error("Failed to bulk update node properties: ".concat(error_11.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'batch_create_nodes',
        description: 'Create multiple child nodes in one undo-aware operation',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path where all nodes should be created (defaults to "/root")'),
            nodes: z.array(z.object({
                node_type: z.string()
                    .describe('Godot node type such as Node2D, Node3D, Label, etc.'),
                node_name: z.string().optional()
                    .describe('Optional preferred node name; the server will resolve conflicts.'),
                properties: z.record(z.any()).optional()
                    .describe('Optional property map applied to the node after instantiation.'),
            })).min(1)
                .describe('List of nodes to create'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_9, count, resolvedParent, error_12;
            var _c, _d, _e, _f;
            var parent_path = _b.parent_path, nodes = _b.nodes, transaction_id = _b.transaction_id;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('batch_create_nodes', {
                                parent_path: parent_path,
                                nodes: nodes,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _g.sent();
                        status_9 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        count = Number((_d = result.count) !== null && _d !== void 0 ? _d : (Array.isArray(result.created_nodes) ? result.created_nodes.length : nodes.length));
                        resolvedParent = (_f = (_e = result.parent_path) !== null && _e !== void 0 ? _e : parent_path) !== null && _f !== void 0 ? _f : '/root';
                        return [2 /*return*/, "Batch created ".concat(count, " node(s) under ").concat(resolvedParent, " [").concat(status_9, "]")];
                    case 3:
                        error_12 = _g.sent();
                        throw new Error("Failed to batch create nodes: ".concat(error_12.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'batch_delete_nodes',
        description: 'Delete multiple nodes in one undo-aware operation',
        parameters: z.object({
            node_paths: z.array(z.string()).min(1)
                .describe('Node paths to delete'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_10, deletedCount, skipped, error_13;
            var _c, _d;
            var node_paths = _b.node_paths, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('batch_delete_nodes', {
                                node_paths: node_paths,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_10 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        deletedCount = Number((_d = result.deleted_count) !== null && _d !== void 0 ? _d : 0);
                        skipped = Array.isArray(result.skipped_descendants) ? result.skipped_descendants.length : 0;
                        return [2 /*return*/, "Batch deleted ".concat(deletedCount, " node(s) [").concat(status_10, "]").concat(skipped > 0 ? "; skipped ".concat(skipped, " descendant duplicates") : '')];
                    case 3:
                        error_13 = _e.sent();
                        throw new Error("Failed to batch delete nodes: ".concat(error_13.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_node_script',
        description: 'Assign a script resource to a node with undo support',
        parameters: z.object({
            node_path: z.string()
                .describe('Node path to receive the script'),
            script_path: z.string()
                .describe('Script resource path in the project (res://...)'),
            create_script: z.boolean().optional()
                .describe('Create the script file if it does not exist'),
            extends_type: z.string().optional()
                .describe('Extends type used when creating a new script'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_11, error_14;
            var _c;
            var node_path = _b.node_path, script_path = _b.script_path, create_script = _b.create_script, extends_type = _b.extends_type, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_node_script', {
                                node_path: node_path,
                                script_path: script_path,
                                create_script: create_script,
                                extends_type: extends_type,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_11 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_11 === 'no_change') {
                            return [2 /*return*/, "Node ".concat(node_path, " already uses script ").concat(script_path, ".")];
                        }
                        return [2 /*return*/, "Assigned script ".concat(script_path, " to ").concat(node_path, " [").concat(status_11, "]")];
                    case 3:
                        error_14 = _d.sent();
                        throw new Error("Failed to set node script: ".concat(error_14.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'clear_node_script',
        description: 'Remove the assigned script from a node',
        parameters: z.object({
            node_path: z.string()
                .describe('Node path whose script should be cleared'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_12, error_15;
            var _c;
            var node_path = _b.node_path, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('clear_node_script', {
                                node_path: node_path,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_12 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_12 === 'no_change') {
                            return [2 /*return*/, "Node ".concat(node_path, " does not have an assigned script.")];
                        }
                        return [2 /*return*/, "Cleared script from ".concat(node_path, " [").concat(status_12, "]")];
                    case 3:
                        error_15 = _d.sent();
                        throw new Error("Failed to clear node script: ".concat(error_15.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_node_owner_recursive',
        description: 'Set owner for a node subtree so edits persist in the scene file',
        parameters: z.object({
            node_path: z.string()
                .describe('Root node of the subtree to update'),
            owner_path: z.string().optional()
                .describe('Owner node path (defaults to "/root")'),
            include_root: z.boolean().optional()
                .describe('Whether to apply owner changes to the root node itself (default true)'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_13, changedCount, error_16;
            var _c, _d, _e, _f;
            var node_path = _b.node_path, owner_path = _b.owner_path, include_root = _b.include_root, transaction_id = _b.transaction_id;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_node_owner_recursive', {
                                node_path: node_path,
                                owner_path: owner_path,
                                include_root: include_root,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _g.sent();
                        status_13 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        changedCount = Number((_d = result.changed_count) !== null && _d !== void 0 ? _d : 0);
                        if (status_13 === 'no_change') {
                            return [2 /*return*/, "Node ownership under ".concat(node_path, " already matches ").concat((_f = (_e = result.owner_path) !== null && _e !== void 0 ? _e : owner_path) !== null && _f !== void 0 ? _f : '/root', ".")];
                        }
                        return [2 /*return*/, "Updated owner for ".concat(changedCount, " node(s) under ").concat(node_path, " [").concat(status_13, "]")];
                    case 3:
                        error_16 = _g.sent();
                        throw new Error("Failed to set node owner recursively: ".concat(error_16.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'paint_tilemap_cells_2d',
        description: 'Paint TileMapLayer or TileMap cells for 2D level authoring',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to a TileMapLayer or TileMap node'),
            layer: z.number().int().min(0).optional()
                .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
            cells: z.array(z.object({
                position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
                coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
                x: z.number().optional(),
                y: z.number().optional(),
                source_id: z.number().int(),
                atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
                alternative_tile: z.number().int().optional(),
            })).min(1)
                .describe('Cell paint operations'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_14, changed, error_17;
            var _c, _d;
            var node_path = _b.node_path, layer = _b.layer, cells = _b.cells, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('paint_tilemap_cells_2d', {
                                node_path: node_path,
                                layer: layer,
                                cells: cells,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_14 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        changed = Number((_d = result.change_count) !== null && _d !== void 0 ? _d : 0);
                        if (status_14 === 'no_change') {
                            return [2 /*return*/, "Tile paint on ".concat(node_path, " produced no effective changes.")];
                        }
                        return [2 /*return*/, "Painted ".concat(changed, " TileMap cell(s) on ").concat(node_path, " [").concat(status_14, "]")];
                    case 3:
                        error_17 = _e.sent();
                        throw new Error("Failed to paint TileMap cells: ".concat(error_17.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'clear_tilemap_cells_2d',
        description: 'Clear TileMapLayer or TileMap cells for 2D level authoring',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to a TileMapLayer or TileMap node'),
            layer: z.number().int().min(0).optional()
                .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
            cells: z.array(z.union([
                z.object({
                    position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
                    coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
                    x: z.number().optional(),
                    y: z.number().optional(),
                }),
                z.tuple([z.number(), z.number()]),
            ])).min(1)
                .describe('Cell coordinates to clear'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_15, changed, error_18;
            var _c, _d;
            var node_path = _b.node_path, layer = _b.layer, cells = _b.cells, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('clear_tilemap_cells_2d', {
                                node_path: node_path,
                                layer: layer,
                                cells: cells,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_15 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        changed = Number((_d = result.change_count) !== null && _d !== void 0 ? _d : 0);
                        if (status_15 === 'no_change') {
                            return [2 /*return*/, "Tile clear on ".concat(node_path, " produced no effective changes.")];
                        }
                        return [2 /*return*/, "Cleared ".concat(changed, " TileMap cell(s) on ").concat(node_path, " [").concat(status_15, "]")];
                    case 3:
                        error_18 = _e.sent();
                        throw new Error("Failed to clear TileMap cells: ".concat(error_18.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_camera2d_follow',
        description: 'Configure Camera2D follow behavior for 2D gameplay',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Camera2D node'),
            zoom: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            enabled: z.boolean().optional(),
            ignore_rotation: z.boolean().optional(),
            position_smoothing_enabled: z.boolean().optional(),
            position_smoothing_speed: z.number().optional(),
            rotation_smoothing_enabled: z.boolean().optional(),
            rotation_smoothing_speed: z.number().optional(),
            drag_enabled: z.object({ horizontal: z.boolean().optional(), vertical: z.boolean().optional() }).optional(),
            drag_margins: z.object({ left: z.number().optional(), right: z.number().optional(), top: z.number().optional(), bottom: z.number().optional() }).optional(),
            drag_offsets: z.object({ horizontal: z.number().optional(), vertical: z.number().optional() }).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_16, changed, error_19;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_camera2d_follow', args)];
                    case 2:
                        result = _b.sent();
                        status_16 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_16 === 'no_change') {
                            return [2 /*return*/, "Camera2D at ".concat(args.node_path, " already matches requested follow settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Camera2D follow on ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_16, "]")];
                    case 3:
                        error_19 = _b.sent();
                        throw new Error("Failed to configure Camera2D follow: ".concat(error_19.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_parallax_2d',
        description: 'Configure Parallax2D scrolling properties for layered backgrounds',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Parallax2D node'),
            scroll_scale: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            scroll_offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            autoscroll: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            repeat_size: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            follow_viewport: z.boolean().optional(),
            ignore_camera_scroll: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_17, changed, error_20;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_parallax_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_17 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_17 === 'no_change') {
                            return [2 /*return*/, "Parallax2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Parallax2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_17, "]")];
                    case 3:
                        error_20 = _b.sent();
                        throw new Error("Failed to configure Parallax2D: ".concat(error_20.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_animated_sprite_2d',
        description: 'Configure AnimatedSprite2D resources and playback-related properties',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the AnimatedSprite2D node'),
            sprite_frames_path: z.string().optional()
                .describe('Optional SpriteFrames resource path (res://...)'),
            animation: z.string().optional()
                .describe('Animation name from the SpriteFrames resource'),
            autoplay: z.string().optional()
                .describe('Autoplay animation name'),
            speed_scale: z.number().optional(),
            centered: z.boolean().optional(),
            offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            flip_h: z.boolean().optional(),
            flip_v: z.boolean().optional(),
            frame: z.number().int().optional(),
            frame_progress: z.number().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_18, changed, error_21;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_animated_sprite_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_18 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_18 === 'no_change') {
                            return [2 /*return*/, "AnimatedSprite2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured AnimatedSprite2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_18, "]")];
                    case 3:
                        error_21 = _b.sent();
                        throw new Error("Failed to configure AnimatedSprite2D: ".concat(error_21.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_sprite_2d',
        description: 'Configure Sprite2D texture and rendering properties',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Sprite2D node'),
            texture_path: z.string().optional()
                .describe('Texture2D resource path (res://...) or empty string to clear'),
            centered: z.boolean().optional(),
            offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            flip_h: z.boolean().optional(),
            flip_v: z.boolean().optional(),
            hframes: z.number().int().min(1).optional(),
            vframes: z.number().int().min(1).optional(),
            frame: z.number().int().min(0).optional(),
            frame_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
            region_enabled: z.boolean().optional(),
            region_filter_clip_enabled: z.boolean().optional(),
            region_rect: z.union([
                z.object({
                    position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
                    size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
                    x: z.number().optional(),
                    y: z.number().optional(),
                    width: z.number().optional(),
                    height: z.number().optional(),
                }),
                z.tuple([z.number(), z.number(), z.number(), z.number()]),
            ]).optional(),
            modulate: z.any().optional(),
            self_modulate: z.any().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_19, changed, error_22;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_sprite_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_19 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_19 === 'no_change') {
                            return [2 /*return*/, "Sprite2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Sprite2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_19, "]")];
                    case 3:
                        error_22 = _b.sent();
                        throw new Error("Failed to configure Sprite2D: ".concat(error_22.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_characterbody2d_controller',
        description: 'Configure CharacterBody2D movement/controller properties for 2D platformers',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the CharacterBody2D node'),
            up_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            motion_mode: z.number().int().optional(),
            floor_stop_on_slope: z.boolean().optional(),
            floor_constant_speed: z.boolean().optional(),
            floor_block_on_wall: z.boolean().optional(),
            floor_snap_length: z.number().optional(),
            floor_max_angle: z.number().optional(),
            wall_min_slide_angle: z.number().optional(),
            max_slides: z.number().int().min(1).optional(),
            safe_margin: z.number().nonnegative().optional(),
            slide_on_ceiling: z.boolean().optional(),
            platform_on_leave: z.number().int().optional(),
            platform_floor_layers: z.number().int().optional(),
            platform_wall_layers: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_20, changed, error_23;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_characterbody2d_controller', args)];
                    case 2:
                        result = _b.sent();
                        status_20 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_20 === 'no_change') {
                            return [2 /*return*/, "CharacterBody2D at ".concat(args.node_path, " already matches requested controller settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured CharacterBody2D controller at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_20, "]")];
                    case 3:
                        error_23 = _b.sent();
                        throw new Error("Failed to configure CharacterBody2D controller: ".concat(error_23.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_area2d_sensor',
        description: 'Configure Area2D sensor/field behavior for triggers and environmental effects',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Area2D node'),
            monitoring: z.boolean().optional(),
            monitorable: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            priority: z.number().optional(),
            gravity_space_override: z.number().int().optional(),
            gravity_point: z.boolean().optional(),
            gravity_point_center: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            gravity_point_unit_distance: z.number().optional(),
            gravity_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
            gravity: z.number().optional(),
            linear_damp_space_override: z.number().int().optional(),
            linear_damp: z.number().optional(),
            angular_damp_space_override: z.number().int().optional(),
            angular_damp: z.number().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_21, changed, error_24;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_area2d_sensor', args)];
                    case 2:
                        result = _b.sent();
                        status_21 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_21 === 'no_change') {
                            return [2 /*return*/, "Area2D at ".concat(args.node_path, " already matches requested sensor settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Area2D sensor at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_21, "]")];
                    case 3:
                        error_24 = _b.sent();
                        throw new Error("Failed to configure Area2D sensor: ".concat(error_24.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'fill_tilemap_rect_2d',
        description: 'Fill or clear a rectangular TileMap region for rapid 2D level layout',
        parameters: z
            .object({
            node_path: z.string()
                .describe('Path to a TileMapLayer or TileMap node'),
            layer: z.number().int().min(0).optional()
                .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
            origin: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
                .describe('Rectangle origin in cell coordinates'),
            size: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
                .describe('Rectangle size in cell units'),
            rect: z.union([
                z.object({
                    position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
                    size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
                    x: z.number().optional(),
                    y: z.number().optional(),
                    width: z.number().optional(),
                    height: z.number().optional(),
                }),
                z.tuple([z.number(), z.number(), z.number(), z.number()]),
            ]).optional()
                .describe('Alternative rectangle descriptor'),
            clear: z.boolean().optional()
                .describe('Clear cells instead of painting tile values'),
            source_id: z.number().int().optional()
                .describe('Tile source id (required unless clear=true)'),
            atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
            alternative_tile: z.number().int().optional(),
            transaction_id: z.string().optional(),
        })
            .superRefine(function (value, ctx) {
            if (!value.rect && (!value.origin || !value.size)) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    message: 'Provide either rect or both origin and size.',
                    path: ['rect'],
                });
            }
            if (!value.clear && value.source_id === undefined) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    message: 'source_id is required unless clear=true.',
                    path: ['source_id'],
                });
            }
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_22, changed, error_25;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('fill_tilemap_rect_2d', args)];
                    case 2:
                        result = _c.sent();
                        status_22 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        changed = Number((_b = result.change_count) !== null && _b !== void 0 ? _b : 0);
                        if (status_22 === 'no_change') {
                            return [2 /*return*/, "TileMap fill on ".concat(args.node_path, " produced no effective changes.")];
                        }
                        return [2 /*return*/, "".concat(args.clear ? 'Cleared' : 'Filled', " ").concat(changed, " TileMap cell(s) on ").concat(args.node_path, " [").concat(status_22, "]")];
                    case 3:
                        error_25 = _c.sent();
                        throw new Error("Failed to fill TileMap rect: ".concat(error_25.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'rename_node',
        description: 'Rename an existing node while preserving undo history',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node that should be renamed (e.g. "/root/MainScene/Player")'),
            new_name: z.string()
                .min(1)
                .describe('New name for the node'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_23, previousName, error_26;
            var _c, _d, _e;
            var node_path = _b.node_path, new_name = _b.new_name, transaction_id = _b.transaction_id;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        godot = getGodotConnection();
                        _f.label = 1;
                    case 1:
                        _f.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('rename_node', {
                                node_path: node_path,
                                new_name: new_name,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _f.sent();
                        status_23 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_23 === 'no_change') {
                            return [2 /*return*/, "Node at ".concat(node_path, " already has the name \"").concat(new_name, "\".")];
                        }
                        previousName = (_e = (_d = result.previous_name) !== null && _d !== void 0 ? _d : node_path.split('/').pop()) !== null && _e !== void 0 ? _e : node_path;
                        return [2 /*return*/, "Renamed node ".concat(previousName, " to ").concat(result.new_name, " [").concat(status_23, "]")];
                    case 3:
                        error_26 = _f.sent();
                        throw new Error("Failed to rename node: ".concat(error_26.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'add_node_to_group',
        description: 'Add a node to a Godot group with optional persistence for scene saving',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node that should join the group (e.g. "/root/MainScene/Enemy")'),
            group_name: z.string()
                .min(1)
                .describe('Group name to assign (case-sensitive)'),
            persistent: z.boolean().optional()
                .describe('Whether the membership should be stored in the scene file (default true)'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_24, error_27;
            var _c;
            var node_path = _b.node_path, group_name = _b.group_name, persistent = _b.persistent, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('add_node_to_group', {
                                node_path: node_path,
                                group_name: group_name,
                                persistent: persistent,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_24 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_24 === 'already_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is already in group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Added node ".concat(node_path, " to group \"").concat(group_name, "\" [").concat(status_24, "]")];
                    case 3:
                        error_27 = _d.sent();
                        throw new Error("Failed to add node to group: ".concat(error_27.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'remove_node_from_group',
        description: 'Remove a node from a Godot group with undo support',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node whose group membership should be removed'),
            group_name: z.string()
                .min(1)
                .describe('Group name to remove from the node'),
            persistent: z.boolean().optional()
                .describe('Whether undo should restore the membership as persistent (default true)'),
            transaction_id: z.string().optional()
                .describe('Optional scene transaction identifier used to batch operations'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_25, error_28;
            var _c;
            var node_path = _b.node_path, group_name = _b.group_name, persistent = _b.persistent, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('remove_node_from_group', {
                                node_path: node_path,
                                group_name: group_name,
                                persistent: persistent,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_25 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_25 === 'not_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is not part of group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Removed node ".concat(node_path, " from group \"").concat(group_name, "\" [").concat(status_25, "]")];
                    case 3:
                        error_28 = _d.sent();
                        throw new Error("Failed to remove node from group: ".concat(error_28.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_camera2d_limits',
        description: 'Adjust Camera2D limit bounds, smoothing, and editor visualization using undo-aware transactions.',
        parameters: z
            .object({
            node_path: z
                .string()
                .describe('Path to the Camera2D node that should be configured (e.g. "/root/MainScene/Camera2D")'),
            transaction_id: z
                .string()
                .optional()
                .describe('Optional scene transaction identifier used to batch operations before committing.'),
            limits: camera2DLimitsSchema.optional(),
            smoothing: camera2DSmoothingSchema.optional(),
        })
            .superRefine(function (value, ctx) {
            var hasLimits = value.limits !== undefined;
            var hasSmoothing = value.smoothing !== undefined;
            if (!hasLimits && !hasSmoothing) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    message: 'Provide limits or smoothing properties to update.',
                    path: ['limits'],
                });
            }
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result, status_26, changeSummary, suffix, error_29;
            var _c, _d;
            var node_path = _b.node_path, transaction_id = _b.transaction_id, limits = _b.limits, smoothing = _b.smoothing;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        payload = { node_path: node_path };
                        if (transaction_id) {
                            payload.transaction_id = transaction_id;
                        }
                        if (hasConfigurationEntries(limits)) {
                            payload.limits = limits;
                        }
                        if (hasConfigurationEntries(smoothing)) {
                            payload.smoothing = smoothing;
                        }
                        return [4 /*yield*/, godot.sendCommand('configure_camera2d_limits', payload)];
                    case 2:
                        result = _e.sent();
                        status_26 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_26 === 'no_change') {
                            return [2 /*return*/, "Camera2D at ".concat(node_path, " already matches the requested configuration.")];
                        }
                        changeSummary = Array.isArray(result.changes)
                            ? result.changes
                                .map(function (change) { return "".concat(change.property, ": ").concat(JSON.stringify(change.value)); })
                                .join(', ')
                            : undefined;
                        suffix = changeSummary && changeSummary.length > 0 ? " (".concat(changeSummary, ")") : '';
                        return [2 /*return*/, "Configured Camera2D limits for ".concat((_d = result.node_path) !== null && _d !== void 0 ? _d : node_path, " [").concat(status_26, "]").concat(suffix)];
                    case 3:
                        error_29 = _e.sent();
                        throw new Error("Failed to configure Camera2D limits: ".concat(error_29.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
            escalationPrompt: 'The assistant is requesting to modify Camera2D boundaries and smoothing. Approve if the scene should adopt these camera constraints.',
        },
    },
    {
        name: 'create_theme_override',
        description: 'Create or update a Control theme override with undo support.',
        parameters: z.object({
            node_path: z
                .string()
                .describe('Path to the Control node that should receive the theme override.'),
            override_type: z
                .enum(['color', 'constant', 'font', 'font_size', 'stylebox', 'icon'])
                .describe('Type of override to apply.'),
            override_name: z
                .string()
                .describe('Theme item name such as "font_color", "panel", or "normal".'),
            value: z
                .any()
                .optional()
                .describe('Override value. Colors accept HTML strings or RGBA dictionaries; resource overrides accept paths.'),
            resource_path: z
                .string()
                .optional()
                .describe('Resource path for font, icon, or stylebox overrides when different from `value`.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing transaction identifier to batch with other edits.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_27, appliedValue, valueDescription, resolvedName, resolvedType, resolvedPath, error_30;
            var _c, _d, _e, _f, _g, _h;
            var node_path = _b.node_path, override_type = _b.override_type, override_name = _b.override_name, value = _b.value, resource_path = _b.resource_path, transaction_id = _b.transaction_id;
            return __generator(this, function (_j) {
                switch (_j.label) {
                    case 0:
                        godot = getGodotConnection();
                        _j.label = 1;
                    case 1:
                        _j.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('create_theme_override', {
                                node_path: node_path,
                                override_type: override_type,
                                override_name: override_name,
                                value: value,
                                resource_path: resource_path,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _j.sent();
                        status_27 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        appliedValue = (_e = (_d = result.value) !== null && _d !== void 0 ? _d : result.applied_value) !== null && _e !== void 0 ? _e : value;
                        valueDescription = appliedValue === undefined ? 'inherit' : JSON.stringify(appliedValue);
                        resolvedName = (_f = result.override_name) !== null && _f !== void 0 ? _f : override_name;
                        resolvedType = (_g = result.override_type) !== null && _g !== void 0 ? _g : override_type;
                        resolvedPath = (_h = result.node_path) !== null && _h !== void 0 ? _h : node_path;
                        return [2 /*return*/, "Theme override ".concat(resolvedName, " (").concat(resolvedType, ") applied to ").concat(resolvedPath, " [").concat(status_27, "] -> ").concat(valueDescription)];
                    case 3:
                        error_30 = _j.sent();
                        throw new Error("Failed to create theme override: ".concat(error_30.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'wire_signal_handler',
        description: 'Connect a signal between nodes and generate method stubs when needed.',
        parameters: z.object({
            source_path: z
                .string()
                .describe('Node emitting the signal (e.g. "/root/Main/StartButton").'),
            signal_name: z
                .string()
                .describe('Name of the signal to connect (e.g. "pressed").'),
            target_path: z
                .string()
                .describe('Node that should receive the callback.'),
            method_name: z
                .string()
                .describe('Method to invoke on the target node when the signal fires.'),
            script_path: z
                .string()
                .optional()
                .describe('Optional script resource to assign before connecting the signal.'),
            create_script: z
                .boolean()
                .optional()
                .describe('Create a new script at `script_path` if none is assigned.'),
            arguments: z
                .array(z.string())
                .optional()
                .describe('Argument names to include in the generated stub.'),
            binds: z
                .array(z.any())
                .optional()
                .describe('Optional values to bind to the signal connection.'),
            deferred: z
                .boolean()
                .optional()
                .describe('Connect the signal in deferred mode.'),
            one_shot: z
                .boolean()
                .optional()
                .describe('Connect the signal in one-shot mode.'),
            reference_counted: z
                .boolean()
                .optional()
                .describe('Use reference-counted connections that disconnect when either side is freed.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing transaction identifier to batch with other edits.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_28, stubInfo, error_31;
            var _c;
            var source_path = _b.source_path, signal_name = _b.signal_name, target_path = _b.target_path, method_name = _b.method_name, script_path = _b.script_path, create_script = _b.create_script, argumentNames = _b.arguments, binds = _b.binds, deferred = _b.deferred, one_shot = _b.one_shot, reference_counted = _b.reference_counted, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('wire_signal_handler', {
                                source_path: source_path,
                                signal_name: signal_name,
                                target_path: target_path,
                                method_name: method_name,
                                script_path: script_path,
                                create_script: create_script,
                                arguments: argumentNames,
                                binds: binds,
                                deferred: deferred,
                                one_shot: one_shot,
                                reference_counted: reference_counted,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_28 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        stubInfo = result.stub_created ? 'stub generated' : 'existing method';
                        return [2 /*return*/, "Connected ".concat(signal_name, " on ").concat(source_path, " -> ").concat(method_name, " [").concat(status_28, "; ").concat(stubInfo, "]")];
                    case 3:
                        error_31 = _d.sent();
                        throw new Error("Failed to wire signal handler: ".concat(error_31.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'layout_ui_grid',
        description: 'Arrange Control children into a grid layout with consistent spacing.',
        parameters: z.object({
            container_path: z
                .string()
                .describe('Path to the container Control whose children should be arranged.'),
            columns: z
                .number()
                .int()
                .min(1)
                .optional()
                .describe('Number of columns to use (default 2).'),
            horizontal_gap: z
                .number()
                .optional()
                .describe('Horizontal spacing between columns in pixels.'),
            vertical_gap: z
                .number()
                .optional()
                .describe('Vertical spacing between rows in pixels.'),
            cell_size: z
                .union([
                z.object({ x: z.number().optional(), y: z.number().optional() }),
                z.tuple([z.number(), z.number()]),
            ])
                .optional()
                .describe('Uniform cell size expressed as `{ x, y }` or `[width, height]`.'),
            size_flags: z
                .object({ horizontal: z.number().optional(), vertical: z.number().optional() })
                .optional()
                .describe('Override size flags for child controls.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing transaction identifier to batch with other edits.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_29, updated, error_32;
            var _c;
            var container_path = _b.container_path, columns = _b.columns, horizontal_gap = _b.horizontal_gap, vertical_gap = _b.vertical_gap, cell_size = _b.cell_size, size_flags = _b.size_flags, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('layout_ui_grid', {
                                container_path: container_path,
                                columns: columns,
                                horizontal_gap: horizontal_gap,
                                vertical_gap: vertical_gap,
                                cell_size: cell_size,
                                size_flags: size_flags,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_29 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        updated = Array.isArray(result.updated_nodes) ? result.updated_nodes.length : 0;
                        return [2 /*return*/, "Applied grid layout to ".concat(container_path, " (").concat(updated, " controls) [").concat(status_29, "]")];
                    case 3:
                        error_32 = _d.sent();
                        throw new Error("Failed to layout UI grid: ".concat(error_32.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'validate_accessibility',
        description: 'Scan Control nodes for accessibility gaps such as missing focus or descriptions.',
        parameters: z.object({
            root_path: z
                .string()
                .optional()
                .describe('Root node to scan (defaults to the edited scene root).'),
            include_hidden: z
                .boolean()
                .optional()
                .describe('Include hidden controls in the scan.'),
            max_depth: z
                .number()
                .int()
                .nonnegative()
                .optional()
                .describe('Limit the traversal depth (0 means unlimited).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, issueCount, scanned, target, error_33;
            var _c, _d, _e, _f;
            var root_path = _b.root_path, include_hidden = _b.include_hidden, max_depth = _b.max_depth;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('validate_accessibility', {
                                root_path: root_path,
                                include_hidden: include_hidden,
                                max_depth: max_depth,
                            })];
                    case 2:
                        result = _g.sent();
                        issueCount = Number((_e = (_c = result.issue_count) !== null && _c !== void 0 ? _c : (_d = result.issues) === null || _d === void 0 ? void 0 : _d.length) !== null && _e !== void 0 ? _e : 0);
                        scanned = Number((_f = result.scanned_count) !== null && _f !== void 0 ? _f : 0);
                        target = root_path !== null && root_path !== void 0 ? root_path : 'scene';
                        return [2 /*return*/, "Accessibility scan for ".concat(target, " inspected ").concat(scanned, " controls and found ").concat(issueCount, " issues.")];
                    case 3:
                        error_33 = _g.sent();
                        throw new Error("Failed to validate accessibility: ".concat(error_33.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_node_groups',
        description: 'List all groups assigned to a specific node',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the node whose groups should be listed'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, groups, error_34;
            var _c;
            var node_path = _b.node_path;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_node_groups', { node_path: node_path })];
                    case 2:
                        result = _d.sent();
                        groups = (_c = result.groups) !== null && _c !== void 0 ? _c : [];
                        if (groups.length === 0) {
                            return [2 /*return*/, "Node at ".concat(node_path, " is not assigned to any groups.")];
                        }
                        return [2 /*return*/, "Groups for node ".concat(node_path, ":\n").concat(groups.join('\n'))];
                    case 3:
                        error_34 = _d.sent();
                        throw new Error("Failed to list node groups: ".concat(error_34.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_nodes_in_group',
        description: 'Enumerate all nodes in the currently edited scene that belong to a specific group',
        parameters: z.object({
            group_name: z.string()
                .min(1)
                .describe('Group name to query'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, nodes, formatted, error_35;
            var _c;
            var group_name = _b.group_name;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_nodes_in_group', { group_name: group_name })];
                    case 2:
                        result = _d.sent();
                        nodes = (_c = result.nodes) !== null && _c !== void 0 ? _c : [];
                        if (nodes.length === 0) {
                            return [2 /*return*/, "No nodes found in group \"".concat(group_name, "\".")];
                        }
                        formatted = nodes
                            .map(function (node) { return "".concat(node.name, " (").concat(node.type, ") - ").concat(node.path); })
                            .join('\n');
                        return [2 /*return*/, "Nodes in group \"".concat(group_name, "\":\n").concat(formatted)];
                    case 3:
                        error_35 = _d.sent();
                        throw new Error("Failed to list nodes in group: ".concat(error_35.message));
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