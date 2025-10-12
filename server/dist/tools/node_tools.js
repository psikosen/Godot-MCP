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
            var godot, result, status_4, previousName, error_6;
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
                        status_4 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_4 === 'no_change') {
                            return [2 /*return*/, "Node at ".concat(node_path, " already has the name \"").concat(new_name, "\".")];
                        }
                        previousName = (_e = (_d = result.previous_name) !== null && _d !== void 0 ? _d : node_path.split('/').pop()) !== null && _e !== void 0 ? _e : node_path;
                        return [2 /*return*/, "Renamed node ".concat(previousName, " to ").concat(result.new_name, " [").concat(status_4, "]")];
                    case 3:
                        error_6 = _f.sent();
                        throw new Error("Failed to rename node: ".concat(error_6.message));
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
            var godot, result, status_5, error_7;
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
                        status_5 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_5 === 'already_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is already in group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Added node ".concat(node_path, " to group \"").concat(group_name, "\" [").concat(status_5, "]")];
                    case 3:
                        error_7 = _d.sent();
                        throw new Error("Failed to add node to group: ".concat(error_7.message));
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
            var godot, result, status_6, error_8;
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
                        status_6 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_6 === 'not_member') {
                            return [2 /*return*/, "Node at ".concat(node_path, " is not part of group \"").concat(group_name, "\".")];
                        }
                        return [2 /*return*/, "Removed node ".concat(node_path, " from group \"").concat(group_name, "\" [").concat(status_6, "]")];
                    case 3:
                        error_8 = _d.sent();
                        throw new Error("Failed to remove node from group: ".concat(error_8.message));
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
            var godot, payload, result, status_7, changeSummary, suffix, error_9;
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
                        status_7 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        if (status_7 === 'no_change') {
                            return [2 /*return*/, "Camera2D at ".concat(node_path, " already matches the requested configuration.")];
                        }
                        changeSummary = Array.isArray(result.changes)
                            ? result.changes
                                .map(function (change) { return "".concat(change.property, ": ").concat(JSON.stringify(change.value)); })
                                .join(', ')
                            : undefined;
                        suffix = changeSummary && changeSummary.length > 0 ? " (".concat(changeSummary, ")") : '';
                        return [2 /*return*/, "Configured Camera2D limits for ".concat((_d = result.node_path) !== null && _d !== void 0 ? _d : node_path, " [").concat(status_7, "]").concat(suffix)];
                    case 3:
                        error_9 = _e.sent();
                        throw new Error("Failed to configure Camera2D limits: ".concat(error_9.message));
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
            var godot, result, status_8, appliedValue, valueDescription, resolvedName, resolvedType, resolvedPath, error_10;
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
                        status_8 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        appliedValue = (_e = (_d = result.value) !== null && _d !== void 0 ? _d : result.applied_value) !== null && _e !== void 0 ? _e : value;
                        valueDescription = appliedValue === undefined ? 'inherit' : JSON.stringify(appliedValue);
                        resolvedName = (_f = result.override_name) !== null && _f !== void 0 ? _f : override_name;
                        resolvedType = (_g = result.override_type) !== null && _g !== void 0 ? _g : override_type;
                        resolvedPath = (_h = result.node_path) !== null && _h !== void 0 ? _h : node_path;
                        return [2 /*return*/, "Theme override ".concat(resolvedName, " (").concat(resolvedType, ") applied to ").concat(resolvedPath, " [").concat(status_8, "] -> ").concat(valueDescription)];
                    case 3:
                        error_10 = _j.sent();
                        throw new Error("Failed to create theme override: ".concat(error_10.message));
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
            var godot, result, status_9, stubInfo, error_11;
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
                        status_9 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        stubInfo = result.stub_created ? 'stub generated' : 'existing method';
                        return [2 /*return*/, "Connected ".concat(signal_name, " on ").concat(source_path, " -> ").concat(method_name, " [").concat(status_9, "; ").concat(stubInfo, "]")];
                    case 3:
                        error_11 = _d.sent();
                        throw new Error("Failed to wire signal handler: ".concat(error_11.message));
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
            var godot, result, status_10, updated, error_12;
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
                        status_10 = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
                        updated = Array.isArray(result.updated_nodes) ? result.updated_nodes.length : 0;
                        return [2 /*return*/, "Applied grid layout to ".concat(container_path, " (").concat(updated, " controls) [").concat(status_10, "]")];
                    case 3:
                        error_12 = _d.sent();
                        throw new Error("Failed to layout UI grid: ".concat(error_12.message));
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
            var godot, result, issueCount, scanned, target, error_13;
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
                        error_13 = _g.sent();
                        throw new Error("Failed to validate accessibility: ".concat(error_13.message));
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
            var godot, result, groups, error_14;
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
                        error_14 = _d.sent();
                        throw new Error("Failed to list node groups: ".concat(error_14.message));
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
            var godot, result, nodes, formatted, error_15;
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
                        error_15 = _d.sent();
                        throw new Error("Failed to list nodes in group: ".concat(error_15.message));
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