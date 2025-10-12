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
