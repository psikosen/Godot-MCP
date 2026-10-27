import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
export declare const vector3: z.ZodUnion<[z.ZodObject<{
    x: z.ZodNumber;
    y: z.ZodNumber;
    z: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    x: number;
    y: number;
    z: number;
}, {
    x: number;
    y: number;
    z: number;
}>, z.ZodTuple<[z.ZodNumber, z.ZodNumber, z.ZodNumber], null>]>;
export declare const builderTools: MCPTool[];
