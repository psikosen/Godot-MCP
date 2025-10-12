@tool
class_name MCPEditorCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/editor_commands.gd"
const DEFAULT_SYSTEM_SECTION := "editor_commands"
const SNAPSHOT_MAX_DEPTH_LIMIT := 6
const SNAPSHOT_PROPERTY_LIMIT_DEFAULT := 32
const SNAPSHOT_USAGE_MASK := PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"get_editor_state":
			_get_editor_state(client_id, params, command_id)
			return true
		"get_selected_node":
			_get_selected_node(client_id, params, command_id)
			return true
		"create_resource":
			_create_resource(client_id, params, command_id)
			return true
                "get_ui_theme_summary":
                        _get_ui_theme_summary(client_id, params, command_id)
                        return true
                "run_godot_headless":
                        _run_godot_headless(client_id, params, command_id)
                        return true
                "capture_editor_profile":
                        _capture_editor_profile(client_id, params, command_id)
                        return true
                "manage_editor_plugins":
                        _manage_editor_plugins(client_id, params, command_id)
                        return true
                "snapshot_scene_state":
                        _snapshot_scene_state(client_id, params, command_id)
                        return true
        return false  # Command not handled

func _get_editor_state(client_id: int, params: Dictionary, command_id: String) -> void:
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	
	var state = {
		"current_scene": "",
		"current_script": "",
		"selected_nodes": [],
		"is_playing": editor_interface.is_playing_scene()
	}
	
	# Get current scene
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if edited_scene_root:
		state["current_scene"] = edited_scene_root.scene_file_path
	
	# Get current script if any is being edited
	var script_editor = editor_interface.get_script_editor()
	var current_script = script_editor.get_current_script()
	if current_script:
		state["current_script"] = current_script.resource_path
	
	# Get selected nodes
	var selection = editor_interface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	for node in selected_nodes:
		state["selected_nodes"].append({
			"name": node.name,
			"path": str(node.get_path())
		})
	
	_send_success(client_id, state, command_id)

func _get_selected_node(client_id: int, params: Dictionary, command_id: String) -> void:
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var selection = editor_interface.get_selection()
	var selected_nodes = selection.get_selected_nodes()
	
	if selected_nodes.size() == 0:
		return _send_success(client_id, {
			"selected": false,
			"message": "No node is currently selected"
		}, command_id)
	
	var node = selected_nodes[0]  # Get the first selected node
	
	# Get node info
	var node_data = {
		"selected": true,
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path())
	}
	
	# Get script info if available
	var script = node.get_script()
	if script:
		node_data["script_path"] = script.resource_path
	
	# Get important properties
	var properties = {}
	var property_list = node.get_property_list()
	
	for prop in property_list:
		var name = prop["name"]
		if not name.begins_with("_"):  # Skip internal properties
			# Only include some common properties to avoid overwhelming data
			if name in ["position", "rotation", "scale", "visible", "modulate", "z_index"]:
				properties[name] = node.get(name)
	
	node_data["properties"] = properties
	
	_send_success(client_id, node_data, command_id)

func _create_resource(client_id: int, params: Dictionary, command_id: String) -> void:
	var resource_type = params.get("resource_type", "")
	var resource_path = params.get("resource_path", "")
	var properties = params.get("properties", {})
	
	# Validation
	if resource_type.is_empty():
		return _send_error(client_id, "Resource type cannot be empty", command_id)
	
	if resource_path.is_empty():
		return _send_error(client_id, "Resource path cannot be empty", command_id)
	
	# Make sure we have an absolute path
	if not resource_path.begins_with("res://"):
		resource_path = "res://" + resource_path
	
	# Get editor interface
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	
	# Create the resource
	var resource
	
	if ClassDB.class_exists(resource_type):
		if ClassDB.is_parent_class(resource_type, "Resource"):
			resource = ClassDB.instantiate(resource_type)
			if not resource:
				return _send_error(client_id, "Failed to instantiate resource: %s" % resource_type, command_id)
		else:
			return _send_error(client_id, "Type is not a Resource: %s" % resource_type, command_id)
	else:
		return _send_error(client_id, "Invalid resource type: %s" % resource_type, command_id)
	
	# Set properties
	for key in properties:
		resource.set(key, properties[key])
	
	# Create directory if needed
	var dir = resource_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			return _send_error(client_id, "Failed to create directory: %s (Error code: %d)" % [dir, err], command_id)
	
	# Save the resource
	var result = ResourceSaver.save(resource, resource_path)
	if result != OK:
		return _send_error(client_id, "Failed to save resource: %d" % result, command_id)
	
	# Refresh the filesystem
	editor_interface.get_resource_filesystem().scan()
	
	_send_success(client_id, {
		"resource_path": resource_path,
		"resource_type": resource_type
	}, command_id)

func _get_ui_theme_summary(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_get_ui_theme_summary"
	var include_palettes := params.get("include_palettes", true)
	var include_icons := params.get("include_icons", true)
	var include_fonts := params.get("include_fonts", true)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		_log("GodotMCPPlugin not found in Engine metadata", function_name, {
			"system_section": "ui_theme_summary",
		}, true)
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface: EditorInterface = plugin.get_editor_interface()
	var base_control: Control = editor_interface.get_base_control()
	if base_control == null:
		_log("Editor base control unavailable", function_name, {
			"system_section": "ui_theme_summary",
		}, true)
		return _send_error(client_id, "Editor base control unavailable", command_id)

	var theme: Theme = base_control.get_theme()
	if theme == null:
		theme = ThemeDB.get_project_theme()

	if theme == null:
		_log("Unable to resolve an active UI Theme", function_name, {
			"system_section": "ui_theme_summary",
		}, true)
		return _send_error(client_id, "Unable to resolve the active editor theme", command_id)

	var type_list: PackedStringArray = theme.get_type_list()
	var types: Array = []
	var color_total := 0
	var icon_total := 0
	var font_total := 0

	for type_name in type_list:
		var entry := {
			"type": String(type_name),
			"constants": _collect_theme_constants(theme, type_name),
		}

		if include_palettes:
			var colors = _collect_theme_colors(theme, type_name)
			var styleboxes = _collect_theme_styleboxes(theme, type_name)
			entry["colors"] = colors
			entry["styleboxes"] = styleboxes
			color_total += colors.size()

		if include_icons:
			var icons = _collect_theme_icons(theme, type_name)
			entry["icons"] = icons
			icon_total += icons.size()

		if include_fonts:
			var fonts = _collect_theme_fonts(theme, type_name)
			var font_sizes = _collect_theme_font_sizes(theme, type_name)
			entry["fonts"] = fonts
			entry["font_sizes"] = font_sizes
			font_total += fonts.size()

		types.append(entry)

	var summary := {
		"theme_name": theme.resource_name,
		"resource_path": theme.resource_path,
		"default_font": _serialize_resource(theme.get_default_font()),
		"default_font_size": theme.get_default_font_size(),
		"type_count": types.size(),
		"types": types,
	}

	_log("Summarised UI Theme metadata", function_name, {
		"system_section": "ui_theme_summary",
		"type_count": types.size(),
		"color_definitions": color_total,
		"icon_definitions": icon_total,
		"font_definitions": font_total,
		"include_palettes": include_palettes,
		"include_icons": include_icons,
		"include_fonts": include_fonts,
	})

	_send_success(client_id, summary, command_id)

func _collect_theme_constants(theme: Theme, type_name: String) -> Array:
	var constants: Array = []
	for constant_name in theme.get_constant_list(type_name):
		constants.append({
			"name": String(constant_name),
			"value": theme.get_constant(constant_name, type_name),
		})
	return constants

func _collect_theme_colors(theme: Theme, type_name: String) -> Array:
	var colors: Array = []
	for color_name in theme.get_color_list(type_name):
		colors.append({
			"name": String(color_name),
			"value": _serialize_color(theme.get_color(color_name, type_name)),
		})
	return colors

func _collect_theme_styleboxes(theme: Theme, type_name: String) -> Array:
	var styleboxes: Array = []
	for style_name in theme.get_stylebox_list(type_name):
		var stylebox = theme.get_stylebox(style_name, type_name)
		styleboxes.append({
			"name": String(style_name),
			"class": stylebox != null ? stylebox.get_class() : "",
			"resource": _serialize_resource(stylebox),
		})
	return styleboxes

func _collect_theme_icons(theme: Theme, type_name: String) -> Array:
	var icons: Array = []
	for icon_name in theme.get_icon_list(type_name):
		var icon = theme.get_icon(icon_name, type_name)
		icons.append({
			"name": String(icon_name),
			"resource": _serialize_resource(icon),
		})
	return icons

func _collect_theme_fonts(theme: Theme, type_name: String) -> Array:
	var fonts: Array = []
	for font_name in theme.get_font_list(type_name):
		var font = theme.get_font(font_name, type_name)
		fonts.append({
			"name": String(font_name),
			"resource": _serialize_resource(font),
		})
	return fonts

func _collect_theme_font_sizes(theme: Theme, type_name: String) -> Array:
        var font_sizes: Array = []
        for size_name in theme.get_font_size_list(type_name):
                font_sizes.append({
                        "name": String(size_name),
                        "size": theme.get_font_size(size_name, type_name),
                })
        return font_sizes

func _run_godot_headless(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_run_godot_headless"
        var binary_path: String = params.get("binary_path", OS.get_executable_path())
        var run_target: String = params.get("run_target", "")
        var additional_args: Array = params.get("additional_args", [])
        var capture_stderr: bool = params.get("capture_stderr", true)
        var include_no_window: bool = params.get("no_window", true)
        var project_path := ProjectSettings.globalize_path("res://")
        var log_context := {
                "system_section": "editor_headless_run",
                "line_num": __LINE__,
                "binary": binary_path,
                "run_target": run_target,
                "capture_stderr": capture_stderr,
                "no_window": include_no_window,
        }

        if binary_path.is_empty():
                log_context["line_num"] = __LINE__
                _log("Godot executable path could not be resolved", function_name, log_context, true)
                return _send_error(client_id, "Godot executable path could not be resolved", command_id)

        var argument_array: Array = ["--headless"]
        if include_no_window:
                argument_array.append("--no-window")
        argument_array.append("--path")
        argument_array.append(project_path)
        if not run_target.is_empty():
                argument_array.append("--run")
                argument_array.append(run_target)

        for arg in additional_args:
                argument_array.append(String(arg))

        var packed_arguments := PackedStringArray(argument_array)
        log_context["arguments"] = argument_array

        var start_time := Time.get_ticks_msec()
        var output: Array = []
        var exit_code := OS.execute(binary_path, packed_arguments, output, capture_stderr)
        var duration_ms := Time.get_ticks_msec() - start_time

        log_context["line_num"] = __LINE__
        log_context["exit_code"] = exit_code
        log_context["duration_ms"] = duration_ms

        if exit_code == ERR_CANT_OPEN:
                log_context["line_num"] = __LINE__
                _log("Failed to launch Godot headless process", function_name, log_context, true)
                return _send_error(client_id, "Failed to launch Godot headless process", command_id)

        var normalized_output: Array = []
        for line in output:
                normalized_output.append(String(line))

        var response := {
                "binary": binary_path,
                "arguments": argument_array,
                "exit_code": exit_code,
                "output": normalized_output,
                "duration_ms": duration_ms,
                "project_path": project_path,
                "stderr_included": capture_stderr,
        }

        if exit_code != OK:
                log_context["line_num"] = __LINE__
                _log("Headless Godot run completed with non-zero exit code", function_name, log_context, true)
        else:
                log_context["line_num"] = __LINE__
                _log("Executed headless Godot run", function_name, log_context)

        _send_success(client_id, response, command_id)


func _capture_editor_profile(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_capture_editor_profile"
        var include_rendering: bool = params.get("include_rendering", true)
        var include_objects: bool = params.get("include_objects", true)
        var include_memory: bool = params.get("include_memory", true)
        var include_gpu: bool = params.get("include_gpu", true)
        var log_context := {
                "system_section": "editor_profile_snapshot",
                "line_num": __LINE__,
                "include_rendering": include_rendering,
                "include_objects": include_objects,
                "include_memory": include_memory,
                "include_gpu": include_gpu,
        }

        var profile := {
                "captured_at": Time.get_datetime_string_from_system(true, true),
                "fps": Engine.get_frames_per_second(),
        }

        var cpu := {
                "process_time_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
                "physics_time_ms": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
                "idle_time_ms": Performance.get_monitor(Performance.TIME_IDLE) * 1000.0,
        }
        cpu["frame_time_ms"] = cpu["process_time_ms"] + cpu["idle_time_ms"]
        profile["cpu"] = cpu

        if include_memory:
                profile["memory"] = {
                        "static_kb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0,
                        "static_max_kb": Performance.get_monitor(Performance.MEMORY_STATIC_MAX) / 1024.0,
                        "message_buffer_max_kb": Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX) / 1024.0,
                }

        if include_objects:
                profile["objects"] = {
                        "total": Performance.get_monitor(Performance.OBJECT_COUNT),
                        "nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
                        "resources": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
                }

        if include_rendering:
                var rendering := {
                        "draw_calls": Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME),
                        "objects": Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME),
                        "material_changes": Performance.get_monitor(Performance.RENDER_MATERIAL_CHANGES_IN_FRAME),
                        "shader_changes": Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME),
                        "surfaces": Performance.get_monitor(Performance.RENDER_SURFACE_CHANGES_IN_FRAME),
                        "vertices": Performance.get_monitor(Performance.RENDER_VERTICES_IN_FRAME),
                }
                if include_gpu:
                        rendering["gpu_time_ms"] = RenderingServer.get_render_info(RenderingServer.RENDER_INFO_GPU_FRAME_TIME)
                        rendering["lights"] = RenderingServer.get_render_info(RenderingServer.RENDER_INFO_TOTAL_LIGHTS_IN_FRAME)
                profile["rendering"] = rendering

        log_context["line_num"] = __LINE__
        log_context["summary"] = {
                "fps": profile.get("fps", 0.0),
                "draw_calls": profile.get("rendering", {}).get("draw_calls", 0),
        }
        _log("Captured editor performance snapshot", function_name, log_context)

        _send_success(client_id, profile, command_id)


func _manage_editor_plugins(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_manage_editor_plugins"
        var action: String = params.get("action", "list")
        var targets: Array = params.get("plugins", [])
        var persist: bool = params.get("persist", false)
        var log_context := {
                "system_section": "editor_plugin_management",
                "line_num": __LINE__,
                "action": action,
                "target_count": targets.size(),
                "persist": persist,
        }

        var plugin := Engine.get_meta("GodotMCPPlugin")
        if not plugin:
                log_context["line_num"] = __LINE__
                _log("GodotMCPPlugin not found in Engine metadata", function_name, log_context, true)
                return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

        var editor_interface: EditorInterface = plugin.get_editor_interface()
        var plugin_inventory := _collect_editor_plugins()
        var entries: Array = plugin_inventory.get("plugins", [])
        var enabled_array: Array = plugin_inventory.get("enabled_array", [])
        var lookup: Dictionary = plugin_inventory.get("lookup", {})
        var name_lookup: Dictionary = plugin_inventory.get("name_lookup", {})

        if action == "list":
                log_context["line_num"] = __LINE__
                log_context["plugins_detected"] = entries.size()
                _log("Enumerated editor plugins", function_name, log_context)
                return _send_success(client_id, {
                        "plugins": entries,
                        "enabled_plugins": enabled_array,
                }, command_id)

        if action != "enable" and action != "disable":
                log_context["line_num"] = __LINE__
                _log("Unsupported editor plugin action", function_name, log_context, true)
                return _send_error(client_id, "Unsupported editor plugin action", command_id)

        if targets.is_empty():
                log_context["line_num"] = __LINE__
                _log("No editor plugins were supplied for mutation", function_name, log_context, true)
                return _send_error(client_id, "No editor plugins were supplied for mutation", command_id)

        var enable_plugins := action == "enable"
        var normalized_targets: Array = []
        for raw_target in targets:
                var target_key := String(raw_target)
                if lookup.has(target_key):
                        normalized_targets.append(target_key)
                elif name_lookup.has(target_key):
                        normalized_targets.append(name_lookup[target_key]["path"])
                else:
                        _log("Requested editor plugin could not be resolved", function_name, {
                                "system_section": "editor_plugin_management",
                                "line_num": __LINE__,
                                "target": target_key,
                        }, true)

        if normalized_targets.is_empty():
                return _send_error(client_id, "No valid editor plugins were resolved for the requested action", command_id)

        var updated_enabled := enabled_array.duplicate()
        var mutated: Array = []

        for plugin_path in normalized_targets:
                if enable_plugins and not updated_enabled.has(plugin_path):
                        updated_enabled.append(plugin_path)
                        mutated.append(plugin_path)
                elif not enable_plugins and updated_enabled.has(plugin_path):
                        updated_enabled.erase(plugin_path)
                        mutated.append(plugin_path)

                if editor_interface and editor_interface.has_method("set_plugin_enabled"):
                        editor_interface.set_plugin_enabled(plugin_path, enable_plugins)

        if mutated.is_empty():
                log_context["line_num"] = __LINE__
                log_context["mutated"] = mutated
                _log("Editor plugin state already matched requested configuration", function_name, log_context)
                return _send_success(client_id, {
                        "mutated": [],
                        "enabled_plugins": updated_enabled,
                        "persisted": false,
                }, command_id)

        ProjectSettings.set_setting("editor_plugins/enabled", PackedStringArray(updated_enabled))
        var persisted := false
        if persist:
                var save_err := ProjectSettings.save()
                if save_err != OK:
                        log_context["line_num"] = __LINE__
                        _log("Failed to persist editor plugin configuration", function_name, log_context, true)
                        return _send_error(client_id, "Failed to persist editor plugin configuration", command_id)
                persisted = true

        log_context["line_num"] = __LINE__
        log_context["mutated"] = mutated
        _log("Mutated editor plugin enablement", function_name, log_context)

        _send_success(client_id, {
                "mutated": mutated,
                "enabled_plugins": updated_enabled,
                "persisted": persisted,
        }, command_id)


func _snapshot_scene_state(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_snapshot_scene_state"
        var include_internal: bool = params.get("include_internal", false)
        var include_resources: bool = params.get("include_resources", true)
        var max_properties: int = clamp(params.get("max_properties_per_node", SNAPSHOT_PROPERTY_LIMIT_DEFAULT), 0, 512)
        var node_limit: int = params.get("node_limit", 0)
        var max_depth: int = clamp(params.get("max_depth", 3), 1, SNAPSHOT_MAX_DEPTH_LIMIT)
        var log_context := {
                "system_section": "editor_scene_snapshot",
                "line_num": __LINE__,
                "include_internal": include_internal,
                "include_resources": include_resources,
                "max_properties": max_properties,
                "node_limit": node_limit,
                "max_depth": max_depth,
        }

        var plugin := Engine.get_meta("GodotMCPPlugin")
        if not plugin:
                log_context["line_num"] = __LINE__
                _log("GodotMCPPlugin not found in Engine metadata", function_name, log_context, true)
                return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

        var editor_interface: EditorInterface = plugin.get_editor_interface()
        var root := editor_interface.get_edited_scene_root()
        if root == null:
                log_context["line_num"] = __LINE__
                _log("No edited scene available for snapshot", function_name, log_context, true)
                return _send_error(client_id, "No edited scene available for snapshot", command_id)

        var snapshot := _build_scene_snapshot(root, {
                "include_internal": include_internal,
                "include_resources": include_resources,
                "max_properties": max_properties,
                "node_limit": node_limit,
                "max_depth": max_depth,
        })

        log_context["line_num"] = __LINE__
        log_context["node_count"] = snapshot.get("node_count", 0)
        log_context["scene_path"] = snapshot.get("scene_path", "")
        _log("Captured editor scene snapshot", function_name, log_context)

        _send_success(client_id, snapshot, command_id)


func _collect_editor_plugins() -> Dictionary:
        var enabled_setting = ProjectSettings.get_setting("editor_plugins/enabled", PackedStringArray())
        var enabled_plugins := PackedStringArray()
        if typeof(enabled_setting) == TYPE_PACKED_STRING_ARRAY:
                enabled_plugins = enabled_setting
        elif typeof(enabled_setting) == TYPE_ARRAY:
                enabled_plugins = PackedStringArray(enabled_setting)

        var enabled_array: Array = []
        for path in enabled_plugins:
                enabled_array.append(String(path))

        var addons_dir := DirAccess.open("res://addons")
        var entries: Array = []
        var lookup := {}
        var name_lookup := {}

        if addons_dir:
                addons_dir.list_dir_begin()
                var entry := addons_dir.get_next()
                while entry != "":
                        if addons_dir.current_is_dir() and not entry.begins_with("."):
                                var plugin_cfg_path := "res://addons/%s/plugin.cfg" % entry
                                if FileAccess.file_exists(plugin_cfg_path):
                                        var cfg := ConfigFile.new()
                                        var err := cfg.load(plugin_cfg_path)
                                        if err == OK:
                                                var plugin_entry := _build_plugin_entry(plugin_cfg_path, cfg, enabled_array.has(plugin_cfg_path))
                                                entries.append(plugin_entry)
                                                lookup[plugin_cfg_path] = plugin_entry
                                                name_lookup[plugin_entry.get("name", plugin_cfg_path)] = plugin_entry
                        entry = addons_dir.get_next()
                addons_dir.list_dir_end()

        return {
                "plugins": entries,
                "enabled_array": enabled_array,
                "lookup": lookup,
                "name_lookup": name_lookup,
        }


func _build_plugin_entry(plugin_cfg_path: String, cfg: ConfigFile, is_enabled: bool) -> Dictionary:
        var entry := {
                "path": plugin_cfg_path,
                "name": cfg.get_value("plugin", "name", plugin_cfg_path.get_base_dir().get_file()),
                "description": cfg.get_value("plugin", "description", ""),
                "author": cfg.get_value("plugin", "author", ""),
                "version": cfg.get_value("plugin", "version", ""),
                "script": cfg.get_value("plugin", "script", ""),
                "is_enabled": is_enabled,
        }

        if cfg.has_section_key("plugin", "min_editor_version"):
                entry["min_editor_version"] = cfg.get_value("plugin", "min_editor_version")
        if cfg.has_section_key("plugin", "max_editor_version"):
                entry["max_editor_version"] = cfg.get_value("plugin", "max_editor_version")

        var install_files = cfg.get_value("plugin", "install_files", [])
        if install_files is Array:
                entry["install_files"] = install_files
        elif install_files is PackedStringArray:
                entry["install_files"] = Array(install_files)

        return entry


func _build_scene_snapshot(root: Node, options: Dictionary) -> Dictionary:
        var include_internal: bool = options.get("include_internal", false)
        var include_resources: bool = options.get("include_resources", true)
        var max_properties: int = options.get("max_properties", SNAPSHOT_PROPERTY_LIMIT_DEFAULT)
        var node_limit: int = options.get("node_limit", 0)
        var max_depth: int = options.get("max_depth", 3)

        var nodes: Array = []
        var queue: Array = [{"node": root, "depth": 0}]
        var processed := 0

        while not queue.is_empty():
                var current := queue.pop_front()
                var node: Node = current["node"]
                var depth: int = current["depth"]

                var node_entry := {
                        "path": str(node.get_path()),
                        "name": node.name,
                        "type": node.get_class(),
                        "child_count": node.get_child_count(),
                        "depth": depth,
                }

                if node.owner != null:
                        node_entry["owner_path"] = str(node.owner.get_path())
                if node.scene_file_path != "":
                        node_entry["scene_file_path"] = node.scene_file_path

                var groups := node.get_groups()
                if groups.size() > 0:
                        node_entry["groups"] = groups

                var script := node.get_script()
                if script and include_resources:
                        node_entry["script"] = _serialize_resource(script)

                var properties := {}
                var captured := 0
                for property in node.get_property_list():
                        var property_name := String(property.get("name", ""))
                        if property_name.is_empty():
                                continue
                        if not include_internal and property_name.begins_with("_"):
                                continue
                        var usage := int(property.get("usage", 0))
                        if usage & SNAPSHOT_USAGE_MASK == 0:
                                continue
                        if max_properties > 0 and captured >= max_properties:
                                break

                        var property_value = node.get(property_name)
                        properties[property_name] = _serialize_snapshot_value(property_value, include_resources, 0, max_depth)
                        captured += 1

                if not properties.is_empty():
                        node_entry["properties"] = properties

                nodes.append(node_entry)
                processed += 1

                if node_limit > 0 and processed >= node_limit:
                        break

                if depth + 1 <= max_depth:
                        for child_index in range(node.get_child_count()):
                                var child = node.get_child(child_index)
                                if child is Node:
                                        queue.append({"node": child, "depth": depth + 1})

        return {
                "scene_path": root.scene_file_path,
                "captured_at": Time.get_datetime_string_from_system(true, true),
                "node_count": nodes.size(),
                "nodes": nodes,
        }


func _serialize_snapshot_value(value, include_resources: bool, depth: int, max_depth: int):
        if depth > max_depth:
                return null

        match typeof(value):
                TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
                        return value
                TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4, TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I,
                TYPE_COLOR, TYPE_QUATERNION, TYPE_RECT2, TYPE_RECT2I:
                        return value
                TYPE_NODE_PATH:
                        return String(value)
                TYPE_ARRAY:
                        var array_result: Array = []
                        for item in value:
                                array_result.append(_serialize_snapshot_value(item, include_resources, depth + 1, max_depth))
                        return array_result
                TYPE_PACKED_STRING_ARRAY:
                        return Array(value)
                TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY,
                TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY,
                TYPE_PACKED_COLOR_ARRAY:
                        return value
                TYPE_DICTIONARY:
                        var dict_result := {}
                        for key in value.keys():
                                dict_result[String(key)] = _serialize_snapshot_value(value[key], include_resources, depth + 1, max_depth)
                        return dict_result
                TYPE_OBJECT:
                        if include_resources and value is Resource:
                                return _serialize_resource(value)
                        if value is NodePath:
                                return String(value)
                        return value.get_class()
        return String(value)

func _serialize_color(color: Color) -> Dictionary:
        return {
                "r": color.r,
                "g": color.g,
                "b": color.b,
		"a": color.a,
	}

func _serialize_resource(resource) -> Dictionary:
	if resource == null:
		return {}
	if resource is Resource:
		return {
			"class": resource.get_class(),
			"resource_path": resource.resource_path,
			"resource_name": resource.resource_name,
		}
	return {
		"class": typeof(resource),
		"description": String(resource),
	}

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPEditorCommands",
		"function": function_name,
		"system_section": extra.get("system_section", DEFAULT_SYSTEM_SECTION),
		"line_num": extra.get("line_num", 0),
		"error": is_error ? message : "",
		"db_phase": extra.get("db_phase", "none"),
		"method": extra.get("method", "NONE"),
		"message": message,
	}

	for key in extra.keys():
		if not payload.has(key):
			payload[key] = extra[key]

	print(JSON.stringify(payload))
	print("[Continuous skepticism (Sherlock Protocol)] %s" % message)
