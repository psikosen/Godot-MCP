#!/usr/bin/env python3
"""
Fix script for Godot MCP plugin issues
"""

import os
import shutil

# Define the base path
base_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp"

def fix_base_command_processor():
    """Fix mixed tabs/spaces in base_command_processor.gd"""
    file_path = os.path.join(base_path, "commands", "base_command_processor.gd")
    
    print(f"Fixing {file_path}...")
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Fix lines 141 onwards - replace 8 spaces with tabs
    fixed_lines = []
    for i, line in enumerate(lines):
        if i >= 140:  # Line 141 in 0-indexed is 140
            # Replace leading spaces (8 spaces = 1 tab, 16 spaces = 2 tabs, etc.)
            # Count leading spaces
            stripped = line.lstrip(' ')
            space_count = len(line) - len(stripped)
            if space_count > 0 and space_count % 8 == 0:
                # Replace with appropriate number of tabs
                tab_count = space_count // 8
                line = '\t' * tab_count + stripped
        fixed_lines.append(line)
    
    # Backup original
    shutil.copy2(file_path, file_path + ".backup")
    
    # Write fixed version
    with open(file_path, 'w') as f:
        f.writelines(fixed_lines)
    
    print(f"  ✓ Fixed indentation (replaced spaces with tabs)")

def fix_command_handler_backup():
    """Fix ternary operator in command_handler_BACKUP.gd"""
    file_path = os.path.join(base_path, "command_handler_BACKUP.gd")
    
    if not os.path.exists(file_path):
        print(f"  ! {file_path} not found, skipping")
        return
    
    print(f"Fixing {file_path}...")
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Fix the ternary operator on line 65
    # Original: command_id = command_id_value != null ? str(command_id_value) : ""
    # Fixed: command_id = str(command_id_value) if command_id_value != null else ""
    
    old_line = '\t\tcommand_id = command_id_value != null ? str(command_id_value) : ""'
    new_line = '\t\tcommand_id = str(command_id_value) if command_id_value != null else ""'
    
    content = content.replace(old_line, new_line)
    
    # Write fixed version
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"  ✓ Fixed ternary operator syntax")

def fix_case_mismatch():
    """Rename backup uid file to match the actual backup file name"""
    old_path = os.path.join(base_path, "command_handler_backup.gd.uid")
    new_path = os.path.join(base_path, "command_handler_BACKUP.gd.uid")
    
    if os.path.exists(old_path):
        print(f"Renaming {old_path} to match case...")
        os.rename(old_path, new_path)
        print(f"  ✓ Renamed to {new_path}")
    else:
        print(f"  ! Case mismatch file not found, may already be fixed")

def main():
    print("=== Godot MCP Plugin Fix Script ===\n")
    
    # Fix 1: Mixed tabs/spaces
    fix_base_command_processor()
    
    # Fix 2: Ternary operator
    fix_command_handler_backup()
    
    # Fix 3: Case mismatch
    fix_case_mismatch()
    
    print("\n=== Fixes Complete ===")
    print("\nNext steps:")
    print("1. Restart the Godot editor")
    print("2. The plugin should now load without errors")
    print("3. If you still see errors, check that all preload statements are using correct paths")

if __name__ == "__main__":
    main()
