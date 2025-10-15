#!/usr/bin/env python3
import re

def check_indentation(file_path):
    """Check for mixed tabs and spaces."""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines, 1):
        # Skip empty lines and comments starting at beginning of line
        if line.strip() == '' or line.lstrip().startswith('#'):
            continue
            
        # Check for lines that have both tabs and spaces in the indentation
        indent = line[:len(line) - len(line.lstrip())]
        if indent and '\t' in indent and ' ' in indent:
            print(f"Line {i}: Mixed tabs and spaces in indentation")
            print(f"  Raw indent: {repr(indent)}")
            print(f"  Line preview: {line[:80].rstrip()}")
        elif indent and '        ' in indent:  # 8 spaces
            print(f"Line {i}: Found 8 spaces, might need conversion")
            print(f"  Line preview: {line[:80].rstrip()}")

check_indentation('/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd')
