import { createHmac } from 'node:crypto';
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { z } from 'zod';
import { CommandGuard } from '../dist/utils/command_guard.js';
import { APPROVAL_TTL_MS, EscalationManager } from '../dist/utils/escalation_manager.js';
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
let keyPath: string;
let manager: EscalationManager;
let guard: CommandGuard;

const escalationId = async (call: Promise<void>): Promise<string> => {
  const error = await call.then(() => null, (err: Error) => err);
  expect(error?.message).toContain('Escalation required');
  return /id: ([0-9a-f-]+)/.exec(error!.message)![1];
};

// What `npm run approve -- <id>` does.
const humanApprove = (id: string) => manager.resolveEscalation({ id, status: 'approved', resolver: 'human' });

type Rec = Record<string, unknown> & { id: string };
// What an attacker (or a Godot tool saving over the file) can do: rewrite the store freely.
const editStore = async (fn: (records: Rec[]) => void): Promise<void> => {
  const state = JSON.parse(await fs.readFile(storagePath, 'utf8'));
  fn(state.records);
  await fs.writeFile(storagePath, JSON.stringify(state, null, 2));
};

beforeEach(async () => {
  vi.spyOn(console, 'error').mockImplementation(() => undefined);
  dir = await fs.mkdtemp(path.join(os.tmpdir(), 'godot-mcp-esc-'));
  storagePath = path.join(dir, 'permission_escalations.json');
  keyPath = path.join(dir, 'keydir', 'approval.key');
  manager = new EscalationManager(storagePath, keyPath);
  guard = new CommandGuard(undefined, manager);
});

afterEach(async () => {
  vi.useRealTimers();
  vi.restoreAllMocks();
  await fs.rm(dir, { recursive: true, force: true });
});

describe('CommandGuard escalation approval', () => {
  it('allows an admin call once after a human approves it, then escalates again', async () => {
    const args = { code: 'print(1)' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));

    // Retrying before approval returns the same pending request.
    expect(await escalationId(guard.assertAllowed(adminTool, args))).toBe(id);

    await humanApprove(id);
    await expect(guard.assertAllowed(adminTool, args)).resolves.toBeUndefined();

    const [record] = await manager.listEscalations({ status: 'approved' });
    expect(record.id).toBe(id);
    expect(record.consumedAt).toBeTruthy();

    // Single use: the next identical call needs a new approval.
    const next = await escalationId(guard.assertAllowed(adminTool, args));
    expect(next).not.toBe(id);
  });

  it('creates the approval key with mode 0600 outside the store', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'k' }));
    await humanApprove(id);
    const stat = await fs.stat(keyPath);
    expect(stat.mode & 0o777).toBe(0o600);
    expect((await fs.readFile(keyPath, 'utf8')).trim()).toMatch(/^[0-9a-f]{64}$/);
  });

  it('ignores a record set to "approved" without a valid signature (self-approval attack)', async () => {
    // A real key exists (the human approved something earlier), so only the signature can stop this.
    await humanApprove(await escalationId(guard.assertAllowed(adminTool, { code: 'earlier()' })));
    expect((await fs.readFile(keyPath, 'utf8')).trim()).toMatch(/^[0-9a-f]{64}$/);

    const args = { code: 'pwn()' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await editStore(records => {
      const r = records.find(x => x.id === id)!;
      r.status = 'approved';
      r.resolvedAt = new Date().toISOString();
      r.approvalSignature = 'f'.repeat(64);
    });
    await expect(guard.assertAllowed(adminTool, args)).rejects.toThrow('Escalation required');
  });

  it('ignores a signed approval whose args were swapped in the file', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'safe()' }));
    await humanApprove(id);
    await editStore(records => {
      (records.find(x => x.id === id)!.metadata as { args: unknown }).args = { code: 'rm_rf()' };
    });
    await expect(guard.assertAllowed(adminTool, { code: 'rm_rf()' })).rejects.toThrow('Escalation required');
  });

  it('does not replay a consumed approval after consumedAt is stripped from the file', async () => {
    const args = { code: 'once()' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await humanApprove(id);
    await guard.assertAllowed(adminTool, args);

    await editStore(records => {
      delete records.find(x => x.id === id)!.consumedAt;
    });
    await expect(guard.assertAllowed(adminTool, args)).rejects.toThrow('Escalation required');
  });

  it('expires signed approvals after the TTL', async () => {
    const args = { code: 'later()' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await humanApprove(id);
    vi.useFakeTimers({ toFake: ['Date'] });
    vi.setSystemTime(Date.now() + APPROVAL_TTL_MS + 1000);
    await expect(guard.assertAllowed(adminTool, args)).rejects.toThrow('Escalation required');
  });

  it('ignores approvals when a Godot resource was saved over the key file', async () => {
    const args = { code: 'k2' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));

    // Godot's JSON saver output is not hex, so a naive Buffer.from(text, 'hex') would give an
    // empty key the attacker can sign with. The 64-hex-char format check must refuse it.
    await fs.mkdir(path.dirname(keyPath), { recursive: true });
    await fs.writeFile(keyPath, '{\n\t"records": []\n}\n');
    const approvedAt = new Date().toISOString();
    const payload = JSON.stringify({ approvedAt, args, id, mode: 'admin', path: 'tool:danger_tool' });
    await editStore(records => {
      const r = records.find(x => x.id === id)!;
      r.status = 'approved';
      r.resolvedAt = approvedAt;
      r.approvalSignature = createHmac('sha256', Buffer.alloc(0)).update(payload).digest('hex');
    });

    const freshManager = new EscalationManager(storagePath, keyPath); // simulates a server restart
    await expect(new CommandGuard(undefined, freshManager).assertAllowed(adminTool, args)).rejects.toThrow(
      'Escalation required',
    );
  });

  it('does not let an approval for one set of args unlock different args', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'safe()' }));
    await humanApprove(id);

    const otherId = await escalationId(guard.assertAllowed(adminTool, { code: 'rm_rf()' }));
    expect(otherId).not.toBe(id);

    // The original approval is still unused and still works for its own args.
    await expect(guard.assertAllowed(adminTool, { code: 'safe()' })).resolves.toBeUndefined();
  });

  it('matches args regardless of key order', async () => {
    const id = await escalationId(guard.assertAllowed(adminTool, { code: 'x', flags: { a: 1, b: 2 } }));
    await humanApprove(id);
    await expect(guard.assertAllowed(adminTool, { flags: { b: 2, a: 1 }, code: 'x' })).resolves.toBeUndefined();
  });

  it('keeps denied escalations blocked', async () => {
    const args = { code: 'print(3)' };
    const id = await escalationId(guard.assertAllowed(adminTool, args));
    await manager.resolveEscalation({ id, status: 'denied' });
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
