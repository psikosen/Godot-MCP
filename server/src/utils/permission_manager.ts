import { promises as fs } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';
import {
  CapabilityConfig,
  PathRule,
  defaultCapabilityConfig,
  CommandRoleRule,
} from './permission_config.js';
import { CapabilityRole } from './types.js';

interface PermissionLogContext {
  systemSection: string;
  functionName?: string;
  details?: Record<string, unknown>;
  error?: boolean;
}

export class PermissionDeniedError extends Error {
  constructor(
    public readonly toolName: string,
    public readonly requiredRole: CapabilityRole,
    public readonly currentRole: CapabilityRole,
    public readonly description?: string,
  ) {
    const reason = description ? ` Reason: ${description}` : '';
    super(
      `Tool "${toolName}" requires ${requiredRole} role (current role: ${currentRole}).${reason} ` +
        'Request an escalation with the request_permission_escalation tool.',
    );
    this.name = 'PermissionDeniedError';
  }
}

/**
 * Performs capability scoping checks for file write operations, ensuring
 * automated edits only touch approved directories or file types. This is the
 * first step toward the broader permission system tracked in the P0 roadmap.
 */
export class PermissionManager {
  private readonly config: CapabilityConfig;
  private readonly projectRoot: string;
  private readonly escalationLogPath: string;
  private readonly commandRoles = new Map<string, CommandRoleRule>();
  private readonly roleOrder: Record<CapabilityRole, number> = {
    read: 0,
    write: 1,
    admin: 2,
  };
  private currentRole: CapabilityRole;

  constructor(
    config: CapabilityConfig = defaultCapabilityConfig,
    { projectRoot, currentRole }: { projectRoot?: string; currentRole?: CapabilityRole } = {},
  ) {
    this.projectRoot = projectRoot ?? path.resolve(process.cwd(), '..');
    this.config = {
      writeAllow: config.writeAllow.map(rule => this.normalizeRule(rule)),
      writeDeny: config.writeDeny.map(rule => this.normalizeRule(rule)),
      defaultRole: config.defaultRole ?? defaultCapabilityConfig.defaultRole ?? 'write',
      commandRoles: config.commandRoles ?? defaultCapabilityConfig.commandRoles ?? [],
    };

    for (const rule of this.config.commandRoles ?? []) {
      this.commandRoles.set(rule.tool, rule);
    }

    this.currentRole = this.normalizeRole(
      currentRole ?? (process.env.MCP_AGENT_ROLE as CapabilityRole) ?? this.config.defaultRole ?? 'write',
    );
    this.escalationLogPath = path.join(this.projectRoot, 'project-manager', 'escalation_requests.log');
  }

  /**
   * Throws when a file write would violate the allow/deny rules.
   */
  assertWriteAllowed(relativePath: string, mode: string): void {
    const normalized = this.normalizePath(relativePath);

    if (this.matchesRuleList(normalized, this.config.writeDeny)) {
      this.log('Permission denied by deny rule', {
        systemSection: 'capability_check',
        functionName: 'assertWriteAllowed',
        error: true,
        details: { relativePath: normalized, mode, ruleSet: 'deny' },
      });
      throw new Error(`Write access to ${normalized} is denied by capability policy.`);
    }

    if (this.matchesRuleList(normalized, this.config.writeAllow)) {
      this.log('Permission granted', {
        systemSection: 'capability_check',
        functionName: 'assertWriteAllowed',
        details: { relativePath: normalized, mode },
      });
      return;
    }

    this.log('Permission requires escalation', {
      systemSection: 'capability_check',
      functionName: 'assertWriteAllowed',
      error: true,
      details: { relativePath: normalized, mode, ruleSet: 'allow' },
    });
    throw new Error(`Write access to ${normalized} is not in the allowlist. Escalation required.`);
  }

  assertCommandAllowed(toolName: string, declaredRole?: CapabilityRole, escalationMessage?: string): void {
    const rule = this.findCommandRule(toolName);
    const requiredRole = this.resolveRequiredRole(toolName, declaredRole);
    const description = rule?.description ?? escalationMessage;

    if (this.roleOrder[this.currentRole] >= this.roleOrder[requiredRole]) {
      this.log('Command permitted', {
        systemSection: 'command_check',
        functionName: 'assertCommandAllowed',
        details: {
          toolName,
          requiredRole,
          currentRole: this.currentRole,
        },
      });
      return;
    }

    this.log('Command requires escalation', {
      systemSection: 'command_check',
      functionName: 'assertCommandAllowed',
      error: true,
      details: {
        toolName,
        requiredRole,
        currentRole: this.currentRole,
      },
    });

    throw new PermissionDeniedError(toolName, requiredRole, this.currentRole, description);
  }

  async requestEscalation(
    toolName: string,
    justification: string,
    requestedRole?: CapabilityRole,
  ): Promise<{
    status: 'recorded' | 'already_satisfied';
    requestId?: string;
    requiredRole: CapabilityRole;
    currentRole: CapabilityRole;
  }> {
    const trimmedJustification = justification?.trim();
    if (!trimmedJustification) {
      throw new Error('Justification is required to request an escalation.');
    }

    const requiredRole = requestedRole
      ? this.normalizeRole(requestedRole)
      : this.resolveRequiredRole(toolName);

    if (this.roleOrder[this.currentRole] >= this.roleOrder[requiredRole]) {
      this.log('Escalation request skipped - already satisfied', {
        systemSection: 'escalation',
        functionName: 'requestEscalation',
        details: { toolName, requiredRole, currentRole: this.currentRole },
      });
      return {
        status: 'already_satisfied',
        requiredRole,
        currentRole: this.currentRole,
      };
    }

    const requestId = randomUUID();
    const entry = {
      request_id: requestId,
      tool: toolName,
      required_role: requiredRole,
      current_role: this.currentRole,
      justification: trimmedJustification,
      description: this.findCommandRule(toolName)?.description ?? null,
      timestamp: new Date().toISOString(),
    };

    await fs.mkdir(path.dirname(this.escalationLogPath), { recursive: true });
    await fs.appendFile(this.escalationLogPath, JSON.stringify(entry) + '\n', 'utf8');

    this.log('Recorded escalation request', {
      systemSection: 'escalation',
      functionName: 'requestEscalation',
      details: { toolName, requiredRole, currentRole: this.currentRole, requestId },
    });

    return {
      status: 'recorded',
      requestId,
      requiredRole,
      currentRole: this.currentRole,
    };
  }

  getCurrentRole(): CapabilityRole {
    return this.currentRole;
  }

  setCurrentRole(role: CapabilityRole): void {
    this.currentRole = this.normalizeRole(role);
    this.log('Updated current permission role', {
      systemSection: 'role_update',
      functionName: 'setCurrentRole',
      details: { currentRole: this.currentRole },
    });
  }

  private matchesRuleList(relativePath: string, rules: PathRule[]): boolean {
    return rules.some(rule => this.matchesRule(relativePath, rule));
  }

  private matchesRule(relativePath: string, rule: PathRule): boolean {
    if (rule.type === 'directory') {
      return relativePath === rule.value || relativePath.startsWith(`${rule.value}/`);
    }
    if (rule.type === 'file') {
      return relativePath === rule.value;
    }
    if (rule.type === 'extension') {
      return relativePath.endsWith(rule.value);
    }
    return false;
  }

  private normalizeRule(rule: PathRule): PathRule {
    if (rule.type === 'extension') {
      return rule;
    }
    return { ...rule, value: this.normalizePath(rule.value) };
  }

  private normalizePath(input: string): string {
    const normalized = path.posix.normalize(input.replace(/\\/g, '/'));
    return normalized.startsWith('./') ? normalized.slice(2) : normalized;
  }

  private findCommandRule(toolName: string): CommandRoleRule | undefined {
    return this.commandRoles.get(toolName);
  }

  private resolveRequiredRole(toolName: string, declaredRole?: CapabilityRole): CapabilityRole {
    if (declaredRole) {
      const normalized = this.normalizeRole(declaredRole);
      const configRole = this.findCommandRule(toolName)?.role;
      if (!configRole) {
        return normalized;
      }
      return this.roleOrder[configRole] > this.roleOrder[normalized] ? configRole : normalized;
    }

    const configRole = this.findCommandRule(toolName)?.role;
    if (configRole) {
      return configRole;
    }

    return this.config.defaultRole ?? 'read';
  }

  private normalizeRole(role: CapabilityRole): CapabilityRole {
    if (!(role in this.roleOrder)) {
      return 'read';
    }
    return role;
  }

  private log(message: string, { systemSection, details, error = false, functionName }: PermissionLogContext): void {
    const logEntry = {
      filename: 'server/src/utils/permission_manager.ts',
      timestamp: new Date().toISOString(),
      classname: 'PermissionManager',
      function: functionName ?? 'assertWriteAllowed',
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

export const permissionManager = new PermissionManager();
