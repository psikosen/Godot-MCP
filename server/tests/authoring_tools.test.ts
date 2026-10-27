import { beforeEach, describe, expect, it, vi } from 'vitest';

const mockSendCommand = vi.hoisted(() => vi.fn<(command: string, payload?: unknown) => Promise<any>>());

vi.mock('../dist/utils/godot_connection.js', () => ({
  getGodotConnection: () => ({ sendCommand: mockSendCommand }),
}));

const { authoringTools } = await import('../dist/tools/authoring_tools.js');
const { toolsetOf } = await import('../dist/utils/toolsets.js');

const tool = (name: string) => authoringTools.find(t => t.name === name)!;
// What FastMCP does before execute: validate against the schema (top level strict, see index.ts).
const run = (name: string, args: unknown) => tool(name).execute((tool(name).parameters as any).strict().parse(args));

beforeEach(() => {
  mockSendCommand.mockReset();
});

describe('authoring tools', () => {
  it('create_tileset_2d sends the sheet settings and reports the tiles', async () => {
    mockSendCommand.mockResolvedValueOnce({
      save_path: 'res://t.tres', source_id: 0, grid: [4, 2], tiles: 7, skipped_empty: 1, collision_tiles: 7,
      node_path: '/root/Tiles', status: 'committed',
    });
    const out = await run('create_tileset_2d', {
      texture_path: 'res://sheet.png', tile_size: { x: 16, y: 16 }, save_path: 'res://t.tres', collision: 'all', node_path: '/root/Tiles',
    });
    expect(mockSendCommand).toHaveBeenCalledWith('create_tileset_2d', expect.objectContaining({ collision: 'all', tile_size: { x: 16, y: 16 } }));
    expect(out).toBe('Saved TileSet res://t.tres: 7 tiles (4x2 grid, 1 empty skipped, collision on 7), source_id 0, assigned to /root/Tiles [committed]');
  });

  it('create_tileset_2d rejects an unknown collision mode before calling Godot', () => {
    expect(() => run('create_tileset_2d', { texture_path: 'a', tile_size: [16, 16], save_path: 'b', collision: 'some' })).toThrow();
  });

  it('create_sprite_frames lists the animations it made', async () => {
    mockSendCommand.mockResolvedValueOnce({
      save_path: '', grid: [4, 2], frame_size: [16, 16], node_path: '/root/Hero', status: 'committed',
      animations: [{ name: 'walk', frames: 4, fps: 8, loop: true }, { name: 'idle', frames: 2, fps: 10, loop: false }],
    });
    const out = await run('create_sprite_frames', {
      texture_path: 'res://hero.png', hframes: 4, vframes: 2, node_path: '/root/Hero',
      animations: [{ name: 'walk', row: 0, fps: 8 }, { name: 'idle', frames: [4, 5], loop: false }],
    });
    expect(out).toBe('Created SpriteFrames: walk (4 frames, 8 fps, loop), idle (2 frames, 10 fps), assigned to /root/Hero [committed]');
  });

  it('create_sprite_frames needs at least one animation', () => {
    expect(() => run('create_sprite_frames', { texture_path: 'a', hframes: 2, animations: [] })).toThrow();
  });

  it('undo_redo reports what it undid, and says so when there was nothing', async () => {
    mockSendCommand.mockResolvedValueOnce({ action: 'undo', done: 2, actions: ['Paint', 'Assign TileSet'], can_undo: true, can_redo: true });
    expect(await run('undo_redo', { steps: 2 })).toBe('Undid 2: Paint, Assign TileSet. Can undo: yes, can redo: yes.');
    expect(mockSendCommand).toHaveBeenLastCalledWith('undo_redo', { steps: 2 });

    mockSendCommand.mockResolvedValueOnce({ action: 'redo', done: 0, actions: [], can_undo: true, can_redo: false });
    expect(await run('undo_redo', { action: 'redo' })).toBe('Nothing to redo. Can undo: yes, can redo: no.');
  });

  it('undo_redo caps steps at 20', () => {
    expect(() => run('undo_redo', { steps: 21 })).toThrow();
  });

  it('get_resource_properties prints one line per property and the missing ones', async () => {
    mockSendCommand.mockResolvedValueOnce({
      path: 'res://box.tres', class: 'StyleBoxFlat', script: '', properties: { corner_radius_top_left: 6 }, missing: ['nope'],
    });
    expect(await run('get_resource_properties', { path: 'res://box.tres', properties: ['corner_radius_top_left', 'nope'] }))
      .toBe('StyleBoxFlat res://box.tres:\ncorner_radius_top_left: 6\nmissing: nope');
  });

  it('update_resource_properties shows each change and surfaces Godot errors', async () => {
    mockSendCommand.mockResolvedValueOnce({ path: 'res://box.tres', changed: { corner_radius_top_left: { from: 0, to: 6 } } });
    expect(await run('update_resource_properties', { path: 'res://box.tres', properties: { corner_radius_top_left: 6 } }))
      .toBe('Saved res://box.tres:\ncorner_radius_top_left: 0 -> 6');

    mockSendCommand.mockRejectedValueOnce(new Error('No changes made: Property bg_color expects Color, got 42.0'));
    await expect(run('update_resource_properties', { path: 'res://box.tres', properties: { bg_color: 42 } }))
      .rejects.toThrow('Failed to update resource: No changes made');
  });

  it('read-only role only for the read tool', () => {
    const roles = Object.fromEntries(authoringTools.map(t => [t.name, t.metadata?.requiredRole]));
    expect(roles).toEqual({
      create_tileset_2d: 'edit', create_sprite_frames: 'edit', undo_redo: 'edit',
      get_resource_properties: 'read', update_resource_properties: 'edit',
    });
  });

  it('lands in the expected tool groups', () => {
    expect(toolsetOf('create_tileset_2d')).toBe('2d');
    expect(toolsetOf('create_sprite_frames')).toBe('animation');
    expect(toolsetOf('undo_redo')).toBe('core');
    expect(toolsetOf('get_resource_properties')).toBe('scene');
  });
});
