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
var DEFAULT_SKIP_PATHS = new Set([
    'server/dist',
]);
var DEFAULT_SKIP_SEGMENTS = new Set([
    '.git',
    '.godot',
    '.import',
    'node_modules',
]);
var ENTRY_LIMIT = 5000;
/**
 * Builds and caches a structural index of the Godot project to support
 * high-level queries from MCP tools. The index intentionally mirrors the
 * capability guardrails by skipping transient or high-churn directories.
 */
var ProjectIndexer = /** @class */ (function () {
    function ProjectIndexer(projectRoot) {
        this.cache = null;
        this.building = false;
        this.projectRoot = projectRoot !== null && projectRoot !== void 0 ? projectRoot : path.resolve(process.cwd(), '..');
    }
    /**
     * Returns the cached snapshot or rebuilds it when missing or forced.
     */
    ProjectIndexer.prototype.getIndex = function () {
        return __awaiter(this, arguments, void 0, function (forceRefresh) {
            var built;
            if (forceRefresh === void 0) { forceRefresh = false; }
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!forceRefresh && this.cache) {
                            return [2 /*return*/, this.cache.snapshot];
                        }
                        if (!this.building) return [3 /*break*/, 4];
                        _a.label = 1;
                    case 1:
                        if (!this.building) return [3 /*break*/, 3];
                        return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, 25); })];
                    case 2:
                        _a.sent();
                        return [3 /*break*/, 1];
                    case 3:
                        if (this.cache) {
                            return [2 /*return*/, this.cache.snapshot];
                        }
                        _a.label = 4;
                    case 4:
                        this.building = true;
                        _a.label = 5;
                    case 5:
                        _a.trys.push([5, , 7, 8]);
                        return [4 /*yield*/, this.buildSnapshot()];
                    case 6:
                        built = _a.sent();
                        this.cache = built;
                        this.log('Rebuilt project index snapshot', {
                            systemSection: 'build',
                            details: {
                                files: built.snapshot.stats.files,
                                directories: built.snapshot.stats.directories,
                                truncated: built.snapshot.stats.truncated,
                            },
                        });
                        return [2 /*return*/, built.snapshot];
                    case 7:
                        this.building = false;
                        return [7 /*endfinally*/];
                    case 8: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Forces a rebuild and returns the latest snapshot.
     */
    ProjectIndexer.prototype.refresh = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/, this.getIndex(true)];
            });
        });
    };
    /**
     * Queries the cached snapshot using glob-like path patterns.
     */
    ProjectIndexer.prototype.query = function (patterns_1) {
        return __awaiter(this, arguments, void 0, function (patterns, options) {
            var snapshot, includeDirectories, limit, normalizedPatterns, regexes, results, _loop_1, _i, _a, _b, entryPath, entry, state_1;
            var _this = this;
            var _c, _d;
            if (options === void 0) { options = {}; }
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0: return [4 /*yield*/, this.getIndex()];
                    case 1:
                        snapshot = _e.sent();
                        includeDirectories = (_c = options.includeDirectories) !== null && _c !== void 0 ? _c : true;
                        limit = Math.min((_d = options.limit) !== null && _d !== void 0 ? _d : 200, ENTRY_LIMIT);
                        normalizedPatterns = patterns.map(function (pattern) { return _this.normalizePath(pattern); });
                        regexes = normalizedPatterns.map(function (pattern) { return _this.globToRegExp(pattern); });
                        results = [];
                        _loop_1 = function (entryPath, entry) {
                            if (entryPath === '.')
                                return "continue";
                            if (!includeDirectories && entry.type === 'directory')
                                return "continue";
                            if (regexes.some(function (regex) { return regex.test(entryPath); })) {
                                results.push(entry);
                                if (results.length >= limit) {
                                    return "break";
                                }
                            }
                        };
                        for (_i = 0, _a = Object.entries(snapshot.entries); _i < _a.length; _i++) {
                            _b = _a[_i], entryPath = _b[0], entry = _b[1];
                            state_1 = _loop_1(entryPath, entry);
                            if (state_1 === "break")
                                break;
                        }
                        return [2 /*return*/, results.sort(function (a, b) { return a.path.localeCompare(b.path); })];
                }
            });
        });
    };
    ProjectIndexer.prototype.buildSnapshot = function () {
        return __awaiter(this, void 0, void 0, function () {
            var stats, entryMap, rootEntry, snapshot;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        stats = {
                            files: 0,
                            directories: 0,
                            totalSize: 0,
                            skipped: [],
                            truncated: false,
                        };
                        entryMap = new Map();
                        return [4 /*yield*/, this.scanDirectory(this.projectRoot, '.', entryMap, stats)];
                    case 1:
                        rootEntry = _b.sent();
                        snapshot = {
                            generatedAt: new Date().toISOString(),
                            projectRoot: this.projectRoot,
                            root: (_a = rootEntry.children) !== null && _a !== void 0 ? _a : [],
                            entries: Object.fromEntries(entryMap.entries()),
                            stats: stats,
                        };
                        return [2 /*return*/, { snapshot: snapshot, entryMap: entryMap }];
                }
            });
        });
    };
    ProjectIndexer.prototype.scanDirectory = function (absolutePath_1, relativePath_1, entryMap_1, stats_1) {
        return __awaiter(this, arguments, void 0, function (absolutePath, relativePath, entryMap, stats, visited) {
            var normalizedRelative, realPath, directoryChildren, aggregateSize, dirStat, stat, error_1, err, dirents, error_2, err, _i, dirents_1, dirent, childRelative, childAbsolute, childEntry, fileEntry, entry;
            var _a;
            if (visited === void 0) { visited = new Set(); }
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        normalizedRelative = this.normalizePath(relativePath);
                        return [4 /*yield*/, fs.realpath(absolutePath).catch(function () { return absolutePath; })];
                    case 1:
                        realPath = _b.sent();
                        if (visited.has(realPath)) {
                            stats.skipped.push(normalizedRelative);
                            return [2 /*return*/, (_a = entryMap.get(normalizedRelative)) !== null && _a !== void 0 ? _a : {
                                    path: normalizedRelative,
                                    type: 'directory',
                                    size: 0,
                                    modified: new Date(0).toISOString(),
                                    children: [],
                                }];
                        }
                        visited.add(realPath);
                        directoryChildren = [];
                        aggregateSize = 0;
                        _b.label = 2;
                    case 2:
                        _b.trys.push([2, 4, , 5]);
                        return [4 /*yield*/, fs.stat(absolutePath)];
                    case 3:
                        stat = _b.sent();
                        dirStat = { mtime: stat.mtime };
                        return [3 /*break*/, 5];
                    case 4:
                        error_1 = _b.sent();
                        err = error_1;
                        this.log("Failed to stat directory: ".concat(err.message), {
                            systemSection: 'scan',
                            error: true,
                            details: { path: normalizedRelative },
                        });
                        dirStat = { mtime: new Date(0) };
                        return [3 /*break*/, 5];
                    case 5:
                        stats.directories += normalizedRelative === '.' ? 0 : 1;
                        dirents = [];
                        _b.label = 6;
                    case 6:
                        _b.trys.push([6, 8, , 9]);
                        return [4 /*yield*/, fs.readdir(absolutePath, { withFileTypes: true })];
                    case 7:
                        dirents = _b.sent();
                        return [3 /*break*/, 9];
                    case 8:
                        error_2 = _b.sent();
                        err = error_2;
                        this.log("Failed to read directory: ".concat(err.message), {
                            systemSection: 'scan',
                            error: true,
                            details: { path: normalizedRelative },
                        });
                        return [3 /*break*/, 9];
                    case 9:
                        _i = 0, dirents_1 = dirents;
                        _b.label = 10;
                    case 10:
                        if (!(_i < dirents_1.length)) return [3 /*break*/, 16];
                        dirent = dirents_1[_i];
                        if (entryMap.size >= ENTRY_LIMIT) {
                            stats.truncated = true;
                            return [3 /*break*/, 16];
                        }
                        childRelative = normalizedRelative === '.'
                            ? dirent.name
                            : "".concat(normalizedRelative, "/").concat(dirent.name);
                        childAbsolute = path.join(absolutePath, dirent.name);
                        if (this.shouldSkip(childRelative, dirent)) {
                            stats.skipped.push(childRelative);
                            return [3 /*break*/, 15];
                        }
                        if (!dirent.isDirectory()) return [3 /*break*/, 12];
                        return [4 /*yield*/, this.scanDirectory(childAbsolute, childRelative, entryMap, stats, visited)];
                    case 11:
                        childEntry = _b.sent();
                        directoryChildren.push(childEntry.path);
                        aggregateSize += childEntry.size;
                        return [3 /*break*/, 15];
                    case 12:
                        if (!dirent.isFile()) return [3 /*break*/, 14];
                        return [4 /*yield*/, this.createFileEntry(childAbsolute, childRelative)];
                    case 13:
                        fileEntry = _b.sent();
                        entryMap.set(fileEntry.path, fileEntry);
                        directoryChildren.push(fileEntry.path);
                        aggregateSize += fileEntry.size;
                        stats.files += 1;
                        stats.totalSize += fileEntry.size;
                        return [3 /*break*/, 15];
                    case 14:
                        stats.skipped.push(childRelative);
                        _b.label = 15;
                    case 15:
                        _i++;
                        return [3 /*break*/, 10];
                    case 16:
                        directoryChildren.sort();
                        entry = {
                            path: normalizedRelative,
                            type: 'directory',
                            size: aggregateSize,
                            modified: dirStat.mtime.toISOString(),
                            children: directoryChildren,
                        };
                        entryMap.set(entry.path, entry);
                        return [2 /*return*/, entry];
                }
            });
        });
    };
    ProjectIndexer.prototype.createFileEntry = function (absolutePath, relativePath) {
        return __awaiter(this, void 0, void 0, function () {
            var stat;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, fs.stat(absolutePath)];
                    case 1:
                        stat = _a.sent();
                        return [2 /*return*/, {
                                path: this.normalizePath(relativePath),
                                type: 'file',
                                size: stat.size,
                                modified: stat.mtime.toISOString(),
                                extension: path.extname(relativePath) || undefined,
                            }];
                }
            });
        });
    };
    ProjectIndexer.prototype.shouldSkip = function (relativePath, dirent) {
        if (dirent.isSymbolicLink()) {
            return true;
        }
        var normalized = this.normalizePath(relativePath);
        if (DEFAULT_SKIP_PATHS.has(normalized)) {
            return true;
        }
        var pathMatch = false;
        DEFAULT_SKIP_PATHS.forEach(function (skipPath) {
            if (!pathMatch && normalized.startsWith("".concat(skipPath, "/"))) {
                pathMatch = true;
            }
        });
        if (pathMatch) {
            return true;
        }
        var segments = normalized.split('/');
        if (segments.some(function (segment) { return DEFAULT_SKIP_SEGMENTS.has(segment); })) {
            return true;
        }
        return false;
    };
    ProjectIndexer.prototype.normalizePath = function (input) {
        if (!input || input === '.') {
            return '.';
        }
        var normalized = path.posix.normalize(input.replace(/\\/g, '/'));
        return normalized.startsWith('./') ? normalized.slice(2) : normalized;
    };
    ProjectIndexer.prototype.globToRegExp = function (pattern) {
        var escaped = pattern.replace(/[.+^${}()|[\]\\]/g, '\\$&');
        var translated = escaped
            .replace(/\\\*\\\*/g, '§§DOUBLESTAR§§')
            .replace(/\\\*/g, '[^/]*')
            .replace(/§§DOUBLESTAR§§/g, '.*')
            .replace(/\\\?/g, '[^/]');
        return new RegExp("^".concat(translated, "$"));
    };
    ProjectIndexer.prototype.log = function (message, _a) {
        var systemSection = _a.systemSection, details = _a.details, _b = _a.error, error = _b === void 0 ? false : _b;
        var logEntry = __assign({ filename: 'server/src/utils/project_indexer.ts', timestamp: new Date().toISOString(), classname: 'ProjectIndexer', function: systemSection, system_section: systemSection, line_num: 0, error: error, db_phase: 'none', method: 'NONE', message: message }, (details ? { details: details } : {}));
        console.error(JSON.stringify(logEntry));
        console.error("[Continuous skepticism (Sherlock Protocol)] ".concat(message));
    };
    return ProjectIndexer;
}());
export { ProjectIndexer };
export var projectIndexer = new ProjectIndexer();
//# sourceMappingURL=project_indexer.js.map