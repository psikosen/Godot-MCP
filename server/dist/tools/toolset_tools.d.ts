import { MCPTool } from '../utils/types.js';
/**
 * load_tools turns tool groups, or single tools, on and off while the session runs. add/remove
 * change the server's tool list, which sends notifications/tools/list_changed so the client lists
 * the tools again. `enabled` is the live set of groups that are on; this tool changes it. A tool is
 * on while any of its groups is on or it was loaded by name, so unloading a group keeps tools
 * another loaded group still has.
 */
export declare function loadToolsTool(tools: MCPTool[], enabled: Set<string>, add: (tools: MCPTool[]) => Promise<void>, remove: (names: string[]) => Promise<void>): {
    tool: MCPTool;
    offToolsHint: (text: string) => string;
};
