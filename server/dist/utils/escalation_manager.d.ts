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
/**
 * Persists permission escalation requests so that humans can review and
 * resolve them outside of the automated patch workflow.
 */
export declare class EscalationManager {
    private readonly storagePath;
    private queue;
    constructor(storagePath?: string);
    get filePath(): string;
    recordEscalation({ path: relativePath, mode, reason, requestedBy, prompt, metadata, }: RecordEscalationInput): Promise<EscalationRecord>;
    listEscalations(options?: ListOptions): Promise<EscalationRecord[]>;
    /**
     * Finds an approved, unused escalation for this path/mode whose recorded args match
     * `args`, marks it consumed, and returns it. Returns undefined when none matches.
     */
    consumeApproval(relativePath: string, mode: string, args: unknown): Promise<EscalationRecord | undefined>;
    resolveEscalation({ id, status, resolver, notes }: ResolveEscalationInput): Promise<EscalationRecord>;
    private withLock;
    private loadState;
    private saveState;
    private ensureDirectory;
    private normalizePath;
    private log;
}
export declare const escalationManager: EscalationManager;
export {};
