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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
import { z } from 'zod';
import { escalationManager } from '../utils/escalation_manager.js';
var statusEnum = z.enum(['pending', 'approved', 'denied']);
export var permissionTools = [
    {
        name: 'list_permission_escalations',
        description: 'List permission escalation requests, newest first, optionally filtered by status.',
        parameters: z.object({
            status: statusEnum
                .optional()
                .describe('Filter results to a specific status (pending, approved, denied).'),
            limit: z.number().int().min(1).max(500).default(20).describe('Most requests to show (default 20).'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var records, shown, lines, hidden;
            var status = _b.status, _c = _b.limit, limit = _c === void 0 ? 20 : _c;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0: return [4 /*yield*/, escalationManager.listEscalations({ status: status })];
                    case 1:
                        records = _d.sent();
                        if (records.length === 0)
                            return [2 /*return*/, status ? "No ".concat(status, " escalation requests.") : 'No escalation requests.'];
                        shown = records.slice(-limit).reverse();
                        lines = shown.map(function (record) {
                            var _a, _b;
                            var args = JSON.stringify((_b = (_a = record.metadata) === null || _a === void 0 ? void 0 : _a.args) !== null && _b !== void 0 ? _b : {});
                            return "- ".concat(record.id, " ").concat(record.status, " ").concat(record.path.replace(/^tool:/, ''), " ").concat(record.requestedAt, " ").concat(args.length > 80 ? "".concat(args.slice(0, 80), "\u2026") : args);
                        });
                        hidden = records.length - shown.length;
                        return [2 /*return*/, __spreadArray(__spreadArray([
                                "Escalation requests (".concat(records.length, ", newest first").concat(hidden ? "; ".concat(hidden, " older not shown, raise limit") : '', "):")
                            ], lines, true), (shown.some(function (record) { return record.status === 'pending'; }) ? ['A human approves with: cd server && npm run approve -- <id>'] : []), true).join('\n')];
                }
            });
        }); },
        metadata: {
            requiredRole: 'read',
        },
    },
    {
        name: 'resolve_permission_escalation',
        description: 'Deny (withdraw) a pending permission escalation request. This tool cannot approve: ' +
            'approval is human-only and signed (cd server && npm run approve -- <id>).',
        parameters: z.object({
            escalation_id: z.string().describe('Identifier returned when the escalation was recorded.'),
            status: z.literal('denied').default('denied')
                .describe('Only "denied" is accepted. A human approves outside MCP.'),
            resolver: z.string().optional().describe('Who resolved the escalation (for audit trail).'),
            notes: z.string().optional().describe('Optional notes explaining the decision.'),
        }),
        execute: function (_a) { return __awaiter(void 0, [_a], void 0, function (_b) {
            var record;
            var escalation_id = _b.escalation_id, resolver = _b.resolver, notes = _b.notes;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0: return [4 /*yield*/, escalationManager.resolveEscalation({
                            id: escalation_id,
                            status: 'denied',
                            resolver: resolver,
                            notes: notes,
                        })];
                    case 1:
                        record = _c.sent();
                        return [2 /*return*/, JSON.stringify({
                                escalation_id: record.id,
                                status: record.status,
                                resolved_at: record.resolvedAt,
                                resolver: record.resolver,
                                notes: record.notes,
                                prompt: record.prompt,
                                metadata: record.metadata,
                            })];
                }
            });
        }); },
        metadata: {
            // Denying only removes access, so it needs no escalation (an 'admin' role here escalated itself forever).
            requiredRole: 'edit',
        },
    },
];
//# sourceMappingURL=permission_tools.js.map