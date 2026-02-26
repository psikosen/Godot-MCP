#!/bin/bash

# Test script to verify Godot MCP auto-launch setup

echo "==================================="
echo "Godot MCP Auto-Launch Test"
echo "==================================="
echo ""

# Check if Godot executable exists
GODOT_EXEC="/Applications/Godot.app/Contents/MacOS/Godot"
if [ ! -f "$GODOT_EXEC" ]; then
    echo "❌ Godot executable not found at: $GODOT_EXEC"
    echo "Please update GODOT_EXECUTABLE in server/.env"
    exit 1
fi
echo "✅ Godot executable found"

# Check if project.godot exists
PROJECT_FILE="../project.godot"
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ project.godot not found"
    exit 1
fi
echo "✅ project.godot found"

# Check if autoload script exists
AUTOLOAD_SCRIPT="../autoload_mcp_server.gd"
if [ ! -f "$AUTOLOAD_SCRIPT" ]; then
    echo "❌ autoload_mcp_server.gd not found"
    exit 1
fi
echo "✅ Autoload script found"

# Check if plugin exists
PLUGIN_SCRIPT="../addons/godot_mcp/mcp_server.gd"
if [ ! -f "$PLUGIN_SCRIPT" ]; then
    echo "❌ MCP plugin not found"
    exit 1
fi
echo "✅ MCP plugin found"

echo ""
echo "==================================="
echo "Testing Manual Godot Launch"
echo "==================================="
echo ""

# Kill any existing Godot processes
echo "Checking for existing Godot processes..."
if pgrep -x "Godot" > /dev/null; then
    echo "⚠️  Godot is already running. Killing it..."
    killall Godot
    sleep 2
fi

# Launch Godot with the project
echo "Launching Godot with project..."
"$GODOT_EXEC" --editor "$(cd .. && pwd)" &
GODOT_PID=$!

echo "Godot launched with PID: $GODOT_PID"
echo "Waiting for Godot to initialize (15 seconds)..."
sleep 15

# Check if port 9080 is listening
echo ""
echo "Checking if WebSocket server is listening on port 9080..."
if lsof -i :9080 > /dev/null 2>&1; then
    echo "✅ Port 9080 is open - WebSocket server is running!"
    echo ""
    echo "==================================="
    echo "SUCCESS!"
    echo "==================================="
    echo ""
    echo "The MCP server should now be able to connect."
    echo "You can now test the MCP server with:"
    echo "  cd server"
    echo "  npm start"
    echo ""
    echo "Press Ctrl+C when done, or leave Godot running."
else
    echo "❌ Port 9080 is not open"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check Godot console for any errors"
    echo "2. Verify the plugin is enabled in Project > Project Settings > Plugins"
    echo "3. Check if autoload script is registered"
    echo "4. Try manually running force_start_mcp.gd from Godot"
    echo ""
    echo "Keeping Godot open for inspection..."
fi

# Keep script running
read -p "Press Enter to close Godot and exit..."
kill $GODOT_PID 2>/dev/null
