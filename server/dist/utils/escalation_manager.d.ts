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
export declare class EscalationManager {
    private readonly storagePath;
    private queue;
    constructor(storagePath?: string);
    recordEscalation({ path: relativePath, mode, reason, requestedBy }: RecordEscalationInput): Promise<EscalationRecord>;
    listEscalations(options?: ListOptions): Promise<EscalationRecord[]>;
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
