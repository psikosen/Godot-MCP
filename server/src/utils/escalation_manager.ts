import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHmac, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { fileURLToPath } from 'node:url';

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
  prompt?: string;
  metadata?: Record<string, unknown>;
  /** Set when an approved escalation has been used. Approvals are single-use. */
  consumedAt?: string;
  /** HMAC from `npm run approve`. An "approved" record without a valid one is ignored. */
  approvalSignature?: string;
}

interface EscalationState {
  records: EscalationRecord[];
}

interface RecordEscalationInput {
  path: string;
  mode: string;
  reason: string;
  requestedBy: string;
  prompt?: string;
  metadata?: Record<string, unknown>;
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

// Key-order-independent JSON, so a hand-edited record still matches the same args.
const canonicalJson = (value: unknown): string =>
  JSON.stringify(value, (_key, v: unknown) =>
    v && typeof v === 'object' && !Array.isArray(v)
      ? Object.fromEntries(Object.entries(v).sort(([a], [b]) => a.localeCompare(b)))
      : v,
  ) ?? '';

/**
 * Default store: <repo>/project-manager/permission_escalations.json, resolved from this
 * module (src/utils or dist/utils) so the server and the approve CLI share one file no
 * matter which directory the MCP client launches the server from.
 */
const defaultStoragePath = fileURLToPath(
  new URL('../../../project-manager/permission_escalations.json', import.meta.url),
);

/**
 * The escalation store lives inside the Godot project, so Godot tools can rewrite it.
 * Approvals are therefore signed with a key kept outside the project; the store alone
 * can never grant anything.
 */
const defaultKeyPath =
  process.env.GODOT_MCP_APPROVAL_KEY_PATH ?? path.join(os.homedir(), '.config', 'godot-mcp', 'approval.key');
const KEY_FORMAT = /^[0-9a-f]{64}$/;
/** Signed approvals expire, which bounds replay if someone strips consumedAt from the file. */
export const APPROVAL_TTL_MS = 10 * 60 * 1000;
const CLOCK_SKEW_MS = 60 * 1000;

/**
 * Persists permission escalation requests so that humans can review and
 * resolve them outside of the automated patch workflow.
 */
export class EscalationManager {
  private readonly storagePath: string;
  private readonly keyPath: string;
  private queue: Promise<void> = Promise.resolve();
  // ponytail: cached for the process lifetime, so overwriting the key file mid-session changes
  // nothing; a restart re-reads it. Tools that can write outside res:// must stay contained.
  private key?: Buffer;
  // Survives a rollback of consumedAt in the file (until restart; the TTL covers the rest).
  private readonly consumedIds = new Set<string>();

  constructor(storagePath?: string, keyPath: string = defaultKeyPath) {
    this.storagePath = storagePath ?? defaultStoragePath;
    this.keyPath = keyPath;
  }

  get filePath(): string {
    return this.storagePath;
  }

  async recordEscalation({
    path: relativePath,
    mode,
    reason,
    requestedBy,
    prompt,
    metadata,
  }: RecordEscalationInput): Promise<EscalationRecord> {
    return this.withLock(async () => {
      const state = await this.loadState();
      const normalizedPath = this.normalizePath(relativePath);

      const existing = state.records.find(
        record =>
          record.status === 'pending' &&
          record.path === normalizedPath &&
          record.mode === mode &&
          record.reason === reason &&
          record.requestedBy === requestedBy &&
          canonicalJson(record.metadata) === canonicalJson(metadata),
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
        prompt,
        metadata,
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

  /**
   * Finds an approved, unused escalation for this path/mode whose recorded args match
   * `args`, marks it consumed, and returns it. Returns undefined when none matches.
   */
  async consumeApproval(relativePath: string, mode: string, args: unknown): Promise<EscalationRecord | undefined> {
    return this.withLock(async () => {
      const state = await this.loadState();
      const normalizedPath = this.normalizePath(relativePath);
      const wanted = canonicalJson(args);

      const key = await this.loadKey(false);
      if (!key) {
        return undefined;
      }

      const now = Date.now();
      const record = state.records.find(
        item =>
          item.status === 'approved' &&
          !item.consumedAt &&
          !this.consumedIds.has(item.id) &&
          item.path === normalizedPath &&
          item.mode === mode &&
          canonicalJson(item.metadata?.args) === wanted &&
          this.isFresh(item.resolvedAt, now) &&
          this.hasValidSignature(item, key),
      );

      if (!record) {
        return undefined;
      }

      this.consumedIds.add(record.id);
      record.consumedAt = new Date(now).toISOString();
      await this.saveState(state);

      this.log('Consumed approved escalation', {
        systemSection: 'consume',
        details: { id: record.id, path: record.path, mode: record.mode },
      });

      return record;
    });
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
      if (status === 'approved') {
        // Only `npm run approve` reaches this branch; the MCP tool hard-codes 'denied'.
        const key = await this.loadKey(true);
        record.approvalSignature = this.sign(record, key!);
      }

      await this.saveState(state);

      this.log('Resolved escalation request', {
        systemSection: 'resolve',
        details: { id: record.id, status: record.status },
      });

      return record;
    });
  }

  private sign(record: EscalationRecord, key: Buffer): string {
    const payload = canonicalJson({
      id: record.id,
      path: record.path,
      mode: record.mode,
      args: record.metadata?.args ?? null,
      approvedAt: record.resolvedAt,
    });
    return createHmac('sha256', key).update(payload).digest('hex');
  }

  private hasValidSignature(record: EscalationRecord, key: Buffer): boolean {
    const given = Buffer.from(record.approvalSignature ?? '', 'utf8');
    const expected = Buffer.from(this.sign(record, key), 'utf8');
    return given.length === expected.length && timingSafeEqual(given, expected);
  }

  private isFresh(resolvedAt: string | undefined, now: number): boolean {
    const age = now - Date.parse(resolvedAt ?? '');
    return age >= -CLOCK_SKEW_MS && age <= APPROVAL_TTL_MS;
  }

  /**
   * Reads the 64-hex-char approval key. With `create`, makes one (mode 0600) when missing.
   * A file in any other format is rejected, so a Godot resource saved over it can't become a key.
   */
  private async loadKey(create: boolean): Promise<Buffer | undefined> {
    if (this.key) {
      return this.key;
    }

    let text: string | undefined;
    try {
      text = (await fs.readFile(this.keyPath, 'utf8')).trim();
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT' || !create) {
        return undefined;
      }
      await fs.mkdir(path.dirname(this.keyPath), { recursive: true, mode: 0o700 });
      text = randomBytes(32).toString('hex');
      await fs.writeFile(this.keyPath, `${text}\n`, { mode: 0o600, flag: 'wx' });
      this.log('Created approval key', { systemSection: 'key', details: { keyPath: this.keyPath } });
    }

    if (!KEY_FORMAT.test(text)) {
      this.log('Approval key has an invalid format; ignoring all approvals', {
        systemSection: 'key',
        error: true,
        details: { keyPath: this.keyPath },
      });
      if (create) {
        throw new Error(`Approval key at ${this.keyPath} is not 64 hex characters. Delete it to create a new one.`);
      }
      return undefined;
    }

    this.key = Buffer.from(text, 'hex');
    return this.key;
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
