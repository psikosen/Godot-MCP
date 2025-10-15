#!/usr/bin/env python3

import os
import re
import json

def check_file(filepath):
    """Check if a GDScript file has parse errors"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    issues = []
    
    # Check for class_name declaration
    class_name_match = re.search(r'class_name\s+(\w+)', content)
    if class_name_match:
        print(f"  ✓ Has class_name: {class_name_match.group(1)}")
    else:
        print(f"  ✗ No class_name found")
    
    # Check for extends declaration
    extends_match = re.search(r'extends\s+(\w+)', content)
    if extends_match:
        print(f"  ✓ Extends: {extends_match.group(1)}")
    else:
        print(f"  ✗ No extends found")
        issues.append("Missing extends declaration")
    
    # Check all preload statements
    preload_pattern = r'preload\("([^"]+)"\)'
    preloads = re.findall(preload_pattern, content)
    
    if preloads:
        print(f"  Preloads {len(preloads)} files:")
        for preload_path in preloads:
            # Convert res:// path to actual path
            actual_path = preload_path.replace("res://", "")
            full_path = os.path.join("/Users/raymondgonzalez/mcp/Godot-MCP", actual_path)
            if os.path.exists(full_path):
                print(f"    ✓ {preload_path}")
            else:
                print(f"    ✗ {preload_path} - FILE NOT FOUND")
                issues.append(f"Preload file not found: {preload_path}")
    
    # Check for potential syntax issues
    # Check for unclosed brackets
    open_parens = content.count('(')
    close_parens = content.count(')')
    if open_parens != close_parens:
        issues.append(f"Mismatched parentheses: {open_parens} open, {close_parens} close")
    
    open_brackets = content.count('[')
    close_brackets = content.count(']')
    if open_brackets != close_brackets:
        issues.append(f"Mismatched brackets: {open_brackets} open, {close_brackets} close")
    
    open_braces = content.count('{')
    close_braces = content.count('}')
    if open_braces != close_braces:
        issues.append(f"Mismatched braces: {open_braces} open, {close_braces} close")
    
    # Check for const declarations before preload
    const_preload_pattern = r'const\s+(\w+)\s*=\s*preload\("([^"]+)"\)'
    const_preloads = re.findall(const_preload_pattern, content)
    for const_name, path in const_preloads:
        print(f"    Const {const_name} = preload({path})")
    
    return issues

def main():
    print("=== Diagnosing Godot-MCP Preload Issues ===\n")
    
    base_dir = "/Users/raymondgonzalez/mcp/Godot-MCP"
    
    # Files to check
    files_to_check = [
        "addons/godot_mcp/mcp_server.gd",
        "addons/godot_mcp/command_handler.gd",
        "addons/godot_mcp/commands/base_command_processor.gd",
        "addons/godot_mcp/commands/node_commands.gd"
    ]
    
    all_issues = {}
    
    for file_path in files_to_check:
        full_path = os.path.join(base_dir, file_path)
        print(f"Checking: {file_path}")
        
        if not os.path.exists(full_path):
            print(f"  ✗ File does not exist!\n")
            continue
        
        issues = check_file(full_path)
        
        if issues:
            all_issues[file_path] = issues
            print(f"  ⚠ Issues found: {issues}")
        else:
            print(f"  ✓ No issues found")
        print()
    
    # Check if command_handler.gd might have cyclic dependencies
    print("=== Checking for Cyclic Dependencies ===")
    
    # Check if any of the command files preload command_handler
    commands_dir = os.path.join(base_dir, "addons/godot_mcp/commands")
    if os.path.exists(commands_dir):
        for filename in os.listdir(commands_dir):
            if filename.endswith('.gd'):
                filepath = os.path.join(commands_dir, filename)
                with open(filepath, 'r') as f:
                    content = f.read()
                if 'preload("res://addons/godot_mcp/command_handler.gd")' in content:
                    print(f"  ⚠ {filename} preloads command_handler.gd - CYCLIC DEPENDENCY!")
    
    print("\n=== Summary ===")
    if all_issues:
        print("Issues found in the following files:")
        for file, issues in all_issues.items():
            print(f"  {file}:")
            for issue in issues:
                print(f"    - {issue}")
    else:
        print("No obvious issues found in the checked files.")
        print("\nThe issue might be:")
        print("1. A deeper syntax error in one of the preloaded files")
        print("2. An issue with Godot's import system (.import files)")
        print("3. A class_name conflict")
        print("4. The files need to be compiled/imported by Godot first")
    
    print("\n=== Suggested Fixes ===")
    print("1. Try removing all .uid files and letting Godot regenerate them")
    print("2. Clear the .godot cache folder")
    print("3. Make sure all files have @tool at the top")
    print("4. Ensure no cyclic dependencies exist")

if __name__ == "__main__":
    main()
