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
type JsonSchema = Record<string, unknown>;
/**
 * Renames short parameter names AIs often use to the one parameter they can mean: path -> script_path,
 * type -> node_type, name -> node_name, group -> group_name, property_name -> property. Only when one parameter that is not
 * given fits, or one required one among several; longer names (node_path for path) are left alone, as
 * their prefix may mean something else.
 */
export declare function withShortNames(value: unknown, keys: string[], required?: string[]): unknown;
/** "a* string, mode on|off, size {x,y}|number[2]" from an object schema's properties. */
export declare function parameterList(json: JsonSchema): string;
export {};
