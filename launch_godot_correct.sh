#!/bin/bash

# Kill existing Godot instance if running wrong project
echo "Checking for existing Godot instances..."
EXISTING_PID=$(ps aux | grep -i "[G]odot.*--editor" | grep -v "Godot-MCP" | awk '{print $2}')

if [ ! -z "$EXISTING_PID" ]; then
    echo "Found Godot running with wrong project (PID: $EXISTING_PID)"
    echo "Stopping existing Godot instance..."
    kill $EXISTING_PID
    sleep 2
fi

# Check if Godot is already running with correct project
CORRECT_PID=$(ps aux | grep -i "[G]odot.*Godot-MCP.*--editor" | awk '{print $2}')

if [ ! -z "$CORRECT_PID" ]; then
    echo "Godot is already running with Godot-MCP project (PID: $CORRECT_PID)"
else
    echo "Starting Godot with Godot-MCP project..."
    /Applications/Godot.app/Contents/MacOS/Godot --path /Users/raymondgonzalez/mcp/Godot-MCP --editor &
    echo "Godot launched with PID: $!"
    sleep 3
fi

echo "Done!"
