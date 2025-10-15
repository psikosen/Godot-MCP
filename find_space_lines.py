#!/usr/bin/env python3
"""Find lines starting with spaces instead of tabs"""

def find_space_lines(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines, 1):
        if line.startswith(' ') and not line.startswith('\t'):
            # Count leading spaces
            leading_spaces = len(line) - len(line.lstrip(' '))
            print(f"Line {i}: {leading_spaces} leading spaces")
            print(f"  Content: {repr(line[:80])}")

if __name__ == "__main__":
    filepath = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"
    find_space_lines(filepath)
