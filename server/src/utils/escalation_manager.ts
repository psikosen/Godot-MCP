import { promises as fs } from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';

export type EscalationStatus = 'pending' | 'approved' | 'denied';

export interface EscalationRecord {
  id: string;
  path: string;
  mode: string;
  reason: string;
  requestedBy: string;
  requestedAt: string;
  status: EscalationStatus;
  resolvedAt?: string;
  resolver?: string;
  notes?: string;
}

interface EscalationState {
  records: EscalationRecord[];
}

interface RecordEscalationInput {
  path: string;
  mode: string;
  reason: string;
  requestedBy: string;
}

interface ResolveEscalationInput {
  id: string;
  status: EscalationStatus;
  resolver?: string;
  notes?: string;
}

interface ListOptions {
  status?: EscalationStatus;
}

/**
 * Persists permission escalation requests so that humans can review and
 * resolve them outside of the automated patch workflow.
 */
export class EscalationManager {
  private readonly storagePath: string;
  private queue: Promise<void> = Promise.resolve();

  constructor(storagePath?: string) {
    this.storagePath =
      storagePath ?? path.resolve(process.cwd(), '..', 'project-manager', 'permission_escalations.json');
  }

  async recordEscalation({ path: relativePath, mode, reason, requestedBy }: RecordEscalationInput): Promise<EscalationRecord> {
    return this.withLock(async () => {
      const state = await this.loadState();
      const normalizedPath = this.normalizePath(relativePath);

      const existing = state.records.find(
        record => record.status === 'pending' && record.path === normalizedPath && record.mode === mode && record.reason === reason,
      );

      if (existing) {
        this.log('Escalation already pending', {
          systemSection: 'record',
          details: { id: existing.id, path: existing.path, mode: existing.mode, reason: existing.reason },
        });
        return existing;
      }

      const record: EscalationRecord = {
        id: randomUUID(),
        path: normalizedPath,
        mode,
        reason,
        requestedBy,
        requestedAt: new Date().toISOString(),
        status: 'pending',
      };

      state.records.push(record);
      await this.saveState(state);

      this.log('Recorded new escalation request', {
        systemSection: 'record',
        details: { id: record.id, path: record.path, mode: record.mode, reason: record.reason },
      });

      return record;
    });
  }

  async listEscalations(options: ListOptions = {}): Promise<EscalationRecord[]> {
    await this.queue;
    const state = await this.loadState();
    const statusFilter = options.status;

    const records = statusFilter ? state.records.filter(record => record.status === statusFilter) : state.records;
    this.log('Listed escalation requests', {
      systemSection: 'list',
      details: { total: records.length, status: statusFilter ?? 'all' },
    });
    return records.sort((a, b) => a.requestedAt.localeCompare(b.requestedAt));
  }

  async resolveEscalation({ id, status, resolver, notes }: ResolveEscalationInput): Promise<EscalationRecord> {
    if (status === 'pending') {
      throw new Error('Cannot resolve escalation to pending state.');
    }

    return this.withLock(async () => {
      const state = await this.loadState();
      const record = state.records.find(item => item.id === id);

      if (!record) {
        this.log('Attempted to resolve missing escalation', {
          systemSection: 'resolve',
          error: true,
          details: { id },
        });
        throw new Error(`Escalation request ${id} was not found.`);
      }

      if (record.status !== 'pending') {
        this.log('Escalation already resolved', {
          systemSection: 'resolve',
          details: { id: record.id, status: record.status },
        });
        return record;
      }

      record.status = status;
      record.resolvedAt = new Date().toISOString();
      record.resolver = resolver;
      record.notes = notes;

      await this.saveState(state);

      this.log('Resolved escalation request', {
        systemSection: 'resolve',
        details: { id: record.id, status: record.status },
      });

      return record;
    });
  }

  private async withLock<T>(fn: () => Promise<T>): Promise<T> {
    const run = async () => fn();
    const next = this.queue.then(run, run);
    this.queue = next.then(
      () => undefined,
      () => undefined,
    );
    return next;
  }

  private async loadState(): Promise<EscalationState> {
    try {
      const raw = await fs.readFile(this.storagePath, 'utf8');
      const parsed = JSON.parse(raw) as EscalationState;
      return parsed.records ? parsed : { records: [] };
    } catch (error) {
      const err = error as NodeJS.ErrnoException;
      if (err.code === 'ENOENT') {
        return { records: [] };
      }

      this.log(`Failed to load escalation state: ${err.message}`, {
        systemSection: 'load',
        error: true,
      });
      return { records: [] };
    }
  }

  private async saveState(state: EscalationState): Promise<void> {
    await this.ensureDirectory();
    const serialized = `${JSON.stringify(state, null, 2)}\n`;
    await fs.writeFile(this.storagePath, serialized, 'utf8');
  }

  private async ensureDirectory(): Promise<void> {
    const dir = path.dirname(this.storagePath);
    await fs.mkdir(dir, { recursive: true });
  }

  private normalizePath(input: string): string {
    const normalized = path.posix.normalize(input.replace(/\\/g, '/'));
    return normalized.startsWith('./') ? normalized.slice(2) : normalized;
  }

  private log(message: string, {
    systemSection,
    error = false,
    details,
  }: {
    systemSection: string;
    error?: boolean;
    details?: Record<string, unknown>;
  }): void {
    const logEntry = {
      filename: 'server/src/utils/escalation_manager.ts',
      timestamp: new Date().toISOString(),
      classname: 'EscalationManager',
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

export const escalationManager = new EscalationManager();
