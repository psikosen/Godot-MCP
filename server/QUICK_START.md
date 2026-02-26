# Quick Reference: Godot MCP Auto-Launch

## ✅ What's Fixed
- Auto-detects your project at `/Users/raymondgonzalez/mcp/Godot-MCP/`
- Validates `project.godot` exists before launching
- Automatically launches Godot if not running
- Configurable via environment variables
- Clear error messages with troubleshooting tips

## 🚀 Quick Start

```bash
cd /Users/raymondgonzalez/mcp/Godot-MCP/server

# Test the auto-launch
node test_auto_launch.js

# Start the MCP server (uses auto-detection)
npm start
```

## 📋 What to Expect

### First Run (Godot NOT Running)
1. Server detects project at `/Users/raymondgonzalez/mcp/Godot-MCP/`
2. Sees Godot is not running
3. **Launches Godot with your project**
4. Waits for WebSocket plugin to start (up to 30 seconds)
5. Connects successfully
6. Ready for commands! 🎉

### Subsequent Runs (Godot Already Running)
1. Server detects project
2. Sees Godot is already running
3. Connects immediately
4. Ready for commands! 🎉

## ⚙️ Optional Configuration

Create `.env` file (only if you want to customize):
```bash
cp .env.example .env
# Edit if needed - defaults work perfectly for your setup
```

## 🔍 Verify It Works

```bash
# Build the updated code
npm run build

# Test auto-launch
node test_auto_launch.js

# Expected output:
# ✅ Launcher instance created successfully
# ✅ Godot launched successfully (or already running)
# ✅ Connection verified
# 🎉 SUCCESS! Auto-launch is working correctly!
```

## 🐛 Common Startup Messages (NORMAL!)

You might see this during startup - **this is expected**:
```
Connecting to Godot WebSocket server at ws://localhost:9080... (Attempt 1/4)
WebSocket error: ... ECONNREFUSED
```

The launcher will:
- Launch Godot if needed
- Wait for plugin to activate
- Retry connection automatically
- Connect successfully when ready

## 📞 Need Help?

If you see:
- "Could not find Godot project" → Check `/Users/raymondgonzalez/mcp/Godot-MCP/project.godot` exists
- "Timed out" → Increase timeout with `export GODOT_STARTUP_TIMEOUT=60000`
- "Failed to launch" → Check Godot path at `/Applications/Godot.app/Contents/MacOS/Godot`

## ✨ Key Improvements

| Before | After |
|--------|-------|
| ❌ Manual project selection required | ✅ Auto-detects project |
| ❌ Godot must be running first | ✅ Auto-launches if needed |
| ❌ Hardcoded paths and ports | ✅ Environment variables |
| ❌ Cryptic error messages | ✅ Clear troubleshooting info |

Now just **start the server and it works!** 🎊
