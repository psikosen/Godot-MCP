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

type StreamDescriptor = string | { path?: string; stream?: unknown; resource?: unknown } | null;

interface InteractiveClipConfig {
  name?: string;
  stream_path?: StreamDescriptor;
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

interface DynamicLayerClipConfig {
  name?: string;
  reference?: ClipReference;
  stream_path?: StreamDescriptor;
}

interface DynamicLayerTransitionConfig {
  from_time?: 'immediate' | 'next_beat' | 'next_bar' | 'end';
  to_time?: 'same_position' | 'start';
  fade_mode?: 'disabled' | 'fade_in' | 'in' | 'fade_out' | 'out' | 'cross' | 'crossfade' | 'automatic' | 'auto';
  fade_beats?: number;
  use_filler_clip?: boolean;
  filler_clip?: ClipReference;
  hold_previous?: boolean;
}

interface GenerateDynamicMusicLayerParams {
  resource_path: string;
  base_clip: ClipReference;
  layer_clip?: DynamicLayerClipConfig;
  layer?: DynamicLayerClipConfig;
  entry_transition?: DynamicLayerTransitionConfig;
  exit_transition?: DynamicLayerTransitionConfig;
  make_initial?: boolean;
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

const dynamicLayerClipSchema = z
  .object({
    name: z.string().optional(),
    reference: clipReferenceSchema.optional(),
    stream_path: streamDescriptorSchema.optional(),
  })
  .describe('Dynamic music layer clip descriptor (name, reference, or stream override)');

const dynamicLayerTransitionSchema = z
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
  .superRefine((value, ctx) => {
    if (value.use_filler_clip && value.filler_clip === undefined) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'filler_clip is required when use_filler_clip is true',
        path: ['filler_clip'],
      });
    }
  })
  .describe('Entry/exit transition settings for dynamic music layers');

const generateDynamicMusicLayerSchema = z
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
  .superRefine((value, ctx) => {
    if (value.layer_clip && value.layer) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: 'Provide either layer_clip or layer, not both',
        path: ['layer'],
      });
    }
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

const formatDynamicLayerResponse = (result: CommandResult): string => {
  const resourcePath = (result.resource_path as string) ?? 'res://resource.interactive';
  const baseClip = (result.base_clip as Record<string, unknown>) ?? {};
  const layerClip = (result.layer_clip as Record<string, unknown>) ?? {};
  const transitions = Array.isArray(result.transitions) ? (result.transitions as any[]) : [];

  const baseLabel = (baseClip.label as string) ?? (typeof baseClip.index === 'number' ? `clip ${baseClip.index}` : 'base');
  const baseIndex = typeof baseClip.index === 'number' ? (baseClip.index as number) : '?';
  const layerLabel = (layerClip.label as string) ?? (typeof layerClip.index === 'number' ? `clip ${layerClip.index}` : 'layer');
  const layerIndex = typeof layerClip.index === 'number' ? (layerClip.index as number) : '?';
  const layerStatus = (layerClip.status as string) ?? (layerClip.was_created ? 'created' : 'updated');
  const header = `Linked ${layerLabel} ↔ ${baseLabel} in ${resourcePath}`;

  const baseLine = `Base clip: ${baseLabel} (index ${baseIndex})`;

  const layerParts: string[] = [`Layer ${layerLabel} (index ${layerIndex}) [${layerStatus}]`];
  if (typeof layerClip.name === 'string' && layerClip.name.length > 0) {
    layerParts.push(`name "${layerClip.name as string}"`);
  }
  if (layerClip.made_initial) {
    layerParts.push('set as initial');
  }
  if (layerClip.stream_cleared) {
    layerParts.push('stream cleared');
  } else if (typeof layerClip.stream_path === 'string' && layerClip.stream_path.length > 0) {
    layerParts.push(`stream ${layerClip.stream_path as string}`);
  }

  const transitionLines = transitions.map((transition) => {
    const fromLabel = transition.from ?? transition.from_label ?? transition.from_index ?? '?';
    const toLabel = transition.to ?? transition.to_label ?? transition.to_index ?? '?';
    const fromTime = transition.from_time ?? 'next_bar';
    const toTime = transition.to_time ?? 'same_position';
    const fadeMode = transition.fade_mode ?? 'cross';
    const fadeBeats = typeof transition.fade_beats === 'number' ? `${transition.fade_beats} beats` : '';
    const filler = transition.use_filler_clip ? transition.filler_clip ?? 'filler' : '';
    const hold = transition.hold_previous ? 'hold previous' : '';

    const parts = [`${fromTime} → ${toTime}`, `fade ${fadeMode}`];
    if (fadeBeats) {
      parts.push(fadeBeats);
    }
    if (filler) {
      parts.push(`filler ${filler}`);
    }
    if (hold) {
      parts.push(hold);
    }

    return `- ${fromLabel} -> ${toLabel}: ${parts.join(', ')}`;
  });

  const lines: string[] = [header, baseLine, layerParts.join(' · ')];
  if (typeof result.initial_clip === 'string' && result.initial_clip.length > 0) {
    lines.push(`Initial clip set to ${result.initial_clip}`);
  }

  if (transitionLines.length > 0) {
    lines.push('Transitions:');
    lines.push(transitionLines.join('\n'));
  }

  return lines.join('\n');
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
  {
    name: 'generate_dynamic_music_layer',
    description:
      'Add or update a clip layer on an AudioStreamInteractive resource with symmetric entry/exit transitions and optional stream overrides.',
    parameters: generateDynamicMusicLayerSchema,
    execute: async (args: GenerateDynamicMusicLayerParams): Promise<string> => {
      const godot = getGodotConnection();

      const payload: Record<string, unknown> = {
        resource_path: args.resource_path,
        base_clip: args.base_clip,
      };

      const layerOptions = args.layer_clip ?? args.layer;
      if (layerOptions) {
        const layerPayload: Record<string, unknown> = {};
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

      const buildTransitionPayload = (transition?: DynamicLayerTransitionConfig) => {
        if (!transition) {
          return undefined;
        }

        const transitionPayload: Record<string, unknown> = {};
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

      const entryPayload = buildTransitionPayload(args.entry_transition);
      if (entryPayload) {
        payload.entry_transition = entryPayload;
      }

      const exitPayload = buildTransitionPayload(args.exit_transition);
      if (exitPayload) {
        payload.exit_transition = exitPayload;
      }

      if (args.make_initial !== undefined) {
        payload.make_initial = args.make_initial;
      }

      try {
        const result = await godot.sendCommand<CommandResult>('generate_dynamic_music_layer', payload);
        return formatDynamicLayerResponse(result);
      } catch (error) {
        throw new Error(`Failed to generate dynamic music layer: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
