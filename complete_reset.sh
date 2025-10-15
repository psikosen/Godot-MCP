#!/bin/bash

echo "=== Complete MCP Server Reset ==="
echo

# Step 1: Kill everything
echo "1. Killing all Godot and MCP processes..."
killall Godot 2>/dev/null
ps aux | grep -E "(godot-mcp|Godot-MCP)" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
sleep 2

# Step 2: Start MCP server which will auto-launch Godot
echo "2. Starting MCP server (will auto-launch Godot)..."
cd /Users/raymondgonzalez/mcp/Godot-MCP/server

# Run in background and capture output
npm start 2>&1 &
SERVER_PID=$!

echo "   MCP server started with PID: $SERVER_PID"
echo

# Step 3: Wait for Godot to launch
echo "3. Waiting for Godot to launch..."
sleep 10

# Step 4: Check status
echo "4. Checking status..."
echo

# Check Godot
if ps aux | grep -E "Godot.*Godot-MCP" | grep -v grep > /dev/null; then
    echo "✓ Godot is running"
else
    echo "✗ Godot is not running"
fi

# Check WebSocket port
if lsof -i :9080 > /dev/null 2>&1; then
    echo "✓ WebSocket server is listening on port 9080"
else
    echo "✗ WebSocket server is NOT listening on port 9080"
    echo
    echo "MANUAL FIX REQUIRED:"
    echo "1. Open Godot (if not already open)"
    echo "2. Go to Project > Project Settings > Plugins"
    echo "3. Toggle 'Godot MCP' OFF then ON"
    echo "4. Check Godot console for 'MCP SERVER STARTING' message"
fi

echo
echo "=== Setup Complete ==="
echo
echo "If the WebSocket server isn't running:"
echo "- In Godot: Project > Project Settings > Plugins"
echo "- Toggle 'Godot MCP' OFF then ON"
echo
echo "To stop the MCP server: kill $SERVER_PID"
