export declare const TOOLSETS: string[];
export declare function toolsetOf(toolName: string): string;
/** Parses GODOT_MCP_TOOLSETS ("2d,animation" or "all"); unset means all. Returns null for all. */
export declare function enabledToolsets(value: string | undefined): Set<string> | null;
