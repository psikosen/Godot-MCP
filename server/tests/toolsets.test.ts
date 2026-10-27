import { describe, expect, it } from 'vitest';
import { enabledToolsets, toolsetOf } from '../src/utils/toolsets.js';

describe('toolsets', () => {
  it('sorts tools into groups and keeps unmatched tools in core', () => {
    expect(toolsetOf('create_node')).toBe('core');
    expect(toolsetOf('get_scene_tree')).toBe('core');
    expect(toolsetOf('configure_camera2d_follow')).toBe('2d');
    expect(toolsetOf('configure_camera3d_rig')).toBe('3d');
    expect(toolsetOf('generate_procedural_planet')).toBe('procedural');
    expect(toolsetOf('build_water_body_2d')).toBe('procedural');
    expect(toolsetOf('edit_animation')).toBe('animation');
    expect(toolsetOf('configure_navigation_agent_2d')).toBe('navigation');
    expect(toolsetOf('initialize_xr_interface')).toBe('xr');
    expect(toolsetOf('build_light_occluder_2d')).toBe('2d');
    expect(toolsetOf('build_subviewport_minimap')).toBe('ui');
  });

  it('treats unset or "all" as everything and always keeps core', () => {
    expect(enabledToolsets(undefined)).toBeNull();
    expect(enabledToolsets('all')).toBeNull();
    expect([...enabledToolsets(' 2D, animation ')!].sort()).toEqual(['2d', 'animation', 'core']);
  });
});
