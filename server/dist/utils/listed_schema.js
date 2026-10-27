var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
import { zodToJsonSchema } from 'zod-to-json-schema';
/**
 * Draft-07 tuples ("items": [a, b], from z.tuple) make Claude Code drop the whole tool without a
 * word; 68 of 260 tools (every vector2/vector3 parameter) were invisible there. List a tuple as an
 * array of n items instead; zod still checks each position when the tool is called.
 */
export function withoutTuples(node) {
    var _a, _b;
    if (Array.isArray(node))
        return node.map(withoutTuples);
    if (!node || typeof node !== 'object')
        return node;
    var out = {};
    for (var _i = 0, _c = Object.entries(node); _i < _c.length; _i++) {
        var _d = _c[_i], key = _d[0], value = _d[1];
        out[key] = withoutTuples(value);
    }
    if (Array.isArray(out.items)) {
        var items_1 = out.items;
        var same = items_1.every(function (item) { return JSON.stringify(item) === JSON.stringify(items_1[0]); });
        out.items = same ? items_1[0] : { anyOf: items_1 };
        (_a = out.minItems) !== null && _a !== void 0 ? _a : (out.minItems = items_1.length);
        (_b = out.maxItems) !== null && _b !== void 0 ? _b : (out.maxItems = items_1.length);
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
export function listedSchema(schema) {
    var _a = withoutTuples(zodToJsonSchema(schema)), $schema = _a.$schema, json = __rest(_a, ["$schema"]);
    return { '~standard': __assign(__assign({}, schema['~standard']), { jsonSchema: { input: function () { return json; } } }) };
}
//# sourceMappingURL=listed_schema.js.map