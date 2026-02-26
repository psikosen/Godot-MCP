#!/bin/bash
# Start Godot with the MCP project if not already running

# Check if Godot is already running
if ! pgrep -x "Godot" > /dev/null; then
    echo "Starting Godot with MCP project..."
    open -a /Applications/Godot.app /Users/raymondgonzalez/mcp/Godot-MCP/project.godot
    echo "Waiting for Godot to initialize..."
    sleep 5
    echo "✅ Godot is ready for Claude!"
else
    echo "✅ Godot is already running"
fi
