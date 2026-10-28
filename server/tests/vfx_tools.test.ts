import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockSendCommand = vi.hoisted(() => vi.fn<(command: string, payload?: unknown) => Promise<any>>());

vi.mock('../dist/utils/godot_connection.js', () => ({
  getGodotConnection: () => ({ sendCommand: mockSendCommand }),
}));

const { vfxTools } = await import('../dist/tools/vfx_tools.js');
const { nodeTools } = await import('../dist/tools/node_tools.js');
const { workflowTools } = await import('../dist/tools/workflow_tools.js');
const { groupsOf } = await import('../dist/utils/toolsets.js');

const tool = (name: string) => [...vfxTools, ...nodeTools, ...workflowTools].find(t => t.name === name)!;
// What FastMCP does before execute: validate against the schema (top level strict, see index.ts).
const parse = (name: string, args: unknown) => (tool(name).parameters as any).strict().parse(args);
const run = (name: string, args: unknown) => tool(name).execute(parse(name, args));

beforeEach(() => {
  mockSendCommand.mockReset();
});

describe('build_vfx_effect', () => {
  it('sends the preset and reports layers, sub-emitters and notes', async () => {
    mockSendCommand.mockResolvedValueOnce({
      node_path: '/root/Explosion', preset: 'explosion', dimension: '3d', status: 'committed',
      layers: ['Smoke', 'Flash', 'Fireball', 'Sparks', 'Shockwave'], sub_emitters: ['Sparks -> SparkTrails (constant)'],
      light: true, camera_shake: true, loop: false, notes: [],
    });
    const out = await run('build_vfx_effect', { preset: 'explosion', position: { x: 1, y: 0, z: 2 }, color: '#40a0ff', scale: 2 });
    expect(mockSendCommand).toHaveBeenCalledWith('build_vfx_effect', expect.objectContaining({ preset: 'explosion', scale: 2, color: '#40a0ff' }));
    expect(out).toBe('explosion (3d) at /root/Explosion [committed]: Smoke, Flash, Fireball, Sparks, Shockwave; '
      + 'sub-emitters Sparks -> SparkTrails (constant); light pop, camera shake. Plays when the game runs; call play() on it to fire again. '
      + 'Tune a layer with configure_particles_3d (3D).');
  });

  it('passes notes through and takes 2D vectors', async () => {
    mockSendCommand.mockResolvedValueOnce({
      node_path: '/root/Fire', preset: 'fire', dimension: '2d', status: 'committed', layers: ['Smoke', 'Glow'],
      sub_emitters: [], light: false, camera_shake: false, loop: true, notes: ['The Compatibility renderer draws no sub-emitters'],
    });
    const out = await run('build_vfx_effect', { preset: 'fire', dimension: '2d', direction: [1, 0], light: false });
    expect(out).toContain('; looping.');
    expect(out).toContain('\nNote: The Compatibility renderer draws no sub-emitters');
  });

  it('refuses unknown presets before Godot sees them', () => {
    expect(() => parse('build_vfx_effect', { preset: 'nuke' })).toThrow();
    expect(() => parse('build_vfx_effect', { preset: 'fire', dimension: '4d' })).toThrow();
  });

  it('loads with the effects and vfx groups, not at start', () => {
    expect(groupsOf('build_vfx_effect')).toEqual(['effects', 'vfx']);
  });
});

describe('build_pixel_vfx', () => {
  it('sends the preset and element and says where the colours are', async () => {
    mockSendCommand.mockResolvedValueOnce({
      node_path: '/root/PixelTornado', preset: 'tornado', element: 'fire', status: 'committed', canvas: [64, 96], pixel_scale: 4,
      size: [256, 384], fps: 12, frames: 16, loop: true, light: false, camera_shake: false, ramps: ['main', 'debris', 'dust'],
    });
    const out = await run('build_pixel_vfx', { preset: 'tornado', element: 'fire', position: [320, 400] });
    expect(mockSendCommand).toHaveBeenCalledWith('build_pixel_vfx', { preset: 'tornado', element: 'fire', position: [320, 400] });
    expect(out).toBe('fire tornado at /root/PixelTornado [committed]: 64x96 art pixels at 4x, 16 frames at 12 fps; looping.'
      + ' Plays when the game runs; play() fires it again. Colours: FX material main_ramp, FX material debris_ramp, FX material dust_ramp.'
      + ' See it move: capture_scene_image with filmstrip.');
  });

  it('refuses unknown presets, elements and scales', () => {
    expect(() => parse('build_pixel_vfx', { preset: 'meteor' })).toThrow();
    expect(() => parse('build_pixel_vfx', { preset: 'heal', element: 'cheese' })).toThrow();
    expect(() => parse('build_pixel_vfx', { preset: 'heal', pixel_scale: 0 })).toThrow();
  });

  it('loads with the effects and vfx groups', () => {
    expect(groupsOf('build_pixel_vfx')).toEqual(['effects', 'vfx']);
  });
});

describe('configure_particles_3d VFX options', () => {
  it('accepts curves, sub-emitter, collision, flipbook and draw options', async () => {
    mockSendCommand.mockResolvedValueOnce({ status: 'committed', amount: 64, lifetime: 1, emitting: true, notes: ['at_collision needs a collider'] });
    const args = {
      node_path: '/root/FX', scale_curve: [[0, 0.2], [0.3, 1], [1, 1.5]], alpha_curve: [1, 0], color_ramp: ['#ffffff', '#ff800000'],
      turbulence_strength: 2, sub_emitter_path: '/root/Sub', sub_emitter_mode: 'at_collision', sub_emitter_amount: 3,
      collision_mode: 'rigid', texture_path: 'res://fx/smoke_sheet.png', flipbook_h_frames: 4, flipbook_v_frames: 4,
      particle_size: { x: 0.05, y: 0.5 }, blend_mode: 'add', align_to_velocity: true,
    };
    const out = await run('configure_particles_3d', args);
    expect(mockSendCommand).toHaveBeenCalledWith('configure_particles_3d', args);
    expect(out).toBe('Configured GPUParticles3D /root/FX amount=64 lifetime=1.00 emitting=true [committed]\nNote: at_collision needs a collider');
  });

  it('refuses malformed curves and unknown modes', () => {
    expect(() => parse('configure_particles_3d', { node_path: '/root/FX', scale_curve: [[0, 1, 2]] })).toThrow();
    expect(() => parse('configure_particles_3d', { node_path: '/root/FX', alpha_curve: [-1, 0] })).toThrow();
    expect(() => parse('configure_particles_3d', { node_path: '/root/FX', sub_emitter_mode: 'on_death' })).toThrow();
    expect(() => parse('configure_particles_3d', { node_path: '/root/FX', mesh_shape: 'torus' })).toThrow();
  });
});

describe('capture_scene_image', () => {
  it('takes particles_time to show a burst mid-effect', () => {
    expect(parse('capture_scene_image', { particles_time: 0.3 })).toEqual({ particles_time: 0.3 });
    expect(() => parse('capture_scene_image', { particles_time: 11 })).toThrow();
  });

  it('takes a filmstrip of 2 to 8 moments', () => {
    expect(parse('capture_scene_image', { filmstrip: [0.05, 0.2, 0.5] })).toEqual({ filmstrip: [0.05, 0.2, 0.5] });
    expect(() => parse('capture_scene_image', { filmstrip: [0.1] })).toThrow();
    expect(() => parse('capture_scene_image', { filmstrip: [0, 1, 2, 3, 4, 5, 6, 7, 8] })).toThrow();
  });
});
