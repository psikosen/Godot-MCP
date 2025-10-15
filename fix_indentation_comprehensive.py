#!/usr/bin/env python3
"""
Comprehensive fix script for Godot MCP plugin indentation issues
"""

import os
import shutil

# Define the base path
base_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp"

def fix_indentation_comprehensive():
    """Fix ALL indentation issues in base_command_processor.gd"""
    file_path = os.path.join(base_path, "commands", "base_command_processor.gd")
    
    print(f"Comprehensively fixing {file_path}...")
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    fixed_lines = []
    for line in lines:
        # For each line, count leading whitespace
        stripped = line.lstrip()
        if stripped:  # Non-empty line
            # Count leading tabs and spaces
            leading_tabs = 0
            leading_spaces = 0
            for char in line:
                if char == '\t':
                    leading_tabs += 1
                elif char == ' ':
                    leading_spaces += 1
                else:
                    break
            
            # Calculate total indentation level
            # Each tab = 1 level, each 8 spaces = 1 level, each 4 spaces after tabs = 1 level
            total_indent = leading_tabs
            
            # If we have spaces after tabs (mixed), convert spaces to tabs
            if leading_tabs > 0 and leading_spaces > 0:
                # Spaces after tabs - convert each 8 spaces to a tab
                additional_tabs = leading_spaces // 8
                remaining_spaces = leading_spaces % 8
                
                # For GDScript, typically each 8 spaces = 1 tab
                # But if we see patterns like "        " (8 spaces) it's likely meant to be 1 tab
                if remaining_spaces == 0:
                    total_indent = leading_tabs + additional_tabs
                else:
                    # Handle cases where there might be intentional spacing
                    total_indent = leading_tabs + additional_tabs
                    if remaining_spaces >= 4:
                        total_indent += 1
                
                # Reconstruct line with only tabs
                fixed_line = '\t' * total_indent + stripped
            elif leading_spaces > 0 and leading_tabs == 0:
                # Only spaces - convert to tabs (8 spaces = 1 tab)
                total_indent = leading_spaces // 8
                if leading_spaces % 8 >= 4:
                    total_indent += 1
                fixed_line = '\t' * total_indent + stripped
            else:
                # Already using tabs only, or no indentation
                fixed_line = line
            
            fixed_lines.append(fixed_line)
        else:
            # Empty line
            fixed_lines.append(line)
    
    # Write fixed version
    with open(file_path, 'w') as f:
        f.writelines(fixed_lines)
    
    print(f"  ✓ Fixed all indentation issues (converted all spaces to tabs)")

def main():
    print("=== Comprehensive Godot MCP Indentation Fix ===\n")
    
    # Create backup first
    file_path = os.path.join(base_path, "commands", "base_command_processor.gd")
    backup_path = file_path + ".backup2"
    shutil.copy2(file_path, backup_path)
    print(f"Created backup: {backup_path}")
    
    # Fix indentation
    fix_indentation_comprehensive()
    
    print("\n=== Fix Complete ===")
    print("\nThe indentation has been standardized to use tabs only.")
    print("Please restart Godot to apply the changes.")

if __name__ == "__main__":
    main()
