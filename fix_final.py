#!/usr/bin/env python3
"""
Final fix for all remaining space indentation in base_command_processor.gd
"""

import re

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/base_command_processor.gd"

with open(file_path, 'r') as f:
    lines = f.readlines()

fixed_lines = []
for line in lines:
    # Replace any sequence of 8 spaces with a tab, repeatedly
    while '        ' in line:  # 8 spaces
        line = line.replace('        ', '\t', 1)
    
    # Also handle 4 spaces that might be intended as half-tabs
    # But only if they appear after tabs (for additional indentation)
    if '\t    ' in line:
        line = line.replace('\t    ', '\t\t')
    
    fixed_lines.append(line)

with open(file_path, 'w') as f:
    f.writelines(fixed_lines)

print("Final indentation fix applied")
print("All sequences of 8 spaces have been converted to tabs")

# Let's also verify the specific problem area
print("\nVerifying lines 140-145:")
with open(file_path, 'r') as f:
    lines = f.readlines()
    for i in range(139, min(145, len(lines))):
        # Show the indentation pattern
        line = lines[i]
        display = line.replace('\t', '<TAB>').replace(' ', '<SP>')
        print(f"Line {i+1}: {display[:60]}...")
