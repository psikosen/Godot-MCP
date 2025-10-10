import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

const listAnimationPlayersSchema = z
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

const describeAnimationTracksSchema = z
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

const describeAnimationStateMachinesSchema = z
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

export const animationTools: MCPTool<any>[] = [
  {
    name: 'list_animation_players',
    description: 'List AnimationPlayer nodes and summarise their animations.',
    parameters: listAnimationPlayersSchema,
    metadata: {
      requiredRole: 'read',
    },
    async execute(args) {
      const payload = listAnimationPlayersSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('list_animation_players', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'describe_animation_tracks',
    description: 'Inspect AnimationPlayer tracks with optional keyframe payloads.',
    parameters: describeAnimationTracksSchema,
    metadata: {
      requiredRole: 'read',
    },
    async execute(args) {
      const payload = describeAnimationTracksSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('describe_animation_tracks', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'describe_animation_state_machines',
    description: 'Summarise AnimationTree state machines, transitions, and nested graphs.',
    parameters: describeAnimationStateMachinesSchema,
    metadata: {
      requiredRole: 'read',
    },
    async execute(args) {
      const payload = describeAnimationStateMachinesSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('describe_animation_state_machines', payload);
      return JSON.stringify(result, null, 2);
    },
  },
];
