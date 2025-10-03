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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
import { promises as fs } from 'node:fs';
import { randomUUID } from 'node:crypto';
import * as path from 'node:path';
import { parsePatch, applyPatch } from 'diff';
import { permissionManager } from './permission_manager.js';
/**
 * Manages preview, application, and cancellation of unified diff patches with
 * atomic file writes and rollback semantics.
 */
var PatchManager = /** @class */ (function () {
    function PatchManager(projectRoot) {
        this.sessions = new Map();
        this.lockedPaths = new Set();
        this.projectRoot = projectRoot !== null && projectRoot !== void 0 ? projectRoot : path.resolve(process.cwd(), '..');
    }
    /**
     * Registers a diff for preview, returning a patch identifier if the diff
     * applies cleanly against the current working tree.
     */
    PatchManager.prototype.preview = function (diffText) {
        return __awaiter(this, void 0, void 0, function () {
            var parsed, files, _i, parsed_1, patch, resolved, patchId;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!diffText.trim()) {
                            throw new Error('Cannot preview an empty diff.');
                        }
                        parsed = parsePatch(diffText);
                        if (parsed.length === 0) {
                            throw new Error('Diff did not contain any file changes.');
                        }
                        files = [];
                        _i = 0, parsed_1 = parsed;
                        _a.label = 1;
                    case 1:
                        if (!(_i < parsed_1.length)) return [3 /*break*/, 4];
                        patch = parsed_1[_i];
                        return [4 /*yield*/, this.prepareFilePlan(patch)];
                    case 2:
                        resolved = _a.sent();
                        files.push(resolved);
                        _a.label = 3;
                    case 3:
                        _i++;
                        return [3 /*break*/, 1];
                    case 4:
                        patchId = randomUUID();
                        this.sessions.set(patchId, {
                            id: patchId,
                            diff: diffText,
                            files: files,
                            createdAt: new Date(),
                        });
                        this.logEvent('Generated patch preview', {
                            systemSection: 'preview',
                            details: {
                                patchId: patchId,
                                fileCount: files.length,
                            },
                        });
                        return [2 /*return*/, {
                                patchId: patchId,
                                files: files.map(function (file) { return ({
                                    path: file.relativePath,
                                    mode: file.mode,
                                    originalSize: Buffer.byteLength(file.originalContent, 'utf8'),
                                    patchedSize: Buffer.byteLength(file.patchedContent, 'utf8'),
                                }); }),
                            }];
                }
            });
        });
    };
    /**
     * Applies a previously previewed patch atomically. If any file fails to
     * update, all changes are rolled back.
     */
    PatchManager.prototype.apply = function (patchId) {
        return __awaiter(this, void 0, void 0, function () {
            var session, paths, applied, _loop_1, this_1, _i, _a, file, error_1;
            var _this = this;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        session = this.sessions.get(patchId);
                        if (!session) {
                            throw new Error("No preview found for patch ID ".concat(patchId, "."));
                        }
                        paths = session.files.map(function (file) { return file.absolutePath; });
                        this.acquireLocks(paths);
                        applied = [];
                        _b.label = 1;
                    case 1:
                        _b.trys.push([1, 6, 8, 9]);
                        _loop_1 = function (file) {
                            return __generator(this, function (_c) {
                                switch (_c.label) {
                                    case 0:
                                        if (!(file.mode === 'delete')) return [3 /*break*/, 4];
                                        return [4 /*yield*/, this_1.ensurePathWithinProject(file.absolutePath)];
                                    case 1:
                                        _c.sent();
                                        if (!file.existedBefore) return [3 /*break*/, 3];
                                        return [4 /*yield*/, fs.unlink(file.absolutePath)];
                                    case 2:
                                        _c.sent();
                                        applied.push(function () { return __awaiter(_this, void 0, void 0, function () {
                                            return __generator(this, function (_a) {
                                                switch (_a.label) {
                                                    case 0: return [4 /*yield*/, this.writeAtomic(file.absolutePath, file.originalContent)];
                                                    case 1:
                                                        _a.sent();
                                                        return [2 /*return*/];
                                                }
                                            });
                                        }); });
                                        _c.label = 3;
                                    case 3: return [3 /*break*/, 7];
                                    case 4: return [4 /*yield*/, this_1.ensureDirectory(path.dirname(file.absolutePath))];
                                    case 5:
                                        _c.sent();
                                        return [4 /*yield*/, this_1.writeAtomic(file.absolutePath, file.patchedContent)];
                                    case 6:
                                        _c.sent();
                                        if (file.existedBefore) {
                                            applied.push(function () { return __awaiter(_this, void 0, void 0, function () {
                                                return __generator(this, function (_a) {
                                                    switch (_a.label) {
                                                        case 0: return [4 /*yield*/, this.writeAtomic(file.absolutePath, file.originalContent)];
                                                        case 1:
                                                            _a.sent();
                                                            return [2 /*return*/];
                                                    }
                                                });
                                            }); });
                                        }
                                        else {
                                            applied.push(function () { return __awaiter(_this, void 0, void 0, function () {
                                                return __generator(this, function (_a) {
                                                    switch (_a.label) {
                                                        case 0: return [4 /*yield*/, this.safeCleanup(file.absolutePath)];
                                                        case 1:
                                                            _a.sent();
                                                            return [2 /*return*/];
                                                    }
                                                });
                                            }); });
                                        }
                                        _c.label = 7;
                                    case 7: return [2 /*return*/];
                                }
                            });
                        };
                        this_1 = this;
                        _i = 0, _a = session.files;
                        _b.label = 2;
                    case 2:
                        if (!(_i < _a.length)) return [3 /*break*/, 5];
                        file = _a[_i];
                        return [5 /*yield**/, _loop_1(file)];
                    case 3:
                        _b.sent();
                        _b.label = 4;
                    case 4:
                        _i++;
                        return [3 /*break*/, 2];
                    case 5:
                        this.sessions.delete(patchId);
                        this.logEvent('Applied patch', {
                            systemSection: 'apply',
                            details: {
                                patchId: patchId,
                                files: session.files.map(function (file) { return ({
                                    path: file.relativePath,
                                    mode: file.mode,
                                }); }),
                            },
                        });
                        return [2 /*return*/, {
                                patchId: patchId,
                                appliedFiles: session.files.map(function (file) { return ({
                                    path: file.relativePath,
                                    mode: file.mode,
                                }); }),
                            }];
                    case 6:
                        error_1 = _b.sent();
                        return [4 /*yield*/, this.rollback(applied)];
                    case 7:
                        _b.sent();
                        this.logEvent("Failed to apply patch: ".concat(error_1.message), {
                            systemSection: 'apply',
                            error: true,
                            details: { patchId: patchId },
                        });
                        throw error_1;
                    case 8:
                        this.releaseLocks(paths);
                        return [7 /*endfinally*/];
                    case 9: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Cancels a previewed patch without applying it.
     */
    PatchManager.prototype.cancel = function (patchId) {
        if (!this.sessions.has(patchId)) {
            throw new Error("No preview found for patch ID ".concat(patchId, "."));
        }
        this.sessions.delete(patchId);
        this.logEvent('Cancelled patch preview', {
            systemSection: 'cancel',
            details: { patchId: patchId },
        });
    };
    PatchManager.prototype.prepareFilePlan = function (patch) {
        return __awaiter(this, void 0, void 0, function () {
            var targetPath, relativePath, exists, originalContent, patched, mode;
            var _a, _b;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        targetPath = this.resolvePatchPath((_a = patch.newFileName) !== null && _a !== void 0 ? _a : patch.oldFileName);
                        relativePath = path.relative(this.projectRoot, targetPath);
                        if (!relativePath || relativePath.startsWith('..') || path.isAbsolute(relativePath)) {
                            throw new Error("Patch targets path outside project root: ".concat((_b = patch.newFileName) !== null && _b !== void 0 ? _b : patch.oldFileName));
                        }
                        return [4 /*yield*/, this.fileExists(targetPath)];
                    case 1:
                        exists = _c.sent();
                        return [4 /*yield*/, this.readOriginalContent(patch, targetPath, exists)];
                    case 2:
                        originalContent = _c.sent();
                        if (patch.hunks.length === 0) {
                            throw new Error("Patch for ".concat(relativePath, " did not contain any hunks."));
                        }
                        patched = applyPatch(originalContent, patch);
                        if (patched === false) {
                            throw new Error("Failed to apply diff for ".concat(relativePath, "."));
                        }
                        mode = this.determineMode(patch, exists);
                        return [4 /*yield*/, permissionManager.assertWriteAllowed(relativePath, mode)];
                    case 3:
                        _c.sent();
                        return [2 /*return*/, {
                                absolutePath: targetPath,
                                relativePath: relativePath,
                                mode: mode,
                                originalContent: originalContent,
                                patchedContent: patched,
                                patch: patch,
                                existedBefore: exists,
                            }];
                }
            });
        });
    };
    PatchManager.prototype.determineMode = function (patch, exists) {
        if (patch.oldFileName === '/dev/null') {
            return 'create';
        }
        if (patch.newFileName === '/dev/null') {
            return 'delete';
        }
        return exists ? 'modify' : 'create';
    };
    PatchManager.prototype.ensureDirectory = function (dirPath) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, fs.mkdir(dirPath, { recursive: true })];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    PatchManager.prototype.writeAtomic = function (targetPath, content) {
        return __awaiter(this, void 0, void 0, function () {
            var dir, base, tempPath, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        dir = path.dirname(targetPath);
                        base = path.basename(targetPath);
                        tempPath = path.join(dir, "".concat(base, ".tmp-").concat(randomUUID()));
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 5, , 7]);
                        return [4 /*yield*/, fs.mkdir(dir, { recursive: true })];
                    case 2:
                        _a.sent();
                        return [4 /*yield*/, fs.writeFile(tempPath, content, 'utf8')];
                    case 3:
                        _a.sent();
                        return [4 /*yield*/, fs.rename(tempPath, targetPath)];
                    case 4:
                        _a.sent();
                        return [3 /*break*/, 7];
                    case 5:
                        error_2 = _a.sent();
                        return [4 /*yield*/, this.safeCleanup(tempPath)];
                    case 6:
                        _a.sent();
                        throw error_2;
                    case 7: return [2 /*return*/];
                }
            });
        });
    };
    PatchManager.prototype.safeCleanup = function (filePath) {
        return __awaiter(this, void 0, void 0, function () {
            var error_3, err;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, fs.unlink(filePath)];
                    case 1:
                        _a.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        error_3 = _a.sent();
                        err = error_3;
                        if (err.code !== 'ENOENT') {
                            throw error_3;
                        }
                        return [3 /*break*/, 3];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    PatchManager.prototype.readOriginalContent = function (patch, targetPath, exists) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                if (patch.oldFileName === '/dev/null') {
                    return [2 /*return*/, ''];
                }
                if (!exists) {
                    throw new Error("Target file for patch does not exist: ".concat(patch.oldFileName));
                }
                return [2 /*return*/, fs.readFile(targetPath, 'utf8')];
            });
        });
    };
    PatchManager.prototype.resolvePatchPath = function (fileName) {
        if (!fileName) {
            throw new Error('Patch file entry missing file name.');
        }
        var cleaned = fileName.replace(/^a\//, '').replace(/^b\//, '');
        var normalized = path.normalize(cleaned);
        var resolved = path.resolve(this.projectRoot, normalized);
        return resolved;
    };
    PatchManager.prototype.fileExists = function (targetPath) {
        return __awaiter(this, void 0, void 0, function () {
            var error_4, err;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, fs.access(targetPath)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, true];
                    case 2:
                        error_4 = _a.sent();
                        err = error_4;
                        if (err.code === 'ENOENT') {
                            return [2 /*return*/, false];
                        }
                        throw error_4;
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    PatchManager.prototype.rollback = function (operations) {
        return __awaiter(this, void 0, void 0, function () {
            var _i, _a, revert, error_5;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _i = 0, _a = operations.reverse();
                        _b.label = 1;
                    case 1:
                        if (!(_i < _a.length)) return [3 /*break*/, 6];
                        revert = _a[_i];
                        _b.label = 2;
                    case 2:
                        _b.trys.push([2, 4, , 5]);
                        return [4 /*yield*/, revert()];
                    case 3:
                        _b.sent();
                        return [3 /*break*/, 5];
                    case 4:
                        error_5 = _b.sent();
                        this.logEvent("Rollback step failed: ".concat(error_5.message), {
                            systemSection: 'rollback',
                            error: true,
                        });
                        return [3 /*break*/, 5];
                    case 5:
                        _i++;
                        return [3 /*break*/, 1];
                    case 6: return [2 /*return*/];
                }
            });
        });
    };
    PatchManager.prototype.acquireLocks = function (paths) {
        var _this = this;
        var sorted = __spreadArray([], paths, true).sort();
        for (var _i = 0, sorted_1 = sorted; _i < sorted_1.length; _i++) {
            var filePath = sorted_1[_i];
            if (this.lockedPaths.has(filePath)) {
                throw new Error("Resource is currently locked: ".concat(path.relative(this.projectRoot, filePath)));
            }
        }
        sorted.forEach(function (filePath) { return _this.lockedPaths.add(filePath); });
    };
    PatchManager.prototype.releaseLocks = function (paths) {
        var _this = this;
        paths.forEach(function (filePath) { return _this.lockedPaths.delete(filePath); });
    };
    PatchManager.prototype.ensurePathWithinProject = function (targetPath) {
        return __awaiter(this, void 0, void 0, function () {
            var relative;
            return __generator(this, function (_a) {
                relative = path.relative(this.projectRoot, targetPath);
                if (!relative || relative.startsWith('..') || path.isAbsolute(relative)) {
                    throw new Error("Resolved path is outside of project root: ".concat(targetPath));
                }
                return [2 /*return*/];
            });
        });
    };
    PatchManager.prototype.logEvent = function (message, _a) {
        var systemSection = _a.systemSection, _b = _a.error, error = _b === void 0 ? false : _b, details = _a.details;
        var logEntry = __assign({ filename: 'server/src/utils/patch_manager.ts', timestamp: new Date().toISOString(), classname: 'PatchManager', function: systemSection, system_section: systemSection, line_num: 0, error: error, db_phase: 'none', method: 'NONE', message: message }, (details ? { details: details } : {}));
        console.error(JSON.stringify(logEntry));
        console.error("[Continuous skepticism (Sherlock Protocol)] ".concat(message));
    };
    return PatchManager;
}());
export { PatchManager };
export var patchManager = new PatchManager();
//# sourceMappingURL=patch_manager.js.map