#!/usr/bin/env python3
"""
Fix all remaining parse errors in Godot MCP plugin
"""

import re
import os

base_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp"

def fix_ternary_operators(file_path):
    """Fix C-style ternary operators"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    fixed_lines = []
    for line in lines:
        # Match C-style ternary: condition ? true_val : false_val
        # Convert to: true_val if condition else false_val
        if '?' in line and ':' in line and not line.strip().startswith('#'):
            # This is a simple pattern match - may need adjustment for complex cases
            match = re.search(r'(.+?)(\s*=\s*)(.+?)\s*\?\s*(.+?)\s*:\s*(.+)', line)
            if match:
                indent = len(line) - len(line.lstrip())
                var_part = match.group(1) + match.group(2)
                condition = match.group(3).strip()
                true_val = match.group(4).strip()
                false_val = match.group(5).strip()
                fixed_line = line[:indent] + var_part + f"{true_val} if {condition} else {false_val}\n"
                fixed_lines.append(fixed_line)
                print(f"  Fixed ternary: line {len(fixed_lines)}")
            else:
                fixed_lines.append(line)
        else:
            fixed_lines.append(line)
    
    with open(file_path, 'w') as f:
        f.writelines(fixed_lines)
    
    return len([l for l in fixed_lines if '?' in l and ':' in l and not l.strip().startswith('#')]) == 0

def fix_indentation(file_path, problem_lines):
    """Fix space/tab indentation issues"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    fixed_lines = []
    for i, line in enumerate(lines, 1):
        if i in problem_lines or line.startswith(' '):
            # Count leading spaces and convert to tabs
            stripped = line.lstrip(' ')
            space_count = len(line) - len(stripped)
            if space_count > 0:
                tab_count = space_count // 8
                if space_count % 8 >= 4:
                    tab_count += 1
                elif space_count % 8 > 0 and space_count < 8:
                    tab_count = 1
                fixed_line = '\t' * tab_count + stripped
                fixed_lines.append(fixed_line)
                if i in problem_lines:
                    print(f"  Fixed indentation: line {i}")
            else:
                fixed_lines.append(line)
        else:
            # Also check for mixed tabs and spaces
            if '\t' in line and line.startswith('\t'):
                # Check if there are spaces after tabs
                tab_end = 0
                for char in line:
                    if char == '\t':
                        tab_end += 1
                    else:
                        break
                
                after_tabs = line[tab_end:]
                if after_tabs.startswith(' '):
                    # Has spaces after tabs
                    spaces_after = len(after_tabs) - len(after_tabs.lstrip(' '))
                    additional_tabs = spaces_after // 8
                    if spaces_after % 8 >= 4:
                        additional_tabs += 1
                    fixed_line = '\t' * (tab_end + additional_tabs) + after_tabs.lstrip(' ')
                    fixed_lines.append(fixed_line)
                else:
                    fixed_lines.append(line)
            else:
                fixed_lines.append(line)
    
    with open(file_path, 'w') as f:
        f.writelines(fixed_lines)

def fix_comment_newline(file_path, line_num):
    """Fix missing newline after comment"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    if line_num <= len(lines):
        problem_line = lines[line_num - 1]
        # Check if it's a comment without proper ending
        if '#' in problem_line:
            # Ensure the line ends with a newline
            if not problem_line.endswith('\n'):
                lines[line_num - 1] = problem_line + '\n'
                print(f"  Added newline after comment: line {line_num}")
            # Check if there's code after the comment on the same line
            elif '#' in problem_line and not problem_line.strip().startswith('#'):
                # Split comment and code
                comment_start = problem_line.index('#')
                code_part = problem_line[:comment_start].rstrip()
                comment_part = problem_line[comment_start:]
                if not comment_part.endswith('\n'):
                    comment_part += '\n'
                lines[line_num - 1] = code_part + '\n'
                lines.insert(line_num, comment_part)
                print(f"  Split comment to new line: line {line_num}")
    
    with open(file_path, 'w') as f:
        f.writelines(lines)

def main():
    print("=== Fixing All Remaining Parse Errors ===\n")
    
    # Fix animation_commands.gd line 768 - ternary operator
    print("Fixing animation_commands.gd...")
    animation_file = os.path.join(base_path, "commands/animation_commands.gd")
    if os.path.exists(animation_file):
        fix_ternary_operators(animation_file)
    
    # Fix navigation_commands.gd line 37 - indentation
    print("Fixing navigation_commands.gd...")
    nav_file = os.path.join(base_path, "commands/navigation_commands.gd")
    if os.path.exists(nav_file):
        fix_indentation(nav_file, [37])
    
    # Fix node_commands.gd line 124 - indentation
    print("Fixing node_commands.gd...")
    node_file = os.path.join(base_path, "commands/node_commands.gd")
    if os.path.exists(node_file):
        fix_indentation(node_file, [124])
    
    # Fix rendering_commands.gd line 564 - ternary operator
    print("Fixing rendering_commands.gd...")
    render_file = os.path.join(base_path, "commands/rendering_commands.gd")
    if os.path.exists(render_file):
        fix_ternary_operators(render_file)
    
    # Fix scene_commands.gd line 146 - comment newline
    print("Fixing scene_commands.gd...")
    scene_file = os.path.join(base_path, "commands/scene_commands.gd")
    if os.path.exists(scene_file):
        fix_comment_newline(scene_file, 146)
    
    print("\n=== Fixes Complete ===")
    print("Please restart Godot to apply changes.")

if __name__ == "__main__":
    main()
