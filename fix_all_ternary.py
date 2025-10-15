#!/usr/bin/env python3
import re
import os
import glob

def fix_ternary_operators(filepath):
    """
    Convert C-style ternary operators to GDScript if/else syntax
    Pattern: condition ? true_value : false_value
    Replacement: true_value if condition else false_value
    """
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    changes = 0
    
    # Pattern to match ternary operators
    # This is tricky because we need to handle nested expressions
    # Pattern: (expression) ? (value1) : (value2)
    
    # Simple approach: find all instances and convert them
    lines = content.split('\n')
    fixed_lines = []
    
    for line_num, line in enumerate(lines, 1):
        # Skip lines that are already in correct if/else format
        if ' if ' in line and ' else ' in line and ' ? ' not in line:
            fixed_lines.append(line)
            continue
            
        # Find ternary operators in the line
        original_line = line
        
        # Pattern: something ? value1 : value2
        # We need to be careful about nested expressions
        while ' ? ' in line and ' : ' in line:
            # Find the ternary operator
            q_pos = line.find(' ? ')
            if q_pos == -1:
                break
            
            # Find the corresponding colon
            colon_pos = line.find(' : ', q_pos)
            if colon_pos == -1:
                break
            
            # Extract the three parts
            # We need to find where the condition starts
            # Look backwards from ? to find the start of the condition
            condition_start = q_pos
            depth = 0
            for i in range(q_pos - 1, -1, -1):
                c = line[i]
                if c == ')':
                    depth += 1
                elif c == '(':
                    depth -= 1
                elif depth == 0 and c in ['=', ',', '(', '\t', ' '] and line[i:q_pos].strip():
                    condition_start = i + 1
                    break
            
            # Extract parts
            before = line[:condition_start]
            condition = line[condition_start:q_pos].strip()
            true_part = line[q_pos + 3:colon_pos].strip()
            
            # Find the end of false part
            # Look forward from colon to find where the expression ends
            false_end = len(line)
            depth = 0
            for i in range(colon_pos + 3, len(line)):
                c = line[i]
                if c == '(':
                    depth += 1
                elif c == ')':
                    depth -= 1
                    if depth < 0:
                        false_end = i
                        break
                elif depth == 0 and c in [',', '\n', ')']:
                    false_end = i
                    break
            
            false_part = line[colon_pos + 3:false_end].strip()
            after = line[false_end:]
            
            # Construct the new line with if/else syntax
            new_expr = f"{true_part} if {condition} else {false_part}"
            line = before + new_expr + after
            changes += 1
            
        if line != original_line:
            print(f"  Line {line_num}: Fixed ternary operator")
            
        fixed_lines.append(line)
    
    if changes > 0:
        new_content = '\n'.join(fixed_lines)
        with open(filepath, 'w') as f:
            f.write(new_content)
        return changes
    return 0

# Find all .gd files
gd_files = []
for root, dirs, files in os.walk('addons/godot_mcp'):
    for file in files:
        if file.endswith('.gd') and not file.endswith('.bak'):
            gd_files.append(os.path.join(root, file))

print(f"Found {len(gd_files)} GDScript files")
print("Fixing ternary operators...\n")

total_changes = 0
for filepath in sorted(gd_files):
    changes = fix_ternary_operators(filepath)
    if changes > 0:
        print(f"✅ {filepath}: {changes} ternary operators fixed")
        total_changes += changes

print(f"\n=== Fixed {total_changes} ternary operators across {len(gd_files)} files ===")
