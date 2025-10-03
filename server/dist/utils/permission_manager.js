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
import path from 'node:path';
import { defaultCapabilityConfig } from './permission_config.js';
import { escalationManager } from './escalation_manager.js';
/**
 * Performs capability scoping checks for file write operations, ensuring
 * automated edits only touch approved directories or file types. This is the
 * first step toward the broader permission system tracked in the P0 roadmap.
 */
var PermissionManager = /** @class */ (function () {
    function PermissionManager(config) {
        if (config === void 0) { config = defaultCapabilityConfig; }
        var _this = this;
        this.config = {
            writeAllow: config.writeAllow.map(function (rule) { return _this.normalizeRule(rule); }),
            writeDeny: config.writeDeny.map(function (rule) { return _this.normalizeRule(rule); }),
        };
    }
    /**
     * Throws when a file write would violate the allow/deny rules.
     */
    PermissionManager.prototype.assertWriteAllowed = function (relativePath, mode) {
        return __awaiter(this, void 0, void 0, function () {
            var normalized, escalation;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        normalized = this.normalizePath(relativePath);
                        if (this.matchesRuleList(normalized, this.config.writeDeny)) {
                            this.log('Permission denied by deny rule', {
                                systemSection: 'capability_check',
                                error: true,
                                details: { relativePath: normalized, mode: mode, ruleSet: 'deny' },
                            });
                            throw new Error("Write access to ".concat(normalized, " is denied by capability policy."));
                        }
                        if (this.matchesRuleList(normalized, this.config.writeAllow)) {
                            this.log('Permission granted', {
                                systemSection: 'capability_check',
                                details: { relativePath: normalized, mode: mode },
                            });
                            return [2 /*return*/];
                        }
                        return [4 /*yield*/, escalationManager.recordEscalation({
                                path: normalized,
                                mode: mode,
                                reason: 'not_allowlisted',
                                requestedBy: 'permission_manager',
                            })];
                    case 1:
                        escalation = _a.sent();
                        this.log('Permission requires escalation', {
                            systemSection: 'capability_check',
                            error: true,
                            details: { relativePath: normalized, mode: mode, ruleSet: 'allow', escalationId: escalation.id },
                        });
                        throw new Error("Write access to ".concat(normalized, " is not in the allowlist. Escalation required (id: ").concat(escalation.id, ")."));
                }
            });
        });
    };
    PermissionManager.prototype.matchesRuleList = function (relativePath, rules) {
        var _this = this;
        return rules.some(function (rule) { return _this.matchesRule(relativePath, rule); });
    };
    PermissionManager.prototype.matchesRule = function (relativePath, rule) {
        if (rule.type === 'directory') {
            return relativePath === rule.value || relativePath.startsWith("".concat(rule.value, "/"));
        }
        if (rule.type === 'file') {
            return relativePath === rule.value;
        }
        if (rule.type === 'extension') {
            return relativePath.endsWith(rule.value);
        }
        return false;
    };
    PermissionManager.prototype.normalizeRule = function (rule) {
        if (rule.type === 'extension') {
            return rule;
        }
        return __assign(__assign({}, rule), { value: this.normalizePath(rule.value) });
    };
    PermissionManager.prototype.normalizePath = function (input) {
        var normalized = path.posix.normalize(input.replace(/\\/g, '/'));
        return normalized.startsWith('./') ? normalized.slice(2) : normalized;
    };
    PermissionManager.prototype.log = function (message, _a) {
        var systemSection = _a.systemSection, details = _a.details, _b = _a.error, error = _b === void 0 ? false : _b;
        var logEntry = __assign({ filename: 'server/src/utils/permission_manager.ts', timestamp: new Date().toISOString(), classname: 'PermissionManager', function: 'assertWriteAllowed', system_section: systemSection, line_num: 0, error: error, db_phase: 'none', method: 'NONE', message: message }, (details ? { details: details } : {}));
        console.error(JSON.stringify(logEntry));
        console.error("[Continuous skepticism (Sherlock Protocol)] ".concat(message));
    };
    return PermissionManager;
}());
export { PermissionManager };
export var permissionManager = new PermissionManager();
//# sourceMappingURL=permission_manager.js.map