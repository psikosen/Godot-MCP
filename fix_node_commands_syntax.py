#!/usr/bin/env python3
"""
Fix all syntax errors in node_commands.gd:
1. Fix backwards ternary operators
2. Remove duplicate function definitions
3. Fix indentation issues
"""

import re

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"

# Read the file
with open(file_path, 'r') as f:
    content = f.read()

# Split by functions to detect duplicates
lines = content.split('\n')

# Find where duplication starts (after first _is_interactive_control)
first_interactive_idx = None
second_interactive_idx = None

for i, line in enumerate(lines):
    if 'func _is_interactive_control(control: Control) -> bool:' in line:
        if first_interactive_idx is None:
            first_interactive_idx = i
        elif second_interactive_idx is None:
            second_interactive_idx = i
            break

# If we found duplicate section, remove it
if second_interactive_idx:
    print(f"Found duplicate section starting at line {second_interactive_idx}")
    # Keep only up to the first _is_interactive_control function and its body
    lines = lines[:second_interactive_idx]

# Rejoin the content
content = '\n'.join(lines)

# Fix Pattern 1: "updated_path if var path_string = typeof..."
# Should be: "var path_string = updated_path if typeof..."
pattern1 = r'(\s*)(\w+)\s+if\s+var\s+(\w+)\s*=\s*typeof\((\w+)\)\s*==\s*(TYPE_\w+)\s+else\s+([\w.()]+)'
replacement1 = r'\1var \3 = \2 if typeof(\4) == \5 else \6'
content = re.sub(pattern1, replacement1, content)

# Fix Pattern 2: "uniform_size.x if var target_width := ..."
# Should be: "var target_width := uniform_size.x if ..."
pattern2 = r'(\s*)(\w+\.\w+)\s+if\s+var\s+(\w+)\s*:=\s*([\w.()]+\s*>\s*[\d.]+)\s+else\s+([\w.()]+)'
replacement2 = r'\1var \3 := \2 if \4 else \5'
content = re.sub(pattern2, replacement2, content)

# Fix Pattern 3: "float(arr[3]) if var a := ..."
# Should be: "var a := float(arr[3]) if ..."  
pattern3 = r'(\s*)(float\(arr\[3\]\))\s+if\s+var\s+(\w+)\s*:=\s+([\w.()]+\s*>\s*\d+)\s+else\s+([\d.]+)'
replacement3 = r'\1var \3 := \2 if \4 else \5'
content = re.sub(pattern3, replacement3, content)

# Fix Pattern 4: "value.to_html(true) if return value is Color else value"
# Should be: "return value.to_html(true) if value is Color else value"
pattern4 = r'(\s*)([\w.()]+)\s+if\s+return\s+([\w\s]+)\s+else\s+([\w]+)'
replacement4 = r'\1return \2 if \3 else \4'
content = re.sub(pattern4, replacement4, content)

# Fix Pattern 5: Lines with "created_path if var path_string = typeof..."
pattern5 = r'(\s*)(\w+)\s+if\s+var\s+(\w+)\s*=\s*typeof\((\w+)\)\s*==\s*(TYPE_\w+)\s+else\s+str\((\w+)\)'
replacement5 = r'\1var \3 = \2 if typeof(\4) == \5 else str(\6)'
content = re.sub(pattern5, replacement5, content)

# Fix indentation issues - replace spaces at beginning of lines with tabs
lines = content.split('\n')
fixed_lines = []
for line in lines:
    # If line starts with spaces (not tabs), convert to tabs
    if line.startswith('        '):  # 8 spaces
        # Count leading spaces
        leading_spaces = len(line) - len(line.lstrip(' '))
        if leading_spaces > 0 and not line.lstrip().startswith('#'):
            # Convert spaces to tabs (assuming 4 spaces = 1 tab for GDScript)
            tabs = '\t' * (leading_spaces // 4)
            fixed_lines.append(tabs + line.lstrip(' '))
        else:
            fixed_lines.append(line)
    else:
        fixed_lines.append(line)

content = '\n'.join(fixed_lines)

# Write the fixed content back
with open(file_path, 'w') as f:
    f.write(content)

print(f"Fixed syntax errors in {file_path}")
print("Fixed patterns:")
print("  1. Backwards ternary operators with var declarations")
print("  2. Removed duplicate function definitions")
print("  3. Fixed indentation (spaces to tabs)")
