import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

type AudioPlayerType =
  | 'AudioStreamPlayer'
  | 'AudioStreamPlayer2D'
  | 'AudioStreamPlayer3D'
  | 'AudioStreamPlayerMicrophone';

interface AuthorAudioStreamPlayerParams {
  parent_path?: string;
  node_path?: string;
  player_name?: string;
  player_type?: AudioPlayerType;
  stream_path?: string;
  create_if_missing?: boolean;
  transaction_id?: string;
  properties?: Record<string, unknown>;
  autoplay?: boolean;
  bus?: string;
  volume_db?: number;
  pitch_scale?: number;
  max_polyphony?: number;
  stream_paused?: boolean;
}

type ClipReference = number | string | { index?: number; name?: string };

interface InteractiveClipConfig {
  name?: string;
  stream_path?: string | { path?: string; stream?: unknown; resource?: unknown } | null;
  auto_advance_mode?: 'disabled' | 'enabled' | 'return_to_hold';
  auto_advance_next_clip?: ClipReference;
}

interface InteractiveTransitionConfig {
  from_clip: ClipReference;
  to_clip: ClipReference;
  from_time?: 'immediate' | 'next_beat' | 'next_bar' | 'end';
  to_time?: 'same_position' | 'start';
  fade_mode?: 'disabled' | 'fade_in' | 'in' | 'fade_out' | 'out' | 'cross' | 'crossfade' | 'automatic' | 'auto';
  fade_beats?: number;
  use_filler_clip?: boolean;
  filler_clip?: ClipReference;
  hold_previous?: boolean;
}

interface AuthorInteractiveMusicGraphParams {
  resource_path: string;
  clips: InteractiveClipConfig[];
  transitions?: InteractiveTransitionConfig[];
  initial_clip?: ClipReference;
  clear_missing_transitions?: boolean;
}

const audioPlayerTypeSchema = z.enum([
  'AudioStreamPlayer',
  'AudioStreamPlayer2D',
  'AudioStreamPlayer3D',
  'AudioStreamPlayerMicrophone',
]);

const authorAudioStreamPlayerSchema = z
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
  .superRefine((data, ctx) => {
    if (!data.node_path && !data.parent_path) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide parent_path when creating a new AudioStreamPlayer',
      });
    }
  });

const propertyKeys: Array<keyof AuthorAudioStreamPlayerParams> = [
  'autoplay',
  'bus',
  'volume_db',
  'pitch_scale',
  'max_polyphony',
  'stream_paused',
];

const clipReferenceSchema: z.ZodType<ClipReference> = z
  .union([
    z.number().int(),
    z.string().min(1),
    z
      .object({
        index: z.number().int().optional(),
        name: z.string().min(1).optional(),
      })
      .refine((value) => value.index !== undefined || value.name !== undefined, {
        message: 'Clip reference must include index or name',
      }),
  ])
  .describe('Clip reference by index, name, or object { index, name }');

const streamDescriptorSchema = z
  .union([
    z.string().min(1),
    z
      .object({
        path: z.string().optional(),
        stream: z.any().optional(),
        resource: z.any().optional(),
      })
      .refine(
        (value) => Boolean(value.path) || value.stream !== undefined || value.resource !== undefined,
        {
          message: 'Provide a path, stream, or resource when configuring a clip stream',
        },
      ),
    z.null(),
  ])
  .describe('Interactive clip stream descriptor (path string, resource dictionary, or null to clear)');

const interactiveClipSchema = z
  .object({
    name: z.string().optional(),
    stream_path: streamDescriptorSchema.optional(),
    auto_advance_mode: z.enum(['disabled', 'enabled', 'return_to_hold']).optional(),
    auto_advance_next_clip: clipReferenceSchema.optional(),
  })
  .refine(
    (value) => value.auto_advance_next_clip === undefined || value.auto_advance_mode !== undefined,
    {
      message: 'auto_advance_mode is required when auto_advance_next_clip is provided',
      path: ['auto_advance_next_clip'],
    },
  );

const interactiveTransitionSchema = z
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
  .superRefine((value, ctx) => {
    if (value.use_filler_clip && value.filler_clip === undefined) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide filler_clip when use_filler_clip is true',
        path: ['filler_clip'],
      });
    }
  });

const authorInteractiveMusicGraphSchema = z.object({
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

const formatAudioPlayerResponse = (result: CommandResult): string => {
  const nodePath = (result.node_path as string) ?? 'unknown node';
  const nodeType = (result.node_type as string) ?? 'AudioStreamPlayer';
  const status = (result.status as string) ?? 'pending';
  const transactionId = result.transaction_id ? ` (transaction ${result.transaction_id})` : '';
  const wasCreated = Boolean(result.was_created);
  const streamPath = typeof result.stream_path === 'string' ? (result.stream_path as string) : '';
  const streamCleared = Boolean(result.stream_cleared);
  const changes = Array.isArray(result.changes) ? (result.changes as any[]) : [];

  const header = wasCreated ? `Created ${nodeType} at ${nodePath}` : `Updated ${nodeType} at ${nodePath}`;
  const streamLine = streamCleared
    ? 'Stream cleared'
    : streamPath
    ? `Stream set to ${streamPath}`
    : 'Stream unchanged';

  if (changes.length === 0) {
    return `${header}${transactionId} [${status}]\n${streamLine}`;
  }

  const changeLines = changes
    .map((change) => {
      const property = change.property ?? 'property';
      const before = change.old_value ?? change.old ?? '';
      const after = change.new_value ?? change.parsed_value ?? change.input_value ?? '';
      return `- ${property}: ${before} -> ${after}`;
    })
    .join('\n');

  return `${header}${transactionId} [${status}]\n${streamLine}\n${changeLines}`;
};

const formatInteractiveMusicResponse = (result: CommandResult): string => {
  const resourcePath = (result.resource_path as string) ?? 'res://resource.interactive';
  const status = (result.status as string) ?? 'updated';
  const clipCount = typeof result.clip_count === 'number' ? (result.clip_count as number) : undefined;
  const clips = Array.isArray(result.clips) ? (result.clips as any[]) : [];
  const transitions = Array.isArray(result.transitions) ? (result.transitions as any[]) : [];

  const header = `${status === 'created' ? 'Created' : 'Updated'} interactive music resource ${resourcePath} [${status}]`;

  const clipLines = clips.map((clip) => {
    const index = clip.index ?? '?';
    const name = clip.name ?? `clip ${index}`;
    const streamCleared = Boolean(clip.stream_cleared);
    const streamPath = typeof clip.stream_path === 'string' ? (clip.stream_path as string) : '';
    const streamInfo = streamCleared
      ? 'stream cleared'
      : streamPath
      ? `stream ${streamPath}`
      : 'stream unchanged';

    const mode = typeof clip.auto_advance_mode === 'string' ? clip.auto_advance_mode : '';
    const nextClip = clip.auto_advance_next_clip ?? '';
    const extraParts = [mode ? `mode=${mode}` : '', nextClip ? `next=${nextClip}` : ''].filter(Boolean);
    const extras = extraParts.length > 0 ? ` (${extraParts.join(', ')})` : '';

    return `- [${index}] ${name}: ${streamInfo}${extras}`;
  });

  const transitionLines = transitions.map((transition) => {
    const fromLabel = transition.from_label ?? transition.from_index ?? '?';
    const toLabel = transition.to_label ?? transition.to_index ?? '?';
    const fromTime = transition.from_time ?? 'immediate';
    const toTime = transition.to_time ?? 'same_position';
    const fadeMode = transition.fade_mode ?? 'automatic';
    const fadeBeats = typeof transition.fade_beats === 'number' ? transition.fade_beats : undefined;
    const filler = transition.use_filler_clip ? transition.filler_clip ?? 'filler' : '';
    const hold = transition.hold_previous ? 'hold previous' : '';
    const statusLabel = transition.status ?? 'updated';

    const parts = [`${fromTime} -> ${toTime}`, `fade ${fadeMode}`];
    if (fadeBeats !== undefined) {
      parts.push(`${fadeBeats} beats`);
    }
    if (filler) {
      parts.push(`filler ${filler}`);
    }
    if (hold) {
      parts.push(hold);
    }

    return `- ${fromLabel} -> ${toLabel} (${parts.join(', ')}) [${statusLabel}]`;
  });

  const sections: string[] = [header];
  if (clipCount !== undefined) {
    sections.push(`Clips (${clipCount}):`);
  } else if (clipLines.length > 0) {
    sections.push('Clips:');
  }

  if (clipLines.length > 0) {
    sections.push(clipLines.join('\n'));
  }

  if (transitionLines.length > 0) {
    sections.push(`Transitions (${transitionLines.length}):`);
    sections.push(transitionLines.join('\n'));
  }

  return sections.join('\n');
};

export const audioTools: MCPTool[] = [
  {
    name: 'author_audio_stream_player',
    description:
      'Create or configure an AudioStreamPlayer node, assigning stream resources, playback settings, and optional transactions.',
    parameters: authorAudioStreamPlayerSchema,
    execute: async (args: AuthorAudioStreamPlayerParams): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {};

      const maybeSet = (key: keyof AuthorAudioStreamPlayerParams) => {
        const value = args[key];
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

      const properties: Record<string, unknown> = { ...(args.properties ?? {}) };
      for (const key of propertyKeys) {
        const value = args[key];
        if (value !== undefined) {
          properties[key] = value;
        }
      }

      if (Object.keys(properties).length > 0) {
        payload.properties = properties;
      }

      try {
        const result = await godot.sendCommand<CommandResult>('author_audio_stream_player', payload);
        return formatAudioPlayerResponse(result);
      } catch (error) {
        throw new Error(`Failed to author audio stream player: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'author_interactive_music_graph',
    description:
      'Create or update an AudioStreamInteractive resource with layered clips, playback metadata, and transition graph authoring.',
    parameters: authorInteractiveMusicGraphSchema,
    execute: async (args: AuthorInteractiveMusicGraphParams): Promise<string> => {
      const godot = getGodotConnection();

      const clipPayloads = args.clips.map((clip) => {
        const clipPayload: Record<string, unknown> = {};
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

      const payload: Record<string, unknown> = {
        resource_path: args.resource_path,
        clips: clipPayloads,
      };

      if (args.transitions) {
        payload.transitions = args.transitions.map((transition) => {
          const transitionPayload: Record<string, unknown> = {
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

      try {
        const result = await godot.sendCommand<CommandResult>('author_interactive_music_graph', payload);
        return formatInteractiveMusicResponse(result);
      } catch (error) {
        throw new Error(`Failed to author interactive music graph: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
