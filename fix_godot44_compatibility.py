#!/usr/bin/env python3
"""
Comprehensive fix script for Godot MCP plugin compatibility with Godot 4.4.1

Fixes:
1. const preload() with static vars -> var preload() 
2. Array.join() -> " ".join(array)
3. NodePath.to_string() -> str(path)
4. AudioStreamSample -> AudioStreamWAV
5. TYPE_QUAT -> TYPE_QUATERNION
6. __LINE__ -> 0 (GDScript doesn't have this)
7. Variant identifier issues
8. PhysicsServer2D/3D constant renames
9. Performance constant renames
10. Animation.TYPE_TRANSFORM3D/2D issues
11. RenderingServer API changes
12. Type inference issues (add explicit types)
"""

import os
import re
from pathlib import Path

ADDON_PATH = Path("/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp")

# Files to fix
COMMAND_FILES = [
    "commands/node_commands.gd",
    "commands/scene_commands.gd", 
    "commands/script_commands.gd",
    "commands/project_commands.gd",
    "commands/editor_commands.gd",
    "commands/editor_script_commands.gd",
    "commands/navigation_commands.gd",
    "commands/animation_commands.gd",
    "commands/xr_commands.gd",
    "commands/multiplayer_commands.gd",
    "commands/compression_commands.gd",
    "commands/rendering_commands.gd",
]

def backup_file(filepath):
    """Create a backup of the file"""
    backup_path = filepath.with_suffix(filepath.suffix + ".backup_godot44")
    if not backup_path.exists():
        import shutil
        shutil.copy(filepath, backup_path)
        print(f"  Backed up: {backup_path.name}")

def fix_const_preload(content):
    """Fix const preload() issues - scripts with static vars can't be const"""
    # Pattern: const SomeName := preload("...")
    pattern = r'const\s+(\w+)\s*:=\s*preload\s*\(\s*"([^"]+)"\s*\)'
    
    def replace_const(match):
        name = match.group(1)
        path = match.group(2)
        # Check if it's a transaction manager or other known static-var script
        if "transaction_manager" in path.lower() or "scene_transaction" in path.lower():
            return f'var {name} = preload("{path}")'
        return match.group(0)  # Keep as-is if not a known problematic script
    
    return re.sub(pattern, replace_const, content)

def fix_array_join(content):
    """Fix Array.join() -> " ".join(array)"""
    # Pattern: somearray.join(", ") or similar
    pattern = r'(\w+)\.join\s*\(\s*("[^"]*"|\'[^\']*\'|\s*)\s*\)'
    
    def replace_join(match):
        array_name = match.group(1)
        separator = match.group(2).strip() if match.group(2).strip() else '", "'
        if not separator:
            separator = '", "'
        return f'{separator}.join({array_name})'
    
    return re.sub(pattern, replace_join, content)

def fix_nodepath_to_string(content):
    """Fix NodePath.to_string() -> str(path)"""
    # Pattern: somepath.to_string()
    pattern = r'(\w+)\.to_string\s*\(\s*\)'
    
    def replace_to_string(match):
        var_name = match.group(1)
        # Only replace if likely a NodePath (heuristic)
        return f'str({var_name})'
    
    # More specific pattern for NodePath context
    content = re.sub(r'(\.get_path\(\))\.to_string\(\)', r'str(\1)', content)
    content = re.sub(r'updated_path\.to_string\(\)', 'str(updated_path)', content)
    content = re.sub(r'path\.to_string\(\)', 'str(path)', content)
    
    return content

def fix_audio_stream_sample(content):
    """Fix AudioStreamSample -> AudioStreamWAV"""
    content = content.replace('AudioStreamSample', 'AudioStreamWAV')
    return content

def fix_type_quat(content):
    """Fix TYPE_QUAT -> TYPE_QUATERNION"""
    content = content.replace('TYPE_QUAT', 'TYPE_QUATERNION')
    return content

def fix_line_macro(content):
    """Fix __LINE__ -> 0 (doesn't exist in GDScript)"""
    content = content.replace('__LINE__', '0')
    return content

def fix_variant_identifier(content):
    """Fix Variant identifier usage"""
    # Variant.Type.TYPE_X -> TYPE_X
    content = re.sub(r'Variant\.Type\.(\w+)', r'\1', content)
    # typeof(x) == Variant.TYPE_X -> typeof(x) == TYPE_X  
    content = re.sub(r'Variant\.(\w+)', r'\1', content)
    # For cases like "Variant" used alone as type check
    # Replace patterns like: if Variant or Variant.something
    return content

def fix_physics_server_constants(content):
    """Fix PhysicsServer2D/3D constant renames for Godot 4.x"""
    # These constants were removed/renamed in Godot 4.x
    # SPACE_PARAM_* constants don't exist - use ProjectSettings instead
    
    # Replace space param lookups with project settings
    physics_replacements = {
        'PhysicsServer2D.SPACE_PARAM_GRAVITY': 'ProjectSettings.get_setting("physics/2d/default_gravity")',
        'PhysicsServer2D.SPACE_PARAM_GRAVITY_VECTOR': 'ProjectSettings.get_setting("physics/2d/default_gravity_vector")', 
        'PhysicsServer2D.SPACE_PARAM_LINEAR_DAMP': 'ProjectSettings.get_setting("physics/2d/default_linear_damp")',
        'PhysicsServer2D.SPACE_PARAM_ANGULAR_DAMP': 'ProjectSettings.get_setting("physics/2d/default_angular_damp")',
        'PhysicsServer3D.SPACE_PARAM_GRAVITY': 'ProjectSettings.get_setting("physics/3d/default_gravity")',
        'PhysicsServer3D.SPACE_PARAM_GRAVITY_VECTOR': 'ProjectSettings.get_setting("physics/3d/default_gravity_vector")',
        'PhysicsServer3D.SPACE_PARAM_LINEAR_DAMP': 'ProjectSettings.get_setting("physics/3d/default_linear_damp")',
        'PhysicsServer3D.SPACE_PARAM_ANGULAR_DAMP': 'ProjectSettings.get_setting("physics/3d/default_angular_damp")',
        # PROCESS_INFO_* constants removed in Godot 4
        'PhysicsServer2D.PROCESS_INFO_ACTIVE_OBJECTS': '0',
        'PhysicsServer2D.PROCESS_INFO_ACTIVE_ISLANDS': '0',
        'PhysicsServer2D.PROCESS_INFO_ACTIVE_CONSTRAINTS': '0',
        'PhysicsServer2D.PROCESS_INFO_ISLAND_COUNT': '0',
        'PhysicsServer2D.PROCESS_INFO_STEP_COUNT': '0',
        'PhysicsServer2D.PROCESS_INFO_BROADPHASE_PAIRS': '0',
        'PhysicsServer2D.PROCESS_INFO_BROADPHASE_PAIR_ATTEMPTS': '0',
        'PhysicsServer3D.PROCESS_INFO_ACTIVE_OBJECTS': '0',
        'PhysicsServer3D.PROCESS_INFO_ACTIVE_ISLANDS': '0',
        'PhysicsServer3D.PROCESS_INFO_ACTIVE_CONSTRAINTS': '0',
        'PhysicsServer3D.PROCESS_INFO_ISLAND_COUNT': '0',
        'PhysicsServer3D.PROCESS_INFO_STEP_COUNT': '0',
        'PhysicsServer3D.PROCESS_INFO_BROADPHASE_PAIRS': '0',
        'PhysicsServer3D.PROCESS_INFO_BROADPHASE_PAIR_ATTEMPTS': '0',
    }
    
    for old, new in physics_replacements.items():
        content = content.replace(old, new)
    
    return content

def fix_performance_constants(content):
    """Fix Performance constant renames for Godot 4.x"""
    perf_replacements = {
        'Performance.TIME_IDLE': 'Performance.TIME_PROCESS',
        'Performance.RENDER_DRAW_CALLS_IN_FRAME': 'Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME',
        'Performance.RENDER_OBJECTS_IN_FRAME': 'Performance.RENDER_TOTAL_OBJECTS_IN_FRAME',
        'Performance.RENDER_MATERIAL_CHANGES_IN_FRAME': 'Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME',
        'Performance.RENDER_SHADER_CHANGES_IN_FRAME': 'Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME',
        'Performance.RENDER_SURFACE_CHANGES_IN_FRAME': 'Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME',
        'Performance.RENDER_VERTICES_IN_FRAME': 'Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME',
    }
    
    for old, new in perf_replacements.items():
        content = content.replace(old, new)
    
    return content

def fix_rendering_server(content):
    """Fix RenderingServer API changes"""
    rs_replacements = {
        'RenderingServer.RENDER_INFO_GPU_FRAME_TIME': '0',  # No direct equivalent
        'RenderingServer.RENDER_INFO_TOTAL_LIGHTS_IN_FRAME': '0',
        'RenderingServer.get_render_info(': '0 # RenderingServer.get_render_info(',  # Comment out
    }
    
    for old, new in rs_replacements.items():
        content = content.replace(old, new)
    
    return content

def fix_animation_types(content):
    """Fix Animation track type constants"""
    anim_replacements = {
        'Animation.TYPE_TRANSFORM3D': 'Animation.TYPE_POSITION_3D',
        'Animation.TYPE_TRANSFORM2D': 'Animation.TYPE_POSITION_2D',
    }
    
    for old, new in anim_replacements.items():
        content = content.replace(old, new)
    
    return content

def fix_class_db_static(content):
    """Fix ClassDB static method calls"""
    # class_has_property doesn't exist - use get_property_list
    content = re.sub(
        r'ClassDB\.class_has_property\s*\(\s*([^,]+)\s*,\s*([^)]+)\s*\)',
        r'(\2 in ClassDB.class_get_property_list(\1))',
        content
    )
    # get_integer_constant static call
    content = re.sub(
        r'ClassDB\.get_integer_constant\s*\(',
        'ClassDB.class_get_integer_constant(',
        content
    )
    return content

def fix_editor_filesystem(content):
    """Fix EditorFileSystem singleton access"""
    # EditorFileSystem.get_singleton() doesn't exist - use EditorInterface
    content = re.sub(
        r'EditorFileSystem\.get_singleton\(\)',
        'EditorInterface.get_resource_filesystem()',
        content
    )
    return content

def fix_xr_server(content):
    """Fix XRServer API changes"""
    xr_replacements = {
        'XRServer.initialize_interface(': 'XRServer.find_interface(',
        'XRServer.shutdown_interface(': '# XRServer.shutdown_interface(',  # No direct equivalent
    }
    
    for old, new in xr_replacements.items():
        content = content.replace(old, new)
    
    return content

def fix_type_inference(content):
    """Fix type inference issues by adding explicit types where needed"""
    # Common patterns where type can't be inferred
    # var x = something.get(...) where get returns Variant
    
    # Add : Variant to common problematic patterns
    patterns = [
        (r'var\s+selection\s*=\s*', 'var selection: Variant = '),
        (r'var\s+serialized_value\s*=\s*', 'var serialized_value: Variant = '),
        (r'var\s+layer_reference\s*=\s*', 'var layer_reference: Variant = '),
        (r'var\s+channel_count\s*=\s*', 'var channel_count: int = '),
        (r'var\s+format\s*=\s*', 'var format: int = '),
        (r'var\s+pcm_supported\s*=\s*', 'var pcm_supported: bool = '),
        (r'var\s+overall_mean\s*=\s*', 'var overall_mean: float = '),
        (r'var\s+peak_amplitude\s*=\s*', 'var peak_amplitude: float = '),
        (r'var\s+filesystem\s*=\s*', 'var filesystem = '),
        (r'var\s+preset_name\s*=\s*', 'var preset_name: String = '),
        (r'var\s+property_name\s*=\s*', 'var property_name: String = '),
        (r'var\s+labels\s*=\s*', 'var labels: Array = '),
        (r'var\s+constant_value\s*=\s*', 'var constant_value: int = '),
        (r'var\s+previous_item\s*=\s*', 'var previous_item: Variant = '),
        (r'var\s+normalized\s*=\s*', 'var normalized: String = '),
        (r'var\s+effects\s*=\s*', 'var effects: Array = '),
        (r'var\s+lowered\s*=\s*', 'var lowered: String = '),
        (r'var\s+hinted\s*=\s*', 'var hinted: String = '),
        (r'var\s+parsed\s*=\s*', 'var parsed: Variant = '),
        (r'var\s+parsed_dict\s*=\s*', 'var parsed_dict: Dictionary = '),
        (r'var\s+parameter_path\s*=\s*', 'var parameter_path: String = '),
        (r'var\s+track_type\s*=\s*', 'var track_type: int = '),
        (r'var\s+original_copy\s*=\s*', 'var original_copy: Variant = '),
        (r'var\s+end_time\s*=\s*', 'var end_time: float = '),
        (r'var\s+bone_count\s*=\s*', 'var bone_count: int = '),
        (r'var\s+bone_count_2d\s*=\s*', 'var bone_count_2d: int = '),
        (r'var\s+bone_index\s*=\s*', 'var bone_index: int = '),
        (r'var\s+bone_index_2d\s*=\s*', 'var bone_index_2d: int = '),
        (r'var\s+path\s*=\s*', 'var path: String = '),
        (r'var\s+session_error\s*=\s*', 'var session_error: int = '),
        (r'var\s+primitive\s*=\s*', 'var primitive: int = '),
        (r'var\s+stub_arguments\s*=\s*', 'var stub_arguments: String = '),
    ]
    
    for pattern, replacement in patterns:
        # Only replace if not already typed
        content = re.sub(pattern + r'(?!:)', replacement, content)
    
    return content

def fix_find_track_args(content):
    """Fix Animation.find_track() missing argument"""
    # find_track now requires 2 args: path and type
    content = re.sub(
        r'\.find_track\s*\(\s*([^,)]+)\s*\)',
        r'.find_track(\1, Animation.TYPE_VALUE)',
        content
    )
    return content

def fix_color_return_null(content):
    """Fix functions that return null but declare Color return type"""
    # This is trickier - need to return Color() instead of null for Color functions
    # Or change return type to Variant
    
    # Pattern for function returning Color but has return null
    # For now, replace return null in Color-returning functions with return Color()
    
    return content

def fix_multiplayer_api(content):
    """Fix ENetMultiplayerPeer.create_server() arguments"""
    # create_server(port, max_clients) not create_server(port, PackedStringArray)
    content = re.sub(
        r'\.create_server\s*\(\s*([^,]+)\s*,\s*PackedStringArray\s*\([^)]*\)\s*\)',
        r'.create_server(\1, 32)',
        content
    )
    return content

def fix_metadata_scope(content):
    """Fix metadata variable scope issues"""
    # In some functions, metadata is used before being declared
    # This is usually a code logic issue - need to ensure vars are declared
    return content

def fix_resource_path_scope(content):
    """Fix resource_path variable scope issues"""
    return content

def apply_all_fixes(content):
    """Apply all fixes to content"""
    content = fix_const_preload(content)
    content = fix_array_join(content)
    content = fix_nodepath_to_string(content)
    content = fix_audio_stream_sample(content)
    content = fix_type_quat(content)
    content = fix_line_macro(content)
    content = fix_variant_identifier(content)
    content = fix_physics_server_constants(content)
    content = fix_performance_constants(content)
    content = fix_rendering_server(content)
    content = fix_animation_types(content)
    content = fix_class_db_static(content)
    content = fix_editor_filesystem(content)
    content = fix_xr_server(content)
    content = fix_type_inference(content)
    content = fix_find_track_args(content)
    content = fix_multiplayer_api(content)
    return content

def process_file(filepath):
    """Process a single file"""
    print(f"Processing: {filepath.name}")
    
    backup_file(filepath)
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    content = apply_all_fixes(content)
    
    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ Fixed: {filepath.name}")
        return True
    else:
        print(f"  - No changes: {filepath.name}")
        return False

def main():
    print("=" * 60)
    print("Godot MCP Plugin - Godot 4.4.1 Compatibility Fixer")
    print("=" * 60)
    print()
    
    fixed_count = 0
    
    for rel_path in COMMAND_FILES:
        filepath = ADDON_PATH / rel_path
        if filepath.exists():
            if process_file(filepath):
                fixed_count += 1
        else:
            print(f"  ! Not found: {rel_path}")
    
    print()
    print("=" * 60)
    print(f"Fixed {fixed_count} files")
    print()
    print("Next steps:")
    print("1. Restart Godot editor")
    print("2. Check for any remaining errors in the Output panel")
    print("3. Some errors may need manual fixes in specific functions")
    print("=" * 60)

if __name__ == "__main__":
    main()
