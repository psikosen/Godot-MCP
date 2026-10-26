import { spawn } from 'node:child_process';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';
import { getGodotConnection } from '../utils/godot_connection.js';
import { MCPTool, CommandResult } from '../utils/types.js';

export const vector2 = z.union([
  z.object({ x: z.number(), y: z.number() }),
  z.tuple([z.number(), z.number()]),
]);

export const send = (command: string, params: Record<string, unknown>) =>
  getGodotConnection().sendCommand<CommandResult>(command, params);

export const fail = (what: string, error: unknown): never => {
  throw new Error(`Failed to ${what}: ${(error as Error).message}`);
};

// Runs Godot in its own process (export, tests, game frames): doing it inside the editor would
// block every other MCP call until it finished.
// code is a string when the run did not exit by itself ("timed out after 30s"); Godot keeps
// running after a script error, so a crashed test only ends at the timeout.
export function runGodot(executable: string, args: string[], timeoutMs: number): Promise<{ code: number | string | null; output: string }> {
  return new Promise(resolve => {
    const child = spawn(executable, args, { stdio: ['ignore', 'pipe', 'pipe'] });
    let output = '';
    let timedOut = false;
    const collect = (chunk: Buffer) => { output = (output + chunk.toString()).slice(-20000); };
    child.stdout.on('data', collect);
    child.stderr.on('data', collect);
    const timer = setTimeout(() => { timedOut = true; child.kill(); }, timeoutMs);
    child.on('error', error => { clearTimeout(timer); resolve({ code: -1, output: error.message }); });
    child.on('close', code => { clearTimeout(timer); resolve({ code: timedOut ? `timed out after ${timeoutMs / 1000}s` : code, output }); });
  });
}

export const godotProblems = (output: string, limit = 12) => output.split('\n')
  .filter(line => !line.startsWith('{') && /SCRIPT ERROR|^ERROR:|Parse Error|^FAIL|not ok/.test(line))
  .slice(0, limit);

// Repository root (dist/tools -> ../..), where the addon to install into new projects lives.
const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..', '..');

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
      const { code, output } = await runGodot(plan.executable as string, [
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
  {
    name: 'get_script_outline',
    description: 'Outline a .gd script with line numbers: extends, signals, exports, vars, consts, enums, funcs, inner classes. Read this before get_script on long files.',
    parameters: z.object({
      script_path: z.string().describe('res:// path of a .gd file'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('get_script_outline', args);
        return `${r.script_path} (${r.line_count} lines)\n${(r.outline as string[]).join('\n')}`;
      } catch (error) {
        return fail('outline script', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'move_project_file',
    description: 'Move or rename one project file (with its .import/.uid) and rewrite references to it in scenes, resources, scripts and project.godot.',
    parameters: z.object({
      from_path: z.string().describe('res:// path now'),
      to_path: z.string().describe('res:// path after the move (same extension)'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('move_project_file', args);
        const refs = r.updated_references as string[];
        return `Moved ${r.from_path} to ${r.to_path}. ${refs.length ? `Updated references in: ${refs.join(', ')}` : 'No files referred to it by path.'}`;
      } catch (error) {
        return fail('move project file', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'configure_particles_2d',
    description: 'Create a CPUParticles2D (pass parent_path) or configure an existing CPU/GPUParticles2D (node_path) from a preset (dust, sparkle, rain, snow, confetti, burst) plus overrides. One undo step.',
    parameters: z.object({
      node_path: z.string().optional().describe('Existing particles node to configure'),
      parent_path: z.string().optional().describe('Create a new CPUParticles2D under this node'),
      node_name: z.string().optional(),
      preset: z.enum(['dust', 'sparkle', 'rain', 'snow', 'confetti', 'burst']).optional(),
      position: vector2.optional(),
      amount: z.number().int().min(1).max(10000).optional(),
      lifetime: z.number().min(0.01).max(600).optional(),
      one_shot: z.boolean().optional(),
      explosiveness: z.number().min(0).max(1).optional(),
      emitting: z.boolean().optional(),
      local_coords: z.boolean().optional(),
      direction: vector2.optional(),
      spread: z.number().min(0).max(180).optional(),
      gravity: vector2.optional(),
      velocity_min: z.number().optional(),
      velocity_max: z.number().optional(),
      scale_min: z.number().min(0).optional(),
      scale_max: z.number().min(0).optional(),
      color: z.any().optional().describe('Start color, e.g. "#ffd27f"'),
      color_end: z.any().optional().describe('Color at the end of each particle\'s life (fade with alpha 0)'),
      hue_variation: z.number().min(0).max(1).optional(),
      emission_shape: z.enum(['point', 'sphere', 'rectangle']).optional(),
      emission_radius: z.number().min(0).optional(),
      emission_rect_extents: vector2.optional(),
      texture: z.string().optional().describe('res:// image for each particle (default: a square)'),
      transaction_id: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('configure_particles_2d', args);
        return `${r.created ? 'Created' : 'Configured'} ${r.type} ${r.node_path}${r.preset ? ` (${r.preset})` : ''} [${r.status}]: ${(r.changed as string[]).join(', ')}`;
      } catch (error) {
        return fail('configure particles', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'manage_translations',
    description: 'Game text in several languages: set_entries writes keys to a translation CSV (keys x locales) and registers the imported files; set_fallback sets the fallback locale; list shows locales and keys. Use tr("KEY") in scripts or the key as Label text.',
    parameters: z.object({
      action: z.enum(['list', 'set_entries', 'set_fallback']),
      csv_path: z.string().optional().describe('Default res://translations/strings.csv'),
      entries: z.record(z.record(z.string())).optional().describe('{"MENU_START": {"en": "Start", "es": "Empezar"}}'),
      locale: z.string().optional().describe('For set_fallback, e.g. "en"'),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('manage_translations', args);
        const keys = r.keys as string[];
        return `${r.csv_path}: locales ${(r.locales as string[]).join(', ') || 'none'}; ${r.key_count} key(s)${keys.length ? ` (${keys.join(', ')}${Number(r.key_count) > keys.length ? ', ...' : ''})` : ''}; registered ${(r.registered as string[]).length} translation file(s); fallback ${r.fallback}`;
      } catch (error) {
        return fail('manage translations', error);
      }
    },
    metadata: { requiredRole: 'edit' },
  },
  {
    name: 'select_in_editor',
    description: 'Select a node in the Godot editor and show it in the Inspector, so the person at the editor sees what you mean. With no node_path, returns the current selection.',
    parameters: z.object({
      node_path: z.string().optional(),
    }),
    execute: async (args: Record<string, unknown>): Promise<string> => {
      try {
        const r = await send('select_in_editor', args);
        const selected = r.selected as string[];
        return selected.length ? `Selected: ${selected.join(', ')}` : 'Nothing is selected.';
      } catch (error) {
        return fail('select in editor', error);
      }
    },
    metadata: { requiredRole: 'read' },
  },
  {
    name: 'run_game_tests',
    description: 'Run GDScript test scripts (scripts that extend SceneTree, e.g. res://tests/*.gd) headless, one Godot process each, and report pass/fail. PASS/FAIL or ok/not ok lines are counted; SCRIPT ERRORs and a non-zero exit fail the script.',
    parameters: z.object({
      tests: z.array(z.string()).optional().describe('res:// test scripts; default: every SceneTree script in tests_dir'),
      tests_dir: z.string().optional().describe('Default res://tests'),
      timeout_seconds: z.number().int().min(5).max(1800).optional().describe('Per script, default 120'),
    }),
    execute: async (args: { tests?: string[]; tests_dir?: string; timeout_seconds?: number }): Promise<string> => {
      let paths: CommandResult;
      try {
        paths = await send('get_runtime_paths', args.tests ? {} : { tests_dir: args.tests_dir ?? 'res://tests' });
      } catch (error) {
        return fail('find tests', error);
      }
      const tests = args.tests ?? (paths.tests as string[]);
      if (tests.length === 0) return `No test scripts (extends SceneTree) found in ${args.tests_dir ?? 'res://tests'}.`;
      const lines: string[] = [];
      let failed = 0;
      for (const test of tests) {
        const started = Date.now();
        const { code, output } = await runGodot(paths.executable as string,
          ['--headless', '--path', paths.project_dir as string, '--fixed-fps', '60', '--script', test],
          (args.timeout_seconds ?? 120) * 1000);
        const passes = output.split('\n').filter(line => /^(PASS|ok)\b/.test(line)).length;
        const problems = godotProblems(output);
        const ok = code === 0 && !problems.some(line => /SCRIPT ERROR|^FAIL|not ok|Parse Error/.test(line));
        if (!ok) failed += 1;
        lines.push(`${ok ? 'PASS' : 'FAIL'} ${test}: ${passes} passed, ${problems.length} problem(s), ${typeof code === 'string' ? code : `exit ${code}`}, ${((Date.now() - started) / 1000).toFixed(1)}s`);
        lines.push(...problems.map(line => `  ${line.trim().slice(0, 200)}`));
      }
      return `${tests.length - failed}/${tests.length} test script(s) passed\n${lines.join('\n')}`;
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to run the project\'s test scripts in a separate headless Godot process.',
    },
  },
  {
    name: 'capture_game_frame',
    description: 'Run a scene for some frames in a real game window (scripts run, so HUDs and movement are live), optionally holding input actions, and return the last frame as a picture. Briefly opens a window.',
    parameters: z.object({
      scene: z.string().optional().describe('res:// scene; default the main scene'),
      frames: z.number().int().min(1).max(3600).optional().describe('Frames to run at 60 fps before the picture (default 60)'),
      hold: z.array(z.object({
        action: z.string().describe('Input action, e.g. "move_right"'),
        from_frame: z.number().int().min(0),
        to_frame: z.number().int().min(0),
      })).max(20).optional().describe('Input to hold while it runs'),
      width: z.number().int().min(64).max(3840).optional(),
      height: z.number().int().min(64).max(2160).optional(),
      timeout_seconds: z.number().int().min(5).max(600).optional().describe('Default 60'),
    }),
    execute: async (args: { scene?: string; frames?: number; hold?: Array<{ action: string; from_frame: number; to_frame: number }>; width?: number; height?: number; timeout_seconds?: number }) => {
      let paths: CommandResult;
      try {
        paths = await send('get_runtime_paths', {});
      } catch (error) {
        return fail('find the game', error);
      }
      const scene = args.scene ?? (paths.main_scene as string);
      if (!scene) throw new Error('No scene given and the project has no main scene');
      const [defaultWidth, defaultHeight] = paths.window as [number, number];
      const png = path.join(tmpdir(), `godot-mcp-frame-${process.pid}-${Date.now()}.png`);
      const holds = (args.hold ?? []).map(h => `${h.action}:${h.from_frame}:${h.to_frame}`);
      const { code, output } = await runGodot(paths.executable as string, [
        '--path', paths.project_dir as string, '--fixed-fps', '60', '--resolution', `${args.width ?? defaultWidth}x${args.height ?? defaultHeight}`,
        '--script', 'res://addons/godot_mcp/runtime/run_scene.gd', '--', scene, String(args.frames ?? 60), png, ...holds,
      ], (args.timeout_seconds ?? 60) * 1000);
      if (!existsSync(png)) {
        throw new Error(`The game did not produce a frame (exit ${code}).\n${godotProblems(output).join('\n') || output.slice(-1200)}`);
      }
      const data = readFileSync(png).toString('base64');
      rmSync(png, { force: true });
      const problems = godotProblems(output);
      return {
        content: [
          { type: 'image' as const, data, mimeType: 'image/png' },
          { type: 'text' as const, text: `${scene} after ${args.frames ?? 60} frame(s)${problems.length ? `\nErrors while running:\n${problems.join('\n')}` : ''}` },
        ],
      };
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to run the game in a window to take a picture of it.',
    },
  },
  {
    name: 'create_project',
    description: 'Create a new Godot project folder with a main scene and the Godot MCP addon installed and enabled, ready to open in the editor.',
    parameters: z.object({
      path: z.string().describe('Absolute folder for the new project (must not exist or be empty)'),
      name: z.string().min(1).describe('Game name'),
      dimension: z.enum(['2d', '3d']).optional().describe('Main scene root: Node2D or Node3D (default 2d)'),
      renderer: z.enum(['gl_compatibility', 'mobile', 'forward_plus']).optional().describe('Default gl_compatibility (runs everywhere)'),
      window_width: z.number().int().min(64).max(7680).optional(),
      window_height: z.number().int().min(64).max(4320).optional(),
      install_mcp: z.boolean().optional().describe('Copy and enable the Godot MCP addon (default true)'),
    }),
    execute: async (args: { path: string; name: string; dimension?: string; renderer?: string; window_width?: number; window_height?: number; install_mcp?: boolean }): Promise<string> => {
      const target = path.resolve(args.path);
      if (!path.isAbsolute(args.path)) throw new Error('path must be absolute');
      if (existsSync(target) && readdirSync(target).length > 0) throw new Error(`${target} already exists and is not empty`);
      let version = '4.4';
      try { version = (await send('get_runtime_paths', {})).godot_version as string; } catch { /* no editor connected */ }
      const renderer = args.renderer ?? 'gl_compatibility';
      const feature = { gl_compatibility: 'GL Compatibility', mobile: 'Mobile', forward_plus: 'Forward Plus' }[renderer];
      const install = args.install_mcp ?? true;
      const is3d = args.dimension === '3d';
      const quoted = JSON.stringify(args.name);
      const projectFile = [
        '; Engine configuration file.', '', 'config_version=5', '', '[application]', '',
        `config/name=${quoted}`, 'run/main_scene="res://main.tscn"', `config/features=PackedStringArray("${version}", "${feature}")`, '',
        ...(install ? ['[autoload]', '', 'MCPAutoload="*res://autoload_mcp_server.gd"', ''] : []),
        '[display]', '', `window/size/viewport_width=${args.window_width ?? 1280}`, `window/size/viewport_height=${args.window_height ?? 720}`,
        ...(is3d ? [] : ['window/stretch/mode="canvas_items"']), '',
        ...(install ? ['[editor_plugins]', '', 'enabled=PackedStringArray("res://addons/godot_mcp/plugin.cfg")', ''] : []),
        '[rendering]', '', `renderer/rendering_method="${renderer}"`,
        ...(renderer === 'gl_compatibility' ? ['renderer/rendering_method.mobile="gl_compatibility"'] : []), '',
      ].join('\n');
      mkdirSync(target, { recursive: true });
      writeFileSync(path.join(target, 'project.godot'), projectFile);
      writeFileSync(path.join(target, 'main.tscn'), `[gd_scene format=3]\n\n[node name="Main" type="${is3d ? 'Node3D' : 'Node2D'}"]\n`);
      writeFileSync(path.join(target, '.gitignore'), '.godot/\n');
      if (install) {
        cpSync(path.join(REPO_ROOT, 'addons', 'godot_mcp'), path.join(target, 'addons', 'godot_mcp'), {
          recursive: true,
          filter: source => !/_test\.gd|command_handler_minimal/.test(source),
        });
        cpSync(path.join(REPO_ROOT, 'autoload_mcp_server.gd'), path.join(target, 'autoload_mcp_server.gd'));
      }
      return `Created ${args.name} at ${target} (${is3d ? '3D' : '2D'}, ${feature}${install ? ', Godot MCP addon enabled' : ''}). Open it in Godot: godot --path "${target}" --editor`;
    },
    metadata: {
      requiredRole: 'admin',
      escalationPrompt: 'Request approval to create a new Godot project folder outside the current project.',
    },
  },
];
