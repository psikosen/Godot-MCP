#!/usr/bin/env python3
"""
Comprehensive fix for JavaScript-style ternary operators in GDScript files.
Converts: condition ? true_value : false_value
To: true_value if condition else false_value
"""
import re
from pathlib import Path
from typing import List, Tuple

def fix_single_line_ternary(line: str) -> str:
    """Fix ternary operators on a single line."""
    # Skip comments
    if line.strip().startswith('#'):
        return line
    
    # Pattern for ternary: anything ? something : something
    # We need to be careful to match the complete expression
    # This handles cases like: var x := condition ? value1 : value2
    pattern = r'([^?]+)\?([^:]+):([^\n,;)\]}]+)'
    
    def replace_ternary(match):
        before = match.group(1).strip()
        true_val = match.group(2).strip()
        false_val = match.group(3).strip()
        
        # Find the last assignment or opening paren/bracket before the ?
        # to determine where the condition starts
        condition_start = max(
            before.rfind('='),
            before.rfind('('),
            before.rfind('['),
            before.rfind(','),
            before.rfind(' ')
        ) + 1
        
        prefix = before[:condition_start]
        condition = before[condition_start:].strip()
        
        # Construct the fixed line
        return f"{prefix}{true_val} if {condition} else {false_val}"
    
    # Keep replacing until no more ternaries found
    max_iterations = 10
    for _ in range(max_iterations):
        new_line = re.sub(pattern, replace_ternary, line)
        if new_line == line:
            break
        line = new_line
    
    return line

def process_file(filepath: Path) -> Tuple[bool, List[dict]]:
    """
    Process a file and return (modified, changes_list).
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        changes = []
        new_lines = []
        
        for i, line in enumerate(lines, 1):
            # Check if line contains a ternary operator
            if '?' in line and ':' in line and not line.strip().startswith('#'):
                fixed_line = fix_single_line_ternary(line)
                if fixed_line != line:
                    changes.append({
                        'line': i,
                        'before': line.rstrip(),
                        'after': fixed_line.rstrip()
                    })
                    modified = True
                    new_lines.append(fixed_line)
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
        
        return modified, changes
    
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        import traceback
        traceback.print_exc()
        return False, []

def main():
    """Main function."""
    addon_path = Path("/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp")
    
    if not addon_path.exists():
        print(f"Error: Directory not found: {addon_path}")
        return 1
    
    print("=" * 80)
    print("Fixing GDScript Ternary Operators")
    print("=" * 80)
    
    # Find all .gd files
    gd_files = sorted([f for f in addon_path.rglob("*.gd") if f.is_file()])
    print(f"\nFound {len(gd_files)} GDScript files\n")
    
    fixed_files = []
    total_changes = 0
    
    for gd_file in gd_files:
        rel_path = gd_file.relative_to(addon_path)
        modified, changes = process_file(gd_file)
        
        if modified:
            fixed_files.append(str(rel_path))
            total_changes += len(changes)
            print(f"\n{rel_path}:")
            for change in changes:
                print(f"  Line {change['line']}:")
                print(f"    - {change['before']}")
                print(f"    + {change['after']}")
    
    print("\n" + "=" * 80)
    print(f"Summary: Fixed {len(fixed_files)} files with {total_changes} changes")
    if fixed_files:
        print("\nModified files:")
        for f in fixed_files:
            print(f"  - {f}")
    print("=" * 80)
    
    return 0

if __name__ == "__main__":
    exit(main())
