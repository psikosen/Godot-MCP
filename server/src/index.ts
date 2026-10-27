import 'dotenv/config';
import { FastMCP, type ContentResult } from 'fastmcp';
import { z } from 'zod';
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
import { workflowTools } from './tools/workflow_tools.js';
import { builderTools } from './tools/builder_tools.js';
import { authoringTools } from './tools/authoring_tools.js';
import { featureTools } from './tools/feature_tools.js';
import { assetTools } from './tools/asset_tools.js';
import { polishTools } from './tools/polish_tools.js';
import { getGodotConnection } from './utils/godot_connection.js';
import { getGodotLauncher } from './utils/godot_launcher.js';
import { commandGuard } from './utils/command_guard.js';
import { MCPTool } from './utils/types.js';
import { enabledToolsets, groupsOf } from './utils/toolsets.js';
import { loadToolsTool } from './tools/toolset_tools.js';
import { listedSchema } from './utils/listed_schema.js';

// Import resources
import { 
  sceneListResource, 
  sceneStructureResource 
} from './resources/scene_resources.js';
import {
  scriptResourceTemplate,
  scriptListResource,
  scriptMetadataResourceTemplate
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
  const toolsets = enabledToolsets(process.env.GODOT_MCP_TOOLSETS);

  // Create FastMCP instance
  const server = new FastMCP({
    name: 'GodotMCP',
    version: '1.0.0',
    // With client tool search (Claude Code), these words and the tool names are all the AI sees until it
    // searches, so they name the areas the tools cover.
    instructions:
      'Builds and edits Godot 4 games in a live Godot editor over WebSocket. The editor must be open with the Godot MCP addon enabled. ' +
      'Tools cover: scenes, nodes and GDScript; 2D players, sprites, tilemaps, tilesets, parallax and cameras; ' +
      '3D players, terrain, GridMaps and CSG; water (2D and 3D); paths and path followers; procedural levels, dungeons, caves, ' +
      'scattering and planets; enemy AI and navigation; physics, joints and ragdolls; animation, AnimationTree, skeletons and IK rigs; ' +
      'lights, sky and environment; particles, smoke and screen effects; materials, shaders and asset imports; UI, menus and HUD; ' +
      'audio and music; input actions; multiplayer; XR; tests and export. Search for tools with these words (e.g. "water", "tilemap", "ik"). ' +
      'Node paths start at /root, the open scene root. Read the godot/* resources or list/get tools before editing. ' +
      'Admin tools (scripts, headless runs, patches, project settings) return an escalation id that a human must approve. ' +
      'Prefer get_scene_tree for an overview, get_node_properties with properties/changed_only, and batch_update_nodes for many edits.' +
      (toolsets ? ' Only some tool groups are on: call load_tools first to turn on the groups your task needs.' : ''),
  });

  // Resources whose content follows the live editor scene (notified after edit/admin tools).
  const SCENE_STATE_RESOURCE_URIS = ['godot/scene/current', 'godot/editor/state'];

  // Adds to a tool's text result; load_tools sets it to point at tools that are not on yet.
  let resultHint = (_text: string) => '';

  // Wraps a tool for FastMCP
  const fastMcpTool = <T>(tool: MCPTool<T>) => ({
    ...tool,
    // Every tool declares a role; only 'read' tools are side-effect free, so clients may auto-approve them.
    annotations: { readOnlyHint: (tool.metadata?.requiredRole ?? 'read') === 'read' },
    // The listed schema already says additionalProperties:false; enforce it so a wrong argument
    // name (e.g. root_type for root_node_type) fails loudly instead of being silently dropped.
    // ponytail: top-level objects only; refined (ZodEffects) schemas still strip unknown keys.
    parameters: listedSchema((tool.parameters instanceof z.ZodObject ? tool.parameters.strict() : tool.parameters) as z.ZodType<T>),
    async execute(args: T): Promise<string | ContentResult> {
      await commandGuard.assertAllowed(tool, args);
      const output = await tool.execute(args);
      // FastMCP advertises resources.subscribe; tell subscribers the live scene may have changed.
      if ((tool.metadata?.requiredRole ?? 'read') !== 'read') {
        for (const uri of SCENE_STATE_RESOURCE_URIS) {
          server.sendResourceUpdated(uri).catch(() => undefined);
        }
      }
      return typeof output === 'string' && tool.name !== 'load_tools' ? output + resultHint(output) : output;
    },
  });

  const allTools: MCPTool[] = [
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
    ...workflowTools,
    ...builderTools,
    ...authoringTools,
    ...featureTools,
    ...assetTools,
    ...polishTools,
  ];
  if (toolsets === null) {
    server.addTools(allTools.map(fastMcpTool));
  } else {
    // FastMCP sends tool changes only to sessions that finished connecting, up to ~100 ms after
    // initialize; a load_tools call that comes sooner waits for that, or its tools never show up.
    const connected = new Promise<void>(resolve => server.on('connect', () => setImmediate(resolve)));
    // ponytail: groups are server-wide, so on HTTP every session sees what any session loaded.
    const loadTools = loadToolsTool(allTools, toolsets,
      async tools => { await connected; server.addTools(tools.map(fastMcpTool)); },
      async names => { await connected; server.removeTools(names); });
    resultHint = text => loadTools.offToolsHint(text);
    server.addTools([...allTools.filter(tool => groupsOf(tool.name).some(group => toolsets.has(group))), loadTools.tool].map(fastMcpTool));
  }

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
  server.addResourceTemplate(scriptResourceTemplate);
  server.addResourceTemplate(scriptMetadataResourceTemplate);

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

  // Start the transport first so the client handshake never waits on a Godot launch
  // (that can take GODOT_STARTUP_TIMEOUT, longer than many clients' connect timeout).
  // Only stdout is the protocol channel; console.error (stderr) stays safe after this.
  try {
    await server.start({
      transportType: 'stdio',
    });
  } catch (error) {
    console.error('Failed to start MCP server:', error);
    process.exit(1);
  }

  // Ensure Godot is running - auto-launch if needed.
  // Not awaited: tool calls retry the connection on their own.
  console.error('Checking if Godot is running...');
  getGodotLauncher()
    .ensureGodotRunning()
    .then(() => console.error('Godot editor is ready!'))
    .catch((error: Error) => {
      console.error(`Failed to ensure Godot is running: ${error.message}`);
      console.error('You may need to manually launch Godot with the project');
    });
}

// Start the server
main().catch(error => {
  console.error('Failed to start Godot MCP server:', error);
  process.exit(1);
});
