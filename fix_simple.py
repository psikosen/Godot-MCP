#!/usr/bin/env python3
"""Fix all GDScript ternary operators at once."""
import re

def fix_ternary_in_text(text):
    """Replace C-style ternary with GDScript if/else."""
    # Pattern: anything before ? true_value : false_value
    # We need to be careful about nested ternaries and complex expressions
    
    def replace_ternary(match):
        condition = match.group(1).strip()
        true_val = match.group(2).strip()
        false_val = match.group(3).strip()
        return f"{true_val} if {condition} else {false_val}"
    
    # Match ternary: condition ? true_value : false_value
    # Use non-greedy matching and handle parentheses
    pattern = r'([^?:]+)\s*\?\s*([^:]+)\s*:\s*([^,\)\]\}]+)'
    
    # Keep replacing until no more found (handles nested ternaries)
    max_iterations = 10
    for _ in range(max_iterations):
        new_text = re.sub(pattern, replace_ternary, text)
        if new_text == text:
            break
        text = new_text
    
    return text

# File-specific fixes (line number, old, new)
fixes = {
    "rendering_commands.gd": [
        (564, 
         '\t\t"status": transaction_id == "" ? "committed" : "pending",',
         '\t\t"status": "committed" if transaction_id == "" else "pending",'),
    ],
    "script_commands.gd": [
        (201,
         '\t\t\t\t"language": path.ends_with(".gd") ? "gdscript" : (path.ends_with(".cs") ? "csharp" : "unknown")',
         '\t\t\t\t"language": "gdscript" if path.ends_with(".gd") else ("csharp" if path.ends_with(".cs") else "unknown")'),
    ],
    "editor_commands.gd": [
        (294,
         '\t\t\t"class": stylebox != null ? stylebox.get_class() : "",',
         '\t\t\t"class": stylebox.get_class() if stylebox != null else "",'),
        (834,
         '\t\t"error": is_error ? message : "",',
         '\t\t"error": message if is_error else "",'),
    ],
    "project_commands.gd": [
        (183,
         '\t\t\t\t"current_scene": get_tree().edited_scene_root ? get_tree().edited_scene_root.scene_file_path : ""',
         '\t\t\t\t"current_scene": get_tree().edited_scene_root.scene_file_path if get_tree().edited_scene_root else ""'),
        (458,
         '\t\t\t\t\t\t"type": effect ? effect.get_class() : "Unknown",',
         '\t\t\t\t\t\t"type": effect.get_class() if effect else "Unknown",'),
        (486,
         '\t\t"error": is_error ? message : "",',
         '\t\t"error": message if is_error else "",'),
    ],
}

base_path = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/"

for filename, replacements in fixes.items():
    filepath = base_path + filename
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
        
        for line_num, old_text, new_text in replacements:
            if lines[line_num - 1].rstrip() == old_text.rstrip():
                lines[line_num - 1] = new_text + '\n'
                print(f"✓ Fixed {filename}:{line_num}")
            else:
                print(f"⚠ Line {line_num} in {filename} doesn't match expected text")
                print(f"  Expected: {old_text[:80]}")
                print(f"  Found:    {lines[line_num - 1][:80]}")
        
        with open(filepath, 'w') as f:
            f.writelines(lines)
    except Exception as e:
        print(f"✗ Error with {filename}: {e}")

print("\n✓ Fixed simple ternary operators")
