export type ProjectIndexEntryType = 'file' | 'directory';
export interface ProjectIndexEntry {
    path: string;
    type: ProjectIndexEntryType;
    size: number;
    modified: string;
    extension?: string;
    children?: string[];
}
export interface ProjectIndexSnapshot {
    generatedAt: string;
    projectRoot: string;
    root: string[];
    entries: Record<string, ProjectIndexEntry>;
    stats: {
        files: number;
        directories: number;
        totalSize: number;
        skipped: string[];
        truncated: boolean;
    };
}
interface QueryOptions {
    includeDirectories?: boolean;
    limit?: number;
}
/**
 * Builds and caches a structural index of the Godot project to support
 * high-level queries from MCP tools. The index intentionally mirrors the
 * capability guardrails by skipping transient or high-churn directories.
 */
export declare class ProjectIndexer {
    private readonly projectRoot;
    private cache;
    private building;
    constructor(projectRoot?: string);
    /**
     * Returns the cached snapshot or rebuilds it when missing or forced.
     */
    getIndex(forceRefresh?: boolean): Promise<ProjectIndexSnapshot>;
    /**
     * Forces a rebuild and returns the latest snapshot.
     */
    refresh(): Promise<ProjectIndexSnapshot>;
    /**
     * Queries the cached snapshot using glob-like path patterns.
     */
    query(patterns: string[], options?: QueryOptions): Promise<ProjectIndexEntry[]>;
    private buildSnapshot;
    private scanDirectory;
    private createFileEntry;
    private shouldSkip;
    private normalizePath;
    private globToRegExp;
    private log;
}
export declare const projectIndexer: ProjectIndexer;
export {};
