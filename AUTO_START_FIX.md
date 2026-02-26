# Godot MCP Auto-Start Fix

## Problem Identified

When the MCP server tried to connect to Godot, it was failing because:

1. **Godot was launching** correctly with `--editor` flag and the project path
2. **The plugin was enabled** in project.godot
3. **BUT the WebSocket server wasn't starting** automatically when Godot launched via command line

The issue was that EditorPlugins don't always fully initialize immediately when Godot is launched from the command line, especially the `_enter_tree()` method that starts the WebSocket server.

## Solution Implemented

### 1. Created Autoload Script (`autoload_mcp_server.gd`)

This script:
- Runs automatically when Godot starts (before the EditorPlugin)
- Continuously checks if the MCP WebSocket server is running
- Force-starts the server if it's not running
- Has retry logic to handle timing issues
- Can manually load and initialize the plugin if needed

### 2. Registered Autoload in `project.godot`

Added this section to project.godot:
```ini
[autoload]

MCPAutoload="*res://autoload_mcp_server.gd"
```

The `*` prefix means it runs in both editor and game mode (though we check for editor mode in the script).

### 3. Fixed Network Configuration

Updated `server/.env`:
- Changed `GODOT_WS_HOST` from `localhost` to `127.0.0.1` to force IPv4 (avoids IPv6 connection issues)
- Increased `GODOT_STARTUP_TIMEOUT` to 45 seconds to allow time for plugin initialization

## How It Works Now

```
User starts MCP → 
  MCP Server checks if Godot is running →
    If NOT running:
      Launch Godot with --editor and project path →
        Godot loads project →
          Autoload script runs immediately →
            Checks for MCP plugin →
              If plugin exists: Verify WebSocket server is active →
              If plugin missing: Load plugin manually →
                Start WebSocket server on port 9080 →
                  MCP Server connects successfully! ✅
```

## Testing the Fix

### Quick Test

```bash
cd /Users/raymondgonzalez/mcp/Godot-MCP/server
./test_auto_launch_v2.sh
```

This will:
1. Verify all files are in place
2. Launch Godot with the project
3. Wait for initialization
4. Check if port 9080 is listening
5. Report success or failure

### Manual Test

1. **Make sure no Godot is running:**
   ```bash
   killall Godot
   ```

2. **Start the MCP server:**
   ```bash
   cd /Users/raymondgonzalez/mcp/Godot-MCP/server
   npm start
   ```

3. **Watch the output:**
   You should see:
   ```
   Checking if Godot is running...
   Godot is not running, launching it now...
   Launching Godot editor with project: /Users/raymondgonzalez/mcp/Godot-MCP
   
   [From Godot console]:
   === MCP Autoload Starting ===
   Started MCP server check timer
   === MCP SERVER STARTING ===
   Listening on port 9080
   ✓ MCP WebSocket server is active on port 9080
   === MCP Autoload Complete ===
   
   [From MCP server]:
   Successfully connected to Godot WebSocket server
   Godot editor is ready!
   ```

### Using with Claude Desktop

1. Open Claude Desktop
2. Start a conversation
3. Ask Claude to use a Godot MCP tool (e.g., "list scenes")
4. Godot should auto-launch (if not already running)
5. Command should execute successfully

## Troubleshooting

### Port 9080 not listening after 15 seconds

**Check Godot Console:**
- Open Godot manually: `/Applications/Godot.app/Contents/MacOS/Godot --editor /Users/raymondgonzalez/mcp/Godot-MCP`
- Look for "MCP Autoload Starting" message
- Check for any error messages

**Verify plugin is enabled:**
- In Godot: Project > Project Settings > Plugins
- Ensure "Godot MCP" checkbox is checked
- If not, enable it and restart Godot

**Check autoload registration:**
- In Godot: Project > Project Settings > Autoload
- Verify "MCPAutoload" is listed
- Path should be: `res://autoload_mcp_server.gd`
- "Enable" checkbox should be checked

### "Failed to start MCP server after 10 attempts"

This means the autoload script couldn't initialize the plugin. Try:

1. **Manually run the force start script:**
   - Open `force_start_mcp.gd` in Godot
   - Click "File > Run" in the script editor
   - Check console output

2. **Reload the plugin:**
   - Disable the plugin in Project Settings
   - Close Godot
   - Open Godot again
   - Enable the plugin

3. **Check file permissions:**
   ```bash
   ls -la /Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/
   ls -la /Users/raymondgonzalez/mcp/Godot-MCP/autoload_mcp_server.gd
   ```

### MCP server times out waiting for connection

**Increase timeout:**
Edit `server/.env`:
```bash
GODOT_STARTUP_TIMEOUT=60000  # 60 seconds
```

**Check Godot is actually launching:**
```bash
ps aux | grep Godot
```

**Verify Godot executable path:**
```bash
ls -la /Applications/Godot.app/Contents/MacOS/Godot
```

### Connection refused (ECONNREFUSED)

This means Godot isn't listening on the port. Follow the steps in "Port 9080 not listening" above.

## Files Modified/Created

### Created:
- `/Users/raymondgonzalez/mcp/Godot-MCP/autoload_mcp_server.gd` - Autoload script that ensures MCP server starts
- `/Users/raymondgonzalez/mcp/Godot-MCP/server/test_auto_launch_v2.sh` - Test script

### Modified:
- `/Users/raymondgonzalez/mcp/Godot-MCP/project.godot` - Added autoload registration
- `/Users/raymondgonzalez/mcp/Godot-MCP/server/.env` - Fixed host to use 127.0.0.1, increased timeout

## Next Steps

1. **Test the setup** using the test script or manual test above
2. **If working:** You can now use the MCP server with Claude Desktop seamlessly
3. **If not working:** Follow the troubleshooting steps and check Godot console output

## Why This Approach Works

**Before:**
- EditorPlugin._enter_tree() was not being called reliably when Godot launched from CLI
- Race condition between MCP connection attempts and plugin initialization
- No fallback mechanism

**After:**
- Autoload script runs before EditorPlugin loads
- Active monitoring and retry logic
- Can manually initialize plugin if needed
- Clear logging for debugging
- More time for Godot to initialize (45s timeout)

## Additional Notes

- The autoload script only runs in editor mode (checks `Engine.is_editor_hint()`)
- It will stop trying after 10 attempts (5 seconds)
- It does not interfere with normal Godot operation
- The MCP plugin can still be manually controlled from Godot's plugin settings

---

**Status:** ✅ Ready to test  
**Last Updated:** 2025-10-16
