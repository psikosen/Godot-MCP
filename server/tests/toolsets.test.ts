import { describe, expect, it } from 'vitest';
import { enabledToolsets, groupsOf, toolsetOf } from '../src/utils/toolsets.js';

describe('toolsets', () => {
  it('sorts tools into groups', () => {
    expect(toolsetOf('create_node')).toBe('core');
    expect(toolsetOf('get_scene_tree')).toBe('core');
    expect(toolsetOf('begin_scene_transaction')).toBe('scene');
    expect(toolsetOf('apply_patch')).toBe('scene');
    expect(toolsetOf('wire_signal_handler')).toBe('scripting');
    expect(toolsetOf('remove_input_event_from_action')).toBe('project');
    expect(toolsetOf('capture_game_frame')).toBe('testing');
    expect(toolsetOf('configure_camera2d_follow')).toBe('2d');
    expect(toolsetOf('configure_camera3d_rig')).toBe('3d');
    expect(toolsetOf('generate_procedural_planet_ocean')).toBe('space');
    expect(toolsetOf('scatter_craters_on_sphere')).toBe('space');
    expect(toolsetOf('build_water_body_2d')).toBe('effects');
    expect(toolsetOf('apply_triplanar_terrain_material')).toBe('levelgen');
    expect(toolsetOf('edit_animation')).toBe('animation');
    expect(toolsetOf('configure_navigation_agent_2d')).toBe('navigation');
    expect(toolsetOf('profile_physics_step')).toBe('physics');
    expect(toolsetOf('initialize_xr_interface')).toBe('xr');
    expect(toolsetOf('build_light_occluder_2d')).toBe('2d');
    expect(toolsetOf('build_subviewport_minimap')).toBe('ui');
  });

  it('puts a tool in its main group and every task group that lists it', () => {
    expect(groupsOf('set_collision_layers')).toEqual(['physics', 'player_2d', 'player_3d', 'enemies', 'gameplay']);
    expect(groupsOf('capture_scene_image')).toEqual(['testing', 'world_3d', 'lighting', 'vfx', 'inspect']);
    expect(groupsOf('list_audio_buses')).toEqual(['audio', 'inspect']);
    expect(groupsOf('build_water_body_2d')).toEqual(['effects', 'water']);
    expect(groupsOf('create_path')).toEqual(['scene', 'world_3d', 'procgen_3d', 'paths']);
    expect(groupsOf('generate_topdown_dungeon_2d')).toEqual(['levelgen', 'tilemap_level', 'procgen_2d']);
    // Core tools are always on, so task groups never need them.
    expect(groupsOf('get_scene_tree')).toEqual(['core']);
  });

  it('starts with core only when unset, everything for "all", and always keeps core', () => {
    expect([...enabledToolsets(undefined)!]).toEqual(['core']);
    expect(enabledToolsets('all')).toBeNull();
    expect([...enabledToolsets(' 2D, player_2d, nope ')!].sort()).toEqual(['2d', 'core', 'player_2d']);
  });
});
