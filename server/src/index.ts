import { FastMCP } from 'fastmcp';
import { nodeTools } from './tools/node_tools.js';
import { scriptTools } from './tools/script_tools.js';
import { sceneTools } from './tools/scene_tools.js';
import { editorTools } from './tools/editor_tools.js';
import { patchTools } from './tools/patch_tools.js';
import { projectTools } from './tools/project_tools.js';
import { permissionTools } from './tools/permission_tools.js';
import { navigationTools } from './tools/navigation_tools.js';
import { getGodotConnection } from './utils/godot_connection.js';
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
  editorStateResource,
  selectedNodeResource,
  currentScriptResource
} from './resources/editor_resources.js';

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
  server.addResource(editorStateResource);
  server.addResource(selectedNodeResource);
  server.addResource(currentScriptResource);
  server.addResource(sceneStructureResource);
  server.addResource(scriptResource);
  server.addResource(scriptMetadataResource);

  // Try to connect to Godot
  try {
    const godot = getGodotConnection();
    await godot.connect();
    console.error('Successfully connected to Godot WebSocket server');
  } catch (error) {
    const err = error as Error;
    console.warn(`Could not connect to Godot: ${err.message}`);
    console.warn('Will retry connection when commands are executed');
  }

  // Start the server
  server.start({
    transportType: 'stdio',
  });

  console.error('Godot MCP server started');

  // Handle cleanup
  const cleanup = () => {
    console.error('Shutting down Godot MCP server...');
    const godot = getGodotConnection();
    godot.disconnect();
    process.exit(0);
  };

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
}

// Start the server
main().catch(error => {
  console.error('Failed to start Godot MCP server:', error);
  process.exit(1);
});
