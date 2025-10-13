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
import 'dotenv/config';
import { FastMCP } from 'fastmcp';
import { nodeTools } from './tools/node_tools.js';
import { scriptTools } from './tools/script_tools.js';
import { sceneTools } from './tools/scene_tools.js';
import { editorTools } from './tools/editor_tools.js';
import { patchTools } from './tools/patch_tools.js';
import { projectTools } from './tools/project_tools.js';
import { permissionTools } from './tools/permission_tools.js';
import { navigationTools } from './tools/navigation_tools.js';
import { audioTools } from './tools/audio_tools.js';
import { animationTools } from './tools/animation_tools.js';
import { xrTools } from './tools/xr_tools.js';
import { multiplayerTools } from './tools/multiplayer_tools.js';
import { compressionTools } from './tools/compression_tools.js';
import { renderingTools } from './tools/rendering_tools.js';
import { getGodotConnection } from './utils/godot_connection.js';
import { getGodotLauncher } from './utils/godot_launcher.js';
import { commandGuard } from './utils/command_guard.js';
// Import resources
import { sceneListResource, sceneStructureResource } from './resources/scene_resources.js';
import { scriptResource, scriptListResource, scriptMetadataResource } from './resources/script_resources.js';
import { projectStructureResource, projectSettingsResource, projectResourcesResource, projectIndexResource, } from './resources/project_resources.js';
import { audioBusResource } from './resources/audio_resources.js';
import { physicsWorldResource } from './resources/physics_resources.js';
import { animationStateMachinesResource, animationTracksResource, } from './resources/animation_resources.js';
import { editorStateResource, selectedNodeResource, currentScriptResource } from './resources/editor_resources.js';
import { uiThemeResource } from './resources/ui_resources.js';
import { xrInterfacesResource } from './resources/xr_resources.js';
import { multiplayerStateResource } from './resources/multiplayer_resources.js';
import { compressionSettingsResource } from './resources/compression_resources.js';
/**
 * Main entry point for the Godot MCP server
 */
function main() {
    return __awaiter(this, void 0, void 0, function () {
        var server, registerTool, launcher, error_1, err, cleanup, error_2;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    console.error('Starting Godot MCP server...');
                    server = new FastMCP({
                        name: 'GodotMCP',
                        version: '1.0.0',
                    });
                    registerTool = function (tool) {
                        server.addTool(__assign(__assign({}, tool), { execute: function (args) {
                                return __awaiter(this, void 0, void 0, function () {
                                    return __generator(this, function (_a) {
                                        switch (_a.label) {
                                            case 0: return [4 /*yield*/, commandGuard.assertAllowed(tool, args)];
                                            case 1:
                                                _a.sent();
                                                return [2 /*return*/, tool.execute(args)];
                                        }
                                    });
                                });
                            } }));
                    };
                    __spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray(__spreadArray([], nodeTools, true), scriptTools, true), sceneTools, true), editorTools, true), patchTools, true), projectTools, true), permissionTools, true), navigationTools, true), audioTools, true), animationTools, true), xrTools, true), multiplayerTools, true), compressionTools, true), renderingTools, true).forEach(function (tool) {
                        registerTool(tool);
                    });
                    // Register all resources
                    // Static resources
                    server.addResource(sceneListResource);
                    server.addResource(scriptListResource);
                    server.addResource(projectStructureResource);
                    server.addResource(projectSettingsResource);
                    server.addResource(projectResourcesResource);
                    server.addResource(projectIndexResource);
                    server.addResource(audioBusResource);
                    server.addResource(physicsWorldResource);
                    server.addResource(animationStateMachinesResource);
                    server.addResource(animationTracksResource);
                    server.addResource(editorStateResource);
                    server.addResource(uiThemeResource);
                    server.addResource(xrInterfacesResource);
                    server.addResource(multiplayerStateResource);
                    server.addResource(compressionSettingsResource);
                    server.addResource(selectedNodeResource);
                    server.addResource(currentScriptResource);
                    server.addResource(sceneStructureResource);
                    server.addResource(scriptResource);
                    server.addResource(scriptMetadataResource);
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 3, , 4]);
                    console.error('Checking if Godot is running...');
                    launcher = getGodotLauncher();
                    return [4 /*yield*/, launcher.ensureGodotRunning()];
                case 2:
                    _a.sent();
                    console.error('Godot editor is ready!');
                    return [3 /*break*/, 4];
                case 3:
                    error_1 = _a.sent();
                    err = error_1;
                    console.error("Failed to ensure Godot is running: ".concat(err.message));
                    console.error('You may need to manually launch Godot with the project');
                    return [3 /*break*/, 4];
                case 4:
                    cleanup = function () {
                        console.error('Shutting down Godot MCP server...');
                        var godot = getGodotConnection();
                        godot.disconnect();
                        // Optionally stop Godot if we launched it
                        // Uncomment the following lines if you want to auto-close Godot when stopping the server
                        // const launcher = getGodotLauncher();
                        // launcher.stop();
                        process.exit(0);
                    };
                    process.on('SIGINT', cleanup);
                    process.on('SIGTERM', cleanup);
                    _a.label = 5;
                case 5:
                    _a.trys.push([5, 7, , 8]);
                    return [4 /*yield*/, server.start({
                            transportType: 'stdio',
                        })];
                case 6:
                    _a.sent();
                    return [3 /*break*/, 8];
                case 7:
                    error_2 = _a.sent();
                    console.error('Failed to start MCP server:', error_2);
                    process.exit(1);
                    return [3 /*break*/, 8];
                case 8: return [2 /*return*/];
            }
        });
    });
}
// Start the server
main().catch(function (error) {
    console.error('Failed to start Godot MCP server:', error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map