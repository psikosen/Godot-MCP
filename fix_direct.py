#!/usr/bin/env python3
"""
Direct fix for base_command_processor.gd indentation
"""

import re

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/base_command_processor.gd"

with open(file_path, 'r') as f:
    content = f.read()

# Fix the specific pattern: tab followed by spaces
# Replace tab + 8 spaces with 2 tabs
content = re.sub(r'\t        ', '\t\t', content)
# Replace tab + 16 spaces with 3 tabs  
content = re.sub(r'\t                ', '\t\t\t', content)
# Replace tab + 24 spaces with 4 tabs
content = re.sub(r'\t                        ', '\t\t\t\t', content)
# Replace tab + 32 spaces with 5 tabs
content = re.sub(r'\t                                ', '\t\t\t\t\t', content)

# Also fix any lines that start with just spaces (no initial tab)
lines = content.split('\n')
fixed_lines = []
for line in lines:
    if line and not line.startswith('\t') and line.startswith(' '):
        # Count leading spaces and convert to tabs
        stripped = line.lstrip(' ')
        space_count = len(line) - len(stripped)
        tab_count = space_count // 8
        if space_count % 8 >= 4:
            tab_count += 1
        line = '\t' * tab_count + stripped
    fixed_lines.append(line)

content = '\n'.join(fixed_lines)

with open(file_path, 'w') as f:
    f.write(content)

print("Fixed indentation in base_command_processor.gd")
print("All space-based indentation has been converted to tabs")
