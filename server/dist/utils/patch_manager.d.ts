export interface PatchPreviewResult {
    patchId: string;
    files: Array<{
        path: string;
        mode: 'modify' | 'create' | 'delete';
        originalSize: number;
        patchedSize: number;
    }>;
}
export interface PatchApplyResult {
    patchId: string;
    appliedFiles: Array<{
        path: string;
        mode: 'modify' | 'create' | 'delete';
    }>;
}
/**
 * Manages preview, application, and cancellation of unified diff patches with
 * atomic file writes and rollback semantics.
 */
export declare class PatchManager {
    private readonly projectRoot;
    private readonly sessions;
    private readonly lockedPaths;
    constructor(projectRoot?: string);
    /**
     * Registers a diff for preview, returning a patch identifier if the diff
     * applies cleanly against the current working tree.
     */
    preview(diffText: string): Promise<PatchPreviewResult>;
    /**
     * Applies a previously previewed patch atomically. If any file fails to
     * update, all changes are rolled back.
     */
    apply(patchId: string): Promise<PatchApplyResult>;
    /**
     * Cancels a previewed patch without applying it.
     */
    cancel(patchId: string): void;
    private prepareFilePlan;
    private determineMode;
    private ensureDirectory;
    private writeAtomic;
    private safeCleanup;
    private readOriginalContent;
    private resolvePatchPath;
    private fileExists;
    private rollback;
    private acquireLocks;
    private releaseLocks;
    private ensurePathWithinProject;
    private logEvent;
}
export declare const patchManager: PatchManager;
