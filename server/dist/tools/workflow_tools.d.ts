import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
export declare const vector2: z.ZodUnion<[z.ZodObject<{
    x: z.ZodNumber;
    y: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    x: number;
    y: number;
}, {
    x: number;
    y: number;
}>, z.ZodTuple<[z.ZodNumber, z.ZodNumber], null>]>;
export declare const send: (command: string, params: Record<string, unknown>) => Promise<CommandResult>;
export declare const fail: (what: string, error: unknown) => never;
export declare function runGodot(executable: string, args: string[], timeoutMs: number): Promise<{
    code: number | string | null;
    output: string;
}>;
export declare const godotProblems: (output: string, limit?: number) => string[];
export declare const workflowTools: MCPTool[];
