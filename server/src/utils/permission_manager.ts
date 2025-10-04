import path from 'node:path';
import { CapabilityConfig, PathRule, defaultCapabilityConfig } from './permission_config.js';
import { escalationManager } from './escalation_manager.js';

interface PermissionLogContext {
  systemSection: string;
  details?: Record<string, unknown>;
  error?: boolean;
}

/**
 * Performs capability scoping checks for file write operations, ensuring
 * automated edits only touch approved directories or file types. This is the
 * first step toward the broader permission system tracked in the P0 roadmap.
 */
export class PermissionManager {
  private readonly config: CapabilityConfig;

  constructor(config: CapabilityConfig = defaultCapabilityConfig) {
    this.config = {
      writeAllow: config.writeAllow.map(rule => this.normalizeRule(rule)),
      writeDeny: config.writeDeny.map(rule => this.normalizeRule(rule)),
    };
  }

  /**
   * Throws when a file write would violate the allow/deny rules.
   */
  async assertWriteAllowed(relativePath: string, mode: string): Promise<void> {
    const normalized = this.normalizePath(relativePath);

    if (this.matchesRuleList(normalized, this.config.writeDeny)) {
      this.log('Permission denied by deny rule', {
        systemSection: 'capability_check',
        error: true,
        details: { relativePath: normalized, mode, ruleSet: 'deny' },
      });
      throw new Error(`Write access to ${normalized} is denied by capability policy.`);
    }

    if (this.matchesRuleList(normalized, this.config.writeAllow)) {
      this.log('Permission granted', {
        systemSection: 'capability_check',
        details: { relativePath: normalized, mode },
      });
      return;
    }

    const escalation = await escalationManager.recordEscalation({
      path: normalized,
      mode,
      reason: 'not_allowlisted',
      requestedBy: 'permission_manager',
      prompt: `Request approval to ${mode} ${normalized}`,
      metadata: {
        relativePath: normalized,
        mode,
      },
    });

    this.log('Permission requires escalation', {
      systemSection: 'capability_check',
      error: true,
      details: { relativePath: normalized, mode, ruleSet: 'allow', escalationId: escalation.id },
    });
    throw new Error(
      `Write access to ${normalized} is not in the allowlist. Escalation required (id: ${escalation.id}).`,
    );
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

  private log(message: string, { systemSection, details, error = false }: PermissionLogContext): void {
    const logEntry = {
      filename: 'server/src/utils/permission_manager.ts',
      timestamp: new Date().toISOString(),
      classname: 'PermissionManager',
      function: 'assertWriteAllowed',
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
