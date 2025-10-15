#!/usr/bin/env python3
"""
Fix script for missing SceneTransactionManager preload statements
"""

import re
import os

# Base path
base_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands"

# Files that need fixing
files_to_fix = [
    "node_commands.gd",
    "animation_commands.gd",
    "navigation_commands.gd",
    "rendering_commands.gd",
    "scene_commands.gd"
]

def fix_scene_transaction_reference(file_path):
    """Fix the SceneTransactionManager reference by adding proper preload"""
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Check if it has the incorrect const line
    if "const SceneTransactionManager := MCPSceneTransactionManager" in content:
        # Replace the incorrect const with a proper preload
        content = content.replace(
            "const SceneTransactionManager := MCPSceneTransactionManager",
            'const SceneTransactionManager = preload("res://addons/godot_mcp/utils/scene_transaction_manager.gd")'
        )
        
        # Write back the fixed content
        with open(file_path, 'w') as f:
            f.write(content)
        
        return True
    return False

def main():
    print("=== Fixing SceneTransactionManager References ===\n")
    
    fixed_count = 0
    for filename in files_to_fix:
        file_path = os.path.join(base_path, filename)
        if os.path.exists(file_path):
            if fix_scene_transaction_reference(file_path):
                print(f"✓ Fixed {filename}")
                fixed_count += 1
            else:
                print(f"  {filename} - already correct or different issue")
        else:
            print(f"✗ {filename} not found")
    
    print(f"\n=== Fixed {fixed_count} files ===")
    print("\nNow restart Godot to apply the changes.")

if __name__ == "__main__":
    main()
