#!/usr/bin/env python3
"""
Final fix for ternary operators in GDScript.
Handles the pattern: var x := condition ? value1 : value2
Converts to: var x := value1 if condition else value2
"""
import re
from pathlib import Path

def fix_line(line: str) -> str:
    """Fix ternary operators in a line."""
    # Skip comments
    if line.strip().startswith('#'):
        return line
    
    original = line
    
    # Pattern 1: Assignment with ternary
    # var x := condition ? value1 : value2
    # var x = condition ? value1 : value2
    pattern1 = r'(.*[:=]\s*)(\S+(?:\([^)]*\)|[^?])*)\s*\?\s*([^:]+?)\s*:\s*(.+)$'
    match = re.search(pattern1, line)
    if match:
        prefix = match.group(1)  # Everything before the condition
        condition = match.group(2).strip()
        true_val = match.group(3).strip()
        false_val = match.group(4).strip()
        line = f"{prefix}{true_val} if {condition} else {false_val}\n" if line.endswith('\n') else f"{prefix}{true_val} if {condition} else {false_val}"
        return line
    
    # Pattern 2: Inline ternary in expressions
    # (condition ? value1 : value2)
    pattern2 = r'\(([^?]+)\?\s*([^:]+?)\s*:\s*([^)]+)\)'
    match = re.search(pattern2, line)
    if match:
        condition = match.group(1).strip()
        true_val = match.group(2).strip()
        false_val = match.group(3).strip()
        replacement = f"({true_val} if {condition} else {false_val})"
        line = line.replace(match.group(0), replacement)
        return line
    
    return line

def process_file(filepath: Path):
    """Process a single file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        new_lines = []
        changes = []
        
        for i, line in enumerate(lines, 1):
            if '?' in line and ':' in line:
                new_line = fix_line(line)
                if new_line != line:
                    modified = True
                    changes.append((i, line.rstrip(), new_line.rstrip()))
                new_lines.append(new_line)
            else:
                new_lines.append(line)
        
        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            return changes
        return None
    
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return None

def main():
    addon_dir = Path("/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp")
    
    files_to_fix = [
        "ui/mcp_panel.gd",
        "utils/scene_transaction_manager.gd",
        "commands/editor_commands.gd",
        "commands/project_commands.gd",
        "commands/rendering_commands.gd",
        "commands/animation_commands.gd",
        "commands/script_commands.gd",
        "commands/scene_commands.gd",
        "commands/node_commands.gd",
        "commands/base_command_processor.gd",
        "commands/navigation_commands.gd",
        "commands/xr_commands.gd",
        "commands/multiplayer_commands.gd",
    ]
    
    print("=" * 70)
    print("Fixing GDScript Ternary Operators")
    print("=" * 70)
    
    fixed_count = 0
    for rel_path in files_to_fix:
        filepath = addon_dir / rel_path
        if not filepath.exists():
            print(f"\n{rel_path}: NOT FOUND")
            continue
        
        changes = process_file(filepath)
        if changes:
            fixed_count += 1
            print(f"\n{rel_path}: Fixed {len(changes)} lines")
            for line_num, before, after in changes[:3]:  # Show first 3 changes
                print(f"  Line {line_num}:")
                print(f"    - {before[:80]}")
                print(f"    + {after[:80]}")
            if len(changes) > 3:
                print(f"  ... and {len(changes) - 3} more changes")
    
    print("\n" + "=" * 70)
    print(f"Fixed {fixed_count} files")
    print("=" * 70)

if __name__ == "__main__":
    main()
