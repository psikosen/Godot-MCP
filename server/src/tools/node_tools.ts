import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

/**
 * Type definitions for node tool parameters
 */
interface CreateNodeParams {
  parent_path: string;
  node_type: string;
  node_name: string;
  transaction_id?: string;
}

interface DeleteNodeParams {
  node_path: string;
  transaction_id?: string;
}

interface UpdateNodePropertyParams {
  node_path: string;
  property: string;
  value: any;
  transaction_id?: string;
}

interface GetNodePropertiesParams {
  node_path: string;
}

interface ListNodesParams {
  parent_path: string;
}

interface DuplicateNodeParams {
  source_path: string;
  parent_path?: string;
  new_name?: string;
  duplicate_groups?: boolean;
  duplicate_signals?: boolean;
  duplicate_scripts?: boolean;
  use_instantiation?: boolean;
  transaction_id?: string;
}

interface ReparentNodeParams {
  node_path: string;
  new_parent_path: string;
  keep_global_transform?: boolean;
  new_name?: string;
  child_index?: number;
  transaction_id?: string;
}

interface MoveNodeInParentParams {
  node_path: string;
  index: number;
  transaction_id?: string;
}

interface InstantiateSceneParams {
  scene_path: string;
  parent_path?: string;
  node_name?: string;
  transaction_id?: string;
}

interface QueryNodesParams {
  root_path?: string;
  name_contains?: string;
  node_type?: string;
  group_name?: string;
  include_root?: boolean;
  include_internal?: boolean;
  max_results?: number;
}

interface BulkUpdateNodePropertiesParams {
  node_path: string;
  properties: Record<string, unknown>;
  transaction_id?: string;
}

interface BatchCreateNodesParams {
  parent_path?: string;
  nodes: Array<{
    node_type: string;
    node_name?: string;
    properties?: Record<string, unknown>;
  }>;
  transaction_id?: string;
}

interface BatchDeleteNodesParams {
  node_paths: string[];
  transaction_id?: string;
}

interface SetNodeScriptParams {
  node_path: string;
  script_path: string;
  create_script?: boolean;
  extends_type?: string;
  transaction_id?: string;
}

interface ClearNodeScriptParams {
  node_path: string;
  transaction_id?: string;
}

interface SetNodeOwnerRecursiveParams {
  node_path: string;
  owner_path?: string;
  include_root?: boolean;
  transaction_id?: string;
}

interface PaintTileMapCells2DParams {
  node_path: string;
  layer?: number;
  cells: Array<{
    position?: { x: number; y: number } | [number, number];
    coords?: { x: number; y: number } | [number, number];
    x?: number;
    y?: number;
    source_id: number;
    atlas_coords?: { x: number; y: number } | [number, number];
    alternative_tile?: number;
  }>;
  transaction_id?: string;
}

interface ClearTileMapCells2DParams {
  node_path: string;
  layer?: number;
  cells: Array<
    | { position?: { x: number; y: number } | [number, number]; coords?: { x: number; y: number } | [number, number]; x?: number; y?: number }
    | { x: number; y: number }
    | [number, number]
  >;
  transaction_id?: string;
}

interface ConfigureCamera2DFollowParams {
  node_path: string;
  zoom?: { x?: number; y?: number } | [number, number];
  offset?: { x?: number; y?: number } | [number, number];
  enabled?: boolean;
  ignore_rotation?: boolean;
  position_smoothing_enabled?: boolean;
  position_smoothing_speed?: number;
  rotation_smoothing_enabled?: boolean;
  rotation_smoothing_speed?: number;
  drag_enabled?: { horizontal?: boolean; vertical?: boolean };
  drag_margins?: { left?: number; right?: number; top?: number; bottom?: number };
  drag_offsets?: { horizontal?: number; vertical?: number };
  transaction_id?: string;
}

interface SetAnimationTreeStateParams {
  node_path: string;
  state_name: string;
  active?: boolean;
  process_callback?: number;
  use_start?: boolean;
  reset_on_teleport?: boolean;
  transaction_id?: string;
}

interface SetAnimationTreeParametersParams {
  node_path: string;
  parameters: Record<string, unknown>;
  transaction_id?: string;
}

interface BuildWaveSpawner2DParams {
  parent_path?: string;
  spawner_name?: string;
  spawn_points?: Array<{ x?: number; y?: number } | [number, number]>;
  create_timer?: boolean;
  timer_name?: string;
  create_spawn_nodes?: boolean;
  spawn_nodes_parent_name?: string;
  wave_interval?: number;
  enemies_per_wave?: number;
  max_waves?: number;
  current_wave?: number;
  auto_start?: boolean;
  enemy_scene_path?: string;
  transaction_id?: string;
}

interface BuildWaveSpawner3DParams {
  parent_path?: string;
  spawner_name?: string;
  spawn_points?: Array<{ x?: number; y?: number; z?: number } | [number, number, number]>;
  create_timer?: boolean;
  timer_name?: string;
  create_spawn_nodes?: boolean;
  spawn_nodes_parent_name?: string;
  wave_interval?: number;
  enemies_per_wave?: number;
  max_waves?: number;
  current_wave?: number;
  auto_start?: boolean;
  enemy_scene_path?: string;
  transaction_id?: string;
}

interface SimulateWaveSpawnerStep2DParams {
  spawner_path: string;
  spawn_count?: number;
  advance_wave?: boolean;
  instantiate_enemy?: boolean;
  enemy_scene_path?: string;
  transaction_id?: string;
}

interface SimulateWaveSpawnerStep3DParams {
  spawner_path: string;
  spawn_count?: number;
  advance_wave?: boolean;
  instantiate_enemy?: boolean;
  enemy_scene_path?: string;
  transaction_id?: string;
}

interface SimulateCamera2DShakeParams {
  node_path: string;
  trauma?: number;
  amplitude?: number;
  rotation_amplitude_degrees?: number;
  add_to_existing?: boolean;
  seed?: number;
  transaction_id?: string;
}

interface SimulateCamera3DShakeParams {
  node_path: string;
  trauma?: number;
  horizontal_amplitude?: number;
  vertical_amplitude?: number;
  roll_amplitude_degrees?: number;
  fov_pulse?: number;
  add_to_existing?: boolean;
  seed?: number;
  transaction_id?: string;
}

interface ConfigureParallax2DParams {
  node_path: string;
  scroll_scale?: { x?: number; y?: number } | [number, number];
  scroll_offset?: { x?: number; y?: number } | [number, number];
  autoscroll?: { x?: number; y?: number } | [number, number];
  repeat_size?: { x?: number; y?: number } | [number, number];
  follow_viewport?: boolean;
  ignore_camera_scroll?: boolean;
  transaction_id?: string;
}

interface ConfigureAnimatedSprite2DParams {
  node_path: string;
  sprite_frames_path?: string;
  animation?: string;
  autoplay?: string;
  speed_scale?: number;
  centered?: boolean;
  offset?: { x?: number; y?: number } | [number, number];
  flip_h?: boolean;
  flip_v?: boolean;
  frame?: number;
  frame_progress?: number;
  transaction_id?: string;
}

interface ConfigureSprite2DParams {
  node_path: string;
  texture_path?: string;
  centered?: boolean;
  offset?: { x?: number; y?: number } | [number, number];
  flip_h?: boolean;
  flip_v?: boolean;
  hframes?: number;
  vframes?: number;
  frame?: number;
  frame_coords?: { x?: number; y?: number } | [number, number];
  region_enabled?: boolean;
  region_filter_clip_enabled?: boolean;
  region_rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  modulate?: unknown;
  self_modulate?: unknown;
  transaction_id?: string;
}

interface ConfigureCharacterBody2DControllerParams {
  node_path: string;
  up_direction?: { x?: number; y?: number } | [number, number];
  motion_mode?: number;
  floor_stop_on_slope?: boolean;
  floor_constant_speed?: boolean;
  floor_block_on_wall?: boolean;
  floor_snap_length?: number;
  floor_max_angle?: number;
  wall_min_slide_angle?: number;
  max_slides?: number;
  safe_margin?: number;
  slide_on_ceiling?: boolean;
  platform_on_leave?: number;
  platform_floor_layers?: number;
  platform_wall_layers?: number;
  transaction_id?: string;
}

interface ConfigureArea2DSensorParams {
  node_path: string;
  monitoring?: boolean;
  monitorable?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  priority?: number;
  gravity_space_override?: number;
  gravity_point?: boolean;
  gravity_point_center?: { x?: number; y?: number } | [number, number];
  gravity_point_unit_distance?: number;
  gravity_direction?: { x?: number; y?: number } | [number, number];
  gravity?: number;
  linear_damp_space_override?: number;
  linear_damp?: number;
  angular_damp_space_override?: number;
  angular_damp?: number;
  transaction_id?: string;
}

interface FillTileMapRect2DParams {
  node_path: string;
  layer?: number;
  origin?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  clear?: boolean;
  source_id?: number;
  atlas_coords?: { x?: number; y?: number } | [number, number];
  alternative_tile?: number;
  transaction_id?: string;
}

interface GenerateTileMapNoise2DParams {
  node_path: string;
  layer?: number;
  origin?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  source_id: number;
  atlas_coords?: { x?: number; y?: number } | [number, number];
  alternative_tile?: number;
  threshold?: number;
  invert?: boolean;
  clear_unselected?: boolean;
  sample_offset?: { x?: number; y?: number } | [number, number];
  noise_seed?: number;
  frequency?: number;
  fractal_octaves?: number;
  fractal_lacunarity?: number;
  fractal_gain?: number;
  noise_type?: number;
  fractal_type?: number;
  transaction_id?: string;
}

interface TilemapTerrainAutopaint2DParams {
  node_path: string;
  layer?: number;
  terrain_set: number;
  terrain: number;
  mode?: 'connect' | 'path';
  cells?: Array<{ x?: number; y?: number } | [number, number]>;
  origin?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  rect?: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  use_noise?: boolean;
  fill_probability?: number;
  threshold?: number;
  invert?: boolean;
  sample_offset?: { x?: number; y?: number } | [number, number];
  seed?: number;
  noise_seed?: number;
  frequency?: number;
  fractal_octaves?: number;
  fractal_lacunarity?: number;
  fractal_gain?: number;
  noise_type?: number;
  fractal_type?: number;
  ignore_empty_terrains?: boolean;
  clear_unselected?: boolean;
  neighbor_margin?: number;
  preview_only?: boolean;
  transaction_id?: string;
}

interface GenerateHeightmapGridMap3DParams {
  node_path: string;
  origin?: { x?: number; y?: number; z?: number } | [number, number, number];
  size: { x?: number; y?: number } | [number, number];
  item_id: number;
  orientation?: number;
  min_height?: number;
  max_height?: number;
  surface_only?: boolean;
  clear_unselected?: boolean;
  sample_offset?: { x?: number; y?: number } | [number, number];
  noise_seed?: number;
  frequency?: number;
  fractal_octaves?: number;
  fractal_lacunarity?: number;
  fractal_gain?: number;
  noise_type?: number;
  fractal_type?: number;
  transaction_id?: string;
}

interface ScatterSceneInstances2DParams {
  parent_path?: string;
  scene_path: string;
  count?: number;
  rect: { position?: { x?: number; y?: number }; size?: { x?: number; y?: number } } | [number, number, number, number];
  min_distance?: number;
  max_attempts?: number;
  require_full_count?: boolean;
  name_prefix?: string;
  random_rotation?: boolean;
  rotation_range_degrees?: { x?: number; y?: number } | [number, number];
  random_scale?: boolean;
  scale_range?: { x?: number; y?: number } | [number, number];
  seed?: number;
  transaction_id?: string;
}

interface ScatterSceneInstances3DParams {
  parent_path?: string;
  scene_path: string;
  count?: number;
  origin?: { x?: number; y?: number; z?: number } | [number, number, number];
  size: { x?: number; y?: number; z?: number } | [number, number, number];
  min_distance?: number;
  max_attempts?: number;
  require_full_count?: boolean;
  name_prefix?: string;
  random_yaw?: boolean;
  yaw_range_degrees?: { x?: number; y?: number } | [number, number];
  random_scale?: boolean;
  scale_range?: { x?: number; y?: number } | [number, number];
  seed?: number;
  transaction_id?: string;
}

interface ConfigureCharacterBody3DControllerParams {
  node_path: string;
  up_direction?: { x?: number; y?: number; z?: number } | [number, number, number];
  motion_mode?: number;
  floor_stop_on_slope?: boolean;
  floor_constant_speed?: boolean;
  floor_block_on_wall?: boolean;
  floor_snap_length?: number;
  floor_max_angle?: number;
  wall_min_slide_angle?: number;
  max_slides?: number;
  safe_margin?: number;
  slide_on_ceiling?: boolean;
  platform_on_leave?: number;
  platform_floor_layers?: number;
  platform_wall_layers?: number;
  velocity?: { x?: number; y?: number; z?: number } | [number, number, number];
  transaction_id?: string;
}

interface ConfigureCamera3DRigParams {
  node_path: string;
  position?: { x?: number; y?: number; z?: number } | [number, number, number];
  rotation_degrees?: { x?: number; y?: number; z?: number } | [number, number, number];
  global_position?: { x?: number; y?: number; z?: number } | [number, number, number];
  global_rotation_degrees?: { x?: number; y?: number; z?: number } | [number, number, number];
  current?: boolean;
  projection?: number;
  fov?: number;
  size?: number;
  near?: number;
  far?: number;
  keep_aspect?: number;
  h_offset?: number;
  v_offset?: number;
  cull_mask?: number;
  doppler_tracking?: number;
  environment_path?: string;
  transaction_id?: string;
}

interface ConfigureSpringArm3DParams {
  node_path: string;
  spring_length?: number;
  margin?: number;
  collision_mask?: number;
  shape_path?: string;
  transaction_id?: string;
}

interface ConfigureNavigationAgent2DParams {
  node_path: string;
  target_position?: { x?: number; y?: number } | [number, number];
  navigation_layers?: number;
  pathfinding_algorithm?: number;
  path_postprocessing?: number;
  path_metadata_flags?: number;
  path_desired_distance?: number;
  target_desired_distance?: number;
  path_max_distance?: number;
  radius?: number;
  max_speed?: number;
  avoidance_enabled?: boolean;
  neighbor_distance?: number;
  max_neighbors?: number;
  time_horizon?: number;
  time_horizon_agents?: number;
  time_horizon_obstacles?: number;
  avoidance_layers?: number;
  avoidance_mask?: number;
  avoidance_priority?: number;
  transaction_id?: string;
}

interface ConfigureNavigationAgent3DParams {
  node_path: string;
  target_position?: { x?: number; y?: number; z?: number } | [number, number, number];
  navigation_layers?: number;
  pathfinding_algorithm?: number;
  path_postprocessing?: number;
  path_metadata_flags?: number;
  path_desired_distance?: number;
  target_desired_distance?: number;
  path_max_distance?: number;
  radius?: number;
  height?: number;
  max_speed?: number;
  avoidance_enabled?: boolean;
  neighbor_distance?: number;
  max_neighbors?: number;
  time_horizon?: number;
  time_horizon_agents?: number;
  time_horizon_obstacles?: number;
  avoidance_layers?: number;
  avoidance_mask?: number;
  avoidance_priority?: number;
  transaction_id?: string;
}

interface ConfigureNavigationObstacle2DParams {
  node_path: string;
  avoidance_enabled?: boolean;
  avoidance_layers?: number;
  radius?: number;
  velocity?: { x?: number; y?: number } | [number, number];
  use_3d_avoidance?: boolean;
  vertices?: Array<{ x?: number; y?: number } | [number, number]>;
  transaction_id?: string;
}

interface ConfigureNavigationObstacle3DParams {
  node_path: string;
  avoidance_enabled?: boolean;
  avoidance_layers?: number;
  radius?: number;
  height?: number;
  velocity?: { x?: number; y?: number; z?: number } | [number, number, number];
  vertices?: Array<{ x?: number; y?: number; z?: number } | [number, number, number]>;
  transaction_id?: string;
}

interface AdvancePathFollow2DParams {
  node_path: string;
  speed?: number;
  delta?: number;
  reverse?: boolean;
  progress?: number;
  progress_delta?: number;
  progress_ratio?: number;
  progress_ratio_delta?: number;
  loop?: boolean;
  cubic_interp?: boolean;
  rotates?: boolean;
  h_offset?: number;
  v_offset?: number;
  transaction_id?: string;
}

interface AdvancePathFollow3DParams {
  node_path: string;
  speed?: number;
  delta?: number;
  reverse?: boolean;
  progress?: number;
  progress_delta?: number;
  progress_ratio?: number;
  progress_ratio_delta?: number;
  loop?: boolean;
  cubic_interp?: boolean;
  rotation_mode?: number;
  tilt_enabled?: boolean;
  use_model_front?: boolean;
  transaction_id?: string;
}

interface ConfigurePath2DFollowersParams {
  path_path: string;
  follower_count?: number;
  create_missing?: boolean;
  base_name?: string;
  use_progress_ratio?: boolean;
  spacing?: number;
  start_progress?: number;
  loop?: boolean;
  cubic_interp?: boolean;
  rotates?: boolean;
  h_offset?: number;
  v_offset?: number;
  speed?: number;
  followers?: Array<{
    node_path?: string;
    index?: number;
    name?: string;
    progress?: number;
    progress_ratio?: number;
    loop?: boolean;
    cubic_interp?: boolean;
    rotates?: boolean;
    h_offset?: number;
    v_offset?: number;
    speed?: number;
  }>;
  transaction_id?: string;
}

interface ConfigurePath3DFollowersParams {
  path_path: string;
  follower_count?: number;
  create_missing?: boolean;
  base_name?: string;
  use_progress_ratio?: boolean;
  spacing?: number;
  start_progress?: number;
  loop?: boolean;
  cubic_interp?: boolean;
  rotation_mode?: number;
  tilt_enabled?: boolean;
  use_model_front?: boolean;
  speed?: number;
  followers?: Array<{
    node_path?: string;
    index?: number;
    name?: string;
    progress?: number;
    progress_ratio?: number;
    loop?: boolean;
    cubic_interp?: boolean;
    rotation_mode?: number;
    tilt_enabled?: boolean;
    use_model_front?: boolean;
    speed?: number;
  }>;
  transaction_id?: string;
}

interface ConfigureTopDownMovement2DParams {
  node_path: string;
  apply_defaults?: boolean;
  motion_mode?: number;
  up_direction?: { x?: number; y?: number } | [number, number];
  floor_stop_on_slope?: boolean;
  floor_constant_speed?: boolean;
  floor_block_on_wall?: boolean;
  floor_snap_length?: number;
  max_slides?: number;
  safe_margin?: number;
  slide_on_ceiling?: boolean;
  platform_on_leave?: number;
  platform_floor_layers?: number;
  platform_wall_layers?: number;
  velocity?: { x?: number; y?: number } | [number, number];
  speed?: number;
  acceleration?: number;
  deceleration?: number;
  input_actions?: { up?: string; down?: string; left?: string; right?: string };
  transaction_id?: string;
}

interface SimulateCharacterBody2DMovementParams {
  node_path: string;
  direction?: { x?: number; y?: number } | [number, number];
  speed?: number;
  acceleration?: number;
  deceleration?: number;
  delta?: number;
  set_rotation?: boolean;
  sprite_path?: string;
  flip_sprite_h?: boolean;
  animation_map?: { move?: string; idle?: string };
  play_animation?: boolean;
  transaction_id?: string;
}

interface SimulateCharacterBody3DMovementParams {
  node_path: string;
  direction?: { x?: number; y?: number; z?: number } | [number, number, number];
  speed?: number;
  acceleration?: number;
  deceleration?: number;
  delta?: number;
  planar_only?: boolean;
  preserve_vertical_velocity?: boolean;
  yaw_to_direction?: boolean;
  transaction_id?: string;
}

interface SimulateNavigationChaseStep2DParams {
  agent_path: string;
  body_path?: string;
  delta?: number;
  speed?: number;
  acceleration?: number;
  deceleration?: number;
  stop_distance?: number;
  set_rotation?: boolean;
  update_agent_velocity?: boolean;
  sync_agent_to_body?: boolean;
  stop_on_navigation_finished?: boolean;
  allow_direct_fallback?: boolean;
  transaction_id?: string;
}

interface SimulateNavigationChaseStep3DParams {
  agent_path: string;
  body_path?: string;
  delta?: number;
  speed?: number;
  acceleration?: number;
  deceleration?: number;
  stop_distance?: number;
  planar_only?: boolean;
  preserve_vertical_velocity?: boolean;
  yaw_to_direction?: boolean;
  update_agent_velocity?: boolean;
  sync_agent_to_body?: boolean;
  stop_on_navigation_finished?: boolean;
  allow_direct_fallback?: boolean;
  transaction_id?: string;
}

interface SetNavigationTargetToNode2DParams {
  agent_path: string;
  target_path: string;
  offset?: { x?: number; y?: number } | [number, number];
  remember_target?: boolean;
  transaction_id?: string;
}

interface SetNavigationTargetToNode3DParams {
  agent_path: string;
  target_path: string;
  offset?: { x?: number; y?: number; z?: number } | [number, number, number];
  remember_target?: boolean;
  transaction_id?: string;
}

interface BuildWaterBody2DParams {
  parent_path?: string;
  water_name?: string;
  position?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  create_visual?: boolean;
  create_area?: boolean;
  create_collision?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  color?: unknown;
  flow_direction?: { x?: number; y?: number } | [number, number];
  flow_speed?: number;
  buoyancy?: number;
  drag?: number;
  wave_amplitude?: number;
  wave_speed?: number;
  wave_length?: number;
  transaction_id?: string;
}

interface BuildWaterBody3DParams {
  parent_path?: string;
  water_name?: string;
  position?: { x?: number; y?: number; z?: number } | [number, number, number];
  size?: { x?: number; y?: number } | [number, number];
  depth?: number;
  create_visual?: boolean;
  create_area?: boolean;
  create_collision?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  flow_direction?: { x?: number; y?: number } | [number, number];
  flow_speed?: number;
  buoyancy?: number;
  drag?: number;
  wave_amplitude?: number;
  wave_speed?: number;
  wave_length?: number;
  surface_color?: unknown;
  roughness?: number;
  metallic?: number;
  emission_color?: unknown;
  emission_energy?: number;
  subdivide_width?: number;
  subdivide_depth?: number;
  transaction_id?: string;
}

interface BuildSandField3DParams {
  parent_path?: string;
  field_name?: string;
  origin?: { x?: number; y?: number; z?: number } | [number, number, number];
  size?: { x?: number; y?: number; z?: number } | [number, number, number];
  create_visual?: boolean;
  create_volume_area?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  grain_spacing?: number;
  grain_radius?: number;
  jitter?: number;
  max_grains?: number;
  random_yaw?: boolean;
  seed?: number;
  grain_color?: unknown;
  grain_roughness?: number;
  grain_metallic?: number;
  profile_name?: string;
  source_reference?: string;
  internal_friction?: number;
  cohesion?: number;
  stiffness?: number;
  bulk_density?: number;
  transaction_id?: string;
}

interface BuildCave2DParams {
  parent_path?: string;
  cave_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  grid_size?: { x?: number; y?: number } | [number, number];
  cell_size?: { x?: number; y?: number } | [number, number];
  fill_ratio?: number;
  smoothing_steps?: number;
  birth_limit?: number;
  death_limit?: number;
  border_solid?: boolean;
  create_collision?: boolean;
  create_visuals?: boolean;
  create_background?: boolean;
  create_spawn_marker?: boolean;
  wall_color?: unknown;
  background_color?: unknown;
  collision_layer?: number;
  collision_mask?: number;
  seed?: number;
  transaction_id?: string;
}

interface BuildSandField2DParams {
  parent_path?: string;
  field_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  create_visual?: boolean;
  create_volume_area?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  grain_spacing?: number;
  grain_radius?: number;
  jitter?: number;
  max_grains?: number;
  random_rotation?: boolean;
  grain_segments?: number;
  seed?: number;
  grain_color?: unknown;
  profile_name?: string;
  source_reference?: string;
  internal_friction?: number;
  cohesion?: number;
  stiffness?: number;
  bulk_density?: number;
  transaction_id?: string;
}

interface GeneratePlatformerBlockout2DParams {
  parent_path?: string;
  level_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  segment_count?: number;
  min_platform_width?: number;
  max_platform_width?: number;
  platform_height?: number;
  min_gap?: number;
  max_gap?: number;
  base_y?: number;
  min_height_step?: number;
  max_height_step?: number;
  min_y?: number;
  max_y?: number;
  create_collision?: boolean;
  create_visuals?: boolean;
  create_spawn_marker?: boolean;
  create_goal_marker?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  platform_color?: unknown;
  seed?: number;
  transaction_id?: string;
}

interface GenerateTopdownDungeon2DParams {
  parent_path?: string;
  dungeon_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  grid_size?: { x?: number; y?: number } | [number, number];
  cell_size?: { x?: number; y?: number } | [number, number];
  room_attempts?: number;
  room_target?: number;
  room_min_size?: { x?: number; y?: number } | [number, number];
  room_max_size?: { x?: number; y?: number } | [number, number];
  corridor_width?: number;
  border_walls?: boolean;
  create_floor_visuals?: boolean;
  create_wall_collision?: boolean;
  create_wall_visuals?: boolean;
  create_spawn_marker?: boolean;
  create_goal_marker?: boolean;
  floor_color?: unknown;
  wall_color?: unknown;
  collision_layer?: number;
  collision_mask?: number;
  seed?: number;
  transaction_id?: string;
}

interface GenerateIsometricTileBlockout2DParams {
  parent_path?: string;
  level_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  grid_size?: { x?: number; y?: number } | [number, number];
  max_tiles?: number;
  tile_size?: { x?: number; y?: number } | [number, number];
  min_height?: number;
  max_height?: number;
  elevation_step?: number;
  noise_frequency?: number;
  fractal_octaves?: number;
  fractal_lacunarity?: number;
  fractal_gain?: number;
  noise_type?: number;
  fractal_type?: number;
  sample_offset?: { x?: number; y?: number } | [number, number];
  create_collision?: boolean;
  create_side_faces?: boolean;
  top_color?: unknown;
  left_color?: unknown;
  right_color?: unknown;
  height_tint_strength?: number;
  collision_layer?: number;
  collision_mask?: number;
  seed?: number;
  transaction_id?: string;
}

interface GenerateTentacleWaypoints2DParams {
  parent_path?: string;
  tentacle_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  waypoint_count?: number;
  segment_length?: number;
  lateral_amplitude?: number;
  wave_count?: number;
  random_jitter?: number;
  taper?: number;
  direction?: { x?: number; y?: number } | [number, number];
  create_line?: boolean;
  create_waypoint_markers?: boolean;
  create_segment_markers?: boolean;
  create_tip_marker?: boolean;
  line_color?: unknown;
  line_width_start?: number;
  line_width_end?: number;
  seed?: number;
  transaction_id?: string;
}

interface BuildCreatureParts2DParams {
  parent_path?: string;
  creature_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  scale?: number;
  include_tail?: boolean;
  include_wings?: boolean;
  include_horns?: boolean;
  create_visuals?: boolean;
  create_collision?: boolean;
  create_attachment_markers?: boolean;
  body_color?: unknown;
  accent_color?: unknown;
  collision_layer?: number;
  collision_mask?: number;
  transaction_id?: string;
}

interface BuildSlimeMoldColony2DParams {
  parent_path?: string;
  colony_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  grid_size?: { x?: number; y?: number } | [number, number];
  cell_size?: { x?: number; y?: number } | [number, number];
  initial_cell_count?: number;
  initial_radius?: number;
  spread_chance?: number;
  growth_rate?: number;
  max_cells?: number;
  create_visuals?: boolean;
  create_collision?: boolean;
  cell_color?: unknown;
  collision_layer?: number;
  collision_mask?: number;
  seed?: number;
  transaction_id?: string;
}

interface SimulateSlimeMoldGrowthStep2DParams {
  colony_path: string;
  cells_path?: string;
  grid_size?: { x?: number; y?: number } | [number, number];
  cell_size?: { x?: number; y?: number } | [number, number];
  spread_chance?: number;
  growth_rate?: number;
  max_cells?: number;
  steps?: number;
  max_new_cells_per_step?: number;
  allow_diagonal?: boolean;
  create_visuals?: boolean;
  create_collision?: boolean;
  cell_color?: unknown;
  collision_layer?: number;
  collision_mask?: number;
  seed?: number;
  transaction_id?: string;
}

interface ConfigureLightNodeParams {
  node_path: string;
  enabled?: boolean;
  color?: unknown;
  profile_name?: string;
  energy?: number;
  shadow_enabled?: boolean;
  shadow_color?: unknown;
  texture_scale?: number;
  height?: number;
  shadow_filter_smooth?: number;
  blend_mode?: number;
  range_item_cull_mask?: number;
  range_layer_min?: number;
  range_layer_max?: number;
  range_z_min?: number;
  range_z_max?: number;
  shadow_filter?: number;
  indirect_energy?: number;
  volumetric_fog_energy?: number;
  specular?: number;
  temperature?: number;
  shadow_blur?: number;
  shadow_bias?: number;
  shadow_normal_bias?: number;
  distance_fade_enabled?: boolean;
  distance_fade_begin?: number;
  distance_fade_length?: number;
  distance_fade_shadow?: number;
  cull_mask?: number;
  projector_path?: string;
  omni_range?: number;
  omni_attenuation?: number;
  spot_range?: number;
  spot_attenuation?: number;
  spot_angle?: number;
  spot_angle_attenuation?: number;
  transaction_id?: string;
}

interface BuildSmokeEffect2DParams {
  parent_path?: string;
  smoke_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  area_size?: { x?: number; y?: number } | [number, number];
  intensity?: number;
  wind_direction?: { x?: number; y?: number } | [number, number];
  wind_strength?: number;
  max_particles?: number;
  particle_lifetime?: number;
  rise_speed_min?: number;
  rise_speed_max?: number;
  spread_degrees?: number;
  rise_acceleration?: number;
  damping_min?: number;
  damping_max?: number;
  particle_scale_min?: { x?: number; y?: number } | [number, number];
  particle_scale_max?: { x?: number; y?: number } | [number, number];
  smoke_roundness?: number;
  smoke_softness?: number;
  smoke_noise_strength?: number;
  smoke_noise_scale?: number;
  smoke_texture_size?: number;
  smoke_color?: unknown;
  create_overlay?: boolean;
  overlay_density?: number;
  overlay_color?: unknown;
  canvas_layer?: number;
  particle_fixed_fps?: number;
  seed?: number;
  transaction_id?: string;
}

interface ConfigureParticles3DParams {
  node_path: string;
  emitting?: boolean;
  one_shot?: boolean;
  local_coords?: boolean;
  trail_enabled?: boolean;
  amount?: number;
  fixed_fps?: number;
  draw_order?: number;
  amount_ratio?: number;
  lifetime?: number;
  preprocess?: number;
  speed_scale?: number;
  explosiveness?: number;
  randomness?: number;
  interp_to_end?: number;
  trail_lifetime?: number;
  visibility_aabb?: {
    position?: { x?: number; y?: number; z?: number } | [number, number, number];
    size?: { x?: number; y?: number; z?: number } | [number, number, number];
    x?: number;
    y?: number;
    z?: number;
    width?: number;
    height?: number;
    depth?: number;
  };
  draw_pass_1_path?: string;
  ensure_process_material?: boolean;
  direction?: { x?: number; y?: number; z?: number } | [number, number, number];
  spread?: number;
  gravity?: { x?: number; y?: number; z?: number } | [number, number, number];
  initial_velocity_min?: number;
  initial_velocity_max?: number;
  angular_velocity_min?: number;
  angular_velocity_max?: number;
  damping_min?: number;
  damping_max?: number;
  scale_min?: number;
  scale_max?: number;
  color?: unknown;
  emission_shape?: number;
  emission_box_extents?: { x?: number; y?: number; z?: number } | [number, number, number];
  color_ramp_path?: string;
  profile_name?: string;
  transaction_id?: string;
}

interface BuildSmokeEffect3DParams {
  parent_path?: string;
  smoke_name?: string;
  position?: { x?: number; y?: number; z?: number } | [number, number, number];
  volume_size?: { x?: number; y?: number; z?: number } | [number, number, number];
  intensity?: number;
  wind_direction?: { x?: number; y?: number; z?: number } | [number, number, number];
  wind_strength?: number;
  max_particles?: number;
  particle_lifetime?: number;
  rise_speed_min?: number;
  rise_speed_max?: number;
  spread_degrees?: number;
  damping_min?: number;
  damping_max?: number;
  smoke_roundness?: number;
  smoke_softness?: number;
  smoke_noise_strength?: number;
  smoke_noise_scale?: number;
  smoke_texture_size?: number;
  smoke_color?: unknown;
  create_ground_haze?: boolean;
  haze_color?: unknown;
  particle_fixed_fps?: number;
  particle_quad_size?: number;
  seed?: number;
  transaction_id?: string;
}

interface BuildLightOccluder2DParams {
  parent_path?: string;
  occluder_name?: string;
  position?: { x?: number; y?: number } | [number, number];
  size?: { x?: number; y?: number } | [number, number];
  polygon_points?: Array<{ x?: number; y?: number } | [number, number]>;
  closed?: boolean;
  cull_mode?: number;
  occluder_light_mask?: number;
  sdf_collision?: boolean;
  transaction_id?: string;
}

interface EditLightOccluderPolygon2DParams {
  occluder_path: string;
  polygon_points?: Array<{ x?: number; y?: number } | [number, number]>;
  append_points?: Array<{ x?: number; y?: number } | [number, number]>;
  offset?: { x?: number; y?: number } | [number, number];
  closed?: boolean;
  cull_mode?: number;
  profile_name?: string;
  transaction_id?: string;
}

interface BuildSubviewportMinimapParams {
  parent_path?: string;
  minimap_name?: string;
  target_path?: string;
  mode?: 'auto' | '2d' | 'topdown3d' | 'isometric3d';
  size?: { x?: number; y?: number } | [number, number];
  margin?: number;
  anchor?: 'top_left' | 'top_right' | 'bottom_left' | 'bottom_right';
  canvas_layer?: number;
  zoom_2d?: number;
  camera_size?: number;
  camera_height?: number;
  isometric_distance?: number;
  near?: number;
  far?: number;
  transaction_id?: string;
}

interface BuildWeatherSystem2DParams {
  parent_path?: string;
  weather_name?: string;
  origin?: { x?: number; y?: number } | [number, number];
  area_size?: { x?: number; y?: number } | [number, number];
  preset?: string;
  intensity?: number;
  transition_rate?: number;
  wind_direction?: { x?: number; y?: number } | [number, number];
  wind_strength?: number;
  canvas_layer?: number;
  enable_precipitation?: boolean;
  enable_fog?: boolean;
  enable_ambient_modulate?: boolean;
  enable_lightning_overlay?: boolean;
  precipitation_mode?: string;
  precipitation_intensity_scale?: number;
  max_particles?: number;
  particle_lifetime?: number;
  particle_speed_min?: number;
  particle_speed_max?: number;
  spread_degrees?: number;
  gravity_strength?: number;
  particle_scale_min?: { x?: number; y?: number } | [number, number];
  particle_scale_max?: { x?: number; y?: number } | [number, number];
  fog_density?: number;
  fog_color?: unknown;
  ambient_color?: unknown;
  precipitation_color?: unknown;
  lightning_enabled?: boolean;
  lightning_chance?: number;
  lightning_flash_strength?: number;
  lightning_decay?: number;
  lightning_color?: unknown;
  particle_fixed_fps?: number;
  seed?: number;
  transaction_id?: string;
}

interface SimulateWeatherStep2DParams {
  weather_path: string;
  target_preset?: string;
  target_intensity?: number;
  delta?: number;
  transition_rate?: number;
  area_size?: { x?: number; y?: number } | [number, number];
  wind_direction?: { x?: number; y?: number } | [number, number];
  wind_strength?: number;
  precipitation_mode?: string;
  precipitation_intensity_scale?: number;
  max_particles?: number;
  particle_lifetime?: number;
  particle_speed_min?: number;
  particle_speed_max?: number;
  spread_degrees?: number;
  gravity_strength?: number;
  particle_scale_min?: { x?: number; y?: number } | [number, number];
  particle_scale_max?: { x?: number; y?: number } | [number, number];
  precipitation_color?: unknown;
  enable_precipitation?: boolean;
  precipitation_path?: string;
  fog_density?: number;
  fog_color?: unknown;
  enable_fog?: boolean;
  fog_overlay_path?: string;
  ambient_color?: unknown;
  enable_ambient_modulate?: boolean;
  ambient_modulate_path?: string;
  lightning_enabled?: boolean;
  lightning_chance?: number;
  lightning_flash_strength?: number;
  lightning_decay?: number;
  lightning_color?: unknown;
  enable_lightning_overlay?: boolean;
  lightning_overlay_path?: string;
  trigger_lightning?: boolean;
  seed?: number;
  transaction_id?: string;
}

interface SimulateWaterCurrentStep2DParams {
  water_path: string;
  body_path: string;
  size?: { x?: number; y?: number } | [number, number];
  flow_direction?: { x?: number; y?: number } | [number, number];
  flow_speed?: number;
  buoyancy?: number;
  drag?: number;
  delta?: number;
  flow_scale?: number;
  buoyancy_scale?: number;
  drag_scale?: number;
  sink_bias?: number;
  clamp_speed?: number;
  apply_position?: boolean;
  require_inside?: boolean;
  current_velocity?: { x?: number; y?: number } | [number, number];
  transaction_id?: string;
}

interface SimulateWaterCurrentStep3DParams {
  water_path: string;
  body_path: string;
  size?: { x?: number; y?: number } | [number, number];
  depth?: number;
  flow_direction?: { x?: number; y?: number } | [number, number];
  flow_speed?: number;
  buoyancy?: number;
  drag?: number;
  delta?: number;
  flow_scale?: number;
  buoyancy_scale?: number;
  drag_scale?: number;
  sink_bias?: number;
  clamp_speed?: number;
  apply_position?: boolean;
  require_inside?: boolean;
  preserve_vertical_velocity?: boolean;
  current_velocity?: { x?: number; y?: number; z?: number } | [number, number, number];
  transaction_id?: string;
}

interface SettleSandField3DParams {
  field_path: string;
  grains_path?: string;
  size?: { x?: number; y?: number; z?: number } | [number, number, number];
  iterations?: number;
  settle_strength?: number;
  horizontal_jitter?: number;
  downward_bias?: number;
  keep_bounds?: boolean;
  seed?: number;
  transaction_id?: string;
}

interface BuildStageBlockout2DParams {
  parent_path?: string;
  stage_name?: string;
  blocks: Array<{
    name?: string;
    position?: { x?: number; y?: number } | [number, number];
    size?: { x?: number; y?: number } | [number, number];
    collision_layer?: number;
    collision_mask?: number;
    color?: unknown;
  }>;
  create_visuals?: boolean;
  collision_layer?: number;
  collision_mask?: number;
  default_color?: unknown;
  transaction_id?: string;
}

interface BuildHudUi2DParams {
  parent_path?: string;
  hud_name?: string;
  include_health?: boolean;
  include_score?: boolean;
  include_objective?: boolean;
  include_message?: boolean;
  include_pause_button?: boolean;
  margin?: number;
  spacing?: number;
  health_text?: string;
  score_text?: string;
  objective_text?: string;
  message_text?: string;
  pause_text?: string;
  transaction_id?: string;
}

interface AuthorEnemyAi2DParams {
  enemy_path: string;
  create_navigation_agent?: boolean;
  create_vision_area?: boolean;
  create_attack_timer?: boolean;
  connect_signals?: boolean;
  movement_speed?: number;
  acceleration?: number;
  attack_cooldown?: number;
  vision_radius?: number;
  detection_group?: string;
  navigation_agent_name?: string;
  navigation_max_speed?: number;
  path_desired_distance?: number;
  target_desired_distance?: number;
  avoidance_enabled?: boolean;
  neighbor_distance?: number;
  max_neighbors?: number;
  time_horizon?: number;
  time_horizon_agents?: number;
  time_horizon_obstacles?: number;
  vision_area_name?: string;
  vision_collision_layer?: number;
  vision_collision_mask?: number;
  vision_offset?: { x?: number; y?: number } | [number, number];
  attack_timer_name?: string;
  target_path?: string;
  patrol_loop?: boolean;
  patrol_points?: Array<{ x?: number; y?: number } | [number, number]>;
  signal_target_path?: string;
  vision_entered_method?: string;
  vision_exited_method?: string;
  attack_timeout_method?: string;
  signal_deferred?: boolean;
  signal_one_shot?: boolean;
  signal_reference_counted?: boolean;
  transaction_id?: string;
}

interface AuthorEnemyAi3DParams {
  enemy_path: string;
  create_navigation_agent?: boolean;
  create_vision_area?: boolean;
  create_attack_timer?: boolean;
  connect_signals?: boolean;
  movement_speed?: number;
  acceleration?: number;
  attack_cooldown?: number;
  vision_radius?: number;
  detection_group?: string;
  navigation_agent_name?: string;
  navigation_max_speed?: number;
  path_desired_distance?: number;
  target_desired_distance?: number;
  avoidance_enabled?: boolean;
  neighbor_distance?: number;
  max_neighbors?: number;
  agent_radius?: number;
  agent_height?: number;
  vision_area_name?: string;
  vision_collision_layer?: number;
  vision_collision_mask?: number;
  vision_offset?: { x?: number; y?: number; z?: number } | [number, number, number];
  attack_timer_name?: string;
  target_path?: string;
  patrol_loop?: boolean;
  patrol_points?: Array<{ x?: number; y?: number; z?: number } | [number, number, number]>;
  signal_target_path?: string;
  vision_entered_method?: string;
  vision_exited_method?: string;
  attack_timeout_method?: string;
  signal_deferred?: boolean;
  signal_one_shot?: boolean;
  signal_reference_counted?: boolean;
  transaction_id?: string;
}

interface BuildMenuUiFlow2DParams {
  parent_path?: string;
  flow_name?: string;
  include_pause_menu?: boolean;
  include_game_over_menu?: boolean;
  create_background?: boolean;
  background_color?: unknown;
  panel_size?: { x?: number; y?: number } | [number, number];
  title_text?: string;
  start_text?: string;
  quit_text?: string;
  pause_title_text?: string;
  resume_text?: string;
  pause_restart_text?: string;
  pause_quit_text?: string;
  game_over_title_text?: string;
  retry_text?: string;
  game_over_quit_text?: string;
  connect_signals?: boolean;
  controller_path?: string;
  start_pressed_method?: string;
  quit_pressed_method?: string;
  resume_pressed_method?: string;
  pause_restart_pressed_method?: string;
  pause_quit_pressed_method?: string;
  retry_pressed_method?: string;
  game_over_quit_pressed_method?: string;
  signal_deferred?: boolean;
  signal_one_shot?: boolean;
  signal_reference_counted?: boolean;
  transaction_id?: string;
}

interface SetMenuUiFlowStateParams {
  flow_path: string;
  state: 'main' | 'pause' | 'game_over' | 'gameover' | 'hidden';
  transaction_id?: string;
}

interface RenameNodeParams {
  node_path: string;
  new_name: string;
  transaction_id?: string;
}

interface NodeGroupParams {
  node_path: string;
  group_name: string;
  persistent?: boolean;
  transaction_id?: string;
}

interface RemoveNodeGroupParams extends NodeGroupParams {
  persistent?: boolean;
}

interface ListNodeGroupsParams {
  node_path: string;
}

interface ListNodesInGroupParams {
  group_name: string;
}

interface ConfigureCamera2DLimitsParams {
  node_path: string;
  transaction_id?: string;
  limits?: {
    enabled?: boolean;
    draw_limits?: boolean;
    smoothed?: boolean;
    left?: number;
    right?: number;
    top?: number;
    bottom?: number;
  };
  smoothing?: {
    position_enabled?: boolean;
    position_speed?: number;
    rotation_enabled?: boolean;
    rotation_speed?: number;
  };
}

const hasConfigurationEntries = (value: Record<string, unknown> | undefined): value is Record<string, unknown> =>
  !!value && Object.values(value).some(entry => entry !== undefined);

interface ThemeOverrideParams {
  node_path: string;
  override_type: 'color' | 'constant' | 'font' | 'font_size' | 'stylebox' | 'icon';
  override_name: string;
  value?: unknown;
  resource_path?: string;
  transaction_id?: string;
}

interface WireSignalHandlerParams {
  source_path: string;
  signal_name: string;
  target_path: string;
  method_name: string;
  script_path?: string;
  create_script?: boolean;
  arguments?: string[];
  binds?: unknown[];
  deferred?: boolean;
  one_shot?: boolean;
  reference_counted?: boolean;
  transaction_id?: string;
}

interface LayoutUiGridParams {
  container_path: string;
  columns?: number;
  horizontal_gap?: number;
  vertical_gap?: number;
  cell_size?: { x?: number; y?: number } | [number, number];
  size_flags?: { horizontal?: number; vertical?: number };
  transaction_id?: string;
}

interface ValidateAccessibilityParams {
  root_path?: string;
  include_hidden?: boolean;
  max_depth?: number;
}

const camera2DLimitsSchema = z
  .object({
    enabled: z.boolean().optional().describe('Enable or disable Camera2D limits.'),
    draw_limits: z.boolean().optional().describe('Toggle visualization of Camera2D limits in the editor.'),
    smoothed: z.boolean().optional().describe('Enable smoothing when the camera hits configured limits.'),
    left: z.number().int().optional().describe('Left boundary in pixels.'),
    right: z.number().int().optional().describe('Right boundary in pixels.'),
    top: z.number().int().optional().describe('Top boundary in pixels.'),
    bottom: z.number().int().optional().describe('Bottom boundary in pixels.'),
  })
  .refine(value => Object.values(value).some(entry => entry !== undefined), {
    message: 'Provide at least one limit property to update.',
  });

const camera2DSmoothingSchema = z
  .object({
    position_enabled: z.boolean().optional().describe('Enable position smoothing for Camera2D.'),
    position_speed: z
      .number()
      .nonnegative()
      .optional()
      .describe('Smoothing speed used when moving towards the target position.'),
    rotation_enabled: z.boolean().optional().describe('Enable rotation smoothing for Camera2D.'),
    rotation_speed: z
      .number()
      .nonnegative()
      .optional()
      .describe('Smoothing speed used when rotating towards the target angle.'),
  })
  .refine(value => Object.values(value).some(entry => entry !== undefined), {
    message: 'Provide at least one smoothing property to update.',
  });

const vector2ParamSchema = z.union([
  z.object({ x: z.number().optional(), y: z.number().optional() }),
  z.tuple([z.number(), z.number()]),
]);

const vector3ParamSchema = z.union([
  z.object({ x: z.number().optional(), y: z.number().optional(), z: z.number().optional() }),
  z.tuple([z.number(), z.number(), z.number()]),
]);

/**
 * Definition for node tools - operations that manipulate nodes in the scene tree
 */
export const nodeTools: MCPTool[] = [
  {
    name: 'create_node',
    description: 'Create a new node in the Godot scene tree',
    parameters: z.object({
      parent_path: z.string()
        .describe('Path to the parent node where the new node will be created (e.g. "/root", "/root/MainScene")'),
      node_type: z.string()
        .describe('Type of node to create (e.g. "Node2D", "Sprite2D", "Label")'),
      node_name: z.string()
        .describe('Name for the new node'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ parent_path, node_type, node_name, transaction_id }: CreateNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('create_node', {
          parent_path,
          node_type,
          node_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        return `Created ${node_type} node named "${node_name}" at ${result.node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to create node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'delete_node',
    description: 'Delete a node from the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to delete (e.g. "/root/MainScene/Player")'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ node_path, transaction_id }: DeleteNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('delete_node', { node_path, transaction_id });
        const status = (result?.status as string) ?? 'committed';
        return `Deleted node at ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to delete node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'update_node_property',
    description: 'Update a property of a node in the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to update (e.g. "/root/MainScene/Player")'),
      property: z.string()
        .describe('Name of the property to update (e.g. "position", "text", "modulate")'),
      value: z.any()
        .describe('New value for the property'),
      transaction_id: z.string().optional()
        .describe('Optional transaction identifier to batch multiple scene operations before committing'),
    }),
    execute: async ({ node_path, property, value, transaction_id }: UpdateNodePropertyParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('update_node_property', {
          node_path,
          property,
          value,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        return `Updated property "${property}" of node at ${node_path} to ${JSON.stringify(value)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to update node property: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },

  {
    name: 'get_node_properties',
    description: 'Get all properties of a node in the Godot scene tree',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to inspect (e.g. "/root/MainScene/Player")'),
    }),
    execute: async ({ node_path }: GetNodePropertiesParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('get_node_properties', { node_path });
        
        // Format properties for display
        const formattedProperties = Object.entries(result.properties)
          .map(([key, value]) => `${key}: ${JSON.stringify(value)}`)
          .join('\n');
        
        return `Properties of node at ${node_path}:\n\n${formattedProperties}`;
      } catch (error) {
        throw new Error(`Failed to get node properties: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },

  {
    name: 'list_nodes',
    description: 'List all child nodes under a parent node in the Godot scene tree',
    parameters: z.object({
      parent_path: z.string()
        .describe('Path to the parent node (e.g. "/root", "/root/MainScene")'),
    }),
    execute: async ({ parent_path }: ListNodesParams): Promise<string> => {
      const godot = getGodotConnection();
      
      try {
        const result = await godot.sendCommand<CommandResult>('list_nodes', { parent_path });
        
        if (result.children.length === 0) {
          return `No child nodes found under ${parent_path}`;
        }
        
        // Format children for display
        const formattedChildren = result.children
          .map((child: any) => `${child.name} (${child.type}) - ${child.path}`)
          .join('\n');
        
        return `Children of node at ${parent_path}:\n\n${formattedChildren}`;
      } catch (error) {
        throw new Error(`Failed to list nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'duplicate_node',
    description: 'Duplicate an existing node subtree with configurable copy flags',
    parameters: z.object({
      source_path: z.string()
        .describe('Path to the node that should be duplicated'),
      parent_path: z.string().optional()
        .describe('Optional target parent path (defaults to the source parent)'),
      new_name: z.string().optional()
        .describe('Optional name for the duplicated node'),
      duplicate_groups: z.boolean().optional()
        .describe('Copy group membership (default true)'),
      duplicate_signals: z.boolean().optional()
        .describe('Copy signal connections (default true)'),
      duplicate_scripts: z.boolean().optional()
        .describe('Copy attached scripts (default true)'),
      use_instantiation: z.boolean().optional()
        .describe('Use scene instantiation semantics when duplicating subtrees'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      source_path,
      parent_path,
      new_name,
      duplicate_groups,
      duplicate_signals,
      duplicate_scripts,
      use_instantiation,
      transaction_id,
    }: DuplicateNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('duplicate_node', {
          source_path,
          parent_path,
          new_name,
          duplicate_groups,
          duplicate_signals,
          duplicate_scripts,
          use_instantiation,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const resolvedPath = (result.node_path as string) ?? source_path;
        const resolvedName = (result.node_name as string) ?? new_name ?? 'copy';
        return `Duplicated ${source_path} as ${resolvedName} at ${resolvedPath} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to duplicate node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'reparent_node',
    description: 'Move a node to a different parent with optional rename and index control',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to move'),
      new_parent_path: z.string()
        .describe('Path to the new parent node'),
      keep_global_transform: z.boolean().optional()
        .describe('Preserve global transform while reparenting (default true)'),
      new_name: z.string().optional()
        .describe('Optional new node name when moved under the new parent'),
      child_index: z.number().int().min(0).optional()
        .describe('Optional index in the new parent child list'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      new_parent_path,
      keep_global_transform,
      new_name,
      child_index,
      transaction_id,
    }: ReparentNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('reparent_node', {
          node_path,
          new_parent_path,
          keep_global_transform,
          new_name,
          child_index,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} is already at the requested parent and ordering.`;
        }

        const resolvedPath = (result.node_path as string) ?? node_path;
        const resolvedParent = (result.new_parent_path as string) ?? new_parent_path;
        const resolvedIndex = result.new_index ?? child_index ?? 'auto';
        return `Reparented ${resolvedPath} to ${resolvedParent} at index ${resolvedIndex} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to reparent node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'move_node_in_parent',
    description: 'Reorder a node within its current parent',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should be reordered'),
      index: z.number().int().min(0)
        .describe('Target index in the parent child array'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, index, transaction_id }: MoveNodeInParentParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('move_node_in_parent', {
          node_path,
          index,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} is already at index ${result.index ?? index}.`;
        }

        const resolvedPath = (result.node_path as string) ?? node_path;
        const resolvedIndex = result.index ?? index;
        return `Moved ${resolvedPath} to index ${resolvedIndex} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to move node in parent: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'instantiate_scene',
    description: 'Instantiate a PackedScene and add it under a parent node',
    parameters: z.object({
      scene_path: z.string()
        .describe('PackedScene resource path (e.g. "res://scenes/enemy.tscn")'),
      parent_path: z.string().optional()
        .describe('Optional parent node path (defaults to "/root")'),
      node_name: z.string().optional()
        .describe('Optional name for the instantiated root node'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ scene_path, parent_path, node_name, transaction_id }: InstantiateSceneParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('instantiate_scene', {
          scene_path,
          parent_path,
          node_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const resolvedPath = (result.node_path as string) ?? `${parent_path ?? '/root'}/${node_name ?? 'Instance'}`;
        return `Instantiated ${scene_path} at ${resolvedPath} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to instantiate scene: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'query_nodes',
    description: 'Search scene nodes by name, type, and group filters',
    parameters: z.object({
      root_path: z.string().optional()
        .describe('Optional root path to search from (defaults to "/root")'),
      name_contains: z.string().optional()
        .describe('Match nodes whose names contain this text (case-insensitive)'),
      node_type: z.string().optional()
        .describe('Match nodes by class name (supports inherited classes)'),
      group_name: z.string().optional()
        .describe('Match nodes in a specific group'),
      include_root: z.boolean().optional()
        .describe('Include the root node in the query evaluation (default true)'),
      include_internal: z.boolean().optional()
        .describe('Include internal children in traversal (default false)'),
      max_results: z.number().int().min(1).max(5000).optional()
        .describe('Maximum number of matched nodes to return (default 500)'),
    }),
    execute: async ({
      root_path,
      name_contains,
      node_type,
      group_name,
      include_root,
      include_internal,
      max_results,
    }: QueryNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('query_nodes', {
          root_path,
          name_contains,
          node_type,
          group_name,
          include_root,
          include_internal,
          max_results,
        });

        const nodes = (result.nodes as Array<Record<string, unknown>>) ?? [];
        const count = Number(result.count ?? nodes.length);
        const target = (result.root_path as string) ?? root_path ?? '/root';
        if (nodes.length === 0) {
          return `No nodes matched the query under ${target}.`;
        }

        const lines = nodes
          .map(node => `${node.name} (${node.type}) - ${node.path}`)
          .join('\n');
        const truncated = Boolean(result.truncated);
        return `Query matched ${count} node(s) under ${target}${truncated ? ' (truncated)' : ''}:\n${lines}`;
      } catch (error) {
        throw new Error(`Failed to query nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'bulk_update_node_properties',
    description: 'Apply multiple node property updates in one undo-aware operation',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node to update'),
      properties: z.record(z.any())
        .refine(value => Object.keys(value).length > 0, {
          message: 'Provide at least one property update.',
        })
        .describe('Property map where keys are property paths (e.g. "position.x")'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, properties, transaction_id }: BulkUpdateNodePropertiesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('bulk_update_node_properties', {
          node_path,
          properties,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Bulk update on ${node_path} had no effective property changes.`;
        }

        const changes = (result.changes as Array<Record<string, unknown>>) ?? [];
        return `Bulk updated ${node_path} with ${changes.length} property change(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to bulk update node properties: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'batch_create_nodes',
    description: 'Create multiple child nodes in one undo-aware operation',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path where all nodes should be created (defaults to "/root")'),
      nodes: z.array(z.object({
        node_type: z.string()
          .describe('Godot node type such as Node2D, Node3D, Label, etc.'),
        node_name: z.string().optional()
          .describe('Optional preferred node name; the server will resolve conflicts.'),
        properties: z.record(z.any()).optional()
          .describe('Optional property map applied to the node after instantiation.'),
      })).min(1)
        .describe('List of nodes to create'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ parent_path, nodes, transaction_id }: BatchCreateNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('batch_create_nodes', {
          parent_path,
          nodes,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const count = Number(result.count ?? (Array.isArray(result.created_nodes) ? result.created_nodes.length : nodes.length));
        const resolvedParent = (result.parent_path as string) ?? parent_path ?? '/root';
        return `Batch created ${count} node(s) under ${resolvedParent} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to batch create nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'batch_delete_nodes',
    description: 'Delete multiple nodes in one undo-aware operation',
    parameters: z.object({
      node_paths: z.array(z.string()).min(1)
        .describe('Node paths to delete'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_paths, transaction_id }: BatchDeleteNodesParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('batch_delete_nodes', {
          node_paths,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const deletedCount = Number(result.deleted_count ?? 0);
        const skipped = Array.isArray(result.skipped_descendants) ? result.skipped_descendants.length : 0;
        return `Batch deleted ${deletedCount} node(s) [${status}]${skipped > 0 ? `; skipped ${skipped} descendant duplicates` : ''}`;
      } catch (error) {
        throw new Error(`Failed to batch delete nodes: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_node_script',
    description: 'Assign a script resource to a node with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Node path to receive the script'),
      script_path: z.string()
        .describe('Script resource path in the project (res://...)'),
      create_script: z.boolean().optional()
        .describe('Create the script file if it does not exist'),
      extends_type: z.string().optional()
        .describe('Extends type used when creating a new script'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      script_path,
      create_script,
      extends_type,
      transaction_id,
    }: SetNodeScriptParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_node_script', {
          node_path,
          script_path,
          create_script,
          extends_type,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} already uses script ${script_path}.`;
        }
        return `Assigned script ${script_path} to ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set node script: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'clear_node_script',
    description: 'Remove the assigned script from a node',
    parameters: z.object({
      node_path: z.string()
        .describe('Node path whose script should be cleared'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, transaction_id }: ClearNodeScriptParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('clear_node_script', {
          node_path,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node ${node_path} does not have an assigned script.`;
        }
        return `Cleared script from ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to clear node script: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_node_owner_recursive',
    description: 'Set owner for a node subtree so edits persist in the scene file',
    parameters: z.object({
      node_path: z.string()
        .describe('Root node of the subtree to update'),
      owner_path: z.string().optional()
        .describe('Owner node path (defaults to "/root")'),
      include_root: z.boolean().optional()
        .describe('Whether to apply owner changes to the root node itself (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({
      node_path,
      owner_path,
      include_root,
      transaction_id,
    }: SetNodeOwnerRecursiveParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_node_owner_recursive', {
          node_path,
          owner_path,
          include_root,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changedCount = Number(result.changed_count ?? 0);
        if (status === 'no_change') {
          return `Node ownership under ${node_path} already matches ${result.owner_path ?? owner_path ?? '/root'}.`;
        }
        return `Updated owner for ${changedCount} node(s) under ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set node owner recursively: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'paint_tilemap_cells_2d',
    description: 'Paint TileMapLayer or TileMap cells for 2D level authoring',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to a TileMapLayer or TileMap node'),
      layer: z.number().int().min(0).optional()
        .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
      cells: z.array(z.object({
        position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        x: z.number().optional(),
        y: z.number().optional(),
        source_id: z.number().int(),
        atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        alternative_tile: z.number().int().optional(),
      })).min(1)
        .describe('Cell paint operations'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, layer, cells, transaction_id }: PaintTileMapCells2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('paint_tilemap_cells_2d', {
          node_path,
          layer,
          cells,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `Tile paint on ${node_path} produced no effective changes.`;
        }
        return `Painted ${changed} TileMap cell(s) on ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to paint TileMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'clear_tilemap_cells_2d',
    description: 'Clear TileMapLayer or TileMap cells for 2D level authoring',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to a TileMapLayer or TileMap node'),
      layer: z.number().int().min(0).optional()
        .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
      cells: z.array(z.union([
        z.object({
          position: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
          coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
          x: z.number().optional(),
          y: z.number().optional(),
        }),
        z.tuple([z.number(), z.number()]),
      ])).min(1)
        .describe('Cell coordinates to clear'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, layer, cells, transaction_id }: ClearTileMapCells2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('clear_tilemap_cells_2d', {
          node_path,
          layer,
          cells,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `Tile clear on ${node_path} produced no effective changes.`;
        }
        return `Cleared ${changed} TileMap cell(s) on ${node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to clear TileMap cells: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_camera2d_follow',
    description: 'Configure Camera2D follow behavior for 2D gameplay',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Camera2D node'),
      zoom: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      enabled: z.boolean().optional(),
      ignore_rotation: z.boolean().optional(),
      position_smoothing_enabled: z.boolean().optional(),
      position_smoothing_speed: z.number().optional(),
      rotation_smoothing_enabled: z.boolean().optional(),
      rotation_smoothing_speed: z.number().optional(),
      drag_enabled: z.object({ horizontal: z.boolean().optional(), vertical: z.boolean().optional() }).optional(),
      drag_margins: z.object({ left: z.number().optional(), right: z.number().optional(), top: z.number().optional(), bottom: z.number().optional() }).optional(),
      drag_offsets: z.object({ horizontal: z.number().optional(), vertical: z.number().optional() }).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCamera2DFollowParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_camera2d_follow', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Camera2D at ${args.node_path} already matches requested follow settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Camera2D follow on ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Camera2D follow: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_animation_tree_state',
    description: 'Set AnimationTree state machine playback state and optional runtime flags',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the AnimationTree node'),
      state_name: z.string().min(1)
        .describe('AnimationNodeStateMachine state name to travel/start'),
      active: z.boolean().optional(),
      process_callback: z.number().int().optional(),
      use_start: z.boolean().optional()
        .describe('Use AnimationNodeStateMachinePlayback.start instead of travel'),
      reset_on_teleport: z.boolean().optional()
        .describe('Reset animation when using start (default true)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SetAnimationTreeStateParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_animation_tree_state', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `AnimationTree at ${args.node_path} is already in state ${args.state_name}.`;
        }
        const currentState = String(result.current_state ?? args.state_name);
        return `Set AnimationTree state on ${args.node_path} to ${currentState} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set AnimationTree state: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_animation_tree_parameters',
    description: 'Set AnimationTree parameter values (for blend trees, transitions, and one-shots)',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the AnimationTree node'),
      parameters: z.record(z.unknown()).refine(value => Object.keys(value).length > 0, {
        message: 'parameters must contain at least one key',
      })
        .describe('AnimationTree parameter path/value map (e.g. "parameters/run_blend/blend_amount": 0.8)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SetAnimationTreeParametersParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_animation_tree_parameters', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `AnimationTree parameters at ${args.node_path} already match requested values.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Set ${changed} AnimationTree parameter(s) on ${args.node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set AnimationTree parameters: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_wave_spawner_2d',
    description: 'Build a 2D wave spawner scaffold with optional spawn markers and timer metadata',
    parameters: z.object({
      parent_path: z.string().optional(),
      spawner_name: z.string().optional(),
      spawn_points: z.array(vector2ParamSchema).optional(),
      create_timer: z.boolean().optional(),
      timer_name: z.string().optional(),
      create_spawn_nodes: z.boolean().optional(),
      spawn_nodes_parent_name: z.string().optional(),
      wave_interval: z.number().nonnegative().optional(),
      enemies_per_wave: z.number().int().positive().optional(),
      max_waves: z.number().int().positive().optional(),
      current_wave: z.number().int().nonnegative().optional(),
      auto_start: z.boolean().optional(),
      enemy_scene_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildWaveSpawner2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_wave_spawner_2d', args);
        const status = (result.status as string) ?? 'committed';
        const spawnerPath = String(result.spawner_path ?? 'unknown');
        const spawnPointCount = Number(
          result.spawn_point_count ?? (Array.isArray(result.spawn_points) ? result.spawn_points.length : 0),
        );
        return `Built 2D wave spawner at ${spawnerPath} (${spawnPointCount} spawn points) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build wave spawner 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_wave_spawner_3d',
    description: 'Build a 3D wave spawner scaffold with optional spawn markers and timer metadata',
    parameters: z.object({
      parent_path: z.string().optional(),
      spawner_name: z.string().optional(),
      spawn_points: z.array(vector3ParamSchema).optional(),
      create_timer: z.boolean().optional(),
      timer_name: z.string().optional(),
      create_spawn_nodes: z.boolean().optional(),
      spawn_nodes_parent_name: z.string().optional(),
      wave_interval: z.number().nonnegative().optional(),
      enemies_per_wave: z.number().int().positive().optional(),
      max_waves: z.number().int().positive().optional(),
      current_wave: z.number().int().nonnegative().optional(),
      auto_start: z.boolean().optional(),
      enemy_scene_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildWaveSpawner3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_wave_spawner_3d', args);
        const status = (result.status as string) ?? 'committed';
        const spawnerPath = String(result.spawner_path ?? 'unknown');
        const spawnPointCount = Number(
          result.spawn_point_count ?? (Array.isArray(result.spawn_points) ? result.spawn_points.length : 0),
        );
        return `Built 3D wave spawner at ${spawnerPath} (${spawnPointCount} spawn points) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build wave spawner 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_wave_spawner_step_2d',
    description: 'Run one 2D wave spawner step and optionally instantiate enemy scenes',
    parameters: z.object({
      spawner_path: z.string()
        .describe('Path to the 2D spawner node'),
      spawn_count: z.number().int().positive().optional(),
      advance_wave: z.boolean().optional(),
      instantiate_enemy: z.boolean().optional(),
      enemy_scene_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateWaveSpawnerStep2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_wave_spawner_step_2d', args);
        const status = (result.status as string) ?? 'committed';
        const spawnCount = Number(result.spawn_count ?? 0);
        const nextWave = Number(result.next_wave ?? 0);
        return `Simulated 2D wave step at ${args.spawner_path} -> spawned ${spawnCount}, next_wave=${nextWave} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate wave spawner step 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_wave_spawner_step_3d',
    description: 'Run one 3D wave spawner step and optionally instantiate enemy scenes',
    parameters: z.object({
      spawner_path: z.string()
        .describe('Path to the 3D spawner node'),
      spawn_count: z.number().int().positive().optional(),
      advance_wave: z.boolean().optional(),
      instantiate_enemy: z.boolean().optional(),
      enemy_scene_path: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateWaveSpawnerStep3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_wave_spawner_step_3d', args);
        const status = (result.status as string) ?? 'committed';
        const spawnCount = Number(result.spawn_count ?? 0);
        const nextWave = Number(result.next_wave ?? 0);
        return `Simulated 3D wave step at ${args.spawner_path} -> spawned ${spawnCount}, next_wave=${nextWave} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate wave spawner step 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_camera2d_shake',
    description: 'Apply deterministic or randomized Camera2D shake offsets for gamefeel testing',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Camera2D node'),
      trauma: z.number().min(0).max(1).optional(),
      amplitude: z.number().nonnegative().optional(),
      rotation_amplitude_degrees: z.number().nonnegative().optional(),
      add_to_existing: z.boolean().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateCamera2DShakeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_camera2d_shake', args);
        const status = (result.status as string) ?? 'committed';
        const offset = result.offset ? JSON.stringify(result.offset) : 'unknown';
        const rotation = Number(result.rotation_radians ?? 0);
        return `Simulated Camera2D shake on ${args.node_path} [${status}] -> offset=${offset}, rotation=${rotation.toFixed(4)}`;
      } catch (error) {
        throw new Error(`Failed to simulate Camera2D shake: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_camera3d_shake',
    description: 'Apply deterministic or randomized Camera3D shake offsets, roll, and optional FOV pulse',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Camera3D node'),
      trauma: z.number().min(0).max(1).optional(),
      horizontal_amplitude: z.number().nonnegative().optional(),
      vertical_amplitude: z.number().nonnegative().optional(),
      roll_amplitude_degrees: z.number().nonnegative().optional(),
      fov_pulse: z.number().nonnegative().optional(),
      add_to_existing: z.boolean().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateCamera3DShakeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_camera3d_shake', args);
        const status = (result.status as string) ?? 'committed';
        const rotation = result.rotation ? JSON.stringify(result.rotation) : 'unknown';
        const hOffset = Number(result.h_offset ?? 0);
        const vOffset = Number(result.v_offset ?? 0);
        const fov = Number(result.fov ?? 0);
        return `Simulated Camera3D shake on ${args.node_path} [${status}] -> h_offset=${hOffset.toFixed(4)}, v_offset=${vOffset.toFixed(4)}, fov=${fov.toFixed(3)}, rotation=${rotation}`;
      } catch (error) {
        throw new Error(`Failed to simulate Camera3D shake: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_parallax_2d',
    description: 'Configure Parallax2D scrolling properties for layered backgrounds',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Parallax2D node'),
      scroll_scale: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      scroll_offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      autoscroll: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      repeat_size: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      follow_viewport: z.boolean().optional(),
      ignore_camera_scroll: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureParallax2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_parallax_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Parallax2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Parallax2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Parallax2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_animated_sprite_2d',
    description: 'Configure AnimatedSprite2D resources and playback-related properties',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the AnimatedSprite2D node'),
      sprite_frames_path: z.string().optional()
        .describe('Optional SpriteFrames resource path (res://...)'),
      animation: z.string().optional()
        .describe('Animation name from the SpriteFrames resource'),
      autoplay: z.string().optional()
        .describe('Autoplay animation name'),
      speed_scale: z.number().optional(),
      centered: z.boolean().optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      flip_h: z.boolean().optional(),
      flip_v: z.boolean().optional(),
      frame: z.number().int().optional(),
      frame_progress: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureAnimatedSprite2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_animated_sprite_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `AnimatedSprite2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured AnimatedSprite2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure AnimatedSprite2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_sprite_2d',
    description: 'Configure Sprite2D texture and rendering properties',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Sprite2D node'),
      texture_path: z.string().optional()
        .describe('Texture2D resource path (res://...) or empty string to clear'),
      centered: z.boolean().optional(),
      offset: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      flip_h: z.boolean().optional(),
      flip_v: z.boolean().optional(),
      hframes: z.number().int().min(1).optional(),
      vframes: z.number().int().min(1).optional(),
      frame: z.number().int().min(0).optional(),
      frame_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
      region_enabled: z.boolean().optional(),
      region_filter_clip_enabled: z.boolean().optional(),
      region_rect: z.union([
        z.object({
          position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          x: z.number().optional(),
          y: z.number().optional(),
          width: z.number().optional(),
          height: z.number().optional(),
        }),
        z.tuple([z.number(), z.number(), z.number(), z.number()]),
      ]).optional(),
      modulate: z.any().optional(),
      self_modulate: z.any().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureSprite2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_sprite_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Sprite2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Sprite2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Sprite2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_characterbody2d_controller',
    description: 'Configure CharacterBody2D movement/controller properties for 2D platformers',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody2D node'),
      up_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      motion_mode: z.number().int().optional(),
      floor_stop_on_slope: z.boolean().optional(),
      floor_constant_speed: z.boolean().optional(),
      floor_block_on_wall: z.boolean().optional(),
      floor_snap_length: z.number().optional(),
      floor_max_angle: z.number().optional(),
      wall_min_slide_angle: z.number().optional(),
      max_slides: z.number().int().min(1).optional(),
      safe_margin: z.number().nonnegative().optional(),
      slide_on_ceiling: z.boolean().optional(),
      platform_on_leave: z.number().int().optional(),
      platform_floor_layers: z.number().int().optional(),
      platform_wall_layers: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCharacterBody2DControllerParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_characterbody2d_controller', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `CharacterBody2D at ${args.node_path} already matches requested controller settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured CharacterBody2D controller at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure CharacterBody2D controller: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_area2d_sensor',
    description: 'Configure Area2D sensor/field behavior for triggers and environmental effects',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Area2D node'),
      monitoring: z.boolean().optional(),
      monitorable: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      priority: z.number().optional(),
      gravity_space_override: z.number().int().optional(),
      gravity_point: z.boolean().optional(),
      gravity_point_center: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      gravity_point_unit_distance: z.number().optional(),
      gravity_direction: z.union([z.object({ x: z.number().optional(), y: z.number().optional() }), z.tuple([z.number(), z.number()])]).optional(),
      gravity: z.number().optional(),
      linear_damp_space_override: z.number().int().optional(),
      linear_damp: z.number().optional(),
      angular_damp_space_override: z.number().int().optional(),
      angular_damp: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureArea2DSensorParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_area2d_sensor', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Area2D at ${args.node_path} already matches requested sensor settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Area2D sensor at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Area2D sensor: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'fill_tilemap_rect_2d',
    description: 'Fill or clear a rectangular TileMap region for rapid 2D level layout',
    parameters: z
      .object({
        node_path: z.string()
          .describe('Path to a TileMapLayer or TileMap node'),
        layer: z.number().int().min(0).optional()
          .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
        origin: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
          .describe('Rectangle origin in cell coordinates'),
        size: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional()
          .describe('Rectangle size in cell units'),
        rect: z.union([
          z.object({
            position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            x: z.number().optional(),
            y: z.number().optional(),
            width: z.number().optional(),
            height: z.number().optional(),
          }),
          z.tuple([z.number(), z.number(), z.number(), z.number()]),
        ]).optional()
          .describe('Alternative rectangle descriptor'),
        clear: z.boolean().optional()
          .describe('Clear cells instead of painting tile values'),
        source_id: z.number().int().optional()
          .describe('Tile source id (required unless clear=true)'),
        atlas_coords: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])]).optional(),
        alternative_tile: z.number().int().optional(),
        transaction_id: z.string().optional(),
      })
      .superRefine((value, ctx) => {
        if (!value.rect && (!value.origin || !value.size)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide either rect or both origin and size.',
            path: ['rect'],
          });
        }
        if (!value.clear && value.source_id === undefined) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'source_id is required unless clear=true.',
            path: ['source_id'],
          });
        }
      }),
    execute: async (args: FillTileMapRect2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('fill_tilemap_rect_2d', args);
        const status = (result.status as string) ?? 'committed';
        const changed = Number(result.change_count ?? 0);
        if (status === 'no_change') {
          return `TileMap fill on ${args.node_path} produced no effective changes.`;
        }
        return `${args.clear ? 'Cleared' : 'Filled'} ${changed} TileMap cell(s) on ${args.node_path} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to fill TileMap rect: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_tilemap_noise_2d',
    description: 'Procedurally fill a TileMap region from FastNoiseLite sampling for terrain and cave layouts',
    parameters: z
      .object({
        node_path: z.string()
          .describe('Path to a TileMapLayer or TileMap node'),
        layer: z.number().int().min(0).optional()
          .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
        origin: vector2ParamSchema.optional()
          .describe('Region origin in cell coordinates'),
        size: vector2ParamSchema.optional()
          .describe('Region size in cells'),
        rect: z.union([
          z.object({
            position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            x: z.number().optional(),
            y: z.number().optional(),
            width: z.number().optional(),
            height: z.number().optional(),
          }),
          z.tuple([z.number(), z.number(), z.number(), z.number()]),
        ]).optional()
          .describe('Alternative region descriptor'),
        source_id: z.number().int()
          .describe('Tile source id to paint when the noise test selects a cell'),
        atlas_coords: vector2ParamSchema.optional(),
        alternative_tile: z.number().int().optional(),
        threshold: z.number().min(-1).max(1).optional()
          .describe('Noise threshold in [-1, 1]'),
        invert: z.boolean().optional()
          .describe('Invert the threshold selection'),
        clear_unselected: z.boolean().optional()
          .describe('Clear cells that do not satisfy the threshold'),
        sample_offset: vector2ParamSchema.optional()
          .describe('Offset added to noise sample coordinates'),
        noise_seed: z.number().int().optional(),
        frequency: z.number().positive().optional(),
        fractal_octaves: z.number().int().min(1).optional(),
        fractal_lacunarity: z.number().nonnegative().optional(),
        fractal_gain: z.number().nonnegative().optional(),
        noise_type: z.number().int().optional(),
        fractal_type: z.number().int().optional(),
        transaction_id: z.string().optional(),
      })
      .superRefine((value, ctx) => {
        if (!value.rect && (!value.origin || !value.size)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide either rect or both origin and size.',
            path: ['rect'],
          });
        }
      }),
    execute: async (args: GenerateTileMapNoise2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_tilemap_noise_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `TileMap noise generation on ${args.node_path} produced no effective changes.`;
        }
        const changed = Number(result.change_count ?? 0);
        const painted = Number(result.painted_count ?? 0);
        const cleared = Number(result.cleared_count ?? 0);
        return `Generated TileMap noise on ${args.node_path}: ${changed} changes (${painted} painted, ${cleared} cleared) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate TileMap noise: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'tilemap_terrain_autopaint_2d',
    description: 'Auto-connect/path paint TileMap terrain cells from explicit coordinates or procedural noise selections',
    parameters: z
      .object({
        node_path: z.string()
          .describe('Path to a TileMapLayer or TileMap node'),
        layer: z.number().int().min(0).optional()
          .describe('TileMap layer index (ignored for TileMapLayer nodes)'),
        terrain_set: z.number().int().min(0)
          .describe('Terrain set index in the TileSet'),
        terrain: z.number().int().min(0)
          .describe('Terrain id to paint/connect'),
        mode: z.enum(['connect', 'path']).optional()
          .describe('Autotile method: connect (blob-like) or path (ordered)'),
        cells: z.array(vector2ParamSchema).optional()
          .describe('Optional explicit terrain target cells'),
        origin: vector2ParamSchema.optional()
          .describe('Selection origin when using procedural selection'),
        size: vector2ParamSchema.optional()
          .describe('Selection size when using procedural selection'),
        rect: z.union([
          z.object({
            position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
            x: z.number().optional(),
            y: z.number().optional(),
            width: z.number().optional(),
            height: z.number().optional(),
          }),
          z.tuple([z.number(), z.number(), z.number(), z.number()]),
        ]).optional()
          .describe('Alternative selection rectangle descriptor'),
        use_noise: z.boolean().optional()
          .describe('Use noise threshold sampling when explicit cells are not provided (default true)'),
        fill_probability: z.number().min(0).max(1).optional(),
        threshold: z.number().min(-1).max(1).optional(),
        invert: z.boolean().optional(),
        sample_offset: vector2ParamSchema.optional(),
        seed: z.number().int().optional(),
        noise_seed: z.number().int().optional(),
        frequency: z.number().positive().optional(),
        fractal_octaves: z.number().int().min(1).optional(),
        fractal_lacunarity: z.number().nonnegative().optional(),
        fractal_gain: z.number().nonnegative().optional(),
        noise_type: z.number().int().optional(),
        fractal_type: z.number().int().optional(),
        ignore_empty_terrains: z.boolean().optional(),
        clear_unselected: z.boolean().optional(),
        neighbor_margin: z.number().int().min(0).optional(),
        preview_only: z.boolean().optional(),
        transaction_id: z.string().optional(),
      })
      .superRefine((value, ctx) => {
        if (!value.cells && !value.rect && (!value.origin || !value.size)) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide cells, or provide rect, or provide both origin and size.',
            path: ['cells'],
          });
        }
      }),
    execute: async (args: TilemapTerrainAutopaint2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('tilemap_terrain_autopaint_2d', args);
        const status = (result.status as string) ?? 'committed';
        const selected = Number(result.selected_count ?? 0);
        if (status === 'preview') {
          return `Previewed terrain autopaint on ${args.node_path} with ${selected} selected cell(s).`;
        }
        if (status === 'no_change') {
          return `Terrain autopaint on ${args.node_path} produced no effective changes.`;
        }
        const changed = Number(result.changed_count ?? 0);
        return `Auto-painted terrain on ${args.node_path}: selected=${selected}, changed=${changed} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to autopaint TileMap terrain: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_heightmap_gridmap_3d',
    description: 'Procedurally generate GridMap cell heights from FastNoiseLite for blockout terrain',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the GridMap node'),
      origin: vector3ParamSchema.optional()
        .describe('Origin of the generated area'),
      size: z.union([z.object({ x: z.number(), y: z.number() }), z.tuple([z.number(), z.number()])])
        .describe('Generation footprint on XZ axes'),
      item_id: z.number().int().min(0)
        .describe('MeshLibrary item id to place'),
      orientation: z.number().int().optional(),
      min_height: z.number().int().optional(),
      max_height: z.number().int().optional(),
      surface_only: z.boolean().optional()
        .describe('Place only the top surface cell for each column'),
      clear_unselected: z.boolean().optional()
        .describe('Clear cells that are outside the generated column profile'),
      sample_offset: vector2ParamSchema.optional(),
      noise_seed: z.number().int().optional(),
      frequency: z.number().positive().optional(),
      fractal_octaves: z.number().int().min(1).optional(),
      fractal_lacunarity: z.number().nonnegative().optional(),
      fractal_gain: z.number().nonnegative().optional(),
      noise_type: z.number().int().optional(),
      fractal_type: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: GenerateHeightmapGridMap3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_heightmap_gridmap_3d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `GridMap heightmap generation on ${args.node_path} produced no effective changes.`;
        }
        const changed = Number(result.change_count ?? 0);
        const placed = Number(result.placed_count ?? 0);
        const cleared = Number(result.cleared_count ?? 0);
        return `Generated GridMap heightmap on ${args.node_path}: ${changed} changes (${placed} placed, ${cleared} cleared) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate GridMap heightmap: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'scatter_scene_instances_2d',
    description: 'Procedurally scatter PackedScene Node2D instances across a 2D region',
    parameters: z.object({
      parent_path: z.string().optional(),
      scene_path: z.string()
        .describe('PackedScene path (res://...) to instantiate'),
      count: z.number().int().positive().optional(),
      rect: z.union([
        z.object({
          position: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          size: z.object({ x: z.number().optional(), y: z.number().optional() }).optional(),
          x: z.number().optional(),
          y: z.number().optional(),
          width: z.number().optional(),
          height: z.number().optional(),
        }),
        z.tuple([z.number(), z.number(), z.number(), z.number()]),
      ]),
      min_distance: z.number().nonnegative().optional(),
      max_attempts: z.number().int().positive().optional(),
      require_full_count: z.boolean().optional(),
      name_prefix: z.string().optional(),
      random_rotation: z.boolean().optional(),
      rotation_range_degrees: vector2ParamSchema.optional(),
      random_scale: z.boolean().optional(),
      scale_range: vector2ParamSchema.optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ScatterSceneInstances2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('scatter_scene_instances_2d', args);
        const status = (result.status as string) ?? 'committed';
        const created = Number(result.created_count ?? 0);
        const requested = Number(result.requested_count ?? created);
        return `Scattered ${created}/${requested} 2D instances under ${result.parent_path ?? args.parent_path ?? '/root'} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to scatter 2D scene instances: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'scatter_scene_instances_3d',
    description: 'Procedurally scatter PackedScene Node3D instances across a 3D volume',
    parameters: z.object({
      parent_path: z.string().optional(),
      scene_path: z.string()
        .describe('PackedScene path (res://...) to instantiate'),
      count: z.number().int().positive().optional(),
      origin: vector3ParamSchema.optional(),
      size: vector3ParamSchema,
      min_distance: z.number().nonnegative().optional(),
      max_attempts: z.number().int().positive().optional(),
      require_full_count: z.boolean().optional(),
      name_prefix: z.string().optional(),
      random_yaw: z.boolean().optional(),
      yaw_range_degrees: vector2ParamSchema.optional(),
      random_scale: z.boolean().optional(),
      scale_range: vector2ParamSchema.optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ScatterSceneInstances3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('scatter_scene_instances_3d', args);
        const status = (result.status as string) ?? 'committed';
        const created = Number(result.created_count ?? 0);
        const requested = Number(result.requested_count ?? created);
        return `Scattered ${created}/${requested} 3D instances under ${result.parent_path ?? args.parent_path ?? '/root'} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to scatter 3D scene instances: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_characterbody3d_controller',
    description: 'Configure CharacterBody3D movement/controller properties for 3D action and platform gameplay',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody3D node'),
      up_direction: vector3ParamSchema.optional(),
      motion_mode: z.number().int().optional(),
      floor_stop_on_slope: z.boolean().optional(),
      floor_constant_speed: z.boolean().optional(),
      floor_block_on_wall: z.boolean().optional(),
      floor_snap_length: z.number().optional(),
      floor_max_angle: z.number().optional(),
      wall_min_slide_angle: z.number().optional(),
      max_slides: z.number().int().min(1).optional(),
      safe_margin: z.number().nonnegative().optional(),
      slide_on_ceiling: z.boolean().optional(),
      platform_on_leave: z.number().int().optional(),
      platform_floor_layers: z.number().int().optional(),
      platform_wall_layers: z.number().int().optional(),
      velocity: vector3ParamSchema.optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCharacterBody3DControllerParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_characterbody3d_controller', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `CharacterBody3D at ${args.node_path} already matches requested controller settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured CharacterBody3D controller at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure CharacterBody3D controller: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_camera3d_rig',
    description: 'Configure Camera3D transform and projection settings for 3D gameplay cameras',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the Camera3D node'),
      position: vector3ParamSchema.optional(),
      rotation_degrees: vector3ParamSchema.optional(),
      global_position: vector3ParamSchema.optional(),
      global_rotation_degrees: vector3ParamSchema.optional(),
      current: z.boolean().optional(),
      projection: z.number().int().optional(),
      fov: z.number().optional(),
      size: z.number().optional(),
      near: z.number().positive().optional(),
      far: z.number().positive().optional(),
      keep_aspect: z.number().int().optional(),
      h_offset: z.number().optional(),
      v_offset: z.number().optional(),
      cull_mask: z.number().int().optional(),
      doppler_tracking: z.number().int().optional(),
      environment_path: z.string().optional()
        .describe('Environment resource path (res://...) or empty string to clear'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureCamera3DRigParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_camera3d_rig', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Camera3D at ${args.node_path} already matches requested rig settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured Camera3D rig at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Camera3D rig: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_springarm3d',
    description: 'Configure SpringArm3D collision sweep and camera boom settings',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the SpringArm3D node'),
      spring_length: z.number().nonnegative().optional(),
      margin: z.number().nonnegative().optional(),
      collision_mask: z.number().int().optional(),
      shape_path: z.string().optional()
        .describe('Shape3D resource path (res://...) or empty string to clear'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureSpringArm3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_springarm3d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `SpringArm3D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured SpringArm3D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure SpringArm3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_navigation_agent_2d',
    description: 'Configure NavigationAgent2D pathfinding and avoidance behavior for top-down and side-view AI',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the NavigationAgent2D node'),
      target_position: vector2ParamSchema.optional(),
      navigation_layers: z.number().int().optional(),
      pathfinding_algorithm: z.number().int().optional(),
      path_postprocessing: z.number().int().optional(),
      path_metadata_flags: z.number().int().optional(),
      path_desired_distance: z.number().nonnegative().optional(),
      target_desired_distance: z.number().nonnegative().optional(),
      path_max_distance: z.number().nonnegative().optional(),
      radius: z.number().nonnegative().optional(),
      max_speed: z.number().nonnegative().optional(),
      avoidance_enabled: z.boolean().optional(),
      neighbor_distance: z.number().nonnegative().optional(),
      max_neighbors: z.number().int().nonnegative().optional(),
      time_horizon: z.number().nonnegative().optional(),
      time_horizon_agents: z.number().nonnegative().optional(),
      time_horizon_obstacles: z.number().nonnegative().optional(),
      avoidance_layers: z.number().int().optional(),
      avoidance_mask: z.number().int().optional(),
      avoidance_priority: z.number().nonnegative().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureNavigationAgent2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_navigation_agent_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `NavigationAgent2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured NavigationAgent2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure NavigationAgent2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_navigation_agent_3d',
    description: 'Configure NavigationAgent3D pathfinding and avoidance behavior for 3D AI characters',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the NavigationAgent3D node'),
      target_position: vector3ParamSchema.optional(),
      navigation_layers: z.number().int().optional(),
      pathfinding_algorithm: z.number().int().optional(),
      path_postprocessing: z.number().int().optional(),
      path_metadata_flags: z.number().int().optional(),
      path_desired_distance: z.number().nonnegative().optional(),
      target_desired_distance: z.number().nonnegative().optional(),
      path_max_distance: z.number().nonnegative().optional(),
      radius: z.number().nonnegative().optional(),
      height: z.number().nonnegative().optional(),
      max_speed: z.number().nonnegative().optional(),
      avoidance_enabled: z.boolean().optional(),
      neighbor_distance: z.number().nonnegative().optional(),
      max_neighbors: z.number().int().nonnegative().optional(),
      time_horizon: z.number().nonnegative().optional(),
      time_horizon_agents: z.number().nonnegative().optional(),
      time_horizon_obstacles: z.number().nonnegative().optional(),
      avoidance_layers: z.number().int().optional(),
      avoidance_mask: z.number().int().optional(),
      avoidance_priority: z.number().nonnegative().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureNavigationAgent3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_navigation_agent_3d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `NavigationAgent3D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured NavigationAgent3D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure NavigationAgent3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_navigation_obstacle_2d',
    description: 'Configure NavigationObstacle2D avoidance behavior and optional polygon vertices for dynamic top-down blockers',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the NavigationObstacle2D node'),
      avoidance_enabled: z.boolean().optional(),
      avoidance_layers: z.number().int().optional(),
      radius: z.number().nonnegative().optional(),
      velocity: vector2ParamSchema.optional(),
      use_3d_avoidance: z.boolean().optional(),
      vertices: z.array(vector2ParamSchema).optional()
        .describe('Optional polygon vertices for obstacle avoidance geometry'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureNavigationObstacle2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_navigation_obstacle_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `NavigationObstacle2D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured NavigationObstacle2D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure NavigationObstacle2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_navigation_obstacle_3d',
    description: 'Configure NavigationObstacle3D avoidance behavior and optional polygon vertices for dynamic 3D blockers',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the NavigationObstacle3D node'),
      avoidance_enabled: z.boolean().optional(),
      avoidance_layers: z.number().int().optional(),
      radius: z.number().nonnegative().optional(),
      height: z.number().nonnegative().optional(),
      velocity: vector3ParamSchema.optional(),
      vertices: z.array(vector3ParamSchema).optional()
        .describe('Optional polygon vertices for obstacle avoidance geometry'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureNavigationObstacle3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_navigation_obstacle_3d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `NavigationObstacle3D at ${args.node_path} already matches requested settings.`;
        }
        const changed = Array.isArray(result.changes) ? result.changes.length : 0;
        return `Configured NavigationObstacle3D at ${args.node_path} (${changed} changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure NavigationObstacle3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'advance_pathfollow2d',
    description: 'Advance PathFollow2D progress for moving platforms, patrol rails, and scripted route motion',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the PathFollow2D node'),
      speed: z.number().optional()
        .describe('Units per second used with delta to compute progress_delta'),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      reverse: z.boolean().optional(),
      progress: z.number().optional()
        .describe('Explicit absolute progress value override'),
      progress_delta: z.number().optional()
        .describe('Explicit progress step override (applied after reverse)'),
      progress_ratio: z.number().optional(),
      progress_ratio_delta: z.number().optional(),
      loop: z.boolean().optional(),
      cubic_interp: z.boolean().optional(),
      rotates: z.boolean().optional(),
      h_offset: z.number().optional(),
      v_offset: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: AdvancePathFollow2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('advance_pathfollow2d', args);
        const status = (result.status as string) ?? 'committed';
        const progress = Number(result.progress ?? 0);
        return `Advanced PathFollow2D ${args.node_path} to progress=${progress.toFixed(3)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to advance PathFollow2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'advance_pathfollow3d',
    description: 'Advance PathFollow3D progress for moving platforms, splines, and scripted patrol routes',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the PathFollow3D node'),
      speed: z.number().optional()
        .describe('Units per second used with delta to compute progress_delta'),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      reverse: z.boolean().optional(),
      progress: z.number().optional()
        .describe('Explicit absolute progress value override'),
      progress_delta: z.number().optional()
        .describe('Explicit progress step override (applied after reverse)'),
      progress_ratio: z.number().optional(),
      progress_ratio_delta: z.number().optional(),
      loop: z.boolean().optional(),
      cubic_interp: z.boolean().optional(),
      rotation_mode: z.number().int().optional(),
      tilt_enabled: z.boolean().optional(),
      use_model_front: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: AdvancePathFollow3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('advance_pathfollow3d', args);
        const status = (result.status as string) ?? 'committed';
        const progress = Number(result.progress ?? 0);
        return `Advanced PathFollow3D ${args.node_path} to progress=${progress.toFixed(3)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to advance PathFollow3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_path2d_followers',
    description: 'Create and batch-configure PathFollow2D children under a Path2D for moving platforms, enemies, and rails',
    parameters: z.object({
      path_path: z.string()
        .describe('Path to the Path2D node'),
      follower_count: z.number().int().min(0).optional(),
      create_missing: z.boolean().optional(),
      base_name: z.string().optional(),
      use_progress_ratio: z.boolean().optional(),
      spacing: z.number().optional(),
      start_progress: z.number().optional(),
      loop: z.boolean().optional(),
      cubic_interp: z.boolean().optional(),
      rotates: z.boolean().optional(),
      h_offset: z.number().optional(),
      v_offset: z.number().optional(),
      speed: z.number().optional(),
      followers: z.array(z.object({
        node_path: z.string().optional(),
        index: z.number().int().min(0).optional(),
        name: z.string().optional(),
        progress: z.number().optional(),
        progress_ratio: z.number().optional(),
        loop: z.boolean().optional(),
        cubic_interp: z.boolean().optional(),
        rotates: z.boolean().optional(),
        h_offset: z.number().optional(),
        v_offset: z.number().optional(),
        speed: z.number().optional(),
      })).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigurePath2DFollowersParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_path2d_followers', args);
        const status = (result.status as string) ?? 'committed';
        const total = Number(result.follower_count ?? 0);
        const created = Number(result.created_count ?? 0);
        const updated = Number(result.updated_count ?? 0);
        return `Configured Path2D followers on ${args.path_path}: total=${total}, created=${created}, updated=${updated} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Path2D followers: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_path3d_followers',
    description: 'Create and batch-configure PathFollow3D children under a Path3D for 3D movers, patrols, and rails',
    parameters: z.object({
      path_path: z.string()
        .describe('Path to the Path3D node'),
      follower_count: z.number().int().min(0).optional(),
      create_missing: z.boolean().optional(),
      base_name: z.string().optional(),
      use_progress_ratio: z.boolean().optional(),
      spacing: z.number().optional(),
      start_progress: z.number().optional(),
      loop: z.boolean().optional(),
      cubic_interp: z.boolean().optional(),
      rotation_mode: z.number().int().optional(),
      tilt_enabled: z.boolean().optional(),
      use_model_front: z.boolean().optional(),
      speed: z.number().optional(),
      followers: z.array(z.object({
        node_path: z.string().optional(),
        index: z.number().int().min(0).optional(),
        name: z.string().optional(),
        progress: z.number().optional(),
        progress_ratio: z.number().optional(),
        loop: z.boolean().optional(),
        cubic_interp: z.boolean().optional(),
        rotation_mode: z.number().int().optional(),
        tilt_enabled: z.boolean().optional(),
        use_model_front: z.boolean().optional(),
        speed: z.number().optional(),
      })).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigurePath3DFollowersParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_path3d_followers', args);
        const status = (result.status as string) ?? 'committed';
        const total = Number(result.follower_count ?? 0);
        const created = Number(result.created_count ?? 0);
        const updated = Number(result.updated_count ?? 0);
        return `Configured Path3D followers on ${args.path_path}: total=${total}, created=${created}, updated=${updated} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure Path3D followers: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_topdown_movement_2d',
    description: 'Configure CharacterBody2D for top-down movement defaults and shared controller tuning metadata',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody2D node'),
      apply_defaults: z.boolean().optional()
        .describe('Apply top-down friendly defaults before explicit overrides (default true)'),
      motion_mode: z.number().int().optional(),
      up_direction: vector2ParamSchema.optional(),
      floor_stop_on_slope: z.boolean().optional(),
      floor_constant_speed: z.boolean().optional(),
      floor_block_on_wall: z.boolean().optional(),
      floor_snap_length: z.number().optional(),
      max_slides: z.number().int().min(1).optional(),
      safe_margin: z.number().nonnegative().optional(),
      slide_on_ceiling: z.boolean().optional(),
      platform_on_leave: z.number().int().optional(),
      platform_floor_layers: z.number().int().optional(),
      platform_wall_layers: z.number().int().optional(),
      velocity: vector2ParamSchema.optional(),
      speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      deceleration: z.number().nonnegative().optional(),
      input_actions: z.object({
        up: z.string().min(1).optional(),
        down: z.string().min(1).optional(),
        left: z.string().min(1).optional(),
        right: z.string().min(1).optional(),
      }).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureTopDownMovement2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_topdown_movement_2d', args);
        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Top-down settings at ${args.node_path} already match requested values.`;
        }
        const propertyChanges = Array.isArray(result.changes) ? result.changes.length : 0;
        const metaChanges = Array.isArray(result.meta_changes) ? result.meta_changes.length : 0;
        return `Configured top-down movement on ${args.node_path} (${propertyChanges} property, ${metaChanges} tuning changes) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure top-down movement: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_characterbody2d_movement',
    description: 'Apply one movement simulation step to a CharacterBody2D for rapid controller iteration and testing',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody2D node'),
      direction: vector2ParamSchema.optional()
        .describe('Desired movement direction for this simulation step'),
      speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      deceleration: z.number().nonnegative().optional(),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      set_rotation: z.boolean().optional()
        .describe('Rotate the body to match movement direction'),
      sprite_path: z.string().optional()
        .describe('Optional Sprite2D/AnimatedSprite2D path to orient visually'),
      flip_sprite_h: z.boolean().optional()
        .describe('Flip the sprite horizontally based on movement direction'),
      animation_map: z.object({
        move: z.string().min(1).optional(),
        idle: z.string().min(1).optional(),
      }).optional(),
      play_animation: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateCharacterBody2DMovementParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_characterbody2d_movement', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.position ? JSON.stringify(result.position) : 'unknown';
        const velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
        return `Simulated CharacterBody2D movement on ${args.node_path} [${status}] -> position=${position}, velocity=${velocity}`;
      } catch (error) {
        throw new Error(`Failed to simulate CharacterBody2D movement: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_characterbody3d_movement',
    description: 'Apply one movement simulation step to a CharacterBody3D for rapid gameplay tuning',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the CharacterBody3D node'),
      direction: vector3ParamSchema.optional()
        .describe('Desired movement direction for this simulation step'),
      speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      deceleration: z.number().nonnegative().optional(),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      planar_only: z.boolean().optional()
        .describe('Ignore vertical input and simulate movement on XZ plane only (default true)'),
      preserve_vertical_velocity: z.boolean().optional()
        .describe('Keep existing vertical velocity when planar_only=true (default true)'),
      yaw_to_direction: z.boolean().optional()
        .describe('Rotate the body yaw to match movement direction'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateCharacterBody3DMovementParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_characterbody3d_movement', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.position ? JSON.stringify(result.position) : 'unknown';
        const velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
        return `Simulated CharacterBody3D movement on ${args.node_path} [${status}] -> position=${position}, velocity=${velocity}`;
      } catch (error) {
        throw new Error(`Failed to simulate CharacterBody3D movement: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_navigation_chase_step_2d',
    description: 'Advance a NavigationAgent2D pursuit step by sampling get_next_path_position and moving a CharacterBody2D',
    parameters: z.object({
      agent_path: z.string()
        .describe('Path to the NavigationAgent2D node'),
      body_path: z.string().optional()
        .describe('Optional CharacterBody2D path to move (defaults to the agent parent)'),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      deceleration: z.number().nonnegative().optional(),
      stop_distance: z.number().nonnegative().optional()
        .describe('Distance threshold from next path point before stopping'),
      set_rotation: z.boolean().optional()
        .describe('Rotate the body toward movement direction'),
      update_agent_velocity: z.boolean().optional()
        .describe('Write velocity back to NavigationAgent2D for avoidance workflows'),
      sync_agent_to_body: z.boolean().optional()
        .describe('Keep NavigationAgent2D transform aligned to the controlled body'),
      stop_on_navigation_finished: z.boolean().optional()
        .describe('Stop movement when NavigationAgent2D reports navigation finished (default true)'),
      allow_direct_fallback: z.boolean().optional()
        .describe('Fallback to direct target pursuit when no nav path point is available (default true)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateNavigationChaseStep2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_navigation_chase_step_2d', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.position ? JSON.stringify(result.position) : 'unknown';
        const velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
        return `Simulated navigation chase step 2D for ${args.agent_path} [${status}] -> position=${position}, velocity=${velocity}`;
      } catch (error) {
        throw new Error(`Failed to simulate navigation chase step 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_navigation_chase_step_3d',
    description: 'Advance a NavigationAgent3D pursuit step by sampling get_next_path_position and moving a CharacterBody3D',
    parameters: z.object({
      agent_path: z.string()
        .describe('Path to the NavigationAgent3D node'),
      body_path: z.string().optional()
        .describe('Optional CharacterBody3D path to move (defaults to the agent parent)'),
      delta: z.number().positive().optional()
        .describe('Simulation step duration in seconds (default 1/60)'),
      speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      deceleration: z.number().nonnegative().optional(),
      stop_distance: z.number().nonnegative().optional()
        .describe('Distance threshold from next path point before stopping'),
      planar_only: z.boolean().optional()
        .describe('Limit chase movement to XZ plane while preserving Y movement controls (default true)'),
      preserve_vertical_velocity: z.boolean().optional()
        .describe('Keep existing Y velocity when planar_only=true (default true)'),
      yaw_to_direction: z.boolean().optional()
        .describe('Rotate the body yaw toward movement direction'),
      update_agent_velocity: z.boolean().optional()
        .describe('Write velocity back to NavigationAgent3D for avoidance workflows'),
      sync_agent_to_body: z.boolean().optional()
        .describe('Keep NavigationAgent3D transform aligned to the controlled body'),
      stop_on_navigation_finished: z.boolean().optional()
        .describe('Stop movement when NavigationAgent3D reports navigation finished (default true)'),
      allow_direct_fallback: z.boolean().optional()
        .describe('Fallback to direct target pursuit when no nav path point is available (default true)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateNavigationChaseStep3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_navigation_chase_step_3d', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.position ? JSON.stringify(result.position) : 'unknown';
        const velocity = result.velocity ? JSON.stringify(result.velocity) : 'unknown';
        return `Simulated navigation chase step 3D for ${args.agent_path} [${status}] -> position=${position}, velocity=${velocity}`;
      } catch (error) {
        throw new Error(`Failed to simulate navigation chase step 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_navigation_target_to_node_2d',
    description: 'Set NavigationAgent2D target_position from another node to quickly wire enemy/player pursuit behaviors',
    parameters: z.object({
      agent_path: z.string()
        .describe('Path to the NavigationAgent2D node'),
      target_path: z.string()
        .describe('Path to the target Node2D'),
      offset: vector2ParamSchema.optional()
        .describe('Optional offset applied to target global position'),
      remember_target: z.boolean().optional()
        .describe('Store target path metadata on the agent for tooling workflows (default true)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SetNavigationTargetToNode2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_navigation_target_to_node_2d', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.target_position ? JSON.stringify(result.target_position) : 'unknown';
        return `Set NavigationAgent2D target for ${args.agent_path} -> ${args.target_path} at ${position} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set NavigationAgent2D target: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_navigation_target_to_node_3d',
    description: 'Set NavigationAgent3D target_position from another node to wire 3D enemy/player navigation',
    parameters: z.object({
      agent_path: z.string()
        .describe('Path to the NavigationAgent3D node'),
      target_path: z.string()
        .describe('Path to the target Node3D'),
      offset: vector3ParamSchema.optional()
        .describe('Optional offset applied to target global position'),
      remember_target: z.boolean().optional()
        .describe('Store target path metadata on the agent for tooling workflows (default true)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SetNavigationTargetToNode3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_navigation_target_to_node_3d', args);
        const status = (result.status as string) ?? 'committed';
        const position = result.target_position ? JSON.stringify(result.target_position) : 'unknown';
        return `Set NavigationAgent3D target for ${args.agent_path} -> ${args.target_path} at ${position} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set NavigationAgent3D target: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_water_body_2d',
    description: 'Generate a 2D water body scaffold (Area2D + collider + visual) with flow and wave metadata for gameplay logic',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated water root (defaults to "/root")'),
      water_name: z.string().optional()
        .describe('Name for the generated water root node'),
      position: vector2ParamSchema.optional(),
      size: vector2ParamSchema.optional(),
      create_visual: z.boolean().optional(),
      create_area: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      color: z.any().optional(),
      flow_direction: vector2ParamSchema.optional(),
      flow_speed: z.number().optional(),
      buoyancy: z.number().optional(),
      drag: z.number().optional(),
      wave_amplitude: z.number().optional(),
      wave_speed: z.number().optional(),
      wave_length: z.number().positive().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildWaterBody2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_water_body_2d', args);
        const status = (result.status as string) ?? 'committed';
        const waterPath = (result.water_path as string) ?? 'unknown';
        const flowSpeed = Number(result.flow_speed ?? 0);
        return `Built 2D water body at ${waterPath} (flow=${flowSpeed.toFixed(2)}) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build water body 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_water_body_3d',
    description: 'Generate a 3D water volume scaffold (surface mesh + Area3D volume) with tunable rendering and wave metadata',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated water root (defaults to "/root")'),
      water_name: z.string().optional()
        .describe('Name for the generated water root node'),
      position: vector3ParamSchema.optional(),
      size: vector2ParamSchema.optional(),
      depth: z.number().positive().optional(),
      create_visual: z.boolean().optional(),
      create_area: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      flow_direction: vector2ParamSchema.optional(),
      flow_speed: z.number().optional(),
      buoyancy: z.number().optional(),
      drag: z.number().optional(),
      wave_amplitude: z.number().optional(),
      wave_speed: z.number().optional(),
      wave_length: z.number().positive().optional(),
      surface_color: z.any().optional(),
      roughness: z.number().min(0).max(1).optional(),
      metallic: z.number().min(0).max(1).optional(),
      emission_color: z.any().optional(),
      emission_energy: z.number().nonnegative().optional(),
      subdivide_width: z.number().int().min(0).optional(),
      subdivide_depth: z.number().int().min(0).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildWaterBody3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_water_body_3d', args);
        const status = (result.status as string) ?? 'committed';
        const waterPath = (result.water_path as string) ?? 'unknown';
        const depth = Number(result.depth ?? 0);
        return `Built 3D water body at ${waterPath} (depth=${depth.toFixed(2)}) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build water body 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_sand_field_3d',
    description: 'Generate a 3D granular field scaffold with MultiMesh grains and homogenized sand profile metadata',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated sand field root (defaults to "/root")'),
      field_name: z.string().optional(),
      origin: vector3ParamSchema.optional(),
      size: vector3ParamSchema.optional(),
      create_visual: z.boolean().optional(),
      create_volume_area: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      grain_spacing: z.number().positive().optional(),
      grain_radius: z.number().positive().optional(),
      jitter: z.number().nonnegative().optional(),
      max_grains: z.number().int().positive().optional(),
      random_yaw: z.boolean().optional(),
      seed: z.number().int().optional(),
      grain_color: z.any().optional(),
      grain_roughness: z.number().min(0).max(1).optional(),
      grain_metallic: z.number().min(0).max(1).optional(),
      profile_name: z.string().optional(),
      source_reference: z.string().optional(),
      internal_friction: z.number().nonnegative().optional(),
      cohesion: z.number().nonnegative().optional(),
      stiffness: z.number().nonnegative().optional(),
      bulk_density: z.number().nonnegative().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSandField3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_sand_field_3d', args);
        const status = (result.status as string) ?? 'committed';
        const fieldPath = (result.field_path as string) ?? 'unknown';
        const grains = Number(result.grain_count ?? 0);
        return `Built 3D sand field at ${fieldPath} with ${grains} grains [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build sand field 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_cave_2d',
    description: 'Generate a procedural 2D cave layout using cellular automata with collision, visuals, and an optional spawn marker',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated cave root (defaults to "/root")'),
      cave_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      grid_size: vector2ParamSchema.optional()
        .describe('Cave grid dimensions in cells'),
      cell_size: vector2ParamSchema.optional()
        .describe('Cell dimensions in local units/pixels'),
      fill_ratio: z.number().min(0).max(1).optional(),
      smoothing_steps: z.number().int().nonnegative().optional(),
      birth_limit: z.number().int().min(0).max(8).optional(),
      death_limit: z.number().int().min(0).max(8).optional(),
      border_solid: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      create_visuals: z.boolean().optional(),
      create_background: z.boolean().optional(),
      create_spawn_marker: z.boolean().optional(),
      wall_color: z.any().optional(),
      background_color: z.any().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildCave2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_cave_2d', args);
        const status = (result.status as string) ?? 'committed';
        const cavePath = (result.cave_path as string) ?? 'unknown';
        const segments = Number(result.wall_segment_count ?? 0);
        return `Built 2D cave at ${cavePath} with ${segments} wall segment(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build cave 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_sand_field_2d',
    description: 'Generate a 2D granular sand field scaffold with grain polygons, optional volume Area2D, and material profile metadata',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated sand field root (defaults to "/root")'),
      field_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      size: vector2ParamSchema.optional(),
      create_visual: z.boolean().optional(),
      create_volume_area: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      grain_spacing: z.number().positive().optional(),
      grain_radius: z.number().positive().optional(),
      jitter: z.number().nonnegative().optional(),
      max_grains: z.number().int().positive().optional(),
      random_rotation: z.boolean().optional(),
      grain_segments: z.number().int().min(3).max(24).optional(),
      seed: z.number().int().optional(),
      grain_color: z.any().optional(),
      profile_name: z.string().optional(),
      source_reference: z.string().optional(),
      internal_friction: z.number().nonnegative().optional(),
      cohesion: z.number().nonnegative().optional(),
      stiffness: z.number().nonnegative().optional(),
      bulk_density: z.number().nonnegative().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSandField2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_sand_field_2d', args);
        const status = (result.status as string) ?? 'committed';
        const fieldPath = (result.field_path as string) ?? 'unknown';
        const grains = Number(result.grain_count ?? 0);
        return `Built 2D sand field at ${fieldPath} with ${grains} grains [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build sand field 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_platformer_blockout_2d',
    description: 'Generate a procedural side-scroller platform chain blockout with optional spawn/goal markers',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated level root (defaults to "/root")'),
      level_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      segment_count: z.number().int().positive().optional(),
      min_platform_width: z.number().positive().optional(),
      max_platform_width: z.number().positive().optional(),
      platform_height: z.number().positive().optional(),
      min_gap: z.number().nonnegative().optional(),
      max_gap: z.number().nonnegative().optional(),
      base_y: z.number().optional(),
      min_height_step: z.number().optional(),
      max_height_step: z.number().optional(),
      min_y: z.number().optional(),
      max_y: z.number().optional(),
      create_collision: z.boolean().optional(),
      create_visuals: z.boolean().optional(),
      create_spawn_marker: z.boolean().optional(),
      create_goal_marker: z.boolean().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      platform_color: z.any().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: GeneratePlatformerBlockout2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_platformer_blockout_2d', args);
        const status = (result.status as string) ?? 'committed';
        const levelPath = (result.level_path as string) ?? 'unknown';
        const segmentCount = Number(result.segment_count ?? 0);
        return `Generated platformer blockout at ${levelPath} with ${segmentCount} segment(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate platformer blockout 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_topdown_dungeon_2d',
    description: 'Generate a procedural top-down dungeon using room placement and corridor carving',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated dungeon root (defaults to "/root")'),
      dungeon_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      grid_size: vector2ParamSchema.optional(),
      cell_size: vector2ParamSchema.optional(),
      room_attempts: z.number().int().positive().optional(),
      room_target: z.number().int().positive().optional(),
      room_min_size: vector2ParamSchema.optional(),
      room_max_size: vector2ParamSchema.optional(),
      corridor_width: z.number().int().positive().optional(),
      border_walls: z.boolean().optional(),
      create_floor_visuals: z.boolean().optional(),
      create_wall_collision: z.boolean().optional(),
      create_wall_visuals: z.boolean().optional(),
      create_spawn_marker: z.boolean().optional(),
      create_goal_marker: z.boolean().optional(),
      floor_color: z.any().optional(),
      wall_color: z.any().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: GenerateTopdownDungeon2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_topdown_dungeon_2d', args);
        const status = (result.status as string) ?? 'committed';
        const dungeonPath = (result.dungeon_path as string) ?? 'unknown';
        const roomCount = Number(result.room_count ?? 0);
        const corridorCount = Number(result.corridor_count ?? 0);
        return `Generated topdown dungeon at ${dungeonPath} with ${roomCount} room(s) and ${corridorCount} corridor(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate topdown dungeon 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_isometric_tile_blockout_2d',
    description: 'Generate an isometric tile blockout with procedural height, optional side faces, and optional collision',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated level root (defaults to "/root")'),
      level_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      grid_size: vector2ParamSchema.optional(),
      max_tiles: z.number().int().positive().optional(),
      tile_size: vector2ParamSchema.optional(),
      min_height: z.number().int().optional(),
      max_height: z.number().int().optional(),
      elevation_step: z.number().positive().optional(),
      noise_frequency: z.number().positive().optional(),
      fractal_octaves: z.number().int().positive().optional(),
      fractal_lacunarity: z.number().nonnegative().optional(),
      fractal_gain: z.number().nonnegative().optional(),
      noise_type: z.number().int().optional(),
      fractal_type: z.number().int().optional(),
      sample_offset: vector2ParamSchema.optional(),
      create_collision: z.boolean().optional(),
      create_side_faces: z.boolean().optional(),
      top_color: z.any().optional(),
      left_color: z.any().optional(),
      right_color: z.any().optional(),
      height_tint_strength: z.number().min(0).max(1).optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: GenerateIsometricTileBlockout2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_isometric_tile_blockout_2d', args);
        const status = (result.status as string) ?? 'committed';
        const levelPath = (result.level_path as string) ?? 'unknown';
        const tileCount = Number(result.tile_count ?? 0);
        return `Generated isometric tile blockout at ${levelPath} with ${tileCount} tile(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate isometric tile blockout 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'generate_tentacle_waypoints_2d',
    description: 'Generate a procedural 2D tentacle rig with waypoint markers, optional line visuals, and optional tip/segment helpers',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated tentacle root (defaults to "/root")'),
      tentacle_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      waypoint_count: z.number().int().min(2).optional(),
      segment_length: z.number().positive().optional(),
      lateral_amplitude: z.number().nonnegative().optional(),
      wave_count: z.number().nonnegative().optional(),
      random_jitter: z.number().nonnegative().optional(),
      taper: z.number().min(0).max(1).optional(),
      direction: vector2ParamSchema.optional(),
      create_line: z.boolean().optional(),
      create_waypoint_markers: z.boolean().optional(),
      create_segment_markers: z.boolean().optional(),
      create_tip_marker: z.boolean().optional(),
      line_color: z.any().optional(),
      line_width_start: z.number().positive().optional(),
      line_width_end: z.number().positive().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: GenerateTentacleWaypoints2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('generate_tentacle_waypoints_2d', args);
        const status = (result.status as string) ?? 'committed';
        const tentaclePath = (result.tentacle_path as string) ?? 'unknown';
        const waypointCount = Number(result.waypoint_count ?? 0);
        return `Generated tentacle waypoints at ${tentaclePath} with ${waypointCount} waypoint(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to generate tentacle waypoints 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_creature_parts_2d',
    description: 'Build a modular 2D creature parts rig with optional visual, collision, and attachment marker scaffolding',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated creature root (defaults to "/root")'),
      creature_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      scale: z.number().positive().optional(),
      include_tail: z.boolean().optional(),
      include_wings: z.boolean().optional(),
      include_horns: z.boolean().optional(),
      create_visuals: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      create_attachment_markers: z.boolean().optional(),
      body_color: z.any().optional(),
      accent_color: z.any().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildCreatureParts2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_creature_parts_2d', args);
        const status = (result.status as string) ?? 'committed';
        const creaturePath = (result.creature_path as string) ?? 'unknown';
        const partCount = Number(result.part_count ?? 0);
        return `Built creature parts at ${creaturePath} with ${partCount} part(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build creature parts 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_slime_mold_colony_2d',
    description: 'Create a slow-growth slime mold colony scaffold on a 2D grid with optional visuals/collision and metadata for future growth steps',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated slime colony root (defaults to "/root")'),
      colony_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      grid_size: vector2ParamSchema.optional(),
      cell_size: vector2ParamSchema.optional(),
      initial_cell_count: z.number().int().positive().optional(),
      initial_radius: z.number().int().nonnegative().optional(),
      spread_chance: z.number().min(0).max(1).optional(),
      growth_rate: z.number().nonnegative().optional(),
      max_cells: z.number().int().positive().optional(),
      create_visuals: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      cell_color: z.any().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSlimeMoldColony2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_slime_mold_colony_2d', args);
        const status = (result.status as string) ?? 'committed';
        const colonyPath = (result.colony_path as string) ?? 'unknown';
        const cellCount = Number(result.cell_count ?? 0);
        return `Built slime mold colony at ${colonyPath} with ${cellCount} cell(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build slime mold colony 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_slime_mold_growth_step_2d',
    description: 'Apply one or more procedural growth steps to a slime colony to spread cells slowly across neighboring grid positions',
    parameters: z.object({
      colony_path: z.string()
        .describe('Path to the slime colony root node'),
      cells_path: z.string().optional()
        .describe('Optional explicit path to the colony cell container'),
      grid_size: vector2ParamSchema.optional(),
      cell_size: vector2ParamSchema.optional(),
      spread_chance: z.number().min(0).max(1).optional(),
      growth_rate: z.number().nonnegative().optional(),
      max_cells: z.number().int().positive().optional(),
      steps: z.number().int().positive().optional(),
      max_new_cells_per_step: z.number().int().positive().optional(),
      allow_diagonal: z.boolean().optional(),
      create_visuals: z.boolean().optional(),
      create_collision: z.boolean().optional(),
      cell_color: z.any().optional(),
      collision_layer: z.number().int().optional(),
      collision_mask: z.number().int().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateSlimeMoldGrowthStep2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_slime_mold_growth_step_2d', args);
        const status = (result.status as string) ?? 'committed';
        const addedCount = Number(result.added_count ?? 0);
        const totalCells = Number(result.total_cells ?? 0);
        return `Simulated slime growth for ${args.colony_path} with +${addedCount} cell(s), total ${totalCells} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate slime mold growth step 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_light_node',
    description: 'Configure Light2D or Light3D properties including enable state, color, intensity, shadows, and range/fade controls',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to a Light2D or Light3D node to configure'),
      enabled: z.boolean().optional(),
      color: z.any().optional(),
      profile_name: z.string().optional(),
      energy: z.number().optional(),
      shadow_enabled: z.boolean().optional(),
      shadow_color: z.any().optional(),
      texture_scale: z.number().optional(),
      height: z.number().optional(),
      shadow_filter_smooth: z.number().optional(),
      blend_mode: z.number().int().optional(),
      range_item_cull_mask: z.number().int().optional(),
      range_layer_min: z.number().int().optional(),
      range_layer_max: z.number().int().optional(),
      range_z_min: z.number().int().optional(),
      range_z_max: z.number().int().optional(),
      shadow_filter: z.number().int().optional(),
      indirect_energy: z.number().optional(),
      volumetric_fog_energy: z.number().optional(),
      specular: z.number().optional(),
      temperature: z.number().optional(),
      shadow_blur: z.number().optional(),
      shadow_bias: z.number().optional(),
      shadow_normal_bias: z.number().optional(),
      distance_fade_enabled: z.boolean().optional(),
      distance_fade_begin: z.number().optional(),
      distance_fade_length: z.number().optional(),
      distance_fade_shadow: z.number().optional(),
      cull_mask: z.number().int().optional(),
      projector_path: z.string().optional(),
      omni_range: z.number().optional(),
      omni_attenuation: z.number().optional(),
      spot_range: z.number().optional(),
      spot_attenuation: z.number().optional(),
      spot_angle: z.number().optional(),
      spot_angle_attenuation: z.number().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureLightNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_light_node', args);
        const status = (result.status as string) ?? 'committed';
        const nodePath = (result.node_path as string) ?? args.node_path;
        const lightType = String(result.light_type ?? 'Light');
        const enabled = Boolean(result.enabled ?? args.enabled ?? true);
        const energy = Number(result.energy ?? args.energy ?? 0);
        return `Configured ${lightType} at ${nodePath} enabled=${enabled} energy=${energy.toFixed(2)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure light node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_smoke_effect_2d',
    description: 'Create a procedural 2D smoke rig with particles, wind drift tuning, and optional full-screen haze overlay',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated smoke root (defaults to "/root")'),
      smoke_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      area_size: vector2ParamSchema.optional(),
      intensity: z.number().min(0).max(1).optional(),
      wind_direction: vector2ParamSchema.optional(),
      wind_strength: z.number().min(0).max(1).optional(),
      max_particles: z.number().int().nonnegative().optional(),
      particle_lifetime: z.number().positive().optional(),
      rise_speed_min: z.number().nonnegative().optional(),
      rise_speed_max: z.number().nonnegative().optional(),
      spread_degrees: z.number().min(0).max(180).optional(),
      rise_acceleration: z.number().nonnegative().optional(),
      damping_min: z.number().nonnegative().optional(),
      damping_max: z.number().nonnegative().optional(),
      particle_scale_min: vector2ParamSchema.optional(),
      particle_scale_max: vector2ParamSchema.optional(),
      smoke_roundness: z.number().min(0).max(1).optional(),
      smoke_softness: z.number().min(0).max(1).optional(),
      smoke_noise_strength: z.number().min(0).max(1).optional(),
      smoke_noise_scale: z.number().positive().optional(),
      smoke_texture_size: z.number().int().min(16).max(256).optional(),
      smoke_color: z.any().optional(),
      create_overlay: z.boolean().optional(),
      overlay_density: z.number().min(0).max(1).optional(),
      overlay_color: z.any().optional(),
      canvas_layer: z.number().int().optional(),
      particle_fixed_fps: z.number().int().positive().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSmokeEffect2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_smoke_effect_2d', args);
        const status = (result.status as string) ?? 'committed';
        const smokePath = (result.smoke_path as string) ?? 'unknown';
        const particles = Number(result.particle_amount ?? 0);
        const emitting = Boolean(result.can_emit ?? false);
        return `Built 2D smoke effect at ${smokePath} particles=${particles} emitting=${emitting} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build smoke effect 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_particles_3d',
    description: 'Configure GPUParticles3D node playback and particle process material properties for gameplay VFX tuning',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the GPUParticles3D node'),
      emitting: z.boolean().optional(),
      one_shot: z.boolean().optional(),
      local_coords: z.boolean().optional(),
      trail_enabled: z.boolean().optional(),
      amount: z.number().int().nonnegative().optional(),
      fixed_fps: z.number().int().nonnegative().optional(),
      draw_order: z.number().int().optional(),
      amount_ratio: z.number().min(0).max(1).optional(),
      lifetime: z.number().positive().optional(),
      preprocess: z.number().nonnegative().optional(),
      speed_scale: z.number().optional(),
      explosiveness: z.number().min(0).max(1).optional(),
      randomness: z.number().min(0).max(1).optional(),
      interp_to_end: z.number().min(0).max(1).optional(),
      trail_lifetime: z.number().nonnegative().optional(),
      visibility_aabb: z.object({
        position: vector3ParamSchema.optional(),
        size: vector3ParamSchema.optional(),
        x: z.number().optional(),
        y: z.number().optional(),
        z: z.number().optional(),
        width: z.number().optional(),
        height: z.number().optional(),
        depth: z.number().optional(),
      }).optional(),
      draw_pass_1_path: z.string().optional(),
      ensure_process_material: z.boolean().optional(),
      direction: vector3ParamSchema.optional(),
      spread: z.number().optional(),
      gravity: vector3ParamSchema.optional(),
      initial_velocity_min: z.number().optional(),
      initial_velocity_max: z.number().optional(),
      angular_velocity_min: z.number().optional(),
      angular_velocity_max: z.number().optional(),
      damping_min: z.number().nonnegative().optional(),
      damping_max: z.number().nonnegative().optional(),
      scale_min: z.number().nonnegative().optional(),
      scale_max: z.number().nonnegative().optional(),
      color: z.any().optional(),
      emission_shape: z.number().int().optional(),
      emission_box_extents: vector3ParamSchema.optional(),
      color_ramp_path: z.string().optional(),
      profile_name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: ConfigureParticles3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('configure_particles_3d', args);
        const status = (result.status as string) ?? 'committed';
        const amount = Number(result.amount ?? 0);
        const lifetime = Number(result.lifetime ?? 0);
        const emitting = Boolean(result.emitting ?? false);
        return `Configured GPUParticles3D ${args.node_path} amount=${amount} lifetime=${lifetime.toFixed(2)} emitting=${emitting} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to configure particles 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_smoke_effect_3d',
    description: 'Create a procedural 3D smoke rig with GPUParticles3D, billboards, wind drift, and optional ground haze',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated smoke root (defaults to "/root")'),
      smoke_name: z.string().optional(),
      position: vector3ParamSchema.optional(),
      volume_size: vector3ParamSchema.optional(),
      intensity: z.number().min(0).max(1).optional(),
      wind_direction: vector3ParamSchema.optional(),
      wind_strength: z.number().min(0).max(1).optional(),
      max_particles: z.number().int().nonnegative().optional(),
      particle_lifetime: z.number().positive().optional(),
      rise_speed_min: z.number().nonnegative().optional(),
      rise_speed_max: z.number().nonnegative().optional(),
      spread_degrees: z.number().min(0).max(180).optional(),
      damping_min: z.number().nonnegative().optional(),
      damping_max: z.number().nonnegative().optional(),
      smoke_roundness: z.number().min(0).max(1).optional(),
      smoke_softness: z.number().min(0).max(1).optional(),
      smoke_noise_strength: z.number().min(0).max(1).optional(),
      smoke_noise_scale: z.number().positive().optional(),
      smoke_texture_size: z.number().int().min(16).max(256).optional(),
      smoke_color: z.any().optional(),
      create_ground_haze: z.boolean().optional(),
      haze_color: z.any().optional(),
      particle_fixed_fps: z.number().int().positive().optional(),
      particle_quad_size: z.number().positive().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSmokeEffect3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_smoke_effect_3d', args);
        const status = (result.status as string) ?? 'committed';
        const smokePath = (result.smoke_path as string) ?? 'unknown';
        const particles = Number(result.particle_amount ?? 0);
        const emitting = Boolean(result.can_emit ?? false);
        return `Built 3D smoke effect at ${smokePath} particles=${particles} emitting=${emitting} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build smoke effect 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_light_occluder_2d',
    description: 'Create a LightOccluder2D with generated or explicit polygon points for 2D shadow blocking',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated light occluder (defaults to "/root")'),
      occluder_name: z.string().optional(),
      position: vector2ParamSchema.optional(),
      size: vector2ParamSchema.optional(),
      polygon_points: z.array(vector2ParamSchema).optional(),
      closed: z.boolean().optional(),
      cull_mode: z.number().int().optional(),
      occluder_light_mask: z.number().int().optional(),
      sdf_collision: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildLightOccluder2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_light_occluder_2d', args);
        const status = (result.status as string) ?? 'committed';
        const occluderPath = (result.occluder_path as string) ?? 'unknown';
        const points = Number(result.point_count ?? 0);
        return `Built LightOccluder2D at ${occluderPath} with ${points} point(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build LightOccluder2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'edit_light_occluder_polygon_2d',
    description: 'Edit a LightOccluder2D polygon by replacing, appending, offsetting points, and changing cull/closure behavior',
    parameters: z.object({
      occluder_path: z.string()
        .describe('Path to the LightOccluder2D node'),
      polygon_points: z.array(vector2ParamSchema).optional(),
      append_points: z.array(vector2ParamSchema).optional(),
      offset: vector2ParamSchema.optional(),
      closed: z.boolean().optional(),
      cull_mode: z.number().int().optional(),
      profile_name: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: EditLightOccluderPolygon2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('edit_light_occluder_polygon_2d', args);
        const status = (result.status as string) ?? 'committed';
        const points = Number(result.point_count ?? 0);
        return `Edited LightOccluder2D ${args.occluder_path} to ${points} point(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to edit LightOccluder2D polygon: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_subviewport_minimap',
    description: 'Build a minimap UI rig using SubViewportContainer/SubViewport with 2D or 3D orthographic camera setup',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the minimap canvas root (defaults to "/root")'),
      minimap_name: z.string().optional(),
      target_path: z.string().optional(),
      mode: z.enum(['auto', '2d', 'topdown3d', 'isometric3d']).optional(),
      size: vector2ParamSchema.optional(),
      margin: z.number().nonnegative().optional(),
      anchor: z.enum(['top_left', 'top_right', 'bottom_left', 'bottom_right']).optional(),
      canvas_layer: z.number().int().optional(),
      zoom_2d: z.number().positive().optional(),
      camera_size: z.number().positive().optional(),
      camera_height: z.number().positive().optional(),
      isometric_distance: z.number().positive().optional(),
      near: z.number().positive().optional(),
      far: z.number().positive().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildSubviewportMinimapParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_subviewport_minimap', args);
        const status = (result.status as string) ?? 'committed';
        const minimapPath = (result.minimap_path as string) ?? 'unknown';
        const mode = String(result.mode ?? args.mode ?? 'auto');
        return `Built minimap at ${minimapPath} mode=${mode} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build subviewport minimap: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_weather_system_2d',
    description: 'Build a full 2D weather rig with precipitation particles, fog overlay, ambient canvas tinting, and optional lightning flash layer',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated weather root (defaults to "/root")'),
      weather_name: z.string().optional(),
      origin: vector2ParamSchema.optional(),
      area_size: vector2ParamSchema.optional()
        .describe('Logical weather coverage area for emitters and overlays'),
      preset: z.string().optional()
        .describe('Weather preset: clear, drizzle, rain, storm, snow, blizzard, ash'),
      intensity: z.number().min(0).max(1).optional(),
      transition_rate: z.number().positive().optional(),
      wind_direction: vector2ParamSchema.optional(),
      wind_strength: z.number().min(0).max(1).optional(),
      canvas_layer: z.number().int().optional(),
      enable_precipitation: z.boolean().optional(),
      enable_fog: z.boolean().optional(),
      enable_ambient_modulate: z.boolean().optional(),
      enable_lightning_overlay: z.boolean().optional(),
      precipitation_mode: z.enum(['none', 'rain', 'snow', 'ash']).optional(),
      precipitation_intensity_scale: z.number().min(0).max(2).optional(),
      max_particles: z.number().int().nonnegative().optional(),
      particle_lifetime: z.number().positive().optional(),
      particle_speed_min: z.number().nonnegative().optional(),
      particle_speed_max: z.number().nonnegative().optional(),
      spread_degrees: z.number().min(0).max(180).optional(),
      gravity_strength: z.number().nonnegative().optional(),
      particle_scale_min: vector2ParamSchema.optional(),
      particle_scale_max: vector2ParamSchema.optional(),
      fog_density: z.number().min(0).max(1).optional(),
      fog_color: z.any().optional(),
      ambient_color: z.any().optional(),
      precipitation_color: z.any().optional(),
      lightning_enabled: z.boolean().optional(),
      lightning_chance: z.number().min(0).max(1).optional(),
      lightning_flash_strength: z.number().min(0).max(1).optional(),
      lightning_decay: z.number().positive().optional(),
      lightning_color: z.any().optional(),
      particle_fixed_fps: z.number().int().positive().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildWeatherSystem2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_weather_system_2d', args);
        const status = (result.status as string) ?? 'committed';
        const weatherPath = (result.weather_path as string) ?? 'unknown';
        const preset = String(result.preset ?? args.preset ?? 'unknown');
        const intensity = Number(result.intensity ?? args.intensity ?? 0);
        return `Built 2D weather system at ${weatherPath} preset=${preset} intensity=${intensity.toFixed(2)} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build weather system 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_weather_step_2d',
    description: 'Advance one iterative weather step for a 2D weather rig with smooth intensity transitions and optional lightning trigger',
    parameters: z.object({
      weather_path: z.string()
        .describe('Path to the weather root node'),
      target_preset: z.string().optional(),
      target_intensity: z.number().min(0).max(1).optional(),
      delta: z.number().positive().optional(),
      transition_rate: z.number().positive().optional(),
      area_size: vector2ParamSchema.optional(),
      wind_direction: vector2ParamSchema.optional(),
      wind_strength: z.number().min(0).max(1).optional(),
      precipitation_mode: z.enum(['none', 'rain', 'snow', 'ash']).optional(),
      precipitation_intensity_scale: z.number().min(0).max(2).optional(),
      max_particles: z.number().int().nonnegative().optional(),
      particle_lifetime: z.number().positive().optional(),
      particle_speed_min: z.number().nonnegative().optional(),
      particle_speed_max: z.number().nonnegative().optional(),
      spread_degrees: z.number().min(0).max(180).optional(),
      gravity_strength: z.number().nonnegative().optional(),
      particle_scale_min: vector2ParamSchema.optional(),
      particle_scale_max: vector2ParamSchema.optional(),
      precipitation_color: z.any().optional(),
      enable_precipitation: z.boolean().optional(),
      precipitation_path: z.string().optional(),
      fog_density: z.number().min(0).max(1).optional(),
      fog_color: z.any().optional(),
      enable_fog: z.boolean().optional(),
      fog_overlay_path: z.string().optional(),
      ambient_color: z.any().optional(),
      enable_ambient_modulate: z.boolean().optional(),
      ambient_modulate_path: z.string().optional(),
      lightning_enabled: z.boolean().optional(),
      lightning_chance: z.number().min(0).max(1).optional(),
      lightning_flash_strength: z.number().min(0).max(1).optional(),
      lightning_decay: z.number().positive().optional(),
      lightning_color: z.any().optional(),
      enable_lightning_overlay: z.boolean().optional(),
      lightning_overlay_path: z.string().optional(),
      trigger_lightning: z.boolean().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateWeatherStep2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_weather_step_2d', args);
        const status = (result.status as string) ?? 'committed';
        const preset = String(result.preset ?? args.target_preset ?? 'unknown');
        const intensity = Number(result.intensity ?? args.target_intensity ?? 0);
        const emitting = Boolean(result.precipitation_emitting ?? false);
        return `Simulated 2D weather step for ${args.weather_path} preset=${preset} intensity=${intensity.toFixed(2)} emitting=${emitting} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate weather step 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_water_current_step_2d',
    description: 'Apply one water current/buoyancy simulation step to a Node2D body against a 2D water volume',
    parameters: z.object({
      water_path: z.string()
        .describe('Path to the 2D water root node'),
      body_path: z.string()
        .describe('Path to the Node2D body to update'),
      size: vector2ParamSchema.optional()
        .describe('Optional water size override when metadata is missing'),
      flow_direction: vector2ParamSchema.optional(),
      flow_speed: z.number().optional(),
      buoyancy: z.number().optional(),
      drag: z.number().nonnegative().optional(),
      delta: z.number().positive().optional(),
      flow_scale: z.number().optional(),
      buoyancy_scale: z.number().optional(),
      drag_scale: z.number().nonnegative().optional(),
      sink_bias: z.number().optional(),
      clamp_speed: z.number().nonnegative().optional(),
      apply_position: z.boolean().optional(),
      require_inside: z.boolean().optional(),
      current_velocity: vector2ParamSchema.optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateWaterCurrentStep2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_water_current_step_2d', args);
        const status = (result.status as string) ?? 'committed';
        const inside = Boolean(result.inside_water ?? false);
        const submersion = Number(result.submersion ?? 0);
        return `Simulated 2D water step for ${args.body_path} in ${args.water_path} (inside=${inside}, submersion=${submersion.toFixed(2)}) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate 2D water current step: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'simulate_water_current_step_3d',
    description: 'Apply one water current/buoyancy simulation step to a Node3D body against a 3D water volume',
    parameters: z.object({
      water_path: z.string()
        .describe('Path to the 3D water root node'),
      body_path: z.string()
        .describe('Path to the Node3D body to update'),
      size: vector2ParamSchema.optional()
        .describe('Optional water XZ size override when metadata is missing'),
      depth: z.number().positive().optional(),
      flow_direction: vector2ParamSchema.optional(),
      flow_speed: z.number().optional(),
      buoyancy: z.number().optional(),
      drag: z.number().nonnegative().optional(),
      delta: z.number().positive().optional(),
      flow_scale: z.number().optional(),
      buoyancy_scale: z.number().optional(),
      drag_scale: z.number().nonnegative().optional(),
      sink_bias: z.number().optional(),
      clamp_speed: z.number().nonnegative().optional(),
      apply_position: z.boolean().optional(),
      require_inside: z.boolean().optional(),
      preserve_vertical_velocity: z.boolean().optional(),
      current_velocity: vector3ParamSchema.optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SimulateWaterCurrentStep3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('simulate_water_current_step_3d', args);
        const status = (result.status as string) ?? 'committed';
        const inside = Boolean(result.inside_water ?? false);
        const submersion = Number(result.submersion ?? 0);
        return `Simulated 3D water step for ${args.body_path} in ${args.water_path} (inside=${inside}, submersion=${submersion.toFixed(2)}) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to simulate 3D water current step: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'settle_sand_field_3d',
    description: 'Apply a settling pass to a sand MultiMesh field to quickly iterate dune/terrain style granular layouts',
    parameters: z.object({
      field_path: z.string()
        .describe('Path to the sand field Node3D root'),
      grains_path: z.string().optional()
        .describe('Optional explicit path to the MultiMeshInstance3D grains node'),
      size: vector3ParamSchema.optional()
        .describe('Optional bounds override for clamping settled grains'),
      iterations: z.number().int().positive().optional(),
      settle_strength: z.number().nonnegative().optional(),
      horizontal_jitter: z.number().nonnegative().optional(),
      downward_bias: z.number().nonnegative().optional(),
      keep_bounds: z.boolean().optional(),
      seed: z.number().int().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SettleSandField3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('settle_sand_field_3d', args);
        const status = (result.status as string) ?? 'committed';
        const moved = Number(result.moved_instances ?? 0);
        const total = Number(result.instance_count ?? 0);
        return `Settled sand field ${args.field_path} with ${moved}/${total} moved instances [${status}]`;
      } catch (error) {
        throw new Error(`Failed to settle sand field 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_stage_blockout_2d',
    description: 'Generate a 2D stage blockout with StaticBody2D colliders and optional Polygon2D visuals',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated stage root (defaults to "/root")'),
      stage_name: z.string().optional()
        .describe('Name for the generated stage root node'),
      blocks: z.array(z.object({
        name: z.string().optional(),
        position: vector2ParamSchema.optional(),
        size: vector2ParamSchema.optional(),
        collision_layer: z.number().int().optional(),
        collision_mask: z.number().int().optional(),
        color: z.any().optional(),
      })).min(1)
        .describe('Block descriptors with position and size'),
      create_visuals: z.boolean().optional()
        .describe('Create Polygon2D visuals for each block (default true)'),
      collision_layer: z.number().int().optional()
        .describe('Default collision layer used when a block does not override it'),
      collision_mask: z.number().int().optional()
        .describe('Default collision mask used when a block does not override it'),
      default_color: z.any().optional()
        .describe('Default Polygon2D color used when a block does not provide color'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildStageBlockout2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_stage_blockout_2d', args);
        const status = (result.status as string) ?? 'committed';
        const stagePath = (result.stage_path as string) ?? 'unknown';
        const count = Number(result.block_count ?? 0);
        return `Built 2D stage blockout at ${stagePath} with ${count} block(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build 2D stage blockout: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_hud_ui_2d',
    description: 'Generate a reusable 2D HUD scaffold (CanvasLayer + labels/button) for fast UI iteration',
    parameters: z.object({
      parent_path: z.string().optional()
        .describe('Parent node path for the generated HUD CanvasLayer (defaults to "/root")'),
      hud_name: z.string().optional()
        .describe('Name for the HUD root node'),
      include_health: z.boolean().optional(),
      include_score: z.boolean().optional(),
      include_objective: z.boolean().optional(),
      include_message: z.boolean().optional(),
      include_pause_button: z.boolean().optional(),
      margin: z.number().int().nonnegative().optional(),
      spacing: z.number().int().nonnegative().optional(),
      health_text: z.string().optional(),
      score_text: z.string().optional(),
      objective_text: z.string().optional(),
      message_text: z.string().optional(),
      pause_text: z.string().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildHudUi2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_hud_ui_2d', args);
        const status = (result.status as string) ?? 'committed';
        const hudPath = (result.hud_path as string) ?? 'unknown';
        const labelCount = Array.isArray(result.labels) ? result.labels.length : 0;
        return `Built HUD UI at ${hudPath} with ${labelCount} label(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build HUD UI: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'author_enemy_ai_2d',
    description: 'Author a 2D enemy AI scaffold (navigation, vision sensor, cooldown timer, metadata, and signal wiring)',
    parameters: z.object({
      enemy_path: z.string()
        .describe('Path to the CharacterBody2D enemy node'),
      create_navigation_agent: z.boolean().optional(),
      create_vision_area: z.boolean().optional(),
      create_attack_timer: z.boolean().optional(),
      connect_signals: z.boolean().optional(),
      movement_speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      attack_cooldown: z.number().positive().optional(),
      vision_radius: z.number().positive().optional(),
      detection_group: z.string().optional(),
      navigation_agent_name: z.string().optional(),
      navigation_max_speed: z.number().nonnegative().optional(),
      path_desired_distance: z.number().nonnegative().optional(),
      target_desired_distance: z.number().nonnegative().optional(),
      avoidance_enabled: z.boolean().optional(),
      neighbor_distance: z.number().nonnegative().optional(),
      max_neighbors: z.number().int().nonnegative().optional(),
      time_horizon: z.number().nonnegative().optional(),
      time_horizon_agents: z.number().nonnegative().optional(),
      time_horizon_obstacles: z.number().nonnegative().optional(),
      vision_area_name: z.string().optional(),
      vision_collision_layer: z.number().int().optional(),
      vision_collision_mask: z.number().int().optional(),
      vision_offset: vector2ParamSchema.optional(),
      attack_timer_name: z.string().optional(),
      target_path: z.string().optional(),
      patrol_loop: z.boolean().optional(),
      patrol_points: z.array(vector2ParamSchema).optional(),
      signal_target_path: z.string().optional(),
      vision_entered_method: z.string().optional(),
      vision_exited_method: z.string().optional(),
      attack_timeout_method: z.string().optional(),
      signal_deferred: z.boolean().optional(),
      signal_one_shot: z.boolean().optional(),
      signal_reference_counted: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: AuthorEnemyAi2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('author_enemy_ai_2d', args);
        const status = (result.status as string) ?? 'committed';
        const createdCount = Array.isArray(result.created_nodes) ? result.created_nodes.length : 0;
        const signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
        return `Authored enemy AI 2D for ${args.enemy_path}: ${createdCount} created node(s), ${signalCount} signal wiring change(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to author enemy AI 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'author_enemy_ai_3d',
    description: 'Author a 3D enemy AI scaffold (navigation, vision sensor, cooldown timer, metadata, and signal wiring)',
    parameters: z.object({
      enemy_path: z.string()
        .describe('Path to the CharacterBody3D enemy node'),
      create_navigation_agent: z.boolean().optional(),
      create_vision_area: z.boolean().optional(),
      create_attack_timer: z.boolean().optional(),
      connect_signals: z.boolean().optional(),
      movement_speed: z.number().nonnegative().optional(),
      acceleration: z.number().nonnegative().optional(),
      attack_cooldown: z.number().positive().optional(),
      vision_radius: z.number().positive().optional(),
      detection_group: z.string().optional(),
      navigation_agent_name: z.string().optional(),
      navigation_max_speed: z.number().nonnegative().optional(),
      path_desired_distance: z.number().nonnegative().optional(),
      target_desired_distance: z.number().nonnegative().optional(),
      avoidance_enabled: z.boolean().optional(),
      neighbor_distance: z.number().nonnegative().optional(),
      max_neighbors: z.number().int().nonnegative().optional(),
      agent_radius: z.number().nonnegative().optional(),
      agent_height: z.number().nonnegative().optional(),
      vision_area_name: z.string().optional(),
      vision_collision_layer: z.number().int().optional(),
      vision_collision_mask: z.number().int().optional(),
      vision_offset: vector3ParamSchema.optional(),
      attack_timer_name: z.string().optional(),
      target_path: z.string().optional(),
      patrol_loop: z.boolean().optional(),
      patrol_points: z.array(vector3ParamSchema).optional(),
      signal_target_path: z.string().optional(),
      vision_entered_method: z.string().optional(),
      vision_exited_method: z.string().optional(),
      attack_timeout_method: z.string().optional(),
      signal_deferred: z.boolean().optional(),
      signal_one_shot: z.boolean().optional(),
      signal_reference_counted: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: AuthorEnemyAi3DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('author_enemy_ai_3d', args);
        const status = (result.status as string) ?? 'committed';
        const createdCount = Array.isArray(result.created_nodes) ? result.created_nodes.length : 0;
        const signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
        return `Authored enemy AI 3D for ${args.enemy_path}: ${createdCount} created node(s), ${signalCount} signal wiring change(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to author enemy AI 3D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'build_menu_ui_flow_2d',
    description: 'Generate a complete menu flow scaffold (main/pause/game-over) and optional button signal wiring',
    parameters: z.object({
      parent_path: z.string().optional(),
      flow_name: z.string().optional(),
      include_pause_menu: z.boolean().optional(),
      include_game_over_menu: z.boolean().optional(),
      create_background: z.boolean().optional(),
      background_color: z.any().optional(),
      panel_size: vector2ParamSchema.optional(),
      title_text: z.string().optional(),
      start_text: z.string().optional(),
      quit_text: z.string().optional(),
      pause_title_text: z.string().optional(),
      resume_text: z.string().optional(),
      pause_restart_text: z.string().optional(),
      pause_quit_text: z.string().optional(),
      game_over_title_text: z.string().optional(),
      retry_text: z.string().optional(),
      game_over_quit_text: z.string().optional(),
      connect_signals: z.boolean().optional(),
      controller_path: z.string().optional(),
      start_pressed_method: z.string().optional(),
      quit_pressed_method: z.string().optional(),
      resume_pressed_method: z.string().optional(),
      pause_restart_pressed_method: z.string().optional(),
      pause_quit_pressed_method: z.string().optional(),
      retry_pressed_method: z.string().optional(),
      game_over_quit_pressed_method: z.string().optional(),
      signal_deferred: z.boolean().optional(),
      signal_one_shot: z.boolean().optional(),
      signal_reference_counted: z.boolean().optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: BuildMenuUiFlow2DParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('build_menu_ui_flow_2d', args);
        const status = (result.status as string) ?? 'committed';
        const flowPath = (result.flow_path as string) ?? 'unknown';
        const signalCount = Array.isArray(result.signal_changes) ? result.signal_changes.length : 0;
        return `Built menu UI flow at ${flowPath} with ${signalCount} signal wiring change(s) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to build menu UI flow 2D: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'set_menu_ui_flow_state',
    description: 'Switch a generated menu flow between main, pause, game-over, or hidden states',
    parameters: z.object({
      flow_path: z.string()
        .describe('Path to the menu flow root node'),
      state: z.enum(['main', 'pause', 'game_over', 'gameover', 'hidden'])
        .describe('Menu state to display'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: SetMenuUiFlowStateParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('set_menu_ui_flow_state', args);
        const status = (result.status as string) ?? 'committed';
        return `Set menu flow state for ${args.flow_path} to ${args.state} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to set menu UI flow state: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'rename_node',
    description: 'Rename an existing node while preserving undo history',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should be renamed (e.g. "/root/MainScene/Player")'),
      new_name: z.string()
        .min(1)
        .describe('New name for the node'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, new_name, transaction_id }: RenameNodeParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('rename_node', {
          node_path,
          new_name,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Node at ${node_path} already has the name "${new_name}".`;
        }

        const previousName = (result.previous_name as string) ?? node_path.split('/').pop() ?? node_path;
        return `Renamed node ${previousName} to ${result.new_name} [${status}]`;
      } catch (error) {
        throw new Error(`Failed to rename node: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'add_node_to_group',
    description: 'Add a node to a Godot group with optional persistence for scene saving',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node that should join the group (e.g. "/root/MainScene/Enemy")'),
      group_name: z.string()
        .min(1)
        .describe('Group name to assign (case-sensitive)'),
      persistent: z.boolean().optional()
        .describe('Whether the membership should be stored in the scene file (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, group_name, persistent, transaction_id }: NodeGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('add_node_to_group', {
          node_path,
          group_name,
          persistent,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'already_member') {
          return `Node at ${node_path} is already in group "${group_name}".`;
        }

        return `Added node ${node_path} to group "${group_name}" [${status}]`;
      } catch (error) {
        throw new Error(`Failed to add node to group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'remove_node_from_group',
    description: 'Remove a node from a Godot group with undo support',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node whose group membership should be removed'),
      group_name: z.string()
        .min(1)
        .describe('Group name to remove from the node'),
      persistent: z.boolean().optional()
        .describe('Whether undo should restore the membership as persistent (default true)'),
      transaction_id: z.string().optional()
        .describe('Optional scene transaction identifier used to batch operations'),
    }),
    execute: async ({ node_path, group_name, persistent, transaction_id }: RemoveNodeGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('remove_node_from_group', {
          node_path,
          group_name,
          persistent,
          transaction_id,
        });

        const status = (result.status as string) ?? 'committed';
        if (status === 'not_member') {
          return `Node at ${node_path} is not part of group "${group_name}".`;
        }

        return `Removed node ${node_path} from group "${group_name}" [${status}]`;
      } catch (error) {
        throw new Error(`Failed to remove node from group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'configure_camera2d_limits',
    description:
      'Adjust Camera2D limit bounds, smoothing, and editor visualization using undo-aware transactions.',
    parameters: z
      .object({
        node_path: z
          .string()
          .describe('Path to the Camera2D node that should be configured (e.g. "/root/MainScene/Camera2D")'),
        transaction_id: z
          .string()
          .optional()
          .describe('Optional scene transaction identifier used to batch operations before committing.'),
        limits: camera2DLimitsSchema.optional(),
        smoothing: camera2DSmoothingSchema.optional(),
      })
      .superRefine((value, ctx) => {
        const hasLimits = value.limits !== undefined;
        const hasSmoothing = value.smoothing !== undefined;
        if (!hasLimits && !hasSmoothing) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: 'Provide limits or smoothing properties to update.',
            path: ['limits'],
          });
        }
      }),
    execute: async ({ node_path, transaction_id, limits, smoothing }: ConfigureCamera2DLimitsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const payload: Record<string, unknown> = { node_path };
        if (transaction_id) {
          payload.transaction_id = transaction_id;
        }
        if (hasConfigurationEntries(limits)) {
          payload.limits = limits;
        }
        if (hasConfigurationEntries(smoothing)) {
          payload.smoothing = smoothing;
        }

        const result = await godot.sendCommand<CommandResult>('configure_camera2d_limits', payload);

        const status = (result.status as string) ?? 'committed';
        if (status === 'no_change') {
          return `Camera2D at ${node_path} already matches the requested configuration.`;
        }

        const changeSummary = Array.isArray(result.changes)
          ? (result.changes as Array<Record<string, unknown>>)
              .map(change => `${change.property}: ${JSON.stringify(change.value)}`)
              .join(', ')
          : undefined;

        const suffix = changeSummary && changeSummary.length > 0 ? ` (${changeSummary})` : '';
        return `Configured Camera2D limits for ${result.node_path ?? node_path} [${status}]${suffix}`;
      } catch (error) {
        throw new Error(`Failed to configure Camera2D limits: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
      escalationPrompt:
        'The assistant is requesting to modify Camera2D boundaries and smoothing. Approve if the scene should adopt these camera constraints.',
    },
  },
  {
    name: 'create_theme_override',
    description: 'Create or update a Control theme override with undo support.',
    parameters: z.object({
      node_path: z
        .string()
        .describe('Path to the Control node that should receive the theme override.'),
      override_type: z
        .enum(['color', 'constant', 'font', 'font_size', 'stylebox', 'icon'])
        .describe('Type of override to apply.'),
      override_name: z
        .string()
        .describe('Theme item name such as "font_color", "panel", or "normal".'),
      value: z
        .any()
        .optional()
        .describe('Override value. Colors accept HTML strings or RGBA dictionaries; resource overrides accept paths.'),
      resource_path: z
        .string()
        .optional()
        .describe('Resource path for font, icon, or stylebox overrides when different from `value`.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      node_path,
      override_type,
      override_name,
      value,
      resource_path,
      transaction_id,
    }: ThemeOverrideParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('create_theme_override', {
          node_path,
          override_type,
          override_name,
          value,
          resource_path,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const appliedValue = result.value ?? result.applied_value ?? value;
        const valueDescription = appliedValue === undefined ? 'inherit' : JSON.stringify(appliedValue);
        const resolvedName = (result.override_name as string) ?? override_name;
        const resolvedType = (result.override_type as string) ?? override_type;
        const resolvedPath = (result.node_path as string) ?? node_path;
        return `Theme override ${resolvedName} (${resolvedType}) applied to ${resolvedPath} [${status}] -> ${valueDescription}`;
      } catch (error) {
        throw new Error(`Failed to create theme override: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'wire_signal_handler',
    description: 'Connect a signal between nodes and generate method stubs when needed.',
    parameters: z.object({
      source_path: z
        .string()
        .describe('Node emitting the signal (e.g. "/root/Main/StartButton").'),
      signal_name: z
        .string()
        .describe('Name of the signal to connect (e.g. "pressed").'),
      target_path: z
        .string()
        .describe('Node that should receive the callback.'),
      method_name: z
        .string()
        .describe('Method to invoke on the target node when the signal fires.'),
      script_path: z
        .string()
        .optional()
        .describe('Optional script resource to assign before connecting the signal.'),
      create_script: z
        .boolean()
        .optional()
        .describe('Create a new script at `script_path` if none is assigned.'),
      arguments: z
        .array(z.string())
        .optional()
        .describe('Argument names to include in the generated stub.'),
      binds: z
        .array(z.any())
        .optional()
        .describe('Optional values to bind to the signal connection.'),
      deferred: z
        .boolean()
        .optional()
        .describe('Connect the signal in deferred mode.'),
      one_shot: z
        .boolean()
        .optional()
        .describe('Connect the signal in one-shot mode.'),
      reference_counted: z
        .boolean()
        .optional()
        .describe('Use reference-counted connections that disconnect when either side is freed.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      source_path,
      signal_name,
      target_path,
      method_name,
      script_path,
      create_script,
      arguments: argumentNames,
      binds,
      deferred,
      one_shot,
      reference_counted,
      transaction_id,
    }: WireSignalHandlerParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('wire_signal_handler', {
          source_path,
          signal_name,
          target_path,
          method_name,
          script_path,
          create_script,
          arguments: argumentNames,
          binds,
          deferred,
          one_shot,
          reference_counted,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const stubInfo = result.stub_created ? 'stub generated' : 'existing method';
        return `Connected ${signal_name} on ${source_path} -> ${method_name} [${status}; ${stubInfo}]`;
      } catch (error) {
        throw new Error(`Failed to wire signal handler: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'layout_ui_grid',
    description: 'Arrange Control children into a grid layout with consistent spacing.',
    parameters: z.object({
      container_path: z
        .string()
        .describe('Path to the container Control whose children should be arranged.'),
      columns: z
        .number()
        .int()
        .min(1)
        .optional()
        .describe('Number of columns to use (default 2).'),
      horizontal_gap: z
        .number()
        .optional()
        .describe('Horizontal spacing between columns in pixels.'),
      vertical_gap: z
        .number()
        .optional()
        .describe('Vertical spacing between rows in pixels.'),
      cell_size: z
        .union([
          z.object({ x: z.number().optional(), y: z.number().optional() }),
          z.tuple([z.number(), z.number()]),
        ])
        .optional()
        .describe('Uniform cell size expressed as `{ x, y }` or `[width, height]`.'),
      size_flags: z
        .object({ horizontal: z.number().optional(), vertical: z.number().optional() })
        .optional()
        .describe('Override size flags for child controls.'),
      transaction_id: z
        .string()
        .optional()
        .describe('Existing transaction identifier to batch with other edits.'),
    }),
    execute: async ({
      container_path,
      columns,
      horizontal_gap,
      vertical_gap,
      cell_size,
      size_flags,
      transaction_id,
    }: LayoutUiGridParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('layout_ui_grid', {
          container_path,
          columns,
          horizontal_gap,
          vertical_gap,
          cell_size,
          size_flags,
          transaction_id,
        });

        const status = (result.status as string) ?? 'pending';
        const updated = Array.isArray(result.updated_nodes) ? result.updated_nodes.length : 0;
        return `Applied grid layout to ${container_path} (${updated} controls) [${status}]`;
      } catch (error) {
        throw new Error(`Failed to layout UI grid: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'validate_accessibility',
    description: 'Scan Control nodes for accessibility gaps such as missing focus or descriptions.',
    parameters: z.object({
      root_path: z
        .string()
        .optional()
        .describe('Root node to scan (defaults to the edited scene root).'),
      include_hidden: z
        .boolean()
        .optional()
        .describe('Include hidden controls in the scan.'),
      max_depth: z
        .number()
        .int()
        .nonnegative()
        .optional()
        .describe('Limit the traversal depth (0 means unlimited).'),
    }),
    execute: async ({ root_path, include_hidden, max_depth }: ValidateAccessibilityParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('validate_accessibility', {
          root_path,
          include_hidden,
          max_depth,
        });

        const issueCount = Number(result.issue_count ?? result.issues?.length ?? 0);
        const scanned = Number(result.scanned_count ?? 0);
        const target = root_path ?? 'scene';
        return `Accessibility scan for ${target} inspected ${scanned} controls and found ${issueCount} issues.`;
      } catch (error) {
        throw new Error(`Failed to validate accessibility: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_node_groups',
    description: 'List all groups assigned to a specific node',
    parameters: z.object({
      node_path: z.string()
        .describe('Path to the node whose groups should be listed'),
    }),
    execute: async ({ node_path }: ListNodeGroupsParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_node_groups', { node_path });
        const groups = (result.groups as string[]) ?? [];
        if (groups.length === 0) {
          return `Node at ${node_path} is not assigned to any groups.`;
        }

        return `Groups for node ${node_path}:\n${groups.join('\n')}`;
      } catch (error) {
        throw new Error(`Failed to list node groups: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'list_nodes_in_group',
    description: 'Enumerate all nodes in the currently edited scene that belong to a specific group',
    parameters: z.object({
      group_name: z.string()
        .min(1)
        .describe('Group name to query'),
    }),
    execute: async ({ group_name }: ListNodesInGroupParams): Promise<string> => {
      const godot = getGodotConnection();

      try {
        const result = await godot.sendCommand<CommandResult>('list_nodes_in_group', { group_name });
        const nodes = (result.nodes as Array<Record<string, unknown>>) ?? [];
        if (nodes.length === 0) {
          return `No nodes found in group "${group_name}".`;
        }

        const formatted = nodes
          .map(node => `${node.name} (${node.type}) - ${node.path}`)
          .join('\n');

        return `Nodes in group "${group_name}":\n${formatted}`;
      } catch (error) {
        throw new Error(`Failed to list nodes in group: ${(error as Error).message}`);
      }
    },
    metadata: {
      requiredRole: 'read',
    },
  },
];
