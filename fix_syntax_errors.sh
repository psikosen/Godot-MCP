#!/bin/bash

# Fix GDScript syntax errors in Godot MCP

echo "=== Fixing GDScript Syntax Errors ==="

# Backup files
cp addons/godot_mcp/command_handler.gd addons/godot_mcp/command_handler.gd.bak
cp addons/godot_mcp/commands/node_commands.gd addons/godot_mcp/commands/node_commands.gd.bak

echo "Backups created..."

# Fix command_handler.gd - line 93
# Change: command_id = command_id_value != null ? str(command_id_value) : ""
# To:     command_id = str(command_id_value) if command_id_value != null else ""
sed -i '' 's/command_id = command_id_value != null ? str(command_id_value) : ""/command_id = str(command_id_value) if command_id_value != null else ""/' addons/godot_mcp/command_handler.gd

echo "Fixed command_handler.gd line 93..."

# Fix node_commands.gd - replace all ? : ternary operators with if/else syntax
sed -i '' 's/uniform_size\.x > 0\.0 ? uniform_size\.x : /uniform_size.x if uniform_size.x > 0.0 else /' addons/godot_mcp/commands/node_commands.gd
sed -i '' 's/uniform_size\.y > 0\.0 ? uniform_size\.y : /uniform_size.y if uniform_size.y > 0.0 else /' addons/godot_mcp/commands/node_commands.gd
sed -i '' 's/arr\.size() > 3 ? float(arr\[3\]) : /float(arr[3]) if arr.size() > 3 else /' addons/godot_mcp/commands/node_commands.gd
sed -i '' 's/value is Color ? value\.to_html(true) : /value.to_html(true) if value is Color else /' addons/godot_mcp/commands/node_commands.gd

echo "Fixed node_commands.gd ternary operators..."

echo "=== Syntax fixes complete ==="
echo ""
echo "Testing if Godot can parse the files now..."
