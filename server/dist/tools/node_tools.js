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
var vector2ParamSchema = z.union([
    z.object({ x: z.number().optional(), y: z.number().optional() }),
    z.tuple([z.number(), z.number()]),
]);
var vector3ParamSchema = z.union([
    z.object({ x: z.number().optional(), y: z.number().optional(), z: z.number().optional() }),
    z.tuple([z.number(), z.number(), z.number()]),
]);
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
        name: 'set_animation_tree_state',
        description: 'Set AnimationTree state machine playback state and optional runtime flags',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the AnimationTree node'),
            state_name: z.string().min(1)
                .describe('AnimationNodeStateMachine state name to travel/start'),
            active: z.boolean().optional(),
            process_callback: z.number().int().optional(),
            use_start: z.boolean().optional()
                .describe('Use AnimationNodeStateMachinePlayback.start instead of travel'),
            reset_on_teleport: z.boolean().optional()
                .describe('Reset animation when using start (default true)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_17, currentState, error_20;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_animation_tree_state', args)];
                    case 2:
                        result = _c.sent();
                        status_17 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_17 === 'no_change') {
                            return [2 /*return*/, "AnimationTree at ".concat(args.node_path, " is already in state ").concat(args.state_name, ".")];
                        }
                        currentState = String((_b = result.current_state) !== null && _b !== void 0 ? _b : args.state_name);
                        return [2 /*return*/, "Set AnimationTree state on ".concat(args.node_path, " to ").concat(currentState, " [").concat(status_17, "]")];
                    case 3:
                        error_20 = _c.sent();
                        throw new Error("Failed to set AnimationTree state: ".concat(error_20.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_animation_tree_parameters',
        description: 'Set AnimationTree parameter values (for blend trees, transitions, and one-shots)',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the AnimationTree node'),
            parameters: z.record(z.unknown()).refine(function (value) { return Object.keys(value).length > 0; }, {
                message: 'parameters must contain at least one key',
            })
                .describe('AnimationTree parameter path/value map (e.g. "parameters/run_blend/blend_amount": 0.8)'),
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
                        return [4 /*yield*/, godot.sendCommand('set_animation_tree_parameters', args)];
                    case 2:
                        result = _b.sent();
                        status_18 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_18 === 'no_change') {
                            return [2 /*return*/, "AnimationTree parameters at ".concat(args.node_path, " already match requested values.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Set ".concat(changed, " AnimationTree parameter(s) on ").concat(args.node_path, " [").concat(status_18, "]")];
                    case 3:
                        error_21 = _b.sent();
                        throw new Error("Failed to set AnimationTree parameters: ".concat(error_21.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_wave_spawner_2d',
        description: 'Build a 2D wave spawner scaffold with optional spawn markers and timer metadata',
        parameters: z.object({
            parent_path: z.string().optional(),
            spawner_name: z.string().optional(),
            spawn_points: z.array(vector2ParamSchema).optional(),
            create_timer: z.boolean().optional(),
            timer_name: z.string().optional(),
            create_spawn_nodes: z.boolean().optional(),
            spawn_nodes_parent_name: z.string().optional(),
            wave_interval: z.number().nonnegative().optional(),
            enemies_per_wave: z.number().int().positive().optional(),
            max_waves: z.number().int().positive().optional(),
            current_wave: z.number().int().nonnegative().optional(),
            auto_start: z.boolean().optional(),
            enemy_scene_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_19, spawnerPath, spawnPointCount, error_22;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_wave_spawner_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_19 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        spawnerPath = String((_b = result.spawner_path) !== null && _b !== void 0 ? _b : 'unknown');
                        spawnPointCount = Number((_c = result.spawn_point_count) !== null && _c !== void 0 ? _c : (Array.isArray(result.spawn_points) ? result.spawn_points.length : 0));
                        return [2 /*return*/, "Built 2D wave spawner at ".concat(spawnerPath, " (").concat(spawnPointCount, " spawn points) [").concat(status_19, "]")];
                    case 3:
                        error_22 = _d.sent();
                        throw new Error("Failed to build wave spawner 2D: ".concat(error_22.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_wave_spawner_3d',
        description: 'Build a 3D wave spawner scaffold with optional spawn markers and timer metadata',
        parameters: z.object({
            parent_path: z.string().optional(),
            spawner_name: z.string().optional(),
            spawn_points: z.array(vector3ParamSchema).optional(),
            create_timer: z.boolean().optional(),
            timer_name: z.string().optional(),
            create_spawn_nodes: z.boolean().optional(),
            spawn_nodes_parent_name: z.string().optional(),
            wave_interval: z.number().nonnegative().optional(),
            enemies_per_wave: z.number().int().positive().optional(),
            max_waves: z.number().int().positive().optional(),
            current_wave: z.number().int().nonnegative().optional(),
            auto_start: z.boolean().optional(),
            enemy_scene_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_20, spawnerPath, spawnPointCount, error_23;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_wave_spawner_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_20 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        spawnerPath = String((_b = result.spawner_path) !== null && _b !== void 0 ? _b : 'unknown');
                        spawnPointCount = Number((_c = result.spawn_point_count) !== null && _c !== void 0 ? _c : (Array.isArray(result.spawn_points) ? result.spawn_points.length : 0));
                        return [2 /*return*/, "Built 3D wave spawner at ".concat(spawnerPath, " (").concat(spawnPointCount, " spawn points) [").concat(status_20, "]")];
                    case 3:
                        error_23 = _d.sent();
                        throw new Error("Failed to build wave spawner 3D: ".concat(error_23.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_wave_spawner_step_2d',
        description: 'Run one 2D wave spawner step and optionally instantiate enemy scenes',
        parameters: z.object({
            spawner_path: z.string()
                .describe('Path to the 2D spawner node'),
            spawn_count: z.number().int().positive().optional(),
            advance_wave: z.boolean().optional(),
            instantiate_enemy: z.boolean().optional(),
            enemy_scene_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_21, spawnCount, nextWave, error_24;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_wave_spawner_step_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_21 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        spawnCount = Number((_b = result.spawn_count) !== null && _b !== void 0 ? _b : 0);
                        nextWave = Number((_c = result.next_wave) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Simulated 2D wave step at ".concat(args.spawner_path, " -> spawned ").concat(spawnCount, ", next_wave=").concat(nextWave, " [").concat(status_21, "]")];
                    case 3:
                        error_24 = _d.sent();
                        throw new Error("Failed to simulate wave spawner step 2D: ".concat(error_24.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_wave_spawner_step_3d',
        description: 'Run one 3D wave spawner step and optionally instantiate enemy scenes',
        parameters: z.object({
            spawner_path: z.string()
                .describe('Path to the 3D spawner node'),
            spawn_count: z.number().int().positive().optional(),
            advance_wave: z.boolean().optional(),
            instantiate_enemy: z.boolean().optional(),
            enemy_scene_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_22, spawnCount, nextWave, error_25;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_wave_spawner_step_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_22 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        spawnCount = Number((_b = result.spawn_count) !== null && _b !== void 0 ? _b : 0);
                        nextWave = Number((_c = result.next_wave) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Simulated 3D wave step at ".concat(args.spawner_path, " -> spawned ").concat(spawnCount, ", next_wave=").concat(nextWave, " [").concat(status_22, "]")];
                    case 3:
                        error_25 = _d.sent();
                        throw new Error("Failed to simulate wave spawner step 3D: ".concat(error_25.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_camera2d_shake',
        description: 'Apply deterministic or randomized Camera2D shake offsets for gamefeel testing',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Camera2D node'),
            trauma: z.number().min(0).max(1).optional(),
            amplitude: z.number().nonnegative().optional(),
            rotation_amplitude_degrees: z.number().nonnegative().optional(),
            add_to_existing: z.boolean().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_23, offset, rotation, error_26;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_camera2d_shake', args)];
                    case 2:
                        result = _c.sent();
                        status_23 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        offset = result.offset ? JSON.stringify(result.offset) : 'unknown';
                        rotation = Number((_b = result.rotation_radians) !== null && _b !== void 0 ? _b : 0);
                        return [2 /*return*/, "Simulated Camera2D shake on ".concat(args.node_path, " [").concat(status_23, "] -> offset=").concat(offset, ", rotation=").concat(rotation.toFixed(4))];
                    case 3:
                        error_26 = _c.sent();
                        throw new Error("Failed to simulate Camera2D shake: ".concat(error_26.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_camera3d_shake',
        description: 'Apply deterministic or randomized Camera3D shake offsets, roll, and optional FOV pulse',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Camera3D node'),
            trauma: z.number().min(0).max(1).optional(),
            horizontal_amplitude: z.number().nonnegative().optional(),
            vertical_amplitude: z.number().nonnegative().optional(),
            roll_amplitude_degrees: z.number().nonnegative().optional(),
            fov_pulse: z.number().nonnegative().optional(),
            add_to_existing: z.boolean().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_24, rotation, hOffset, vOffset, fov, error_27;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_camera3d_shake', args)];
                    case 2:
                        result = _e.sent();
                        status_24 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        rotation = result.rotation ? JSON.stringify(result.rotation) : 'unknown';
                        hOffset = Number((_b = result.h_offset) !== null && _b !== void 0 ? _b : 0);
                        vOffset = Number((_c = result.v_offset) !== null && _c !== void 0 ? _c : 0);
                        fov = Number((_d = result.fov) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Simulated Camera3D shake on ".concat(args.node_path, " [").concat(status_24, "] -> h_offset=").concat(hOffset.toFixed(4), ", v_offset=").concat(vOffset.toFixed(4), ", fov=").concat(fov.toFixed(3), ", rotation=").concat(rotation)];
                    case 3:
                        error_27 = _e.sent();
                        throw new Error("Failed to simulate Camera3D shake: ".concat(error_27.message));
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
            var godot, result, status_25, changed, error_28;
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
                        status_25 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_25 === 'no_change') {
                            return [2 /*return*/, "Parallax2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Parallax2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_25, "]")];
                    case 3:
                        error_28 = _b.sent();
                        throw new Error("Failed to configure Parallax2D: ".concat(error_28.message));
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
            var godot, result, status_26, changed, error_29;
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
                        status_26 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_26 === 'no_change') {
                            return [2 /*return*/, "AnimatedSprite2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured AnimatedSprite2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_26, "]")];
                    case 3:
                        error_29 = _b.sent();
                        throw new Error("Failed to configure AnimatedSprite2D: ".concat(error_29.message));
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
            var godot, result, status_27, changed, error_30;
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
                        status_27 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_27 === 'no_change') {
                            return [2 /*return*/, "Sprite2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Sprite2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_27, "]")];
                    case 3:
                        error_30 = _b.sent();
                        throw new Error("Failed to configure Sprite2D: ".concat(error_30.message));
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
            var godot, result, status_28, changed, error_31;
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
                        status_28 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_28 === 'no_change') {
                            return [2 /*return*/, "CharacterBody2D at ".concat(args.node_path, " already matches requested controller settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured CharacterBody2D controller at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_28, "]")];
                    case 3:
                        error_31 = _b.sent();
                        throw new Error("Failed to configure CharacterBody2D controller: ".concat(error_31.message));
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
            var godot, result, status_29, changed, error_32;
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
                        status_29 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_29 === 'no_change') {
                            return [2 /*return*/, "Area2D at ".concat(args.node_path, " already matches requested sensor settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Area2D sensor at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_29, "]")];
                    case 3:
                        error_32 = _b.sent();
                        throw new Error("Failed to configure Area2D sensor: ".concat(error_32.message));
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
            var godot, result, status_30, changed, error_33;
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
                        status_30 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        changed = Number((_b = result.change_count) !== null && _b !== void 0 ? _b : 0);
                        if (status_30 === 'no_change') {
                            return [2 /*return*/, "TileMap fill on ".concat(args.node_path, " produced no effective changes.")];
                        }
                        return [2 /*return*/, "".concat(args.clear ? 'Cleared' : 'Filled', " ").concat(changed, " TileMap cell(s) on ").concat(args.node_path, " [").concat(status_30, "]")];
                    case 3:
                        error_33 = _c.sent();
                        throw new Error("Failed to fill TileMap rect: ".concat(error_33.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_tilemap_noise_2d',
        description: 'Procedurally fill a TileMap region from FastNoiseLite sampling for terrain and cave layouts',
        parameters: z
            .object({
            node_path: z.string()
                .describe('Path to a TileMapLayer or TileMap node'),
            layer: z.number().int().min(0).optional()
                .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
            origin: vector2ParamSchema.optional()
                .describe('Region origin in cell coordinates'),
            size: vector2ParamSchema.optional()
                .describe('Region size in cells'),
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
                .describe('Alternative region descriptor'),
            source_id: z.number().int()
                .describe('Tile source id to paint when the noise test selects a cell'),
            atlas_coords: vector2ParamSchema.optional(),
            alternative_tile: z.number().int().optional(),
            threshold: z.number().min(-1).max(1).optional()
                .describe('Noise threshold in [-1, 1]'),
            invert: z.boolean().optional()
                .describe('Invert the threshold selection'),
            clear_unselected: z.boolean().optional()
                .describe('Clear cells that do not satisfy the threshold'),
            sample_offset: vector2ParamSchema.optional()
                .describe('Offset added to noise sample coordinates'),
            noise_seed: z.number().int().optional(),
            frequency: z.number().positive().optional(),
            fractal_octaves: z.number().int().min(1).optional(),
            fractal_lacunarity: z.number().nonnegative().optional(),
            fractal_gain: z.number().nonnegative().optional(),
            noise_type: z.number().int().optional(),
            fractal_type: z.number().int().optional(),
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
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_31, changed, painted, cleared, error_34;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_tilemap_noise_2d', args)];
                    case 2:
                        result = _e.sent();
                        status_31 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_31 === 'no_change') {
                            return [2 /*return*/, "TileMap noise generation on ".concat(args.node_path, " produced no effective changes.")];
                        }
                        changed = Number((_b = result.change_count) !== null && _b !== void 0 ? _b : 0);
                        painted = Number((_c = result.painted_count) !== null && _c !== void 0 ? _c : 0);
                        cleared = Number((_d = result.cleared_count) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Generated TileMap noise on ".concat(args.node_path, ": ").concat(changed, " changes (").concat(painted, " painted, ").concat(cleared, " cleared) [").concat(status_31, "]")];
                    case 3:
                        error_34 = _e.sent();
                        throw new Error("Failed to generate TileMap noise: ".concat(error_34.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'tilemap_terrain_autopaint_2d',
        description: 'Auto-connect/path paint TileMap terrain cells from explicit coordinates or procedural noise selections',
        parameters: z
            .object({
            node_path: z.string()
                .describe('Path to a TileMapLayer or TileMap node'),
            layer: z.number().int().min(0).optional()
                .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
            terrain_set: z.number().int().min(0)
                .describe('Terrain set index in the TileSet'),
            terrain: z.number().int().min(0)
                .describe('Terrain id to paint/connect'),
            mode: z.enum(['connect', 'path']).optional()
                .describe('Autotile method: connect (blob-like) or path (ordered)'),
            cells: z.array(vector2ParamSchema).optional()
                .describe('Optional explicit terrain target cells'),
            origin: vector2ParamSchema.optional()
                .describe('Selection origin when using procedural selection'),
            size: vector2ParamSchema.optional()
                .describe('Selection size when using procedural selection'),
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
                .describe('Alternative selection rectangle descriptor'),
            use_noise: z.boolean().optional()
                .describe('Use noise threshold sampling when explicit cells are not provided (default true)'),
            fill_probability: z.number().min(0).max(1).optional(),
            threshold: z.number().min(-1).max(1).optional(),
            invert: z.boolean().optional(),
            sample_offset: vector2ParamSchema.optional(),
            seed: z.number().int().optional(),
            noise_seed: z.number().int().optional(),
            frequency: z.number().positive().optional(),
            fractal_octaves: z.number().int().min(1).optional(),
            fractal_lacunarity: z.number().nonnegative().optional(),
            fractal_gain: z.number().nonnegative().optional(),
            noise_type: z.number().int().optional(),
            fractal_type: z.number().int().optional(),
            ignore_empty_terrains: z.boolean().optional(),
            clear_unselected: z.boolean().optional(),
            neighbor_margin: z.number().int().min(0).optional(),
            preview_only: z.boolean().optional(),
            transaction_id: z.string().optional(),
        })
            .superRefine(function (value, ctx) {
            if (!value.cells && !value.rect && (!value.origin || !value.size)) {
                ctx.addIssue({
                    code: z.ZodIssueCode.custom,
                    message: 'Provide cells, or provide rect, or provide both origin and size.',
                    path: ['cells'],
                });
            }
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_32, selected, changed, error_35;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('tilemap_terrain_autopaint_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_32 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        selected = Number((_b = result.selected_count) !== null && _b !== void 0 ? _b : 0);
                        if (status_32 === 'preview') {
                            return [2 /*return*/, "Previewed terrain autopaint on ".concat(args.node_path, " with ").concat(selected, " selected cell(s).")];
                        }
                        if (status_32 === 'no_change') {
                            return [2 /*return*/, "Terrain autopaint on ".concat(args.node_path, " produced no effective changes.")];
                        }
                        changed = Number((_c = result.changed_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Auto-painted terrain on ".concat(args.node_path, ": selected=").concat(selected, ", changed=").concat(changed, " [").concat(status_32, "]")];
                    case 3:
                        error_35 = _d.sent();
                        throw new Error("Failed to autopaint TileMap terrain: ".concat(error_35.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_heightmap_gridmap_3d',
        description: 'Procedurally generate GridMap cell heights from FastNoiseLite for blockout terrain',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the GridMap node'),
            origin: vector3ParamSchema.optional()
                .describe('Origin of the generated area'),
            size: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])])
                .describe('Generation footprint on XZ axes'),
            item_id: z.number().int().min(0)
                .describe('MeshLibrary item id to place'),
            orientation: z.number().int().optional(),
            min_height: z.number().int().optional(),
            max_height: z.number().int().optional(),
            surface_only: z.boolean().optional()
                .describe('Place only the top surface cell for each column'),
            clear_unselected: z.boolean().optional()
                .describe('Clear cells that are outside the generated column profile'),
            sample_offset: vector2ParamSchema.optional(),
            noise_seed: z.number().int().optional(),
            frequency: z.number().positive().optional(),
            fractal_octaves: z.number().int().min(1).optional(),
            fractal_lacunarity: z.number().nonnegative().optional(),
            fractal_gain: z.number().nonnegative().optional(),
            noise_type: z.number().int().optional(),
            fractal_type: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_33, changed, placed, cleared, error_36;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_heightmap_gridmap_3d', args)];
                    case 2:
                        result = _e.sent();
                        status_33 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_33 === 'no_change') {
                            return [2 /*return*/, "GridMap heightmap generation on ".concat(args.node_path, " produced no effective changes.")];
                        }
                        changed = Number((_b = result.change_count) !== null && _b !== void 0 ? _b : 0);
                        placed = Number((_c = result.placed_count) !== null && _c !== void 0 ? _c : 0);
                        cleared = Number((_d = result.cleared_count) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Generated GridMap heightmap on ".concat(args.node_path, ": ").concat(changed, " changes (").concat(placed, " placed, ").concat(cleared, " cleared) [").concat(status_33, "]")];
                    case 3:
                        error_36 = _e.sent();
                        throw new Error("Failed to generate GridMap heightmap: ".concat(error_36.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'scatter_scene_instances_2d',
        description: 'Procedurally scatter PackedScene Node2D instances across a 2D region',
        parameters: z.object({
            parent_path: z.string().optional(),
            scene_path: z.string()
                .describe('PackedScene path (res://...) to instantiate'),
            count: z.number().int().positive().optional(),
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
            ]),
            min_distance: z.number().nonnegative().optional(),
            max_attempts: z.number().int().positive().optional(),
            require_full_count: z.boolean().optional(),
            name_prefix: z.string().optional(),
            random_rotation: z.boolean().optional(),
            rotation_range_degrees: vector2ParamSchema.optional(),
            random_scale: z.boolean().optional(),
            scale_range: vector2ParamSchema.optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_34, created, requested, error_37;
            var _a, _b, _c, _d, _e;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        godot = getGodotConnection();
                        _f.label = 1;
                    case 1:
                        _f.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('scatter_scene_instances_2d', args)];
                    case 2:
                        result = _f.sent();
                        status_34 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        created = Number((_b = result.created_count) !== null && _b !== void 0 ? _b : 0);
                        requested = Number((_c = result.requested_count) !== null && _c !== void 0 ? _c : created);
                        return [2 /*return*/, "Scattered ".concat(created, "/").concat(requested, " 2D instances under ").concat((_e = (_d = result.parent_path) !== null && _d !== void 0 ? _d : args.parent_path) !== null && _e !== void 0 ? _e : '/root', " [").concat(status_34, "]")];
                    case 3:
                        error_37 = _f.sent();
                        throw new Error("Failed to scatter 2D scene instances: ".concat(error_37.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'scatter_scene_instances_3d',
        description: 'Procedurally scatter PackedScene Node3D instances across a 3D volume',
        parameters: z.object({
            parent_path: z.string().optional(),
            scene_path: z.string()
                .describe('PackedScene path (res://...) to instantiate'),
            count: z.number().int().positive().optional(),
            origin: vector3ParamSchema.optional(),
            size: vector3ParamSchema,
            min_distance: z.number().nonnegative().optional(),
            max_attempts: z.number().int().positive().optional(),
            require_full_count: z.boolean().optional(),
            name_prefix: z.string().optional(),
            random_yaw: z.boolean().optional(),
            yaw_range_degrees: vector2ParamSchema.optional(),
            random_scale: z.boolean().optional(),
            scale_range: vector2ParamSchema.optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_35, created, requested, error_38;
            var _a, _b, _c, _d, _e;
            return __generator(this, function (_f) {
                switch (_f.label) {
                    case 0:
                        godot = getGodotConnection();
                        _f.label = 1;
                    case 1:
                        _f.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('scatter_scene_instances_3d', args)];
                    case 2:
                        result = _f.sent();
                        status_35 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        created = Number((_b = result.created_count) !== null && _b !== void 0 ? _b : 0);
                        requested = Number((_c = result.requested_count) !== null && _c !== void 0 ? _c : created);
                        return [2 /*return*/, "Scattered ".concat(created, "/").concat(requested, " 3D instances under ").concat((_e = (_d = result.parent_path) !== null && _d !== void 0 ? _d : args.parent_path) !== null && _e !== void 0 ? _e : '/root', " [").concat(status_35, "]")];
                    case 3:
                        error_38 = _f.sent();
                        throw new Error("Failed to scatter 3D scene instances: ".concat(error_38.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_characterbody3d_controller',
        description: 'Configure CharacterBody3D movement/controller properties for 3D action and platform gameplay',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the CharacterBody3D node'),
            up_direction: vector3ParamSchema.optional(),
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
            velocity: vector3ParamSchema.optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_36, changed, error_39;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_characterbody3d_controller', args)];
                    case 2:
                        result = _b.sent();
                        status_36 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_36 === 'no_change') {
                            return [2 /*return*/, "CharacterBody3D at ".concat(args.node_path, " already matches requested controller settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured CharacterBody3D controller at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_36, "]")];
                    case 3:
                        error_39 = _b.sent();
                        throw new Error("Failed to configure CharacterBody3D controller: ".concat(error_39.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_camera3d_rig',
        description: 'Configure Camera3D transform and projection settings for 3D gameplay cameras',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the Camera3D node'),
            position: vector3ParamSchema.optional(),
            rotation_degrees: vector3ParamSchema.optional(),
            global_position: vector3ParamSchema.optional(),
            global_rotation_degrees: vector3ParamSchema.optional(),
            current: z.boolean().optional(),
            projection: z.number().int().optional(),
            fov: z.number().optional(),
            size: z.number().optional(),
            near: z.number().positive().optional(),
            far: z.number().positive().optional(),
            keep_aspect: z.number().int().optional(),
            h_offset: z.number().optional(),
            v_offset: z.number().optional(),
            cull_mask: z.number().int().optional(),
            doppler_tracking: z.number().int().optional(),
            environment_path: z.string().optional()
                .describe('Environment resource path (res://...) or empty string to clear'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_37, changed, error_40;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_camera3d_rig', args)];
                    case 2:
                        result = _b.sent();
                        status_37 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_37 === 'no_change') {
                            return [2 /*return*/, "Camera3D at ".concat(args.node_path, " already matches requested rig settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured Camera3D rig at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_37, "]")];
                    case 3:
                        error_40 = _b.sent();
                        throw new Error("Failed to configure Camera3D rig: ".concat(error_40.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_springarm3d',
        description: 'Configure SpringArm3D collision sweep and camera boom settings',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the SpringArm3D node'),
            spring_length: z.number().nonnegative().optional(),
            margin: z.number().nonnegative().optional(),
            collision_mask: z.number().int().optional(),
            shape_path: z.string().optional()
                .describe('Shape3D resource path (res://...) or empty string to clear'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_38, changed, error_41;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_springarm3d', args)];
                    case 2:
                        result = _b.sent();
                        status_38 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_38 === 'no_change') {
                            return [2 /*return*/, "SpringArm3D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured SpringArm3D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_38, "]")];
                    case 3:
                        error_41 = _b.sent();
                        throw new Error("Failed to configure SpringArm3D: ".concat(error_41.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_navigation_agent_2d',
        description: 'Configure NavigationAgent2D pathfinding and avoidance behavior for top-down and side-view AI',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the NavigationAgent2D node'),
            target_position: vector2ParamSchema.optional(),
            navigation_layers: z.number().int().optional(),
            pathfinding_algorithm: z.number().int().optional(),
            path_postprocessing: z.number().int().optional(),
            path_metadata_flags: z.number().int().optional(),
            path_desired_distance: z.number().nonnegative().optional(),
            target_desired_distance: z.number().nonnegative().optional(),
            path_max_distance: z.number().nonnegative().optional(),
            radius: z.number().nonnegative().optional(),
            max_speed: z.number().nonnegative().optional(),
            avoidance_enabled: z.boolean().optional(),
            neighbor_distance: z.number().nonnegative().optional(),
            max_neighbors: z.number().int().nonnegative().optional(),
            time_horizon: z.number().nonnegative().optional(),
            time_horizon_agents: z.number().nonnegative().optional(),
            time_horizon_obstacles: z.number().nonnegative().optional(),
            avoidance_layers: z.number().int().optional(),
            avoidance_mask: z.number().int().optional(),
            avoidance_priority: z.number().nonnegative().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_39, changed, error_42;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_navigation_agent_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_39 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_39 === 'no_change') {
                            return [2 /*return*/, "NavigationAgent2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured NavigationAgent2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_39, "]")];
                    case 3:
                        error_42 = _b.sent();
                        throw new Error("Failed to configure NavigationAgent2D: ".concat(error_42.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_navigation_agent_3d',
        description: 'Configure NavigationAgent3D pathfinding and avoidance behavior for 3D AI characters',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the NavigationAgent3D node'),
            target_position: vector3ParamSchema.optional(),
            navigation_layers: z.number().int().optional(),
            pathfinding_algorithm: z.number().int().optional(),
            path_postprocessing: z.number().int().optional(),
            path_metadata_flags: z.number().int().optional(),
            path_desired_distance: z.number().nonnegative().optional(),
            target_desired_distance: z.number().nonnegative().optional(),
            path_max_distance: z.number().nonnegative().optional(),
            radius: z.number().nonnegative().optional(),
            height: z.number().nonnegative().optional(),
            max_speed: z.number().nonnegative().optional(),
            avoidance_enabled: z.boolean().optional(),
            neighbor_distance: z.number().nonnegative().optional(),
            max_neighbors: z.number().int().nonnegative().optional(),
            time_horizon: z.number().nonnegative().optional(),
            time_horizon_agents: z.number().nonnegative().optional(),
            time_horizon_obstacles: z.number().nonnegative().optional(),
            avoidance_layers: z.number().int().optional(),
            avoidance_mask: z.number().int().optional(),
            avoidance_priority: z.number().nonnegative().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_40, changed, error_43;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_navigation_agent_3d', args)];
                    case 2:
                        result = _b.sent();
                        status_40 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_40 === 'no_change') {
                            return [2 /*return*/, "NavigationAgent3D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured NavigationAgent3D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_40, "]")];
                    case 3:
                        error_43 = _b.sent();
                        throw new Error("Failed to configure NavigationAgent3D: ".concat(error_43.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_navigation_obstacle_2d',
        description: 'Configure NavigationObstacle2D avoidance behavior and optional polygon vertices for dynamic top-down blockers',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the NavigationObstacle2D node'),
            avoidance_enabled: z.boolean().optional(),
            avoidance_layers: z.number().int().optional(),
            radius: z.number().nonnegative().optional(),
            velocity: vector2ParamSchema.optional(),
            use_3d_avoidance: z.boolean().optional(),
            vertices: z.array(vector2ParamSchema).optional()
                .describe('Optional polygon vertices for obstacle avoidance geometry'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_41, changed, error_44;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_navigation_obstacle_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_41 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_41 === 'no_change') {
                            return [2 /*return*/, "NavigationObstacle2D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured NavigationObstacle2D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_41, "]")];
                    case 3:
                        error_44 = _b.sent();
                        throw new Error("Failed to configure NavigationObstacle2D: ".concat(error_44.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_navigation_obstacle_3d',
        description: 'Configure NavigationObstacle3D avoidance behavior and optional polygon vertices for dynamic 3D blockers',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the NavigationObstacle3D node'),
            avoidance_enabled: z.boolean().optional(),
            avoidance_layers: z.number().int().optional(),
            radius: z.number().nonnegative().optional(),
            height: z.number().nonnegative().optional(),
            velocity: vector3ParamSchema.optional(),
            vertices: z.array(vector3ParamSchema).optional()
                .describe('Optional polygon vertices for obstacle avoidance geometry'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_42, changed, error_45;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_navigation_obstacle_3d', args)];
                    case 2:
                        result = _b.sent();
                        status_42 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_42 === 'no_change') {
                            return [2 /*return*/, "NavigationObstacle3D at ".concat(args.node_path, " already matches requested settings.")];
                        }
                        changed = Array.isArray(result.changes) ? result.changes.length : 0;
                        return [2 /*return*/, "Configured NavigationObstacle3D at ".concat(args.node_path, " (").concat(changed, " changes) [").concat(status_42, "]")];
                    case 3:
                        error_45 = _b.sent();
                        throw new Error("Failed to configure NavigationObstacle3D: ".concat(error_45.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'advance_pathfollow2d',
        description: 'Advance PathFollow2D progress for moving platforms, patrol rails, and scripted route motion',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the PathFollow2D node'),
            speed: z.number().optional()
                .describe('Units per second used with delta to compute progress_delta'),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            reverse: z.boolean().optional(),
            progress: z.number().optional()
                .describe('Explicit absolute progress value override'),
            progress_delta: z.number().optional()
                .describe('Explicit progress step override (applied after reverse)'),
            progress_ratio: z.number().optional(),
            progress_ratio_delta: z.number().optional(),
            loop: z.boolean().optional(),
            cubic_interp: z.boolean().optional(),
            rotates: z.boolean().optional(),
            h_offset: z.number().optional(),
            v_offset: z.number().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_43, progress, error_46;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('advance_pathfollow2d', args)];
                    case 2:
                        result = _c.sent();
                        status_43 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        progress = Number((_b = result.progress) !== null && _b !== void 0 ? _b : 0);
                        return [2 /*return*/, "Advanced PathFollow2D ".concat(args.node_path, " to progress=").concat(progress.toFixed(3), " [").concat(status_43, "]")];
                    case 3:
                        error_46 = _c.sent();
                        throw new Error("Failed to advance PathFollow2D: ".concat(error_46.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'advance_pathfollow3d',
        description: 'Advance PathFollow3D progress for moving platforms, splines, and scripted patrol routes',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the PathFollow3D node'),
            speed: z.number().optional()
                .describe('Units per second used with delta to compute progress_delta'),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            reverse: z.boolean().optional(),
            progress: z.number().optional()
                .describe('Explicit absolute progress value override'),
            progress_delta: z.number().optional()
                .describe('Explicit progress step override (applied after reverse)'),
            progress_ratio: z.number().optional(),
            progress_ratio_delta: z.number().optional(),
            loop: z.boolean().optional(),
            cubic_interp: z.boolean().optional(),
            rotation_mode: z.number().int().optional(),
            tilt_enabled: z.boolean().optional(),
            use_model_front: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_44, progress, error_47;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('advance_pathfollow3d', args)];
                    case 2:
                        result = _c.sent();
                        status_44 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        progress = Number((_b = result.progress) !== null && _b !== void 0 ? _b : 0);
                        return [2 /*return*/, "Advanced PathFollow3D ".concat(args.node_path, " to progress=").concat(progress.toFixed(3), " [").concat(status_44, "]")];
                    case 3:
                        error_47 = _c.sent();
                        throw new Error("Failed to advance PathFollow3D: ".concat(error_47.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_path2d_followers',
        description: 'Create and batch-configure PathFollow2D children under a Path2D for moving platforms, enemies, and rails',
        parameters: z.object({
            path_path: z.string()
                .describe('Path to the Path2D node'),
            follower_count: z.number().int().min(0).optional(),
            create_missing: z.boolean().optional(),
            base_name: z.string().optional(),
            use_progress_ratio: z.boolean().optional(),
            spacing: z.number().optional(),
            start_progress: z.number().optional(),
            loop: z.boolean().optional(),
            cubic_interp: z.boolean().optional(),
            rotates: z.boolean().optional(),
            h_offset: z.number().optional(),
            v_offset: z.number().optional(),
            speed: z.number().optional(),
            followers: z.array(z.object({
                node_path: z.string().optional(),
                index: z.number().int().min(0).optional(),
                name: z.string().optional(),
                progress: z.number().optional(),
                progress_ratio: z.number().optional(),
                loop: z.boolean().optional(),
                cubic_interp: z.boolean().optional(),
                rotates: z.boolean().optional(),
                h_offset: z.number().optional(),
                v_offset: z.number().optional(),
                speed: z.number().optional(),
            })).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_45, total, created, updated, error_48;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_path2d_followers', args)];
                    case 2:
                        result = _e.sent();
                        status_45 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        total = Number((_b = result.follower_count) !== null && _b !== void 0 ? _b : 0);
                        created = Number((_c = result.created_count) !== null && _c !== void 0 ? _c : 0);
                        updated = Number((_d = result.updated_count) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Configured Path2D followers on ".concat(args.path_path, ": total=").concat(total, ", created=").concat(created, ", updated=").concat(updated, " [").concat(status_45, "]")];
                    case 3:
                        error_48 = _e.sent();
                        throw new Error("Failed to configure Path2D followers: ".concat(error_48.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_path3d_followers',
        description: 'Create and batch-configure PathFollow3D children under a Path3D for 3D movers, patrols, and rails',
        parameters: z.object({
            path_path: z.string()
                .describe('Path to the Path3D node'),
            follower_count: z.number().int().min(0).optional(),
            create_missing: z.boolean().optional(),
            base_name: z.string().optional(),
            use_progress_ratio: z.boolean().optional(),
            spacing: z.number().optional(),
            start_progress: z.number().optional(),
            loop: z.boolean().optional(),
            cubic_interp: z.boolean().optional(),
            rotation_mode: z.number().int().optional(),
            tilt_enabled: z.boolean().optional(),
            use_model_front: z.boolean().optional(),
            speed: z.number().optional(),
            followers: z.array(z.object({
                node_path: z.string().optional(),
                index: z.number().int().min(0).optional(),
                name: z.string().optional(),
                progress: z.number().optional(),
                progress_ratio: z.number().optional(),
                loop: z.boolean().optional(),
                cubic_interp: z.boolean().optional(),
                rotation_mode: z.number().int().optional(),
                tilt_enabled: z.boolean().optional(),
                use_model_front: z.boolean().optional(),
                speed: z.number().optional(),
            })).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_46, total, created, updated, error_49;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_path3d_followers', args)];
                    case 2:
                        result = _e.sent();
                        status_46 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        total = Number((_b = result.follower_count) !== null && _b !== void 0 ? _b : 0);
                        created = Number((_c = result.created_count) !== null && _c !== void 0 ? _c : 0);
                        updated = Number((_d = result.updated_count) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Configured Path3D followers on ".concat(args.path_path, ": total=").concat(total, ", created=").concat(created, ", updated=").concat(updated, " [").concat(status_46, "]")];
                    case 3:
                        error_49 = _e.sent();
                        throw new Error("Failed to configure Path3D followers: ".concat(error_49.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_topdown_movement_2d',
        description: 'Configure CharacterBody2D for top-down movement defaults and shared controller tuning metadata',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the CharacterBody2D node'),
            apply_defaults: z.boolean().optional()
                .describe('Apply top-down friendly defaults before explicit overrides (default true)'),
            motion_mode: z.number().int().optional(),
            up_direction: vector2ParamSchema.optional(),
            floor_stop_on_slope: z.boolean().optional(),
            floor_constant_speed: z.boolean().optional(),
            floor_block_on_wall: z.boolean().optional(),
            floor_snap_length: z.number().optional(),
            max_slides: z.number().int().min(1).optional(),
            safe_margin: z.number().nonnegative().optional(),
            slide_on_ceiling: z.boolean().optional(),
            platform_on_leave: z.number().int().optional(),
            platform_floor_layers: z.number().int().optional(),
            platform_wall_layers: z.number().int().optional(),
            velocity: vector2ParamSchema.optional(),
            speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            deceleration: z.number().nonnegative().optional(),
            input_actions: z.object({
                up: z.string().min(1).optional(),
                down: z.string().min(1).optional(),
                left: z.string().min(1).optional(),
                right: z.string().min(1).optional(),
            }).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_47, propertyChanges, metaChanges, error_50;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_topdown_movement_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_47 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        if (status_47 === 'no_change') {
                            return [2 /*return*/, "Top-down settings at ".concat(args.node_path, " already match requested values.")];
                        }
                        propertyChanges = Array.isArray(result.changes) ? result.changes.length : 0;
                        metaChanges = Array.isArray(result.meta_changes) ? result.meta_changes.length : 0;
                        return [2 /*return*/, "Configured top-down movement on ".concat(args.node_path, " (").concat(propertyChanges, " property, ").concat(metaChanges, " tuning changes) [").concat(status_47, "]")];
                    case 3:
                        error_50 = _b.sent();
                        throw new Error("Failed to configure top-down movement: ".concat(error_50.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_characterbody2d_movement',
        description: 'Apply one movement simulation step to a CharacterBody2D for rapid controller iteration and testing',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the CharacterBody2D node'),
            direction: vector2ParamSchema.optional()
                .describe('Desired movement direction for this simulation step'),
            speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            deceleration: z.number().nonnegative().optional(),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            set_rotation: z.boolean().optional()
                .describe('Rotate the body to match movement direction'),
            sprite_path: z.string().optional()
                .describe('Optional Sprite2D/AnimatedSprite2D path to orient visually'),
            flip_sprite_h: z.boolean().optional()
                .describe('Flip the sprite horizontally based on movement direction'),
            animation_map: z.object({
                move: z.string().min(1).optional(),
                idle: z.string().min(1).optional(),
            }).optional(),
            play_animation: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_48, position, velocity, error_51;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_characterbody2d_movement', args)];
                    case 2:
                        result = _b.sent();
                        status_48 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.position ? JSON.stringify(result.position) : 'unknown';
                        velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
                        return [2 /*return*/, "Simulated CharacterBody2D movement on ".concat(args.node_path, " [").concat(status_48, "] -> position=").concat(position, ", velocity=").concat(velocity)];
                    case 3:
                        error_51 = _b.sent();
                        throw new Error("Failed to simulate CharacterBody2D movement: ".concat(error_51.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_characterbody3d_movement',
        description: 'Apply one movement simulation step to a CharacterBody3D for rapid gameplay tuning',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the CharacterBody3D node'),
            direction: vector3ParamSchema.optional()
                .describe('Desired movement direction for this simulation step'),
            speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            deceleration: z.number().nonnegative().optional(),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            planar_only: z.boolean().optional()
                .describe('Ignore vertical input and simulate movement on XZ plane only (default true)'),
            preserve_vertical_velocity: z.boolean().optional()
                .describe('Keep existing vertical velocity when planar_only=true (default true)'),
            yaw_to_direction: z.boolean().optional()
                .describe('Rotate the body yaw to match movement direction'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_49, position, velocity, error_52;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_characterbody3d_movement', args)];
                    case 2:
                        result = _b.sent();
                        status_49 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.position ? JSON.stringify(result.position) : 'unknown';
                        velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
                        return [2 /*return*/, "Simulated CharacterBody3D movement on ".concat(args.node_path, " [").concat(status_49, "] -> position=").concat(position, ", velocity=").concat(velocity)];
                    case 3:
                        error_52 = _b.sent();
                        throw new Error("Failed to simulate CharacterBody3D movement: ".concat(error_52.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_navigation_chase_step_2d',
        description: 'Advance a NavigationAgent2D pursuit step by sampling get_next_path_position and moving a CharacterBody2D',
        parameters: z.object({
            agent_path: z.string()
                .describe('Path to the NavigationAgent2D node'),
            body_path: z.string().optional()
                .describe('Optional CharacterBody2D path to move (defaults to the agent parent)'),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            deceleration: z.number().nonnegative().optional(),
            stop_distance: z.number().nonnegative().optional()
                .describe('Distance threshold from next path point before stopping'),
            set_rotation: z.boolean().optional()
                .describe('Rotate the body toward movement direction'),
            update_agent_velocity: z.boolean().optional()
                .describe('Write velocity back to NavigationAgent2D for avoidance workflows'),
            sync_agent_to_body: z.boolean().optional()
                .describe('Keep NavigationAgent2D transform aligned to the controlled body'),
            stop_on_navigation_finished: z.boolean().optional()
                .describe('Stop movement when NavigationAgent2D reports navigation finished (default true)'),
            allow_direct_fallback: z.boolean().optional()
                .describe('Fallback to direct target pursuit when no nav path point is available (default true)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_50, position, velocity, error_53;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_navigation_chase_step_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_50 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.position ? JSON.stringify(result.position) : 'unknown';
                        velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
                        return [2 /*return*/, "Simulated navigation chase step 2D for ".concat(args.agent_path, " [").concat(status_50, "] -> position=").concat(position, ", velocity=").concat(velocity)];
                    case 3:
                        error_53 = _b.sent();
                        throw new Error("Failed to simulate navigation chase step 2D: ".concat(error_53.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_navigation_chase_step_3d',
        description: 'Advance a NavigationAgent3D pursuit step by sampling get_next_path_position and moving a CharacterBody3D',
        parameters: z.object({
            agent_path: z.string()
                .describe('Path to the NavigationAgent3D node'),
            body_path: z.string().optional()
                .describe('Optional CharacterBody3D path to move (defaults to the agent parent)'),
            delta: z.number().positive().optional()
                .describe('Simulation step duration in seconds (default 1/60)'),
            speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            deceleration: z.number().nonnegative().optional(),
            stop_distance: z.number().nonnegative().optional()
                .describe('Distance threshold from next path point before stopping'),
            planar_only: z.boolean().optional()
                .describe('Limit chase movement to XZ plane while preserving Y movement controls (default true)'),
            preserve_vertical_velocity: z.boolean().optional()
                .describe('Keep existing Y velocity when planar_only=true (default true)'),
            yaw_to_direction: z.boolean().optional()
                .describe('Rotate the body yaw toward movement direction'),
            update_agent_velocity: z.boolean().optional()
                .describe('Write velocity back to NavigationAgent3D for avoidance workflows'),
            sync_agent_to_body: z.boolean().optional()
                .describe('Keep NavigationAgent3D transform aligned to the controlled body'),
            stop_on_navigation_finished: z.boolean().optional()
                .describe('Stop movement when NavigationAgent3D reports navigation finished (default true)'),
            allow_direct_fallback: z.boolean().optional()
                .describe('Fallback to direct target pursuit when no nav path point is available (default true)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_51, position, velocity, error_54;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_navigation_chase_step_3d', args)];
                    case 2:
                        result = _b.sent();
                        status_51 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.position ? JSON.stringify(result.position) : 'unknown';
                        velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
                        return [2 /*return*/, "Simulated navigation chase step 3D for ".concat(args.agent_path, " [").concat(status_51, "] -> position=").concat(position, ", velocity=").concat(velocity)];
                    case 3:
                        error_54 = _b.sent();
                        throw new Error("Failed to simulate navigation chase step 3D: ".concat(error_54.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_navigation_target_to_node_2d',
        description: 'Set NavigationAgent2D target_position from another node to quickly wire enemy/player pursuit behaviors',
        parameters: z.object({
            agent_path: z.string()
                .describe('Path to the NavigationAgent2D node'),
            target_path: z.string()
                .describe('Path to the target Node2D'),
            offset: vector2ParamSchema.optional()
                .describe('Optional offset applied to target global position'),
            remember_target: z.boolean().optional()
                .describe('Store target path metadata on the agent for tooling workflows (default true)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_52, position, error_55;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_navigation_target_to_node_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_52 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.target_position ? JSON.stringify(result.target_position) : 'unknown';
                        return [2 /*return*/, "Set NavigationAgent2D target for ".concat(args.agent_path, " -> ").concat(args.target_path, " at ").concat(position, " [").concat(status_52, "]")];
                    case 3:
                        error_55 = _b.sent();
                        throw new Error("Failed to set NavigationAgent2D target: ".concat(error_55.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_navigation_target_to_node_3d',
        description: 'Set NavigationAgent3D target_position from another node to wire 3D enemy/player navigation',
        parameters: z.object({
            agent_path: z.string()
                .describe('Path to the NavigationAgent3D node'),
            target_path: z.string()
                .describe('Path to the target Node3D'),
            offset: vector3ParamSchema.optional()
                .describe('Optional offset applied to target global position'),
            remember_target: z.boolean().optional()
                .describe('Store target path metadata on the agent for tooling workflows (default true)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_53, position, error_56;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_navigation_target_to_node_3d', args)];
                    case 2:
                        result = _b.sent();
                        status_53 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        position = result.target_position ? JSON.stringify(result.target_position) : 'unknown';
                        return [2 /*return*/, "Set NavigationAgent3D target for ".concat(args.agent_path, " -> ").concat(args.target_path, " at ").concat(position, " [").concat(status_53, "]")];
                    case 3:
                        error_56 = _b.sent();
                        throw new Error("Failed to set NavigationAgent3D target: ".concat(error_56.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_water_body_2d',
        description: 'Generate a 2D water body scaffold (Area2D + collider + visual) with flow and wave metadata for gameplay logic',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated water root (defaults to "/root")'),
            water_name: z.string().optional()
                .describe('Name for the generated water root node'),
            position: vector2ParamSchema.optional(),
            size: vector2ParamSchema.optional(),
            create_visual: z.boolean().optional(),
            create_area: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            color: z.any().optional(),
            flow_direction: vector2ParamSchema.optional(),
            flow_speed: z.number().optional(),
            buoyancy: z.number().optional(),
            drag: z.number().optional(),
            wave_amplitude: z.number().optional(),
            wave_speed: z.number().optional(),
            wave_length: z.number().positive().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_54, waterPath, flowSpeed, error_57;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_water_body_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_54 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        waterPath = (_b = result.water_path) !== null && _b !== void 0 ? _b : 'unknown';
                        flowSpeed = Number((_c = result.flow_speed) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 2D water body at ".concat(waterPath, " (flow=").concat(flowSpeed.toFixed(2), ") [").concat(status_54, "]")];
                    case 3:
                        error_57 = _d.sent();
                        throw new Error("Failed to build water body 2D: ".concat(error_57.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_water_body_3d',
        description: 'Generate a 3D water volume scaffold (surface mesh + Area3D volume) with tunable rendering and wave metadata',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated water root (defaults to "/root")'),
            water_name: z.string().optional()
                .describe('Name for the generated water root node'),
            position: vector3ParamSchema.optional(),
            size: vector2ParamSchema.optional(),
            depth: z.number().positive().optional(),
            create_visual: z.boolean().optional(),
            create_area: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            flow_direction: vector2ParamSchema.optional(),
            flow_speed: z.number().optional(),
            buoyancy: z.number().optional(),
            drag: z.number().optional(),
            wave_amplitude: z.number().optional(),
            wave_speed: z.number().optional(),
            wave_length: z.number().positive().optional(),
            surface_color: z.any().optional(),
            roughness: z.number().min(0).max(1).optional(),
            metallic: z.number().min(0).max(1).optional(),
            emission_color: z.any().optional(),
            emission_energy: z.number().nonnegative().optional(),
            subdivide_width: z.number().int().min(0).optional(),
            subdivide_depth: z.number().int().min(0).optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_55, waterPath, depth, error_58;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_water_body_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_55 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        waterPath = (_b = result.water_path) !== null && _b !== void 0 ? _b : 'unknown';
                        depth = Number((_c = result.depth) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 3D water body at ".concat(waterPath, " (depth=").concat(depth.toFixed(2), ") [").concat(status_55, "]")];
                    case 3:
                        error_58 = _d.sent();
                        throw new Error("Failed to build water body 3D: ".concat(error_58.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_sand_field_3d',
        description: 'Generate a 3D granular field scaffold with MultiMesh grains and homogenized sand profile metadata',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated sand field root (defaults to "/root")'),
            field_name: z.string().optional(),
            origin: vector3ParamSchema.optional(),
            size: vector3ParamSchema.optional(),
            create_visual: z.boolean().optional(),
            create_volume_area: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            grain_spacing: z.number().positive().optional(),
            grain_radius: z.number().positive().optional(),
            jitter: z.number().nonnegative().optional(),
            max_grains: z.number().int().positive().optional(),
            random_yaw: z.boolean().optional(),
            seed: z.number().int().optional(),
            grain_color: z.any().optional(),
            grain_roughness: z.number().min(0).max(1).optional(),
            grain_metallic: z.number().min(0).max(1).optional(),
            profile_name: z.string().optional(),
            source_reference: z.string().optional(),
            internal_friction: z.number().nonnegative().optional(),
            cohesion: z.number().nonnegative().optional(),
            stiffness: z.number().nonnegative().optional(),
            bulk_density: z.number().nonnegative().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_56, fieldPath, grains, error_59;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_sand_field_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_56 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        fieldPath = (_b = result.field_path) !== null && _b !== void 0 ? _b : 'unknown';
                        grains = Number((_c = result.grain_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 3D sand field at ".concat(fieldPath, " with ").concat(grains, " grains [").concat(status_56, "]")];
                    case 3:
                        error_59 = _d.sent();
                        throw new Error("Failed to build sand field 3D: ".concat(error_59.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_cave_2d',
        description: 'Generate a procedural 2D cave layout using cellular automata with collision, visuals, and an optional spawn marker',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated cave root (defaults to "/root")'),
            cave_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            grid_size: vector2ParamSchema.optional()
                .describe('Cave grid dimensions in cells'),
            cell_size: vector2ParamSchema.optional()
                .describe('Cell dimensions in local units/pixels'),
            fill_ratio: z.number().min(0).max(1).optional(),
            smoothing_steps: z.number().int().nonnegative().optional(),
            birth_limit: z.number().int().min(0).max(8).optional(),
            death_limit: z.number().int().min(0).max(8).optional(),
            border_solid: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            create_visuals: z.boolean().optional(),
            create_background: z.boolean().optional(),
            create_spawn_marker: z.boolean().optional(),
            wall_color: z.any().optional(),
            background_color: z.any().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_57, cavePath, segments, error_60;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_cave_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_57 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        cavePath = (_b = result.cave_path) !== null && _b !== void 0 ? _b : 'unknown';
                        segments = Number((_c = result.wall_segment_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 2D cave at ".concat(cavePath, " with ").concat(segments, " wall segment(s) [").concat(status_57, "]")];
                    case 3:
                        error_60 = _d.sent();
                        throw new Error("Failed to build cave 2D: ".concat(error_60.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_sand_field_2d',
        description: 'Generate a 2D granular sand field scaffold with grain polygons, optional volume Area2D, and material profile metadata',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated sand field root (defaults to "/root")'),
            field_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            size: vector2ParamSchema.optional(),
            create_visual: z.boolean().optional(),
            create_volume_area: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            grain_spacing: z.number().positive().optional(),
            grain_radius: z.number().positive().optional(),
            jitter: z.number().nonnegative().optional(),
            max_grains: z.number().int().positive().optional(),
            random_rotation: z.boolean().optional(),
            grain_segments: z.number().int().min(3).max(24).optional(),
            seed: z.number().int().optional(),
            grain_color: z.any().optional(),
            profile_name: z.string().optional(),
            source_reference: z.string().optional(),
            internal_friction: z.number().nonnegative().optional(),
            cohesion: z.number().nonnegative().optional(),
            stiffness: z.number().nonnegative().optional(),
            bulk_density: z.number().nonnegative().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_58, fieldPath, grains, error_61;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_sand_field_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_58 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        fieldPath = (_b = result.field_path) !== null && _b !== void 0 ? _b : 'unknown';
                        grains = Number((_c = result.grain_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 2D sand field at ".concat(fieldPath, " with ").concat(grains, " grains [").concat(status_58, "]")];
                    case 3:
                        error_61 = _d.sent();
                        throw new Error("Failed to build sand field 2D: ".concat(error_61.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_platformer_blockout_2d',
        description: 'Generate a procedural side-scroller platform chain blockout with optional spawn/goal markers',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated level root (defaults to "/root")'),
            level_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            segment_count: z.number().int().positive().optional(),
            min_platform_width: z.number().positive().optional(),
            max_platform_width: z.number().positive().optional(),
            platform_height: z.number().positive().optional(),
            min_gap: z.number().nonnegative().optional(),
            max_gap: z.number().nonnegative().optional(),
            base_y: z.number().optional(),
            min_height_step: z.number().optional(),
            max_height_step: z.number().optional(),
            min_y: z.number().optional(),
            max_y: z.number().optional(),
            create_collision: z.boolean().optional(),
            create_visuals: z.boolean().optional(),
            create_spawn_marker: z.boolean().optional(),
            create_goal_marker: z.boolean().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            platform_color: z.any().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_59, levelPath, segmentCount, error_62;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_platformer_blockout_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_59 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        levelPath = (_b = result.level_path) !== null && _b !== void 0 ? _b : 'unknown';
                        segmentCount = Number((_c = result.segment_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Generated platformer blockout at ".concat(levelPath, " with ").concat(segmentCount, " segment(s) [").concat(status_59, "]")];
                    case 3:
                        error_62 = _d.sent();
                        throw new Error("Failed to generate platformer blockout 2D: ".concat(error_62.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_topdown_dungeon_2d',
        description: 'Generate a procedural top-down dungeon using room placement and corridor carving',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated dungeon root (defaults to "/root")'),
            dungeon_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            grid_size: vector2ParamSchema.optional(),
            cell_size: vector2ParamSchema.optional(),
            room_attempts: z.number().int().positive().optional(),
            room_target: z.number().int().positive().optional(),
            room_min_size: vector2ParamSchema.optional(),
            room_max_size: vector2ParamSchema.optional(),
            corridor_width: z.number().int().positive().optional(),
            border_walls: z.boolean().optional(),
            create_floor_visuals: z.boolean().optional(),
            create_wall_collision: z.boolean().optional(),
            create_wall_visuals: z.boolean().optional(),
            create_spawn_marker: z.boolean().optional(),
            create_goal_marker: z.boolean().optional(),
            floor_color: z.any().optional(),
            wall_color: z.any().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_60, dungeonPath, roomCount, corridorCount, error_63;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_topdown_dungeon_2d', args)];
                    case 2:
                        result = _e.sent();
                        status_60 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        dungeonPath = (_b = result.dungeon_path) !== null && _b !== void 0 ? _b : 'unknown';
                        roomCount = Number((_c = result.room_count) !== null && _c !== void 0 ? _c : 0);
                        corridorCount = Number((_d = result.corridor_count) !== null && _d !== void 0 ? _d : 0);
                        return [2 /*return*/, "Generated topdown dungeon at ".concat(dungeonPath, " with ").concat(roomCount, " room(s) and ").concat(corridorCount, " corridor(s) [").concat(status_60, "]")];
                    case 3:
                        error_63 = _e.sent();
                        throw new Error("Failed to generate topdown dungeon 2D: ".concat(error_63.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_isometric_tile_blockout_2d',
        description: 'Generate an isometric tile blockout with procedural height, optional side faces, and optional collision',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated level root (defaults to "/root")'),
            level_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            grid_size: vector2ParamSchema.optional(),
            max_tiles: z.number().int().positive().optional(),
            tile_size: vector2ParamSchema.optional(),
            min_height: z.number().int().optional(),
            max_height: z.number().int().optional(),
            elevation_step: z.number().positive().optional(),
            noise_frequency: z.number().positive().optional(),
            fractal_octaves: z.number().int().positive().optional(),
            fractal_lacunarity: z.number().nonnegative().optional(),
            fractal_gain: z.number().nonnegative().optional(),
            noise_type: z.number().int().optional(),
            fractal_type: z.number().int().optional(),
            sample_offset: vector2ParamSchema.optional(),
            create_collision: z.boolean().optional(),
            create_side_faces: z.boolean().optional(),
            top_color: z.any().optional(),
            left_color: z.any().optional(),
            right_color: z.any().optional(),
            height_tint_strength: z.number().min(0).max(1).optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_61, levelPath, tileCount, error_64;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_isometric_tile_blockout_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_61 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        levelPath = (_b = result.level_path) !== null && _b !== void 0 ? _b : 'unknown';
                        tileCount = Number((_c = result.tile_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Generated isometric tile blockout at ".concat(levelPath, " with ").concat(tileCount, " tile(s) [").concat(status_61, "]")];
                    case 3:
                        error_64 = _d.sent();
                        throw new Error("Failed to generate isometric tile blockout 2D: ".concat(error_64.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'generate_tentacle_waypoints_2d',
        description: 'Generate a procedural 2D tentacle rig with waypoint markers, optional line visuals, and optional tip/segment helpers',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated tentacle root (defaults to "/root")'),
            tentacle_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            waypoint_count: z.number().int().min(2).optional(),
            segment_length: z.number().positive().optional(),
            lateral_amplitude: z.number().nonnegative().optional(),
            wave_count: z.number().nonnegative().optional(),
            random_jitter: z.number().nonnegative().optional(),
            taper: z.number().min(0).max(1).optional(),
            direction: vector2ParamSchema.optional(),
            create_line: z.boolean().optional(),
            create_waypoint_markers: z.boolean().optional(),
            create_segment_markers: z.boolean().optional(),
            create_tip_marker: z.boolean().optional(),
            line_color: z.any().optional(),
            line_width_start: z.number().positive().optional(),
            line_width_end: z.number().positive().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_62, tentaclePath, waypointCount, error_65;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_tentacle_waypoints_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_62 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        tentaclePath = (_b = result.tentacle_path) !== null && _b !== void 0 ? _b : 'unknown';
                        waypointCount = Number((_c = result.waypoint_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Generated tentacle waypoints at ".concat(tentaclePath, " with ").concat(waypointCount, " waypoint(s) [").concat(status_62, "]")];
                    case 3:
                        error_65 = _d.sent();
                        throw new Error("Failed to generate tentacle waypoints 2D: ".concat(error_65.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_creature_parts_2d',
        description: 'Build a modular 2D creature parts rig with optional visual, collision, and attachment marker scaffolding',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated creature root (defaults to "/root")'),
            creature_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            scale: z.number().positive().optional(),
            include_tail: z.boolean().optional(),
            include_wings: z.boolean().optional(),
            include_horns: z.boolean().optional(),
            create_visuals: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            create_attachment_markers: z.boolean().optional(),
            body_color: z.any().optional(),
            accent_color: z.any().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_63, creaturePath, partCount, error_66;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_creature_parts_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_63 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        creaturePath = (_b = result.creature_path) !== null && _b !== void 0 ? _b : 'unknown';
                        partCount = Number((_c = result.part_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built creature parts at ".concat(creaturePath, " with ").concat(partCount, " part(s) [").concat(status_63, "]")];
                    case 3:
                        error_66 = _d.sent();
                        throw new Error("Failed to build creature parts 2D: ".concat(error_66.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_slime_mold_colony_2d',
        description: 'Create a slow-growth slime mold colony scaffold on a 2D grid with optional visuals/collision and metadata for future growth steps',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated slime colony root (defaults to "/root")'),
            colony_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            grid_size: vector2ParamSchema.optional(),
            cell_size: vector2ParamSchema.optional(),
            initial_cell_count: z.number().int().positive().optional(),
            initial_radius: z.number().int().nonnegative().optional(),
            spread_chance: z.number().min(0).max(1).optional(),
            growth_rate: z.number().nonnegative().optional(),
            max_cells: z.number().int().positive().optional(),
            create_visuals: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            cell_color: z.any().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_64, colonyPath, cellCount, error_67;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_slime_mold_colony_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_64 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        colonyPath = (_b = result.colony_path) !== null && _b !== void 0 ? _b : 'unknown';
                        cellCount = Number((_c = result.cell_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built slime mold colony at ".concat(colonyPath, " with ").concat(cellCount, " cell(s) [").concat(status_64, "]")];
                    case 3:
                        error_67 = _d.sent();
                        throw new Error("Failed to build slime mold colony 2D: ".concat(error_67.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_slime_mold_growth_step_2d',
        description: 'Apply one or more procedural growth steps to a slime colony to spread cells slowly across neighboring grid positions',
        parameters: z.object({
            colony_path: z.string()
                .describe('Path to the slime colony root node'),
            cells_path: z.string().optional()
                .describe('Optional explicit path to the colony cell container'),
            grid_size: vector2ParamSchema.optional(),
            cell_size: vector2ParamSchema.optional(),
            spread_chance: z.number().min(0).max(1).optional(),
            growth_rate: z.number().nonnegative().optional(),
            max_cells: z.number().int().positive().optional(),
            steps: z.number().int().positive().optional(),
            max_new_cells_per_step: z.number().int().positive().optional(),
            allow_diagonal: z.boolean().optional(),
            create_visuals: z.boolean().optional(),
            create_collision: z.boolean().optional(),
            cell_color: z.any().optional(),
            collision_layer: z.number().int().optional(),
            collision_mask: z.number().int().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_65, addedCount, totalCells, error_68;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_slime_mold_growth_step_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_65 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        addedCount = Number((_b = result.added_count) !== null && _b !== void 0 ? _b : 0);
                        totalCells = Number((_c = result.total_cells) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Simulated slime growth for ".concat(args.colony_path, " with +").concat(addedCount, " cell(s), total ").concat(totalCells, " [").concat(status_65, "]")];
                    case 3:
                        error_68 = _d.sent();
                        throw new Error("Failed to simulate slime mold growth step 2D: ".concat(error_68.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_light_node',
        description: 'Configure Light2D or Light3D properties including enable state, color, intensity, shadows, and range/fade controls',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to a Light2D or Light3D node to configure'),
            enabled: z.boolean().optional(),
            color: z.any().optional(),
            profile_name: z.string().optional(),
            energy: z.number().optional(),
            shadow_enabled: z.boolean().optional(),
            shadow_color: z.any().optional(),
            texture_scale: z.number().optional(),
            height: z.number().optional(),
            shadow_filter_smooth: z.number().optional(),
            blend_mode: z.number().int().optional(),
            range_item_cull_mask: z.number().int().optional(),
            range_layer_min: z.number().int().optional(),
            range_layer_max: z.number().int().optional(),
            range_z_min: z.number().int().optional(),
            range_z_max: z.number().int().optional(),
            shadow_filter: z.number().int().optional(),
            indirect_energy: z.number().optional(),
            volumetric_fog_energy: z.number().optional(),
            specular: z.number().optional(),
            temperature: z.number().optional(),
            shadow_blur: z.number().optional(),
            shadow_bias: z.number().optional(),
            shadow_normal_bias: z.number().optional(),
            distance_fade_enabled: z.boolean().optional(),
            distance_fade_begin: z.number().optional(),
            distance_fade_length: z.number().optional(),
            distance_fade_shadow: z.number().optional(),
            cull_mask: z.number().int().optional(),
            projector_path: z.string().optional(),
            omni_range: z.number().optional(),
            omni_attenuation: z.number().optional(),
            spot_range: z.number().optional(),
            spot_attenuation: z.number().optional(),
            spot_angle: z.number().optional(),
            spot_angle_attenuation: z.number().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_66, nodePath, lightType, enabled, energy, error_69;
            var _a, _b, _c, _d, _e, _f, _g;
            return __generator(this, function (_h) {
                switch (_h.label) {
                    case 0:
                        godot = getGodotConnection();
                        _h.label = 1;
                    case 1:
                        _h.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_light_node', args)];
                    case 2:
                        result = _h.sent();
                        status_66 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        nodePath = (_b = result.node_path) !== null && _b !== void 0 ? _b : args.node_path;
                        lightType = String((_c = result.light_type) !== null && _c !== void 0 ? _c : 'Light');
                        enabled = Boolean((_e = (_d = result.enabled) !== null && _d !== void 0 ? _d : args.enabled) !== null && _e !== void 0 ? _e : true);
                        energy = Number((_g = (_f = result.energy) !== null && _f !== void 0 ? _f : args.energy) !== null && _g !== void 0 ? _g : 0);
                        return [2 /*return*/, "Configured ".concat(lightType, " at ").concat(nodePath, " enabled=").concat(enabled, " energy=").concat(energy.toFixed(2), " [").concat(status_66, "]")];
                    case 3:
                        error_69 = _h.sent();
                        throw new Error("Failed to configure light node: ".concat(error_69.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_smoke_effect_2d',
        description: 'Create a procedural 2D smoke rig with particles, wind drift tuning, and optional full-screen haze overlay',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated smoke root (defaults to "/root")'),
            smoke_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            area_size: vector2ParamSchema.optional(),
            intensity: z.number().min(0).max(1).optional(),
            wind_direction: vector2ParamSchema.optional(),
            wind_strength: z.number().min(0).max(1).optional(),
            max_particles: z.number().int().nonnegative().optional(),
            particle_lifetime: z.number().positive().optional(),
            rise_speed_min: z.number().nonnegative().optional(),
            rise_speed_max: z.number().nonnegative().optional(),
            spread_degrees: z.number().min(0).max(180).optional(),
            rise_acceleration: z.number().nonnegative().optional(),
            damping_min: z.number().nonnegative().optional(),
            damping_max: z.number().nonnegative().optional(),
            particle_scale_min: vector2ParamSchema.optional(),
            particle_scale_max: vector2ParamSchema.optional(),
            smoke_roundness: z.number().min(0).max(1).optional(),
            smoke_softness: z.number().min(0).max(1).optional(),
            smoke_noise_strength: z.number().min(0).max(1).optional(),
            smoke_noise_scale: z.number().positive().optional(),
            smoke_texture_size: z.number().int().min(16).max(256).optional(),
            smoke_color: z.any().optional(),
            create_overlay: z.boolean().optional(),
            overlay_density: z.number().min(0).max(1).optional(),
            overlay_color: z.any().optional(),
            canvas_layer: z.number().int().optional(),
            particle_fixed_fps: z.number().int().positive().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_67, smokePath, particles, emitting, error_70;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_smoke_effect_2d', args)];
                    case 2:
                        result = _e.sent();
                        status_67 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        smokePath = (_b = result.smoke_path) !== null && _b !== void 0 ? _b : 'unknown';
                        particles = Number((_c = result.particle_amount) !== null && _c !== void 0 ? _c : 0);
                        emitting = Boolean((_d = result.can_emit) !== null && _d !== void 0 ? _d : false);
                        return [2 /*return*/, "Built 2D smoke effect at ".concat(smokePath, " particles=").concat(particles, " emitting=").concat(emitting, " [").concat(status_67, "]")];
                    case 3:
                        error_70 = _e.sent();
                        throw new Error("Failed to build smoke effect 2D: ".concat(error_70.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_particles_3d',
        description: 'Configure GPUParticles3D node playback and particle process material properties for gameplay VFX tuning',
        parameters: z.object({
            node_path: z.string()
                .describe('Path to the GPUParticles3D node'),
            emitting: z.boolean().optional(),
            one_shot: z.boolean().optional(),
            local_coords: z.boolean().optional(),
            trail_enabled: z.boolean().optional(),
            amount: z.number().int().nonnegative().optional(),
            fixed_fps: z.number().int().nonnegative().optional(),
            draw_order: z.number().int().optional(),
            amount_ratio: z.number().min(0).max(1).optional(),
            lifetime: z.number().positive().optional(),
            preprocess: z.number().nonnegative().optional(),
            speed_scale: z.number().optional(),
            explosiveness: z.number().min(0).max(1).optional(),
            randomness: z.number().min(0).max(1).optional(),
            interp_to_end: z.number().min(0).max(1).optional(),
            trail_lifetime: z.number().nonnegative().optional(),
            visibility_aabb: z.object({
                position: vector3ParamSchema.optional(),
                size: vector3ParamSchema.optional(),
                x: z.number().optional(),
                y: z.number().optional(),
                z: z.number().optional(),
                width: z.number().optional(),
                height: z.number().optional(),
                depth: z.number().optional(),
            }).optional(),
            draw_pass_1_path: z.string().optional(),
            ensure_process_material: z.boolean().optional(),
            direction: vector3ParamSchema.optional(),
            spread: z.number().optional(),
            gravity: vector3ParamSchema.optional(),
            initial_velocity_min: z.number().optional(),
            initial_velocity_max: z.number().optional(),
            angular_velocity_min: z.number().optional(),
            angular_velocity_max: z.number().optional(),
            damping_min: z.number().nonnegative().optional(),
            damping_max: z.number().nonnegative().optional(),
            scale_min: z.number().nonnegative().optional(),
            scale_max: z.number().nonnegative().optional(),
            color: z.any().optional(),
            emission_shape: z.number().int().optional(),
            emission_box_extents: vector3ParamSchema.optional(),
            color_ramp_path: z.string().optional(),
            profile_name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_68, amount, lifetime, emitting, error_71;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_particles_3d', args)];
                    case 2:
                        result = _e.sent();
                        status_68 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        amount = Number((_b = result.amount) !== null && _b !== void 0 ? _b : 0);
                        lifetime = Number((_c = result.lifetime) !== null && _c !== void 0 ? _c : 0);
                        emitting = Boolean((_d = result.emitting) !== null && _d !== void 0 ? _d : false);
                        return [2 /*return*/, "Configured GPUParticles3D ".concat(args.node_path, " amount=").concat(amount, " lifetime=").concat(lifetime.toFixed(2), " emitting=").concat(emitting, " [").concat(status_68, "]")];
                    case 3:
                        error_71 = _e.sent();
                        throw new Error("Failed to configure particles 3D: ".concat(error_71.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_smoke_effect_3d',
        description: 'Create a procedural 3D smoke rig with GPUParticles3D, billboards, wind drift, and optional ground haze',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated smoke root (defaults to "/root")'),
            smoke_name: z.string().optional(),
            position: vector3ParamSchema.optional(),
            volume_size: vector3ParamSchema.optional(),
            intensity: z.number().min(0).max(1).optional(),
            wind_direction: vector3ParamSchema.optional(),
            wind_strength: z.number().min(0).max(1).optional(),
            max_particles: z.number().int().nonnegative().optional(),
            particle_lifetime: z.number().positive().optional(),
            rise_speed_min: z.number().nonnegative().optional(),
            rise_speed_max: z.number().nonnegative().optional(),
            spread_degrees: z.number().min(0).max(180).optional(),
            damping_min: z.number().nonnegative().optional(),
            damping_max: z.number().nonnegative().optional(),
            smoke_roundness: z.number().min(0).max(1).optional(),
            smoke_softness: z.number().min(0).max(1).optional(),
            smoke_noise_strength: z.number().min(0).max(1).optional(),
            smoke_noise_scale: z.number().positive().optional(),
            smoke_texture_size: z.number().int().min(16).max(256).optional(),
            smoke_color: z.any().optional(),
            create_ground_haze: z.boolean().optional(),
            haze_color: z.any().optional(),
            particle_fixed_fps: z.number().int().positive().optional(),
            particle_quad_size: z.number().positive().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_69, smokePath, particles, emitting, error_72;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_smoke_effect_3d', args)];
                    case 2:
                        result = _e.sent();
                        status_69 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        smokePath = (_b = result.smoke_path) !== null && _b !== void 0 ? _b : 'unknown';
                        particles = Number((_c = result.particle_amount) !== null && _c !== void 0 ? _c : 0);
                        emitting = Boolean((_d = result.can_emit) !== null && _d !== void 0 ? _d : false);
                        return [2 /*return*/, "Built 3D smoke effect at ".concat(smokePath, " particles=").concat(particles, " emitting=").concat(emitting, " [").concat(status_69, "]")];
                    case 3:
                        error_72 = _e.sent();
                        throw new Error("Failed to build smoke effect 3D: ".concat(error_72.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_light_occluder_2d',
        description: 'Create a LightOccluder2D with generated or explicit polygon points for 2D shadow blocking',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated light occluder (defaults to "/root")'),
            occluder_name: z.string().optional(),
            position: vector2ParamSchema.optional(),
            size: vector2ParamSchema.optional(),
            polygon_points: z.array(vector2ParamSchema).optional(),
            closed: z.boolean().optional(),
            cull_mode: z.number().int().optional(),
            occluder_light_mask: z.number().int().optional(),
            sdf_collision: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_70, occluderPath, points, error_73;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_light_occluder_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_70 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        occluderPath = (_b = result.occluder_path) !== null && _b !== void 0 ? _b : 'unknown';
                        points = Number((_c = result.point_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built LightOccluder2D at ".concat(occluderPath, " with ").concat(points, " point(s) [").concat(status_70, "]")];
                    case 3:
                        error_73 = _d.sent();
                        throw new Error("Failed to build LightOccluder2D: ".concat(error_73.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'edit_light_occluder_polygon_2d',
        description: 'Edit a LightOccluder2D polygon by replacing, appending, offsetting points, and changing cull/closure behavior',
        parameters: z.object({
            occluder_path: z.string()
                .describe('Path to the LightOccluder2D node'),
            polygon_points: z.array(vector2ParamSchema).optional(),
            append_points: z.array(vector2ParamSchema).optional(),
            offset: vector2ParamSchema.optional(),
            closed: z.boolean().optional(),
            cull_mode: z.number().int().optional(),
            profile_name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_71, points, error_74;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('edit_light_occluder_polygon_2d', args)];
                    case 2:
                        result = _c.sent();
                        status_71 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        points = Number((_b = result.point_count) !== null && _b !== void 0 ? _b : 0);
                        return [2 /*return*/, "Edited LightOccluder2D ".concat(args.occluder_path, " to ").concat(points, " point(s) [").concat(status_71, "]")];
                    case 3:
                        error_74 = _c.sent();
                        throw new Error("Failed to edit LightOccluder2D polygon: ".concat(error_74.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_subviewport_minimap',
        description: 'Build a minimap UI rig using SubViewportContainer/SubViewport with 2D or 3D orthographic camera setup',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the minimap canvas root (defaults to "/root")'),
            minimap_name: z.string().optional(),
            target_path: z.string().optional(),
            mode: z.enum(['auto', '2d', 'topdown3d', 'isometric3d']).optional(),
            size: vector2ParamSchema.optional(),
            margin: z.number().nonnegative().optional(),
            anchor: z.enum(['top_left', 'top_right', 'bottom_left', 'bottom_right']).optional(),
            canvas_layer: z.number().int().optional(),
            zoom_2d: z.number().positive().optional(),
            camera_size: z.number().positive().optional(),
            camera_height: z.number().positive().optional(),
            isometric_distance: z.number().positive().optional(),
            near: z.number().positive().optional(),
            far: z.number().positive().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_72, minimapPath, mode, error_75;
            var _a, _b, _c, _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_subviewport_minimap', args)];
                    case 2:
                        result = _e.sent();
                        status_72 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        minimapPath = (_b = result.minimap_path) !== null && _b !== void 0 ? _b : 'unknown';
                        mode = String((_d = (_c = result.mode) !== null && _c !== void 0 ? _c : args.mode) !== null && _d !== void 0 ? _d : 'auto');
                        return [2 /*return*/, "Built minimap at ".concat(minimapPath, " mode=").concat(mode, " [").concat(status_72, "]")];
                    case 3:
                        error_75 = _e.sent();
                        throw new Error("Failed to build subviewport minimap: ".concat(error_75.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_weather_system_2d',
        description: 'Build a full 2D weather rig with precipitation particles, fog overlay, ambient canvas tinting, and optional lightning flash layer',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated weather root (defaults to "/root")'),
            weather_name: z.string().optional(),
            origin: vector2ParamSchema.optional(),
            area_size: vector2ParamSchema.optional()
                .describe('Logical weather coverage area for emitters and overlays'),
            preset: z.string().optional()
                .describe('Weather preset: clear, drizzle, rain, storm, snow, blizzard, ash'),
            intensity: z.number().min(0).max(1).optional(),
            transition_rate: z.number().positive().optional(),
            wind_direction: vector2ParamSchema.optional(),
            wind_strength: z.number().min(0).max(1).optional(),
            canvas_layer: z.number().int().optional(),
            enable_precipitation: z.boolean().optional(),
            enable_fog: z.boolean().optional(),
            enable_ambient_modulate: z.boolean().optional(),
            enable_lightning_overlay: z.boolean().optional(),
            precipitation_mode: z.enum(['none', 'rain', 'snow', 'ash']).optional(),
            precipitation_intensity_scale: z.number().min(0).max(2).optional(),
            max_particles: z.number().int().nonnegative().optional(),
            particle_lifetime: z.number().positive().optional(),
            particle_speed_min: z.number().nonnegative().optional(),
            particle_speed_max: z.number().nonnegative().optional(),
            spread_degrees: z.number().min(0).max(180).optional(),
            gravity_strength: z.number().nonnegative().optional(),
            particle_scale_min: vector2ParamSchema.optional(),
            particle_scale_max: vector2ParamSchema.optional(),
            fog_density: z.number().min(0).max(1).optional(),
            fog_color: z.any().optional(),
            ambient_color: z.any().optional(),
            precipitation_color: z.any().optional(),
            lightning_enabled: z.boolean().optional(),
            lightning_chance: z.number().min(0).max(1).optional(),
            lightning_flash_strength: z.number().min(0).max(1).optional(),
            lightning_decay: z.number().positive().optional(),
            lightning_color: z.any().optional(),
            particle_fixed_fps: z.number().int().positive().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_73, weatherPath, preset, intensity, error_76;
            var _a, _b, _c, _d, _e, _f;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_weather_system_2d', args)];
                    case 2:
                        result = _g.sent();
                        status_73 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        weatherPath = (_b = result.weather_path) !== null && _b !== void 0 ? _b : 'unknown';
                        preset = String((_d = (_c = result.preset) !== null && _c !== void 0 ? _c : args.preset) !== null && _d !== void 0 ? _d : 'unknown');
                        intensity = Number((_f = (_e = result.intensity) !== null && _e !== void 0 ? _e : args.intensity) !== null && _f !== void 0 ? _f : 0);
                        return [2 /*return*/, "Built 2D weather system at ".concat(weatherPath, " preset=").concat(preset, " intensity=").concat(intensity.toFixed(2), " [").concat(status_73, "]")];
                    case 3:
                        error_76 = _g.sent();
                        throw new Error("Failed to build weather system 2D: ".concat(error_76.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_weather_step_2d',
        description: 'Advance one iterative weather step for a 2D weather rig with smooth intensity transitions and optional lightning trigger',
        parameters: z.object({
            weather_path: z.string()
                .describe('Path to the weather root node'),
            target_preset: z.string().optional(),
            target_intensity: z.number().min(0).max(1).optional(),
            delta: z.number().positive().optional(),
            transition_rate: z.number().positive().optional(),
            area_size: vector2ParamSchema.optional(),
            wind_direction: vector2ParamSchema.optional(),
            wind_strength: z.number().min(0).max(1).optional(),
            precipitation_mode: z.enum(['none', 'rain', 'snow', 'ash']).optional(),
            precipitation_intensity_scale: z.number().min(0).max(2).optional(),
            max_particles: z.number().int().nonnegative().optional(),
            particle_lifetime: z.number().positive().optional(),
            particle_speed_min: z.number().nonnegative().optional(),
            particle_speed_max: z.number().nonnegative().optional(),
            spread_degrees: z.number().min(0).max(180).optional(),
            gravity_strength: z.number().nonnegative().optional(),
            particle_scale_min: vector2ParamSchema.optional(),
            particle_scale_max: vector2ParamSchema.optional(),
            precipitation_color: z.any().optional(),
            enable_precipitation: z.boolean().optional(),
            precipitation_path: z.string().optional(),
            fog_density: z.number().min(0).max(1).optional(),
            fog_color: z.any().optional(),
            enable_fog: z.boolean().optional(),
            fog_overlay_path: z.string().optional(),
            ambient_color: z.any().optional(),
            enable_ambient_modulate: z.boolean().optional(),
            ambient_modulate_path: z.string().optional(),
            lightning_enabled: z.boolean().optional(),
            lightning_chance: z.number().min(0).max(1).optional(),
            lightning_flash_strength: z.number().min(0).max(1).optional(),
            lightning_decay: z.number().positive().optional(),
            lightning_color: z.any().optional(),
            enable_lightning_overlay: z.boolean().optional(),
            lightning_overlay_path: z.string().optional(),
            trigger_lightning: z.boolean().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_74, preset, intensity, emitting, error_77;
            var _a, _b, _c, _d, _e, _f;
            return __generator(this, function (_g) {
                switch (_g.label) {
                    case 0:
                        godot = getGodotConnection();
                        _g.label = 1;
                    case 1:
                        _g.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_weather_step_2d', args)];
                    case 2:
                        result = _g.sent();
                        status_74 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        preset = String((_c = (_b = result.preset) !== null && _b !== void 0 ? _b : args.target_preset) !== null && _c !== void 0 ? _c : 'unknown');
                        intensity = Number((_e = (_d = result.intensity) !== null && _d !== void 0 ? _d : args.target_intensity) !== null && _e !== void 0 ? _e : 0);
                        emitting = Boolean((_f = result.precipitation_emitting) !== null && _f !== void 0 ? _f : false);
                        return [2 /*return*/, "Simulated 2D weather step for ".concat(args.weather_path, " preset=").concat(preset, " intensity=").concat(intensity.toFixed(2), " emitting=").concat(emitting, " [").concat(status_74, "]")];
                    case 3:
                        error_77 = _g.sent();
                        throw new Error("Failed to simulate weather step 2D: ".concat(error_77.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_water_current_step_2d',
        description: 'Apply one water current/buoyancy simulation step to a Node2D body against a 2D water volume',
        parameters: z.object({
            water_path: z.string()
                .describe('Path to the 2D water root node'),
            body_path: z.string()
                .describe('Path to the Node2D body to update'),
            size: vector2ParamSchema.optional()
                .describe('Optional water size override when metadata is missing'),
            flow_direction: vector2ParamSchema.optional(),
            flow_speed: z.number().optional(),
            buoyancy: z.number().optional(),
            drag: z.number().nonnegative().optional(),
            delta: z.number().positive().optional(),
            flow_scale: z.number().optional(),
            buoyancy_scale: z.number().optional(),
            drag_scale: z.number().nonnegative().optional(),
            sink_bias: z.number().optional(),
            clamp_speed: z.number().nonnegative().optional(),
            apply_position: z.boolean().optional(),
            require_inside: z.boolean().optional(),
            current_velocity: vector2ParamSchema.optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_75, inside, submersion, error_78;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_water_current_step_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_75 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        inside = Boolean((_b = result.inside_water) !== null && _b !== void 0 ? _b : false);
                        submersion = Number((_c = result.submersion) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Simulated 2D water step for ".concat(args.body_path, " in ").concat(args.water_path, " (inside=").concat(inside, ", submersion=").concat(submersion.toFixed(2), ") [").concat(status_75, "]")];
                    case 3:
                        error_78 = _d.sent();
                        throw new Error("Failed to simulate 2D water current step: ".concat(error_78.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'simulate_water_current_step_3d',
        description: 'Apply one water current/buoyancy simulation step to a Node3D body against a 3D water volume',
        parameters: z.object({
            water_path: z.string()
                .describe('Path to the 3D water root node'),
            body_path: z.string()
                .describe('Path to the Node3D body to update'),
            size: vector2ParamSchema.optional()
                .describe('Optional water XZ size override when metadata is missing'),
            depth: z.number().positive().optional(),
            flow_direction: vector2ParamSchema.optional(),
            flow_speed: z.number().optional(),
            buoyancy: z.number().optional(),
            drag: z.number().nonnegative().optional(),
            delta: z.number().positive().optional(),
            flow_scale: z.number().optional(),
            buoyancy_scale: z.number().optional(),
            drag_scale: z.number().nonnegative().optional(),
            sink_bias: z.number().optional(),
            clamp_speed: z.number().nonnegative().optional(),
            apply_position: z.boolean().optional(),
            require_inside: z.boolean().optional(),
            preserve_vertical_velocity: z.boolean().optional(),
            current_velocity: vector3ParamSchema.optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_76, inside, submersion, error_79;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('simulate_water_current_step_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_76 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        inside = Boolean((_b = result.inside_water) !== null && _b !== void 0 ? _b : false);
                        submersion = Number((_c = result.submersion) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Simulated 3D water step for ".concat(args.body_path, " in ").concat(args.water_path, " (inside=").concat(inside, ", submersion=").concat(submersion.toFixed(2), ") [").concat(status_76, "]")];
                    case 3:
                        error_79 = _d.sent();
                        throw new Error("Failed to simulate 3D water current step: ".concat(error_79.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'settle_sand_field_3d',
        description: 'Apply a settling pass to a sand MultiMesh field to quickly iterate dune/terrain style granular layouts',
        parameters: z.object({
            field_path: z.string()
                .describe('Path to the sand field Node3D root'),
            grains_path: z.string().optional()
                .describe('Optional explicit path to the MultiMeshInstance3D grains node'),
            size: vector3ParamSchema.optional()
                .describe('Optional bounds override for clamping settled grains'),
            iterations: z.number().int().positive().optional(),
            settle_strength: z.number().nonnegative().optional(),
            horizontal_jitter: z.number().nonnegative().optional(),
            downward_bias: z.number().nonnegative().optional(),
            keep_bounds: z.boolean().optional(),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_77, moved, total, error_80;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('settle_sand_field_3d', args)];
                    case 2:
                        result = _d.sent();
                        status_77 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        moved = Number((_b = result.moved_instances) !== null && _b !== void 0 ? _b : 0);
                        total = Number((_c = result.instance_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Settled sand field ".concat(args.field_path, " with ").concat(moved, "/").concat(total, " moved instances [").concat(status_77, "]")];
                    case 3:
                        error_80 = _d.sent();
                        throw new Error("Failed to settle sand field 3D: ".concat(error_80.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_stage_blockout_2d',
        description: 'Generate a 2D stage blockout with StaticBody2D colliders and optional Polygon2D visuals',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated stage root (defaults to "/root")'),
            stage_name: z.string().optional()
                .describe('Name for the generated stage root node'),
            blocks: z.array(z.object({
                name: z.string().optional(),
                position: vector2ParamSchema.optional(),
                size: vector2ParamSchema.optional(),
                collision_layer: z.number().int().optional(),
                collision_mask: z.number().int().optional(),
                color: z.any().optional(),
            })).min(1)
                .describe('Block descriptors with position and size'),
            create_visuals: z.boolean().optional()
                .describe('Create Polygon2D visuals for each block (default true)'),
            collision_layer: z.number().int().optional()
                .describe('Default collision layer used when a block does not override it'),
            collision_mask: z.number().int().optional()
                .describe('Default collision mask used when a block does not override it'),
            default_color: z.any().optional()
                .describe('Default Polygon2D color used when a block does not provide color'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_78, stagePath, count, error_81;
            var _a, _b, _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_stage_blockout_2d', args)];
                    case 2:
                        result = _d.sent();
                        status_78 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        stagePath = (_b = result.stage_path) !== null && _b !== void 0 ? _b : 'unknown';
                        count = Number((_c = result.block_count) !== null && _c !== void 0 ? _c : 0);
                        return [2 /*return*/, "Built 2D stage blockout at ".concat(stagePath, " with ").concat(count, " block(s) [").concat(status_78, "]")];
                    case 3:
                        error_81 = _d.sent();
                        throw new Error("Failed to build 2D stage blockout: ".concat(error_81.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_hud_ui_2d',
        description: 'Generate a reusable 2D HUD scaffold (CanvasLayer + labels/button) for fast UI iteration',
        parameters: z.object({
            parent_path: z.string().optional()
                .describe('Parent node path for the generated HUD CanvasLayer (defaults to "/root")'),
            hud_name: z.string().optional()
                .describe('Name for the HUD root node'),
            include_health: z.boolean().optional(),
            include_score: z.boolean().optional(),
            include_objective: z.boolean().optional(),
            include_message: z.boolean().optional(),
            include_pause_button: z.boolean().optional(),
            margin: z.number().int().nonnegative().optional(),
            spacing: z.number().int().nonnegative().optional(),
            health_text: z.string().optional(),
            score_text: z.string().optional(),
            objective_text: z.string().optional(),
            message_text: z.string().optional(),
            pause_text: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_79, hudPath, labelCount, error_82;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_hud_ui_2d', args)];
                    case 2:
                        result = _c.sent();
                        status_79 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        hudPath = (_b = result.hud_path) !== null && _b !== void 0 ? _b : 'unknown';
                        labelCount = Array.isArray(result.labels) ? result.labels.length : 0;
                        return [2 /*return*/, "Built HUD UI at ".concat(hudPath, " with ").concat(labelCount, " label(s) [").concat(status_79, "]")];
                    case 3:
                        error_82 = _c.sent();
                        throw new Error("Failed to build HUD UI: ".concat(error_82.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'author_enemy_ai_2d',
        description: 'Author a 2D enemy AI scaffold (navigation, vision sensor, cooldown timer, metadata, and signal wiring)',
        parameters: z.object({
            enemy_path: z.string()
                .describe('Path to the CharacterBody2D enemy node'),
            create_navigation_agent: z.boolean().optional(),
            create_vision_area: z.boolean().optional(),
            create_attack_timer: z.boolean().optional(),
            connect_signals: z.boolean().optional(),
            movement_speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            attack_cooldown: z.number().positive().optional(),
            vision_radius: z.number().positive().optional(),
            detection_group: z.string().optional(),
            navigation_agent_name: z.string().optional(),
            navigation_max_speed: z.number().nonnegative().optional(),
            path_desired_distance: z.number().nonnegative().optional(),
            target_desired_distance: z.number().nonnegative().optional(),
            avoidance_enabled: z.boolean().optional(),
            neighbor_distance: z.number().nonnegative().optional(),
            max_neighbors: z.number().int().nonnegative().optional(),
            time_horizon: z.number().nonnegative().optional(),
            time_horizon_agents: z.number().nonnegative().optional(),
            time_horizon_obstacles: z.number().nonnegative().optional(),
            vision_area_name: z.string().optional(),
            vision_collision_layer: z.number().int().optional(),
            vision_collision_mask: z.number().int().optional(),
            vision_offset: vector2ParamSchema.optional(),
            attack_timer_name: z.string().optional(),
            target_path: z.string().optional(),
            patrol_loop: z.boolean().optional(),
            patrol_points: z.array(vector2ParamSchema).optional(),
            signal_target_path: z.string().optional(),
            vision_entered_method: z.string().optional(),
            vision_exited_method: z.string().optional(),
            attack_timeout_method: z.string().optional(),
            signal_deferred: z.boolean().optional(),
            signal_one_shot: z.boolean().optional(),
            signal_reference_counted: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_80, createdCount, signalCount, error_83;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('author_enemy_ai_2d', args)];
                    case 2:
                        result = _b.sent();
                        status_80 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        createdCount = Array.isArray(result.created_nodes) ? result.created_nodes.length : 0;
                        signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
                        return [2 /*return*/, "Authored enemy AI 2D for ".concat(args.enemy_path, ": ").concat(createdCount, " created node(s), ").concat(signalCount, " signal wiring change(s) [").concat(status_80, "]")];
                    case 3:
                        error_83 = _b.sent();
                        throw new Error("Failed to author enemy AI 2D: ".concat(error_83.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'author_enemy_ai_3d',
        description: 'Author a 3D enemy AI scaffold (navigation, vision sensor, cooldown timer, metadata, and signal wiring)',
        parameters: z.object({
            enemy_path: z.string()
                .describe('Path to the CharacterBody3D enemy node'),
            create_navigation_agent: z.boolean().optional(),
            create_vision_area: z.boolean().optional(),
            create_attack_timer: z.boolean().optional(),
            connect_signals: z.boolean().optional(),
            movement_speed: z.number().nonnegative().optional(),
            acceleration: z.number().nonnegative().optional(),
            attack_cooldown: z.number().positive().optional(),
            vision_radius: z.number().positive().optional(),
            detection_group: z.string().optional(),
            navigation_agent_name: z.string().optional(),
            navigation_max_speed: z.number().nonnegative().optional(),
            path_desired_distance: z.number().nonnegative().optional(),
            target_desired_distance: z.number().nonnegative().optional(),
            avoidance_enabled: z.boolean().optional(),
            neighbor_distance: z.number().nonnegative().optional(),
            max_neighbors: z.number().int().nonnegative().optional(),
            agent_radius: z.number().nonnegative().optional(),
            agent_height: z.number().nonnegative().optional(),
            vision_area_name: z.string().optional(),
            vision_collision_layer: z.number().int().optional(),
            vision_collision_mask: z.number().int().optional(),
            vision_offset: vector3ParamSchema.optional(),
            attack_timer_name: z.string().optional(),
            target_path: z.string().optional(),
            patrol_loop: z.boolean().optional(),
            patrol_points: z.array(vector3ParamSchema).optional(),
            signal_target_path: z.string().optional(),
            vision_entered_method: z.string().optional(),
            vision_exited_method: z.string().optional(),
            attack_timeout_method: z.string().optional(),
            signal_deferred: z.boolean().optional(),
            signal_one_shot: z.boolean().optional(),
            signal_reference_counted: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_81, createdCount, signalCount, error_84;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('author_enemy_ai_3d', args)];
                    case 2:
                        result = _b.sent();
                        status_81 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        createdCount = Array.isArray(result.created_nodes) ? result.created_nodes.length : 0;
                        signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
                        return [2 /*return*/, "Authored enemy AI 3D for ".concat(args.enemy_path, ": ").concat(createdCount, " created node(s), ").concat(signalCount, " signal wiring change(s) [").concat(status_81, "]")];
                    case 3:
                        error_84 = _b.sent();
                        throw new Error("Failed to author enemy AI 3D: ".concat(error_84.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'build_menu_ui_flow_2d',
        description: 'Generate a complete menu flow scaffold (main/pause/game-over) and optional button signal wiring',
        parameters: z.object({
            parent_path: z.string().optional(),
            flow_name: z.string().optional(),
            include_pause_menu: z.boolean().optional(),
            include_game_over_menu: z.boolean().optional(),
            create_background: z.boolean().optional(),
            background_color: z.any().optional(),
            panel_size: vector2ParamSchema.optional(),
            title_text: z.string().optional(),
            start_text: z.string().optional(),
            quit_text: z.string().optional(),
            pause_title_text: z.string().optional(),
            resume_text: z.string().optional(),
            pause_restart_text: z.string().optional(),
            pause_quit_text: z.string().optional(),
            game_over_title_text: z.string().optional(),
            retry_text: z.string().optional(),
            game_over_quit_text: z.string().optional(),
            connect_signals: z.boolean().optional(),
            controller_path: z.string().optional(),
            start_pressed_method: z.string().optional(),
            quit_pressed_method: z.string().optional(),
            resume_pressed_method: z.string().optional(),
            pause_restart_pressed_method: z.string().optional(),
            pause_quit_pressed_method: z.string().optional(),
            retry_pressed_method: z.string().optional(),
            game_over_quit_pressed_method: z.string().optional(),
            signal_deferred: z.boolean().optional(),
            signal_one_shot: z.boolean().optional(),
            signal_reference_counted: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_82, flowPath, signalCount, error_85;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('build_menu_ui_flow_2d', args)];
                    case 2:
                        result = _c.sent();
                        status_82 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        flowPath = (_b = result.flow_path) !== null && _b !== void 0 ? _b : 'unknown';
                        signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
                        return [2 /*return*/, "Built menu UI flow at ".concat(flowPath, " with ").concat(signalCount, " signal wiring change(s) [").concat(status_82, "]")];
                    case 3:
                        error_85 = _c.sent();
                        throw new Error("Failed to build menu UI flow 2D: ".concat(error_85.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'set_menu_ui_flow_state',
        description: 'Switch a generated menu flow between main, pause, game-over, or hidden states',
        parameters: z.object({
            flow_path: z.string()
                .describe('Path to the menu flow root node'),
            state: z.enum(['main', 'pause', 'game_over', 'gameover', 'hidden'])
                .describe('Menu state to display'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, status_83, error_86;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('set_menu_ui_flow_state', args)];
                    case 2:
                        result = _b.sent();
                        status_83 = (_a = result.status) !== null && _a !== void 0 ? _a : 'committed';
                        return [2 /*return*/, "Set menu flow state for ".concat(args.flow_path, " to ").concat(args.state, " [").concat(status_83, "]")];
                    case 3:
                        error_86 = _b.sent();
                        throw new Error("Failed to set menu UI flow state: ".concat(error_86.message));
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
            var godot, result, status_84, previousName, error_87;
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
                        status_84 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_84 === 'no_change') {
                            return [2 /*return*/, "Node at ".concat(node_path, " already has the name \"").concat(new_name, "\".")];
                        }
                        previousName = (_e = (_d = result.previous_name) !== null && _d !== void 0 ? _d : node_path.split('/').pop()) !== null && _e !== void 0 ? _e : node_path;
                        return [2 /*return*/, "Renamed node ".concat(previousName, " to ").concat(result.new_name, " [").concat(status_84, "]")];
                    case 3:
                        error_87 = _f.sent();
                        throw new Error("Failed to rename node: ".concat(error_87.message));
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
            var godot, result, status_85, error_88;
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
                        status_85 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_85 === 'already_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is already in group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Added node ".concat(node_path, " to group \"").concat(group_name, "\" [").concat(status_85, "]")];
                    case 3:
                        error_88 = _d.sent();
                        throw new Error("Failed to add node to group: ".concat(error_88.message));
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
            var godot, result, status_86, error_89;
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
                        status_86 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_86 === 'not_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is not part of group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Removed node ".concat(node_path, " from group \"").concat(group_name, "\" [").concat(status_86, "]")];
                    case 3:
                        error_89 = _d.sent();
                        throw new Error("Failed to remove node from group: ".concat(error_89.message));
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
            var godot, payload, result, status_87, changeSummary, suffix, error_90;
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
                        status_87 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_87 === 'no_change') {
                            return [2 /*return*/, "Camera2D at ".concat(node_path, " already matches the requested configuration.")];
                        }
                        changeSummary = Array.isArray(result.changes)
                            ? result.changes
                                .map(function (change) { return "".concat(change.property, ": ").concat(JSON.stringify(change.value)); })
                                .join(', ')
                            : undefined;
                        suffix = changeSummary && changeSummary.length > 0 ? " (".concat(changeSummary, ")") : '';
                        return [2 /*return*/, "Configured Camera2D limits for ".concat((_d = result.node_path) !== null && _d !== void 0 ? _d : node_path, " [").concat(status_87, "]").concat(suffix)];
                    case 3:
                        error_90 = _e.sent();
                        throw new Error("Failed to configure Camera2D limits: ".concat(error_90.message));
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
            var godot, result, status_88, appliedValue, valueDescription, resolvedName, resolvedType, resolvedPath, error_91;
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
                        status_88 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        appliedValue = (_e = (_d = result.value) !== null && _d !== void 0 ? _d : result.applied_value) !== null && _e !== void 0 ? _e : value;
                        valueDescription = appliedValue === undefined ? 'inherit' : JSON.stringify(appliedValue);
                        resolvedName = (_f = result.override_name) !== null && _f !== void 0 ? _f : override_name;
                        resolvedType = (_g = result.override_type) !== null && _g !== void 0 ? _g : override_type;
                        resolvedPath = (_h = result.node_path) !== null && _h !== void 0 ? _h : node_path;
                        return [2 /*return*/, "Theme override ".concat(resolvedName, " (").concat(resolvedType, ") applied to ").concat(resolvedPath, " [").concat(status_88, "] -> ").concat(valueDescription)];
                    case 3:
                        error_91 = _j.sent();
                        throw new Error("Failed to create theme override: ".concat(error_91.message));
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
            var godot, result, status_89, stubInfo, error_92;
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
                        status_89 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        stubInfo = result.stub_created ? 'stub generated' : 'existing method';
                        return [2 /*return*/, "Connected ".concat(signal_name, " on ").concat(source_path, " -> ").concat(method_name, " [").concat(status_89, "; ").concat(stubInfo, "]")];
                    case 3:
                        error_92 = _d.sent();
                        throw new Error("Failed to wire signal handler: ".concat(error_92.message));
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
            var godot, result, status_90, updated, error_93;
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
                        status_90 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        updated = Array.isArray(result.updated_nodes) ? result.updated_nodes.length : 0;
                        return [2 /*return*/, "Applied grid layout to ".concat(container_path, " (").concat(updated, " controls) [").concat(status_90, "]")];
                    case 3:
                        error_93 = _d.sent();
                        throw new Error("Failed to layout UI grid: ".concat(error_93.message));
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
            var godot, result, issueCount, scanned, target, error_94;
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
                        error_94 = _g.sent();
                        throw new Error("Failed to validate accessibility: ".concat(error_94.message));
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
            var godot, result, groups, error_95;
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
                        error_95 = _d.sent();
                        throw new Error("Failed to list node groups: ".concat(error_95.message));
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
            var godot, result, nodes, formatted, error_96;
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
                        error_96 = _d.sent();
                        throw new Error("Failed to list nodes in group: ".concat(error_96.message));
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