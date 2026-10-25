import os from 'node:os';
import { escalationManager } from './utils/escalation_manager.js';

/**
 * Human-only approval of permission escalations. MCP clients cannot approve their own
 * requests (resolve_permission_escalation can only deny), so approval happens here.
 *
 *   npm run approve                    list pending escalations
 *   npm run approve -- <id> [notes]    approve one escalation (single use)
 */
// ponytail: plain read-modify-write of the JSON file; a server write landing in the same
// millisecond can drop one change. Add a file lock if approvals ever race in practice.
async function main(): Promise<void> {
  const [id, ...notes] = process.argv.slice(2);

  if (!id) {
    const pending = await escalationManager.listEscalations({ status: 'pending' });
    console.log(`${pending.length} pending escalation(s) in ${escalationManager.filePath}`);
    for (const record of pending) {
      console.log(`\n${record.id}  ${record.path}  (${record.mode}, requested ${record.requestedAt})`);
      console.log(`  args: ${JSON.stringify(record.metadata?.args ?? record.metadata ?? {})}`);
    }
    console.log('\nApprove one with: npm run approve -- <id> [notes]');
    return;
  }

  const record = await escalationManager.resolveEscalation({
    id,
    status: 'approved',
    resolver: os.userInfo().username,
    notes: notes.join(' ') || undefined,
  });

  if (record.status !== 'approved') {
    console.log(`Escalation ${id} was already ${record.status}; nothing changed.`);
    process.exitCode = 1;
    return;
  }

  console.log(`Approved ${record.id} (${record.path}). The client can now retry that exact call once.`);
}

main().catch(error => {
  console.error((error as Error).message);
  process.exitCode = 1;
});
