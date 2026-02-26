#!/usr/bin/env python3
"""
Properly fix GDScript ternary operators.
Convert: condition ? value_if_true : value_if_false
To: value_if_true if condition else value_if_false
"""

import re
import os

def fix_ternary(line):
    """Fix ternary operator - handle assignment context carefully."""
    # Pattern to match variable assignments with ternary
    # Format: var_name = condition ? true_val : false_val
    assignment_pattern = r'(\s*)([\w\[\]"\.]+)\s*[:=]\s*(.+?)\s*\?\s*(.+?)\s*:\s*(.+)$'
    
    match = re.match(assignment_pattern, line)
    if match:
        indent = match.group(1)
        var_name = match.group(2)
        condition = match.group(3).strip()
        true_val = match.group(4).strip()
        false_val = match.group(5).strip()
        
        # Build proper GDScript if/else
        return f"{indent}{var_name} = {true_val} if {condition} else {false_val}\n"
    
    return line

def process_file(filepath):
    """Process a single file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for i, line in enumerate(lines):
            if ' ? ' in line and ' : ' in line:
                new_line = fix_ternary(line)
                if new_line != line:
                    modified = True
                    print(f"Line {i+1} in {os.path.basename(filepath)}:")
                    print(f"  OLD: {line.rstrip()}")
                    print(f"  NEW: {new_line.rstrip()}")
                    new_lines.append(new_line)
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"✓ Fixed {filepath}\n")
            return True
        return False
    
    except Exception as e:
        print(f"✗ Error: {filepath}: {e}\n")
        return False

def main():
    import glob
    
    base = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp"
    files = []
    for pattern in [f"{base}/commands/*.gd", f"{base}/utils/*.gd"]:
        files.extend(glob.glob(pattern))
    
    print(f"Processing {len(files)} files...\n")
    fixed = sum(1 for f in files if process_file(f))
    print(f"\n{'='*60}")
    print(f"Fixed {fixed} file(s)")

if __name__ == "__main__":
    main()
