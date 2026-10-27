import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { escalationManager, EscalationStatus } from '../utils/escalation_manager.js';

const statusEnum = z.enum(['pending', 'approved', 'denied']);

export const permissionTools: MCPTool[] = [
  {
    name: 'list_permission_escalations',
    description: 'List permission escalation requests, newest first, optionally filtered by status.',
    parameters: z.object({
      status: statusEnum
        .optional()
        .describe('Filter results to a specific status (pending, approved, denied).'),
      limit: z.number().int().min(1).max(500).default(20).describe('Most requests to show (default 20).'),
    }),
    execute: async ({ status, limit = 20 }: { status?: EscalationStatus; limit?: number }): Promise<string> => {
      // Requests pile up with every admin call; full JSON records ran past 70k characters at 120 of them.
      const records = await escalationManager.listEscalations({ status });
      if (records.length === 0) return status ? `No ${status} escalation requests.` : 'No escalation requests.';
      const shown = records.slice(-limit).reverse();
      const lines = shown.map(record => {
        const args = JSON.stringify((record.metadata?.args as unknown) ?? {});
        return `- ${record.id} ${record.status} ${record.path.replace(/^tool:/, '')} ${record.requestedAt} ${args.length > 80 ? `${args.slice(0, 80)}…` : args}`;
      });
      const hidden = records.length - shown.length;
      return [
        `Escalation requests (${records.length}, newest first${hidden ? `; ${hidden} older not shown, raise limit` : ''}):`,
        ...lines,
        ...(shown.some(record => record.status === 'pending') ? ['A human approves with: cd server && npm run approve -- <id>'] : []),
      ].join('\n');
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'resolve_permission_escalation',
    description:
      'Deny (withdraw) a pending permission escalation request. This tool cannot approve: ' +
      'approval is human-only and signed (cd server && npm run approve -- <id>).',
    parameters: z.object({
      escalation_id: z.string().describe('Identifier returned when the escalation was recorded.'),
      status: z.literal('denied').default('denied')
        .describe('Only "denied" is accepted. A human approves outside MCP.'),
      resolver: z.string().optional().describe('Who resolved the escalation (for audit trail).'),
      notes: z.string().optional().describe('Optional notes explaining the decision.'),
    }),
    execute: async ({
      escalation_id,
      resolver,
      notes,
    }: {
      escalation_id: string;
      status?: 'denied';
      resolver?: string;
      notes?: string;
    }): Promise<string> => {
      // Hard-coded: the MCP client must never be able to approve its own escalation.
      const record = await escalationManager.resolveEscalation({
        id: escalation_id,
        status: 'denied',
        resolver,
        notes,
      });

      return JSON.stringify({
        escalation_id: record.id,
        status: record.status,
        resolved_at: record.resolvedAt,
        resolver: record.resolver,
        notes: record.notes,
        prompt: record.prompt,
        metadata: record.metadata,
      });
    },
    metadata: {
      // Denying only removes access, so it needs no escalation (an 'admin' role here escalated itself forever).
      requiredRole: 'edit',
    },
  },
];
