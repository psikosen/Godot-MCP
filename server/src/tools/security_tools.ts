import { z } from 'zod';
import { permissionManager } from '../utils/permission_manager.js';
import { CapabilityRole, MCPTool } from '../utils/types.js';

const roleEnum = z.enum(['read', 'write', 'admin']);

type RequestEscalationParams = {
  tool_name: string;
  justification: string;
  requested_role?: CapabilityRole;
};

export const securityTools: MCPTool<RequestEscalationParams>[] = [
  {
    name: 'request_permission_escalation',
    description: 'Record a justification for escalating the MCP agent permission role.',
    capability: {
      role: 'read',
      escalationMessage: 'Records escalation requests for manual review.',
    },
    parameters: z.object({
      tool_name: z
        .string()
        .min(1)
        .describe('Name of the tool that triggered the permission denial.'),
      justification: z
        .string()
        .min(1)
        .describe('Business or safety justification for granting higher privileges.'),
      requested_role: roleEnum.optional().describe('Optional target role (read, write, or admin).'),
    }),
    execute: async ({ tool_name, justification, requested_role }: RequestEscalationParams): Promise<string> => {
      const result = await permissionManager.requestEscalation(tool_name, justification, requested_role);
      return JSON.stringify(
        {
          status: result.status,
          request_id: result.requestId,
          required_role: result.requiredRole,
          current_role: result.currentRole,
          tool: tool_name,
        },
        null,
        2,
      );
    },
  },
];
