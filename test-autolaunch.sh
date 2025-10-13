#!/bin/bash

echo "==================================="
echo "  Godot MCP Auto-Launch Test"
echo "==================================="
echo ""

# Check if Godot executable exists
GODOT_EXEC="${GODOT_EXECUTABLE:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [ ! -f "$GODOT_EXEC" ]; then
    echo "❌ Godot executable not found at: $GODOT_EXEC"
    echo ""
    echo "Please set GODOT_EXECUTABLE in .env file or run:"
    echo "export GODOT_EXECUTABLE=/path/to/godot"
    exit 1
fi

echo "✅ Found Godot executable: $GODOT_EXEC"

# Check if project.godot exists
PROJECT_PATH="${GODOT_PROJECT_PATH:-$(dirname "$0")}"
if [ ! -f "$PROJECT_PATH/project.godot" ]; then
    echo "❌ project.godot not found in: $PROJECT_PATH"
    echo ""
    echo "Please set GODOT_PROJECT_PATH in .env file or run:"
    echo "export GODOT_PROJECT_PATH=/path/to/project"
    exit 1
fi

echo "✅ Found Godot project: $PROJECT_PATH/project.godot"
echo ""

# Load .env if it exists
if [ -f "$PROJECT_PATH/.env" ]; then
    echo "📝 Loading configuration from .env..."
    export $(cat "$PROJECT_PATH/.env" | grep -v '^#' | xargs)
    echo ""
fi

echo "==================================="
echo "Configuration:"
echo "==================================="
echo "Project Path: ${GODOT_PROJECT_PATH:-$PROJECT_PATH}"
echo "Godot Executable: ${GODOT_EXECUTABLE:-$GODOT_EXEC}"
echo "Startup Timeout: ${GODOT_STARTUP_TIMEOUT:-30000}ms"
echo "WebSocket Port: 9080"
echo ""

# Check if Godot is already running
echo "Checking if Godot is already running..."
if lsof -i:9080 >/dev/null 2>&1; then
    echo "⚠️  Port 9080 is already in use (Godot may be running)"
    echo ""
    read -p "Kill existing process and continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Killing process on port 9080..."
        lsof -ti:9080 | xargs kill -9 2>/dev/null
        sleep 2
    else
        echo "Test cancelled."
        exit 0
    fi
fi

echo "✅ Port 9080 is available"
echo ""

# Test manual launch
echo "==================================="
echo "Testing manual Godot launch..."
echo "==================================="
echo ""
echo "Launching Godot with project..."
echo "Command: $GODOT_EXEC --editor $PROJECT_PATH"
echo ""

# Launch Godot in the background
"$GODOT_EXEC" --editor "$PROJECT_PATH" &
GODOT_PID=$!

echo "✅ Godot launched with PID: $GODOT_PID"
echo ""

# Wait for WebSocket server to start
echo "Waiting for WebSocket server to start on port 9080..."
MAX_WAIT=30
WAIT_COUNT=0

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    if lsof -i:9080 >/dev/null 2>&1; then
        echo "✅ WebSocket server is running!"
        echo ""
        echo "==================================="
        echo "  ✅ Auto-Launch Test PASSED!"
        echo "==================================="
        echo ""
        echo "You can now:"
        echo "1. Test the MCP server: cd server && npm start"
        echo "2. Use with Claude Desktop"
        echo "3. Close Godot to clean up this test"
        echo ""
        exit 0
    fi
    
    echo -n "."
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

echo ""
echo "❌ WebSocket server did not start within ${MAX_WAIT} seconds"
echo ""
echo "Please check:"
echo "1. Open Godot and check for errors in the console"
echo "2. Verify the 'Godot MCP' plugin is enabled"
echo "3. Check if there are any plugin initialization errors"
echo ""
echo "Godot is still running (PID: $GODOT_PID)"
echo "You can close it manually or run: kill $GODOT_PID"
echo ""
exit 1
