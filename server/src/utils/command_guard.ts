import { escalationManager } from './escalation_manager.js';
import { CommandRole, MCPTool } from './types.js';

interface CommandPolicyConfig {
  /**
   * Roles that are automatically allowed without requiring an escalation.
   */
  autoApproveRoles: CommandRole[];
  /**
   * Default role applied to commands that do not specify a requirement.
   */
  defaultRole: CommandRole;
}

const defaultPolicy: CommandPolicyConfig = {
  autoApproveRoles: ['read', 'edit'],
  defaultRole: 'read',
};

interface CommandLogContext {
  systemSection: string;
  error?: boolean;
  details?: Record<string, unknown>;
}

export class CommandGuard {
  private readonly policy: CommandPolicyConfig;

  constructor(policy: CommandPolicyConfig = defaultPolicy) {
    this.policy = policy;
  }

  async assertAllowed<T>(tool: MCPTool<T>, args: T): Promise<void> {
    const requiredRole = tool.metadata?.requiredRole ?? this.policy.defaultRole;

    if (this.policy.autoApproveRoles.includes(requiredRole)) {
      this.log('command_allowed', {
        systemSection: 'assert',
        details: {
          tool: tool.name,
          requiredRole,
        },
      });
      return;
    }

    const escalation = await escalationManager.recordEscalation({
      path: `tool:${tool.name}`,
      mode: requiredRole,
      reason: 'role_escalation_required',
      requestedBy: 'command_guard',
      prompt: tool.metadata?.escalationPrompt,
      metadata: {
        tool: tool.name,
        description: tool.description,
        requiredRole,
        args,
      },
    });

    this.log('command_escalation_required', {
      systemSection: 'assert',
      error: true,
      details: {
        tool: tool.name,
        requiredRole,
        escalationId: escalation.id,
      },
    });

    const promptSuffix = tool.metadata?.escalationPrompt
      ? ` Suggested prompt: ${tool.metadata.escalationPrompt}`
      : '';
    throw new Error(
      `Command "${tool.name}" requires role "${requiredRole}". Escalation required (id: ${escalation.id}).${promptSuffix}`,
    );
  }

  private log(message: string, { systemSection, error = false, details }: CommandLogContext): void {
    const logEntry = {
      filename: 'server/src/utils/command_guard.ts',
      timestamp: new Date().toISOString(),
      classname: 'CommandGuard',
      function: systemSection,
      system_section: systemSection,
      line_num: 0,
      error,
      db_phase: 'none' as const,
      method: 'NONE' as const,
      message,
      ...(details ? { details } : {}),
    };

    console.error(JSON.stringify(logEntry));
    console.error(`[Continuous skepticism (Sherlock Protocol)] ${message}`);
  }
}

export const commandGuard = new CommandGuard();
