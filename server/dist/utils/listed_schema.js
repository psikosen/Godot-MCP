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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
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
    var _this = this;
    var _a = withoutTuples(zodToJsonSchema(schema)), $schema = _a.$schema, json = __rest(_a, ["$schema"]);
    var standard = schema['~standard'];
    var usage = parameterList(json);
    return {
        '~standard': __assign(__assign({}, standard), { jsonSchema: { input: function () { return json; } }, 
            // AIs call a tool they only know by name with {} (most eval errors were these); the error then
            // lists the parameters, so the retry is right without first loading the tool's schema.
            validate: function (value) { return __awaiter(_this, void 0, void 0, function () {
                var result;
                var _a, _b;
                return __generator(this, function (_c) {
                    switch (_c.label) {
                        case 0: return [4 /*yield*/, standard.validate(withShortNames(value, Object.keys(((_a = json.properties) !== null && _a !== void 0 ? _a : {})), (_b = json.required) !== null && _b !== void 0 ? _b : []))];
                        case 1:
                            result = _c.sent();
                            return [2 /*return*/, result.issues && usage
                                    ? { issues: __spreadArray(__spreadArray([], result.issues, true), [{ message: "this tool takes ".concat(usage, " (* = required)"), path: ['usage'] }], false) }
                                    : result];
                    }
                });
            }); } }),
    };
}
/**
 * Renames short parameter names AIs often use to the one parameter they can mean: path -> script_path,
 * type -> node_type, name -> node_name, property_name -> property. Only when one parameter that is not
 * given fits, or one required one among several; longer names (node_path for path) are left alone, as
 * their prefix may mean something else.
 */
export function withShortNames(value, keys, required) {
    if (required === void 0) { required = []; }
    if (!value || typeof value !== 'object' || Array.isArray(value))
        return value;
    var out = __assign({}, value);
    var _loop_1 = function (given) {
        if (keys.includes(given))
            return "continue";
        var fits = keys.filter(function (key) { return !(key in out) && (key.endsWith("_".concat(given)) || given === "".concat(key, "_name")); });
        if (fits.length > 1)
            fits = fits.filter(function (key) { return required.includes(key); });
        if (fits.length !== 1)
            return "continue";
        out[fits[0]] = out[given];
        delete out[given];
    };
    for (var _i = 0, _a = Object.keys(out); _i < _a.length; _i++) {
        var given = _a[_i];
        _loop_1(given);
    }
    return out;
}
/** "a* string, mode on|off, size {x,y}|number[2]" from an object schema's properties. */
export function parameterList(json) {
    var _a, _b;
    var properties = ((_a = json.properties) !== null && _a !== void 0 ? _a : {});
    var required = new Set((_b = json.required) !== null && _b !== void 0 ? _b : []);
    var label = function (schema) {
        var _a, _b;
        var ref = schema.$ref;
        if (ref === null || ref === void 0 ? void 0 : ref.startsWith('#/properties/'))
            return label((_a = properties[ref.slice('#/properties/'.length)]) !== null && _a !== void 0 ? _a : {});
        var values = schema.enum;
        if (values && values.length <= 6)
            return values.join('|');
        if (schema.anyOf)
            return Array.from(new Set(schema.anyOf.map(label))).join('|');
        if (schema.type === 'array') {
            var item = schema.items ? label(schema.items) : 'value';
            var length_1 = schema.minItems === schema.maxItems && schema.minItems ? schema.minItems : '';
            return "".concat(item.includes('|') ? "(".concat(item, ")") : item, "[").concat(length_1, "]");
        }
        if (schema.type === 'object' && schema.properties)
            return "{".concat(Object.keys(schema.properties).join(','), "}");
        return [(_b = schema.type) !== null && _b !== void 0 ? _b : 'value'].flat().join('|');
    };
    return Object.entries(properties).map(function (_a) {
        var name = _a[0], property = _a[1];
        return "".concat(name).concat(required.has(name) ? '*' : '', " ").concat(label(property));
    }).join(', ');
}
//# sourceMappingURL=listed_schema.js.map