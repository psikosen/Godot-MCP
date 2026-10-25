import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { escalationManager, EscalationStatus } from '../utils/escalation_manager.js';

const statusEnum = z.enum(['pending', 'approved', 'denied']);

export const permissionTools: MCPTool[] = [
  {
    name: 'list_permission_escalations',
    description: 'List recorded permission escalation requests optionally filtered by status.',
    parameters: z.object({
      status: statusEnum
        .optional()
        .describe('Filter results to a specific status (pending, approved, denied).'),
    }),
    execute: async ({ status }: { status?: EscalationStatus }): Promise<string> => {
      const records = await escalationManager.listEscalations({ status });
      return JSON.stringify(
        {
          status: status ?? 'all',
          count: records.length,
          records,
        },
        null,
        2,
      );
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
      }, null, 2);
    },
    metadata: {
      // Denying only removes access, so it needs no escalation (an 'admin' role here escalated itself forever).
      requiredRole: 'edit',
    },
  },
];
