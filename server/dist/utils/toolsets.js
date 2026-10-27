// Tool groups. Listing every tool costs about 71k tokens per session in clients that load all tool
// schemas up front, so by default only the core tools (about 4k) are on and the AI turns on the
// groups its task needs with load_tools. GODOT_MCP_TOOLSETS picks the groups that start on.
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
// Everyday scene and script editing. Always on; keep it small (a test holds it under 5k tokens).
var CORE = new Set([
    'get_project_info', 'get_scene_tree', 'get_current_scene', 'open_scene', 'create_scene', 'save_scene',
    'create_node', 'delete_node', 'duplicate_node', 'rename_node', 'reparent_node', 'instantiate_scene',
    'batch_create_nodes', 'batch_update_nodes', 'update_node_property', 'get_node_properties', 'query_nodes',
    'create_script', 'edit_script', 'get_script', 'set_node_script',
    'undo_redo', 'get_godot_errors', 'search_project',
]);
// [group, tools, what it is for]. The first matching pattern wins.
var RULES = [
    ['scene', /^(batch_delete_nodes|bulk_update_node_properties|move_node_in_parent|(add|remove)_node_(to|from)_group|list_node_groups|list_nodes_in_group|list_nodes|set_node_owner_recursive|save_branch_as_scene|create_inherited_scene|snapshot_scene_state|create_path|select_in_editor|create_resource|(get|update)_resource_properties)$|scene_transaction|_patch$/,
        'node groups, transactions, patches, inherited scenes, resource files, paths'],
    ['scripting', /^(create_script_template|get_script_outline|replace_in_script|replace_in_project|clear_node_script|wire_signal_handler|disconnect_signal|list_signal_connections|describe_class|execute_editor_script)$/,
        'signals, script outlines, find and replace, templates, class docs, editor scripts'],
    ['project', /input_action|input_event|^(configure_game_settings|configure_project_setting|manage_autoloads|manage_translations|manage_editor_plugins|list_editor_plugins|create_project|export_project|find_unused_files|move_project_file|delete_project_file|query_project_index|refresh_project_index)$|permission_escalation/,
        'input actions, settings, autoloads, translations, plugins, export, files, approvals'],
    ['testing', /^(capture_game_frame|capture_scene_image|capture_editor_profile|profile_game|run_game_tests|run_godot_headless|check_project)$/,
        'run the game, screenshots, profiling, game tests, headless runs'],
    ['xr', /xr_/, 'VR/AR interfaces'],
    ['multiplayer', /multiplayer/, 'network peers and synced spawning'],
    ['space', /planet|ocean_tile|crater|ring_system|starfield|moon/, 'planets, oceans, moons, rings, craters, starfield skies'],
    ['effects', /smoke|weather|water_|sand_field|slime_mold|tentacle|creature/, 'smoke, weather, water bodies and currents, sand, slime mold, creatures'],
    ['levelgen', /blockout|cave_|dungeon|heightmap|tilemap_noise|terrain_autopaint|terrain_3d|triplanar|scatter_|along_path|wave_spawner/,
        'blockouts, caves, dungeons, terrain, scattering, along paths, wave spawners'],
    ['animation', /animat|tween|skeleton|sprite_frames|ik_chain|bone_constraint|spring_bones/,
        'AnimationPlayer and AnimationTree, tweens, sprite frames, skeletons, IK, spring bones'],
    ['audio', /audio|music|waveform|sfx/, 'audio players and buses, music layers, sound effects'],
    ['navigation', /navigation|navmesh|pathfollow|path[23]d_followers|chase_step/, 'navigation agents, regions and obstacles, path followers, chase steps'],
    ['physics', /physics|joint|collision|ragdoll/, 'bodies, areas, joints, collision shapes and layers, ragdolls'],
    ['ui', /hud_|menu_ui|theme|accessibility|layout_ui|minimap|control_layout|touch_controls/, 'HUDs, menus, themes, layouts, minimaps, touch controls, accessibility'],
    ['assets', /texture|lightmap|mesh_lods|material|shader|stencil|model|screen_effect|placeholder|environment|sun_settings|import_asset/,
        'model and texture import, materials, shaders, sky, screen effects, placeholder art'],
    ['2d', /_2d$|2d_|tilemap|parallax|sprite|camera2d/, 'tilemaps, sprites, 2D cameras and controllers, parallax, 2D lights and enemies'],
    ['3d', /_3d$|3d_|gridmap|mesh_library|multimesh|day_night|snap_to_ground|csg|camera3d|springarm|light_node|particles/,
        'gridmaps, CSG, 3D cameras and controllers, lights, particles, day/night, 3D enemies'],
];
// Task groups: the tools one job needs, taken from several groups above, so a focused task loads
// less than whole groups. A tool can be in many task groups; it stays on while any of them is on.
var tools = function () {
    var names = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        names[_i] = arguments[_i];
    }
    return new Set(names);
};
export var TASK_GROUPS = [
    ['player_2d', tools('configure_characterbody2d_controller', 'configure_topdown_movement_2d', 'simulate_characterbody2d_movement', 'configure_camera2d_follow', 'configure_camera2d_limits', 'add_input_action', 'add_input_event_to_action', 'list_input_actions', 'configure_sprite_2d', 'configure_animated_sprite_2d', 'create_sprite_frames', 'fit_collision_shape', 'set_collision_layers', 'configure_area2d_sensor', 'add_touch_controls'),
        '2D player: platformer or top-down movement, camera, input, sprite animation'],
    ['player_3d', tools('configure_characterbody3d_controller', 'simulate_characterbody3d_movement', 'configure_camera3d_rig', 'configure_springarm3d', 'add_input_action', 'add_input_event_to_action', 'list_input_actions', 'add_animation_library', 'configure_animation_tree', 'set_animation_tree_state', 'set_animation_tree_parameters', 'fit_collision_shape', 'set_collision_layers', 'snap_to_ground', 'add_touch_controls'),
        '3D player: movement, camera rig, input, AnimationTree'],
    ['enemies', tools('author_enemy_ai_2d', 'author_enemy_ai_3d', 'configure_navigation_agent_2d', 'configure_navigation_agent_3d', 'set_navigation_target_to_node_2d', 'set_navigation_target_to_node_3d', 'simulate_navigation_chase_step_2d', 'simulate_navigation_chase_step_3d', 'bake_navigation_region', 'build_wave_spawner_2d', 'build_wave_spawner_3d', 'simulate_wave_spawner_step_2d', 'simulate_wave_spawner_step_3d', 'configure_area2d_sensor', 'configure_physics_area', 'set_collision_layers'),
        'enemy AI that patrols, chases and attacks; pathfinding; wave spawners'],
    ['tilemap_level', tools('create_tileset_2d', 'paint_tilemap_cells_2d', 'paint_tilemap_ascii', 'fill_tilemap_rect_2d', 'clear_tilemap_cells_2d', 'tilemap_terrain_autopaint_2d', 'generate_tilemap_noise_2d', 'generate_platformer_blockout_2d', 'generate_topdown_dungeon_2d', 'generate_isometric_tile_blockout_2d', 'synchronize_navmesh_with_tilemap', 'generate_placeholder_art'),
        '2D tile level: tileset from a sheet, painting, terrain, generated layouts'],
    ['world_3d', tools('generate_terrain_3d', 'apply_triplanar_terrain_material', 'build_water_body_3d', 'scatter_scene_instances_3d', 'snap_to_ground', 'create_path', 'place_along_path', 'convert_to_multimesh', 'setup_day_night_cycle', 'configure_environment', 'generate_heightmap_gridmap_3d', 'build_blockout_3d', 'configure_csg_shape', 'bake_csg', 'capture_scene_image'),
        'outdoor 3D world: terrain, water, props, paths, sky and day/night'],
    ['rigging', tools('inspect_model', 'configure_model_import', 'add_animation_library', 'describe_skeleton', 'setup_ik_chain', 'add_bone_constraint', 'setup_spring_bones', 'create_ragdoll', 'bake_skeleton_pose', 'describe_animation_tracks', 'edit_animation', 'configure_animation_tree', 'set_animation_tree_state', 'set_animation_tree_parameters'),
        'rigged 3D models: import, shared animations, IK, spring bones, ragdolls'],
    ['lighting', tools('configure_light_node', 'setup_2d_lighting', 'build_light_occluder_2d', 'edit_light_occluder_polygon_2d', 'configure_environment', 'preview_environment_sun_settings', 'setup_day_night_cycle', 'unwrap_lightmap_uv2', 'capture_scene_image'),
        '2D and 3D lights and shadows, environment, sun, day/night'],
    ['vfx', tools('configure_particles_2d', 'configure_particles_3d', 'sync_particles_with_animation', 'add_screen_effect', 'create_canvas_shader', 'create_spatial_shader', 'compile_shader_preview', 'set_stencil_effect', 'simulate_camera2d_shake', 'simulate_camera3d_shake', 'generate_tween_sequence', 'build_smoke_effect_2d', 'build_smoke_effect_3d', 'generate_sfx', 'create_audio_randomizer', 'capture_scene_image'),
        'game feel: particles, shaders, screen effects, shake, tweens, hit sounds'],
    ['release', tools('check_project', 'run_game_tests', 'profile_game', 'capture_game_frame', 'find_unused_files', 'configure_game_settings', 'configure_texture_compression', 'list_texture_compression_settings', 'manage_translations', 'validate_accessibility', 'export_project'),
        'ship it: checks, tests, profiling, unused files, settings, export'],
    ['refactor', tools('replace_in_project', 'replace_in_script', 'get_script_outline', 'move_project_file', 'delete_project_file', 'find_unused_files', 'save_branch_as_scene', 'create_inherited_scene', 'list_signal_connections', 'disconnect_signal', 'query_project_index', 'refresh_project_index'),
        'clean up: rename across files, move or delete files, split scenes, signals'],
    // Read-only look-arounds: every list_/describe_/get_/inspect_ style tool outside core.
    ['inspect', /^(list_|describe_|get_|inspect_|query_|find_|check_|validate_|analyze_)|^capture_scene_image$/,
        'read-only: list and describe nodes, signals, animations, audio, input, models'],
];
export var TOOLSETS = __spreadArray(__spreadArray(['core'], RULES.map(function (_a) {
    var name = _a[0];
    return name;
}), true), TASK_GROUPS.map(function (_a) {
    var name = _a[0];
    return name;
}), true);
/** The tool's main group: core, or the first rule it matches. */
export function toolsetOf(toolName) {
    var _a, _b;
    if (CORE.has(toolName))
        return 'core';
    // ponytail: unmatched tools fall back to core; a test fails when that happens, so new tools get a group.
    return (_b = (_a = RULES.find(function (_a) {
        var pattern = _a[1];
        return pattern.test(toolName);
    })) === null || _a === void 0 ? void 0 : _a[0]) !== null && _b !== void 0 ? _b : 'core';
}
/** Every group the tool is in: its main group, then the task groups that list it. */
export function groupsOf(toolName) {
    var main = toolsetOf(toolName);
    var tasks = main === 'core' ? [] : TASK_GROUPS
        .filter(function (_a) {
        var members = _a[1];
        return members instanceof RegExp ? members.test(toolName) : members.has(toolName);
    })
        .map(function (_a) {
        var name = _a[0];
        return name;
    });
    return __spreadArray([main], tasks, true);
}
/** The load_tools menu, one line per group: "- physics (10): bodies, areas, ...". */
export function toolsetMenu(counts) {
    var lines = function (groups) { return groups.filter(function (_a) {
        var name = _a[0];
        return counts.get(name);
    })
        .map(function (_a) {
        var name = _a[0], purpose = _a[2];
        return "- ".concat(name, " (").concat(counts.get(name), "): ").concat(purpose);
    }).join('\n'); };
    return "Task groups (just what one job needs):\n".concat(lines(TASK_GROUPS), "\n") +
        "Feature groups (all tools for one area):\n".concat(lines(RULES));
}
/** Parses GODOT_MCP_TOOLSETS ("2d,animation" or "all"). Unset means core only. Returns null for all. */
export function enabledToolsets(value) {
    var names = (value !== null && value !== void 0 ? value : '').split(',').map(function (name) { return name.trim().toLowerCase(); }).filter(Boolean);
    if (names.includes('all'))
        return null;
    var unknown = names.filter(function (name) { return !TOOLSETS.includes(name); });
    if (unknown.length > 0) {
        console.error("GODOT_MCP_TOOLSETS: unknown toolset(s) ".concat(unknown.join(', '), "; known: ").concat(TOOLSETS.join(', ')));
    }
    return new Set(__spreadArray(['core'], names.filter(function (name) { return TOOLSETS.includes(name); }), true));
}
//# sourceMappingURL=toolsets.js.map