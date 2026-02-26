import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { MCPTool } from '../dist/utils/types.js';

const snapshot = {
  generatedAt: '2024-01-01T00:00:00.000Z',
  projectRoot: '/workspace/Godot-MCP',
  root: [],
  entries: {},
  stats: { files: 0, directories: 0, totalSize: 0, skipped: [], truncated: false },
};

const mockState = vi.hoisted(() => {
  const sampleRecord = {
    id: 'esc-123',
    path: 'res://script.gd',
    mode: 'edit',
    reason: 'Modify script',
    requestedBy: 'tester',
    requestedAt: '2024-01-01T00:00:00.000Z',
    status: 'pending' as const,
    prompt: 'Please allow edit',
    metadata: {},
  };

  return {
    mockSendCommand: vi.fn<(command: string, payload?: unknown) => Promise<any>>(async () => ({})),
    mockRefresh: vi.fn(async () => snapshot),
    mockQuery: vi.fn(async () => []),
    mockGetIndex: vi.fn(async () => snapshot),
    mockPreview: vi.fn(async (diff: string) => ({
      patchId: 'patch-123',
      files: [
        {
          path: 'res://script.gd',
          mode: 'modify' as const,
          originalSize: diff.length,
          patchedSize: diff.length + 10,
        },
      ],
    })),
    mockApply: vi.fn(async (patchId: string) => ({
      patchId,
      appliedFiles: [
        {
          path: 'res://script.gd',
          mode: 'modify' as const,
        },
      ],
    })),
    mockCancel: vi.fn((_patchId: string) => undefined),
    sampleRecord,
    mockListEscalations: vi.fn(async ({ status }: { status?: 'pending' | 'approved' | 'denied' } = {}) => {
      if (!status || status === 'pending') {
        return [sampleRecord];
      }
      return [];
    }),
    mockResolveEscalation: vi.fn(async ({ id, status, resolver, notes }: {
      id: string;
      status: 'approved' | 'denied';
      resolver?: string;
      notes?: string;
    }) => ({
      ...sampleRecord,
      id,
      status,
      resolver,
      notes,
      resolvedAt: '2024-01-02T00:00:00.000Z',
    })),
  };
});

const {
  mockSendCommand,
  mockRefresh,
  mockQuery,
  mockGetIndex,
  mockPreview,
  mockApply,
  mockCancel,
  sampleRecord,
  mockListEscalations,
  mockResolveEscalation,
} = mockState;

vi.mock('../dist/utils/godot_connection.js', () => ({
  getGodotConnection: () => ({
    sendCommand: mockSendCommand,
    connect: vi.fn(),
    disconnect: vi.fn(),
  }),
}));

vi.mock('../dist/utils/project_indexer.js', () => ({
  projectIndexer: {
    refresh: mockRefresh,
    query: mockQuery,
    getIndex: mockGetIndex,
  },
}));

vi.mock('../dist/utils/patch_manager.js', () => ({
  patchManager: {
    preview: mockPreview,
    apply: mockApply,
    cancel: mockCancel,
  },
}));

vi.mock('../dist/utils/escalation_manager.js', () => ({
  escalationManager: {
    listEscalations: mockListEscalations,
    resolveEscalation: mockResolveEscalation,
  },
}));

const { nodeTools } = await import('../dist/tools/node_tools.js');
const { scriptTools } = await import('../dist/tools/script_tools.js');
const { sceneTools } = await import('../dist/tools/scene_tools.js');
const { editorTools } = await import('../dist/tools/editor_tools.js');
const { projectTools } = await import('../dist/tools/project_tools.js');
const { permissionTools } = await import('../dist/tools/permission_tools.js');
const { navigationTools } = await import('../dist/tools/navigation_tools.js');
const { audioTools } = await import('../dist/tools/audio_tools.js');
const { animationTools } = await import('../dist/tools/animation_tools.js');
const { patchTools } = await import('../dist/tools/patch_tools.js');
const { xrTools } = await import('../dist/tools/xr_tools.js');
const { multiplayerTools } = await import('../dist/tools/multiplayer_tools.js');
const { compressionTools } = await import('../dist/tools/compression_tools.js');
const { renderingTools } = await import('../dist/tools/rendering_tools.js');

const getTool = (collection: MCPTool[], name: string): MCPTool => {
  const tool = collection.find(item => item.name === name);
  if (!tool) {
    throw new Error(`Tool ${name} not found`);
  }
  return tool;
};

const godotCommandCases: Array<{
  collection: MCPTool[];
  name: string;
  args: Record<string, unknown>;
  command: string;
  response?: Record<string, unknown>;
}> = [
  { collection: nodeTools, name: 'create_node', command: 'create_node', args: { parent_path: '/root', node_type: 'Node2D', node_name: 'Generated' } },
  { collection: nodeTools, name: 'delete_node', command: 'delete_node', args: { node_path: '/root/Generated' } },
  { collection: nodeTools, name: 'update_node_property', command: 'update_node_property', args: { node_path: '/root/Generated', property: 'position', value: { x: 0, y: 0 } } },
  { collection: nodeTools, name: 'get_node_properties', command: 'get_node_properties', args: { node_path: '/root/Generated' }, response: { properties: { name: 'Generated' } } },
  { collection: nodeTools, name: 'list_nodes', command: 'list_nodes', args: { parent_path: '/root' }, response: { children: [] } },
  {
    collection: nodeTools,
    name: 'duplicate_node',
    command: 'duplicate_node',
    args: { source_path: '/root/Generated', new_name: 'GeneratedCopy' },
    response: { node_path: '/root/GeneratedCopy', node_name: 'GeneratedCopy', status: 'committed' },
  },
  {
    collection: nodeTools,
    name: 'reparent_node',
    command: 'reparent_node',
    args: { node_path: '/root/Generated', new_parent_path: '/root/Container', child_index: 0 },
    response: { node_path: '/root/Container/Generated', new_parent_path: '/root/Container', new_index: 0, status: 'committed' },
  },
  {
    collection: nodeTools,
    name: 'move_node_in_parent',
    command: 'move_node_in_parent',
    args: { node_path: '/root/Generated', index: 1 },
    response: { node_path: '/root/Generated', index: 1, status: 'committed' },
  },
  {
    collection: nodeTools,
    name: 'instantiate_scene',
    command: 'instantiate_scene',
    args: { scene_path: 'res://scenes/enemy.tscn', parent_path: '/root' },
    response: { node_path: '/root/Enemy', status: 'committed' },
  },
  {
    collection: nodeTools,
    name: 'query_nodes',
    command: 'query_nodes',
    args: { root_path: '/root', name_contains: 'Gen' },
    response: {
      root_path: '/root',
      count: 1,
      truncated: false,
      nodes: [{ name: 'Generated', type: 'Node2D', path: '/root/Generated' }],
    },
  },
  {
    collection: nodeTools,
    name: 'bulk_update_node_properties',
    command: 'bulk_update_node_properties',
    args: { node_path: '/root/Generated', properties: { 'position.x': 32, 'position.y': 48 } },
    response: { status: 'committed', changes: [{ property_path: 'position.x' }, { property_path: 'position.y' }] },
  },
  {
    collection: nodeTools,
    name: 'batch_create_nodes',
    command: 'batch_create_nodes',
    args: {
      parent_path: '/root',
      nodes: [
        { node_type: 'Node2D', node_name: 'BatchA' },
        { node_type: 'Label', node_name: 'BatchB', properties: { text: 'Hello' } },
      ],
    },
    response: { status: 'committed', count: 2, created_nodes: [{ node_path: '/root/BatchA' }, { node_path: '/root/BatchB' }] },
  },
  {
    collection: nodeTools,
    name: 'batch_delete_nodes',
    command: 'batch_delete_nodes',
    args: { node_paths: ['/root/BatchA', '/root/BatchB'] },
    response: { status: 'committed', deleted_count: 2, skipped_descendants: [] },
  },
  {
    collection: nodeTools,
    name: 'set_node_script',
    command: 'set_node_script',
    args: { node_path: '/root/Generated', script_path: 'res://scripts/generated.gd' },
    response: { status: 'committed', script_path: 'res://scripts/generated.gd' },
  },
  {
    collection: nodeTools,
    name: 'clear_node_script',
    command: 'clear_node_script',
    args: { node_path: '/root/Generated' },
    response: { status: 'committed', previous_script_path: 'res://scripts/generated.gd' },
  },
  {
    collection: nodeTools,
    name: 'set_node_owner_recursive',
    command: 'set_node_owner_recursive',
    args: { node_path: '/root/Generated', owner_path: '/root', include_root: true },
    response: { status: 'committed', changed_count: 1, owner_path: '/root' },
  },
  {
    collection: nodeTools,
    name: 'paint_tilemap_cells_2d',
    command: 'paint_tilemap_cells_2d',
    args: {
      node_path: '/root/TileMap',
      layer: 0,
      cells: [{ x: 0, y: 0, source_id: 1, atlas_coords: { x: 0, y: 0 }, alternative_tile: 0 }],
    },
    response: { status: 'committed', change_count: 1 },
  },
  {
    collection: nodeTools,
    name: 'clear_tilemap_cells_2d',
    command: 'clear_tilemap_cells_2d',
    args: {
      node_path: '/root/TileMap',
      layer: 0,
      cells: [{ x: 0, y: 0 }],
    },
    response: { status: 'committed', change_count: 1 },
  },
  {
    collection: nodeTools,
    name: 'configure_camera2d_follow',
    command: 'configure_camera2d_follow',
    args: {
      node_path: '/root/Camera2D',
      zoom: { x: 1.2, y: 1.2 },
      drag_enabled: { horizontal: true, vertical: true },
      drag_margins: { left: 0.2, right: 0.2, top: 0.1, bottom: 0.1 },
    },
    response: { status: 'committed', changes: [{ property: 'zoom' }] },
  },
  {
    collection: nodeTools,
    name: 'set_animation_tree_state',
    command: 'set_animation_tree_state',
    args: {
      node_path: '/root/PlayerAnimTree',
      state_name: 'run',
      active: true,
      process_callback: 1,
      use_start: false,
    },
    response: { status: 'committed', current_state: 'run', changes: [{ property: 'active' }] },
  },
  {
    collection: nodeTools,
    name: 'set_animation_tree_parameters',
    command: 'set_animation_tree_parameters',
    args: {
      node_path: '/root/PlayerAnimTree',
      parameters: {
        'parameters/run_blend/blend_amount': 0.85,
        'parameters/conditions/is_grounded': true,
      },
    },
    response: { status: 'committed', changes: [{ property: 'parameters/run_blend/blend_amount' }] },
  },
  {
    collection: nodeTools,
    name: 'build_wave_spawner_2d',
    command: 'build_wave_spawner_2d',
    args: {
      parent_path: '/root',
      spawner_name: 'EnemyWaves2D',
      spawn_points: [{ x: -64, y: 16 }, { x: 64, y: 16 }, { x: 0, y: -24 }],
      create_timer: true,
      wave_interval: 2.5,
      enemies_per_wave: 3,
      max_waves: 5,
    },
    response: { status: 'committed', spawner_path: '/root/EnemyWaves2D', spawn_point_count: 3 },
  },
  {
    collection: nodeTools,
    name: 'build_wave_spawner_3d',
    command: 'build_wave_spawner_3d',
    args: {
      parent_path: '/root',
      spawner_name: 'EnemyWaves3D',
      spawn_points: [{ x: -4, y: 0, z: -4 }, { x: 4, y: 0, z: -4 }, { x: 0, y: 0, z: 4 }],
      create_timer: true,
      wave_interval: 3.0,
      enemies_per_wave: 4,
      max_waves: 6,
    },
    response: { status: 'committed', spawner_path: '/root/EnemyWaves3D', spawn_point_count: 3 },
  },
  {
    collection: nodeTools,
    name: 'simulate_wave_spawner_step_2d',
    command: 'simulate_wave_spawner_step_2d',
    args: {
      spawner_path: '/root/EnemyWaves2D',
      spawn_count: 3,
      advance_wave: true,
      instantiate_enemy: false,
    },
    response: { status: 'committed', spawn_count: 3, next_wave: 2, spawn_positions: [{ x: 0, y: 0 }] },
  },
  {
    collection: nodeTools,
    name: 'simulate_wave_spawner_step_3d',
    command: 'simulate_wave_spawner_step_3d',
    args: {
      spawner_path: '/root/EnemyWaves3D',
      spawn_count: 2,
      advance_wave: true,
      instantiate_enemy: false,
    },
    response: { status: 'committed', spawn_count: 2, next_wave: 2, spawn_positions: [{ x: 0, y: 0, z: 0 }] },
  },
  {
    collection: nodeTools,
    name: 'simulate_camera2d_shake',
    command: 'simulate_camera2d_shake',
    args: {
      node_path: '/root/Camera2D',
      trauma: 0.8,
      amplitude: 14,
      rotation_amplitude_degrees: 2.5,
      seed: 1234,
    },
    response: { status: 'committed', offset: { x: 6.1, y: -4.2 }, rotation_radians: 0.04 },
  },
  {
    collection: nodeTools,
    name: 'simulate_camera3d_shake',
    command: 'simulate_camera3d_shake',
    args: {
      node_path: '/root/Camera3D',
      trauma: 0.75,
      horizontal_amplitude: 0.25,
      vertical_amplitude: 0.2,
      roll_amplitude_degrees: 2.0,
      fov_pulse: 1.2,
      seed: 4321,
    },
    response: { status: 'committed', h_offset: 0.08, v_offset: -0.04, fov: 76.2, rotation: { x: 0, y: 0, z: 0.03 } },
  },
  {
    collection: nodeTools,
    name: 'configure_parallax_2d',
    command: 'configure_parallax_2d',
    args: {
      node_path: '/root/Parallax',
      scroll_scale: { x: 0.5, y: 1.0 },
      autoscroll: { x: 15, y: 0 },
    },
    response: { status: 'committed', changes: [{ property: 'scroll_scale' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_animated_sprite_2d',
    command: 'configure_animated_sprite_2d',
    args: {
      node_path: '/root/PlayerAnimated',
      animation: 'run',
      speed_scale: 1.5,
      flip_h: false,
    },
    response: { status: 'committed', changes: [{ property: 'animation' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_sprite_2d',
    command: 'configure_sprite_2d',
    args: {
      node_path: '/root/Sprite',
      texture_path: 'res://icon.svg',
      centered: true,
      flip_h: false,
    },
    response: { status: 'committed', changes: [{ property: 'texture' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_characterbody2d_controller',
    command: 'configure_characterbody2d_controller',
    args: {
      node_path: '/root/Player2D',
      floor_snap_length: 4.0,
      floor_max_angle: 0.9,
      max_slides: 6,
    },
    response: { status: 'committed', changes: [{ property: 'floor_snap_length' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_area2d_sensor',
    command: 'configure_area2d_sensor',
    args: {
      node_path: '/root/TriggerArea',
      monitoring: true,
      collision_layer: 2,
      collision_mask: 1,
    },
    response: { status: 'committed', changes: [{ property: 'monitoring' }] },
  },
  {
    collection: nodeTools,
    name: 'fill_tilemap_rect_2d',
    command: 'fill_tilemap_rect_2d',
    args: {
      node_path: '/root/TileMap',
      origin: { x: 0, y: 0 },
      size: { x: 4, y: 2 },
      source_id: 1,
      atlas_coords: { x: 0, y: 0 },
      alternative_tile: 0,
    },
    response: { status: 'committed', change_count: 8 },
  },
  {
    collection: nodeTools,
    name: 'generate_tilemap_noise_2d',
    command: 'generate_tilemap_noise_2d',
    args: {
      node_path: '/root/TileMap',
      layer: 0,
      origin: { x: 0, y: 0 },
      size: { x: 12, y: 8 },
      source_id: 1,
      atlas_coords: { x: 0, y: 0 },
      threshold: 0.05,
      clear_unselected: true,
      noise_seed: 1024,
      frequency: 0.09,
      fractal_octaves: 2,
    },
    response: { status: 'committed', change_count: 53, painted_count: 41, cleared_count: 12 },
  },
  {
    collection: nodeTools,
    name: 'tilemap_terrain_autopaint_2d',
    command: 'tilemap_terrain_autopaint_2d',
    args: {
      node_path: '/root/TileMap',
      layer: 0,
      terrain_set: 0,
      terrain: 1,
      mode: 'connect',
      origin: { x: 0, y: 0 },
      size: { x: 14, y: 8 },
      use_noise: true,
      threshold: 0.02,
      clear_unselected: false,
      frequency: 0.08,
      noise_seed: 6060,
    },
    response: { status: 'committed', selected_count: 62, changed_count: 49 },
  },
  {
    collection: nodeTools,
    name: 'generate_heightmap_gridmap_3d',
    command: 'generate_heightmap_gridmap_3d',
    args: {
      node_path: '/root/GridMap',
      origin: { x: 0, y: 0, z: 0 },
      size: { x: 16, y: 16 },
      item_id: 0,
      orientation: 0,
      min_height: 0,
      max_height: 5,
      surface_only: false,
      clear_unselected: true,
      noise_seed: 777,
      frequency: 0.07,
    },
    response: { status: 'committed', change_count: 184, placed_count: 184, cleared_count: 0 },
  },
  {
    collection: nodeTools,
    name: 'scatter_scene_instances_2d',
    command: 'scatter_scene_instances_2d',
    args: {
      parent_path: '/root/World2D',
      scene_path: 'res://scenes/coin.tscn',
      count: 10,
      rect: { x: -320, y: -180, width: 640, height: 360 },
      min_distance: 24,
      max_attempts: 400,
      random_rotation: true,
      random_scale: true,
      scale_range: { x: 0.85, y: 1.2 },
      seed: 2026,
    },
    response: { status: 'committed', requested_count: 10, created_count: 10, created_nodes: ['/root/World2D/Scatter2D01'] },
  },
  {
    collection: nodeTools,
    name: 'scatter_scene_instances_3d',
    command: 'scatter_scene_instances_3d',
    args: {
      parent_path: '/root/World3D',
      scene_path: 'res://scenes/crate.tscn',
      count: 18,
      origin: { x: -20, y: 0, z: -20 },
      size: { x: 40, y: 6, z: 40 },
      min_distance: 1.5,
      max_attempts: 800,
      random_yaw: true,
      random_scale: true,
      scale_range: { x: 0.8, y: 1.3 },
      seed: 4242,
    },
    response: { status: 'committed', requested_count: 18, created_count: 18, created_nodes: ['/root/World3D/Scatter3D01'] },
  },
  {
    collection: nodeTools,
    name: 'configure_characterbody3d_controller',
    command: 'configure_characterbody3d_controller',
    args: {
      node_path: '/root/Player3D',
      floor_snap_length: 0.25,
      floor_max_angle: 0.8,
      max_slides: 6,
      safe_margin: 0.01,
    },
    response: { status: 'committed', changes: [{ property: 'floor_snap_length' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_camera3d_rig',
    command: 'configure_camera3d_rig',
    args: {
      node_path: '/root/Camera3D',
      position: { x: 0, y: 4, z: -8 },
      rotation_degrees: { x: -12, y: 0, z: 0 },
      current: true,
      projection: 1,
      size: 14,
    },
    response: { status: 'committed', changes: [{ property: 'position' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_springarm3d',
    command: 'configure_springarm3d',
    args: {
      node_path: '/root/CameraBoom',
      spring_length: 7.5,
      margin: 0.1,
      collision_mask: 1,
    },
    response: { status: 'committed', changes: [{ property: 'spring_length' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_navigation_agent_2d',
    command: 'configure_navigation_agent_2d',
    args: {
      node_path: '/root/EnemyAgent2D',
      navigation_layers: 1,
      max_speed: 180,
      path_desired_distance: 6,
      target_desired_distance: 8,
      avoidance_enabled: true,
    },
    response: { status: 'committed', changes: [{ property: 'max_speed' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_navigation_agent_3d',
    command: 'configure_navigation_agent_3d',
    args: {
      node_path: '/root/EnemyAgent3D',
      navigation_layers: 1,
      max_speed: 4.5,
      radius: 0.4,
      height: 1.8,
      avoidance_enabled: true,
    },
    response: { status: 'committed', changes: [{ property: 'max_speed' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_navigation_obstacle_2d',
    command: 'configure_navigation_obstacle_2d',
    args: {
      node_path: '/root/Obstacle2D',
      avoidance_enabled: true,
      avoidance_layers: 1,
      radius: 20,
      velocity: { x: 48, y: 0 },
      vertices: [{ x: -24, y: -24 }, { x: 24, y: -24 }, { x: 24, y: 24 }, { x: -24, y: 24 }],
    },
    response: { status: 'committed', changes: [{ property: 'radius' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_navigation_obstacle_3d',
    command: 'configure_navigation_obstacle_3d',
    args: {
      node_path: '/root/Obstacle3D',
      avoidance_enabled: true,
      avoidance_layers: 1,
      radius: 0.7,
      height: 1.8,
      velocity: { x: 1.5, y: 0, z: 0 },
      vertices: [{ x: -0.8, y: 0, z: -0.8 }, { x: 0.8, y: 0, z: -0.8 }, { x: 0.8, y: 0, z: 0.8 }, { x: -0.8, y: 0, z: 0.8 }],
    },
    response: { status: 'committed', changes: [{ property: 'radius' }] },
  },
  {
    collection: nodeTools,
    name: 'advance_pathfollow2d',
    command: 'advance_pathfollow2d',
    args: {
      node_path: '/root/PlatformPath/PathFollow2D',
      speed: 120,
      delta: 0.0166667,
      loop: true,
      cubic_interp: true,
      rotates: true,
    },
    response: { status: 'committed', progress: 8.5, changes: [{ property: 'progress' }] },
  },
  {
    collection: nodeTools,
    name: 'advance_pathfollow3d',
    command: 'advance_pathfollow3d',
    args: {
      node_path: '/root/FlightPath/PathFollow3D',
      speed: 4.2,
      delta: 0.0166667,
      loop: true,
      cubic_interp: true,
      rotation_mode: 2,
      tilt_enabled: false,
      use_model_front: true,
    },
    response: { status: 'committed', progress: 0.3, changes: [{ property: 'progress' }] },
  },
  {
    collection: nodeTools,
    name: 'configure_path2d_followers',
    command: 'configure_path2d_followers',
    args: {
      path_path: '/root/PlatformPath',
      follower_count: 4,
      create_missing: true,
      base_name: 'Mover',
      use_progress_ratio: true,
      spacing: 0.2,
      start_progress: 0.0,
      loop: true,
      cubic_interp: true,
      rotates: false,
      speed: 90,
    },
    response: { status: 'committed', follower_count: 4, created_count: 4, updated_count: 4 },
  },
  {
    collection: nodeTools,
    name: 'configure_path3d_followers',
    command: 'configure_path3d_followers',
    args: {
      path_path: '/root/FlightPath',
      follower_count: 3,
      create_missing: true,
      base_name: 'Drone',
      use_progress_ratio: true,
      spacing: 0.33,
      loop: true,
      cubic_interp: true,
      rotation_mode: 2,
      tilt_enabled: false,
      use_model_front: true,
      speed: 4.8,
    },
    response: { status: 'committed', follower_count: 3, created_count: 3, updated_count: 3 },
  },
  {
    collection: nodeTools,
    name: 'configure_topdown_movement_2d',
    command: 'configure_topdown_movement_2d',
    args: {
      node_path: '/root/Player2D',
      apply_defaults: true,
      speed: 260,
      acceleration: 1800,
      deceleration: 2400,
      input_actions: {
        up: 'move_up',
        down: 'move_down',
        left: 'move_left',
        right: 'move_right',
      },
    },
    response: { status: 'committed', changes: [{ property: 'motion_mode' }], meta_changes: [{ key: 'mcp_topdown_speed' }] },
  },
  {
    collection: nodeTools,
    name: 'simulate_characterbody2d_movement',
    command: 'simulate_characterbody2d_movement',
    args: {
      node_path: '/root/Player2D',
      direction: { x: 1, y: 0 },
      speed: 220,
      acceleration: 1600,
      deceleration: 2000,
      delta: 0.0166667,
      set_rotation: true,
    },
    response: { status: 'committed', position: { x: 3.5, y: 0 }, velocity: { x: 210, y: 0 } },
  },
  {
    collection: nodeTools,
    name: 'simulate_characterbody3d_movement',
    command: 'simulate_characterbody3d_movement',
    args: {
      node_path: '/root/Player3D',
      direction: { x: 0, y: 0, z: 1 },
      speed: 6.0,
      acceleration: 40.0,
      deceleration: 60.0,
      delta: 0.0166667,
      yaw_to_direction: true,
    },
    response: { status: 'committed', position: { x: 0, y: 1, z: 0.08 }, velocity: { x: 0, y: 0, z: 4.8 } },
  },
  {
    collection: nodeTools,
    name: 'simulate_navigation_chase_step_2d',
    command: 'simulate_navigation_chase_step_2d',
    args: {
      agent_path: '/root/Enemy2D/NavigationAgent2D',
      body_path: '/root/Enemy2D',
      delta: 0.0166667,
      speed: 180,
      acceleration: 1200,
      deceleration: 1600,
      stop_distance: 6,
      set_rotation: true,
      update_agent_velocity: true,
      sync_agent_to_body: true,
      allow_direct_fallback: true,
    },
    response: { status: 'committed', position: { x: 48.5, y: 32 }, velocity: { x: 90, y: 0 }, navigation_finished: false },
  },
  {
    collection: nodeTools,
    name: 'simulate_navigation_chase_step_3d',
    command: 'simulate_navigation_chase_step_3d',
    args: {
      agent_path: '/root/Enemy3D/NavigationAgent3D',
      body_path: '/root/Enemy3D',
      delta: 0.0166667,
      speed: 5.5,
      acceleration: 36,
      deceleration: 48,
      stop_distance: 0.5,
      planar_only: true,
      preserve_vertical_velocity: true,
      yaw_to_direction: true,
      update_agent_velocity: true,
      sync_agent_to_body: true,
      allow_direct_fallback: true,
    },
    response: { status: 'committed', position: { x: 1.2, y: 0.5, z: -2.9 }, velocity: { x: 2.2, y: 0, z: 4.4 }, navigation_finished: false },
  },
  {
    collection: nodeTools,
    name: 'set_navigation_target_to_node_2d',
    command: 'set_navigation_target_to_node_2d',
    args: {
      agent_path: '/root/EnemyAgent2D',
      target_path: '/root/Player2D',
      offset: { x: 8, y: 0 },
      remember_target: true,
    },
    response: { status: 'committed', target_position: { x: 120, y: 48 }, changes: [{ property: 'target_position' }] },
  },
  {
    collection: nodeTools,
    name: 'set_navigation_target_to_node_3d',
    command: 'set_navigation_target_to_node_3d',
    args: {
      agent_path: '/root/EnemyAgent3D',
      target_path: '/root/Player3D',
      offset: { x: 0, y: 0, z: 1.5 },
      remember_target: true,
    },
    response: { status: 'committed', target_position: { x: 0, y: 1, z: -3.5 }, changes: [{ property: 'target_position' }] },
  },
  {
    collection: nodeTools,
    name: 'build_water_body_2d',
    command: 'build_water_body_2d',
    args: {
      parent_path: '/root',
      water_name: 'WaterLake2D',
      position: { x: -320, y: 180 },
      size: { x: 640, y: 140 },
      create_visual: true,
      create_area: true,
      create_collision: true,
      flow_direction: { x: 1, y: 0.1 },
      flow_speed: 36,
      buoyancy: 1.25,
      wave_amplitude: 10,
      wave_speed: 1.3,
      wave_length: 120,
      color: { r: 0.15, g: 0.45, b: 0.9, a: 0.55 },
    },
    response: { status: 'committed', water_path: '/root/WaterLake2D', paths: { area_path: '/root/WaterLake2D/WaterArea2D' } },
  },
  {
    collection: nodeTools,
    name: 'build_water_body_3d',
    command: 'build_water_body_3d',
    args: {
      parent_path: '/root',
      water_name: 'WaterPlane3D',
      position: { x: 0, y: 0.5, z: 0 },
      size: { x: 24, y: 24 },
      depth: 3.5,
      create_visual: true,
      create_area: true,
      create_collision: true,
      flow_direction: { x: 1, y: 0 },
      flow_speed: 2.2,
      wave_amplitude: 0.35,
      wave_speed: 1.4,
      wave_length: 2.8,
      subdivide_width: 32,
      subdivide_depth: 32,
    },
    response: { status: 'committed', water_path: '/root/WaterPlane3D', paths: { area_path: '/root/WaterPlane3D/WaterArea3D' } },
  },
  {
    collection: nodeTools,
    name: 'build_sand_field_3d',
    command: 'build_sand_field_3d',
    args: {
      parent_path: '/root',
      field_name: 'SandField3D',
      origin: { x: 0, y: 0, z: 0 },
      size: { x: 10, y: 3, z: 10 },
      create_visual: true,
      create_volume_area: true,
      grain_spacing: 0.5,
      grain_radius: 0.16,
      jitter: 0.08,
      max_grains: 240,
      random_yaw: true,
      internal_friction: 0.95,
      cohesion: 0.2,
      stiffness: 1700,
      bulk_density: 1650,
      profile_name: 'homogenized_sand',
      seed: 5050,
    },
    response: { status: 'committed', field_path: '/root/SandField3D', grain_count: 240, paths: { grains_path: '/root/SandField3D/SandGrains' } },
  },
  {
    collection: nodeTools,
    name: 'build_cave_2d',
    command: 'build_cave_2d',
    args: {
      parent_path: '/root',
      cave_name: 'ProceduralCave2D',
      origin: { x: 0, y: 0 },
      grid_size: { x: 42, y: 26 },
      cell_size: { x: 24, y: 24 },
      fill_ratio: 0.46,
      smoothing_steps: 5,
      birth_limit: 4,
      death_limit: 3,
      border_solid: true,
      create_collision: true,
      create_visuals: true,
      create_background: true,
      create_spawn_marker: true,
      seed: 8080,
    },
    response: {
      status: 'committed',
      cave_path: '/root/ProceduralCave2D',
      wall_segment_count: 118,
      wall_cell_count: 642,
      open_cell_count: 450,
      paths: { spawn_path: '/root/ProceduralCave2D/SpawnPoint' },
    },
  },
  {
    collection: nodeTools,
    name: 'build_sand_field_2d',
    command: 'build_sand_field_2d',
    args: {
      parent_path: '/root',
      field_name: 'SandField2D',
      origin: { x: 0, y: 0 },
      size: { x: 900, y: 280 },
      create_visual: true,
      create_volume_area: true,
      grain_spacing: 20,
      grain_radius: 7,
      jitter: 4,
      max_grains: 360,
      random_rotation: true,
      grain_segments: 10,
      profile_name: 'homogenized_sand_2d',
      internal_friction: 0.92,
      cohesion: 0.16,
      stiffness: 1250,
      bulk_density: 1580,
      seed: 9090,
    },
    response: {
      status: 'committed',
      field_path: '/root/SandField2D',
      grain_count: 360,
      paths: { grains_path: '/root/SandField2D/SandGrains2D' },
    },
  },
  {
    collection: nodeTools,
    name: 'generate_platformer_blockout_2d',
    command: 'generate_platformer_blockout_2d',
    args: {
      parent_path: '/root',
      level_name: 'PlatformerCourse',
      origin: { x: 0, y: 0 },
      segment_count: 16,
      min_platform_width: 96,
      max_platform_width: 220,
      platform_height: 32,
      min_gap: 42,
      max_gap: 110,
      base_y: 240,
      min_height_step: -58,
      max_height_step: 64,
      create_collision: true,
      create_visuals: true,
      create_spawn_marker: true,
      create_goal_marker: true,
      seed: 4242,
    },
    response: {
      status: 'committed',
      level_path: '/root/PlatformerCourse',
      segment_count: 16,
      estimated_total_length: 3370,
      paths: { spawn_path: '/root/PlatformerCourse/SpawnPoint', goal_path: '/root/PlatformerCourse/GoalPoint' },
    },
  },
  {
    collection: nodeTools,
    name: 'generate_topdown_dungeon_2d',
    command: 'generate_topdown_dungeon_2d',
    args: {
      parent_path: '/root',
      dungeon_name: 'TopdownDungeon',
      origin: { x: 0, y: 0 },
      grid_size: { x: 56, y: 56 },
      cell_size: { x: 20, y: 20 },
      room_attempts: 120,
      room_target: 14,
      room_min_size: { x: 6, y: 6 },
      room_max_size: { x: 12, y: 14 },
      corridor_width: 2,
      create_floor_visuals: true,
      create_wall_collision: true,
      create_wall_visuals: true,
      create_spawn_marker: true,
      create_goal_marker: true,
      seed: 5151,
    },
    response: {
      status: 'committed',
      dungeon_path: '/root/TopdownDungeon',
      room_count: 13,
      corridor_count: 12,
      floor_cell_count: 1234,
      wall_cell_count: 1081,
      paths: { walls_path: '/root/TopdownDungeon/Walls' },
    },
  },
  {
    collection: nodeTools,
    name: 'generate_isometric_tile_blockout_2d',
    command: 'generate_isometric_tile_blockout_2d',
    args: {
      parent_path: '/root',
      level_name: 'IsoBlockout',
      origin: { x: 0, y: 0 },
      grid_size: { x: 14, y: 14 },
      tile_size: { x: 96, y: 48 },
      min_height: 0,
      max_height: 4,
      elevation_step: 20,
      noise_frequency: 0.14,
      create_side_faces: true,
      create_collision: false,
      seed: 6262,
    },
    response: {
      status: 'committed',
      level_path: '/root/IsoBlockout',
      tile_count: 196,
      height_range: { min: 0, max: 4 },
      paths: { tiles_path: '/root/IsoBlockout/Tiles' },
    },
  },
  {
    collection: nodeTools,
    name: 'generate_tentacle_waypoints_2d',
    command: 'generate_tentacle_waypoints_2d',
    args: {
      parent_path: '/root',
      tentacle_name: 'TentacleRig',
      origin: { x: 64, y: 120 },
      waypoint_count: 9,
      segment_length: 52,
      lateral_amplitude: 30,
      wave_count: 1.4,
      random_jitter: 3,
      taper: 0.7,
      direction: { x: 1, y: -0.2 },
      create_line: true,
      create_waypoint_markers: true,
      create_segment_markers: true,
      create_tip_marker: true,
      seed: 7373,
    },
    response: {
      status: 'committed',
      tentacle_path: '/root/TentacleRig',
      waypoint_count: 9,
      total_length: 430.5,
      paths: { path_path: '/root/TentacleRig/Path' },
    },
  },
  {
    collection: nodeTools,
    name: 'build_creature_parts_2d',
    command: 'build_creature_parts_2d',
    args: {
      parent_path: '/root',
      creature_name: 'CreatureParts',
      origin: { x: 0, y: 0 },
      scale: 1.1,
      include_tail: true,
      include_wings: true,
      include_horns: true,
      create_visuals: true,
      create_collision: true,
      create_attachment_markers: true,
    },
    response: {
      status: 'committed',
      creature_path: '/root/CreatureParts',
      part_count: 11,
      paths: { parts_path: '/root/CreatureParts/Parts' },
    },
  },
  {
    collection: nodeTools,
    name: 'build_slime_mold_colony_2d',
    command: 'build_slime_mold_colony_2d',
    args: {
      parent_path: '/root',
      colony_name: 'SlimeColony',
      origin: { x: 0, y: 0 },
      grid_size: { x: 40, y: 32 },
      cell_size: { x: 14, y: 14 },
      initial_cell_count: 8,
      initial_radius: 3,
      spread_chance: 0.26,
      growth_rate: 0.24,
      max_cells: 240,
      create_visuals: true,
      create_collision: false,
      seed: 8484,
    },
    response: {
      status: 'committed',
      colony_path: '/root/SlimeColony',
      cell_count: 8,
      paths: { cells_path: '/root/SlimeColony/Cells' },
    },
  },
  {
    collection: nodeTools,
    name: 'simulate_slime_mold_growth_step_2d',
    command: 'simulate_slime_mold_growth_step_2d',
    args: {
      colony_path: '/root/SlimeColony',
      cells_path: '/root/SlimeColony/Cells',
      steps: 3,
      max_new_cells_per_step: 5,
      spread_chance: 0.22,
      growth_rate: 0.3,
      allow_diagonal: false,
      seed: 8585,
    },
    response: {
      status: 'committed',
      colony_path: '/root/SlimeColony',
      cells_path: '/root/SlimeColony/Cells',
      added_count: 9,
      total_cells: 17,
    },
  },
  {
    collection: nodeTools,
    name: 'configure_light_node',
    command: 'configure_light_node',
    args: {
      node_path: '/root/Level/KeyLight2D',
      enabled: true,
      color: { r: 1, g: 0.92, b: 0.76, a: 1 },
      energy: 1.5,
      texture_scale: 1.2,
      shadow_enabled: true,
      shadow_color: { r: 0.08, g: 0.08, b: 0.12, a: 0.9 },
      profile_name: 'warm_key',
    },
    response: {
      status: 'committed',
      node_path: '/root/Level/KeyLight2D',
      light_type: 'PointLight2D',
      enabled: true,
      color: { r: 1, g: 0.92, b: 0.76, a: 1 },
      energy: 1.5,
    },
  },
  {
    collection: nodeTools,
    name: 'build_smoke_effect_2d',
    command: 'build_smoke_effect_2d',
    args: {
      parent_path: '/root',
      smoke_name: 'CampfireSmoke',
      origin: { x: 160, y: 240 },
      area_size: { x: 640, y: 360 },
      intensity: 0.72,
      wind_direction: { x: 0.8, y: -0.2 },
      wind_strength: 0.4,
      max_particles: 2200,
      particle_lifetime: 4.2,
      rise_speed_min: 22,
      rise_speed_max: 88,
      spread_degrees: 30,
      rise_acceleration: 74,
      damping_min: 5,
      damping_max: 14,
      create_overlay: true,
      overlay_density: 0.2,
      seed: 9393,
    },
    response: {
      status: 'committed',
      smoke_path: '/root/CampfireSmoke',
      particle_amount: 1584,
      can_emit: true,
      paths: { smoke_particles_path: '/root/CampfireSmoke/SmokeParticles' },
    },
  },
  {
    collection: nodeTools,
    name: 'configure_particles_3d',
    command: 'configure_particles_3d',
    args: {
      node_path: '/root/FX/SmokeParticles3D',
      emitting: true,
      amount: 1400,
      lifetime: 3.4,
      one_shot: false,
      local_coords: false,
      speed_scale: 1.0,
      spread: 18,
      gravity: { x: 0, y: 3.8, z: 0 },
      initial_velocity_min: 1.4,
      initial_velocity_max: 3.2,
      damping_min: 0.4,
      damping_max: 1.8,
      scale_min: 0.9,
      scale_max: 2.2,
      profile_name: 'smoke_column_soft',
    },
    response: { status: 'committed', amount: 1400, lifetime: 3.4, emitting: true },
  },
  {
    collection: nodeTools,
    name: 'build_smoke_effect_3d',
    command: 'build_smoke_effect_3d',
    args: {
      parent_path: '/root',
      smoke_name: 'FactorySmoke3D',
      position: { x: 0, y: 0.5, z: 0 },
      volume_size: { x: 6, y: 3, z: 6 },
      intensity: 0.68,
      wind_direction: { x: 0.4, y: 0.9, z: 0.1 },
      wind_strength: 0.45,
      max_particles: 2800,
      particle_lifetime: 4.0,
      rise_speed_min: 1.6,
      rise_speed_max: 4.4,
      create_ground_haze: true,
      seed: 9494,
    },
    response: { status: 'committed', smoke_path: '/root/FactorySmoke3D', particle_amount: 1904, can_emit: true },
  },
  {
    collection: nodeTools,
    name: 'build_light_occluder_2d',
    command: 'build_light_occluder_2d',
    args: {
      parent_path: '/root/Level',
      occluder_name: 'WallOccluder',
      position: { x: 96, y: 128 },
      size: { x: 160, y: 64 },
      closed: true,
      cull_mode: 1,
      occluder_light_mask: 1,
      sdf_collision: true,
    },
    response: { status: 'committed', occluder_path: '/root/Level/WallOccluder', point_count: 4 },
  },
  {
    collection: nodeTools,
    name: 'edit_light_occluder_polygon_2d',
    command: 'edit_light_occluder_polygon_2d',
    args: {
      occluder_path: '/root/Level/WallOccluder',
      append_points: [{ x: 24, y: 12 }],
      offset: { x: 2, y: -1 },
      closed: true,
      cull_mode: 1,
      profile_name: 'building_wall',
    },
    response: { status: 'committed', point_count: 5 },
  },
  {
    collection: nodeTools,
    name: 'build_subviewport_minimap',
    command: 'build_subviewport_minimap',
    args: {
      parent_path: '/root/UI',
      minimap_name: 'MinimapHUD',
      target_path: '/root/Player2D',
      mode: '2d',
      size: { x: 260, y: 180 },
      margin: 16,
      anchor: 'top_right',
      zoom_2d: 0.22,
      canvas_layer: 20,
    },
    response: { status: 'committed', minimap_path: '/root/UI/MinimapHUD', mode: '2d' },
  },
  {
    collection: nodeTools,
    name: 'build_weather_system_2d',
    command: 'build_weather_system_2d',
    args: {
      parent_path: '/root',
      weather_name: 'WeatherRig2D',
      origin: { x: 0, y: 0 },
      area_size: { x: 1280, y: 720 },
      preset: 'storm',
      intensity: 0.85,
      transition_rate: 2.4,
      wind_direction: { x: -0.22, y: 1.0 },
      wind_strength: 0.7,
      enable_precipitation: true,
      enable_fog: true,
      enable_ambient_modulate: true,
      enable_lightning_overlay: true,
      max_particles: 3000,
      lightning_enabled: true,
      lightning_chance: 0.08,
      seed: 9191,
    },
    response: {
      status: 'committed',
      weather_path: '/root/WeatherRig2D',
      preset: 'storm',
      intensity: 0.85,
      precipitation_mode: 'rain',
      can_emit_precipitation: true,
      paths: { precipitation_path: '/root/WeatherRig2D/Precipitation' },
    },
  },
  {
    collection: nodeTools,
    name: 'simulate_weather_step_2d',
    command: 'simulate_weather_step_2d',
    args: {
      weather_path: '/root/WeatherRig2D',
      target_preset: 'blizzard',
      target_intensity: 0.92,
      delta: 0.0166667,
      transition_rate: 2.0,
      wind_direction: { x: -0.6, y: 1.0 },
      wind_strength: 0.95,
      trigger_lightning: true,
      seed: 9292,
    },
    response: {
      status: 'committed',
      weather_path: '/root/WeatherRig2D',
      preset: 'blizzard',
      intensity: 0.9,
      precipitation_emitting: true,
      precipitation_amount: 2600,
      flash_alpha: 0.88,
    },
  },
  {
    collection: nodeTools,
    name: 'simulate_water_current_step_2d',
    command: 'simulate_water_current_step_2d',
    args: {
      water_path: '/root/WaterLake2D',
      body_path: '/root/Player2D',
      delta: 0.0166667,
      flow_scale: 1.0,
      buoyancy_scale: 1.2,
      drag_scale: 1.0,
      clamp_speed: 260,
      apply_position: true,
      require_inside: true,
    },
    response: {
      status: 'committed',
      inside_water: true,
      submersion: 0.45,
      position: { x: 24.5, y: 188.9 },
      velocity: { x: 41.2, y: -23.8 },
    },
  },
  {
    collection: nodeTools,
    name: 'simulate_water_current_step_3d',
    command: 'simulate_water_current_step_3d',
    args: {
      water_path: '/root/WaterPlane3D',
      body_path: '/root/Player3D',
      delta: 0.0166667,
      flow_scale: 1.0,
      buoyancy_scale: 0.9,
      preserve_vertical_velocity: false,
      clamp_speed: 8,
      apply_position: true,
      require_inside: true,
    },
    response: {
      status: 'committed',
      inside_water: true,
      submersion: 0.32,
      position: { x: 0.12, y: -0.8, z: 0.25 },
      velocity: { x: 2.1, y: 0.4, z: 1.8 },
    },
  },
  {
    collection: nodeTools,
    name: 'settle_sand_field_3d',
    command: 'settle_sand_field_3d',
    args: {
      field_path: '/root/SandField3D',
      grains_path: '/root/SandField3D/SandGrains',
      iterations: 3,
      settle_strength: 0.6,
      horizontal_jitter: 0.15,
      downward_bias: 0.22,
      keep_bounds: true,
      seed: 9001,
    },
    response: {
      status: 'committed',
      field_path: '/root/SandField3D',
      grains_path: '/root/SandField3D/SandGrains',
      instance_count: 240,
      moved_instances: 240,
      average_drop: 0.11,
    },
  },
  {
    collection: nodeTools,
    name: 'build_stage_blockout_2d',
    command: 'build_stage_blockout_2d',
    args: {
      parent_path: '/root',
      stage_name: 'StageBlockout',
      blocks: [
        { name: 'Ground', position: { x: 0, y: 200 }, size: { x: 640, y: 48 } },
        { name: 'PlatformA', position: { x: 220, y: 120 }, size: { x: 160, y: 32 } },
      ],
      create_visuals: true,
    },
    response: { status: 'committed', stage_path: '/root/StageBlockout', block_count: 2 },
  },
  {
    collection: nodeTools,
    name: 'build_hud_ui_2d',
    command: 'build_hud_ui_2d',
    args: {
      parent_path: '/root',
      hud_name: 'HUD',
      include_health: true,
      include_score: true,
      include_objective: true,
      include_pause_button: true,
      margin: 16,
      spacing: 8,
    },
    response: { status: 'committed', hud_path: '/root/HUD', labels: [{ name: 'HealthLabel' }, { name: 'ScoreLabel' }] },
  },
  {
    collection: nodeTools,
    name: 'author_enemy_ai_2d',
    command: 'author_enemy_ai_2d',
    args: {
      enemy_path: '/root/Enemy2D',
      create_navigation_agent: true,
      create_vision_area: true,
      create_attack_timer: true,
      connect_signals: true,
      signal_target_path: '/root/EnemyController',
      movement_speed: 180,
      vision_radius: 220,
      patrol_points: [{ x: -96, y: 0 }, { x: 96, y: 0 }],
    },
    response: { status: 'committed', created_nodes: ['/root/Enemy2D/NavigationAgent2D'], signal_changes: [{ signal: 'body_entered' }] },
  },
  {
    collection: nodeTools,
    name: 'author_enemy_ai_3d',
    command: 'author_enemy_ai_3d',
    args: {
      enemy_path: '/root/Enemy3D',
      create_navigation_agent: true,
      create_vision_area: true,
      create_attack_timer: true,
      connect_signals: true,
      signal_target_path: '/root/EnemyController3D',
      movement_speed: 5.5,
      vision_radius: 7.5,
      patrol_points: [{ x: -4, y: 0, z: 0 }, { x: 4, y: 0, z: 0 }],
    },
    response: { status: 'committed', created_nodes: ['/root/Enemy3D/NavigationAgent3D'], signal_changes: [{ signal: 'body_entered' }] },
  },
  {
    collection: nodeTools,
    name: 'build_menu_ui_flow_2d',
    command: 'build_menu_ui_flow_2d',
    args: {
      parent_path: '/root',
      flow_name: 'MenuFlow',
      include_pause_menu: true,
      include_game_over_menu: true,
      connect_signals: true,
      controller_path: '/root/MenuController',
      title_text: 'My Game',
      start_text: 'Play',
      quit_text: 'Exit',
    },
    response: { status: 'committed', flow_path: '/root/MenuFlow', signal_changes: [{ signal: 'pressed' }] },
  },
  {
    collection: nodeTools,
    name: 'set_menu_ui_flow_state',
    command: 'set_menu_ui_flow_state',
    args: {
      flow_path: '/root/MenuFlow',
      state: 'pause',
    },
    response: { status: 'committed', state: 'pause', changes: [{ property: 'visible' }] },
  },
  { collection: nodeTools, name: 'rename_node', command: 'rename_node', args: { node_path: '/root/Generated', new_name: 'Renamed' } },
  { collection: nodeTools, name: 'add_node_to_group', command: 'add_node_to_group', args: { node_path: '/root/Generated', group_name: 'GroupA' } },
  { collection: nodeTools, name: 'remove_node_from_group', command: 'remove_node_from_group', args: { node_path: '/root/Generated', group_name: 'GroupA' } },
  {
    collection: nodeTools,
    name: 'configure_camera2d_limits',
    command: 'configure_camera2d_limits',
    args: {
      node_path: '/root/Camera2D',
      limits: { enabled: true, left: -256, right: 256, top: -128, bottom: 128, smoothed: true },
      smoothing: { position_enabled: true, position_speed: 6, rotation_enabled: false },
    },
  },
  {
    collection: nodeTools,
    name: 'create_theme_override',
    command: 'create_theme_override',
    args: {
      node_path: '/root/UI/Label',
      override_type: 'color',
      override_name: 'font_color',
      value: '#ffcc00',
    },
    response: {
      node_path: '/root/UI/Label',
      override_type: 'color',
      override_name: 'font_color',
      status: 'committed',
      value: '#ffcc00',
    },
  },
  {
    collection: nodeTools,
    name: 'wire_signal_handler',
    command: 'wire_signal_handler',
    args: {
      source_path: '/root/UI/Button',
      signal_name: 'pressed',
      target_path: '/root/UI/Controller',
      method_name: '_on_button_pressed',
    },
    response: {
      status: 'committed',
      stub_created: true,
    },
  },
  {
    collection: nodeTools,
    name: 'layout_ui_grid',
    command: 'layout_ui_grid',
    args: {
      container_path: '/root/UI/Grid',
      columns: 3,
      horizontal_gap: 12,
      vertical_gap: 8,
    },
    response: {
      status: 'committed',
      updated_nodes: [{ node_path: '/root/UI/Grid/Label1' }],
    },
  },
  {
    collection: nodeTools,
    name: 'validate_accessibility',
    command: 'validate_accessibility',
    args: { root_path: '/root/UI' },
    response: {
      issue_count: 1,
      scanned_count: 5,
      issues: [{ node_path: '/root/UI/Button', issues: ['Missing accessible description'] }],
    },
  },
  { collection: nodeTools, name: 'list_node_groups', command: 'list_node_groups', args: { node_path: '/root/Generated' } },
  { collection: nodeTools, name: 'list_nodes_in_group', command: 'list_nodes_in_group', args: { group_name: 'GroupA' } },
  { collection: scriptTools, name: 'create_script', command: 'create_script', args: { script_path: 'res://scripts/example.gd', content: 'extends Node' } },
  { collection: scriptTools, name: 'edit_script', command: 'edit_script', args: { script_path: 'res://scripts/example.gd', content: 'extends Node\n' } },
  { collection: scriptTools, name: 'get_script', command: 'get_script', args: { script_path: 'res://scripts/example.gd' } },
  { collection: sceneTools, name: 'create_scene', command: 'create_scene', args: { path: 'res://scenes/new_scene.tscn', root_node_type: 'Node2D' } },
  { collection: sceneTools, name: 'save_scene', command: 'save_scene', args: { path: 'res://scenes/new_scene.tscn' } },
  { collection: sceneTools, name: 'open_scene', command: 'open_scene', args: { path: 'res://scenes/new_scene.tscn' } },
  { collection: sceneTools, name: 'get_current_scene', command: 'get_current_scene', args: {} },
  {
    collection: sceneTools,
    name: 'get_project_info',
    command: 'get_project_info',
    args: {},
    response: {
      project_name: 'Test Project',
      project_version: '1.0.0',
      project_path: '/workspace/project',
      godot_version: { major: 4, minor: 2, patch: 1 },
      current_scene: 'res://scene.tscn',
    },
  },
  { collection: sceneTools, name: 'create_resource', command: 'create_resource', args: { resource_type: 'ImageTexture', resource_path: 'res://textures/test.tres', properties: {} } },
  { collection: sceneTools, name: 'begin_scene_transaction', command: 'begin_scene_transaction', args: { action_name: 'Batch Edit' } },
  { collection: sceneTools, name: 'commit_scene_transaction', command: 'commit_scene_transaction', args: { transaction_id: 'txn-1' } },
  { collection: sceneTools, name: 'rollback_scene_transaction', command: 'rollback_scene_transaction', args: { transaction_id: 'txn-1' } },
  { collection: sceneTools, name: 'list_scene_transactions', command: 'list_scene_transactions', args: {} },
  { collection: sceneTools, name: 'configure_physics_body', command: 'configure_physics_body', args: { node_path: '/root/Body', properties: { mass: 1 } } },
  { collection: sceneTools, name: 'configure_physics_area', command: 'configure_physics_area', args: { node_path: '/root/Area', properties: { gravity: 9.8 } } },
  { collection: sceneTools, name: 'configure_physics_joint', command: 'configure_physics_joint', args: { node_path: '/root/Joint', properties: { bias: 0.1 } } },
  {
    collection: sceneTools,
    name: 'link_joint_bodies',
    command: 'link_joint_bodies',
    args: {
      joint_path: '/root/Joint',
      body_a_path: '/root/BodyA',
      body_b_path: '/root/BodyB',
      properties: { max_force: 100 },
    },
  },
  {
    collection: sceneTools,
    name: 'rebuild_physics_shapes',
    command: 'rebuild_physics_shapes',
    args: {
      node_path: '/root/CollisionShape3D',
      mesh_node_path: '/root/MeshInstance3D',
      shape_type: 'convex',
    },
  },
  {
    collection: sceneTools,
    name: 'profile_physics_step',
    command: 'profile_physics_step',
    args: { include_2d: true, include_3d: true, include_performance: true },
  },
  { collection: sceneTools, name: 'configure_csg_shape', command: 'configure_csg_shape', args: { node_path: '/root/CSG', properties: { radius: 2 } } },
  { collection: sceneTools, name: 'configure_material_resource', command: 'configure_material_resource', args: { resource_path: 'res://materials/mat.tres', material_properties: { albedo_color: '#ffffff' } } },
  {
    collection: sceneTools,
    name: 'paint_gridmap_cells',
    command: 'paint_gridmap_cells',
    args: { node_path: '/root/Grid', cells: [{ position: { x: 0, y: 0, z: 0 }, item: 1 }], transaction_id: 'txn' },
  },
  {
    collection: sceneTools,
    name: 'clear_gridmap_cells',
    command: 'clear_gridmap_cells',
    args: { node_path: '/root/Grid', cells: [{ position: { x: 0, y: 0, z: 0 } }], transaction_id: 'txn' },
  },
  { collection: projectTools, name: 'list_input_actions', command: 'list_input_actions', args: {} },
  { collection: projectTools, name: 'list_audio_buses', command: 'list_audio_buses', args: {} },
  {
    collection: projectTools,
    name: 'configure_audio_bus',
    command: 'configure_audio_bus',
    args: { bus_name: 'Master', volume_db: -6 },
  },
  {
    collection: projectTools,
    name: 'configure_project_setting',
    command: 'configure_project_setting',
    args: {
      setting: 'application/config/name',
      value: 'Updated Project',
      persist: true,
    },
    response: {
      setting: 'application/config/name',
      changed: true,
    },
  },
  {
    collection: projectTools,
    name: 'add_input_action',
    command: 'add_input_action',
    args: { action_name: 'jump', overwrite: true, events: [] },
  },
  {
    collection: projectTools,
    name: 'remove_input_action',
    command: 'remove_input_action',
    args: { action_name: 'jump' },
  },
  {
    collection: projectTools,
    name: 'add_input_event_to_action',
    command: 'add_input_event_to_action',
    args: { action_name: 'jump', event: { type: 'key', keycode: 32 } },
  },
  {
    collection: projectTools,
    name: 'remove_input_event_from_action',
    command: 'remove_input_event_from_action',
    args: { action_name: 'jump', event_index: 0 },
  },
  {
    collection: projectTools,
    name: 'configure_input_action_context',
    command: 'configure_input_action_context',
    args: {
      context_name: 'gamepad',
      actions: [
        { name: 'move_left', events: [{ type: 'key', keycode: 65 }] },
        { name: 'jump', remove: true },
      ],
    },
    response: {
      context_name: 'gamepad',
      created_actions: ['move_left'],
      updated_actions: [],
      removed_actions: ['jump'],
    },
  },
  { collection: navigationTools, name: 'list_navigation_maps', command: 'list_navigation_maps', args: { dimension: 'both' } },
  { collection: navigationTools, name: 'list_navigation_agents', command: 'list_navigation_agents', args: { dimension: 'both' } },
  {
    collection: navigationTools,
    name: 'bake_navigation_region',
    command: 'bake_navigation_region',
    args: { node_path: '/root/NavRegion', on_thread: true },
  },
  {
    collection: navigationTools,
    name: 'update_navigation_region',
    command: 'update_navigation_region',
    args: { node_path: '/root/NavRegion', properties: { enabled: true } },
  },
  {
    collection: navigationTools,
    name: 'update_navigation_resource',
    command: 'update_navigation_resource',
    args: { node_path: '/root/NavRegion', resource_path: 'res://navmesh.tres', properties: { agent_radius: 0.5 } },
  },
  {
    collection: navigationTools,
    name: 'update_navigation_agent',
    command: 'update_navigation_agent',
    args: { node_path: '/root/Agent', properties: { max_speed: 5 } },
  },
  {
    collection: navigationTools,
    name: 'synchronize_navmesh_with_tilemap',
    command: 'synchronize_navmesh_with_tilemap',
    args: { tilemap_path: '/root/TileMap', region_paths: ['/root/NavRegion'], on_thread: true },
  },
  { collection: audioTools, name: 'author_audio_stream_player', command: 'author_audio_stream_player', args: { parent_path: '/root', player_name: 'Music', stream_path: 'res://audio/theme.ogg', autoplay: true } },
  {
    collection: audioTools,
    name: 'author_interactive_music_graph',
    command: 'author_interactive_music_graph',
    args: {
      resource_path: 'res://audio/interactive.tres',
      clips: [{ name: 'base', stream_path: 'res://audio/base.ogg' }],
    },
  },
  {
    collection: audioTools,
    name: 'generate_dynamic_music_layer',
    command: 'generate_dynamic_music_layer',
    args: {
      resource_path: 'res://audio/interactive.tres',
      base_clip: 0,
      layer: { name: 'layer', stream_path: 'res://audio/layer.ogg' },
    },
  },
  {
    collection: audioTools,
    name: 'analyze_waveform',
    command: 'analyze_waveform',
    args: { resource_path: 'res://audio/theme.ogg', envelope_bins: 128 },
  },
  {
    collection: audioTools,
    name: 'batch_import_audio_assets',
    command: 'batch_import_audio_assets',
    args: {
      assets: [
        {
          path: 'res://audio/theme.ogg',
          preset: 'music_high_quality',
          options: { 'edit/loop': true, 'compress/mode': 'disabled' },
        },
      ],
    },
  },
  {
    collection: editorTools,
    name: 'execute_editor_script',
    command: 'execute_editor_script',
    args: { code: 'print("hello")' },
    response: { output: ['hello'], result: { value: 1 } },
  },
  {
    collection: editorTools,
    name: 'run_godot_headless',
    command: 'run_godot_headless',
    args: { run_target: 'res://scenes/demo.tscn', additional_args: ['--quit-after-init'] },
    response: { exit_code: 0 },
  },
  {
    collection: editorTools,
    name: 'capture_editor_profile',
    command: 'capture_editor_profile',
    args: { include_rendering: true, include_gpu: true },
    response: { fps: 60 },
  },
  {
    collection: editorTools,
    name: 'manage_editor_plugins',
    command: 'manage_editor_plugins',
    args: { action: 'enable', plugins: ['res://addons/sample/plugin.cfg'], persist: true },
    response: { mutated: ['res://addons/sample/plugin.cfg'] },
  },
  {
    collection: editorTools,
    name: 'snapshot_scene_state',
    command: 'snapshot_scene_state',
    args: { include_resources: false, node_limit: 10 },
    response: { node_count: 3 },
  },
  { collection: animationTools, name: 'list_animation_players', command: 'list_animation_players', args: { include_tracks: true } },
  { collection: animationTools, name: 'describe_animation_tracks', command: 'describe_animation_tracks', args: { include_keys: true } },
  { collection: animationTools, name: 'describe_animation_state_machines', command: 'describe_animation_state_machines', args: { include_transitions: true } },
  {
    collection: animationTools,
    name: 'edit_animation',
    command: 'edit_animation',
    args: {
      player_path: '/root/Animator',
      animation: 'Idle',
      operations: [
        { type: 'set_property', property: 'length', value: 1.25 },
        { type: 'insert_key', track_path: '../Sprite:position', time: 0, value: { x: 0, y: 0 } },
      ],
    },
  },
  {
    collection: animationTools,
    name: 'configure_animation_tree',
    command: 'configure_animation_tree',
    args: {
      tree_path: '/root/AnimationTree',
      properties: { active: true },
      parameters: { 'Blend2/blend_amount': 0.5 },
      state_transitions: [{ path: 'parameters/StateMachine/playback', state: 'Run' }],
    },
  },
  {
    collection: animationTools,
    name: 'bake_skeleton_pose',
    command: 'bake_skeleton_pose',
    args: {
      skeleton_path: '/root/Skeleton3D',
      player_path: '/root/Animator',
      animation: 'PoseCapture',
      bones: ['Spine'],
      space: 'local',
      time: 0,
    },
  },
  {
    collection: animationTools,
    name: 'generate_tween_sequence',
    command: 'generate_tween_sequence',
    args: {
      player_path: '/root/Animator',
      animation: 'TweenTimeline',
      sequence: [
        {
          target_path: '/root/Sprite2D',
          property: 'position',
          from: { x: 0, y: 0 },
          to: { x: 64, y: 64 },
          duration: 0.5,
        },
      ],
    },
  },
  {
    collection: animationTools,
    name: 'sync_particles_with_animation',
    command: 'sync_particles_with_animation',
    args: {
      particles_path: '/root/Particles3D',
      player_path: '/root/Animator',
      animation: 'Idle',
      emission: { lifetime: 1.2 },
    },
  },
  { collection: xrTools, name: 'list_xr_interfaces', command: 'list_xr_interfaces', args: {} },
  {
    collection: xrTools,
    name: 'initialize_xr_interface',
    command: 'initialize_xr_interface',
    args: { interface_name: 'OpenXR', make_primary: true },
  },
  {
    collection: xrTools,
    name: 'shutdown_xr_interface',
    command: 'shutdown_xr_interface',
    args: { interface_name: 'OpenXR' },
  },
  {
    collection: xrTools,
    name: 'save_xr_project_settings',
    command: 'save_xr_project_settings',
    args: { settings: [{ path: 'xr/openxr/enabled', value: true }], save: true },
  },
  { collection: multiplayerTools, name: 'get_multiplayer_state', command: 'get_multiplayer_state', args: {} },
  {
    collection: multiplayerTools,
    name: 'create_multiplayer_peer',
    command: 'create_multiplayer_peer',
    args: { peer_type: 'enet', mode: 'server', port: 9000 },
  },
  { collection: multiplayerTools, name: 'teardown_multiplayer_peer', command: 'teardown_multiplayer_peer', args: {} },
  {
    collection: multiplayerTools,
    name: 'spawn_multiplayer_scene',
    command: 'spawn_multiplayer_scene',
    args: { scene_path: 'res://scenes/network.tscn', parent_path: '/root', owner_peer_id: 1 },
  },
  {
    collection: compressionTools,
    name: 'configure_texture_compression',
    command: 'configure_texture_compression',
    args: { platform: 'mobile', settings: { mode: 'astc' }, save: true },
  },
  {
    collection: compressionTools,
    name: 'batch_reimport_textures',
    command: 'batch_reimport_textures',
    args: { paths: ['res://textures/icon.png'] },
  },
  {
    collection: compressionTools,
    name: 'create_texture_import_preset',
    command: 'create_texture_import_preset',
    args: { preset_name: 'astc_high', importer: 'texture', options: { 'compress/mode': 'Lossy' }, save: true },
  },
  {
    collection: compressionTools,
    name: 'list_texture_compression_settings',
    command: 'list_texture_compression_settings',
    args: {},
  },
  {
    collection: renderingTools,
    name: 'generate_material_variant',
    command: 'generate_material_variant',
    args: {
      source_material: 'res://materials/base_material.tres',
      overrides: { albedo_color: '#ffffff' },
    },
  },
  {
    collection: renderingTools,
    name: 'compile_shader_preview',
    command: 'compile_shader_preview',
    args: {
      shader_code: 'shader_type spatial; void fragment() { ALBEDO = vec3(1.0); }',
    },
  },
  {
    collection: renderingTools,
    name: 'unwrap_lightmap_uv2',
    command: 'unwrap_lightmap_uv2',
    args: {
      mesh_path: 'res://meshes/example.mesh',
      texel_size: 0.2,
    },
  },
  {
    collection: renderingTools,
    name: 'optimize_mesh_lods',
    command: 'optimize_mesh_lods',
    args: {
      mesh_path: 'res://meshes/example.mesh',
      lods: [0.5, 0.25],
    },
  },
  {
    collection: renderingTools,
    name: 'configure_environment',
    command: 'configure_environment',
    args: {
      environment_path: 'res://environment/world_env.tres',
      properties: { background_mode: 2 },
      ambient_light: { energy: 1.0 },
    },
  },
  {
    collection: renderingTools,
    name: 'preview_environment_sun_settings',
    command: 'preview_environment_sun_settings',
    args: {
      environment_path: 'res://environment/world_env.tres',
      sun: { color: '#ffd27f', amount: 0.5 },
    },
  },
  {
    collection: renderingTools,
    name: 'generate_procedural_planet',
    command: 'generate_procedural_planet',
    args: {
      seed: 1337,
      texture_width: 512,
      texture_height: 256,
      radius: 2.0,
      save_material_path: 'res://materials/planet_material.tres',
      create_node: true,
      parent_path: '/root/Main',
      node_name: 'PlanetA',
    },
  },
  {
    collection: renderingTools,
    name: 'generate_procedural_planet_ocean',
    command: 'generate_procedural_planet_ocean',
    args: {
      mesh_mode: 'single_tile',
      tile_size: 4.0,
      wave_scale: 2.8,
      wave_speed: 0.45,
      create_node: true,
      parent_path: '/root/Main',
      node_name: 'OceanTile01',
      save_material_path: 'res://materials/ocean_tile_material.tres',
    },
  },
  {
    collection: renderingTools,
    name: 'create_planet_shell',
    command: 'create_planet_shell',
    args: {
      radius: 2.2,
      color: { r: 0.28, g: 0.42, b: 0.33, a: 1.0 },
      create_node: true,
      parent_path: '/root/Main',
      node_name: 'PlanetShellSimple',
    },
  },
  {
    collection: renderingTools,
    name: 'create_ocean_tile',
    command: 'create_ocean_tile',
    args: {
      tile_size: 6.0,
      wave_speed: 0.5,
      create_node: true,
      parent_path: '/root/Main',
      node_name: 'OceanTileSimple',
    },
  },
  {
    collection: renderingTools,
    name: 'apply_triplanar_terrain_material',
    command: 'apply_triplanar_terrain_material',
    args: {
      node_path: '/root/Main/TerrainMesh',
      texture_scale: 2.6,
      snow_height: 0.72,
    },
  },
  {
    collection: renderingTools,
    name: 'generate_planet_cloud_layer',
    command: 'generate_planet_cloud_layer',
    args: {
      cloud_radius: 2.25,
      cloud_density: 0.5,
      planet_node_path: '/root/Main/PlanetShellSimple',
      parent_path: '/root/Main',
      node_name: 'PlanetClouds',
    },
  },
  {
    collection: renderingTools,
    name: 'create_planet_atmosphere_glow',
    command: 'create_planet_atmosphere_glow',
    args: {
      radius: 2.32,
      fresnel_power: 4.2,
      intensity: 1.3,
      planet_node_path: '/root/Main/PlanetShellSimple',
      parent_path: '/root/Main',
      node_name: 'PlanetAtmosphere',
    },
  },
  {
    collection: renderingTools,
    name: 'scatter_craters_on_sphere',
    command: 'scatter_craters_on_sphere',
    args: {
      count: 18,
      planet_radius: 2.2,
      seed: 501,
      parent_path: '/root/Main/PlanetShellSimple',
      node_name: 'CraterFieldA',
    },
  },
  {
    collection: renderingTools,
    name: 'create_ring_system',
    command: 'create_ring_system',
    args: {
      inner_radius: 2.8,
      outer_radius: 4.1,
      tilt_degrees: 18,
      parent_path: '/root/Main',
      node_name: 'PlanetRingsA',
    },
  },
  {
    collection: renderingTools,
    name: 'generate_starfield_skybox',
    command: 'generate_starfield_skybox',
    args: {
      width: 1024,
      height: 512,
      star_count: 1800,
      node_path: '/root/Main/WorldEnvironment',
      apply_to_environment: true,
    },
  },
  {
    collection: renderingTools,
    name: 'create_moon_proxy',
    command: 'create_moon_proxy',
    args: {
      radius: 0.45,
      distance: 5.2,
      orbit_speed_deg_per_sec: 7.5,
      planet_node_path: '/root/Main/PlanetShellSimple',
      parent_path: '/root/Main',
      node_name: 'MoonA',
    },
  },
  {
    collection: renderingTools,
    name: 'planet_preset_quickstart',
    command: 'planet_preset_quickstart',
    args: {
      preset: 'earthlike',
      parent_path: '/root/Main',
      node_name: 'PlanetPresetA',
      planet_radius: 1.8,
      include_moon: true,
    },
  },
];

describe('Godot MCP tool command wiring', () => {
  beforeEach(() => {
    mockSendCommand.mockClear();
    mockSendCommand.mockImplementation(async () => ({}));
    mockRefresh.mockClear();
    mockQuery.mockClear();
    mockGetIndex.mockClear();
    mockPreview.mockClear();
    mockApply.mockClear();
    mockCancel.mockClear();
    mockListEscalations.mockClear();
    mockResolveEscalation.mockClear();
  });

  for (const testCase of godotCommandCases) {
    it(`executes ${testCase.name} and calls ${testCase.command}`, async () => {
      if (testCase.response) {
        mockSendCommand.mockResolvedValueOnce(testCase.response);
      }

      const tool = getTool(testCase.collection, testCase.name);
      const output = await tool.execute(testCase.args as never);

      expect(typeof output).toBe('string');
      expect(mockSendCommand).toHaveBeenCalledTimes(1);
      expect(mockSendCommand).toHaveBeenCalledWith(testCase.command, expect.anything());
    });
  }

  it('generates script templates locally without Godot access', async () => {
    const tool = getTool(scriptTools, 'create_script_template');
    const output = await tool.execute({
      class_name: 'Enemy',
      extends_type: 'CharacterBody2D',
      include_ready: true,
      include_process: false,
      include_input: true,
      include_physics: false,
    });

    expect(output).toContain('class_name Enemy');
    expect(mockSendCommand).not.toHaveBeenCalled();
  });

  it('refreshes the project index via projectIndexer', async () => {
    const tool = getTool(projectTools, 'refresh_project_index');
    const output = await tool.execute({});

    expect(output).toContain('generated_at');
    expect(mockRefresh).toHaveBeenCalledTimes(1);
  });

  it('queries the cached project index', async () => {
    mockQuery.mockResolvedValueOnce([
      {
        path: 'res://scripts/example.gd',
        type: 'file',
        size: 10,
        modified: '2024-01-01T00:00:00.000Z',
      },
    ]);

    const tool = getTool(projectTools, 'query_project_index');
    const output = await tool.execute({ pattern: 'res://**/*.gd' });

    expect(mockQuery).toHaveBeenCalledWith(['res://**/*.gd'], { includeDirectories: true, limit: undefined });
    expect(JSON.parse(output).matches.length).toBe(1);
  });

  it('previews patches using the patch manager', async () => {
    const tool = getTool(patchTools, 'preview_patch');
    const diff = 'diff --git a/file b/file';
    const output = await tool.execute({ diff });

    expect(mockPreview).toHaveBeenCalledWith(diff);
    expect(output).toContain('patch-123');
  });

  it('applies patches via the patch manager', async () => {
    const tool = getTool(patchTools, 'apply_patch');
    const output = await tool.execute({ patch_id: 'patch-123' });

    expect(mockApply).toHaveBeenCalledWith('patch-123');
    expect(output).toContain('patch-123');
  });

  it('cancels patches via the patch manager', async () => {
    const tool = getTool(patchTools, 'cancel_patch');
    const output = await tool.execute({ patch_id: 'patch-123' });

    expect(mockCancel).toHaveBeenCalledWith('patch-123');
    expect(output).toContain('true');
  });

  it('lists permission escalations', async () => {
    const tool = getTool(permissionTools, 'list_permission_escalations');
    const output = await tool.execute({});

    expect(mockListEscalations).toHaveBeenCalledWith({});
    expect(JSON.parse(output).count).toBeGreaterThanOrEqual(0);
  });

  it('resolves permission escalations', async () => {
    mockResolveEscalation.mockResolvedValueOnce({
      id: 'esc-123',
      status: 'approved',
      resolvedAt: '2024-01-02T00:00:00.000Z',
      resolver: 'admin',
      notes: 'Approved',
      prompt: 'Please allow edit',
      metadata: {},
    });

    const tool = getTool(permissionTools, 'resolve_permission_escalation');
    const output = await tool.execute({ escalation_id: 'esc-123', status: 'approved', resolver: 'admin', notes: 'Approved' });

    expect(mockResolveEscalation).toHaveBeenCalledWith({
      id: 'esc-123',
      status: 'approved',
      resolver: 'admin',
      notes: 'Approved',
    });
    expect(output).toContain('approved');
  });
});
