// Agent eval: a real Claude (the `claude` CLI) does plain-language Godot tasks through this MCP server
// and a headless Godot editor. It records which tool groups the AI loads, errors, turns, peak context
// and cost, then checks the scene. Compare modes: "default" starts with core tools only, "all" with
// every tool. Costs real API money (about $0.05-0.50 per run on Sonnet).
//
// Usage: npm run build && node eval/agent_eval.mjs [--model sonnet] [--lanes 3] [--out eval/out] [task:mode ...]
//   No runs given: every task in eval/tasks.mjs in default mode.
// Needs: the `claude` CLI, and Godot (GODOT_EXECUTABLE, default the macOS app path).
import { spawn, execFileSync } from 'child_process';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join, resolve } from 'path';
import { TASKS } from './tasks.mjs';

const SERVER = resolve(new URL('..', import.meta.url).pathname);
const REPO = resolve(SERVER, '..');
const GODOT = process.env.GODOT_EXECUTABLE ?? '/Applications/Godot.app/Contents/MacOS/Godot';
const BASE_PORT = Number(process.env.EVAL_BASE_PORT ?? 9170);

const argv = process.argv.slice(2);
const option = (name, fallback) => {
  const at = argv.indexOf(`--${name}`);
  return at === -1 ? fallback : argv.splice(at, 2)[1];
};
const model = option('model', 'sonnet');
const laneCount = Number(option('lanes', 3));
const outDir = resolve(option('out', join(SERVER, 'eval', 'out')));
const runs = (argv.length > 0 ? argv : Object.keys(TASKS).map(task => `${task}:default`)).map(run => run.split(':'));
mkdirSync(outDir, { recursive: true });

// A copy of the repo's Godot project with its own port and a headless editor on it.
async function startLane(port) {
  const dir = mkdtempSync(join(tmpdir(), `godot-mcp-eval-${port}-`));
  execFileSync('rsync', ['-a', '--exclude', 'server', '--exclude', '.git', '--exclude', '.claude', '--exclude', '.godot',
    '--exclude', 'project-manager', `${REPO}/`, `${dir}/`]);
  for (const [file, from, to] of [['mcp_server.gd', 'var port := 9080', `var port := ${port}`],
    ['websocket_server.gd', 'var _port = 9080', `var _port = ${port}`]]) {
    const path = `${dir}/addons/godot_mcp/${file}`;
    writeFileSync(path, readFileSync(path, 'utf8').replace(from, to));
  }
  mkdirSync(`${dir}/project-manager`);
  writeFileSync(`${dir}/project-manager/permission_escalations.json`, '{\n  "records": []\n}\n');
  const godot = spawn(GODOT, ['--headless', '--editor', '--path', dir], { stdio: ['ignore', 'pipe', 'pipe'] });
  let log = '';
  await new Promise((done, fail) => {
    const timer = setTimeout(() => fail(new Error(`Godot on port ${port} did not load the addon:\n${log.slice(-2000)}`)), 180000);
    const watch = chunk => {
      log += chunk;
      if (/Loaded \d+\/\d+ processor/.test(log)) { clearTimeout(timer); done(); }
    };
    godot.stdout.on('data', watch);
    godot.stderr.on('data', watch);
  });
  return { dir, port, stop: () => { godot.kill(); rmSync(dir, { recursive: true, force: true }); } };
}

// A short-lived MCP client with every tool on, for setup and checks.
async function client(lane) {
  const server = spawn('node', [`${SERVER}/dist/index.js`], { cwd: lane.dir, stdio: ['pipe', 'pipe', 'ignore'],
    env: { ...process.env, GODOT_MCP_TOOLSETS: 'all', GODOT_WS_PORT: String(lane.port), GODOT_PROJECT_PATH: lane.dir, GODOT_EXECUTABLE: '/nonexistent' } });
  let buffer = ''; const pending = new Map(); let nextId = 0;
  server.stdout.on('data', chunk => {
    buffer += chunk;
    const lines = buffer.split('\n');
    buffer = lines.pop();
    for (const line of lines) { const message = JSON.parse(line); pending.get(message.id)?.(message); }
  });
  const rpc = (method, params) => new Promise(done => {
    const id = ++nextId;
    pending.set(id, done);
    server.stdin.write(JSON.stringify({ jsonrpc: '2.0', id, method, params }) + '\n');
  });
  await rpc('initialize', { protocolVersion: '2025-11-25', capabilities: {}, clientInfo: { name: 'eval', version: '0' } });
  server.stdin.write('{"jsonrpc":"2.0","method":"notifications/initialized"}\n');
  const call = async (name, args) => {
    const message = await rpc('tools/call', { name, arguments: args });
    const text = message.error ? `ERROR ${message.error.message}` : message.result.content.map(part => part.text ?? '').join('\n');
    return { text, failed: !!message.error || !!message.result?.isError };
  };
  return { call, close: () => server.kill() };
}

function runClaude(lane, config, prompt) {
  return new Promise(done => {
    let out = '';
    // --setting-sources local: no user hooks, plugins or settings, so runs measure the server alone.
    // --tools "": no built-in tools (no Bash or file edits), so the AI works only through this server.
    const claude = spawn('claude', ['-p', '--model', model, '--setting-sources', 'local', '--strict-mcp-config', '--mcp-config', config,
      '--tools', '', '--allowedTools', 'mcp__godot', '--output-format', 'stream-json', '--verbose', '--max-turns', '80',
      '--max-budget-usd', '3', '--no-session-persistence', prompt], { cwd: lane.dir, stdio: ['ignore', 'pipe', 'ignore'] });
    const timer = setTimeout(() => claude.kill(), 20 * 60 * 1000);
    claude.stdout.on('data', chunk => { out += chunk; });
    claude.on('close', () => { clearTimeout(timer); done(out); });
  });
}

function readTranscript(jsonl) {
  const messages = jsonl.trim().split('\n').filter(Boolean).map(line => { try { return JSON.parse(line); } catch { return {}; } });
  const calls = []; const errors = []; const seen = new Set(); const names = new Map();
  let peakContext = 0;
  for (const message of messages) {
    if (message.type === 'assistant') {
      const usage = message.message.usage ?? {};
      if (!seen.has(message.message.id)) {
        seen.add(message.message.id);
        peakContext = Math.max(peakContext, (usage.input_tokens ?? 0) + (usage.cache_read_input_tokens ?? 0) + (usage.cache_creation_input_tokens ?? 0));
      }
      for (const part of message.message.content) {
        if (part.type === 'tool_use') {
          calls.push({ name: part.name.replace(/^mcp__godot__/, ''), input: part.input });
          names.set(part.id, part.name.replace(/^mcp__godot__/, ''));
        }
      }
    }
    if (message.type === 'user') {
      for (const part of [].concat(message.message?.content ?? [])) {
        if (part.type === 'tool_result' && part.is_error) {
          const text = [].concat(part.content).map(item => (typeof item === 'string' ? item : item.text ?? '')).join(' ');
          errors.push(`${names.get(part.tool_use_id) ?? '?'}: ${text.slice(0, 220)}`);
        }
      }
    }
  }
  return { messages, calls, errors, peakContext, result: messages.find(message => message.type === 'result') ?? {} };
}

async function runOne(lane, taskName, mode) {
  const task = TASKS[taskName];
  const dir = `res://eval/${taskName}_${mode}`;
  const setup = await client(lane);
  const setupErrors = [];
  for (const [tool, args] of task.setup(dir)) {
    const result = await setup.call(tool, args);
    if (result.failed) setupErrors.push(`${tool}: ${result.text.slice(0, 200)}`);
  }
  await setup.call('create_scene', { path: `res://eval/blank_${taskName}_${mode}.tscn`, root_node_type: 'Node' }); // start on a blank scene
  setup.close();

  const env = { GODOT_WS_PORT: String(lane.port), GODOT_PROJECT_PATH: lane.dir, GODOT_EXECUTABLE: '/nonexistent',
    GODOT_MCP_APPROVAL_KEY_PATH: `${lane.dir}/approval.key` };
  if (mode === 'all') env.GODOT_MCP_TOOLSETS = 'all';
  const config = `${outDir}/mcp_${taskName}_${mode}.json`;
  writeFileSync(config, JSON.stringify({ mcpServers: { godot: { command: 'node', args: [`${SERVER}/dist/index.js`], env } } }));
  const prompt = 'You are working on a game in a Godot project through the godot MCP tools; the Godot editor is open with this project. ' +
    'Do the whole task, then save. Do not ask questions; choose sensible defaults.\nTask: ' + task.prompt(dir);
  const started = Date.now();
  const jsonl = await runClaude(lane, config, prompt);
  writeFileSync(`${outDir}/${taskName}_${mode}.jsonl`, jsonl);
  const { calls, errors, peakContext, result, messages } = readTranscript(jsonl);
  const init = messages.find(message => message.type === 'system' && message.subtype === 'init') ?? {};

  const check = await client(lane);
  let tree = '';
  const props = {};
  if (task.scene) {
    await check.call('open_scene', { path: task.scene(dir) });
    tree = (await check.call('get_scene_tree', { max_nodes: 2000 })).text;
    for (const [key, type] of Object.entries(task.propTypes ?? {})) {
      const found = (await check.call('query_nodes', { node_type: type })).text.match(/\/root\/[^\s",)]+/);
      if (found) props[key] = (await check.call('get_node_properties', { node_path: found[0] })).text;
    }
  }
  check.close();
  const checks = task.check(tree, props, dir, result.result ?? '').map(([ok, what]) => ({ ok, what }));
  const writes = calls.filter(call => !/^(load_tools|get_|list_|describe_|query_|inspect_|search_|find_|check_|validate_|analyze_|open_scene|capture_scene_image)/.test(call.name));
  const report = {
    task: taskName, mode, model, setupErrors,
    pass: checks.every(item => item.ok) && (!task.readOnly || writes.length === 0),
    checks, readOnlyBroken: task.readOnly ? writes.map(call => call.name) : undefined,
    toolsAtStart: (init.tools ?? []).length,
    loads: calls.filter(call => call.name === 'load_tools').map(call => call.input),
    expectedAny: task.expect,
    calls: calls.length, distinctTools: [...new Set(calls.map(call => call.name))],
    errors, turns: result.num_turns, seconds: Math.round((Date.now() - started) / 1000),
    cost: result.total_cost_usd, peakContext, stop: result.subtype, answer: (result.result ?? '').slice(0, 600),
  };
  writeFileSync(`${outDir}/${taskName}_${mode}.json`, JSON.stringify(report, null, 2));
  return report;
}

const queue = [...runs];
const reports = [];
await Promise.all(Array.from({ length: Math.min(laneCount, queue.length) }, async (_, index) => {
  const lane = await startLane(BASE_PORT + index);
  try {
    for (let next = queue.shift(); next; next = queue.shift()) {
      try {
        const report = await runOne(lane, next[0], next[1]);
        reports.push(report);
        console.log(`${report.pass ? 'PASS' : 'FAIL'} ${next.join(':')}`);
      } catch (error) {
        console.log(`ERROR ${next.join(':')}: ${error.stack}`);
      }
    }
  } finally {
    lane.stop();
  }
}));

const pad = (value, width) => String(value ?? '').padEnd(width);
console.log(`\n${pad('task:mode', 18)}${pad('pass', 6)}${pad('turns', 7)}${pad('cost', 8)}${pad('peak ctx', 10)}${pad('errors', 8)}loaded`);
for (const report of reports.sort((a, b) => `${a.task}:${a.mode}`.localeCompare(`${b.task}:${b.mode}`))) {
  const loaded = report.loads.flatMap(load => [...(load.groups ?? []), ...(load.tools ?? []), ...(load.find ? [`find:${load.find}`] : [])]);
  const expected = report.mode === 'all' || loaded.some(group => report.expectedAny.includes(group)) ? '' : `  (expected one of ${report.expectedAny.join(', ')})`;
  console.log(`${pad(`${report.task}:${report.mode}`, 18)}${pad(report.pass ? 'yes' : 'NO', 6)}${pad(report.turns, 7)}` +
    `${pad(`$${(report.cost ?? 0).toFixed(2)}`, 8)}${pad(report.peakContext, 10)}${pad(report.errors.length, 8)}${loaded.join(', ') || '-'}${expected}`);
  for (const item of report.checks.filter(item => !item.ok)) console.log(`    failed check: ${item.what}`);
}
