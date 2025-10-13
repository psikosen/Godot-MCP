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
import { spawn } from 'child_process';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { getGodotConnection } from './godot_connection.js';
// Get __dirname equivalent in ES modules
var __filename = fileURLToPath(import.meta.url);
var __dirname = dirname(__filename);
/**
 * Manages launching and monitoring the Godot editor
 */
var GodotLauncher = /** @class */ (function () {
    /**
     * Creates a new Godot launcher
     * @param projectPath Path to the Godot project (containing project.godot)
     * @param godotExecutable Path or command to launch Godot (default: 'godot' or '/Applications/Godot.app/Contents/MacOS/Godot')
     * @param maxStartupTime Maximum time to wait for Godot to start in ms
     */
    function GodotLauncher(projectPath, godotExecutable, maxStartupTime) {
        if (projectPath === void 0) { projectPath = resolve(__dirname, '../../../'); }
        if (godotExecutable === void 0) { godotExecutable = '/Applications/Godot.app/Contents/MacOS/Godot'; }
        if (maxStartupTime === void 0) { maxStartupTime = 30000; }
        this.godotProcess = null;
        this.projectPath = projectPath;
        this.godotExecutable = godotExecutable;
        this.maxStartupTime = maxStartupTime;
    }
    /**
     * Checks if Godot is running and the WebSocket server is accessible
     */
    GodotLauncher.prototype.isGodotRunning = function () {
        return __awaiter(this, void 0, void 0, function () {
            var godot, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        godot = getGodotConnection();
                        return [4 /*yield*/, godot.connect()];
                    case 1:
                        _b.sent();
                        return [2 /*return*/, true];
                    case 2:
                        _a = _b.sent();
                        return [2 /*return*/, false];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Launches the Godot editor with the specified project
     * @returns Promise that resolves when Godot is ready and WebSocket server is accessible
     */
    GodotLauncher.prototype.launch = function () {
        return __awaiter(this, void 0, void 0, function () {
            var startTime, lastError, godot, error_1;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        console.error("Launching Godot editor with project: ".concat(this.projectPath));
                        // Launch Godot with the project path
                        // Use --editor flag to open the editor, and pass the project path
                        this.godotProcess = spawn(this.godotExecutable, ['--editor', this.projectPath], {
                            stdio: 'ignore', // Ignore stdio to prevent interfering with MCP protocol
                            detached: false,
                        });
                        this.godotProcess.on('error', function (error) {
                            console.error('Failed to launch Godot:', error);
                            throw new Error("Failed to launch Godot: ".concat(error.message));
                        });
                        this.godotProcess.on('exit', function (code, signal) {
                            console.error("Godot process exited with code ".concat(code, ", signal ").concat(signal));
                            _this.godotProcess = null;
                        });
                        startTime = Date.now();
                        lastError = null;
                        _a.label = 1;
                    case 1:
                        if (!(Date.now() - startTime < this.maxStartupTime)) return [3 /*break*/, 7];
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 6]);
                        godot = getGodotConnection();
                        return [4 /*yield*/, godot.connect()];
                    case 3:
                        _a.sent();
                        console.error('Successfully connected to Godot WebSocket server');
                        return [2 /*return*/];
                    case 4:
                        error_1 = _a.sent();
                        lastError = error_1;
                        // Wait a bit before retrying
                        return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, 1000); })];
                    case 5:
                        // Wait a bit before retrying
                        _a.sent();
                        return [3 /*break*/, 6];
                    case 6: return [3 /*break*/, 1];
                    case 7:
                        // If we get here, we timed out
                        if (this.godotProcess) {
                            this.godotProcess.kill();
                            this.godotProcess = null;
                        }
                        throw new Error("Timed out waiting for Godot WebSocket server to start. Last error: ".concat(lastError === null || lastError === void 0 ? void 0 : lastError.message));
                }
            });
        });
    };
    /**
     * Ensures Godot is running - launches it if necessary
     */
    GodotLauncher.prototype.ensureGodotRunning = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.isGodotRunning()];
                    case 1:
                        if (_a.sent()) {
                            console.error('Godot is already running');
                            return [2 /*return*/];
                        }
                        console.error('Godot is not running, launching it now...');
                        return [4 /*yield*/, this.launch()];
                    case 2:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Stops the Godot process if it was launched by this instance
     */
    GodotLauncher.prototype.stop = function () {
        if (this.godotProcess) {
            console.error('Stopping Godot process...');
            this.godotProcess.kill();
            this.godotProcess = null;
        }
    };
    return GodotLauncher;
}());
export { GodotLauncher };
// Singleton instance
var launcherInstance = null;
/**
 * Gets the singleton instance of GodotLauncher
 * Uses environment variables for configuration:
 * - GODOT_PROJECT_PATH: Path to the Godot project directory
 * - GODOT_EXECUTABLE: Path to the Godot executable
 * - GODOT_STARTUP_TIMEOUT: Maximum startup time in milliseconds
 */
export function getGodotLauncher() {
    if (!launcherInstance) {
        var projectPath = process.env.GODOT_PROJECT_PATH || resolve(__dirname, '../../../');
        var godotExecutable = process.env.GODOT_EXECUTABLE || '/Applications/Godot.app/Contents/MacOS/Godot';
        var maxStartupTime = parseInt(process.env.GODOT_STARTUP_TIMEOUT || '30000', 10);
        console.error('=== Godot Launcher Configuration ===');
        console.error("Project Path: ".concat(projectPath));
        console.error("Godot Executable: ".concat(godotExecutable));
        console.error("Max Startup Time: ".concat(maxStartupTime, "ms"));
        console.error('===================================');
        launcherInstance = new GodotLauncher(projectPath, godotExecutable, maxStartupTime);
    }
    return launcherInstance;
}
//# sourceMappingURL=godot_launcher.js.map