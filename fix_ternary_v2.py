#!/usr/bin/env python3
"""
Fix C-style ternary operators in GDScript.
Converts: condition ? true_value : false_value
To: true_value if condition else false_value

This handles common patterns like:
- var x = condition ? val1 : val2
- func_arg(condition ? val1 : val2)
- dict["key"]: condition ? val1 : val2
"""

import re
from pathlib import Path

def fix_ternary_operators(content):
    """
    Fix ternary operators while preserving context.
    We look for patterns where the condition is bounded by certain delimiters.
    """
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Skip lines that don't have ternary operators
        if ' ? ' not in line or ' : ' not in line:
            fixed_lines.append(line)
            continue
        
        # Skip lines that already use if/else
        if ' if ' in line and ' else ' in line:
            fixed_lines.append(line)
            continue
        
        # Pattern: [delimiter][ws]condition ? true_val : false_val
        # where delimiter is one of: = ( , : \t (assignment, function arg, list item, dict value, indent)
        
        # Find all ternary patterns
        # We use a more specific regex that looks for the delimiter before the condition
        pattern = r'([\s=\(,:\[])([^?]+?)\s+\?\s+([^:]+?)\s+:\s+([^,\)\]\n]+)'
        
        def replace_match(m):
            delimiter = m.group(1)
            condition = m.group(2).strip()
            true_val = m.group(3).strip()
            false_val = m.group(4).strip()
            
            # Reconstruct with if/else syntax
            return f"{delimiter}{true_val} if {condition} else {false_val}"
        
        # Apply the replacement
        fixed_line = re.sub(pattern, replace_match, line)
        fixed_lines.append(fixed_line)
    
    return '\n'.join(fixed_lines)

def process_file(filepath):
    """Process a single file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()
    
    fixed = fix_ternary_operators(original)
    
    if fixed != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(fixed)
        
        # Count changes
        orig_lines = original.split('\n')
        fixed_lines = fixed.split('\n')
        changes = sum(1 for o, f in zip(orig_lines, fixed_lines) if o != f)
        return changes
    
    return 0

def main():
    addon_dir = Path('addons/godot_mcp')
    gd_files = [f for f in addon_dir.rglob('*.gd') if not f.name.endswith('.bak')]
    
    print(f"Processing {len(gd_files)} GDScript files...")
    print("=" * 70)
    
    total_changes = 0
    files_modified = 0
    
    for filepath in sorted(gd_files):
        changes = process_file(filepath)
        if changes > 0:
            print(f"✅ {filepath.relative_to(addon_dir.parent)}: {changes} lines modified")
            total_changes += changes
            files_modified += 1
    
    print("=" * 70)
    print(f"Modified {files_modified} files with {total_changes} total line changes")
    
    # Verify no ternary operators remain
    print("\nVerifying...")
    remaining_files = []
    for filepath in gd_files:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            ternary_lines = [i+1 for i, line in enumerate(lines) 
                           if ' ? ' in line and ' : ' in line and ' if ' not in line]
            if ternary_lines:
                remaining_files.append((filepath, ternary_lines))
    
    if remaining_files:
        print("\n⚠️  Files with remaining ternary operators:")
        for filepath, lines in remaining_files:
            print(f"  {filepath.relative_to(addon_dir.parent)}: lines {lines}")
    else:
        print("✅ All ternary operators fixed!")

if __name__ == '__main__':
    main()
