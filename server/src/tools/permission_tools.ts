import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { escalationManager, EscalationStatus } from '../utils/escalation_manager.js';

const statusEnum = z.enum(['pending', 'approved', 'denied']);
const resolutionEnum = z.enum(['approved', 'denied']);
type ResolutionStatus = z.infer<typeof resolutionEnum>;

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
  },
  {
    name: 'resolve_permission_escalation',
    description: 'Resolve a permission escalation request by approving or denying it.',
    parameters: z.object({
      escalation_id: z.string().describe('Identifier returned when the escalation was recorded.'),
      status: resolutionEnum.describe('Resolution outcome for the escalation request.'),
      resolver: z.string().optional().describe('Who resolved the escalation (for audit trail).'),
      notes: z.string().optional().describe('Optional notes explaining the decision.'),
    }),
    execute: async ({
      escalation_id,
      status,
      resolver,
      notes,
    }: {
      escalation_id: string;
      status: ResolutionStatus;
      resolver?: string;
      notes?: string;
    }): Promise<string> => {
      const record = await escalationManager.resolveEscalation({
        id: escalation_id,
        status,
        resolver,
        notes,
      });

      return JSON.stringify({
        escalation_id: record.id,
        status: record.status,
        resolved_at: record.resolvedAt,
        resolver: record.resolver,
        notes: record.notes,
      }, null, 2);
    },
  },
];
