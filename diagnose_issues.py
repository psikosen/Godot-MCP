#!/usr/bin/env python3
"""Diagnose Godot MCP syntax issues"""

import sys
import re

def check_file(filepath):
    """Check for common GDScript syntax issues"""
    print(f"\n=== Checking {filepath} ===")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    issues = []
    
    for i, line in enumerate(lines, 1):
        # Check for mixed tabs and spaces
        if '\t' in line and '    ' in line:
            # Get leading whitespace
            leading = len(line) - len(line.lstrip())
            if leading > 0:
                issues.append(f"Line {i}: Mixed tabs and spaces in indentation")
        
        # Check for ternary operator syntax (?)
        if '?' in line and 'if' not in line:
            issues.append(f"Line {i}: Unexpected '?' - GDScript uses 'value if condition else other'")
            print(f"  Content: {line.rstrip()}")
        
        # Check for duplicate function definitions nearby
        if line.strip().startswith('func '):
            func_name = re.search(r'func\s+(\w+)', line)
            if func_name:
                func_name = func_name.group(1)
                # Check if this function appears again soon after
                for j in range(i, min(i + 100, len(lines))):
                    if j != i - 1 and lines[j].strip().startswith(f'func {func_name}'):
                        issues.append(f"Line {i} and {j+1}: Duplicate function definition '{func_name}'")
                        break
    
    # Check overall indentation consistency
    tab_lines = sum(1 for line in lines if line.startswith('\t'))
    space_lines = sum(1 for line in lines if line.startswith('    ') and not line.startswith('\t'))
    
    if tab_lines > 0 and space_lines > 0:
        issues.append(f"File has {tab_lines} lines with tabs and {space_lines} lines with spaces at start")
    
    if issues:
        print(f"Found {len(issues)} issues:")
        for issue in issues[:20]:  # Show first 20
            print(f"  - {issue}")
    else:
        print("No issues found!")
    
    return issues

if __name__ == "__main__":
    files = [
        "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/command_handler.gd",
        "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd",
        "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/mcp_server.gd"
    ]
    
    for filepath in files:
        try:
            check_file(filepath)
        except Exception as e:
            print(f"Error checking {filepath}: {e}")
