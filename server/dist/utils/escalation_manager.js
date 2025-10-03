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
import { promises as fs } from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
/**
 * Persists permission escalation requests so that humans can review and
 * resolve them outside of the automated patch workflow.
 */
var EscalationManager = /** @class */ (function () {
    function EscalationManager(storagePath) {
        this.queue = Promise.resolve();
        this.storagePath =
            storagePath !== null && storagePath !== void 0 ? storagePath : path.resolve(process.cwd(), '..', 'project-manager', 'permission_escalations.json');
    }
    EscalationManager.prototype.recordEscalation = function (_a) {
        return __awaiter(this, arguments, void 0, function (_b) {
            var _this = this;
            var relativePath = _b.path, mode = _b.mode, reason = _b.reason, requestedBy = _b.requestedBy;
            return __generator(this, function (_c) {
                return [2 /*return*/, this.withLock(function () { return __awaiter(_this, void 0, void 0, function () {
                        var state, normalizedPath, existing, record;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, this.loadState()];
                                case 1:
                                    state = _a.sent();
                                    normalizedPath = this.normalizePath(relativePath);
                                    existing = state.records.find(function (record) { return record.status === 'pending' && record.path === normalizedPath && record.mode === mode && record.reason === reason; });
                                    if (existing) {
                                        this.log('Escalation already pending', {
                                            systemSection: 'record',
                                            details: { id: existing.id, path: existing.path, mode: existing.mode, reason: existing.reason },
                                        });
                                        return [2 /*return*/, existing];
                                    }
                                    record = {
                                        id: randomUUID(),
                                        path: normalizedPath,
                                        mode: mode,
                                        reason: reason,
                                        requestedBy: requestedBy,
                                        requestedAt: new Date().toISOString(),
                                        status: 'pending',
                                    };
                                    state.records.push(record);
                                    return [4 /*yield*/, this.saveState(state)];
                                case 2:
                                    _a.sent();
                                    this.log('Recorded new escalation request', {
                                        systemSection: 'record',
                                        details: { id: record.id, path: record.path, mode: record.mode, reason: record.reason },
                                    });
                                    return [2 /*return*/, record];
                            }
                        });
                    }); })];
            });
        });
    };
    EscalationManager.prototype.listEscalations = function () {
        return __awaiter(this, arguments, void 0, function (options) {
            var state, statusFilter, records;
            if (options === void 0) { options = {}; }
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.queue];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, this.loadState()];
                    case 2:
                        state = _a.sent();
                        statusFilter = options.status;
                        records = statusFilter ? state.records.filter(function (record) { return record.status === statusFilter; }) : state.records;
                        this.log('Listed escalation requests', {
                            systemSection: 'list',
                            details: { total: records.length, status: statusFilter !== null && statusFilter !== void 0 ? statusFilter : 'all' },
                        });
                        return [2 /*return*/, records.sort(function (a, b) { return a.requestedAt.localeCompare(b.requestedAt); })];
                }
            });
        });
    };
    EscalationManager.prototype.resolveEscalation = function (_a) {
        return __awaiter(this, arguments, void 0, function (_b) {
            var _this = this;
            var id = _b.id, status = _b.status, resolver = _b.resolver, notes = _b.notes;
            return __generator(this, function (_c) {
                if (status === 'pending') {
                    throw new Error('Cannot resolve escalation to pending state.');
                }
                return [2 /*return*/, this.withLock(function () { return __awaiter(_this, void 0, void 0, function () {
                        var state, record;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, this.loadState()];
                                case 1:
                                    state = _a.sent();
                                    record = state.records.find(function (item) { return item.id === id; });
                                    if (!record) {
                                        this.log('Attempted to resolve missing escalation', {
                                            systemSection: 'resolve',
                                            error: true,
                                            details: { id: id },
                                        });
                                        throw new Error("Escalation request ".concat(id, " was not found."));
                                    }
                                    if (record.status !== 'pending') {
                                        this.log('Escalation already resolved', {
                                            systemSection: 'resolve',
                                            details: { id: record.id, status: record.status },
                                        });
                                        return [2 /*return*/, record];
                                    }
                                    record.status = status;
                                    record.resolvedAt = new Date().toISOString();
                                    record.resolver = resolver;
                                    record.notes = notes;
                                    return [4 /*yield*/, this.saveState(state)];
                                case 2:
                                    _a.sent();
                                    this.log('Resolved escalation request', {
                                        systemSection: 'resolve',
                                        details: { id: record.id, status: record.status },
                                    });
                                    return [2 /*return*/, record];
                            }
                        });
                    }); })];
            });
        });
    };
    EscalationManager.prototype.withLock = function (fn) {
        return __awaiter(this, void 0, void 0, function () {
            var run, next;
            var _this = this;
            return __generator(this, function (_a) {
                run = function () { return __awaiter(_this, void 0, void 0, function () { return __generator(this, function (_a) {
                    return [2 /*return*/, fn()];
                }); }); };
                next = this.queue.then(run, run);
                this.queue = next.then(function () { return undefined; }, function () { return undefined; });
                return [2 /*return*/, next];
            });
        });
    };
    EscalationManager.prototype.loadState = function () {
        return __awaiter(this, void 0, void 0, function () {
            var raw, parsed, error_1, err;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, fs.readFile(this.storagePath, 'utf8')];
                    case 1:
                        raw = _a.sent();
                        parsed = JSON.parse(raw);
                        return [2 /*return*/, parsed.records ? parsed : { records: [] }];
                    case 2:
                        error_1 = _a.sent();
                        err = error_1;
                        if (err.code === 'ENOENT') {
                            return [2 /*return*/, { records: [] }];
                        }
                        this.log("Failed to load escalation state: ".concat(err.message), {
                            systemSection: 'load',
                            error: true,
                        });
                        return [2 /*return*/, { records: [] }];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    EscalationManager.prototype.saveState = function (state) {
        return __awaiter(this, void 0, void 0, function () {
            var serialized;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.ensureDirectory()];
                    case 1:
                        _a.sent();
                        serialized = "".concat(JSON.stringify(state, null, 2), "\n");
                        return [4 /*yield*/, fs.writeFile(this.storagePath, serialized, 'utf8')];
                    case 2:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    EscalationManager.prototype.ensureDirectory = function () {
        return __awaiter(this, void 0, void 0, function () {
            var dir;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        dir = path.dirname(this.storagePath);
                        return [4 /*yield*/, fs.mkdir(dir, { recursive: true })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    EscalationManager.prototype.normalizePath = function (input) {
        var normalized = path.posix.normalize(input.replace(/\\/g, '/'));
        return normalized.startsWith('./') ? normalized.slice(2) : normalized;
    };
    EscalationManager.prototype.log = function (message, _a) {
        var systemSection = _a.systemSection, _b = _a.error, error = _b === void 0 ? false : _b, details = _a.details;
        var logEntry = __assign({ filename: 'server/src/utils/escalation_manager.ts', timestamp: new Date().toISOString(), classname: 'EscalationManager', function: systemSection, system_section: systemSection, line_num: 0, error: error, db_phase: 'none', method: 'NONE', message: message }, (details ? { details: details } : {}));
        console.error(JSON.stringify(logEntry));
        console.error("[Continuous skepticism (Sherlock Protocol)] ".concat(message));
    };
    return EscalationManager;
}());
export { EscalationManager };
export var escalationManager = new EscalationManager();
//# sourceMappingURL=escalation_manager.js.map