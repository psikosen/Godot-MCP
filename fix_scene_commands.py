#!/usr/bin/env python3
"""
Fix backwards ternary operators in scene_commands.gd
"""

import re

file_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/scene_commands.gd"

# Read the file
with open(file_path, 'r') as f:
    content = f.read()

# Fix Pattern 1: "spaces_2d if var space_map = ..."
# Should be: "var space_map = spaces_2d if ..."
pattern1 = r'(\s*)(\w+)\s+if\s+var\s+(\w+)\s*=\s*([\w\s"=]+)\s+else\s+(\w+)'
replacement1 = r'\1var \3 = \2 if \4 else \5'
content = re.sub(pattern1, replacement1, content)

# Fix Pattern 2: "null if var new_stream_value = ..."
pattern2 = r'(\s*)(null)\s+if\s+var\s+(\w+)\s*=\s*([\w.()]+)\s+else\s+([\w.()]+)'
replacement2 = r'\1var \3 = \2 if \4 else \5'
content = re.sub(pattern2, replacement2, content)

# Fix Pattern 3: "2 if var bytes_per_sample : ..."
pattern3 = r'(\s*)(\d+)\s+if\s+var\s+(\w+)\s*:\s*([\w.()]+\s*[<>=]+\s*\d+)\s+else\s+(\d+)'
replacement3 = r'\1var \3: int = \2 if \4 else \5'
content = re.sub(pattern3, replacement3, content)

# Fix Pattern 4: "sample_count if var mean_amplitude : ..."
pattern4 = r'(\s*)(\w+)\s+if\s+var\s+(\w+)\s*:\s*([\w\s<>=.()]+)\s+else\s+([\d.]+)'
replacement4 = r'\1var \3 = \2 if \4 else \5'
content = re.sub(pattern4, replacement4, content)

# Write back
with open(file_path, 'w') as f:
    f.write(content)

print(f"Fixed backwards ternary operators in scene_commands.gd")
