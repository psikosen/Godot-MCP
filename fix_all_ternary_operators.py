#!/usr/bin/env python3
"""
Fix all JavaScript-style ternary operators (? :) to GDScript syntax (if else)
"""
import re
import os
from pathlib import Path

def fix_ternary_in_line(line: str) -> str:
    """
    Convert JavaScript-style ternary operator to GDScript syntax.
    Pattern: condition ? true_value : false_value
    To: true_value if condition else false_value
    """
    # Match ternary operator pattern
    # This regex looks for: some_expression ? value1 : value2
    pattern = r'(.+?)\s+\?\s+(.+?)\s+:\s+(.+?)(\s*$|[\s,\)\]\}])'
    
    def replace_ternary(match):
        condition = match.group(1).strip()
        true_value = match.group(2).strip()
        false_value = match.group(3).strip()
        trailing = match.group(4)
        
        # Skip if this looks like a type annotation (Dict[String, int])
        if '[' in condition or ']' in true_value:
            return match.group(0)
        
        # Convert to GDScript syntax
        result = f"{true_value} if {condition} else {false_value}{trailing}"
        return result
    
    # Keep replacing until no more ternary operators found
    max_iterations = 10
    iteration = 0
    while iteration < max_iterations:
        new_line = re.sub(pattern, replace_ternary, line)
        if new_line == line:
            break
        line = new_line
        iteration += 1
    
    return line

def process_file(filepath: Path) -> bool:
    """Process a single GDScript file to fix ternary operators."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        
        for i, line in enumerate(lines, 1):
            # Check if line contains JavaScript-style ternary
            if '?' in line and ':' in line and not line.strip().startswith('#'):
                new_line = fix_ternary_in_line(line)
                if new_line != line:
                    print(f"  Line {i}: Fixed ternary operator")
                    print(f"    Before: {line.rstrip()}")
                    print(f"    After:  {new_line.rstrip()}")
                    modified = True
                new_lines.append(new_line)
            else:
                new_lines.append(line)
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            return True
        
        return False
    
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main function to process all GDScript files."""
    addon_path = Path("/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp")
    
    if not addon_path.exists():
        print(f"Error: Path not found: {addon_path}")
        return
    
    print("Scanning for GDScript files with ternary operators...")
    print("=" * 60)
    
    # Find all .gd files
    gd_files = list(addon_path.rglob("*.gd"))
    print(f"Found {len(gd_files)} GDScript files\n")
    
    fixed_count = 0
    for gd_file in gd_files:
        print(f"\nProcessing: {gd_file.relative_to(addon_path)}")
        if process_file(gd_file):
            fixed_count += 1
    
    print("\n" + "=" * 60)
    print(f"Fixed {fixed_count} files")

if __name__ == "__main__":
    main()
