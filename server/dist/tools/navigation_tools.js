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
 * Utility to format a vector dictionary into readable string output.
 */
function formatVector(value) {
    if (!value) {
        return 'n/a';
    }
    var keys = Object.keys(value);
    if (keys.includes('x')) {
        var coords = keys.map(function (key) { return "".concat(key, ": ").concat(value[key]); }).join(', ');
        return "{ ".concat(coords, " }");
    }
    return JSON.stringify(value);
}
/**
 * Utility to format navigation region summaries.
 */
function formatNavigationRegions(regions) {
    if (!regions || regions.length === 0) {
        return 'No navigation regions found.';
    }
    return regions
        .map(function (region) {
        var details = [
            "Path: ".concat(region.node_path),
            "Dimension: ".concat(region.dimension),
            "Enabled: ".concat(region.enabled),
            "Layers: ".concat(region.navigation_layers),
            "Travel Cost: ".concat(region.travel_cost),
            "Enter Cost: ".concat(region.enter_cost),
            "Edge Connections: ".concat(region.use_edge_connections),
        ];
        if (region.resource) {
            var resource = region.resource;
            details.push('Resource:', "  Path: ".concat(resource.resource_path || '<local>'), "  Vertex Count: ".concat(resource.vertex_count), "  Polygon Count: ".concat(resource.polygon_count));
            if ('agent_radius' in resource) {
                details.push("  Agent Radius: ".concat(resource.agent_radius), "  Cell Size: ".concat(resource.cell_size), "  Cell Height: ".concat(resource.cell_height));
            }
        }
        return details.join('\n');
    })
        .join('\n\n');
}
/**
 * Utility to format navigation agent summaries.
 */
function formatNavigationAgents(agents) {
    if (!agents || agents.length === 0) {
        return 'No navigation agents found.';
    }
    return agents
        .map(function (agent) {
        var details = [
            "Path: ".concat(agent.node_path),
            "Dimension: ".concat(agent.dimension),
            "Radius: ".concat(agent.radius),
            "Max Speed: ".concat(agent.max_speed),
            "Max Acceleration: ".concat(agent.max_acceleration),
            "Avoidance Enabled: ".concat(agent.avoidance_enabled),
            "Max Neighbors: ".concat(agent.max_neighbors),
            "Neighbor Max Distance: ".concat(agent.neighbor_max_distance),
            "Target Position: ".concat(formatVector(agent.target_position)),
            "Current Position: ".concat(formatVector(agent.position)),
            "Velocity: ".concat(formatVector(agent.velocity)),
        ];
        if ('height' in agent) {
            details.push("Height: ".concat(agent.height));
        }
        details.push("Path Desired Distance: ".concat(agent.path_desired_distance), "Target Desired Distance: ".concat(agent.target_desired_distance));
        return details.join('\n');
    })
        .join('\n\n');
}
/**
 * Navigation-focused MCP tools that align with Godot's navigation modules.
 */
export var navigationTools = [
    {
        name: 'list_navigation_maps',
        description: 'List navigation regions in the active scene with summary details.',
        parameters: z
            .object({
            dimension: z.enum(['2d', '3d', 'both']).optional()
                .describe('Filter regions by dimension (2d, 3d, or both). Defaults to both.'),
        })
            .default({}),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, summary, error_1;
            var _c;
            var _d = _b.dimension, dimension = _d === void 0 ? 'both' : _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_navigation_maps', {
                                dimension: dimension,
                            })];
                    case 2:
                        result = _e.sent();
                        summary = formatNavigationRegions((_c = result.regions) !== null && _c !== void 0 ? _c : []);
                        return [2 /*return*/, "Navigation regions (".concat(dimension, "):\n\n").concat(summary)];
                    case 3:
                        error_1 = _e.sent();
                        throw new Error("Failed to list navigation regions: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'list_navigation_agents',
        description: 'Inspect navigation agents in the active scene and view avoidance parameters.',
        parameters: z
            .object({
            dimension: z.enum(['2d', '3d', 'both']).optional()
                .describe('Filter agents by dimension (2d, 3d, or both). Defaults to both.'),
        })
            .default({}),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, summary, error_2;
            var _c;
            var _d = _b.dimension, dimension = _d === void 0 ? 'both' : _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('list_navigation_agents', {
                                dimension: dimension,
                            })];
                    case 2:
                        result = _e.sent();
                        summary = formatNavigationAgents((_c = result.agents) !== null && _c !== void 0 ? _c : []);
                        return [2 /*return*/, "Navigation agents (".concat(dimension, "):\n\n").concat(summary)];
                    case 3:
                        error_2 = _e.sent();
                        throw new Error("Failed to list navigation agents: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'bake_navigation_region',
        description: 'Trigger baking for a NavigationRegion2D or NavigationRegion3D.',
        parameters: z.object({
            node_path: z
                .string()
                .describe('Path to the navigation region node (e.g. "/root/Main/NavigationRegion3D").'),
            on_thread: z
                .boolean()
                .optional()
                .describe('If true (default), baking occurs on a worker thread.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, dimension, error_3;
            var _c;
            var node_path = _b.node_path, _d = _b.on_thread, on_thread = _d === void 0 ? true : _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('bake_navigation_region', {
                                node_path: node_path,
                                on_thread: on_thread,
                            })];
                    case 2:
                        result = _e.sent();
                        dimension = String((_c = result.dimension) !== null && _c !== void 0 ? _c : 'unknown');
                        return [2 /*return*/, "Started ".concat(dimension.toUpperCase(), " navigation bake for ").concat(result.node_path, " (threaded: ").concat(result.on_thread, ").")];
                    case 3:
                        error_3 = _e.sent();
                        throw new Error("Failed to bake navigation region: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'update_navigation_region',
        description: 'Update properties on a navigation region node with undo/redo support.',
        parameters: z.object({
            node_path: z
                .string()
                .describe('Path to the NavigationRegion2D/3D node to modify.'),
            properties: z
                .record(z.any())
                .describe('Dictionary of property names to new values.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing scene transaction identifier to batch changes.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_1, error_4;
            var _c;
            var node_path = _b.node_path, properties = _b.properties, transaction_id = _b.transaction_id;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        godot = getGodotConnection();
                        _d.label = 1;
                    case 1:
                        _d.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('update_navigation_region', {
                                node_path: node_path,
                                properties: properties,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _d.sent();
                        status_1 = (_c = result.status) !== null && _c !== void 0 ? _c : 'committed';
                        return [2 /*return*/, "Updated navigation region ".concat(result.node_path, " (").concat(status_1, "). Properties: ").concat(Object.keys(properties).join(', '))];
                    case 3:
                        error_4 = _d.sent();
                        throw new Error("Failed to update navigation region: ".concat(error_4.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'update_navigation_resource',
        description: 'Modify the NavigationPolygon or NavigationMesh resource attached to a region.',
        parameters: z.object({
            node_path: z
                .string()
                .describe('Path to the navigation region whose resource should be edited.'),
            properties: z
                .record(z.any())
                .describe('Dictionary of resource property names to new values.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing scene transaction identifier to batch changes.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_2, dimension, error_5;
            var _c, _d;
            var node_path = _b.node_path, properties = _b.properties, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('update_navigation_resource', {
                                node_path: node_path,
                                properties: properties,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_2 = String((_c = result.status) !== null && _c !== void 0 ? _c : 'committed');
                        dimension = String((_d = result.dimension) !== null && _d !== void 0 ? _d : 'unknown');
                        return [2 /*return*/, "Updated ".concat(dimension.toUpperCase(), " navigation resource for ").concat(result.node_path, " (").concat(status_2, ").")];
                    case 3:
                        error_5 = _e.sent();
                        throw new Error("Failed to update navigation resource: ".concat(error_5.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'update_navigation_agent',
        description: 'Adjust NavigationAgent2D/3D parameters with undo/redo support.',
        parameters: z.object({
            node_path: z
                .string()
                .describe('Path to the NavigationAgent2D/3D node to modify.'),
            properties: z
                .record(z.any())
                .describe('Dictionary of agent property names to new values.'),
            transaction_id: z
                .string()
                .optional()
                .describe('Existing scene transaction identifier to batch changes.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, result, status_3, dimension, error_6;
            var _c, _d;
            var node_path = _b.node_path, properties = _b.properties, transaction_id = _b.transaction_id;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('update_navigation_agent', {
                                node_path: node_path,
                                properties: properties,
                                transaction_id: transaction_id,
                            })];
                    case 2:
                        result = _e.sent();
                        status_3 = String((_c = result.status) !== null && _c !== void 0 ? _c : 'committed');
                        dimension = String((_d = result.dimension) !== null && _d !== void 0 ? _d : 'unknown');
                        return [2 /*return*/, "Updated ".concat(dimension.toUpperCase(), " navigation agent ").concat(result.node_path, " (").concat(status_3, "). Properties: ").concat(Object.keys(properties).join(', '))];
                    case 3:
                        error_6 = _e.sent();
                        throw new Error("Failed to update navigation agent: ".concat(error_6.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'synchronize_navmesh_with_tilemap',
        description: 'Rebake TileMap navigation layers and optional navigation regions to keep pathfinding in sync.',
        parameters: z.object({
            tilemap_path: z
                .string()
                .describe('Path to the TileMap node whose navigation data should be synchronized.'),
            region_paths: z
                .array(z.string())
                .optional()
                .describe('Optional navigation region node paths to rebake after updating the TileMap.'),
            on_thread: z
                .boolean()
                .optional()
                .describe('Whether navigation baking should run on a worker thread (defaults to true).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var godot, payload, result, rebaked, invalid, navigationUpdated, lines, error_7;
            var _c;
            var tilemap_path = _b.tilemap_path, region_paths = _b.region_paths, _d = _b.on_thread, on_thread = _d === void 0 ? true : _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {
                            tilemap_path: tilemap_path,
                            on_thread: on_thread,
                        };
                        if (region_paths && region_paths.length > 0) {
                            payload.region_paths = region_paths;
                        }
                        _e.label = 1;
                    case 1:
                        _e.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('synchronize_navmesh_with_tilemap', payload)];
                    case 2:
                        result = _e.sent();
                        rebaked = Array.isArray(result.rebaked_regions) ? result.rebaked_regions : [];
                        invalid = Array.isArray(result.invalid_regions) ? result.invalid_regions : [];
                        navigationUpdated = Boolean(result.navigation_map_updated);
                        lines = [
                            "Synchronized TileMap navigation for ".concat((_c = result.tilemap_path) !== null && _c !== void 0 ? _c : tilemap_path),
                            "Rebaked regions: ".concat(rebaked.length > 0 ? rebaked.join(', ') : 'none'),
                            "Invalid regions: ".concat(invalid.length > 0 ? invalid.join(', ') : 'none'),
                            "Navigation map updated: ".concat(navigationUpdated ? 'yes' : 'no'),
                        ];
                        return [2 /*return*/, lines.join('\n')];
                    case 3:
                        error_7 = _e.sent();
                        throw new Error("Failed to synchronize TileMap navigation: ".concat(error_7.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=navigation_tools.js.map