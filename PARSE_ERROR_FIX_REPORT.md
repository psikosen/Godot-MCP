# Godot MCP Parse Error Diagnosis and Fix

## Date: 2025-10-13

## Error Summary
```
ERROR: res://addons/godot_mcp/mcp_server.gd:45 - Parse Error: Could not preload resource script "res://addons/godot_mcp/command_handler.gd".
ERROR: res://addons/godot_mcp/mcp_server.gd:45 - Parse Error: Could not resolve script "res://addons/godot_mcp/command_handler.gd".
ERROR: modules/gdscript/gdscript.cpp:3022 - Failed to load script "res://addons/godot_mcp/mcp_server.gd" with error "Parse error".
```

## Root Cause

The issue was in `addons/godot_mcp/command_handler.gd` at the `_initialize_processors()` function (lines 18-35 of the original file).

### Problem Details:

The command_handler.gd file was referencing command processor classes directly without preloading them:

```gdscript
func _initialize_processors() -> void:
	var processor_classes: Array = [
		MCPNodeCommands,           # ❌ No preload statement
		MCPScriptCommands,         # ❌ No preload statement
		MCPSceneCommands,          # ❌ No preload statement
		MCPProjectCommands,        # ❌ No preload statement
		MCPEditorCommands,         # ❌ No preload statement
		MCPEditorScriptCommands,   # ❌ No preload statement
		MCPNavigationCommands,     # ❌ No preload statement
		MCPAnimationCommands,      # ❌ No preload statement
		MCPXRCommands,             # ❌ No preload statement
		MCPMultiplayerCommands,    # ❌ No preload statement
		MCPCompressionCommands,    # ❌ No preload statement
		MCPRenderingCommands,      # ❌ No preload statement
	]
	# ... rest of function
```

### Why This Caused the Error:

1. When Godot 4 loads the plugin, it tries to parse `mcp_server.gd`
2. `mcp_server.gd` line 45 attempts to preload `command_handler.gd`
3. During parsing of `command_handler.gd`, Godot encounters references to classes (MCPNodeCommands, etc.) that haven't been explicitly loaded yet
4. While these classes have `class_name` declarations in their respective files, the timing of script registration during plugin initialization can cause them to be unresolved
5. This creates a parsing error, which cascades back to prevent `mcp_server.gd` from loading

## The Fix

Added explicit preload statements at the top of `command_handler.gd`:

```gdscript
@tool
class_name MCPCommandHandler
extends Node

# Preload all command processor classes
const MCPNodeCommands = preload("res://addons/godot_mcp/commands/node_commands.gd")
const MCPScriptCommands = preload("res://addons/godot_mcp/commands/script_commands.gd")
const MCPSceneCommands = preload("res://addons/godot_mcp/commands/scene_commands.gd")
const MCPProjectCommands = preload("res://addons/godot_mcp/commands/project_commands.gd")
const MCPEditorCommands = preload("res://addons/godot_mcp/commands/editor_commands.gd")
const MCPEditorScriptCommands = preload("res://addons/godot_mcp/commands/editor_script_commands.gd")
const MCPNavigationCommands = preload("res://addons/godot_mcp/commands/navigation_commands.gd")
const MCPAnimationCommands = preload("res://addons/godot_mcp/commands/animation_commands.gd")
const MCPXRCommands = preload("res://addons/godot_mcp/commands/xr_commands.gd")
const MCPMultiplayerCommands = preload("res://addons/godot_mcp/commands/multiplayer_commands.gd")
const MCPCompressionCommands = preload("res://addons/godot_mcp/commands/compression_commands.gd")
const MCPRenderingCommands = preload("res://addons/godot_mcp/commands/rendering_commands.gd")

# ... rest of the file
```

## Files Modified

1. **command_handler.gd** - Added 12 preload statements
2. **command_handler_BACKUP.gd** - Backup of original file

## Next Steps

1. Restart Godot Editor or reload the project
2. The plugin should now load without parse errors
3. The MCP server should initialize properly on startup

## Technical Notes

- This is a common pattern in Godot 4 plugins that need to reference multiple classes
- Using explicit `preload()` ensures proper dependency resolution during script parsing
- The `class_name` declarations are still important for global class registration, but preload ensures they're available when the script is parsed
- This issue specifically manifests with `@tool` scripts (editor plugins) because they're parsed immediately when the editor starts

## Verification

To verify the fix worked:

1. Open Godot Editor
2. Check the Output panel for the startup messages - should see:
   - "=== MCP SERVER STARTING ==="
   - "Listening on port 9080"
   - "=== MCP SERVER INITIALIZED ==="
3. No parse errors should appear in the console

## Related Files Structure

```
addons/godot_mcp/
├── command_handler.gd (FIXED)
├── command_handler_BACKUP.gd (original backup)
├── mcp_server.gd (plugin entry point)
├── commands/
│   ├── base_command_processor.gd
│   ├── node_commands.gd
│   ├── script_commands.gd
│   ├── scene_commands.gd
│   ├── project_commands.gd
│   ├── editor_commands.gd
│   ├── editor_script_commands.gd
│   ├── navigation_commands.gd
│   ├── animation_commands.gd
│   ├── xr_commands.gd
│   ├── multiplayer_commands.gd
│   ├── compression_commands.gd
│   └── rendering_commands.gd
└── utils/
    ├── scene_transaction_manager.gd
    ├── script_utils.gd
    ├── node_utils.gd
    └── resource_utils.gd
```
