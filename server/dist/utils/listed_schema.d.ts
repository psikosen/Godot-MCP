import { z } from 'zod';
/**
 * Draft-07 tuples ("items": [a, b], from z.tuple) make Claude Code drop the whole tool without a
 * word; 68 of 260 tools (every vector2/vector3 parameter) were invisible there. List a tuple as an
 * array of n items instead; zod still checks each position when the tool is called.
 */
export declare function withoutTuples(node: unknown): unknown;
/**
 * The JSON schema clients see. FastMCP lists zod v3 schemas through zodToJsonSchema, which adds a
 * "$schema" key (about 13 tokens per tool, 3.4k for all 260) that no client needs, and writes
 * tuples that Claude Code rejects. Standard JSON Schema lets a schema hand FastMCP its own JSON
 * form, so this lists a cleaned copy; validation is unchanged.
 */
export declare function listedSchema<T>(schema: z.ZodType<T>): z.ZodType<T>;
