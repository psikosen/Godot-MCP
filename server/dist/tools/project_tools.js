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
import { projectIndexer } from '../utils/project_indexer.js';
import { getGodotConnection } from '../utils/godot_connection.js';
var ENTRY_LIMIT = 5000;
var inputEventSchema = z.object({
    type: z.string()
        .describe('Input event type such as InputEventKey, key, InputEventMouseButton, mouse_button, etc.'),
}).passthrough();
export var projectTools = [
    {
        name: 'refresh_project_index',
        description: 'Refresh the cached project structure index and return summary statistics.',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var snapshot;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, projectIndexer.refresh()];
                    case 1:
                        snapshot = _a.sent();
                        return [2 /*return*/, JSON.stringify({
                                generated_at: snapshot.generatedAt,
                                stats: snapshot.stats,
                                root_entries: snapshot.root,
                            }, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'query_project_index',
        description: 'Query the cached project index using glob-style patterns.',
        parameters: z.object({
            pattern: z.union([
                z.string(),
                z.array(z.string()).min(1),
            ]).describe('Glob pattern or list of patterns (supports * and **).'),
            include_directories: z.boolean()
                .optional()
                .describe('Whether to include directories in the results (default true).'),
            limit: z.number()
                .int()
                .positive()
                .max(ENTRY_LIMIT)
                .optional()
                .describe('Maximum number of entries to return (default 200, max 5000).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var patterns, matches;
            var pattern = _b.pattern, include_directories = _b.include_directories, limit = _b.limit;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        patterns = Array.isArray(pattern) ? pattern : [pattern];
                        return [4 /*yield*/, projectIndexer.query(patterns, {
                                includeDirectories: include_directories !== null && include_directories !== void 0 ? include_directories : true,
                                limit: limit,
                            })];
                    case 1:
                        matches = _c.sent();
                        return [2 /*return*/, JSON.stringify({
                                patterns: patterns,
                                count: matches.length,
                                matches: matches,
                            }, null, 2)];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_input_actions',
        description: 'List all configured input actions from the Godot project settings.',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_input_actions', {})];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                    case 3:
                        error_1 = _a.sent();
                        throw new Error("Failed to list input actions: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_audio_buses',
        description: 'Inspect the project audio bus layout including routing, volume, and effects.',
        parameters: z.object({}),
        execute: function () { return __awaiter(void 0, void 0, void 0, function () {
            var godot, result, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_audio_buses', {})];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                    case 3:
                        error_2 = _a.sent();
                        throw new Error("Failed to list audio buses: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'configure_audio_bus',
        description: 'Modify a Godot audio bus, toggling volume, routing, and effect state with optional persistence.',
        parameters: z
            .object({
            bus_name: z
                .string()
                .min(1)
                .optional()
                .describe('Name of the audio bus to configure.'),
            bus_index: z
                .number()
                .int()
                .nonnegative()
                .optional()
                .describe('Index of the audio bus to configure.'),
            new_name: z
                .string()
                .min(1)
                .optional()
                .describe('Optional new name for the bus.'),
            volume_db: z
                .number()
                .optional()
                .describe('Set the bus volume in decibels.'),
            solo: z
                .boolean()
                .optional()
                .describe('Toggle solo state.'),
            mute: z
                .boolean()
                .optional()
                .describe('Toggle mute state.'),
            bypass_effects: z
                .boolean()
                .optional()
                .describe('Toggle bypass on the entire effect chain.'),
            send: z
                .string()
                .optional()
                .describe('Set the downstream send target bus (empty string clears).'),
            effects: z
                .array(z
                .object({
                index: z
                    .number()
                    .int()
                    .nonnegative()
                    .describe('Effect index on the target bus.'),
                enabled: z
                    .boolean()
                    .optional()
                    .describe('Enable or disable the effect at the provided index.'),
            })
                .strict())
                .optional()
                .describe('Batch toggle effect state for the bus.'),
            persist: z
                .boolean()
                .optional()
                .describe('Persist the mutated bus layout to the project default layout resource.'),
        })
            .refine(function (data) { return data.bus_name !== undefined || data.bus_index !== undefined; }, {
            message: 'Either bus_name or bus_index must be provided.',
            path: ['bus_name'],
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result, error_3;
            var bus_name = _b.bus_name, bus_index = _b.bus_index, new_name = _b.new_name, volume_db = _b.volume_db, solo = _b.solo, mute = _b.mute, bypass_effects = _b.bypass_effects, send = _b.send, effects = _b.effects, persist = _b.persist;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (bus_name !== undefined) {
                            payload.bus_name = bus_name;
                        }
                        if (bus_index !== undefined) {
                            payload.bus_index = bus_index;
                        }
                        if (new_name !== undefined) {
                            payload.new_name = new_name;
                        }
                        if (volume_db !== undefined) {
                            payload.volume_db = volume_db;
                        }
                        if (solo !== undefined) {
                            payload.solo = solo;
                        }
                        if (mute !== undefined) {
                            payload.mute = mute;
                        }
                        if (bypass_effects !== undefined) {
                            payload.bypass_effects = bypass_effects;
                        }
                        if (send !== undefined) {
                            payload.send = send;
                        }
                        if (effects !== undefined) {
                            payload.effects = effects;
                        }
                        if (persist !== undefined) {
                            payload.persist = persist;
                        }
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_audio_bus', payload)];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, JSON.stringify(result, null, 2)];
                    case 3:
                        error_3 = _c.sent();
                        throw new Error("Failed to configure audio bus: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'add_input_action',
        description: 'Create or overwrite a Godot input action with optional default events.',
        parameters: z.object({
            action_name: z.string()
                .describe('Name of the input action to create or overwrite.'),
            deadzone: z.number()
                .min(0)
                .max(1)
                .optional()
                .describe('Optional custom deadzone value (default 0.5).'),
            overwrite: z.boolean()
                .optional()
                .describe('Whether to overwrite an existing action with the same name (default false).'),
            persistent: z.boolean()
                .optional()
                .describe('Persist changes to project.godot immediately (default true).'),
            events: z.array(inputEventSchema)
                .optional()
                .describe('Optional array of input events to register with the action.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_4;
            var _c, _d;
            var action_name = _b.action_name, deadzone = _b.deadzone, overwrite = _b.overwrite, persistent = _b.persistent, events = _b.events;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('add_input_action', {
                                action_name: action_name,
                                deadzone: deadzone,
                                overwrite: overwrite,
                                persistent: persistent,
                                events: events,
                            })];
                    case 2:
                        result = _e.sent();
                        return [2 /*return*/, "Created/updated input action \"".concat(result.action_name, "\" with ").concat((_d = (_c = result.events) === null || _c === void 0 ? void 0 : _c.length) !== null && _d !== void 0 ? _d : 0, " event(s).")];
                    case 3:
                        error_4 = _e.sent();
                        throw new Error("Failed to add input action: ".concat(error_4.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'remove_input_action',
        description: 'Remove a Godot input action from the project settings.',
        parameters: z.object({
            action_name: z.string()
                .describe('Name of the input action to remove.'),
            persistent: z.boolean()
                .optional()
                .describe('Persist changes to project.godot immediately (default true).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, error_5;
            var action_name = _b.action_name, persistent = _b.persistent;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('remove_input_action', {
                                action_name: action_name,
                                persistent: persistent,
                            })];
                    case 2:
                        _c.sent();
                        return [2 /*return*/, "Removed input action \"".concat(action_name, "\".")];
                    case 3:
                        error_5 = _c.sent();
                        throw new Error("Failed to remove input action: ".concat(error_5.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'add_input_event_to_action',
        description: 'Register an additional event on an existing Godot input action.',
        parameters: z.object({
            action_name: z.string()
                .describe('Name of the input action to modify.'),
            event: inputEventSchema
                .describe('Input event definition that should be added to the action.'),
            persistent: z.boolean()
                .optional()
                .describe('Persist changes to project.godot immediately (default true).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_6;
            var action_name = _b.action_name, event = _b.event, persistent = _b.persistent;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('add_input_event_to_action', {
                                action_name: action_name,
                                event: event,
                                persistent: persistent,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Added event to action \"".concat(result.action_name, "\".")];
                    case 3:
                        error_6 = _c.sent();
                        throw new Error("Failed to add input event: ".concat(error_6.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'remove_input_event_from_action',
        description: 'Remove an event from a Godot input action by index or matching fields.',
        parameters: z.object({
            action_name: z.string()
                .describe('Name of the input action to modify.'),
            event_index: z.number()
                .int()
                .nonnegative()
                .optional()
                .describe('Index of the event to remove (0-based).'),
            event: inputEventSchema.optional()
                .describe('Event description to match for removal when index is not provided.'),
            persistent: z.boolean()
                .optional()
                .describe('Persist changes to project.godot immediately (default true).'),
        }).refine(function (data) { return data.event_index !== undefined || data.event !== undefined; }, {
            message: 'Either event_index or event must be provided to identify the input event to remove.',
            path: ['event_index'],
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, error_7;
            var action_name = _b.action_name, event_index = _b.event_index, event = _b.event, persistent = _b.persistent;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('remove_input_event_from_action', {
                                action_name: action_name,
                                event_index: event_index,
                                event: event,
                                persistent: persistent,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, "Removed event from action \"".concat(result.action_name, "\".")];
                    case 3:
                        error_7 = _c.sent();
                        throw new Error("Failed to remove input event: ".concat(error_7.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'configure_input_action_context',
        description: 'Batch manage input actions for a named context, creating, updating, or removing bindings together.',
        parameters: z.object({
            context_name: z
                .string()
                .min(1)
                .describe('Identifier for the input context to create or update.'),
            actions: z
                .array(z.object({
                name: z
                    .string()
                    .min(1)
                    .describe('Input action name to configure.'),
                events: z
                    .array(inputEventSchema)
                    .optional()
                    .describe('Input events to assign to the action.'),
                remove: z
                    .boolean()
                    .optional()
                    .describe('Remove the action from the context and Input Map.'),
                replace_events: z
                    .boolean()
                    .optional()
                    .describe('Override existing events instead of merging with them.'),
            }))
                .min(1)
                .describe('List of action definitions to apply for the context.'),
            persistent: z
                .boolean()
                .optional()
                .describe('Persist changes to ProjectSettings immediately (default true).'),
            replace_existing: z
                .boolean()
                .optional()
                .describe('Default replace behaviour for events when not specified per action.'),
            remove_missing: z
                .boolean()
                .optional()
                .describe('Remove actions from the context that are not present in the payload.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, created, updated, removed, error_8;
            var context_name = _b.context_name, actions = _b.actions, persistent = _b.persistent, replace_existing = _b.replace_existing, remove_missing = _b.remove_missing;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('configure_input_action_context', {
                                context_name: context_name,
                                actions: actions,
                                persistent: persistent,
                                replace_existing: replace_existing,
                                remove_missing: remove_missing,
                            })];
                    case 2:
                        result = _c.sent();
                        created = Array.isArray(result.created_actions) ? result.created_actions.length : 0;
                        updated = Array.isArray(result.updated_actions) ? result.updated_actions.length : 0;
                        removed = Array.isArray(result.removed_actions) ? result.removed_actions.length : 0;
                        return [2 /*return*/, "Configured input action context \"".concat(context_name, "\": ").concat(created, " created, ").concat(updated, " updated, ").concat(removed, " removed.")];
                    case 3:
                        error_8 = _c.sent();
                        throw new Error("Failed to configure input action context: ".concat(error_8.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=project_tools.js.map