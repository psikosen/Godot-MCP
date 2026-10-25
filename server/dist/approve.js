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
import os from 'node:os';
import { escalationManager } from './utils/escalation_manager.js';
/**
 * Human-only approval of permission escalations. MCP clients cannot approve their own
 * requests (resolve_permission_escalation can only deny), so approval happens here.
 *
 *   npm run approve                    list pending escalations
 *   npm run approve -- <id> [notes]    approve one escalation (single use)
 */
// ponytail: plain read-modify-write of the JSON file; a server write landing in the same
// millisecond can drop one change. Add a file lock if approvals ever race in practice.
function main() {
    return __awaiter(this, void 0, void 0, function () {
        var _a, id, notes, pending_2, _i, pending_1, record_1, record;
        var _b, _c, _d;
        return __generator(this, function (_e) {
            switch (_e.label) {
                case 0:
                    _a = process.argv.slice(2), id = _a[0], notes = _a.slice(1);
                    if (!!id) return [3 /*break*/, 2];
                    return [4 /*yield*/, escalationManager.listEscalations({ status: 'pending' })];
                case 1:
                    pending_2 = _e.sent();
                    console.log("".concat(pending_2.length, " pending escalation(s) in ").concat(escalationManager.filePath));
                    for (_i = 0, pending_1 = pending_2; _i < pending_1.length; _i++) {
                        record_1 = pending_1[_i];
                        console.log("\n".concat(record_1.id, "  ").concat(record_1.path, "  (").concat(record_1.mode, ", requested ").concat(record_1.requestedAt, ")"));
                        console.log("  args: ".concat(JSON.stringify((_d = (_c = (_b = record_1.metadata) === null || _b === void 0 ? void 0 : _b.args) !== null && _c !== void 0 ? _c : record_1.metadata) !== null && _d !== void 0 ? _d : {})));
                    }
                    console.log('\nApprove one with: npm run approve -- <id> [notes]');
                    return [2 /*return*/];
                case 2: return [4 /*yield*/, escalationManager.resolveEscalation({
                        id: id,
                        status: 'approved',
                        resolver: os.userInfo().username,
                        notes: notes.join(' ') || undefined,
                    })];
                case 3:
                    record = _e.sent();
                    if (record.status !== 'approved') {
                        console.log("Escalation ".concat(id, " was already ").concat(record.status, "; nothing changed."));
                        process.exitCode = 1;
                        return [2 /*return*/];
                    }
                    console.log("Approved ".concat(record.id, " (").concat(record.path, "). The client can now retry that exact call once."));
                    return [2 /*return*/];
            }
        });
    });
}
main().catch(function (error) {
    console.error(error.message);
    process.exitCode = 1;
});
//# sourceMappingURL=approve.js.map