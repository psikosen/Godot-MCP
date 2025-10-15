#!/usr/bin/env python3
"""Fix var := declarations that were incorrectly converted."""

import re
from pathlib import Path

def fix_var_declarations(content):
    """
    Fix patterns like:
      value if var name := condition else other_value
    To:
      var name := value if condition else other_value
    """
    lines = content.split('\n')
    fixed_lines = []
    
    for line in lines:
        # Pattern: (value) if var (name) := (condition) else (other_value)
        pattern = r'(.+?)\s+if\s+var\s+([a-zA-Z_][a-zA-Z0-9_]*)\s+:=\s+(.+?)\s+else\s+(.+)'
        
        match = re.match(pattern, line.strip())
        if match:
            value = match.group(1).strip()
            var_name = match.group(2).strip()
            condition = match.group(3).strip()
            other_value = match.group(4).strip()
            
            # Get indentation
            indent = line[:len(line) - len(line.lstrip())]
            
            # Reconstruct correctly
            fixed = f"{indent}var {var_name} := {value} if {condition} else {other_value}"
            fixed_lines.append(fixed)
        else:
            fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

def process_file(filepath):
    """Process a single file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()
    
    fixed = fix_var_declarations(original)
    
    if fixed != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(fixed)
        return True
    return False

def main():
    # Files that need fixing based on grep results
    files_to_fix = [
        'addons/godot_mcp/commands/base_command_processor.gd',
        'addons/godot_mcp/commands/multiplayer_commands.gd',
        'addons/godot_mcp/commands/navigation_commands.gd',
        'addons/godot_mcp/commands/node_commands.gd',
        'addons/godot_mcp/commands/scene_commands.gd',
    ]
    
    fixed_count = 0
    for filepath in files_to_fix:
        if process_file(filepath):
            print(f"✅ Fixed {filepath}")
            fixed_count += 1
    
    print(f"\nFixed {fixed_count} files")

if __name__ == '__main__':
    main()
