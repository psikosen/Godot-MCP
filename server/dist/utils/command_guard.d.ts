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
export declare class CommandGuard {
    private readonly policy;
    constructor(policy?: CommandPolicyConfig);
    assertAllowed<T>(tool: MCPTool<T>, args: T): Promise<void>;
    private log;
}
export declare const commandGuard: CommandGuard;
export {};
