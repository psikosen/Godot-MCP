var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
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
var audioPlayerTypeSchema = z.enum([
    'AudioStreamPlayer',
    'AudioStreamPlayer2D',
    'AudioStreamPlayer3D',
    'AudioStreamPlayerMicrophone',
]);
var authorAudioStreamPlayerSchema = z
    .object({
    parent_path: z
        .string()
        .optional()
        .describe('Parent node path used when creating a new AudioStreamPlayer (e.g. "/root/MainScene")'),
    node_path: z
        .string()
        .optional()
        .describe('Existing AudioStreamPlayer path to configure (e.g. "/root/MainScene/Music")'),
    player_name: z
        .string()
        .optional()
        .describe('Optional name override to apply when creating the player'),
    player_type: audioPlayerTypeSchema
        .default('AudioStreamPlayer')
        .describe('AudioStreamPlayer class to instantiate when creating a new node'),
    stream_path: z
        .string()
        .optional()
        .describe('AudioStream resource path to assign to the player (e.g. "res://audio/theme.ogg")'),
    create_if_missing: z
        .boolean()
        .optional()
        .describe('Create the AudioStreamPlayer when node_path is missing instead of returning an error'),
    transaction_id: z
        .string()
        .optional()
        .describe('Optional scene transaction identifier used to batch multiple edits'),
    properties: z
        .record(z.any())
        .optional()
        .describe('Additional AudioStreamPlayer properties to set (e.g. volume_db, mix_target, unit_size)'),
    autoplay: z.boolean().optional().describe('Convenience flag mapped to the autoplay property'),
    bus: z.string().optional().describe('Bus name to assign for playback (maps to the bus property)'),
    volume_db: z
        .number()
        .optional()
        .describe('Playback volume in decibels applied to the player'),
    pitch_scale: z
        .number()
        .optional()
        .describe('Pitch multiplier applied to the audio stream'),
    max_polyphony: z
        .number()
        .int()
        .optional()
        .describe('Maximum simultaneous voices for 3D and microphone players'),
    stream_paused: z
        .boolean()
        .optional()
        .describe('Whether the AudioStreamPlayer starts in a paused state'),
})
    .superRefine(function (data, ctx) {
    if (!data.node_path && !data.parent_path) {
        ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide parent_path when creating a new AudioStreamPlayer',
        });
    }
});
var propertyKeys = [
    'autoplay',
    'bus',
    'volume_db',
    'pitch_scale',
    'max_polyphony',
    'stream_paused',
];
var clipReferenceSchema = z
    .union([
    z.number().int(),
    z.string().min(1),
    z
        .object({
        index: z.number().int().optional(),
        name: z.string().min(1).optional(),
    })
        .refine(function (value) { return value.index !== undefined || value.name !== undefined; }, {
        message: 'Clip reference must include index or name',
    }),
])
    .describe('Clip reference by index, name, or object { index, name }');
var streamDescriptorSchema = z
    .union([
    z.string().min(1),
    z
        .object({
        path: z.string().optional(),
        stream: z.any().optional(),
        resource: z.any().optional(),
    })
        .refine(function (value) { return Boolean(value.path) || value.stream !== undefined || value.resource !== undefined; }, {
        message: 'Provide a path, stream, or resource when configuring a clip stream',
    }),
    z.null(),
])
    .describe('Interactive clip stream descriptor (path string, resource dictionary, or null to clear)');
var interactiveClipSchema = z
    .object({
    name: z.string().optional(),
    stream_path: streamDescriptorSchema.optional(),
    auto_advance_mode: z.enum(['disabled', 'enabled', 'return_to_hold']).optional(),
    auto_advance_next_clip: clipReferenceSchema.optional(),
})
    .refine(function (value) { return value.auto_advance_next_clip === undefined || value.auto_advance_mode !== undefined; }, {
    message: 'auto_advance_mode is required when auto_advance_next_clip is provided',
    path: ['auto_advance_next_clip'],
});
var interactiveTransitionSchema = z
    .object({
    from_clip: clipReferenceSchema,
    to_clip: clipReferenceSchema,
    from_time: z.enum(['immediate', 'next_beat', 'next_bar', 'end']).default('immediate'),
    to_time: z.enum(['same_position', 'start']).default('same_position'),
    fade_mode: z
        .enum(['disabled', 'fade_in', 'in', 'fade_out', 'out', 'cross', 'crossfade', 'automatic', 'auto'])
        .default('automatic'),
    fade_beats: z.number().optional(),
    use_filler_clip: z.boolean().optional(),
    filler_clip: clipReferenceSchema.optional(),
    hold_previous: z.boolean().optional(),
})
    .superRefine(function (value, ctx) {
    if (value.use_filler_clip && value.filler_clip === undefined) {
        ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide filler_clip when use_filler_clip is true',
            path: ['filler_clip'],
        });
    }
});
var authorInteractiveMusicGraphSchema = z.object({
    resource_path: z
        .string()
        .min(1, 'Interactive music resource path is required')
        .describe('Destination resource path (e.g. "res://audio/music.interactive")'),
    clips: z
        .array(interactiveClipSchema)
        .min(1, 'At least one interactive music clip must be provided'),
    transitions: z.array(interactiveTransitionSchema).optional(),
    initial_clip: clipReferenceSchema.optional(),
    clear_missing_transitions: z
        .boolean()
        .optional()
        .describe('Remove transitions not present in the current request'),
});
var formatAudioPlayerResponse = function (result) {
    var _a, _b, _c;
    var nodePath = (_a = result.node_path) !== null && _a !== void 0 ? _a : 'unknown node';
    var nodeType = (_b = result.node_type) !== null && _b !== void 0 ? _b : 'AudioStreamPlayer';
    var status = (_c = result.status) !== null && _c !== void 0 ? _c : 'pending';
    var transactionId = result.transaction_id ? " (transaction ".concat(result.transaction_id, ")") : '';
    var wasCreated = Boolean(result.was_created);
    var streamPath = typeof result.stream_path === 'string' ? result.stream_path : '';
    var streamCleared = Boolean(result.stream_cleared);
    var changes = Array.isArray(result.changes) ? result.changes : [];
    var header = wasCreated ? "Created ".concat(nodeType, " at ").concat(nodePath) : "Updated ".concat(nodeType, " at ").concat(nodePath);
    var streamLine = streamCleared
        ? 'Stream cleared'
        : streamPath
            ? "Stream set to ".concat(streamPath)
            : 'Stream unchanged';
    if (changes.length === 0) {
        return "".concat(header).concat(transactionId, " [").concat(status, "]\n").concat(streamLine);
    }
    var changeLines = changes
        .map(function (change) {
        var _a, _b, _c, _d, _e, _f;
        var property = (_a = change.property) !== null && _a !== void 0 ? _a : 'property';
        var before = (_c = (_b = change.old_value) !== null && _b !== void 0 ? _b : change.old) !== null && _c !== void 0 ? _c : '';
        var after = (_f = (_e = (_d = change.new_value) !== null && _d !== void 0 ? _d : change.parsed_value) !== null && _e !== void 0 ? _e : change.input_value) !== null && _f !== void 0 ? _f : '';
        return "- ".concat(property, ": ").concat(before, " -> ").concat(after);
    })
        .join('\n');
    return "".concat(header).concat(transactionId, " [").concat(status, "]\n").concat(streamLine, "\n").concat(changeLines);
};
var formatInteractiveMusicResponse = function (result) {
    var _a, _b;
    var resourcePath = (_a = result.resource_path) !== null && _a !== void 0 ? _a : 'res://resource.interactive';
    var status = (_b = result.status) !== null && _b !== void 0 ? _b : 'updated';
    var clipCount = typeof result.clip_count === 'number' ? result.clip_count : undefined;
    var clips = Array.isArray(result.clips) ? result.clips : [];
    var transitions = Array.isArray(result.transitions) ? result.transitions : [];
    var header = "".concat(status === 'created' ? 'Created' : 'Updated', " interactive music resource ").concat(resourcePath, " [").concat(status, "]");
    var clipLines = clips.map(function (clip) {
        var _a, _b, _c;
        var index = (_a = clip.index) !== null && _a !== void 0 ? _a : '?';
        var name = (_b = clip.name) !== null && _b !== void 0 ? _b : "clip ".concat(index);
        var streamCleared = Boolean(clip.stream_cleared);
        var streamPath = typeof clip.stream_path === 'string' ? clip.stream_path : '';
        var streamInfo = streamCleared
            ? 'stream cleared'
            : streamPath
                ? "stream ".concat(streamPath)
                : 'stream unchanged';
        var mode = typeof clip.auto_advance_mode === 'string' ? clip.auto_advance_mode : '';
        var nextClip = (_c = clip.auto_advance_next_clip) !== null && _c !== void 0 ? _c : '';
        var extraParts = [mode ? "mode=".concat(mode) : '', nextClip ? "next=".concat(nextClip) : ''].filter(Boolean);
        var extras = extraParts.length > 0 ? " (".concat(extraParts.join(', '), ")") : '';
        return "- [".concat(index, "] ").concat(name, ": ").concat(streamInfo).concat(extras);
    });
    var transitionLines = transitions.map(function (transition) {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j;
        var fromLabel = (_b = (_a = transition.from_label) !== null && _a !== void 0 ? _a : transition.from_index) !== null && _b !== void 0 ? _b : '?';
        var toLabel = (_d = (_c = transition.to_label) !== null && _c !== void 0 ? _c : transition.to_index) !== null && _d !== void 0 ? _d : '?';
        var fromTime = (_e = transition.from_time) !== null && _e !== void 0 ? _e : 'immediate';
        var toTime = (_f = transition.to_time) !== null && _f !== void 0 ? _f : 'same_position';
        var fadeMode = (_g = transition.fade_mode) !== null && _g !== void 0 ? _g : 'automatic';
        var fadeBeats = typeof transition.fade_beats === 'number' ? transition.fade_beats : undefined;
        var filler = transition.use_filler_clip ? (_h = transition.filler_clip) !== null && _h !== void 0 ? _h : 'filler' : '';
        var hold = transition.hold_previous ? 'hold previous' : '';
        var statusLabel = (_j = transition.status) !== null && _j !== void 0 ? _j : 'updated';
        var parts = ["".concat(fromTime, " -> ").concat(toTime), "fade ".concat(fadeMode)];
        if (fadeBeats !== undefined) {
            parts.push("".concat(fadeBeats, " beats"));
        }
        if (filler) {
            parts.push("filler ".concat(filler));
        }
        if (hold) {
            parts.push(hold);
        }
        return "- ".concat(fromLabel, " -> ").concat(toLabel, " (").concat(parts.join(', '), ") [").concat(statusLabel, "]");
    });
    var sections = [header];
    if (clipCount !== undefined) {
        sections.push("Clips (".concat(clipCount, "):"));
    }
    else if (clipLines.length > 0) {
        sections.push('Clips:');
    }
    if (clipLines.length > 0) {
        sections.push(clipLines.join('\n'));
    }
    if (transitionLines.length > 0) {
        sections.push("Transitions (".concat(transitionLines.length, "):"));
        sections.push(transitionLines.join('\n'));
    }
    return sections.join('\n');
};
export var audioTools = [
    {
        name: 'author_audio_stream_player',
        description: 'Create or configure an AudioStreamPlayer node, assigning stream resources, playback settings, and optional transactions.',
        parameters: authorAudioStreamPlayerSchema,
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, payload, maybeSet, properties, _i, propertyKeys_1, key, value, result, error_1;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        maybeSet = function (key) {
                            var value = args[key];
                            if (value !== undefined) {
                                payload[key] = value;
                            }
                        };
                        maybeSet('node_path');
                        maybeSet('parent_path');
                        maybeSet('player_name');
                        maybeSet('player_type');
                        maybeSet('stream_path');
                        maybeSet('create_if_missing');
                        maybeSet('transaction_id');
                        properties = __assign({}, ((_a = args.properties) !== null && _a !== void 0 ? _a : {}));
                        for (_i = 0, propertyKeys_1 = propertyKeys; _i < propertyKeys_1.length; _i++) {
                            key = propertyKeys_1[_i];
                            value = args[key];
                            if (value !== undefined) {
                                properties[key] = value;
                            }
                        }
                        if (Object.keys(properties).length > 0) {
                            payload.properties = properties;
                        }
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('author_audio_stream_player', payload)];
                    case 2:
                        result = _b.sent();
                        return [2 /*return*/, formatAudioPlayerResponse(result)];
                    case 3:
                        error_1 = _b.sent();
                        throw new Error("Failed to author audio stream player: ".concat(error_1.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'author_interactive_music_graph',
        description: 'Create or update an AudioStreamInteractive resource with layered clips, playback metadata, and transition graph authoring.',
        parameters: authorInteractiveMusicGraphSchema,
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, clipPayloads, payload, result, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        clipPayloads = args.clips.map(function (clip) {
                            var clipPayload = {};
                            if (clip.name !== undefined) {
                                clipPayload.name = clip.name;
                            }
                            if (clip.stream_path !== undefined) {
                                clipPayload.stream_path = clip.stream_path;
                            }
                            if (clip.auto_advance_mode !== undefined) {
                                clipPayload.auto_advance_mode = clip.auto_advance_mode;
                            }
                            if (clip.auto_advance_next_clip !== undefined) {
                                clipPayload.auto_advance_next_clip = clip.auto_advance_next_clip;
                            }
                            return clipPayload;
                        });
                        payload = {
                            resource_path: args.resource_path,
                            clips: clipPayloads,
                        };
                        if (args.transitions) {
                            payload.transitions = args.transitions.map(function (transition) {
                                var transitionPayload = {
                                    from_clip: transition.from_clip,
                                    to_clip: transition.to_clip,
                                };
                                if (transition.from_time !== undefined) {
                                    transitionPayload.from_time = transition.from_time;
                                }
                                if (transition.to_time !== undefined) {
                                    transitionPayload.to_time = transition.to_time;
                                }
                                if (transition.fade_mode !== undefined) {
                                    transitionPayload.fade_mode = transition.fade_mode;
                                }
                                if (transition.fade_beats !== undefined) {
                                    transitionPayload.fade_beats = transition.fade_beats;
                                }
                                if (transition.use_filler_clip !== undefined) {
                                    transitionPayload.use_filler_clip = transition.use_filler_clip;
                                }
                                if (transition.filler_clip !== undefined) {
                                    transitionPayload.filler_clip = transition.filler_clip;
                                }
                                if (transition.hold_previous !== undefined) {
                                    transitionPayload.hold_previous = transition.hold_previous;
                                }
                                return transitionPayload;
                            });
                        }
                        if (args.initial_clip !== undefined) {
                            payload.initial_clip = args.initial_clip;
                        }
                        if (args.clear_missing_transitions !== undefined) {
                            payload.clear_missing_transitions = args.clear_missing_transitions;
                        }
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('author_interactive_music_graph', payload)];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, formatInteractiveMusicResponse(result)];
                    case 3:
                        error_2 = _a.sent();
                        throw new Error("Failed to author interactive music graph: ".concat(error_2.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=audio_tools.js.map