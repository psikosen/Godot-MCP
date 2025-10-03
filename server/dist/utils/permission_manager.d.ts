import { CapabilityConfig } from './permission_config.js';
/**
 * Performs capability scoping checks for file write operations, ensuring
 * automated edits only touch approved directories or file types. This is the
 * first step toward the broader permission system tracked in the P0 roadmap.
 */
export declare class PermissionManager {
    private readonly config;
    constructor(config?: CapabilityConfig);
    /**
     * Throws when a file write would violate the allow/deny rules.
     */
    assertWriteAllowed(relativePath: string, mode: string): Promise<void>;
    private matchesRuleList;
    private matchesRule;
    private normalizeRule;
    private normalizePath;
    private log;
}
export declare const permissionManager: PermissionManager;
