import { z } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

/**
 * Draft-07 tuples ("items": [a, b], from z.tuple) make Claude Code drop the whole tool without a
 * word; 68 of 260 tools (every vector2/vector3 parameter) were invisible there. List a tuple as an
 * array of n items instead; zod still checks each position when the tool is called.
 */
export function withoutTuples(node: unknown): unknown {
  if (Array.isArray(node)) return node.map(withoutTuples);
  if (!node || typeof node !== 'object') return node;
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(node)) out[key] = withoutTuples(value);
  if (Array.isArray(out.items)) {
    const items = out.items as unknown[];
    const same = items.every(item => JSON.stringify(item) === JSON.stringify(items[0]));
    out.items = same ? items[0] : { anyOf: items };
    out.minItems ??= items.length;
    out.maxItems ??= items.length;
    delete out.additionalItems;
  }
  return out;
}

/**
 * The JSON schema clients see. FastMCP lists zod v3 schemas through zodToJsonSchema, which adds a
 * "$schema" key (about 13 tokens per tool, 3.4k for all 260) that no client needs, and writes
 * tuples that Claude Code rejects. Standard JSON Schema lets a schema hand FastMCP its own JSON
 * form, so this lists a cleaned copy; validation is unchanged.
 */
export function listedSchema<T>(schema: z.ZodType<T>): z.ZodType<T> {
  const { $schema, ...json } = withoutTuples(zodToJsonSchema(schema)) as Record<string, unknown>;
  return { '~standard': { ...schema['~standard'], jsonSchema: { input: () => json } } } as unknown as z.ZodType<T>;
}
