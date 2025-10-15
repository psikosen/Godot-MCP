#!/bin/bash

echo "=== Godot MCP Diagnostic & Fix Script ==="
echo

# Step 1: Clean up stale processes
echo "Step 1: Cleaning up stale processes..."
ps aux | grep "godot-mcp/build/index.js" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
echo "✓ Cleaned up stale node processes"
echo

# Step 2: Check if Godot is running
echo "Step 2: Checking Godot status..."
GODOT_PID=$(ps aux | grep -E "Godot.*--path.*Godot-MCP" | grep -v grep | awk '{print $2}')
if [ -z "$GODOT_PID" ]; then
    echo "✗ Godot is not running"
else
    echo "✓ Godot is running (PID: $GODOT_PID)"
fi
echo

# Step 3: Check port 9080
echo "Step 3: Checking WebSocket port 9080..."
if lsof -i :9080 > /dev/null 2>&1; then
    echo "✓ Port 9080 is in use (WebSocket server might be running)"
    lsof -i :9080
else
    echo "✗ Port 9080 is not in use (WebSocket server not running)"
fi
echo

# Step 4: Test WebSocket connection
echo "Step 4: Testing WebSocket connection..."
if command -v nc &> /dev/null; then
    if nc -z localhost 9080 2>/dev/null; then
        echo "✓ Can connect to port 9080"
    else
        echo "✗ Cannot connect to port 9080"
    fi
else
    echo "- netcat not available for testing"
fi
echo

# Step 5: Provide recommendations
echo "=== Recommendations ==="
echo
if [ -z "$GODOT_PID" ]; then
    echo "1. Start Godot manually:"
    echo "   /Applications/Godot.app/Contents/MacOS/Godot --editor /Users/raymondgonzalez/mcp/Godot-MCP"
    echo
    echo "2. Once Godot opens, verify the plugin is enabled:"
    echo "   - Go to Project > Project Settings > Plugins"
    echo "   - Ensure 'Godot MCP' is enabled"
    echo
else
    echo "1. Godot is running. Check the Godot console for errors:"
    echo "   - Look for 'MCP SERVER STARTING' message"
    echo "   - Check for any error messages"
    echo
    echo "2. Try disabling and re-enabling the plugin:"
    echo "   - Go to Project > Project Settings > Plugins"
    echo "   - Disable 'Godot MCP'"
    echo "   - Save and re-enable it"
    echo
    echo "3. If the WebSocket server still doesn't start:"
    echo "   - Close Godot completely"
    echo "   - Run: killall Godot"
    echo "   - Start fresh with the MCP server"
fi

echo
echo "=== Quick Fix Option ==="
echo "To restart everything fresh, run these commands:"
echo
echo "# Kill all Godot and MCP processes"
echo "killall Godot 2>/dev/null"
echo "ps aux | grep 'godot-mcp' | grep -v grep | awk '{print \$2}' | xargs kill -9 2>/dev/null"
echo
echo "# Start the MCP server (which will auto-launch Godot)"
echo "cd /Users/raymondgonzalez/mcp/Godot-MCP/server"
echo "npm start"
echo
echo "=== Alternative: Disable Auto-Launch ==="
echo "If auto-launch continues to cause issues, you can disable it:"
echo "1. Edit /Users/raymondgonzalez/mcp/Godot-MCP/.env"
echo "2. Comment out GODOT_EXECUTABLE line"
echo "3. Start Godot manually before running the MCP server"
