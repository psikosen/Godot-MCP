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
import { MCPTool } from './utils/types.js';

// Import resources
import { 
  sceneListResource, 
  sceneStructureResource 
} from './resources/scene_resources.js';
import { 
  scriptResource, 
  scriptListResource,
  scriptMetadataResource 
} from './resources/script_resources.js';
import {
  projectStructureResource,
  projectSettingsResource,
  projectResourcesResource,
  projectIndexResource,
} from './resources/project_resources.js';
import { audioBusResource } from './resources/audio_resources.js';
import { physicsWorldResource } from './resources/physics_resources.js';
import {
  animationStateMachinesResource,
  animationTracksResource,
} from './resources/animation_resources.js';
import {
  editorStateResource,
  selectedNodeResource,
  currentScriptResource
} from './resources/editor_resources.js';
import { uiThemeResource } from './resources/ui_resources.js';
import { xrInterfacesResource } from './resources/xr_resources.js';
import { multiplayerStateResource } from './resources/multiplayer_resources.js';
import { compressionSettingsResource } from './resources/compression_resources.js';

/**
 * Main entry point for the Godot MCP server
 */
async function main() {
  console.error('Starting Godot MCP server...');

  // Create FastMCP instance
  const server = new FastMCP({
    name: 'GodotMCP',
    version: '1.0.0',
  });

  // Register all tools
  const registerTool = <T>(tool: MCPTool<T>) => {
    server.addTool({
      ...tool,
      async execute(args: T): Promise<string> {
        await commandGuard.assertAllowed(tool, args);
        return tool.execute(args);
      },
    });
  };

  [
    ...nodeTools,
    ...scriptTools,
    ...sceneTools,
    ...editorTools,
    ...patchTools,
    ...projectTools,
    ...permissionTools,
    ...navigationTools,
    ...audioTools,
    ...animationTools,
    ...xrTools,
    ...multiplayerTools,
    ...compressionTools,
    ...renderingTools,
  ].forEach(tool => {
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

  // Ensure Godot is running - auto-launch if needed
  try {
    console.error('Checking if Godot is running...');
    const launcher = getGodotLauncher();
    await launcher.ensureGodotRunning();
    console.error('Godot editor is ready!');
  } catch (error) {
    const err = error as Error;
    console.error(`Failed to ensure Godot is running: ${err.message}`);
    console.error('You may need to manually launch Godot with the project');
    // Don't exit - continue with the server startup
    // The connection will be retried when commands are executed
  }

  // Handle cleanup
  const cleanup = () => {
    console.error('Shutting down Godot MCP server...');
    const godot = getGodotConnection();
    godot.disconnect();
    
    // Optionally stop Godot if we launched it
    // Uncomment the following lines if you want to auto-close Godot when stopping the server
    // const launcher = getGodotLauncher();
    // launcher.stop();
    
    process.exit(0);
  };

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);

  // Start the server - CRITICAL: Must be last, and no console output after this
  // Any console.log/error after this point will corrupt the stdio MCP protocol
  try {
    await server.start({
      transportType: 'stdio',
    });
  } catch (error) {
    console.error('Failed to start MCP server:', error);
    process.exit(1);
  }
}

// Start the server
main().catch(error => {
  console.error('Failed to start Godot MCP server:', error);
  process.exit(1);
});
