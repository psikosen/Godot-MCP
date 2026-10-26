import { spawn } from 'node:child_process';
import { statSync } from 'node:fs';
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

const vector2 = z.union([
  z.object({ x: z.number(), y: z.number() }),
  z.tuple([z.number(), z.number()]),
]);

const send = (command: string, params: Record<string, unknown>) =>
  getGodotConnection().sendCommand<CommandResult>(command, params);

const fail = (what: string, error: unknown): never => {
  throw new Error(`Failed to ${what}: ${(error as Error).message}`);
};

// Runs Godot's command-line export in its own process: an export inside the editor would block
// every other MCP call until it finished.
function runExport(executable: string, args: string[], timeoutMs: number): Promise<{ code: number | null; output: string }> {
  return new Promise(resolve => {
    const child = spawn(executable, args, { stdio: ['ignore', 'pipe', 'pipe'] });
    let output = '';
    const collect = (chunk: Buffer) => { output = (output + chunk.toString()).slice(-20000); };
    child.stdout.on('data', collect);
    child.stderr.on('data', collect);
    const timer = setTimeout(() => { child.kill(); output += `\nStopped after ${timeoutMs / 1000}s.`; }, timeoutMs);
    child.on('error', error => { clearTimeout(timer); resolve({ code: -1, output: error.message }); });
    child.on('close', code => { clearTimeout(timer); resolve({ code, output }); });
  });
}

export const workflowTools: MCPTool[] = [
  {
    name: 'describe_class',
    description: 'Godot class reference: properties (type = default), methods, signals and enums for an engine class or a project class_name. Use filter to keep it short.',
    parameters: z.object({
      class_name: z.string().describe('e.g. "CharacterBody2D", "Tween", or a project class_name'),
      filter: z.string().optional().describe('Only members whose name contains this text'),
      sections: z.array(z.enum(['properties', 'methods', 'signals', 'constants'])).optional()
        .describe('Default: properties, methods, signals'),
      inherited: z.boolean().optional().describe('Include members from parent classes (default false)'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('describe_class', args);
        const parts = [`${r.class}${r.script ? ` (${r.script})` : ''} inherits ${(r.inherits as string[]).join(' < ') || 'nothing'}`];
        for (const section of ['properties', 'methods', 'signals', 'constants']) {
          const lines = r[section] as string[] | undefined;
          if (lines) parts.push(`${section} (${lines.length}):${lines.length ? `\n  ${lines.join('\n  ')}` : ' none'}`);
        }
        return parts.join('\n');
      } catch (error) {
        return fail('describe class', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'search_project',
    description: 'Search project text files (.gd, .tscn, .tres, .gdshader, ...) for text or a regex; returns file:line: text. Skips res://addons unless include_addons.',
    parameters: z.object({
      query: z.string().min(1).describe('Text to find (or a regular expression with regex: true)'),
      regex: z.boolean().optional(),
      case_sensitive: z.boolean().optional(),
      extensions: z.array(z.string()).optional().describe('e.g. [".gd"]'),
      include_addons: z.boolean().optional(),
      max_results: z.number().int().min(1).max(1000).optional().describe('Default 100'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('search_project', args);
        const matches = r.matches as string[];
        if (matches.length === 0) return `No matches in ${r.files_searched} file(s).`;
        return `${matches.join('\n')}${r.truncated ? '\n(more matches not shown; raise max_results or narrow the query)' : ''}`;
      } catch (error) {
        return fail('search project', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'replace_in_script',
    description: 'Replace an exact piece of text in a .gd or .gdshader file (much cheaper than rewriting the file with edit_script). Reports compile errors.',
    parameters: z.object({
      script_path: z.string().describe('res:// path'),
      old_text: z.string().min(1).describe('Exact text to replace, including indentation; must be unique unless replace_all'),
      new_text: z.string().describe('Replacement text'),
      replace_all: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('replace_in_script', args);
        return `Replaced ${r.replacements} occurrence(s) in ${r.script_path}`;
      } catch (error) {
        return fail('replace in script', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'list_signal_connections',
    description: 'List a node\'s signal connections in the open scene (outgoing and incoming) and its signal names.',
    parameters: z.object({
      node_path: z.string().describe('e.g. "/root/Player"'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('list_signal_connections', args);
        const out = r.outgoing as string[];
        const inc = r.incoming as string[];
        return [
          `${r.node_path}`,
          `outgoing: ${out.length ? `\n  ${out.join('\n  ')}` : 'none'}`,
          `incoming: ${inc.length ? `\n  ${inc.join('\n  ')}` : 'none'}`,
          `signals: ${(r.signals as string[]).join(', ')}`,
        ].join('\n');
      } catch (error) {
        return fail('list signal connections', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'disconnect_signal',
    description: 'Remove a signal connection (undo-aware).',
    parameters: z.object({
      source_path: z.string(),
      signal_name: z.string(),
      target_path: z.string(),
      method_name: z.string(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('disconnect_signal', args);
        return `Disconnected ${r.source_path}.${r.signal_name} -> ${r.target_path}.${r.method_name} [${r.status}]`;
      } catch (error) {
        return fail('disconnect signal', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'manage_autoloads',
    description: 'List, add or remove autoload singletons (global nodes such as a GameState script).',
    parameters: z.object({
      action: z.enum(['list', 'add', 'remove']),
      name: z.string().optional().describe('Autoload name (a valid identifier), for add/remove'),
      path: z.string().optional().describe('res:// .gd or .tscn file, for add'),
      overwrite: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('manage_autoloads', args);
        const list = (r.autoloads as Array<Record<string, unknown>>)
          .map(a => `${a.name} = ${a.path}${a.global ? '' : ' (not global)'}`);
        const verb = r.action === 'add' ? `Added ${args.name}. ` : r.action === 'remove' ? `Removed ${args.name}. ` : '';
        return `${verb}Autoloads:${list.length ? `\n  ${list.join('\n  ')}` : ' none'}`;
      } catch (error) {
        return fail('manage autoloads', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'configure_game_settings',
    description: 'Set common project settings: game name, main scene, window size, stretch, background color, texture filter, gravity, layer names. With no arguments, shows the current values.',
    parameters: z.object({
      game_name: z.string().optional(),
      main_scene: z.string().optional().describe('res:// scene the game starts with'),
      window_width: z.number().int().optional(),
      window_height: z.number().int().optional(),
      stretch_mode: z.enum(['disabled', 'canvas_items', 'viewport']).optional(),
      stretch_aspect: z.enum(['ignore', 'keep', 'keep_width', 'keep_height', 'expand']).optional(),
      clear_color: z.any().optional().describe('Background color, e.g. "#87ceeb"'),
      texture_filter: z.enum(['nearest', 'linear']).optional().describe('"nearest" for pixel art'),
      gravity_2d: z.number().optional(),
      gravity_3d: z.number().optional(),
      layer_names: z.record(z.record(z.string())).optional()
        .describe('e.g. {"2d_physics": {"1": "world", "2": "player"}}; kinds: 2d_physics, 3d_physics, 2d_render, 3d_render, 2d_navigation, 3d_navigation, avoidance'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('configure_game_settings', args);
        const changes = (r.changes as Array<Record<string, unknown>>).map(c => `${c.setting}: ${c.previous} -> ${c.value}`);
        const current = Object.entries(r.current as Record<string, unknown>).map(([k, v]) => `${k}=${JSON.stringify(v)}`).join(', ');
        return `${changes.length ? `Changed:\n  ${changes.join('\n  ')}\n` : ''}Current: ${current}`;
      } catch (error) {
        return fail('configure game settings', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'set_control_layout',
    description: 'Lay out a UI Control: anchor preset (full_rect, center, top_right, bottom_wide, ...), margin, size, position, minimum size, size flags. Undo-aware.',
    parameters: z.object({
      node_path: z.string(),
      preset: z.enum(['top_left', 'top_right', 'bottom_left', 'bottom_right', 'center_left', 'center_top', 'center_right',
        'center_bottom', 'center', 'left_wide', 'top_wide', 'right_wide', 'bottom_wide', 'vcenter_wide', 'hcenter_wide', 'full_rect']).optional(),
      margin: z.number().int().optional().describe('Gap from the anchored edges, in pixels'),
      size: vector2.optional(),
      position: vector2.optional(),
      min_size: vector2.optional(),
      size_flags_horizontal: z.enum(['fill', 'expand_fill', 'shrink_begin', 'shrink_center', 'shrink_end']).optional(),
      size_flags_vertical: z.enum(['fill', 'expand_fill', 'shrink_begin', 'shrink_center', 'shrink_end']).optional(),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('set_control_layout', args);
        if (r.status === 'no_change') return `${args.node_path} already has this layout.`;
        return `Laid out ${r.node_path} [${r.status}]: ${(r.changes as string[]).join('; ')}`;
      } catch (error) {
        return fail('set control layout', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'create_inherited_scene',
    description: 'Create a scene that inherits another (Godot\'s "New Inherited Scene"), e.g. enemy variants. Opens it unless open is false.',
    parameters: z.object({
      base_scene: z.string().describe('res:// scene to inherit from'),
      path: z.string().describe('res:// .tscn path for the new scene'),
      open: z.boolean().optional(),
      overwrite: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('create_inherited_scene', args);
        return `Created ${r.path} inheriting ${r.base_scene}${r.opened ? ' (now the open scene)' : ''}`;
      } catch (error) {
        return fail('create inherited scene', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'save_branch_as_scene',
    description: 'Save a node and its children as a new scene file (Godot\'s "Save Branch as Scene") and, unless replace is false, put an instance of it in their place.',
    parameters: z.object({
      node_path: z.string().describe('Root of the branch, e.g. "/root/Level/Enemy"'),
      path: z.string().describe('res:// .tscn path for the new scene'),
      replace: z.boolean().optional().describe('Replace the branch with an instance (default true)'),
      overwrite: z.boolean().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('save_branch_as_scene', args);
        return `Saved ${args.node_path} as ${r.path}${r.replaced ? `; ${r.node_path} is now an instance of it` : ''}`;
      } catch (error) {
        return fail('save branch as scene', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'capture_scene_image',
    description: 'Take a picture of the open scene (scripts do not run, so it shows the scene as built). 2D: centered on center at zoom; 3D: from camera_path or the first Camera3D. Needs the editor window (not --headless).',
    parameters: z.object({
      width: z.number().int().min(64).max(2048).optional().describe('Default 960'),
      height: z.number().int().min(64).max(2048).optional().describe('Default 540'),
      center: vector2.optional().describe('2D: world point at the middle of the picture'),
      zoom: z.number().min(0.05).max(20).optional().describe('2D: above 1 zooms in'),
      camera_path: z.string().optional().describe('A Camera2D or Camera3D in the scene to look through'),
      show_helpers: z.boolean().optional().describe('Also draw editor-only helpers: collision shapes, rays, markers'),
    }),
    execute: async (args: Record<string, unknown>) => {
      try {
        const r = await send('capture_scene_image', args);
        return {
          content: [
            { type: 'image' as const, data: r.image_base64 as string, mimeType: 'image/png' },
            { type: 'text' as const, text: `${r.width}x${r.height} picture of the open scene` },
          ],
        };
      } catch (error) {
        return fail('capture scene image', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'export_project',
    description: 'Export the game (macOS, Windows, Linux or Web) with Godot\'s export templates. Uses the named preset or creates one for the platform. Default output: res://builds/<platform>/.',
    parameters: z.object({
      platform: z.enum(['macos', 'windows', 'linux', 'web']).optional(),
      preset: z.string().optional().describe('Existing preset name from export_presets.cfg'),
      output_path: z.string().optional().describe('res:// or absolute file path'),
      debug: z.boolean().optional().describe('Debug build (default release)'),
      timeout_seconds: z.number().int().min(10).max(1800).optional().describe('Default 300'),
    }),
    execute: async (args: { platform?: string; preset?: string; output_path?: string; debug?: boolean; timeout_seconds?: number }): Promise<string> => {
      let plan: CommandResult;
      try {
        plan = await send('prepare_export', { platform: args.platform, preset: args.preset, output_path: args.output_path });
      } catch (error) {
        return fail('prepare export', error);
      }
      const { code, output } = await runExport(plan.executable as string, [
        '--headless', '--path', plan.project_dir as string,
        args.debug ? '--export-debug' : '--export-release', plan.preset as string, plan.output_path as string,
      ], (args.timeout_seconds ?? 300) * 1000);
      let size = 0;
      try { size = statSync(plan.output_path as string).size; } catch { /* not written */ }
      if (code !== 0 || size === 0) {
        // The addon logs JSON lines ("error":false) on startup; keep Godot's own messages.
        const errors = output.split('\n')
          .filter(line => !line.startsWith('{') && !line.trim().startsWith('at:') && /error|cannot|failed|missing|invalid/i.test(line))
          .slice(-8).join('\n');
        throw new Error(`Export "${plan.preset}" failed (exit ${code}).\n${errors || output.slice(-1500)}`);
      }
      const notes = (plan.notes as string[] | undefined) ?? [];
      return `Exported "${plan.preset}" (${plan.platform}) to ${plan.output_path} (${(size / 1048576).toFixed(1)} MB)${notes.length ? `\nNote: ${notes.join('; ')}` : ''}`;
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to export the project, which runs Godot in a separate process and writes the build files.',
    },
  },
];
