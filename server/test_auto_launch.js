#!/usr/bin/env node

/**
 * Test script to verify Godot MCP auto-launch functionality
 */

import { getGodotLauncher } from './dist/utils/godot_launcher.js';

async function testAutoLaunch() {
  console.log('🧪 Testing Godot MCP Auto-Launch Functionality\n');
  
  try {
    console.log('Step 1: Getting launcher instance...');
    const launcher = getGodotLauncher();
    console.log('✅ Launcher instance created successfully\n');
    
    console.log('Step 2: Checking if Godot is running...');
    const isRunning = await launcher.isGodotRunning();
    console.log(`   Godot running: ${isRunning ? 'Yes' : 'No'}\n`);
    
    if (!isRunning) {
      console.log('Step 3: Launching Godot...');
      await launcher.ensureGodotRunning();
      console.log('✅ Godot launched successfully\n');
    } else {
      console.log('Step 3: Skipped (Godot already running)\n');
    }
    
    console.log('Step 4: Verifying connection...');
    const stillRunning = await launcher.isGodotRunning();
    if (stillRunning) {
      console.log('✅ Connection verified\n');
      console.log('🎉 SUCCESS! Auto-launch is working correctly!\n');
      console.log('Next steps:');
      console.log('  1. Check that Godot editor opened with your project');
      console.log('  2. Verify the WebSocket plugin is active');
      console.log('  3. Try sending MCP commands');
    } else {
      console.error('❌ Connection failed after launch');
      process.exit(1);
    }
    
  } catch (error) {
    console.error('\n❌ TEST FAILED\n');
    console.error('Error:', error.message);
    console.error('\nTroubleshooting:');
    console.error('  1. Check that project.godot exists in your project directory');
    console.error('  2. Verify GODOT_PROJECT_PATH environment variable (if set)');
    console.error('  3. Ensure Godot executable path is correct');
    console.error('  4. Check WebSocket plugin is installed in Godot');
    process.exit(1);
  }
}

testAutoLaunch();
