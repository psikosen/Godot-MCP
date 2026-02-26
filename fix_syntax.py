#!/usr/bin/env python3
"""
Fix GDScript syntax errors:
1. Replace ternary operators (? :) with (if else)
2. Fix indentation issues
"""

import re
import os
import glob

def fix_ternary_operator(line):
    """Convert ternary operator to GDScript if/else syntax."""
    # Pattern: something ? value1 : value2
    # Convert to: value1 if something else value2
    
    # Match ternary pattern
    ternary_pattern = r'([^?]+)\s*\?\s*([^:]+)\s*:\s*(.+)'
    match = re.search(ternary_pattern, line)
    
    if match:
        condition = match.group(1).strip()
        true_value = match.group(2).strip()
        false_value = match.group(3).strip()
        
        # Get everything before the ternary
        before = line[:match.start(1)]
        # Get everything after the ternary (if any)
        after_match_end = match.end(3)
        after = line[after_match_end:] if after_match_end < len(line) else ""
        
        # Build the new line with proper GDScript syntax
        new_line = f"{before}{true_value} if {condition} else {false_value}{after}"
        return new_line
    
    return line

def fix_file(filepath):
    """Fix syntax errors in a GDScript file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for line in lines:
            new_line = line
            
            # Fix ternary operators
            if ' ? ' in line and ' : ' in line:
                new_line = fix_ternary_operator(line)
                if new_line != line:
                    modified = True
                    print(f"Fixed ternary in {filepath}:")
                    print(f"  OLD: {line.rstrip()}")
                    print(f"  NEW: {new_line.rstrip()}")
            
            new_lines.append(new_line)
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f"✓ Fixed {filepath}\n")
            return True
        
        return False
    
    except Exception as e:
        print(f"✗ Error fixing {filepath}: {e}\n")
        return False

def main():
    # Find all .gd files in the commands directory
    base_dir = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp"
    patterns = [
        f"{base_dir}/commands/*.gd",
        f"{base_dir}/utils/*.gd",
        f"{base_dir}/*.gd"
    ]
    
    all_files = []
    for pattern in patterns:
        all_files.extend(glob.glob(pattern))
    
    print(f"Found {len(all_files)} files to check\n")
    
    fixed_count = 0
    for filepath in all_files:
        if fix_file(filepath):
            fixed_count += 1
    
    print(f"\n{'='*60}")
    print(f"Fixed {fixed_count} file(s)")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
