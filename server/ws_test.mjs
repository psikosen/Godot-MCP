import WebSocket from 'ws';

console.log('Testing WebSocket connection to Godot MCP...');

const ws = new WebSocket('ws://127.0.0.1:9080');

ws.on('open', () => {
  console.log('✓ Connected to Godot MCP WebSocket!');
  ws.send(JSON.stringify({ type: 'ping' }));
});

ws.on('message', (data) => {
  console.log('Received:', data.toString());
});

ws.on('error', (err) => {
  console.log('✗ Connection error:', err.message);
});

ws.on('close', () => {
  console.log('Connection closed');
  process.exit(0);
});

setTimeout(() => {
  console.log('Timeout - closing');
  ws.close();
  process.exit(0);
}, 5000);
