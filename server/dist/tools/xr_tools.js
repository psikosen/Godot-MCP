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
var xrSettingsEntrySchema = z
    .object({
    path: z
        .string()
        .min(1)
        .describe('ProjectSettings path to update (e.g. xr/openxr/rendering).'),
    value: z.any().describe('Value written to the provided ProjectSettings path.'),
})
    .strict();
var xrSettingsSchema = z.union([
    z.array(xrSettingsEntrySchema).min(1).describe('Explicit array of { path, value } entries.'),
    z
        .record(z.any())
        .describe('Dictionary where keys map directly to ProjectSettings paths.'),
]);
export var xrTools = [
    {
        name: 'list_xr_interfaces',
        description: 'Enumerate available XR interfaces and their initialization state.',
        parameters: z.object({}),
        execute: function () {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('list_xr_interfaces', {})];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'initialize_xr_interface',
        description: 'Initialize a specific XR interface and optionally promote it to the primary interface.',
        parameters: z.object({
            interface_name: z
                .string()
                .min(1)
                .describe('XR interface name as reported by Godot (e.g. OpenXR, WebXR).'),
            make_primary: z
                .boolean()
                .optional()
                .describe('Set the XR interface as the primary interface after initialization.'),
            start_session: z
                .boolean()
                .optional()
                .describe('Request the interface to start a session when supported.'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var interface_name = _b.interface_name, make_primary = _b.make_primary, start_session = _b.start_session;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = {
                                interface_name: interface_name,
                            };
                            if (make_primary !== undefined) {
                                payload.make_primary = make_primary;
                            }
                            if (start_session !== undefined) {
                                payload.start_session = start_session;
                            }
                            return [4 /*yield*/, godot.sendCommand('initialize_xr_interface', payload)];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'shutdown_xr_interface',
        description: 'Shut down an XR interface and end its active session if one is running.',
        parameters: z.object({
            interface_name: z
                .string()
                .min(1)
                .describe('XR interface name that should be stopped.'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, result;
                var interface_name = _b.interface_name;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('shutdown_xr_interface', {
                                    interface_name: interface_name,
                                })];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'save_xr_project_settings',
        description: 'Persist XR-specific ProjectSettings entries, enabling deterministic editor setup.',
        parameters: z.object({
            settings: xrSettingsSchema,
            save: z
                .boolean()
                .optional()
                .describe('When true (default), ProjectSettings.save() is invoked after applying changes.'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var settings = _b.settings, save = _b.save;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = { settings: settings };
                            if (save !== undefined) {
                                payload.save = save;
                            }
                            return [4 /*yield*/, godot.sendCommand('save_xr_project_settings', payload)];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
        metadata: {
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=xr_tools.js.map