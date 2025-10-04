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
import WebSocket from 'ws';
/**
 * Manages WebSocket connection to the Godot editor
 */
var GodotConnection = /** @class */ (function () {
    /**
     * Creates a new Godot connection
     * @param url WebSocket URL for the Godot server
     * @param timeout Command timeout in ms
     * @param maxRetries Maximum number of connection retries
     * @param retryDelay Delay between retries in ms
     */
    function GodotConnection(url, timeout, maxRetries, retryDelay) {
        if (url === void 0) { url = 'ws://localhost:9080'; }
        if (timeout === void 0) { timeout = 20000; }
        if (maxRetries === void 0) { maxRetries = 3; }
        if (retryDelay === void 0) { retryDelay = 2000; }
        this.url = url;
        this.timeout = timeout;
        this.maxRetries = maxRetries;
        this.retryDelay = retryDelay;
        this.ws = null;
        this.connected = false;
        this.commandQueue = new Map();
        this.commandId = 0;
        console.error('GodotConnection created with URL:', this.url);
    }
    /**
     * Connects to the Godot WebSocket server
     */
    GodotConnection.prototype.connect = function () {
        return __awaiter(this, void 0, void 0, function () {
            var retries, tryConnect, error_1;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (this.connected)
                            return [2 /*return*/];
                        retries = 0;
                        tryConnect = function () {
                            return new Promise(function (resolve, reject) {
                                console.error("Connecting to Godot WebSocket server at ".concat(_this.url, "... (Attempt ").concat(retries + 1, "/").concat(_this.maxRetries + 1, ")"));
                                // Use protocol option to match Godot's supported_protocols
                                _this.ws = new WebSocket(_this.url, {
                                    protocol: 'json',
                                    handshakeTimeout: 8000, // Increase handshake timeout
                                    perMessageDeflate: false // Disable compression for compatibility
                                });
                                _this.ws.on('open', function () {
                                    _this.connected = true;
                                    console.error('Connected to Godot WebSocket server');
                                    resolve();
                                });
                                _this.ws.on('message', function (data) {
                                    try {
                                        var response = JSON.parse(data.toString());
                                        console.error('Received response:', response);
                                        // Handle command responses
                                        if ('commandId' in response) {
                                            var commandId = response.commandId;
                                            var pendingCommand = _this.commandQueue.get(commandId);
                                            if (pendingCommand) {
                                                clearTimeout(pendingCommand.timeout);
                                                _this.commandQueue.delete(commandId);
                                                if (response.status === 'success') {
                                                    pendingCommand.resolve(response.result);
                                                }
                                                else {
                                                    pendingCommand.reject(new Error(response.message || 'Unknown error'));
                                                }
                                            }
                                        }
                                    }
                                    catch (error) {
                                        console.error('Error parsing response:', error);
                                    }
                                });
                                _this.ws.on('error', function (error) {
                                    var err = error;
                                    console.error('WebSocket error:', err);
                                    // Don't terminate the connection on error - let the timeout handle it
                                    // Just log the error and allow retry mechanism to work
                                });
                                _this.ws.on('close', function () {
                                    if (_this.connected) {
                                        console.error('Disconnected from Godot WebSocket server');
                                        _this.connected = false;
                                    }
                                });
                                // Set connection timeout
                                var connectionTimeout = setTimeout(function () {
                                    var _a;
                                    if (((_a = _this.ws) === null || _a === void 0 ? void 0 : _a.readyState) !== WebSocket.OPEN) {
                                        if (_this.ws) {
                                            _this.ws.terminate();
                                            _this.ws = null;
                                        }
                                        reject(new Error('Connection timeout'));
                                    }
                                }, _this.timeout);
                                _this.ws.on('open', function () {
                                    clearTimeout(connectionTimeout);
                                });
                            });
                        };
                        _a.label = 1;
                    case 1:
                        if (!(retries <= this.maxRetries)) return [3 /*break*/, 9];
                        _a.label = 2;
                    case 2:
                        _a.trys.push([2, 4, , 8]);
                        return [4 /*yield*/, tryConnect()];
                    case 3:
                        _a.sent();
                        return [2 /*return*/];
                    case 4:
                        error_1 = _a.sent();
                        retries++;
                        if (!(retries <= this.maxRetries)) return [3 /*break*/, 6];
                        console.error("Connection attempt failed. Retrying in ".concat(this.retryDelay, "ms..."));
                        return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, _this.retryDelay); })];
                    case 5:
                        _a.sent();
                        return [3 /*break*/, 7];
                    case 6: throw error_1;
                    case 7: return [3 /*break*/, 8];
                    case 8: return [3 /*break*/, 1];
                    case 9: return [2 /*return*/];
                }
            });
        });
    };
    /**
     * Sends a command to Godot and waits for a response
     * @param type Command type
     * @param params Command parameters
     * @returns Promise that resolves with the command result
     */
    GodotConnection.prototype.sendCommand = function (type_1) {
        return __awaiter(this, arguments, void 0, function (type, params) {
            var error_2;
            var _this = this;
            if (params === void 0) { params = {}; }
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        if (!(!this.ws || !this.connected)) return [3 /*break*/, 4];
                        _a.label = 1;
                    case 1:
                        _a.trys.push([1, 3, , 4]);
                        return [4 /*yield*/, this.connect()];
                    case 2:
                        _a.sent();
                        return [3 /*break*/, 4];
                    case 3:
                        error_2 = _a.sent();
                        throw new Error("Failed to connect: ".concat(error_2.message));
                    case 4: return [2 /*return*/, new Promise(function (resolve, reject) {
                            var _a;
                            var commandId = "cmd_".concat(_this.commandId++);
                            var command = {
                                type: type,
                                params: params,
                                commandId: commandId
                            };
                            // Set timeout for command
                            var timeoutId = setTimeout(function () {
                                if (_this.commandQueue.has(commandId)) {
                                    _this.commandQueue.delete(commandId);
                                    reject(new Error("Command timed out: ".concat(type)));
                                }
                            }, _this.timeout);
                            // Store the promise resolvers
                            _this.commandQueue.set(commandId, {
                                resolve: resolve,
                                reject: reject,
                                timeout: timeoutId
                            });
                            // Send the command
                            if (((_a = _this.ws) === null || _a === void 0 ? void 0 : _a.readyState) === WebSocket.OPEN) {
                                _this.ws.send(JSON.stringify(command));
                            }
                            else {
                                clearTimeout(timeoutId);
                                _this.commandQueue.delete(commandId);
                                reject(new Error('WebSocket not connected'));
                            }
                        })];
                }
            });
        });
    };
    /**
     * Disconnects from the Godot WebSocket server
     */
    GodotConnection.prototype.disconnect = function () {
        var _this = this;
        if (this.ws) {
            // Clear all pending commands
            this.commandQueue.forEach(function (command, commandId) {
                clearTimeout(command.timeout);
                command.reject(new Error('Connection closed'));
                _this.commandQueue.delete(commandId);
            });
            this.ws.close();
            this.ws = null;
            this.connected = false;
        }
    };
    /**
     * Checks if connected to Godot
     */
    GodotConnection.prototype.isConnected = function () {
        return this.connected;
    };
    return GodotConnection;
}());
export { GodotConnection };
// Singleton instance
var connectionInstance = null;
/**
 * Gets the singleton instance of GodotConnection
 */
export function getGodotConnection() {
    if (!connectionInstance) {
        connectionInstance = new GodotConnection();
    }
    return connectionInstance;
}
//# sourceMappingURL=godot_connection.js.map