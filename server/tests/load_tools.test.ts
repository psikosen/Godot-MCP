import { spawn, type ChildProcess } from 'child_process';
import { fileURLToPath } from 'url';
import { afterEach, describe, expect, it } from 'vitest';
import { z } from 'zod';

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
  const callTool = (name: string, args: object) => rpc('tools/call', { name, arguments: args });
  return { listTools, loadTools, callTool, notifications };
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
    expect(unloaded.result.content[0].text).toMatch(/^Turned off player_2d \(14 tools; /);
    const left = (await server.listTools()).map(tool => tool.name);
    // set_collision_layers and fit_collision_shape are physics tools too, so they stay.
    expect(left).toEqual(expect.arrayContaining(['set_collision_layers', 'fit_collision_shape', 'create_ragdoll']));
    expect(left).not.toContain('configure_camera2d_follow');
    expect(left).not.toContain('add_input_action');
  });

  it('finds tools by what they do, and loads single tools by name', async () => {
    const server = await startServer();
    const found = (await server.loadTools({ find: 'ragdoll' })).result.content[0].text;
    expect(found).toMatch(/- create_ragdoll \[physics, rigging\]: Make a 3D character fall like a ragdoll/);
    // find only lists; nothing turns on.
    expect((await server.listTools()).map(tool => tool.name)).not.toContain('create_ragdoll');

    const loaded = (await server.loadTools({ tools: ['create_ragdoll'] })).result.content[0].text;
    expect(loaded).toMatch(/^Turned on create_ragdoll\.\nOn: core, create_ragdoll\./);
    const names = (await server.listTools()).map(tool => tool.name);
    expect(names).toContain('create_ragdoll');
    expect(names).not.toContain('configure_physics_body');
    expect(names).toHaveLength(26);

    await server.loadTools({ unload: ['create_ragdoll'] });
    expect((await server.listTools()).map(tool => tool.name)).not.toContain('create_ragdoll');
    expect((await server.loadTools({ tools: ['make_coffee'] })).result.content[0].text).toMatch(/^Unknown: make_coffee\./);
  });

  it('points at tools a result names that are not on yet', async () => {
    const { loadToolsTool } = await import('../dist/tools/toolset_tools.js');
    const fake = (name: string) => ({ name, description: '', parameters: null as any, execute: async () => '' });
    const enabled = new Set(['core']);
    const { tool, offToolsHint } = loadToolsTool([fake('create_tileset_2d'), fake('paint_tilemap_ascii'), fake('get_scene_tree')],
      enabled, async () => undefined, async () => undefined);
    const result = 'Saved TileSet. Then paint with paint_tilemap_ascii; check with get_scene_tree. my_var stays.';
    expect(offToolsHint(result)).toBe('\n(Not on yet: paint_tilemap_ascii [2d, tilemap_level]. Turn on with load_tools.)');
    await tool.execute({ groups: ['2d'] });
    expect(offToolsHint(result)).toBe('');
  });

  it('starts with the groups GODOT_MCP_TOOLSETS names, and rejects unknown groups', async () => {
    const server = await startServer('2d');
    expect((await server.listTools()).map(tool => tool.name)).toContain('create_tileset_2d');
    expect((await server.loadTools({})).result.content[0].text).toMatch(/^On: core, 2d\. Off: scene, /);
    // Bad arguments are a JSON-RPC error (invalid params), not a tool result.
    expect((await server.loadTools({ groups: ['procedural'] })).error.message).toMatch(/groups/);
  });
});

describe('listed schemas', () => {
  it('lists tuples as arrays Claude Code accepts, without $schema', async () => {
    const { withoutTuples } = await import('../dist/utils/listed_schema.js');
    expect(withoutTuples({ type: 'array', minItems: 2, maxItems: 2, items: [{ type: 'number' }, { type: 'number' }], additionalItems: false }))
      .toEqual({ type: 'array', minItems: 2, maxItems: 2, items: { type: 'number' } });
    expect(withoutTuples({ items: [{ type: 'string' }, { type: 'number' }] }))
      .toEqual({ items: { anyOf: [{ type: 'string' }, { type: 'number' }] }, minItems: 2, maxItems: 2 });
    const tools = await (await startServer('all')).listTools();
    const listed = JSON.stringify(tools);
    expect(listed).not.toMatch(/"items":\[/);
    expect(listed).not.toContain('$schema');
  });

  it('lists the parameters when a call has wrong or missing ones', async () => {
    const server = await startServer();
    const empty = await server.callTool('get_node_properties', {});
    expect(empty.error.message).toMatch(/node_path: (Required|Invalid input).*this tool takes node_path\* string/);
    const unknown = await server.callTool('load_tools', { group: 'water' });
    expect(unknown.error.message).toContain('this tool takes groups string[], tools string[], find string, unload string[]');
    const { parameterList, withShortNames } = await import('../dist/utils/listed_schema.js');
    expect(withShortNames({ path: 'res://a.gd', content: '' }, ['script_path', 'content'])).toEqual({ script_path: 'res://a.gd', content: '' });
    expect(withShortNames({ type: 'Node', name: 'A' }, ['node_type', 'node_name'])).toEqual({ node_type: 'Node', node_name: 'A' });
    expect(withShortNames({ property_name: 'x' }, ['property'])).toEqual({ property: 'x' });
    expect(withShortNames({ path: 'x' }, ['script_path', 'scene_path'])).toEqual({ path: 'x' }); // two fit: left alone
    expect(withShortNames({ path: 'x' }, ['script_path', 'node_path'], ['script_path'])).toEqual({ script_path: 'x' }); // the required one
    expect(withShortNames({ node_path: 'x' }, ['path'])).toEqual({ node_path: 'x' }); // longer names are not shortened
    const { listedSchema } = await import('../dist/utils/listed_schema.js');
    const schema = listedSchema(z.object({ script_path: z.string(), content: z.string(), node_path: z.string().optional() }).strict());
    expect(await schema['~standard'].validate({ path: 'res://a.gd', content: '' })).toEqual({ value: { script_path: 'res://a.gd', content: '' } });
    const vector = { anyOf: [{ type: 'object', properties: { x: {}, y: {} } }, { type: 'array', minItems: 2, maxItems: 2, items: { type: 'number' } }] };
    expect(parameterList({ required: ['size'], properties: { size: vector, points: { type: 'array', items: { $ref: '#/properties/size' } }, mode: { enum: ['a', 'b'] } } }))
      .toBe('size* {x,y}|number[2], points ({x,y}|number[2])[], mode a|b');
  });
});
