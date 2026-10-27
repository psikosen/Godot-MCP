export declare const TASK_GROUPS: Array<[string, Set<string> | RegExp, string]>;
export declare const TOOLSETS: string[];
/** The tool's main group: core, or the first rule it matches. */
export declare function toolsetOf(toolName: string): string;
/** Every group the tool is in: its main group, then the task groups that list it. */
export declare function groupsOf(toolName: string): string[];
/** The load_tools menu, one line per group: "- physics (10): bodies, areas, ...". */
export declare function toolsetMenu(counts: Map<string, number>): string;
/** Parses GODOT_MCP_TOOLSETS ("2d,animation" or "all"). Unset means core only. Returns null for all. */
export declare function enabledToolsets(value: string | undefined): Set<string> | null;
