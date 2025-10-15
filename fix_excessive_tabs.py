#!/usr/bin/env python3
"""
Fix the double-tab indentation issue on lines like "var updated_path = node.get_path()"
"""

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"

# Read the file
with open(file_path, 'r') as f:
    lines = f.readlines()

fixed_lines = []
for i, line in enumerate(lines, 1):
    # Fix lines that have excessive indentation (3+ tabs when should be 2)
    if line.startswith('\t\t\t\t'):
        # Check if it should be 2 tabs instead
        stripped = line.lstrip('\t')
        tab_count = len(line) - len(stripped)
        
        # Context check: if it's a var declaration and has 4+ tabs, reduce to 2
        if stripped.strip().startswith('var ') and tab_count >= 4:
            fixed_line = '\t\t' + stripped
            fixed_lines.append(fixed_line)
            print(f"Line {i}: Reduced excessive tabs (was {tab_count}, now 2)")
        else:
            fixed_lines.append(line)
    else:
        fixed_lines.append(line)

# Write back
with open(file_path, 'w') as f:
    f.writelines(fixed_lines)

print(f"\nFixed excessive indentation in {file_path}")
