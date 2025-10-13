#!/usr/bin/env node

/**
 * Simple WebSocket connection test
 */

import WebSocket from 'ws';

const WS_URL = 'ws://localhost:9080';

console.log('Testing WebSocket connection to Godot...');
console.log(`URL: ${WS_URL}\n`);

const ws = new WebSocket(WS_URL);

ws.on('open', () => {
  console.log('✅ CONNECTED to Godot WebSocket!');
  console.log('Sending test command...\n');
  
  const testCommand = {
    type: 'list_nodes',
    params: { parent_path: '/root' },
    commandId: 'test_001'
  };
  
  ws.send(JSON.stringify(testCommand));
  console.log('Sent:', JSON.stringify(testCommand, null, 2));
  
  // Close after 2 seconds
  setTimeout(() => {
    console.log('\nClosing connection...');
    ws.close();
  }, 2000);
});

ws.on('message', (data) => {
  console.log('\n📨 RECEIVED RESPONSE:');
  try {
    const response = JSON.parse(data.toString());
    console.log(JSON.stringify(response, null, 2));
  } catch (err) {
    console.log('Raw:', data.toString());
  }
});

ws.on('error', (error) => {
  console.log('❌ CONNECTION FAILED:', error.message);
  console.log('\nPossible issues:');
  console.log('  1. Godot is not running');
  console.log('  2. Godot MCP plugin is not enabled');
  console.log('  3. Plugin failed to start (check Godot Output panel)');
  console.log('\nTo enable the plugin:');
  console.log('  Project → Project Settings → Plugins → Enable "Godot MCP"');
  process.exit(1);
});

ws.on('close', () => {
  console.log('\n✓ Connection closed');
  process.exit(0);
});
