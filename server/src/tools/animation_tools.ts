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

const editAnimationOperationSchema = z
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

const editAnimationSchema = z
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

const configureAnimationTreeSchema = z
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
      .array(
        z.object({
          playback_path: z.string().optional(),
          path: z.string().optional(),
          state: z.string().optional(),
          target: z.string().optional(),
        }),
      )
      .optional()
      .describe('Array of state machine playback updates specifying target states.'),
    transaction_id: z
      .string()
      .min(1)
      .optional()
      .describe('Optional existing transaction identifier for batching edits.'),
  })
  .describe('Configure AnimationTree properties, parameters, and optional state transitions.');

const bakeSkeletonPoseSchema = z
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

const tweenSequenceStepSchema = z
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

const generateTweenSequenceSchema = z
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

const syncParticlesWithAnimationSchema = z
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
  {
    name: 'edit_animation',
    description: 'Apply structured operations to an Animation resource.',
    parameters: editAnimationSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const payload = editAnimationSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('edit_animation', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'configure_animation_tree',
    description: 'Configure AnimationTree properties, parameters, and state transitions.',
    parameters: configureAnimationTreeSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const payload = configureAnimationTreeSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('configure_animation_tree', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'bake_skeleton_pose',
    description: 'Capture the current skeleton pose into an Animation resource.',
    parameters: bakeSkeletonPoseSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const payload = bakeSkeletonPoseSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('bake_skeleton_pose', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'generate_tween_sequence',
    description: 'Generate an Animation timeline that mirrors a tween sequence.',
    parameters: generateTweenSequenceSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const payload = generateTweenSequenceSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('generate_tween_sequence', payload);
      return JSON.stringify(result, null, 2);
    },
  },
  {
    name: 'sync_particles_with_animation',
    description: 'Align particle emission with an animation timeline.',
    parameters: syncParticlesWithAnimationSchema,
    metadata: {
      requiredRole: 'edit',
    },
    async execute(args) {
      const payload = syncParticlesWithAnimationSchema.parse(args ?? {});
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('sync_particles_with_animation', payload);
      return JSON.stringify(result, null, 2);
    },
  },
];
