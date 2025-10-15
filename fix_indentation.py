#!/usr/bin/env python3
"""
Fix specific indentation and syntax issues in node_commands.gd
"""

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"

# Read the file
with open(file_path, 'r') as f:
    lines = f.readlines()

fixed_lines = []
for i, line in enumerate(lines, 1):
    # Fix any line that starts with a single space followed by 'var'
    if line.startswith(' var '):
        # Replace leading space with proper tabs (should be 2 tabs based on context)
        fixed_line = '\t\t' + line.lstrip()
        fixed_lines.append(fixed_line)
        print(f"Line {i}: Fixed leading space before 'var'")
    # Fix lines with weird indentation (double tabs followed by space)
    elif line.startswith('\t\t        '):
        # Replace with proper indentation
        fixed_line = '\t\t' + line.lstrip()
        fixed_lines.append(fixed_line)
        print(f"Line {i}: Fixed mixed tab/space indentation")
    else:
        fixed_lines.append(line)

# Write back
with open(file_path, 'w') as f:
    f.writelines(fixed_lines)

print(f"\nFixed indentation issues in {file_path}")
