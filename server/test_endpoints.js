#!/usr/bin/env node

/**
 * MCP Endpoint Tester
 * Tests each MCP tool to identify which one is causing connection issues
 */

import WebSocket from 'ws';

const WS_URL = 'ws://localhost:9080';
const TEST_TIMEOUT = 5000;

// All MCP tools organized by category
const TOOL_CATEGORIES = {
  node: [
    'create_node',
    'delete_node', 
    'update_node_property',
    'get_node_properties',
    'list_nodes',
    'rename_node',
    'add_node_to_group',
    'remove_node_from_group',
    'list_node_groups',
    'list_nodes_in_group',
    'configure_camera2d_limits',
    'create_theme_override',
    'wire_signal_handler',
    'layout_ui_grid',
    'validate_accessibility'
  ],
  script: [
    'create_script',
    'update_script',
    'get_script_content',
    'list_scripts',
    'attach_script',
    'detach_script'
  ],
  scene: [
    'save_scene',
    'open_scene',
    'reload_scene',
    'get_scene_tree',
    'duplicate_node'
  ],
  editor: [
    'get_editor_state',
    'select_node',
    'get_selected_nodes',
    'set_editor_setting',
    'get_editor_setting'
  ],
  project: [
    'get_project_settings',
    'set_project_setting',
    'list_project_files',
    'get_project_structure'
  ],
  navigation: [
    'bake_navigation_mesh',
    'get_navigation_mesh'
  ],
  audio: [
    'get_audio_buses',
    'add_audio_bus',
    'remove_audio_bus'
  ],
  animation: [
    'create_animation',
    'get_animation_tracks',
    'add_animation_track'
  ],
  xr: [
    'get_xr_interfaces',
    'initialize_xr',
    'get_xr_capabilities'
  ],
  multiplayer: [
    'get_multiplayer_state',
    'create_multiplayer_peer'
  ],
  compression: [
    'compress_data',
    'decompress_data'
  ],
  rendering: [
    'get_rendering_info',
    'set_rendering_quality'
  ]
};

class MCPTester {
  constructor() {
    this.ws = null;
    this.commandId = 0;
    this.pendingCommands = new Map();
    this.results = {
      passed: [],
      failed: [],
      timeout: [],
      connection_failed: false
    };
  }

  async connect() {
    return new Promise((resolve, reject) => {
      console.log(`Connecting to Godot WebSocket at ${WS_URL}...`);
      
      this.ws = new WebSocket(WS_URL);
      
      const timeout = setTimeout(() => {
        this.results.connection_failed = true;
        reject(new Error('Connection timeout'));
      }, 5000);

      this.ws.on('open', () => {
        clearTimeout(timeout);
        console.log('✓ Connected to Godot WebSocket\n');
        resolve();
      });

      this.ws.on('message', (data) => {
        try {
          const response = JSON.parse(data.toString());
          this.handleResponse(response);
        } catch (err) {
          console.error('Failed to parse response:', err);
        }
      });

      this.ws.on('error', (error) => {
        clearTimeout(timeout);
        this.results.connection_failed = true;
        reject(error);
      });

      this.ws.on('close', () => {
        console.log('WebSocket connection closed');
      });
    });
  }

  handleResponse(response) {
    const commandId = response.commandId;
    if (!commandId || !this.pendingCommands.has(commandId)) {
      return;
    }

    const { resolve, toolName } = this.pendingCommands.get(commandId);
    this.pendingCommands.delete(commandId);

    if (response.status === 'success' || response.status === 'error') {
      resolve({ success: true, response, toolName });
    } else {
      resolve({ success: false, response, toolName });
    }
  }

  async testCommand(toolName, params = {}) {
    return new Promise((resolve, reject) => {
      const commandId = `test_${++this.commandId}`;
      
      const command = {
        type: toolName,
        params: params,
        commandId: commandId
      };

      const timeout = setTimeout(() => {
        this.pendingCommands.delete(commandId);
        resolve({ success: false, timeout: true, toolName });
      }, TEST_TIMEOUT);

      this.pendingCommands.set(commandId, { 
        resolve: (result) => {
          clearTimeout(timeout);
          resolve(result);
        },
        toolName 
      });

      try {
        this.ws.send(JSON.stringify(command));
      } catch (err) {
        clearTimeout(timeout);
        this.pendingCommands.delete(commandId);
        resolve({ success: false, error: err.message, toolName });
      }
    });
  }

  async testAllCommands() {
    console.log('=== TESTING MCP ENDPOINTS ===\n');

    for (const [category, tools] of Object.entries(TOOL_CATEGORIES)) {
      console.log(`\n--- ${category.toUpperCase()} TOOLS ---`);
      
      for (const tool of tools) {
        process.stdout.write(`Testing ${tool}... `);
        
        const result = await this.testCommand(tool, {});
        
        if (result.timeout) {
          console.log('⏱️  TIMEOUT');
          this.results.timeout.push(tool);
        } else if (result.error) {
          console.log(`✗ ERROR: ${result.error}`);
          this.results.failed.push({ tool, error: result.error });
        } else if (result.success) {
          // Even errors from Godot mean the endpoint is working
          console.log('✓ RESPONDS');
          this.results.passed.push(tool);
        } else {
          console.log('✗ FAILED');
          this.results.failed.push({ tool, error: 'Unknown failure' });
        }
      }
    }
  }

  printSummary() {
    console.log('\n\n=== TEST SUMMARY ===');
    console.log(`Total endpoints tested: ${
      this.results.passed.length + 
      this.results.failed.length + 
      this.results.timeout.length
    }`);
    console.log(`✓ Responding: ${this.results.passed.length}`);
    console.log(`✗ Failed: ${this.results.failed.length}`);
    console.log(`⏱️  Timeout: ${this.results.timeout.length}`);

    if (this.results.timeout.length > 0) {
      console.log('\n⚠️  Endpoints that timed out (likely causing issues):');
      this.results.timeout.forEach(tool => {
        console.log(`  - ${tool}`);
      });
    }

    if (this.results.failed.length > 0) {
      console.log('\n✗ Endpoints that failed:');
      this.results.failed.forEach(({ tool, error }) => {
        console.log(`  - ${tool}: ${error}`);
      });
    }

    if (this.results.connection_failed) {
      console.log('\n🔴 CRITICAL: Could not connect to Godot WebSocket server!');
      console.log('Make sure:');
      console.log('  1. Godot is running');
      console.log('  2. The Godot MCP plugin is enabled');
      console.log('  3. The WebSocket server is listening on port 9080');
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
    }
  }
}

async function main() {
  const tester = new MCPTester();
  
  try {
    await tester.connect();
    await tester.testAllCommands();
  } catch (err) {
    console.error('Connection failed:', err.message);
  } finally {
    tester.printSummary();
    tester.disconnect();
  }
}

main().catch(console.error);
