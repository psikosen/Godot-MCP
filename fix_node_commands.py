#!/usr/bin/env python3
"""Fix indentation and duplicate function issues in node_commands.gd"""

import re

def fix_file(filepath):
    """Fix indentation issues"""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print(f"Total lines: {len(lines)}")
    
    fixed_lines = []
    removed_duplicates = []
    seen_functions = {}
    in_duplicate_section = False
    duplicate_start = -1
    
    for i, line in enumerate(lines, 1):
        # Fix indentation: convert leading spaces to tabs
        if line.startswith(' ') and not line.startswith('\t'):
            # Count leading spaces
            leading_spaces = len(line) - len(line.lstrip(' '))
            # Convert every 4 spaces to 1 tab (or estimate based on context)
            if leading_spaces > 0:
                # For lines with 8 spaces, convert to 2 tabs
                # For lines with 1 space, convert to 1 tab (these look like errors)
                if leading_spaces >= 4:
                    num_tabs = leading_spaces // 4
                else:
                    # Single space before return is likely a typo - should be tab
                    num_tabs = 2  # Looking at context, this is inside a match statement
                
                content = line.lstrip(' ')
                line = '\t' * num_tabs + content
                print(f"Fixed line {i}: {leading_spaces} spaces -> {num_tabs} tabs")
        
        # Check for function definitions
        func_match = re.match(r'^func\s+(_\w+)', line)
        if func_match:
            func_name = func_match.group(1)
            if func_name in seen_functions:
                print(f"Line {i}: Duplicate function {func_name} (first seen at line {seen_functions[func_name]})")
                in_duplicate_section = True
                duplicate_start = i
                removed_duplicates.append(f"{func_name} at line {i}")
                continue  # Skip this line
            else:
                seen_functions[func_name] = i
                in_duplicate_section = False
        
        # If we're in a duplicate function section, skip lines until we hit the next function
        if in_duplicate_section:
            # Check if this is the start of a new function
            if re.match(r'^func\s+', line):
                # This is a new function, stop skipping
                in_duplicate_section = False
                func_match = re.match(r'^func\s+(_\w+)', line)
                if func_match:
                    func_name = func_match.group(1)
                    if func_name in seen_functions:
                        print(f"Line {i}: Another duplicate function {func_name}")
                        in_duplicate_section = True
                        removed_duplicates.append(f"{func_name} at line {i}")
                        continue
                    else:
                        seen_functions[func_name] = i
            else:
                # Still in duplicate section, skip
                continue
        
        fixed_lines.append(line)
    
    print(f"\nFixed {len(lines) - len(fixed_lines)} duplicate lines")
    if removed_duplicates:
        print("Removed duplicate functions:")
        for dup in removed_duplicates:
            print(f"  - {dup}")
    
    # Write fixed file
    backup_path = filepath + '.backup'
    with open(backup_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print(f"\nBackup saved to: {backup_path}")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(fixed_lines)
    print(f"Fixed file written: {filepath}")
    print(f"Original lines: {len(lines)}, Fixed lines: {len(fixed_lines)}")

if __name__ == "__main__":
    filepath = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"
    fix_file(filepath)
