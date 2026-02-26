# IPv4/IPv6 Connection Fix

## Problem Diagnosed

The MCP server was failing to connect with error:
```
WebSocket error: Error: connect ECONNREFUSED ::1:9080
```

**Root Cause:** The Node.js WebSocket client was trying to connect via IPv6 (`::1`) but Godot's WebSocket server needed to explicitly listen on IPv4 (`127.0.0.1`).

## Fixes Applied

### 1. Updated `.env` - Force IPv4 Connection
Added explicit IPv4 configuration:
```bash
# Force IPv4 connection (Godot WebSocket only listens on IPv4)
GODOT_WS_HOST=127.0.0.1
GODOT_WS_PORT=9080
GODOT_WS_TIMEOUT=30000
GODOT_WS_MAX_RETRIES=10
GODOT_WS_RETRY_DELAY=3000
```

**Effect:** 
- Forces Node.js to connect via IPv4 (127.0.0.1) instead of letting DNS resolve "localhost" to IPv6
- Increases retries to 10 attempts with 3-second delays
- Gives Godot 30 seconds per connection attempt

### 2. Modified `websocket_server.gd` - Bind to IPv4
Changed line in `start_server()`:
```gdscript
# OLD
var err = tcp_server.listen(_port)

# NEW  
var err = tcp_server.listen(_port, "127.0.0.1")
```

**Effect:** Godot WebSocket server now explicitly listens only on IPv4 127.0.0.1, preventing any IPv6 confusion.

## Testing Instructions

1. **Restart Claude Desktop** (to reload the .env changes)

2. **Start fresh** - Close any open Godot instances

3. **Enable the MCP server** in Claude Desktop:
   - Go to Settings → Developer → Edit Config
   - Ensure the Godot MCP server is listed
   - Restart if needed

4. **Test the connection:**
   - Open a chat with Claude
   - Ask: "Can you connect to Godot?"
   - The MCP server should auto-launch Godot
   - Wait 10-15 seconds for Godot to fully load
   - You should see success messages

## Expected Behavior

### In Node.js logs (Claude Desktop):
```
Starting Godot MCP server...
Connecting to Godot WebSocket server at ws://127.0.0.1:9080...
Launching Godot editor with project: /Users/raymondgonzalez/mcp/Godot-MCP
Connected to Godot WebSocket server
Godot editor is ready!
```

### In Godot console:
```
=== MCP Autoload Starting ===
MCP WebSocket server started on IPv4 127.0.0.1:9080
✓ MCP WebSocket server is active on port 9080
=== MCP Autoload Complete ===
```

## Alternative: Manual Launch

If auto-launch still has issues, you can manually open Godot first:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --editor /Users/raymondgonzalez/mcp/Godot-MCP
```

Then the MCP server will connect to the already-running instance.

## Troubleshooting

### If connection still fails:

1. **Check if Godot is actually running:**
   ```bash
   lsof -i :9080
   ```
   Should show Godot listening on port 9080

2. **Check Godot console** for plugin errors

3. **Verify plugin is enabled:**
   - In Godot: Project → Project Settings → Plugins
   - "Godot MCP" should be checked/enabled

4. **Check if WebSocket is active in Godot console:**
   - Look for "MCP WebSocket server started on IPv4 127.0.0.1:9080"
   - If missing, the autoload might not be running

## Technical Notes

- **Why IPv4 only?** The WebSocket implementation in the MCP server uses Node.js's `ws` library, which can resolve "localhost" to either IPv4 or IPv6 depending on system DNS configuration. macOS 10.15+ prefers IPv6, causing connection failures.
- **Why explicit bind?** Godot's `TCPServer.listen(port)` defaults to listening on all interfaces ("*"), which works, but explicitly binding to "127.0.0.1" ensures we're only listening on the IPv4 loopback interface.
- **Why more retries?** Godot takes 5-15 seconds to fully start, load plugins, and initialize the WebSocket server. The increased retries (10 × 3s = 30s) gives enough time for startup.

## Files Modified

1. `/Users/raymondgonzalez/mcp/Godot-MCP/.env`
2. `/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/websocket_server.gd`
3. Server rebuilt with: `cd server && npm run build`
