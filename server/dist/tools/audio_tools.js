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
var dynamicLayerClipSchema = z
    .object({
    name: z.string().optional(),
    reference: clipReferenceSchema.optional(),
    stream_path: streamDescriptorSchema.optional(),
})
    .describe('Dynamic music layer clip descriptor (name, reference, or stream override)');
var dynamicLayerTransitionSchema = z
    .object({
    from_time: z.enum(['immediate', 'next_beat', 'next_bar', 'end']).optional(),
    to_time: z.enum(['same_position', 'start']).optional(),
    fade_mode: z
        .enum(['disabled', 'fade_in', 'in', 'fade_out', 'out', 'cross', 'crossfade', 'automatic', 'auto'])
        .optional(),
    fade_beats: z.number().optional(),
    use_filler_clip: z.boolean().optional(),
    filler_clip: clipReferenceSchema.optional(),
    hold_previous: z.boolean().optional(),
})
    .superRefine(function (value, ctx) {
    if (value.use_filler_clip && value.filler_clip === undefined) {
        ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'filler_clip is required when use_filler_clip is true',
            path: ['filler_clip'],
        });
    }
})
    .describe('Entry/exit transition settings for dynamic music layers');
var generateDynamicMusicLayerSchema = z
    .object({
    resource_path: z
        .string()
        .min(1)
        .describe('AudioStreamInteractive resource path to update (e.g. "res://audio/music.interactive")'),
    base_clip: clipReferenceSchema.describe('Base clip that the dynamic layer extends'),
    layer_clip: dynamicLayerClipSchema
        .optional()
        .describe('Layer clip configuration; omit to reuse defaults when creating a new layer'),
    layer: dynamicLayerClipSchema
        .optional()
        .describe('Alias for layer_clip maintained for backwards compatibility'),
    entry_transition: dynamicLayerTransitionSchema
        .optional()
        .describe('Entry transition overrides from the base clip into the new layer'),
    exit_transition: dynamicLayerTransitionSchema
        .optional()
        .describe('Exit transition overrides when returning to the base clip'),
    make_initial: z
        .boolean()
        .optional()
        .describe('Set the generated layer as the interactive stream initial clip'),
})
    .superRefine(function (value, ctx) {
    if (value.layer_clip && value.layer) {
        ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide either layer_clip or layer, not both',
            path: ['layer'],
        });
    }
});
var analyzeWaveformSchema = z.object({
    resource_path: z
        .string()
        .min(1, 'Audio resource path is required')
        .describe('AudioStream resource to analyze (e.g. "res://audio/theme.ogg")'),
    silence_threshold: z
        .number()
        .min(0.000001)
        .max(0.1)
        .optional()
        .describe('Amplitude considered silence when computing ratios (default 0.0005)'),
    envelope_bins: z
        .number()
        .int()
        .min(16)
        .max(4096)
        .optional()
        .describe('Number of min/max envelope bins to aggregate for waveform preview (default 256)'),
});
var audioImportAssetSchema = z.object({
    path: z
        .string()
        .min(1, 'Audio resource path is required')
        .describe('Audio asset to reimport (e.g. "res://audio/music.ogg")'),
    preset: z
        .string()
        .min(1)
        .optional()
        .describe('Optional import preset name stored in the .import remap section'),
    options: z
        .record(z.any())
        .optional()
        .describe('Import parameter overrides written to the .import [params] section'),
    import_settings: z
        .record(z.any())
        .optional()
        .describe('Alias for options maintained for backwards compatibility'),
});
var batchImportAudioAssetsSchema = z
    .object({
    assets: z
        .array(audioImportAssetSchema)
        .optional()
        .describe('Detailed audio asset descriptors with optional presets and options'),
    paths: z
        .array(z.string().min(1))
        .optional()
        .describe('Shorthand list of audio asset paths to reimport with existing settings'),
})
    .refine(function (value) { return (value.assets && value.assets.length > 0) || (value.paths && value.paths.length > 0); }, {
    message: 'Provide at least one asset or path to import',
    path: ['assets'],
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
var formatDynamicLayerResponse = function (result) {
    var _a, _b, _c, _d, _e, _f;
    var resourcePath = (_a = result.resource_path) !== null && _a !== void 0 ? _a : 'res://resource.interactive';
    var baseClip = (_b = result.base_clip) !== null && _b !== void 0 ? _b : {};
    var layerClip = (_c = result.layer_clip) !== null && _c !== void 0 ? _c : {};
    var transitions = Array.isArray(result.transitions) ? result.transitions : [];
    var baseLabel = (_d = baseClip.label) !== null && _d !== void 0 ? _d : (typeof baseClip.index === 'number' ? "clip ".concat(baseClip.index) : 'base');
    var baseIndex = typeof baseClip.index === 'number' ? baseClip.index : '?';
    var layerLabel = (_e = layerClip.label) !== null && _e !== void 0 ? _e : (typeof layerClip.index === 'number' ? "clip ".concat(layerClip.index) : 'layer');
    var layerIndex = typeof layerClip.index === 'number' ? layerClip.index : '?';
    var layerStatus = (_f = layerClip.status) !== null && _f !== void 0 ? _f : (layerClip.was_created ? 'created' : 'updated');
    var header = "Linked ".concat(layerLabel, " \u2194 ").concat(baseLabel, " in ").concat(resourcePath);
    var baseLine = "Base clip: ".concat(baseLabel, " (index ").concat(baseIndex, ")");
    var layerParts = ["Layer ".concat(layerLabel, " (index ").concat(layerIndex, ") [").concat(layerStatus, "]")];
    if (typeof layerClip.name === 'string' && layerClip.name.length > 0) {
        layerParts.push("name \"".concat(layerClip.name, "\""));
    }
    if (layerClip.made_initial) {
        layerParts.push('set as initial');
    }
    if (layerClip.stream_cleared) {
        layerParts.push('stream cleared');
    }
    else if (typeof layerClip.stream_path === 'string' && layerClip.stream_path.length > 0) {
        layerParts.push("stream ".concat(layerClip.stream_path));
    }
    var transitionLines = transitions.map(function (transition) {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
        var fromLabel = (_c = (_b = (_a = transition.from) !== null && _a !== void 0 ? _a : transition.from_label) !== null && _b !== void 0 ? _b : transition.from_index) !== null && _c !== void 0 ? _c : '?';
        var toLabel = (_f = (_e = (_d = transition.to) !== null && _d !== void 0 ? _d : transition.to_label) !== null && _e !== void 0 ? _e : transition.to_index) !== null && _f !== void 0 ? _f : '?';
        var fromTime = (_g = transition.from_time) !== null && _g !== void 0 ? _g : 'next_bar';
        var toTime = (_h = transition.to_time) !== null && _h !== void 0 ? _h : 'same_position';
        var fadeMode = (_j = transition.fade_mode) !== null && _j !== void 0 ? _j : 'cross';
        var fadeBeats = typeof transition.fade_beats === 'number' ? "".concat(transition.fade_beats, " beats") : '';
        var filler = transition.use_filler_clip ? (_k = transition.filler_clip) !== null && _k !== void 0 ? _k : 'filler' : '';
        var hold = transition.hold_previous ? 'hold previous' : '';
        var parts = ["".concat(fromTime, " \u2192 ").concat(toTime), "fade ".concat(fadeMode)];
        if (fadeBeats) {
            parts.push(fadeBeats);
        }
        if (filler) {
            parts.push("filler ".concat(filler));
        }
        if (hold) {
            parts.push(hold);
        }
        return "- ".concat(fromLabel, " -> ").concat(toLabel, ": ").concat(parts.join(', '));
    });
    var lines = [header, baseLine, layerParts.join(' · ')];
    if (typeof result.initial_clip === 'string' && result.initial_clip.length > 0) {
        lines.push("Initial clip set to ".concat(result.initial_clip));
    }
    if (transitionLines.length > 0) {
        lines.push('Transitions:');
        lines.push(transitionLines.join('\n'));
    }
    return lines.join('\n');
};
var formatWaveformAnalysis = function (result) {
    var _a, _b, _c, _d, _e;
    var metadata = (_a = result.metadata) !== null && _a !== void 0 ? _a : {};
    var resourcePath = (_c = (_b = metadata.resource_path) !== null && _b !== void 0 ? _b : result.resource_path) !== null && _c !== void 0 ? _c : 'res://audio/stream.audio';
    var lengthSeconds = typeof metadata.length_seconds === 'number' ? metadata.length_seconds : undefined;
    var mixRate = typeof metadata.mix_rate === 'number' ? metadata.mix_rate : undefined;
    var channelCount = typeof metadata.channel_count === 'number' ? metadata.channel_count : undefined;
    var analysisMode = (_d = result.analysis_mode) !== null && _d !== void 0 ? _d : 'metadata_only';
    var limited = Boolean(result.limited);
    var limitedReason = typeof result.limited_reason === 'string' ? result.limited_reason : undefined;
    var silenceThreshold = typeof result.silence_threshold === 'number' ? result.silence_threshold : undefined;
    var sampleFrames = typeof result.sample_frames === 'number' ? result.sample_frames : undefined;
    var analysisDurationMs = typeof result.analysis_duration_ms === 'number' ? result.analysis_duration_ms : undefined;
    var overall = (_e = result.overall) !== null && _e !== void 0 ? _e : {};
    var channelSummaries = Array.isArray(result.channel_summaries)
        ? result.channel_summaries
        : [];
    var formatDb = function (value) {
        if (typeof value !== 'number' || !Number.isFinite(value)) {
            return 'n/a';
        }
        return "".concat(value.toFixed(2), " dB");
    };
    var lines = [];
    lines.push("Waveform analysis for ".concat(resourcePath));
    lines.push("Mode: ".concat(analysisMode).concat(limited ? ' (limited)' : ''));
    if (limitedReason) {
        lines.push("Limitations: ".concat(limitedReason));
    }
    if (lengthSeconds !== undefined) {
        lines.push("Length: ".concat(lengthSeconds.toFixed(3), "s"));
    }
    if (mixRate !== undefined) {
        lines.push("Sample rate: ".concat(mixRate, " Hz"));
    }
    if (channelCount !== undefined) {
        lines.push("Channels: ".concat(channelCount));
    }
    if (sampleFrames !== undefined) {
        lines.push("Frames analyzed: ".concat(sampleFrames));
    }
    if (silenceThreshold !== undefined) {
        lines.push("Silence threshold: ".concat(silenceThreshold));
    }
    if (analysisDurationMs !== undefined) {
        lines.push("Analysis time: ".concat(analysisDurationMs.toFixed(2), " ms"));
    }
    if (Object.keys(overall).length > 0) {
        var peakDb = typeof overall.peak_db === 'number' ? overall.peak_db : undefined;
        var rmsDb = typeof overall.rms_db === 'number' ? overall.rms_db : undefined;
        var crestDb = typeof overall.dynamic_range_db === 'number' ? overall.dynamic_range_db : undefined;
        var summaryParts = ["peak ".concat(formatDb(peakDb)), "RMS ".concat(formatDb(rmsDb))];
        if (crestDb !== undefined && Number.isFinite(crestDb)) {
            summaryParts.push("crest ".concat(crestDb.toFixed(2), " dB"));
        }
        lines.push("Overall: ".concat(summaryParts.join(' | ')));
    }
    if (channelSummaries.length > 0) {
        lines.push('Channels:');
        channelSummaries.forEach(function (summary, index) {
            var channelIndex = typeof summary.channel_index === 'number' ? summary.channel_index : index;
            var peakDb = typeof summary.peak_db === 'number' ? summary.peak_db : undefined;
            var rmsDb = typeof summary.rms_db === 'number' ? summary.rms_db : undefined;
            var crestDb = typeof summary.crest_factor_db === 'number' ? summary.crest_factor_db : undefined;
            var silenceRatio = typeof summary.silence_ratio === 'number' ? summary.silence_ratio : undefined;
            var zcr = typeof summary.zero_crossings_per_second === 'number'
                ? summary.zero_crossings_per_second
                : undefined;
            var parts = ["peak ".concat(formatDb(peakDb)), "RMS ".concat(formatDb(rmsDb))];
            if (crestDb !== undefined && Number.isFinite(crestDb)) {
                parts.push("crest ".concat(crestDb.toFixed(2), " dB"));
            }
            if (silenceRatio !== undefined && Number.isFinite(silenceRatio)) {
                parts.push("silence ".concat((silenceRatio * 100).toFixed(1), "%"));
            }
            if (zcr !== undefined && Number.isFinite(zcr)) {
                parts.push("ZCR ".concat(zcr.toFixed(1), "/s"));
            }
            lines.push("- Channel ".concat(channelIndex, ": ").concat(parts.join(' | ')));
        });
    }
    return lines.join('\n');
};
var formatBatchImportAudioResult = function (result) {
    var reimported = typeof result.reimported === 'number' ? result.reimported : 0;
    var configUpdates = typeof result.config_updates === 'number' ? result.config_updates : 0;
    var assets = Array.isArray(result.assets) ? result.assets : [];
    var errors = Array.isArray(result.errors) ? result.errors : [];
    var lines = [];
    lines.push("Reimported ".concat(reimported, " audio asset").concat(reimported === 1 ? '' : 's', " (").concat(configUpdates, " config update").concat(configUpdates === 1 ? '' : 's', ")"));
    if (assets.length > 0) {
        lines.push('Assets:');
        assets.forEach(function (asset) {
            var _a, _b, _c, _d;
            var resourcePath = (_b = (_a = asset.resource_path) !== null && _a !== void 0 ? _a : asset.path) !== null && _b !== void 0 ? _b : 'res://audio/asset.audio';
            var status = (_c = asset.config_status) !== null && _c !== void 0 ? _c : 'unchanged';
            var preset = (_d = asset.preset) !== null && _d !== void 0 ? _d : '';
            var optionsApplied = typeof asset.options_applied === 'number' ? asset.options_applied : undefined;
            var details = ["status=".concat(status)];
            if (preset) {
                details.push("preset=".concat(preset));
            }
            if (optionsApplied !== undefined) {
                details.push("options=".concat(optionsApplied));
            }
            lines.push("- ".concat(resourcePath, ": ").concat(details.join(', ')));
        });
    }
    if (errors.length > 0) {
        lines.push('Warnings:');
        errors.forEach(function (warning) {
            var _a, _b, _c;
            var path = (_b = (_a = warning.resource_path) !== null && _a !== void 0 ? _a : warning.path) !== null && _b !== void 0 ? _b : 'unknown';
            var message = (_c = warning.error) !== null && _c !== void 0 ? _c : 'Unknown import warning';
            lines.push("- ".concat(path, ": ").concat(message));
        });
    }
    return lines.join('\n');
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
    {
        name: 'generate_dynamic_music_layer',
        description: 'Add or update a clip layer on an AudioStreamInteractive resource with symmetric entry/exit transitions and optional stream overrides.',
        parameters: generateDynamicMusicLayerSchema,
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, payload, layerOptions, layerPayload, buildTransitionPayload, entryPayload, exitPayload, result, error_3;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {
                            resource_path: args.resource_path,
                            base_clip: args.base_clip,
                        };
                        layerOptions = (_a = args.layer_clip) !== null && _a !== void 0 ? _a : args.layer;
                        if (layerOptions) {
                            layerPayload = {};
                            if (layerOptions.name !== undefined) {
                                layerPayload.name = layerOptions.name;
                            }
                            if (layerOptions.reference !== undefined) {
                                layerPayload.reference = layerOptions.reference;
                            }
                            if (layerOptions.stream_path !== undefined) {
                                layerPayload.stream_path = layerOptions.stream_path;
                            }
                            payload.layer_clip = layerPayload;
                        }
                        buildTransitionPayload = function (transition) {
                            if (!transition) {
                                return undefined;
                            }
                            var transitionPayload = {};
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
                        };
                        entryPayload = buildTransitionPayload(args.entry_transition);
                        if (entryPayload) {
                            payload.entry_transition = entryPayload;
                        }
                        exitPayload = buildTransitionPayload(args.exit_transition);
                        if (exitPayload) {
                            payload.exit_transition = exitPayload;
                        }
                        if (args.make_initial !== undefined) {
                            payload.make_initial = args.make_initial;
                        }
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('generate_dynamic_music_layer', payload)];
                    case 2:
                        result = _b.sent();
                        return [2 /*return*/, formatDynamicLayerResponse(result)];
                    case 3:
                        error_3 = _b.sent();
                        throw new Error("Failed to generate dynamic music layer: ".concat(error_3.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'edit',
        },
    },
    {
        name: 'analyze_waveform',
        description: 'Inspect waveform amplitude, RMS, crest factor, and optional envelope summaries for an AudioStream resource.',
        parameters: analyzeWaveformSchema,
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, payload, result, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {
                            resource_path: args.resource_path,
                        };
                        if (args.silence_threshold !== undefined) {
                            payload.silence_threshold = args.silence_threshold;
                        }
                        if (args.envelope_bins !== undefined) {
                            payload.envelope_bins = args.envelope_bins;
                        }
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('analyze_waveform', payload)];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, formatWaveformAnalysis(result)];
                    case 3:
                        error_4 = _a.sent();
                        throw new Error("Failed to analyze waveform: ".concat(error_4.message));
                    case 4: return [2 /*return*/];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'batch_import_audio_assets',
        description: 'Apply import presets or parameter overrides to audio assets and trigger a batch reimport through the EditorFileSystem.',
        parameters: batchImportAudioAssetsSchema,
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var godot, payload, result, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        godot = getGodotConnection();
                        payload = {};
                        if (args.assets && args.assets.length > 0) {
                            payload.assets = args.assets.map(function (asset) {
                                var _a;
                                var assetPayload = { path: asset.path };
                                if (asset.preset !== undefined) {
                                    assetPayload.preset = asset.preset;
                                }
                                var options = (_a = asset.options) !== null && _a !== void 0 ? _a : asset.import_settings;
                                if (options !== undefined) {
                                    assetPayload.options = options;
                                }
                                return assetPayload;
                            });
                        }
                        if (args.paths && args.paths.length > 0) {
                            payload.paths = args.paths;
                        }
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('batch_import_audio_assets', payload)];
                    case 2:
                        result = _a.sent();
                        return [2 /*return*/, formatBatchImportAudioResult(result)];
                    case 3:
                        error_5 = _a.sent();
                        throw new Error("Failed to batch import audio assets: ".concat(error_5.message));
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