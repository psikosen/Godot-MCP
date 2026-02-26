#!/bin/bash

# Fix JavaScript-style ternary operators in GDScript files
# Pattern: condition ? true_value : false_value
# Becomes: true_value if condition else false_value

cd /Users/raymondgonzalez/mcp/Godot-MCP

files=(
    "addons/godot_mcp/ui/mcp_panel.gd"
    "addons/godot_mcp/utils/scene_transaction_manager.gd"
    "addons/godot_mcp/commands/editor_commands.gd"
    "addons/godot_mcp/commands/project_commands.gd"
    "addons/godot_mcp/commands/rendering_commands.gd"
    "addons/godot_mcp/commands/animation_commands.gd"
    "addons/godot_mcp/commands/script_commands.gd"
    "addons/godot_mcp/commands/scene_commands.gd"
    "addons/godot_mcp/commands/node_commands.gd"
    "addons/godot_mcp/commands/base_command_processor.gd"
    "addons/godot_mcp/commands/navigation_commands.gd"
    "addons/godot_mcp/commands/xr_commands.gd"
    "addons/godot_mcp/commands/multiplayer_commands.gd"
)

echo "==================================="
echo "Fixing Ternary Operators"
echo "==================================="

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        # Create backup
        cp "$file" "$file.backup"
        
        # Use Python for more reliable replacement
        python3 - "$file" <<'EOF'
import sys
import re

filepath = sys.argv[1]

with open(filepath, 'r') as f:
    content = f.read()

# Pattern to match: expr1 ? expr2 : expr3
# This is a simple pattern that works for single-line ternaries
pattern = r'(\w+(?:\([^)]*\))?(?:\.[a-zA-Z_]\w*(?:\([^)]*\))?)*)\s*\?\s*([^:]+?)\s*:\s*([^,\n;)\]]+)'

def replace_ternary(match):
    condition = match.group(1).strip()
    true_val = match.group(2).strip()
    false_val = match.group(3).strip()
    return f"{true_val} if {condition} else {false_val}"

# Replace all ternaries
new_content = re.sub(pattern, replace_ternary, content)

if new_content != content:
    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"  ✓ Fixed {filepath}")
else:
    print(f"  - No changes needed")

EOF
    else
        echo "  ✗ File not found: $file"
    fi
done

echo "==================================="
echo "Done!"
echo "===================================" 
