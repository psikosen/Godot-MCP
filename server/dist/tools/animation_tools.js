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
var listAnimationPlayersSchema = z
    .object({
    node_path: z
        .string()
        .min(1)
        .optional()
        .describe('Optional node path limiting the search for AnimationPlayer nodes.'),
    include_tracks: z
        .boolean()
        .default(false)
        .describe('Include per-animation track metadata when listing AnimationPlayer nodes.'),
    include_keys: z
        .boolean()
        .default(false)
        .describe('Include per-track keyframe details (time/value/transition) in the response.'),
})
    .describe('Enumerate AnimationPlayer nodes in the edited scene.');
var describeAnimationTracksSchema = z
    .object({
    node_path: z
        .string()
        .min(1)
        .optional()
        .describe('Target AnimationPlayer node path. Defaults to all players in the edited scene.'),
    include_keys: z
        .boolean()
        .default(true)
        .describe('Include keyframe timing, value, and transition data for each track.'),
})
    .describe('Inspect AnimationPlayer tracks and optional keyframe details.');
var describeAnimationStateMachinesSchema = z
    .object({
    node_path: z
        .string()
        .min(1)
        .optional()
        .describe('Optional AnimationTree node path to inspect. Defaults to all trees in the edited scene.'),
    include_nested: z
        .boolean()
        .default(true)
        .describe('Include nested state machine nodes when encountered.'),
    include_graph: z
        .boolean()
        .default(true)
        .describe('Include editor graph metadata such as node positions.'),
    include_transitions: z
        .boolean()
        .default(true)
        .describe('Include transition metadata (switch mode, advance mode, etc.).'),
})
    .describe('Surface AnimationTree state machine layout and transition metadata.');
export var animationTools = [
    {
        name: 'list_animation_players',
        description: 'List AnimationPlayer nodes and summarise their animations.',
        parameters: listAnimationPlayersSchema,
        metadata: {
            requiredRole: 'read',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = listAnimationPlayersSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('list_animation_players', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'describe_animation_tracks',
        description: 'Inspect AnimationPlayer tracks with optional keyframe payloads.',
        parameters: describeAnimationTracksSchema,
        metadata: {
            requiredRole: 'read',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = describeAnimationTracksSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('describe_animation_tracks', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'describe_animation_state_machines',
        description: 'Summarise AnimationTree state machines, transitions, and nested graphs.',
        parameters: describeAnimationStateMachinesSchema,
        metadata: {
            requiredRole: 'read',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = describeAnimationStateMachinesSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('describe_animation_state_machines', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
];
//# sourceMappingURL=animation_tools.js.map