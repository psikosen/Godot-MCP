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
var editAnimationOperationSchema = z
    .object({
    type: z.string().min(1).describe('Operation type to apply (e.g. set_property, insert_key, rename).'),
    track_path: z.string().optional().describe('Optional animation track path used for track/key operations.'),
    track_index: z.number().int().optional().describe('Optional track index used for track/key operations.'),
    property: z.string().optional().describe('Property name for set_property operations.'),
    value: z.any().optional().describe('Value payload for property/key operations.'),
    time: z.number().optional().describe('Time value for key insertion/updating operations.'),
    duration: z.number().optional().describe('Duration for tween-style operations.'),
    key_index: z.number().int().optional().describe('Key index used by set_key/remove_key operations.'),
    new_name: z.string().optional().describe('New animation name when renaming.'),
    name: z.string().optional().describe('Optional legacy alias for new animation name.'),
})
    .passthrough();
var editAnimationSchema = z
    .object({
    player_path: z.string().min(1).describe('AnimationPlayer node path that owns the animation.'),
    animation: z.string().min(1).describe('Animation resource name to modify.'),
    operations: z
        .array(editAnimationOperationSchema)
        .min(1)
        .describe('Array of operations to apply to the animation.'),
    transaction_id: z
        .string()
        .min(1)
        .optional()
        .describe('Optional existing transaction identifier for batching edits.'),
})
    .describe('Apply structured operations to an Animation resource.');
var configureAnimationTreeSchema = z
    .object({
    tree_path: z.string().min(1).describe('AnimationTree node path to configure.'),
    properties: z
        .record(z.any())
        .optional()
        .describe('Dictionary of top-level AnimationTree properties to update.'),
    parameters: z
        .record(z.any())
        .optional()
        .describe('Dictionary of AnimationTree parameters (parameters/foo) to update.'),
    state_transitions: z
        .array(z.object({
        playback_path: z.string().optional(),
        path: z.string().optional(),
        state: z.string().optional(),
        target: z.string().optional(),
    }))
        .optional()
        .describe('Array of state machine playback updates specifying target states.'),
    transaction_id: z
        .string()
        .min(1)
        .optional()
        .describe('Optional existing transaction identifier for batching edits.'),
})
    .describe('Configure AnimationTree properties, parameters, and optional state transitions.');
var bakeSkeletonPoseSchema = z
    .object({
    skeleton_path: z.string().min(1).describe('Skeleton2D or Skeleton3D node path to sample.'),
    player_path: z.string().min(1).describe('AnimationPlayer node path where the pose should be stored.'),
    animation: z.string().min(1).describe('Animation name that should receive the baked pose.'),
    bones: z
        .array(z.string().min(1))
        .optional()
        .describe('Optional subset of bones to capture. Defaults to all bones.'),
    space: z
        .enum(['local', 'global'])
        .default('local')
        .describe('Whether to capture bone poses in local or global space.'),
    overwrite: z
        .boolean()
        .default(true)
        .describe('If true, existing keys for the tracked bones are removed before baking.'),
    time: z
        .number()
        .default(0)
        .describe('Time (seconds) at which the baked keys should be inserted.'),
    transaction_id: z.string().min(1).optional(),
})
    .describe('Bake the current skeleton pose into an Animation resource.');
var tweenSequenceStepSchema = z
    .object({
    target_path: z.string().optional().describe('Optional node path whose property should be animated.'),
    property: z.string().min(1).describe('Property name to animate.'),
    to: z.any().optional().describe('Target value for the property.'),
    value: z.any().optional().describe('Alias for target value.'),
    from: z.any().optional().describe('Optional starting value override.'),
    start: z.any().optional().describe('Alias for starting value.'),
    duration: z.number().nonnegative().default(0).describe('Duration of the tween segment in seconds.'),
    delay: z.number().nonnegative().default(0).describe('Delay before this tween segment starts.'),
    interpolation: z
        .string()
        .optional()
        .describe('Interpolation mode (linear, cubic, nearest).'),
    ease: z.string().optional().describe('Alias for interpolation mode.'),
})
    .describe('Single tween step describing an animated property segment.');
var generateTweenSequenceSchema = z
    .object({
    player_path: z.string().min(1).describe('AnimationPlayer node path that will own the generated animation.'),
    animation: z.string().min(1).describe('Animation name that should store the generated tween sequence.'),
    sequence: z
        .array(tweenSequenceStepSchema)
        .min(1)
        .describe('Ordered array of tween steps describing the desired timeline.'),
    overwrite: z
        .boolean()
        .default(true)
        .describe('If true, the animation will be cleared before generating the tween sequence.'),
    loop: z
        .boolean()
        .default(false)
        .describe('If true, mark the animation as looping.'),
    target_path: z
        .string()
        .optional()
        .describe('Default target node path when individual steps omit a target.'),
    transaction_id: z.string().min(1).optional(),
})
    .describe('Generate or update an Animation resource representing a tween-style sequence.');
var syncParticlesWithAnimationSchema = z
    .object({
    particles_path: z.string().min(1).describe('Particles node path to synchronise.'),
    player_path: z.string().min(1).describe('AnimationPlayer node path that controls the animation.'),
    animation: z.string().min(1).describe('Animation name that should trigger particle emission.'),
    emission: z
        .record(z.any())
        .optional()
        .describe('Optional particle property overrides (lifetime, preprocess, amount, etc.).'),
    overwrite_keys: z
        .boolean()
        .default(true)
        .describe('If true, emission keys in the animation will be replaced.'),
    add_animation_keys: z
        .boolean()
        .default(true)
        .describe('If true, add animation keys to toggle particle emission in sync with the animation.'),
    transaction_id: z.string().min(1).optional(),
})
    .describe('Synchronise particle emission properties and add animation keys to control emission timing.');
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
    {
        name: 'edit_animation',
        description: 'Apply structured operations to an Animation resource.',
        parameters: editAnimationSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = editAnimationSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('edit_animation', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'configure_animation_tree',
        description: 'Configure AnimationTree properties, parameters, and state transitions.',
        parameters: configureAnimationTreeSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = configureAnimationTreeSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('configure_animation_tree', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'bake_skeleton_pose',
        description: 'Capture the current skeleton pose into an Animation resource.',
        parameters: bakeSkeletonPoseSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = bakeSkeletonPoseSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('bake_skeleton_pose', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'generate_tween_sequence',
        description: 'Generate an Animation timeline that mirrors a tween sequence.',
        parameters: generateTweenSequenceSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = generateTweenSequenceSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('generate_tween_sequence', payload)];
                        case 1:
                            result = _a.sent();
                            return [2 /*return*/, JSON.stringify(result, null, 2)];
                    }
                });
            });
        },
    },
    {
        name: 'sync_particles_with_animation',
        description: 'Align particle emission with an animation timeline.',
        parameters: syncParticlesWithAnimationSchema,
        metadata: {
            requiredRole: 'edit',
        },
        execute: function (args) {
            return __awaiter(this, void 0, void 0, function () {
                var payload, godot, result;
                return __generator(this, function (_a) {
                    switch (_a.label) {
                        case 0:
                            payload = syncParticlesWithAnimationSchema.parse(args !== null && args !== void 0 ? args : {});
                            godot = getGodotConnection();
                            return [4 /*yield*/, godot.sendCommand('sync_particles_with_animation', payload)];
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