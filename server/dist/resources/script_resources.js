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
import { getGodotConnection } from '../utils/godot_connection.js';
var SCRIPT_EXTENSIONS = ['.gd', '.cs'];
var SCRIPT_COMPLETION_LIMIT = 25;
var isNonEmptyString = function (value) {
    return typeof value === 'string' && value.trim().length > 0;
};
var inferScriptLanguage = function (scriptPath) {
    if (scriptPath.endsWith('.gd'))
        return 'gdscript';
    if (scriptPath.endsWith('.cs'))
        return 'csharp';
    return 'unknown';
};
var decodeScriptPath = function (rawPath) {
    try {
        return decodeURIComponent(rawPath);
    }
    catch (_a) {
        return rawPath;
    }
};
var normalizeScriptPath = function (rawPath) {
    var decoded = decodeScriptPath(rawPath !== null && rawPath !== void 0 ? rawPath : '');
    var normalized = decoded.trim();
    if (!normalized) {
        throw new Error('A script resource path is required.');
    }
    if (!normalized.includes('://')) {
        throw new Error('Script path must be a valid Godot resource path (e.g., res://player.gd).');
    }
    return normalized;
};
var fetchScriptPaths = function () {
    var args_1 = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args_1[_i] = arguments[_i];
    }
    return __awaiter(void 0, __spreadArray([], args_1, true), void 0, function (godot) {
        var response, rawFiles, filtered, trimmed, deduped;
        var _a;
        if (godot === void 0) { godot = getGodotConnection(); }
        return __generator(this, function (_b) {
            switch (_b.label) {
                case 0: return [4 /*yield*/, godot.sendCommand('list_project_files', {
                        extensions: SCRIPT_EXTENSIONS,
                    })];
                case 1:
                    response = _b.sent();
                    if (!response || !Array.isArray(response.files)) {
                        return [2 /*return*/, []];
                    }
                    rawFiles = ((_a = response.files) !== null && _a !== void 0 ? _a : []);
                    filtered = rawFiles.filter(isNonEmptyString);
                    trimmed = filtered.map(function (path) { return path.trim(); });
                    deduped = Array.from(new Set(trimmed));
                    deduped.sort(function (a, b) { return a.localeCompare(b); });
                    return [2 /*return*/, deduped];
            }
        });
    });
};
var completeScriptPath = function (partial) { return __awaiter(void 0, void 0, void 0, function () {
    var scripts, query, matches, values;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, fetchScriptPaths()];
            case 1:
                scripts = _a.sent();
                query = partial.trim().toLowerCase();
                matches = query
                    ? scripts.filter(function (script) { return script.toLowerCase().includes(query); })
                    : scripts;
                values = matches.slice(0, SCRIPT_COMPLETION_LIMIT);
                return [2 /*return*/, {
                        values: values,
                        total: matches.length,
                        hasMore: matches.length > values.length,
                    }];
        }
    });
}); };
var buildScriptPathArgument = function () { return ({
    name: 'path',
    description: 'Full resource path to the script (e.g., res://player.gd).',
    complete: function (value) { return completeScriptPath(value !== null && value !== void 0 ? value : ''); },
}); };
/**
 * Resource template that provides the content of a specific script
 */
export var scriptResourceTemplate = {
    uriTemplate: 'godot/script/{path}',
    name: 'Godot Script Content',
    description: 'Fetch raw script source for a given Godot resource path.',
    mimeType: 'text/plain',
    arguments: [buildScriptPathArgument()],
    load: function (_a) {
        return __awaiter(this, arguments, void 0, function (_b) {
            var scriptPath, godot, result, resolvedPath, content, error_1;
            var path = _b.path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        scriptPath = normalizeScriptPath(path);
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_script', {
                                path: scriptPath,
                            })];
                    case 2:
                        result = _c.sent();
                        resolvedPath = isNonEmptyString(result === null || result === void 0 ? void 0 : result.script_path)
                            ? result.script_path.trim()
                            : scriptPath;
                        content = isNonEmptyString(result === null || result === void 0 ? void 0 : result.content) ? result.content : '';
                        return [2 /*return*/, {
                                text: content,
                                metadata: {
                                    path: resolvedPath,
                                    language: inferScriptLanguage(resolvedPath),
                                },
                            }];
                    case 3:
                        error_1 = _c.sent();
                        console.error('Error fetching script content:', error_1);
                        throw error_1;
                    case 4: return [2 /*return*/];
                }
            });
        });
    },
};
/**
 * Resource that provides a list of all scripts in the project
 */
export var scriptListResource = {
    uri: 'godot/scripts',
    name: 'Godot Script List',
    mimeType: 'application/json',
    load: function () {
        return __awaiter(this, void 0, void 0, function () {
            var scripts, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, fetchScriptPaths()];
                    case 1:
                        scripts = _a.sent();
                        return [2 /*return*/, {
                                text: JSON.stringify({
                                    scripts: scripts,
                                    count: scripts.length,
                                    gdscripts: scripts.filter(function (script) { return script.endsWith('.gd'); }),
                                    csharp_scripts: scripts.filter(function (script) { return script.endsWith('.cs'); }),
                                }),
                            }];
                    case 2:
                        error_2 = _a.sent();
                        console.error('Error fetching script list:', error_2);
                        throw error_2;
                    case 3: return [2 /*return*/];
                }
            });
        });
    }
};
/**
 * Resource template that provides metadata for a specific script, including classes and methods
 */
export var scriptMetadataResourceTemplate = {
    uriTemplate: 'godot/script/{path}/metadata',
    name: 'Godot Script Metadata',
    description: 'Retrieve declared classes, methods, and signals for a script path.',
    mimeType: 'application/json',
    arguments: [buildScriptPathArgument()],
    load: function (_a) {
        return __awaiter(this, arguments, void 0, function (_b) {
            var scriptPath, godot, result, error_3;
            var path = _b.path;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        scriptPath = normalizeScriptPath(path);
                        godot = getGodotConnection();
                        _c.label = 1;
                    case 1:
                        _c.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, godot.sendCommand('get_script_metadata', {
                                path: scriptPath,
                            })];
                    case 2:
                        result = _c.sent();
                        return [2 /*return*/, {
                                text: JSON.stringify(result, null, 2),
                            }];
                    case 3:
                        error_3 = _c.sent();
                        console.error('Error fetching script metadata:', error_3);
                        throw error_3;
                    case 4: return [2 /*return*/];
                }
            });
        });
    },
};
//# sourceMappingURL=script_resources.js.map