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
var _a;
import { promises as fs } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHmac, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { fileURLToPath } from 'node:url';
// Key-order-independent JSON, so a hand-edited record still matches the same args.
var canonicalJson = function (value) {
    var _a;
    return (_a = JSON.stringify(value, function (_key, v) {
        return v && typeof v === 'object' && !Array.isArray(v)
            ? Object.fromEntries(Object.entries(v).sort(function (_a, _b) {
                var a = _a[0];
                var b = _b[0];
                return a.localeCompare(b);
            }))
            : v;
    })) !== null && _a !== void 0 ? _a : '';
};
/**
 * Default store: <repo>/project-manager/permission_escalations.json, resolved from this
 * module (src/utils or dist/utils) so the server and the approve CLI share one file no
 * matter which directory the MCP client launches the server from.
 */
var defaultStoragePath = fileURLToPath(new URL('../../../project-manager/permission_escalations.json', import.meta.url));
/**
 * The escalation store lives inside the Godot project, so Godot tools can rewrite it.
 * Approvals are therefore signed with a key kept outside the project; the store alone
 * can never grant anything.
 */
var defaultKeyPath = (_a = process.env.GODOT_MCP_APPROVAL_KEY_PATH) !== null && _a !== void 0 ? _a : path.join(os.homedir(), '.config', 'godot-mcp', 'approval.key');
var KEY_FORMAT = /^[0-9a-f]{64}$/;
/** Signed approvals expire, which bounds replay if someone strips consumedAt from the file. */
export var APPROVAL_TTL_MS = 10 * 60 * 1000;
var CLOCK_SKEW_MS = 60 * 1000;
/**
 * Persists permission escalation requests so that humans can review and
 * resolve them outside of the automated patch workflow.
 */
var EscalationManager = /** @class */ (function () {
    function EscalationManager(storagePath, keyPath) {
        if (keyPath === void 0) { keyPath = defaultKeyPath; }
        this.queue = Promise.resolve();
        // Survives a rollback of consumedAt in the file (until restart; the TTL covers the rest).
        this.consumedIds = new Set();
        this.storagePath = storagePath !== null && storagePath !== void 0 ? storagePath : defaultStoragePath;
        this.keyPath = keyPath;
    }
    Object.defineProperty(EscalationManager.prototype, "filePath", {
        get: function () {
            return this.storagePath;
        },
        enumerable: false,
        configurable: true
    });
    EscalationManager.prototype.recordEscalation = function (_a) {
        return __awaiter(this, arguments, void 0, function (_b) {
            var _this = this;
            var relativePath = _b.path, mode = _b.mode, reason = _b.reason, requestedBy = _b.requestedBy, prompt = _b.prompt, metadata = _b.metadata;
            return __generator(this, function (_c) {
                return [2 /*return*/, this.withLock(function () { return __awaiter(_this, void 0, void 0, function () {
                        var state, normalizedPath, existing, record;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, this.loadState()];
                                case 1:
                                    state = _a.sent();
                                    normalizedPath = this.normalizePath(relativePath);
                                    existing = state.records.find(function (record) {
                                        return record.status === 'pending' &&
                                            record.path === normalizedPath &&
                                            record.mode === mode &&
                                            record.reason === reason &&
                                            record.requestedBy === requestedBy &&
                                            canonicalJson(record.metadata) === canonicalJson(metadata);
                                    });
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
                                        prompt: prompt,
                                        metadata: metadata,
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
    /**
     * Finds an approved, unused escalation for this path/mode whose recorded args match
     * `args`, marks it consumed, and returns it. Returns undefined when none matches.
     */
    EscalationManager.prototype.consumeApproval = function (relativePath, mode, args) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, this.withLock(function () { return __awaiter(_this, void 0, void 0, function () {
                        var state, normalizedPath, wanted, key, now, record;
                        var _this = this;
                        return __generator(this, function (_a) {
                            switch (_a.label) {
                                case 0: return [4 /*yield*/, this.loadState()];
                                case 1:
                                    state = _a.sent();
                                    normalizedPath = this.normalizePath(relativePath);
                                    wanted = canonicalJson(args);
                                    return [4 /*yield*/, this.loadKey(false)];
                                case 2:
                                    key = _a.sent();
                                    if (!key) {
                                        return [2 /*return*/, undefined];
                                    }
                                    now = Date.now();
                                    record = state.records.find(function (item) {
                                        var _a;
                                        return item.status === 'approved' &&
                                            !item.consumedAt &&
                                            !_this.consumedIds.has(item.id) &&
                                            item.path === normalizedPath &&
                                            item.mode === mode &&
                                            canonicalJson((_a = item.metadata) === null || _a === void 0 ? void 0 : _a.args) === wanted &&
                                            _this.isFresh(item.resolvedAt, now) &&
                                            _this.hasValidSignature(item, key);
                                    });
                                    if (!record) {
                                        return [2 /*return*/, undefined];
                                    }
                                    this.consumedIds.add(record.id);
                                    record.consumedAt = new Date(now).toISOString();
                                    return [4 /*yield*/, this.saveState(state)];
                                case 3:
                                    _a.sent();
                                    this.log('Consumed approved escalation', {
                                        systemSection: 'consume',
                                        details: { id: record.id, path: record.path, mode: record.mode },
                                    });
                                    return [2 /*return*/, record];
                            }
                        });
                    }); })];
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
                        var state, record, key;
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
                                    if (!(status === 'approved')) return [3 /*break*/, 3];
                                    return [4 /*yield*/, this.loadKey(true)];
                                case 2:
                                    key = _a.sent();
                                    record.approvalSignature = this.sign(record, key);
                                    _a.label = 3;
                                case 3: return [4 /*yield*/, this.saveState(state)];
                                case 4:
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
    EscalationManager.prototype.sign = function (record, key) {
        var _a, _b;
        var payload = canonicalJson({
            id: record.id,
            path: record.path,
            mode: record.mode,
            args: (_b = (_a = record.metadata) === null || _a === void 0 ? void 0 : _a.args) !== null && _b !== void 0 ? _b : null,
            approvedAt: record.resolvedAt,
        });
        return createHmac('sha256', key).update(payload).digest('hex');
    };
    EscalationManager.prototype.hasValidSignature = function (record, key) {
        var _a;
        var given = Buffer.from((_a = record.approvalSignature) !== null && _a !== void 0 ? _a : '', 'utf8');
        var expected = Buffer.from(this.sign(record, key), 'utf8');
        return given.length === expected.length && timingSafeEqual(given, expected);
    };
    EscalationManager.prototype.isFresh = function (resolvedAt, now) {
        var age = now - Date.parse(resolvedAt !== null && resolvedAt !== void 0 ? resolvedAt : '');
        return age >= -CLOCK_SKEW_MS && age <= APPROVAL_TTL_MS;
    };
    /**
     * Reads the 64-hex-char approval key. With `create`, makes one (mode 0600) when missing.
     * A file in any other format is rejected, so a Godot resource saved over it can't become a key.
     */
    EscalationManager.prototype.loadKey = function (create) {
        return __awaiter(this, void 0, void 0, function () {
            var text, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (this.key) {
                            return [2 /*return*/, this.key];
                        }
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 6]);
                        return [4 /*yield*/, fs.readFile(this.keyPath, 'utf8')];
                    case 2:
                        text = (_a.sent()).trim();
                        return [3 /*break*/, 6];
                    case 3:
                        error_1 = _a.sent();
                        if (error_1.code !== 'ENOENT' || !create) {
                            return [2 /*return*/, undefined];
                        }
                        return [4 /*yield*/, fs.mkdir(path.dirname(this.keyPath), { recursive: true, mode: 448 })];
                    case 4:
                        _a.sent();
                        text = randomBytes(32).toString('hex');
                        return [4 /*yield*/, fs.writeFile(this.keyPath, "".concat(text, "\n"), { mode: 384, flag: 'wx' })];
                    case 5:
                        _a.sent();
                        this.log('Created approval key', { systemSection: 'key', details: { keyPath: this.keyPath } });
                        return [3 /*break*/, 6];
                    case 6:
                        if (!KEY_FORMAT.test(text)) {
                            this.log('Approval key has an invalid format; ignoring all approvals', {
                                systemSection: 'key',
                                error: true,
                                details: { keyPath: this.keyPath },
                            });
                            if (create) {
                                throw new Error("Approval key at ".concat(this.keyPath, " is not 64 hex characters. Delete it to create a new one."));
                            }
                            return [2 /*return*/, undefined];
                        }
                        this.key = Buffer.from(text, 'hex');
                        return [2 /*return*/, this.key];
                }
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
            var raw, parsed, error_2, err;
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
                        error_2 = _a.sent();
                        err = error_2;
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