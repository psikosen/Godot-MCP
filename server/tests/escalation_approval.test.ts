import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { z } from 'zod';
import { CommandGuard } from '../dist/utils/command_guard.js';
import { EscalationManager } from '../dist/utils/escalation_manager.js';
import type { MCPTool } from '../dist/utils/types.js';

const adminTool: MCPTool<{ code: string; flags?: { a: number; b: number } }> = {
  name: 'danger_tool',
  description: 'test admin tool',
  parameters: z.object({ code: z.string() }),
  execute: async () => 'ran',
  metadata: { requiredRole: 'admin' },
};

let dir: string;
let storagePath: string;
let manager: EscalationManager;
let guard: CommandGuard;

const escalationId = async (call: Promise<void>): Promise<string> => {
  const error = await call.then(() => null, (err: Error) => err);
  expect(error?.message).toContain('Escalation required');
  return /id: ([0-9a-f-]+)/.exec(error!.message)![1];
};

// What a human does by hand: open the JSON file and flip "pending" to "approved".
const approveByEditingFile = async (id: string, status = 'approved'): Promise<void> => {
  const state = JSON.parse(await fs.readFile(storagePath, 'utf8'));
  state.records.find((r: { id: string }) => r.id === id).status = status;
  await fs.writeFile(storagePath, JSON.stringify(state, null, 2));
};

beforeEach(async () => {
  vi.spyOn(console, 'error').mockImplementation(() => undefined);
  dir = await fs.mkdtemp(path.join(os.tmpdir(), 'godot-mcp-esc-'));
  storagePath = path.join(dir, 'permission_escalations.json');
  manager = new EscalationManager(storagePath);
  guard = new CommandGuard(undefined, manager);
});

afterEach(async () => {
  vi.restoreAllMocks();
  await fs.rm(dir, { recursive: true, force: true });
});

describe('CommandGuard escalation approval', () => {
  it('allows an admin call once after a human approves it, then escalates again', async () => {
    const args = { code: 'print(1)' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));

    // Retrying before approval returns the same pending request.
    expect(await escalationId(guard.assertAllowed(adminTool, args))).toBe(id);

    await approveByEditingFile(id);
    await expect(guard.assertAllowed(adminTool, args)).resolves.toBeUndefined();

    const [record] = await manager.listEscalations({ status: 'approved' });
    expect(record.id).toBe(id);
    expect(record.consumedAt).toBeTruthy();

    // Single use: the next identical call needs a new approval.
    const next = await escalationId(guard.assertAllowed(adminTool, args));
    expect(next).not.toBe(id);
  });

  it('works with approvals made through resolveEscalation (the npm run approve path)', async () => {
    const args = { code: 'print(2)' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await manager.resolveEscalation({ id, status: 'approved', resolver: 'human' });
    await expect(guard.assertAllowed(adminTool, args)).resolves.toBeUndefined();
  });

  it('does not let an approval for one set of args unlock different args', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'safe()' }));
    await approveByEditingFile(id);

    const otherId = await escalationId(guard.assertAllowed(adminTool, { code: 'rm_rf()' }));
    expect(otherId).not.toBe(id);

    // The original approval is still unused and still works for its own args.
    await expect(guard.assertAllowed(adminTool, { code: 'safe()' })).resolves.toBeUndefined();
  });

  it('matches args regardless of key order', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'x', flags: { a: 1, b: 2 } }));
    await approveByEditingFile(id);
    await expect(guard.assertAllowed(adminTool, { flags: { b: 2, a: 1 }, code: 'x' })).resolves.toBeUndefined();
  });

  it('keeps denied escalations blocked', async () => {
    const args = { code: 'print(3)' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await approveByEditingFile(id, 'denied');
    await expect(guard.assertAllowed(adminTool, args)).rejects.toThrow('Escalation required');
  });
});

describe('resolve_permission_escalation is deny-only', () => {
  it('rejects approve in its schema, needs no escalation itself, and can deny', async () => {
    vi.resetModules();
    vi.doMock('../dist/utils/escalation_manager.js', () => ({ escalationManager: manager }));
    const { permissionTools } = await import('../dist/tools/permission_tools.js');
    const tool = permissionTools.find(t => t.name === 'resolve_permission_escalation')!;

    expect(tool.parameters.safeParse({ escalation_id: 'x', status: 'approved' }).success).toBe(false);
    expect(tool.metadata?.requiredRole).not.toBe('admin');

    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'y' }));
    // Even if schema validation were bypassed, execute only ever denies.
    await tool.execute({ escalation_id: id, status: 'approved' } as never);

    const [record] = await manager.listEscalations();
    expect(record.status).toBe('denied');
    await expect(guard.assertAllowed(adminTool, { code: 'y' })).rejects.toThrow('Escalation required');
    vi.doUnmock('../dist/utils/escalation_manager.js');
  });
});
