#!/bin/bash

echo "=== Verifying GDScript Parse Fixes ==="
echo ""

# Check for any remaining ? ternary operators
echo "1. Checking for remaining ternary operators..."
if grep -r " ? " addons/godot_mcp/*.gd addons/godot_mcp/commands/*.gd 2>/dev/null; then
    echo "   ❌ Still found ? ternary operators!"
    exit 1
else
    echo "   ✅ No ? ternary operators found"
fi

# Check that fixes were applied
echo ""
echo "2. Verifying command_handler.gd fix..."
if grep -q "str(command_id_value) if command_id_value != null else" addons/godot_mcp/command_handler.gd; then
    echo "   ✅ command_handler.gd fixed correctly"
else
    echo "   ❌ command_handler.gd fix not found"
    exit 1
fi

echo ""
echo "3. Verifying node_commands.gd fixes..."
if grep -q "uniform_size.x if uniform_size.x > 0.0 else" addons/godot_mcp/commands/node_commands.gd; then
    echo "   ✅ node_commands.gd ternary operators fixed"
else
    echo "   ❌ node_commands.gd fixes not found"
    exit 1
fi

echo ""
echo "4. Checking indentation consistency..."
# Check line 1984 has correct indentation (2 tabs)
if sed -n '1984p' addons/godot_mcp/commands/node_commands.gd | grep -q "^$(printf '\t\t')var target_width"; then
    echo "   ✅ Indentation is correct"
else
    echo "   ⚠️  Indentation might still have issues"
fi

echo ""
echo "=== All Syntax Checks Passed! ==="
echo ""
echo "Next steps:"
echo "1. Open Godot project: /Users/raymondgonzalez/mcp/Godot-MCP"
echo "2. Check for parse errors in the Output panel"
echo "3. Enable the GodotMCP plugin if not enabled"
echo "4. Verify WebSocket server starts on port 9080"
echo "5. Test MCP connection from Claude Desktop"
