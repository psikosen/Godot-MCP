@tool
class_name MCPEditorCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/editor_commands.gd"
const DEFAULT_SYSTEM_SECTION := "editor_commands"


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
