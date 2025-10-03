import { CapabilityRole, MCPTool } from '../utils/types.js';
type RequestEscalationParams = {
    tool_name: string;
    justification: string;
    requested_role?: CapabilityRole;
};
export declare const securityTools: MCPTool<RequestEscalationParams>[];
export {};
