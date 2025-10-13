# Auto-Launch Feature Guide

The Godot MCP server now includes an **automatic launch feature** that will start the Godot editor with your project when the MCP server starts!

## How It Works

When you start the MCP server (via Claude Desktop or the CLI), it will:

1. **Check if Godot is already running** by attempting to connect to the WebSocket server on port 9080
2. **Auto-launch Godot** if it's not running, using the configured executable and project path
3. **Wait for the WebSocket server to become available** (with a configurable timeout)
4. **Begin accepting MCP commands** once the connection is established

## Configuration

The auto-launch behavior is controlled by environment variables in the `.env` file:

```bash
# Path to your Godot project directory (containing project.godot)
GODOT_PROJECT_PATH=/Users/raymondgonzalez/mcp/Godot-MCP

# Path to the Godot executable
# macOS: /Applications/Godot.app/Contents/MacOS/Godot
# Windows: C:\Program Files\Godot\godot.exe
# Linux: /usr/bin/godot
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot

# Maximum time to wait for Godot to start (in milliseconds)
# Default: 30000 (30 seconds)
# Recommended: 45000 (45 seconds) for slower machines
GODOT_STARTUP_TIMEOUT=45000
```

### Platform-Specific Configuration

#### macOS
```bash
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot
```

#### Windows
```bash
GODOT_EXECUTABLE=C:\Program Files\Godot\godot.exe
# Or if using Godot from Steam:
GODOT_EXECUTABLE=C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.exe
```

#### Linux
```bash
GODOT_EXECUTABLE=/usr/bin/godot
# Or if installed via snap:
GODOT_EXECUTABLE=/snap/bin/godot
```

## Setup Steps

1. **Copy the environment template:**
   ```bash
   cd /Users/raymondgonzalez/mcp/Godot-MCP
   cp .env.example .env
   ```

2. **Edit `.env` to match your system:**
   - Update `GODOT_PROJECT_PATH` if your project is in a different location
   - Update `GODOT_EXECUTABLE` if Godot is installed in a non-standard location
   - Adjust `GODOT_STARTUP_TIMEOUT` if Godot takes longer to start

3. **Test the auto-launch:**
   ```bash
   cd server
   npm start
   ```

   You should see output like:
   ```
   Starting Godot MCP server...
   === Godot Launcher Configuration ===
   Project Path: /Users/raymondgonzalez/mcp/Godot-MCP
   Godot Executable: /Applications/Godot.app/Contents/MacOS/Godot
   Max Startup Time: 45000ms
   ===================================
   Checking if Godot is running...
   Godot is not running, launching it now...
   Launching Godot editor with project: /Users/raymondgonzalez/mcp/Godot-MCP
   Successfully connected to Godot WebSocket server
   Godot editor is ready!
   ```

## Troubleshooting

### Godot doesn't launch

**Check the executable path:**
```bash
# macOS - verify Godot exists
ls -la /Applications/Godot.app/Contents/MacOS/Godot

# Test launch manually
/Applications/Godot.app/Contents/MacOS/Godot --editor /Users/raymondgonzalez/mcp/Godot-MCP
```

**Common issues:**
- The Godot app is named differently (e.g., `Godot_v4.4-stable.app`)
- Godot is installed in a different location
- The executable doesn't have execution permissions

### Connection timeout

If you see "Timed out waiting for Godot WebSocket server to start":

1. **Increase the timeout** in `.env`:
   ```bash
   GODOT_STARTUP_TIMEOUT=60000  # 60 seconds
   ```

2. **Check if the WebSocket plugin is enabled:**
   - Open the project in Godot
   - Go to `Project > Project Settings > Plugins`
   - Ensure "Godot MCP" is enabled

3. **Verify the WebSocket server is starting:**
   - Check the Godot console for "MCP SERVER STARTING" messages
   - Ensure there are no errors in the plugin initialization

### Manual launch fallback

If auto-launch fails, the server will continue running and you can:

1. Manually launch Godot with the project
2. Ensure the plugin is enabled
3. The MCP server will automatically connect once the WebSocket server is available

## Advanced Options

### Disabling auto-launch

If you prefer to always manually launch Godot, comment out the auto-launch section in the server code:

```typescript
// Comment out this section in src/index.ts:
// try {
//   console.error('Checking if Godot is running...');
//   const launcher = getGodotLauncher();
//   await launcher.ensureGodotRunning();
//   console.error('Godot editor is ready!');
// } catch (error) {
//   ...
// }
```

### Auto-closing Godot on exit

By default, Godot stays open when the MCP server stops. To auto-close Godot:

1. Edit `server/src/index.ts`
2. Uncomment these lines in the cleanup function:
   ```typescript
   // Uncomment these lines:
   const launcher = getGodotLauncher();
   launcher.stop();
   ```

## Usage with Claude Desktop

The auto-launch feature works seamlessly with Claude Desktop:

1. **First time setup:** Configure the `.env` file as described above
2. **Start a conversation** with Claude that uses the Godot MCP server
3. **Godot will automatically launch** in the background
4. **Begin working** - Claude can now interact with your Godot project!

Example conversation:
```
You: "List the scenes in my Godot project"
Claude: [Auto-launches Godot if not running, then lists scenes]
```

## Performance Tips

- **Keep Godot open:** Once launched, keep Godot running between sessions for faster connections
- **Use an SSD:** Faster disk I/O significantly reduces Godot's startup time
- **Minimize addons:** Fewer enabled plugins = faster startup
- **Adjust timeout:** Set a realistic timeout based on your machine's performance

## Security Notes

- The auto-launch feature runs Godot with `--editor` flag (safe)
- No network ports are exposed beyond localhost:9080
- The WebSocket server only accepts local connections
- Process spawning is done securely with minimal privileges

## Logs and Debugging

Enable detailed logging by checking the console output:

```bash
# Run the server directly to see all logs
cd server
node dist/index.js
```

Look for:
- ✅ "Godot editor is ready!" = Success
- ⚠️ "Failed to ensure Godot is running" = Check configuration
- ⏱️ "Timed out waiting" = Increase timeout or check plugin

---

## Summary

The auto-launch feature makes working with Godot MCP effortless:

✅ **No manual steps** - Just start Claude and begin working  
✅ **Smart detection** - Only launches if Godot isn't already running  
✅ **Configurable** - Easy to adjust for your environment  
✅ **Reliable** - Includes retry logic and timeout handling  

Enjoy seamless Godot development with Claude! 🚀
