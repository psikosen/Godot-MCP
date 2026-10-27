import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { fail, send, vector2 } from './workflow_tools.js';

const transactionId = z.string().optional()
  .describe('Add the node change to an open scene transaction instead of committing it now');

const status = (r: CommandResult) => (r.status ? ` [${r.status}]` : '');
const assigned = (r: CommandResult) => (r.node_path ? `, assigned to ${r.node_path}${status(r)}` : '');

const animation = z.object({
  name: z.string().min(1),
  frames: z.array(z.number().int().min(0)).max(256).optional()
    .describe('Frame numbers, counted left to right then top to bottom from 0'),
  row: z.number().int().min(0).optional()
    .describe('Use every frame of this row (instead of frames)'),
  fps: z.number().positive().optional().describe('Frames per second (default 10)'),
  loop: z.boolean().optional().describe('Default true'),
});

export const authoringTools: MCPTool[] = [
  {
    name: 'create_tileset_2d',
    description: 'Make a TileSet from a sprite sheet: one tile per grid cell (fully transparent cells skipped), saved as .tres. Optional full-tile collision and assignment to a TileMapLayer. Then paint with paint_tilemap_cells_2d or paint_tilemap_ascii (source_id 0).',
    parameters: z.object({
      texture_path: z.string().describe('Sprite sheet image, e.g. "res://art/tiles.png"'),
      tile_size: vector2.describe('Tile size in pixels, e.g. {"x": 16, "y": 16}'),
      save_path: z.string().describe('Where to save the TileSet, e.g. "res://tiles/world.tres"'),
      margins: vector2.optional().describe('Pixels to skip at the left and top edge of the sheet'),
      separation: vector2.optional().describe('Pixels between tiles'),
      skip_empty: z.boolean().optional().describe('Skip fully transparent cells (default true)'),
      collision: z.union([z.enum(['none', 'all']), z.array(vector2).max(4096)]).optional()
        .describe('Full-tile square collision: "none" (default), "all", or tile coordinates [[x, y], ...]'),
      node_path: z.string().optional().describe('TileMapLayer to give the TileSet to (undoable)'),
      overwrite: z.boolean().optional().describe('Replace save_path if it exists (default false)'),
      transaction_id: transactionId,
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_tileset_2d', args);
        const [columns, rows] = r.grid as number[];
        const skipped = r.skipped_empty ? `, ${r.skipped_empty} empty skipped` : '';
        const collision = r.collision_tiles ? `, collision on ${r.collision_tiles}` : '';
        return `Saved TileSet ${r.save_path}: ${r.tiles} tiles (${columns}x${rows} grid${skipped}${collision}), source_id ${r.source_id}${assigned(r)}`;
      } catch (error) {
        return fail('create TileSet', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_sprite_frames',
    description: 'Make SpriteFrames (named animations) for AnimatedSprite2D/3D from a grid sprite sheet. Save as .tres, give to a node, or both.',
    parameters: z.object({
      texture_path: z.string().describe('Sprite sheet image, e.g. "res://art/hero.png"'),
      frame_size: vector2.optional().describe('Frame size in pixels; or use hframes/vframes'),
      hframes: z.number().int().min(1).optional().describe('Frames across the sheet'),
      vframes: z.number().int().min(1).optional().describe('Frames down the sheet'),
      animations: z.array(animation).min(1).max(64)
        .describe('e.g. [{"name": "run", "row": 1, "fps": 12}, {"name": "jump", "frames": [8, 9], "loop": false}]'),
      save_path: z.string().optional().describe('Where to save the SpriteFrames (.tres)'),
      node_path: z.string().optional().describe('AnimatedSprite2D or AnimatedSprite3D to give the frames to (undoable)'),
      autoplay: z.string().optional().describe('Animation the node plays on start'),
      overwrite: z.boolean().optional().describe('Replace save_path if it exists (default false)'),
      transaction_id: transactionId,
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_sprite_frames', args);
        const animations = (r.animations as Array<{ name: string; frames: number; fps: number; loop: boolean }>)
          .map(a => `${a.name} (${a.frames} frames, ${a.fps} fps${a.loop ? ', loop' : ''})`);
        const where = r.save_path ? `Saved SpriteFrames ${r.save_path}` : 'Created SpriteFrames';
        return `${where}: ${animations.join(', ')}${assigned(r)}`;
      } catch (error) {
        return fail('create SpriteFrames', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'undo_redo',
    description: 'Undo or redo the last editor actions, the same as pressing Undo/Redo in the Godot editor (scene and project history). Says which actions it undid. Files saved by save_path or update_resource_properties stay as written.',
    parameters: z.object({
      action: z.enum(['undo', 'redo']).optional().describe('Default "undo"'),
      steps: z.number().int().min(1).max(20).optional().describe('How many actions (default 1)'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('undo_redo', args);
        const verb = r.action === 'redo' ? 'Redid' : 'Undid';
        const done = (r.actions as string[]).map(name => name || '(unnamed)');
        const head = done.length ? `${verb} ${done.length}: ${done.join(', ')}.` : `Nothing to ${r.action}.`;
        return `${head} Can undo: ${r.can_undo ? 'yes' : 'no'}, can redo: ${r.can_redo ? 'yes' : 'no'}.`;
      } catch (error) {
        return fail('undo/redo', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'get_resource_properties',
    description: 'Read the saved properties of a resource file (.tres/.res: custom Resources, materials, styleboxes, curves, TileSets, SpriteFrames). Sub-resources show as their file path or <Class>.',
    parameters: z.object({
      path: z.string().describe('Resource file, e.g. "res://data/sword.tres"'),
      properties: z.array(z.string()).max(200).optional().describe('Only these properties'),
      changed_only: z.boolean().optional().describe('Only properties that differ from the class or script default'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('get_resource_properties', args);
        const lines = Object.entries(r.properties as Record<string, unknown>)
          .map(([key, value]) => `${key}: ${JSON.stringify(value)}`);
        const missing = (r.missing as string[] | undefined) ?? [];
        if (missing.length > 0) lines.push(`missing: ${missing.join(', ')}`);
        const script = r.script ? ` (script ${r.script})` : '';
        return `${r.class} ${r.path}${script}:\n${lines.join('\n') || '(none differ from defaults)'}`;
      } catch (error) {
        return fail('read resource', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'update_resource_properties',
    description: 'Set properties on a resource file and save it. All values are checked first; one bad value changes nothing. Not for scenes or scripts. Not on the undo history.',
    parameters: z.object({
      path: z.string().describe('Resource file, e.g. "res://data/sword.tres"'),
      properties: z.record(z.unknown()).describe('e.g. {"damage": 12, "color": "#ff8800", "icon": "res://icons/sword.png"}'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('update_resource_properties', args);
        const changes = Object.entries(r.changed as Record<string, { from: unknown; to: unknown }>)
          .map(([key, change]) => `${key}: ${JSON.stringify(change.from)} -> ${JSON.stringify(change.to)}`);
        return `Saved ${r.path}:\n${changes.join('\n')}`;
      } catch (error) {
        return fail('update resource', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
];
