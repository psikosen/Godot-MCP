import { spawn, type ChildProcess } from 'child_process';
import { fileURLToPath } from 'url';
import { afterEach, describe, expect, it } from 'vitest';

const { groupsOf, toolsetOf, TASK_GROUPS, TOOLSETS } = await import('../dist/utils/toolsets.js');

const serverDir = fileURLToPath(new URL('..', import.meta.url));
const children: ChildProcess[] = [];

// The real server over stdio (no Godot needed to list or load tools).
async function startServer(toolsets?: string) {
  const env: NodeJS.ProcessEnv = { ...process.env, GODOT_WS_PORT: '1', GODOT_EXECUTABLE: '/nonexistent' };
  delete env.GODOT_MCP_TOOLSETS;
  if (toolsets !== undefined) env.GODOT_MCP_TOOLSETS = toolsets;
  const child = spawn('node', ['dist/index.js'], { cwd: serverDir, env, stdio: ['pipe', 'pipe', 'ignore'] });
  children.push(child);
  const pending = new Map<number, (message: any) => void>();
  const notifications: string[] = [];
  let buffer = '';
  child.stdout!.on('data', chunk => {
    buffer += chunk;
    const lines = buffer.split('\n');
    buffer = lines.pop()!;
    for (const line of lines) {
      const message = JSON.parse(line);
      if (message.id !== undefined) pending.get(message.id)?.(message);
      else notifications.push(message.method);
    }
  });
  let nextId = 0;
  const rpc = (method: string, params: object = {}) => new Promise<any>(resolve => {
    const id = ++nextId;
    pending.set(id, resolve);
    child.stdin!.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n');
  });
  await rpc('initialize', { protocolVersion: '2025-11-25', capabilities: {}, clientInfo: { name: 'test', version: '0' } });
  child.stdin!.write('{"jsonrpc":"2.0","method":"notifications/initialized"}\n');
  const listTools = async () => (await rpc('tools/list')).result.tools as Array<{ name: string }>;
  const loadTools = (args: object) => rpc('tools/call', { name: 'load_tools', arguments: args });
  return { listTools, loadTools, notifications };
}

afterEach(() => {
  children.splice(0).forEach(child => child.kill());
});

describe('load_tools', () => {
  it('starts with only the core tools, under 5k tokens', async () => {
    const tools = await (await startServer()).listTools();
    expect(tools.length).toBe(25);
    expect(tools.map(tool => tool.name)).toContain('load_tools');
    expect(tools.every(tool => toolsetOf(tool.name) === 'core')).toBe(true);
    // ponytail: 4 characters per token, close enough for a budget check.
    expect(JSON.stringify(tools).length / 4).toBeLessThan(5000);
  });

  it('puts every tool in a group, and every group has tools', async () => {
    const tools = await (await startServer('all')).listTools();
    const groups = new Map<string, string[]>();
    for (const tool of tools) {
      for (const group of groupsOf(tool.name)) groups.set(group, [...(groups.get(group) ?? []), tool.name]);
    }
    // A new tool that matches no rule lands in core: give it a group in utils/toolsets.ts.
    expect(groups.get('core')).toHaveLength(24);
    expect(TOOLSETS.filter((group: string) => !groups.has(group))).toEqual([]);
    // Task groups name real tools (a typo would silently drop one), and inspect stays read-only.
    const names = new Set(tools.map(tool => tool.name));
    for (const [group, members] of TASK_GROUPS) {
      if (members instanceof Set) expect([...members].filter(name => !names.has(name)), group).toEqual([]);
    }
    const inspect = tools.filter((tool: any) => groupsOf(tool.name).includes('inspect'));
    expect(inspect.filter((tool: any) => !tool.annotations.readOnlyHint).map(tool => tool.name)).toEqual([]);
    // No single group should cost as much as the old 17k-token procedural group.
    for (const [group, names] of groups) {
      const tokens = JSON.stringify(tools.filter(tool => names.includes(tool.name))).length / 4;
      expect(tokens, group).toBeLessThan(10000);
    }
  });

  it('turns groups on and off, and tells the client the list changed', async () => {
    const server = await startServer();
    const loaded = await server.loadTools({ groups: ['physics'] });
    expect(loaded.result.content[0].text).toMatch(/^Turned on physics: .*create_ragdoll/);
    expect(server.notifications).toContain('notifications/tools/list_changed');
    expect((await server.listTools()).map(tool => tool.name)).toContain('create_ragdoll');

    const unloaded = await server.loadTools({ unload: ['physics'] });
    expect(unloaded.result.content[0].text).toMatch(/^Turned off physics \(10 tools; .*\nOn: core\./);
    expect((await server.listTools()).map(tool => tool.name)).not.toContain('create_ragdoll');
  });

  it('keeps a tool on while another loaded group still has it', async () => {
    const server = await startServer();
    await server.loadTools({ groups: ['player_2d', 'physics'] });
    const loaded = (await server.listTools()).map(tool => tool.name);
    expect(loaded).toEqual(expect.arrayContaining(['configure_camera2d_follow', 'add_input_action', 'set_collision_layers', 'create_ragdoll']));

    const unloaded = await server.loadTools({ unload: ['player_2d'] });
    expect(unloaded.result.content[0].text).toMatch(/^Turned off player_2d \(13 tools; /);
    const left = (await server.listTools()).map(tool => tool.name);
    // set_collision_layers and fit_collision_shape are physics tools too, so they stay.
    expect(left).toEqual(expect.arrayContaining(['set_collision_layers', 'fit_collision_shape', 'create_ragdoll']));
    expect(left).not.toContain('configure_camera2d_follow');
    expect(left).not.toContain('add_input_action');
  });

  it('starts with the groups GODOT_MCP_TOOLSETS names, and rejects unknown groups', async () => {
    const server = await startServer('2d');
    expect((await server.listTools()).map(tool => tool.name)).toContain('create_tileset_2d');
    expect((await server.loadTools({})).result.content[0].text).toMatch(/^On: core, 2d\. Off: scene, /);
    // Bad arguments are a JSON-RPC error (invalid params), not a tool result.
    expect((await server.loadTools({ groups: ['procedural'] })).error.message).toMatch(/groups/);
  });
});
