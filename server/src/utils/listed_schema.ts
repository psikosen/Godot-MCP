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
  const standard = schema['~standard'];
  const usage = parameterList(json);
  return {
    '~standard': {
      ...standard,
      jsonSchema: { input: () => json },
      // AIs call a tool they only know by name with {} (most eval errors were these); the error then
      // lists the parameters, so the retry is right without first loading the tool's schema.
      validate: async (value: unknown) => {
        const result = await standard.validate(withShortNames(value, Object.keys((json.properties ?? {}) as object), (json.required as string[] | undefined) ?? []));
        return result.issues && usage
          ? { issues: [...result.issues, { message: `this tool takes ${usage} (* = required)`, path: ['usage'] }] }
          : result;
      },
    },
  } as unknown as z.ZodType<T>;
}

type JsonSchema = Record<string, unknown>;

/**
 * Renames short parameter names AIs often use to the one parameter they can mean: path -> script_path,
 * type -> node_type, name -> node_name, property_name -> property. Only when one parameter that is not
 * given fits, or one required one among several; longer names (node_path for path) are left alone, as
 * their prefix may mean something else.
 */
export function withShortNames(value: unknown, keys: string[], required: string[] = []): unknown {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return value;
  const out: Record<string, unknown> = { ...(value as Record<string, unknown>) };
  for (const given of Object.keys(out)) {
    if (keys.includes(given)) continue;
    let fits = keys.filter(key => !(key in out) && (key.endsWith(`_${given}`) || given === `${key}_name`));
    if (fits.length > 1) fits = fits.filter(key => required.includes(key));
    if (fits.length !== 1) continue;
    out[fits[0]] = out[given];
    delete out[given];
  }
  return out;
}

/** "a* string, mode on|off, size {x,y}|number[2]" from an object schema's properties. */
export function parameterList(json: JsonSchema): string {
  const properties = (json.properties ?? {}) as Record<string, JsonSchema>;
  const required = new Set((json.required as string[] | undefined) ?? []);
  const label = (schema: JsonSchema): string => {
    const ref = schema.$ref as string | undefined;
    if (ref?.startsWith('#/properties/')) return label(properties[ref.slice('#/properties/'.length)] ?? {});
    const values = schema.enum as unknown[] | undefined;
    if (values && values.length <= 6) return values.join('|');
    if (schema.anyOf) return Array.from(new Set((schema.anyOf as JsonSchema[]).map(label))).join('|');
    if (schema.type === 'array') {
      const item = schema.items ? label(schema.items as JsonSchema) : 'value';
      const length = schema.minItems === schema.maxItems && schema.minItems ? schema.minItems : '';
      return `${item.includes('|') ? `(${item})` : item}[${length}]`;
    }
    if (schema.type === 'object' && schema.properties) return `{${Object.keys(schema.properties).join(',')}}`;
    return [schema.type ?? 'value'].flat().join('|');
  };
  return Object.entries(properties).map(([name, property]) => `${name}${required.has(name) ? '*' : ''} ${label(property)}`).join(', ');
}
