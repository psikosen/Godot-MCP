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
var peerTypeSchema = z.enum(['enet', 'websocket', 'webrtc']);
var peerModeSchema = z.enum(['server', 'client']);
export var multiplayerTools = [
    {
        name: 'get_multiplayer_state',
        description: 'Return a snapshot of the active SceneTree multiplayer configuration.',
        parameters: z.object({}),
        execute: function () {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('get_multiplayer_state', {})];
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
        name: 'create_multiplayer_peer',
        description: 'Create and attach a multiplayer peer (ENet/WebSocket/WebRTC) to the active SceneTree.',
        parameters: z.object({
            peer_type: peerTypeSchema.describe('Transport to configure for the SceneTree multiplayer peer.'),
            mode: peerModeSchema
                .default('server')
                .describe('Create the peer in server or client mode, depending on the desired topology.'),
            port: z
                .number()
                .int()
                .optional()
                .describe('Listening port for ENet/WebSocket servers or destination port for ENet clients.'),
            max_clients: z
                .number()
                .int()
                .optional()
                .describe('Maximum concurrent clients when creating an ENet server.'),
            address: z
                .string()
                .optional()
                .describe('Remote address for ENet clients (ignored for other peer types).'),
            url: z
                .string()
                .url()
                .optional()
                .describe('WebSocket URL when configuring a WebSocket client.'),
            protocols: z
                .array(z.string())
                .optional()
                .describe('Optional WebSocket subprotocols to register for server transports.'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var peer_type = _b.peer_type, mode = _b.mode, port = _b.port, max_clients = _b.max_clients, address = _b.address, url = _b.url, protocols = _b.protocols;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = {
                                peer_type: peer_type,
                                mode: mode,
                            };
                            if (port !== undefined) {
                                payload.port = port;
                            }
                            if (max_clients !== undefined) {
                                payload.max_clients = max_clients;
                            }
                            if (address !== undefined) {
                                payload.address = address;
                            }
                            if (url !== undefined) {
                                payload.url = url;
                            }
                            if (protocols !== undefined) {
                                payload.protocols = protocols;
                            }
                            return [4 /*yield*/, godot.sendCommand('create_multiplayer_peer', payload)];
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
        name: 'teardown_multiplayer_peer',
        description: 'Disconnect and clear the SceneTree multiplayer peer, returning to single-player mode.',
        parameters: z.object({}),
        execute: function () {
            return __awaiter(this, void 0, void 0, function () {
                var godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('teardown_multiplayer_peer', {})];
                        case 1:
                            result = _a.sent();
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
        name: 'spawn_multiplayer_scene',
        description: 'Instantiate a PackedScene for multiplayer playtests and optionally assign authority.',
        parameters: z.object({
            scene_path: z
                .string()
                .min(1)
                .describe('PackedScene path to instantiate (e.g. res://scenes/level.tscn).'),
            parent_path: z
                .string()
                .optional()
                .describe('Parent node path where the new instance should be added. Defaults to /root.'),
            owner_peer_id: z
                .number()
                .int()
                .optional()
                .describe('Peer ID to assign as the multiplayer authority on the spawned instance.'),
        }),
        execute: function (_a) {
            return __awaiter(this, arguments, void 0, function (_b) {
                var godot, payload, result;
                var scene_path = _b.scene_path, parent_path = _b.parent_path, owner_peer_id = _b.owner_peer_id;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0:
                            godot = getGodotConnection();
                            payload = { scene_path: scene_path };
                            if (parent_path !== undefined) {
                                payload.parent_path = parent_path;
                            }
                            if (owner_peer_id !== undefined) {
                                payload.owner_peer_id = owner_peer_id;
                            }
                            return [4 /*yield*/, godot.sendCommand('spawn_multiplayer_scene', payload)];
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
//# sourceMappingURL=multiplayer_tools.js.map