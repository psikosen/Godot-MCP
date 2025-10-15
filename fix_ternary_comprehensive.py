#!/usr/bin/env python3
"""
Fix all C-style ternary operators in GDScript files.
Converts: condition ? true_value : false_value
To: true_value if condition else false_value
"""

import re
import os
from pathlib import Path

def fix_ternary_in_line(line):
    """Fix ternary operators in a single line."""
    # Pattern matches: [condition] ? [true_value] : [false_value]
    # We need to be careful with:
    # - Method calls: obj.method() ? val : val
    # - Boolean expressions: has_meta(...) ? get_meta(...) : null
    # - Nested calls: value ? value.method() : default
    
    # This regex matches the ternary pattern
    # Group 1: condition (everything before ?)
    # Group 2: true value (between ? and :)
    # Group 3: false value (after :)
    pattern = r'([^?]+?)\s+\?\s+([^:]+?)\s+:\s+([^,\)\n]+)'
    
    def replace_ternary(match):
        condition = match.group(1).strip()
        true_val = match.group(2).strip()
        false_val = match.group(3).strip()
        return f"{true_val} if {condition} else {false_val}"
    
    # Keep replacing until no more ternary operators found
    max_iterations = 10  # Prevent infinite loops
    iteration = 0
    while ' ? ' in line and ' : ' in line and iteration < max_iterations:
        new_line = re.sub(pattern, replace_ternary, line, count=1)
        if new_line == line:
            break  # No change, stop
        line = new_line
        iteration += 1
    
    return line

def fix_file(filepath):
    """Fix all ternary operators in a file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    fixed_lines = []
    changes = 0
    
    for line_num, line in enumerate(lines, 1):
        # Skip if already using if/else syntax
        if ' if ' in line and ' else ' in line and ' ? ' not in line:
            fixed_lines.append(line)
            continue
        
        fixed_line = fix_ternary_in_line(line)
        if fixed_line != line:
            print(f"  Line {line_num}: {line.strip()[:80]}")
            print(f"       -> {fixed_line.strip()[:80]}")
            changes += 1
        
        fixed_lines.append(fixed_line)
    
    if changes > 0:
        # Write back
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(fixed_lines)
    
    return changes

def main():
    # Find all .gd files in addons/godot_mcp
    addon_dir = Path('addons/godot_mcp')
    gd_files = list(addon_dir.rglob('*.gd'))
    
    # Exclude backup files
    gd_files = [f for f in gd_files if not f.name.endswith('.bak')]
    
    print(f"Found {len(gd_files)} GDScript files")
    print("=" * 60)
    
    total_changes = 0
    files_changed = 0
    
    for filepath in sorted(gd_files):
        changes = fix_file(filepath)
        if changes > 0:
            print(f"\n✅ {filepath}: {changes} changes")
            total_changes += changes
            files_changed += 1
    
    print("\n" + "=" * 60)
    print(f"Fixed {total_changes} ternary operators in {files_changed} files")
    
    # Verify
    print("\nVerifying fixes...")
    remaining = 0
    for filepath in gd_files:
        with open(filepath, 'r') as f:
            content = f.read()
            count = content.count(' ? ') + content.count('?')
            if count > 0:
                # Check if they're actually ternary operators
                lines_with_ternary = [i+1 for i, line in enumerate(content.split('\n')) 
                                     if ' ? ' in line and ' : ' in line]
                if lines_with_ternary:
                    remaining += len(lines_with_ternary)
                    print(f"  ⚠️  {filepath}: lines {lines_with_ternary}")
    
    if remaining == 0:
        print("\n✅ All ternary operators successfully fixed!")
    else:
        print(f"\n⚠️  Found {remaining} lines that may still need manual review")

if __name__ == '__main__':
    main()
