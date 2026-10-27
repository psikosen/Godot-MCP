@tool
class_name MCPWorkflowCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Everyday editor workflows: class reference, project search, small script edits, signal
## connections, autoloads, game settings, UI layout, scene inheritance and branching, scene
## pictures and export preparation.

var SceneTransactionManager = preload("res://addons/godot_mcp/utils/scene_transaction_manager.gd")

const LIST_LIMIT := 200
const SEARCH_EXTENSIONS := [".gd", ".tscn", ".tres", ".gdshader", ".cfg", ".godot", ".json", ".md", ".txt", ".csv"]
const LAYOUT_PRESETS := {
	"top_left": Control.PRESET_TOP_LEFT, "top_right": Control.PRESET_TOP_RIGHT,
	"bottom_left": Control.PRESET_BOTTOM_LEFT, "bottom_right": Control.PRESET_BOTTOM_RIGHT,
	"center_left": Control.PRESET_CENTER_LEFT, "center_top": Control.PRESET_CENTER_TOP,
	"center_right": Control.PRESET_CENTER_RIGHT, "center_bottom": Control.PRESET_CENTER_BOTTOM,
	"center": Control.PRESET_CENTER, "left_wide": Control.PRESET_LEFT_WIDE, "top_wide": Control.PRESET_TOP_WIDE,
	"right_wide": Control.PRESET_RIGHT_WIDE, "bottom_wide": Control.PRESET_BOTTOM_WIDE,
	"vcenter_wide": Control.PRESET_VCENTER_WIDE, "hcenter_wide": Control.PRESET_HCENTER_WIDE,
	"full_rect": Control.PRESET_FULL_RECT,
}
const SIZE_FLAGS := {"fill": Control.SIZE_FILL, "expand_fill": Control.SIZE_EXPAND_FILL,
	"shrink_center": Control.SIZE_SHRINK_CENTER, "shrink_end": Control.SIZE_SHRINK_END, "shrink_begin": Control.SIZE_SHRINK_BEGIN}
const LAYOUT_PROPERTIES := ["anchor_left", "anchor_top", "anchor_right", "anchor_bottom", "offset_left", "offset_top",
	"offset_right", "offset_bottom", "grow_horizontal", "grow_vertical", "size_flags_horizontal", "size_flags_vertical",
	"custom_minimum_size"]
# Project settings configure_game_settings may change: name -> [setting path, type, or the accepted
# words (an Array is stored as the word, a Dictionary maps the word to the stored number)].
const GAME_SETTINGS := {
	"game_name": ["application/config/name", TYPE_STRING],
	"main_scene": ["application/run/main_scene", TYPE_STRING],
	"icon": ["application/config/icon", TYPE_STRING],
	"window_width": ["display/window/size/viewport_width", TYPE_INT],
	"window_height": ["display/window/size/viewport_height", TYPE_INT],
	"stretch_mode": ["display/window/stretch/mode", ["disabled", "canvas_items", "viewport"]],
	"stretch_aspect": ["display/window/stretch/aspect", ["ignore", "keep", "keep_width", "keep_height", "expand"]],
	"clear_color": ["rendering/environment/defaults/default_clear_color", TYPE_COLOR],
	"texture_filter": ["rendering/textures/canvas_textures/default_texture_filter", {"nearest": 0, "linear": 1}],
	"gravity_2d": ["physics/2d/default_gravity", TYPE_FLOAT],
	"gravity_3d": ["physics/3d/default_gravity", TYPE_FLOAT],
	"physics_engine_3d": ["physics/3d/physics_engine", {"default": "DEFAULT", "jolt": "Jolt Physics", "godot": "GodotPhysics3D"}],
	"physics_ticks_per_second": ["physics/common/physics_ticks_per_second", TYPE_INT],
	"max_physics_steps_per_frame": ["physics/common/max_physics_steps_per_frame", TYPE_INT],
	"physics_interpolation": ["physics/common/physics_interpolation", TYPE_BOOL],
	"renderer": ["rendering/renderer/rendering_method", ["forward_plus", "mobile", "gl_compatibility"]],
	"vsync": ["display/window/vsync/vsync_mode", {"disabled": 0, "enabled": 1, "adaptive": 2, "mailbox": 3}],
	"hdr_output": ["display/window/hdr/request_hdr_output", TYPE_BOOL],
}
const LAYER_KINDS := ["2d_physics", "3d_physics", "2d_render", "3d_render", "2d_navigation", "3d_navigation", "avoidance"]
const EXPORT_PLATFORMS := {"macos": "macOS", "windows": "Windows Desktop", "linux": "Linux", "web": "Web"}
const EXPORT_EXTENSIONS := {"macOS": ".zip", "Windows Desktop": ".exe", "Linux": ".x86_64", "Web": ".html"}


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"describe_class":
			_describe_class(client_id, params, command_id)
		"search_project":
			_search_project(client_id, params, command_id)
		"replace_in_script":
			_replace_in_script(client_id, params, command_id)
		"list_signal_connections":
			_list_signal_connections(client_id, params, command_id)
		"disconnect_signal":
			_disconnect_signal(client_id, params, command_id)
		"manage_autoloads":
			_manage_autoloads(client_id, params, command_id)
		"configure_game_settings":
			_configure_game_settings(client_id, params, command_id)
		"set_control_layout":
			_set_control_layout(client_id, params, command_id)
		"create_inherited_scene":
			_create_inherited_scene(client_id, params, command_id)
		"save_branch_as_scene":
			_save_branch_as_scene(client_id, params, command_id)
		"capture_scene_image":
			_capture_scene_image(client_id, params, command_id)
		"prepare_export":
			_prepare_export(client_id, params, command_id)
		"get_runtime_paths":
			_get_runtime_paths(client_id, params, command_id)
		"get_script_outline":
			_get_script_outline(client_id, params, command_id)
		"configure_particles_2d":
			_configure_particles_2d(client_id, params, command_id)
		"manage_translations":
			_manage_translations(client_id, params, command_id)
		"select_in_editor":
			_select_in_editor(client_id, params, command_id)
		_:
			return false
	return true


# --- describe_class -------------------------------------------------------------------------

func _describe_class(client_id: int, params: Dictionary, command_id: String) -> void:
	var name := str(params.get("class_name", "")).strip_edges()
	var filter := str(params.get("filter", "")).to_lower()
	var inherited: bool = params.get("inherited", false)
	var sections: Array = params.get("sections", ["properties", "methods", "signals"])
	var out := {"class": name}
	if ClassDB.class_exists(name):
		var chain: Array = []
		var parent := ClassDB.get_parent_class(name)
		while not parent.is_empty():
			chain.append(parent)
			parent = ClassDB.get_parent_class(parent)
		out["inherits"] = chain
		if "properties" in sections:
			out["properties"] = _class_properties(ClassDB.class_get_property_list(name, not inherited), filter, name)
		if "methods" in sections:
			out["methods"] = _method_lines(ClassDB.class_get_method_list(name, not inherited), filter)
		if "signals" in sections:
			out["signals"] = _method_lines(ClassDB.class_get_signal_list(name, not inherited), filter)
		if "constants" in sections:
			var lines: Array = []
			for enum_name in ClassDB.class_get_enum_list(name, not inherited):
				var values: Array = []
				for constant in ClassDB.class_get_enum_constants(name, enum_name, true):
					values.append("%s=%d" % [constant, ClassDB.class_get_integer_constant(name, constant)])
				var line := "%s: %s" % [enum_name, ", ".join(PackedStringArray(values))]
				if filter.is_empty() or line.to_lower().contains(filter):
					lines.append(line)
			out["constants"] = lines
		return _send_success(client_id, out, command_id)

	# A class_name script in this project.
	for entry in ProjectSettings.get_global_class_list():
		if str(entry["class"]) == name:
			var script: Script = load(entry["path"])
			out["inherits"] = [str(entry["base"])]
			out["script"] = entry["path"]
			if "properties" in sections:
				out["properties"] = _class_properties(script.get_script_property_list(), filter, "")
			if "methods" in sections:
				out["methods"] = _method_lines(script.get_script_method_list(), filter)
			if "signals" in sections:
				out["signals"] = _method_lines(script.get_script_signal_list(), filter)
			return _send_success(client_id, out, command_id)

	var similar: Array = []
	for known in ClassDB.get_class_list():
		if str(known).to_lower().contains(name.to_lower()) and similar.size() < 10:
			similar.append(known)
	_send_error(client_id, "Unknown class: %s%s" % [name, (". Did you mean: " + ", ".join(PackedStringArray(similar))) if not similar.is_empty() else ""], command_id)


func _class_properties(list: Array, filter: String, owner_class: String) -> Array:
	var lines: Array = []
	var skip := PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP | PROPERTY_USAGE_INTERNAL
	for info in list:
		var name := str(info["name"])
		if info.get("usage", 0) & skip or name.begins_with("_") or name.ends_with(".gd"):
			continue
		if not filter.is_empty() and not name.to_lower().contains(filter):
			continue
		var line := "%s: %s" % [name, _type_label(info)]
		if not owner_class.is_empty():
			var default_value = ClassDB.class_get_property_default_value(owner_class, name)
			if default_value != null:
				line += " = %s" % var_to_str(default_value)
		if info.get("hint", 0) in [PROPERTY_HINT_ENUM, PROPERTY_HINT_RANGE] and not str(info.get("hint_string", "")).is_empty():
			line += " (%s)" % str(info["hint_string"]).left(120)
		lines.append(line)
		if lines.size() >= LIST_LIMIT:
			break
	return lines


func _method_lines(list: Array, filter: String) -> Array:
	var lines: Array = []
	for info in list:
		var name := str(info["name"])
		if not filter.is_empty() and not name.to_lower().contains(filter):
			continue
		var args: Array = []
		for arg in info.get("args", []):
			args.append("%s: %s" % [arg["name"], _type_label(arg)])
		var line := "%s(%s)" % [name, ", ".join(PackedStringArray(args))]
		if info.has("return") and int(info["return"].get("type", TYPE_NIL)) != TYPE_NIL:
			line += " -> " + _type_label(info["return"])
		if int(info.get("flags", 0)) & METHOD_FLAG_VIRTUAL:
			line += " [virtual]"
		lines.append(line)
		if lines.size() >= LIST_LIMIT:
			break
	return lines


func _type_label(info: Dictionary) -> String:
	var type: int = int(info.get("type", TYPE_NIL))
	var hinted_class := str(info.get("class_name", ""))
	if not hinted_class.is_empty() and type in [TYPE_OBJECT, TYPE_INT]:
		return hinted_class
	if type == TYPE_NIL:
		return "Variant"
	return type_string(type)


# --- search_project -------------------------------------------------------------------------

func _search_project(client_id: int, params: Dictionary, command_id: String) -> void:
	var query := str(params.get("query", ""))
	if query.is_empty():
		return _send_error(client_id, "query cannot be empty", command_id)
	var case_sensitive: bool = params.get("case_sensitive", false)
	var include_addons: bool = params.get("include_addons", false)
	var max_results: int = clampi(int(params.get("max_results", 100)), 1, 1000)
	var extensions: Array = params.get("extensions", SEARCH_EXTENSIONS)
	var regex: RegEx = null
	if params.get("regex", false):
		regex = RegEx.new()
		if regex.compile(("(?i)" if not case_sensitive else "") + query) != OK:
			return _send_error(client_id, "Invalid regular expression: %s" % query, command_id)
	var needle := query if case_sensitive else query.to_lower()

	var files: Array = []
	_scan_directory(DirAccess.open("res://"), "", extensions, files)
	var matches: Array = []
	var searched := 0
	for path in files:
		if not include_addons and str(path).begins_with("res://addons/"):
			continue
		searched += 1
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for i in range(lines.size()):
			var line: String = lines[i]
			var hit: bool = regex.search(line) != null if regex else (line if case_sensitive else line.to_lower()).contains(needle)
			if hit:
				matches.append("%s:%d: %s" % [path, i + 1, line.strip_edges().left(200)])
				if matches.size() >= max_results:
					return _send_success(client_id, {"matches": matches, "truncated": true, "files_searched": searched}, command_id)
	_send_success(client_id, {"matches": matches, "truncated": false, "files_searched": searched}, command_id)


# --- replace_in_script ----------------------------------------------------------------------

# Swaps one exact piece of text in a script, so a small fix costs a few lines instead of the
# whole file that edit_script needs.
func _replace_in_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var requested := str(params.get("script_path", ""))
	# Same names as replace_in_project: find (exact text here) and replace.
	var old_text := str(params.get("find", ""))
	var new_text := str(params.get("replace", ""))
	var replace_all: bool = params.get("replace_all", false)
	if not (requested.ends_with(".gd") or requested.ends_with(".gdshader")):
		return _send_error(client_id, "replace_in_script only edits .gd and .gdshader files: %s" % requested, command_id)
	var path := _contained_res_path(requested)
	if path.is_empty():
		return _send_error(client_id, "Script path must stay inside the project (res://): %s" % requested, command_id)
	if _is_protected_path(path):
		return _send_error(client_id, "%s belongs to the Godot MCP addon and cannot be changed by tools" % path, command_id)
	if not FileAccess.file_exists(path):
		return _send_error(client_id, "Script file not found: %s" % path, command_id)
	if old_text.is_empty():
		return _send_error(client_id, "find cannot be empty", command_id)
	var content := FileAccess.get_file_as_string(path)
	var count := content.count(old_text)
	if count == 0:
		return _send_error(client_id, "find text was not found in %s (check tabs vs spaces and line breaks)" % path, command_id)
	if count > 1 and not replace_all:
		return _send_error(client_id, "find text appears %d times in %s; include more surrounding lines or set replace_all" % [count, path], command_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _send_error(client_id, "Failed to open %s for writing" % path, command_id)
	file.store_string(content.replace(old_text, new_text))
	file = null
	var compile_error := _gdscript_compile_error(path) if path.ends_with(".gd") else ""
	if not compile_error.is_empty():
		return _send_error(client_id, "Replaced %d occurrence(s) in %s but the script does not compile: %s" % [count, path, compile_error], command_id)
	_send_success(client_id, {"script_path": path, "replacements": count}, command_id)


# --- signal connections ---------------------------------------------------------------------

func _list_signal_connections(client_id: int, params: Dictionary, command_id: String) -> void:
	if str(params.get("node_path", "")).is_empty():
		return _list_scene_connections(client_id, command_id)
	var node_path := str(params.get("node_path", ""))
	var node := _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	var outgoing: Array = []
	# Signals the node's own class and script add; the ~20 every Node/CanvasItem has are left out.
	var signal_names: Array = ClassDB.class_get_signal_list(node.get_class(), true).map(func(info): return str(info["name"]))
	if node.get_script():
		signal_names = node.get_script().get_script_signal_list().map(func(info): return str(info["name"])) + signal_names
	for info in node.get_signal_list():
		for connection in node.get_signal_connection_list(info["name"]):
			var target = connection["callable"].get_object()
			if _in_edited_scene(target):
				outgoing.append(_connection_line("%s ->" % info["name"], target, connection))
	var incoming: Array = []
	for connection in node.get_incoming_connections():
		var source = connection["signal"].get_object()
		if _in_edited_scene(source):
			incoming.append("%s.%s -> %s%s" % [_to_mcp_path(source), connection["signal"].get_name(),
				connection["callable"].get_method(), _connection_flags(connection)])
	_send_success(client_id, {"node_path": _to_mcp_path(node), "outgoing": outgoing, "incoming": incoming, "signals": signal_names}, command_id)


# Every connection between nodes of the open scene, one line each ("/root/Button.pressed -> /root/Game._on_start").
func _list_scene_connections(client_id: int, command_id: String) -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		return _send_error(client_id, "No scene is open", command_id)
	var lines: Array = []
	var stack: Array = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for info in node.get_signal_list():
			for connection in node.get_signal_connection_list(info["name"]):
				var target = connection["callable"].get_object()
				# Only connections saved in the scene; the engine makes its own at runtime (Control::_size_changed).
				if _in_edited_scene(target) and connection["flags"] & Object.CONNECT_PERSIST:
					lines.append(_connection_line("%s.%s ->" % [_to_mcp_path(node), info["name"]], target, connection))
		for child in node.get_children():
			if child.owner == root or child == root:
				stack.append(child)
	lines.sort()
	_send_success(client_id, {"connections": lines}, command_id)


func _connection_line(prefix: String, target: Object, connection: Dictionary) -> String:
	return "%s %s.%s%s" % [prefix, _to_mcp_path(target), connection["callable"].get_method(), _connection_flags(connection)]


func _connection_flags(connection: Dictionary) -> String:
	var notes: Array = []
	var binds: Array = connection["callable"].get_bound_arguments()
	if not binds.is_empty():
		notes.append("binds %s" % JSON.stringify(binds))
	if int(connection.get("flags", 0)) & CONNECT_DEFERRED:
		notes.append("deferred")
	if int(connection.get("flags", 0)) & CONNECT_ONE_SHOT:
		notes.append("one_shot")
	if not (int(connection.get("flags", 0)) & CONNECT_PERSIST):
		notes.append("not saved")
	return " (%s)" % ", ".join(PackedStringArray(notes)) if not notes.is_empty() else ""


func _in_edited_scene(object) -> bool:
	var root := EditorInterface.get_edited_scene_root()
	return object is Node and root != null and (object == root or root.is_ancestor_of(object)) and not _is_editor_internal_node(object)


func _disconnect_signal(client_id: int, params: Dictionary, command_id: String) -> void:
	var source := _get_editor_node(str(params.get("source_path", "")))
	var target := _get_editor_node(str(params.get("target_path", "")))
	var signal_name := str(params.get("signal_name", ""))
	var method_name := str(params.get("method_name", ""))
	var transaction_id := str(params.get("transaction_id", ""))
	if not source or not target:
		return _send_error(client_id, "Source or target node not found", command_id)
	if not source.has_signal(signal_name):
		return _send_error(client_id, "%s has no signal %s" % [_to_mcp_path(source), signal_name], command_id)
	var found: Dictionary = {}
	for connection in source.get_signal_connection_list(signal_name):
		if connection["callable"].get_object() == target and str(connection["callable"].get_method()) == method_name:
			found = connection
			break
	if found.is_empty():
		return _send_error(client_id, "No connection %s.%s -> %s.%s" % [_to_mcp_path(source), signal_name, _to_mcp_path(target), method_name], command_id)
	var transaction = _transaction("Disconnect Signal", transaction_id, {"command": "disconnect_signal"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_method(source, "disconnect", [signal_name, found["callable"]])
	transaction.add_undo_method(source, "connect", [signal_name, found["callable"], int(found.get("flags", 0))])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"source_path": _to_mcp_path(source), "signal_name": signal_name,
		"target_path": _to_mcp_path(target), "method_name": method_name})


# --- autoloads ------------------------------------------------------------------------------

func _manage_autoloads(client_id: int, params: Dictionary, command_id: String) -> void:
	var action := str(params.get("action", "list"))
	var name := str(params.get("name", "")).strip_edges()
	var plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
	if action == "add":
		var requested := str(params.get("path", ""))
		var path := _contained_res_path(requested)
		if not name.is_valid_identifier():
			return _send_error(client_id, "Autoload name must be a valid identifier: %s" % name, command_id)
		if ClassDB.class_exists(name) or Engine.has_singleton(name):
			return _send_error(client_id, "%s is already a Godot class or singleton name" % name, command_id)
		if path.is_empty() or not (path.ends_with(".gd") or path.ends_with(".tscn") or path.ends_with(".scn")) or not FileAccess.file_exists(path):
			return _send_error(client_id, "path must be an existing .gd or .tscn file in the project: %s" % requested, command_id)
		if ProjectSettings.has_setting("autoload/" + name) and not params.get("overwrite", false):
			return _send_error(client_id, "Autoload %s already exists (pass overwrite=true to replace it)" % name, command_id)
		if not plugin:
			return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
		plugin.add_autoload_singleton(name, path)
		ProjectSettings.save()
	elif action == "remove":
		if name == "MCPAutoload":
			return _send_error(client_id, "MCPAutoload belongs to the MCP addon and cannot be removed", command_id)
		if not ProjectSettings.has_setting("autoload/" + name):
			return _send_error(client_id, "No autoload named %s" % name, command_id)
		if not plugin:
			return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
		plugin.remove_autoload_singleton(name)
		ProjectSettings.save()
	elif action != "list":
		return _send_error(client_id, "action must be list, add or remove", command_id)
	var autoloads: Array = []
	for info in ProjectSettings.get_property_list():
		var setting := str(info["name"])
		if setting.begins_with("autoload/"):
			var value := str(ProjectSettings.get_setting(setting))
			var target := value.trim_prefix("*")
			if target.begins_with("uid://") and ResourceUID.has_id(ResourceUID.text_to_id(target)):
				target = ResourceUID.get_id_path(ResourceUID.text_to_id(target))
			autoloads.append({"name": setting.trim_prefix("autoload/"), "path": target, "global": value.begins_with("*")})
	_send_success(client_id, {"action": action, "autoloads": autoloads}, command_id)


# --- game settings --------------------------------------------------------------------------

func _configure_game_settings(client_id: int, params: Dictionary, command_id: String) -> void:
	var staged := {}
	for key in params.keys():
		if key == "layer_names":
			continue
		if not GAME_SETTINGS.has(key):
			return _send_error(client_id, "Unknown setting %s; known: %s, layer_names" % [key, ", ".join(PackedStringArray(GAME_SETTINGS.keys()))], command_id)
		var spec: Array = GAME_SETTINGS[key]
		var value = params[key]
		if not ProjectSettings.has_setting(spec[0]):
			return _send_error(client_id, "%s (%s) is not in this Godot (%s); it needs a newer version" % [key, spec[0], _godot_version()], command_id)
		if spec[1] is Array or spec[1] is Dictionary:
			var words: Array = spec[1] if spec[1] is Array else (spec[1] as Dictionary).keys()
			if not str(value) in words:
				return _send_error(client_id, "%s must be one of: %s" % [key, ", ".join(PackedStringArray(words))], command_id)
			value = str(value) if spec[1] is Array else spec[1][str(value)]
		elif spec[1] == TYPE_COLOR:
			value = _coerce_value_to_type(value, TYPE_COLOR)
			if not value is Color:
				return _send_error(client_id, "%s must be a color (\"#87ceeb\" or {r,g,b})" % key, command_id)
		elif spec[1] == TYPE_INT:
			if not (typeof(value) in [TYPE_INT, TYPE_FLOAT]) or int(value) < 1 or int(value) > 16384:
				return _send_error(client_id, "%s must be a whole number from 1 to 16384" % key, command_id)
			value = int(value)
		elif spec[1] == TYPE_BOOL:
			if typeof(value) != TYPE_BOOL:
				return _send_error(client_id, "%s must be true or false" % key, command_id)
		elif spec[1] == TYPE_FLOAT:
			if not (typeof(value) in [TYPE_INT, TYPE_FLOAT]):
				return _send_error(client_id, "%s must be a number" % key, command_id)
			value = float(value)
		elif key == "icon":
			var icon := _contained_res_path(str(value))
			if icon.is_empty() or not icon.get_extension().to_lower() in ["png", "svg", "webp", "jpg", "jpeg"] or not FileAccess.file_exists(icon):
				return _send_error(client_id, "icon must be an existing .png/.svg/.webp/.jpg in the project: %s" % value, command_id)
			value = icon
		elif key == "main_scene":
			var scene := _contained_res_path(str(value))
			if scene.is_empty() or not (scene.ends_with(".tscn") or scene.ends_with(".scn")) or not FileAccess.file_exists(scene):
				return _send_error(client_id, "main_scene must be an existing scene in the project: %s" % value, command_id)
			value = scene
		else:
			value = str(value)
		staged[spec[0]] = value
	var layer_names = params.get("layer_names", {})
	if typeof(layer_names) != TYPE_DICTIONARY:
		return _send_error(client_id, "layer_names must be {\"2d_physics\": {\"1\": \"world\"}, ...}", command_id)
	for kind in layer_names:
		if not str(kind) in LAYER_KINDS or typeof(layer_names[kind]) != TYPE_DICTIONARY:
			return _send_error(client_id, "layer_names keys must be one of: %s, each mapping layer numbers to names" % ", ".join(PackedStringArray(LAYER_KINDS)), command_id)
		for layer in layer_names[kind]:
			var number := int(str(layer)) if str(layer).is_valid_int() else 0
			if number < 1 or number > 32:
				return _send_error(client_id, "Layer numbers run from 1 to 32 (got %s)" % layer, command_id)
			staged["layer_names/%s/layer_%d" % [kind, number]] = str(layer_names[kind][layer])

	var changes: Array = []
	for setting in staged:
		var previous = ProjectSettings.get_setting(setting) if ProjectSettings.has_setting(setting) else null
		if previous != staged[setting]:
			ProjectSettings.set_setting(setting, staged[setting])
			changes.append({"setting": setting, "previous": var_to_str(previous), "value": var_to_str(staged[setting])})
	if not changes.is_empty():
		ProjectSettings.save()
	var current := {}
	for key in GAME_SETTINGS:
		current[key] = ProjectSettings.get_setting(GAME_SETTINGS[key][0], null)
		if GAME_SETTINGS[key][1] is Dictionary and current[key] != null:
			var words: Dictionary = GAME_SETTINGS[key][1]
			var word = words.find_key(current[key])
			if word == null and typeof(current[key]) in [TYPE_INT, TYPE_FLOAT]:
				word = words.find_key(int(current[key]))
			current[key] = word if word != null else current[key]
	_send_success(client_id, {"changes": changes, "current": current}, command_id)


# --- UI layout ------------------------------------------------------------------------------

func _set_control_layout(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := str(params.get("node_path", ""))
	var transaction_id := str(params.get("transaction_id", ""))
	var control := _get_editor_node(node_path) as Control
	if not control:
		return _send_error(client_id, "Control node not found: %s" % node_path, command_id)
	var preset_name := str(params.get("preset", ""))
	if not preset_name.is_empty() and not LAYOUT_PRESETS.has(preset_name):
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PackedStringArray(LAYOUT_PRESETS.keys())), command_id)
	for flag_key in ["size_flags_horizontal", "size_flags_vertical"]:
		if params.has(flag_key) and not SIZE_FLAGS.has(str(params[flag_key])):
			return _send_error(client_id, "%s must be one of: %s" % [flag_key, ", ".join(PackedStringArray(SIZE_FLAGS.keys()))], command_id)

	var before := {}
	for property in LAYOUT_PROPERTIES:
		before[property] = control.get(property)
	if params.has("min_size"):
		control.custom_minimum_size = _coerce_to_vector2(params["min_size"])
	for flag_key in ["size_flags_horizontal", "size_flags_vertical"]:
		if params.has(flag_key):
			control.set(flag_key, SIZE_FLAGS[str(params[flag_key])])
	if params.has("size"):
		control.size = _coerce_to_vector2(params["size"])
	if not preset_name.is_empty():
		var keep := Control.PRESET_MODE_KEEP_SIZE if params.has("size") else Control.PRESET_MODE_MINSIZE
		control.set_anchors_and_offsets_preset(LAYOUT_PRESETS[preset_name], keep, int(params.get("margin", 0)))
	if params.has("position"):
		control.position = _coerce_to_vector2(params["position"])
	var after := {}
	for property in LAYOUT_PROPERTIES:
		after[property] = control.get(property)
		control.set(property, before[property])  # the transaction applies the new layout, so undo restores it

	var transaction = _transaction("Set Control Layout", transaction_id, {"command": "set_control_layout", "node_path": node_path})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var changed: Array = []
	for property in LAYOUT_PROPERTIES:
		if after[property] != before[property]:
			transaction.add_do_property(control, property, after[property])
			transaction.add_undo_property(control, property, before[property])
			changed.append("%s: %s" % [property, var_to_str(after[property])])
	if changed.is_empty():
		return _send_success(client_id, {"node_path": node_path, "changes": [], "status": "no_change"}, command_id)
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {"node_path": _to_mcp_path(control), "changes": changed})


# --- scene files ----------------------------------------------------------------------------

func _create_inherited_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var base_path := _contained_res_path(str(params.get("base_scene", "")))
	var path := _contained_res_path(str(params.get("path", "")))
	if base_path.is_empty() or not FileAccess.file_exists(base_path):
		return _send_error(client_id, "base_scene must be an existing scene in the project", command_id)
	if path.is_empty() or not path.ends_with(".tscn"):
		return _send_error(client_id, "path must be a .tscn file inside the project", command_id)
	if FileAccess.file_exists(path) and not params.get("overwrite", false):
		return _send_error(client_id, "%s already exists (pass overwrite=true to replace it)" % path, command_id)
	var base := ResourceLoader.load(base_path, "PackedScene") as PackedScene
	if base == null:
		return _send_error(client_id, "Failed to load %s as a scene" % base_path, command_id)
	# PackedScene.pack() cannot mark a root as inherited from scripts (it saved a full copy), so
	# write the same text Godot writes for an inherited scene: one instanced root, no overrides.
	var uid: int = ResourceLoader.get_resource_uid(base_path)
	var uid_attribute := ' uid="%s"' % ResourceUID.id_to_text(uid) if uid != ResourceUID.INVALID_ID else ""
	var text := '[gd_scene format=3]\n\n[ext_resource type="PackedScene"%s path="%s" id="1_base"]\n\n[node name="%s" instance=ExtResource("1_base")]\n' % [
		uid_attribute, base_path, base.get_state().get_node_name(0)]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _send_error(client_id, "Failed to write %s" % path, command_id)
	file.store_string(text)
	file = null
	EditorInterface.get_resource_filesystem().update_file(path)
	if params.get("open", true):
		EditorInterface.open_scene_from_path(path)
	_send_success(client_id, {"path": path, "base_scene": base_path, "opened": params.get("open", true)}, command_id)


# Godot's "Save Branch as Scene": writes a subtree to its own scene file and, by default, puts an
# instance of that file where the subtree was (one undo step).
func _save_branch_as_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := str(params.get("node_path", ""))
	var path := _contained_res_path(str(params.get("path", "")))
	var replace: bool = params.get("replace", true)
	var node := _get_editor_node(node_path)
	var scene_root := EditorInterface.get_edited_scene_root()
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if node == scene_root:
		return _send_error(client_id, "%s is the scene root; use save_scene with a new path instead" % node_path, command_id)
	if not node.scene_file_path.is_empty():
		return _send_error(client_id, "%s is already an instance of %s" % [node_path, node.scene_file_path], command_id)
	if path.is_empty() or not path.ends_with(".tscn"):
		return _send_error(client_id, "path must be a .tscn file inside the project", command_id)
	if FileAccess.file_exists(path) and not params.get("overwrite", false):
		return _send_error(client_id, "%s already exists (pass overwrite=true to replace it)" % path, command_id)

	var branch := node.duplicate(Node.DUPLICATE_SIGNALS | Node.DUPLICATE_GROUPS | Node.DUPLICATE_SCRIPTS | Node.DUPLICATE_USE_INSTANTIATION)
	_own_branch(branch, branch)
	var packed := PackedScene.new()
	var err := packed.pack(branch)
	branch.free()
	if err == OK:
		err = _save_resource_contained(packed, path)
	if err != OK:
		return _send_error(client_id, "Failed to save branch scene: %s" % error_string(err), command_id)
	EditorInterface.get_resource_filesystem().update_file(path)
	if not replace:
		return _send_success(client_id, {"path": path, "node_path": node_path, "replaced": false}, command_id)

	var saved := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
	var instance := saved.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var parent := node.get_parent()
	var index := node.get_index()
	instance.name = node.name
	var owners: Array = []
	_collect_owners(node, owners)
	var transaction = SceneTransactionManager.begin_inline("Save Branch as Scene", {"command": "save_branch_as_scene", "path": path})
	if not transaction:
		instance.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_method(parent, "remove_child", [node])
	transaction.add_do_method(parent, "add_child", [instance, true])
	transaction.add_do_method(parent, "move_child", [instance, index])
	transaction.add_do_method(instance, "set_owner", [scene_root])
	transaction.add_do_reference(instance)
	transaction.add_undo_method(parent, "remove_child", [instance])
	transaction.add_undo_method(parent, "add_child", [node, true])
	transaction.add_undo_method(parent, "move_child", [node, index])
	for pair in owners:
		transaction.add_undo_method(pair[0], "set_owner", [pair[1]])
	var moved := _move_external_connections(transaction, node, instance)
	transaction.register_on_commit(func(): _mark_scene_modified())
	if not transaction.commit():
		instance.free()
		return _send_error(client_id, "Failed to replace %s with the new scene" % node_path, command_id)
	_send_success(client_id, {"path": path, "node_path": _to_mcp_path(instance), "replaced": true,
		"moved_connections": moved["moved"], "dropped_connections": moved["dropped"]}, command_id)


# Like Godot's own replace: connections between the branch root and the rest of the scene move to
# the instance. Connections from deeper branch nodes to the outside cannot be kept and are listed.
func _move_external_connections(transaction, node: Node, instance: Node) -> Dictionary:
	var outside := func(other) -> bool: return other is Node and other != node and not node.is_ancestor_of(other) and _in_edited_scene(other)
	var moved: Array = []
	var dropped: Array = []
	for info in node.get_signal_list():
		for connection in node.get_signal_connection_list(info["name"]):
			var target = connection["callable"].get_object()
			if outside.call(target):
				transaction.add_do_method(instance, "connect", [info["name"], connection["callable"], int(connection["flags"])])
				moved.append(_connection_line("%s ->" % info["name"], target, connection))
	for connection in node.get_incoming_connections():
		var source = connection["signal"].get_object()
		if outside.call(source):
			var signal_name: StringName = connection["signal"].get_name()
			var old_callable: Callable = connection["callable"]
			var new_callable := Callable(instance, old_callable.get_method()).bindv(old_callable.get_bound_arguments())
			transaction.add_do_method(source, "disconnect", [signal_name, old_callable])
			transaction.add_do_method(source, "connect", [signal_name, new_callable, int(connection["flags"])])
			transaction.add_undo_method(source, "disconnect", [signal_name, new_callable])
			transaction.add_undo_method(source, "connect", [signal_name, old_callable, int(connection["flags"])])
			moved.append("%s.%s -> (instance).%s" % [_to_mcp_path(source), signal_name, old_callable.get_method()])
	for descendant in node.find_children("*", "", true, false):
		for info in descendant.get_signal_list():
			for connection in descendant.get_signal_connection_list(info["name"]):
				if outside.call(connection["callable"].get_object()):
					dropped.append("%s.%s" % [_to_mcp_path(descendant), info["name"]])
	return {"moved": moved, "dropped": dropped}


# Nodes the edited scene owned now belong to the branch root; nodes inside nested instances keep
# their own owner (duplicate() already re-pointed those).
func _own_branch(node: Node, branch_root: Node) -> void:
	for child in node.get_children():
		if child.owner == null and not _is_editor_internal_node(child):
			child.owner = branch_root
		_own_branch(child, branch_root)


func _collect_owners(node: Node, owners: Array) -> void:
	owners.append([node, node.owner])
	for child in node.get_children():
		_collect_owners(child, owners)


# --- capture_scene_image --------------------------------------------------------------------

# Renders a copy of the edited scene into an off-screen viewport. The copy's scripts do not run
# (only @tool scripts run in the editor), so this shows the scene as built, frozen.
func _capture_scene_image(client_id: int, params: Dictionary, command_id: String) -> void:
	if DisplayServer.get_name() == "headless":
		return _send_error(client_id, "capture_scene_image needs the Godot editor window; this editor runs with --headless", command_id)
	var scene_root := EditorInterface.get_edited_scene_root()
	if not scene_root:
		return _send_error(client_id, "No scene is open", command_id)
	var strip: Array = params.get("filmstrip", []) if params.get("filmstrip") is Array else []
	if strip.size() > 8:
		return _send_error(client_id, "filmstrip takes up to 8 moments", command_id)
	# A filmstrip is side by side, so its default frames are narrower.
	var default_width := 960 if strip.is_empty() else mini(960, 3840 / strip.size())
	var size := Vector2i(clampi(int(params.get("width", default_width)), 64, 2048), clampi(int(params.get("height", default_width * 9 / 16)), 64, 2048))
	if size.x * maxi(strip.size(), 1) > 8192:
		return _send_error(client_id, "The filmstrip would be %d px wide; pass a smaller width" % (size.x * strip.size()), command_id)
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	# No DUPLICATE_USE_INSTANTIATION: with it the root reloads from its saved file, so the picture
	# left out every change since the last save.
	var copy := scene_root.duplicate(0)
	# The editor draws collision shapes, rays and marker crosses that the game never shows; they
	# covered the art (a vision-cone collider painted the cone red).
	if not params.get("show_helpers", false):
		for helper in copy.find_children("*", "", true, false):
			if helper is CollisionShape2D or helper is CollisionPolygon2D or helper is CollisionShape3D \
					or helper is CollisionPolygon3D or helper is RayCast2D or helper is RayCast3D:
				helper.visible = false
			elif helper is Marker2D or helper is Marker3D:
				helper.gizmo_extents = 0.0
	viewport.add_child(copy)
	EditorInterface.get_base_control().add_child(viewport)

	var camera_path := str(params.get("camera_path", ""))
	var camera: Node = null
	if not camera_path.is_empty():
		var original := _get_editor_node(camera_path)
		if not (original is Camera2D or original is Camera3D):
			viewport.queue_free()
			return _send_error(client_id, "camera_path must point to a Camera2D or Camera3D", command_id)
		camera = copy.get_node_or_null(scene_root.get_path_to(original))
	elif copy is Node3D or copy.find_children("*", "Node3D", true, false).size() > copy.find_children("*", "Node2D", true, false).size():
		var cameras := copy.find_children("*", "Camera3D", true, false)
		if cameras.is_empty():
			viewport.queue_free()
			return _send_error(client_id, "No Camera3D in the scene; add one or pass camera_path", command_id)
		camera = cameras[0]
	else:
		var view := Camera2D.new()
		view.position = _coerce_to_vector2(params.get("center", {"x": size.x / 2.0, "y": size.y / 2.0}))
		view.zoom = Vector2.ONE * clampf(float(params.get("zoom", 1.0)), 0.05, 20.0)
		viewport.add_child(view)
		camera = view
	if camera is Camera2D or camera is Camera3D:
		camera.make_current()

	# Moments after a restart: particles in the copy start over, and shaders with a `clock` uniform
	# (pixel VFX) jump to each moment, so a one-shot shows mid-effect. Several moments come back
	# side by side, to judge motion in one picture.
	var moments: Array = strip.map(func(value): return clampf(float(value), 0.0, 10.0))
	if moments.is_empty() and params.has("particles_time"):
		moments.append(clampf(float(params["particles_time"]), 0.0, 10.0))
	moments.sort()
	var clocked: Array = []
	if not moments.is_empty():
		for item in [copy] + copy.find_children("*", "", true, false):
			if item is GPUParticles2D or item is GPUParticles3D or item is CPUParticles2D or item is CPUParticles3D:
				item.restart()
			var property := "material" if item is CanvasItem else ("material_override" if item is GeometryInstance3D else "")
			var material = item.get(property) if not property.is_empty() else null
			if material is ShaderMaterial and material.shader \
					and material.shader.get_shader_uniform_list().any(func(uniform): return uniform.name == "clock"):
				# The copy shares the scene's material; turning the copy's clock must not touch the scene.
				material = material.duplicate()
				item.set(property, material)
				clocked.append(material)
	var frames: Array = []
	var elapsed := 0.0
	# An unfocused editor draws only when something changes, so a wait with nothing moving (a shader
	# effect, no particles) never got its frame. Draw every frame until the pictures are taken.
	var low_processor := OS.low_processor_usage_mode
	OS.low_processor_usage_mode = false
	for moment in (moments if not moments.is_empty() else [0.0]):
		if moment > elapsed:
			await get_tree().create_timer(moment - elapsed).timeout
			elapsed = moment
		for material in clocked:
			material.set_shader_parameter("clock", moment)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var frame := viewport.get_texture().get_image()
		if frame == null or frame.is_empty():
			OS.low_processor_usage_mode = low_processor
			viewport.queue_free()
			return _send_error(client_id, "The renderer returned no image", command_id)
		frames.append(frame)
	OS.low_processor_usage_mode = low_processor
	viewport.queue_free()
	var image: Image = frames[0]
	if frames.size() > 1:
		image = Image.create(size.x * frames.size(), size.y, false, image.get_format())
		for i in frames.size():
			image.blit_rect(frames[i], Rect2i(Vector2i.ZERO, size), Vector2i(size.x * i, 0))
	_send_success(client_id, {"image_base64": Marshalls.raw_to_base64(image.save_png_to_buffer()),
		"width": image.get_width(), "height": image.get_height(), "moments": moments}, command_id)


# --- export ---------------------------------------------------------------------------------

# Finds or creates an export preset and returns what the server needs to run the export in a
# separate Godot process (an export inside the editor would block it).
func _prepare_export(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset_name := str(params.get("preset", ""))
	var platform_key := str(params.get("platform", "")).to_lower()
	var presets := ConfigFile.new()
	presets.load("res://export_presets.cfg")
	var section := ""
	var platform := ""
	for candidate in presets.get_sections():
		if candidate.count(".") != 1:
			continue
		var candidate_platform := str(presets.get_value(candidate, "platform", ""))
		if (not preset_name.is_empty() and str(presets.get_value(candidate, "name", "")) == preset_name) \
				or (preset_name.is_empty() and EXPORT_PLATFORMS.get(platform_key, "") == candidate_platform):
			section = candidate
			platform = candidate_platform
			break
	if section.is_empty():
		if not EXPORT_PLATFORMS.has(platform_key):
			return _send_error(client_id, "No preset %s; pass platform (one of: %s) to create one" % [preset_name, ", ".join(PackedStringArray(EXPORT_PLATFORMS.keys()))], command_id)
		platform = EXPORT_PLATFORMS[platform_key]
		var index := 0
		while presets.has_section("preset.%d" % index):
			index += 1
		section = "preset.%d" % index
		preset_name = preset_name if not preset_name.is_empty() else platform
		var game_name := str(ProjectSettings.get_setting("application/config/name", "Game"))
		# Godot reads these keys without defaults and logs an error for each one that is missing.
		for key_value in [["name", preset_name], ["platform", platform], ["runnable", true], ["dedicated_server", false],
				["custom_features", ""], ["export_filter", "all_resources"], ["include_filter", ""],
				["exclude_filter", "builds/*, server/*"], ["export_path", ""], ["encryption_include_filters", ""],
				["encryption_exclude_filters", ""], ["encrypt_pck", false], ["encrypt_directory", false], ["script_export_mode", 2]]:
			presets.set_value(section, key_value[0], key_value[1])
		if platform == "macOS":
			var bundle := game_name.to_lower().validate_filename().replace(" ", "").replace("_", "")
			presets.set_value(section + ".options", "application/bundle_identifier", "com.example." + (bundle if not bundle.is_empty() else "game"))
		var err := presets.save("res://export_presets.cfg")
		if err != OK:
			return _send_error(client_id, "Failed to write export_presets.cfg: %s" % error_string(err), command_id)
	preset_name = str(presets.get_value(section, "name"))
	var notes: Array = []
	# macOS builds are universal (arm64 + x86_64) and refuse to export without ETC2/ASTC textures.
	if platform == "macOS" and not ProjectSettings.get_setting("rendering/textures/vram_compression/import_etc2_astc", false):
		ProjectSettings.set_setting("rendering/textures/vram_compression/import_etc2_astc", true)
		ProjectSettings.save()
		notes.append("Enabled Rendering > Textures > VRAM Compression > Import ETC2 ASTC (required for macOS exports)")

	var file_name := str(ProjectSettings.get_setting("application/config/name", "game")).validate_filename().replace(" ", "_")
	var output := str(params.get("output_path", ""))
	if output.is_empty():
		output = "res://builds/%s/%s%s" % [platform.to_lower().replace(" ", "_"), file_name, EXPORT_EXTENSIONS.get(platform, "")]
	var global_output := ProjectSettings.globalize_path(output) if output.begins_with("res://") else output
	DirAccess.make_dir_recursive_absolute(global_output.get_base_dir())
	# Godot would otherwise import the exported files as project assets.
	var builds := ProjectSettings.globalize_path("res://builds")
	if global_output.begins_with(builds) and not FileAccess.file_exists(builds + "/.gdignore"):
		FileAccess.open(builds + "/.gdignore", FileAccess.WRITE)
	_send_success(client_id, {
		"preset": preset_name,
		"platform": platform,
		"executable": OS.get_executable_path(),
		"project_dir": ProjectSettings.globalize_path("res://"),
		"output_path": global_output,
		"notes": notes,
	}, command_id)


# --- runtime paths (run_game_tests, capture_game_frame) ------------------------------------

# What the server needs to start its own Godot process for this project. With tests_dir, also the
# SceneTree/MainLoop scripts in that folder (the scripts `godot --script` can run).
func _get_runtime_paths(client_id: int, params: Dictionary, command_id: String) -> void:
	var result := {
		"executable": OS.get_executable_path(),
		"project_dir": ProjectSettings.globalize_path("res://"),
		"godot_version": "%d.%d" % [Engine.get_version_info()["major"], Engine.get_version_info()["minor"]],
		"main_scene": str(ProjectSettings.get_setting("application/run/main_scene", "")),
		"window": [int(ProjectSettings.get_setting("display/window/size/viewport_width", 1152)),
			int(ProjectSettings.get_setting("display/window/size/viewport_height", 648))],
	}
	var tests_dir := str(params.get("tests_dir", ""))
	if not tests_dir.is_empty():
		var folder := _contained_res_path(tests_dir)
		if folder.is_empty() or not DirAccess.dir_exists_absolute(folder):
			return _send_error(client_id, "Test folder not found: %s" % tests_dir, command_id)
		var files: Array = []
		var relative := folder.trim_prefix("res://").trim_suffix("/")
		_scan_directory(DirAccess.open(folder), relative + "/" if not relative.is_empty() else "", [".gd"], files)
		result["tests"] = files.filter(func(path): return RegEx.create_from_string("(?m)^extends\\s+(SceneTree|MainLoop)\\b").search(FileAccess.get_file_as_string(path)) != null)
	_send_success(client_id, result, command_id)


# --- get_script_outline ---------------------------------------------------------------------

# The shape of a script with line numbers (extends, signals, exports, vars, consts, enums, funcs,
# inner classes), so an agent can read a 400-line file as 30 lines and fetch only what it needs.
func _get_script_outline(client_id: int, params: Dictionary, command_id: String) -> void:
	var requested := str(params.get("script_path", ""))
	var path := _contained_res_path(requested)
	if path.is_empty() or not path.ends_with(".gd") or not FileAccess.file_exists(path):
		return _send_error(client_id, "script_path must be an existing .gd file in the project: %s" % requested, command_id)
	var keyword := RegEx.create_from_string("^((?:@\\w+(?:\\([^)]*\\))?\\s+)*)(static\\s+)?(func|signal|var|const|enum|class_name|extends|class)\\b(.*)$")
	var lines := FileAccess.get_file_as_string(path).split("\n")
	var outline: Array = []
	var annotations := ""
	var in_class := false
	for i in range(lines.size()):
		var raw: String = lines[i]
		var leading := raw.substr(0, raw.length() - raw.lstrip(" \t").length())
		var indent := leading.count("\t") + leading.count(" ") / 4
		var text := raw.strip_edges()
		if text.is_empty() or text.begins_with("#"):
			continue
		if indent == 0:
			in_class = false
		if indent > (1 if in_class else 0):
			continue
		if text.begins_with("@") and keyword.search(text) == null:
			annotations += text + " "  # e.g. @export on its own line before the var
			continue
		var found := keyword.search(text)
		if found == null:
			annotations = ""
			continue
		var entry := (annotations + text).strip_edges()
		annotations = ""
		if found.get_string(3) == "func":
			entry = entry.substr(0, entry.rfind(":")) if entry.ends_with(":") or entry.contains("):") else entry
		elif found.get_string(3) == "class" and indent == 0:
			in_class = true
		outline.append("L%d %s%s" % [i + 1, "  " if indent > 0 else "", entry.left(160)])
	_send_success(client_id, {"script_path": path, "line_count": lines.size(), "outline": outline}, command_id)


# --- configure_particles_2d -----------------------------------------------------------------

const PARTICLE_PRESETS := {
	"dust": {"amount": 16, "lifetime": 0.6, "direction": Vector2(0, -1), "spread": 60.0, "gravity": Vector2(0, 120),
		"velocity": [20.0, 60.0], "scale": [2.0, 4.0], "color": Color(0.85, 0.78, 0.65, 0.8), "color_end": Color(0.85, 0.78, 0.65, 0.0),
		"emission_shape": "rectangle", "emission_rect_extents": Vector2(12, 2)},
	"sparkle": {"amount": 24, "lifetime": 0.8, "direction": Vector2(0, -1), "spread": 180.0, "gravity": Vector2.ZERO,
		"velocity": [10.0, 40.0], "scale": [1.5, 3.0], "color": Color(1, 1, 0.6), "color_end": Color(1, 1, 1, 0)},
	"rain": {"amount": 200, "lifetime": 1.2, "direction": Vector2(0.1, 1), "spread": 3.0, "gravity": Vector2(0, 600),
		"velocity": [400.0, 500.0], "scale": [1.0, 2.0], "color": Color(0.6, 0.75, 1, 0.7),
		"emission_shape": "rectangle", "emission_rect_extents": Vector2(640, 10)},
	"snow": {"amount": 120, "lifetime": 4.0, "direction": Vector2(0, 1), "spread": 20.0, "gravity": Vector2(0, 20),
		"velocity": [20.0, 50.0], "scale": [2.0, 4.0], "color": Color(1, 1, 1, 0.9),
		"emission_shape": "rectangle", "emission_rect_extents": Vector2(640, 10)},
	"confetti": {"amount": 60, "lifetime": 1.5, "one_shot": true, "explosiveness": 1.0, "direction": Vector2(0, -1), "spread": 70.0,
		"gravity": Vector2(0, 400), "velocity": [200.0, 350.0], "scale": [3.0, 5.0], "color": Color(1, 0.3, 0.3), "hue_variation": 1.0},
	"burst": {"amount": 20, "lifetime": 0.4, "one_shot": true, "explosiveness": 1.0, "direction": Vector2(1, 0), "spread": 180.0,
		"gravity": Vector2.ZERO, "velocity": [80.0, 160.0], "scale": [2.0, 4.0], "color": Color(1, 0.9, 0.5), "color_end": Color(1, 0.4, 0.1, 0)},
}

# Creates a CPUParticles2D (works on every renderer) or configures an existing CPUParticles2D or
# GPUParticles2D, from a preset plus overrides. One undo step.
func _configure_particles_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var transaction_id := str(params.get("transaction_id", ""))
	var preset_name := str(params.get("preset", ""))
	if not preset_name.is_empty() and not PARTICLE_PRESETS.has(preset_name):
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PackedStringArray(PARTICLE_PRESETS.keys())), command_id)
	var settings: Dictionary = (PARTICLE_PRESETS.get(preset_name, {}) as Dictionary).duplicate()
	for key in ["amount", "lifetime", "one_shot", "explosiveness", "spread", "emitting", "local_coords", "hue_variation", "emission_shape", "emission_radius"]:
		if params.has(key):
			settings[key] = params[key]
	for key in ["direction", "gravity", "emission_rect_extents"]:
		if params.has(key):
			settings[key] = _coerce_to_vector2(params[key])
	for key in ["color", "color_end"]:
		if params.has(key):
			settings[key] = _coerce_value_to_type(params[key], TYPE_COLOR)
			if not settings[key] is Color:
				return _send_error(client_id, "%s must be a color" % key, command_id)
	if params.has("velocity_min") or params.has("velocity_max"):
		settings["velocity"] = [float(params.get("velocity_min", params.get("velocity_max"))), float(params.get("velocity_max", params.get("velocity_min")))]
	if params.has("scale_min") or params.has("scale_max"):
		settings["scale"] = [float(params.get("scale_min", params.get("scale_max"))), float(params.get("scale_max", params.get("scale_min")))]
	if settings.has("emission_shape") and not str(settings["emission_shape"]) in ["point", "sphere", "rectangle"]:
		return _send_error(client_id, "emission_shape must be point, sphere or rectangle", command_id)
	var texture: Texture2D = null
	if params.has("texture"):
		texture = load(_contained_res_path(str(params["texture"]))) as Texture2D
		if texture == null:
			return _send_error(client_id, "texture must be a res:// image or texture", command_id)

	var node_path := str(params.get("node_path", ""))
	var node: Node = _get_editor_node(node_path) if not node_path.is_empty() else null
	var created := false
	if node == null:
		if not node_path.is_empty() and not params.has("parent_path"):
			return _send_error(client_id, "Node not found: %s (pass parent_path to create one)" % node_path, command_id)
		var parent := _get_editor_node(str(params.get("parent_path", "/root")))
		if not parent:
			return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
		node = CPUParticles2D.new()
		node.name = str(params.get("node_name", preset_name.capitalize().replace(" ", "") + "Particles" if not preset_name.is_empty() else "Particles"))
		created = true
	if not (node is CPUParticles2D or node is GPUParticles2D):
		return _send_error(client_id, "%s is a %s, not CPUParticles2D or GPUParticles2D" % [node_path, node.get_class()], command_id)

	# Desired values: on the node itself, and for GPUParticles2D on its ParticleProcessMaterial.
	var on_node := {}
	var on_material := {}
	for key in ["amount", "lifetime", "one_shot", "explosiveness", "emitting", "local_coords"]:
		if settings.has(key):
			on_node[key] = settings[key]
	if texture:
		on_node["texture"] = texture
	if params.has("position"):
		on_node["position"] = _coerce_to_vector2(params["position"])
	var gradient: Gradient = null
	if settings.has("color_end"):
		gradient = Gradient.new()
		gradient.set_color(0, settings.get("color", Color.WHITE))
		gradient.set_color(1, settings["color_end"])
	var shape_names := ["point", "sphere", "rectangle"]
	if node is CPUParticles2D:
		var target := on_node
		for key in ["direction", "spread", "gravity", "emission_rect_extents", "color"]:
			if settings.has(key):
				target[key] = settings[key]
		if settings.has("velocity"):
			target["initial_velocity_min"] = settings["velocity"][0]
			target["initial_velocity_max"] = settings["velocity"][1]
		if settings.has("scale"):
			target["scale_amount_min"] = settings["scale"][0]
			target["scale_amount_max"] = settings["scale"][1]
		if settings.has("hue_variation"):
			target["hue_variation_min"] = -float(settings["hue_variation"])
			target["hue_variation_max"] = float(settings["hue_variation"])
		if settings.has("emission_shape"):
			target["emission_shape"] = [CPUParticles2D.EMISSION_SHAPE_POINT, CPUParticles2D.EMISSION_SHAPE_SPHERE, CPUParticles2D.EMISSION_SHAPE_RECTANGLE][shape_names.find(str(settings["emission_shape"]))]
		if settings.has("emission_radius"):
			target["emission_sphere_radius"] = float(settings["emission_radius"])
		if gradient:
			target["color_ramp"] = gradient
	else:
		var target := on_material
		for key in ["spread", "color"]:
			if settings.has(key):
				target[key] = settings[key]
		for key in ["direction", "gravity"]:
			if settings.has(key):
				target[key] = Vector3(settings[key].x, settings[key].y, 0)
		if settings.has("emission_rect_extents"):
			target["emission_box_extents"] = Vector3(settings["emission_rect_extents"].x, settings["emission_rect_extents"].y, 0)
		if settings.has("velocity"):
			target["initial_velocity_min"] = settings["velocity"][0]
			target["initial_velocity_max"] = settings["velocity"][1]
		if settings.has("scale"):
			target["scale_min"] = settings["scale"][0]
			target["scale_max"] = settings["scale"][1]
		if settings.has("hue_variation"):
			target["hue_variation_min"] = -float(settings["hue_variation"])
			target["hue_variation_max"] = float(settings["hue_variation"])
		if settings.has("emission_shape"):
			target["emission_shape"] = [ParticleProcessMaterial.EMISSION_SHAPE_POINT, ParticleProcessMaterial.EMISSION_SHAPE_SPHERE, ParticleProcessMaterial.EMISSION_SHAPE_BOX][shape_names.find(str(settings["emission_shape"]))]
		if settings.has("emission_radius"):
			target["emission_sphere_radius"] = float(settings["emission_radius"])
		if gradient:
			var ramp := GradientTexture1D.new()
			ramp.gradient = gradient
			target["color_ramp"] = ramp

	for key in on_node:
		var error := _property_value_error(node, key, on_node[key])
		if not error.is_empty():
			if created:
				node.free()
			return _send_error(client_id, error, command_id)

	var transaction = _transaction("Configure Particles 2D", transaction_id, {"command": "configure_particles_2d"})
	if not transaction:
		if created:
			node.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var changed: Array = on_node.keys() + on_material.keys()
	if created:
		for key in on_node:
			node.set(key, on_node[key])
		var parent := _get_editor_node(str(params.get("parent_path", "/root")))
		node.name = _unique_child_name(parent, str(node.name))
		transaction.add_do_method(parent, "add_child", [node, true])
		transaction.add_do_method(node, "set_owner", [EditorInterface.get_edited_scene_root()])
		transaction.add_do_reference(node)
		transaction.add_undo_method(parent, "remove_child", [node])
	else:
		for key in on_node:
			transaction.add_do_property(node, key, on_node[key])
			transaction.add_undo_property(node, key, node.get(key))
	if node is GPUParticles2D and not on_material.is_empty():
		var current = node.process_material
		var material: ParticleProcessMaterial = current.duplicate() if current is ParticleProcessMaterial else ParticleProcessMaterial.new()
		for key in on_material:
			material.set(key, on_material[key])
		transaction.add_do_property(node, "process_material", material)
		transaction.add_undo_property(node, "process_material", current)
	transaction.register_on_commit(func(): _mark_scene_modified())
	var expected := _join_path(_to_mcp_path(_get_editor_node(str(params.get("parent_path", "/root")))), str(node.name)) if created else _to_mcp_path(node)
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": expected, "type": node.get_class(), "created": created, "preset": preset_name, "changed": changed})


# --- manage_translations --------------------------------------------------------------------

# Keeps a translation CSV (keys, then one column per locale) that Godot imports into
# .translation files, and registers those files in the project.
func _manage_translations(client_id: int, params: Dictionary, command_id: String) -> void:
	var action := str(params.get("action", "list"))
	var requested := str(params.get("csv_path", "res://translations/strings.csv"))
	var csv_path := _contained_res_path(requested)
	if csv_path.is_empty() or not csv_path.ends_with(".csv"):
		return _send_error(client_id, "csv_path must be a .csv file inside the project: %s" % requested, command_id)
	var locale_pattern := RegEx.create_from_string("^[a-z]{2,3}(_[A-Z]{2})?$")
	var table := _read_translation_csv(csv_path)
	var existed := FileAccess.file_exists(csv_path)
	if action == "set_entries":
		var entries = params.get("entries", {})
		if typeof(entries) != TYPE_DICTIONARY or (entries as Dictionary).is_empty():
			return _send_error(client_id, "entries must be {\"KEY\": {\"en\": \"text\", \"es\": \"texto\"}}", command_id)
		for key in entries:
			if str(key).strip_edges().is_empty() or typeof(entries[key]) != TYPE_DICTIONARY:
				return _send_error(client_id, "Each key needs a {locale: text} object", command_id)
			for locale in entries[key]:
				if locale_pattern.search(str(locale)) == null:
					return _send_error(client_id, "Locale %s should look like en, es or pt_BR" % locale, command_id)
				if not str(locale) in table["locales"]:
					table["locales"].append(str(locale))
				if not table["rows"].has(str(key)):
					table["rows"][str(key)] = {}
				table["rows"][str(key)][str(locale)] = str(entries[key][locale])
		DirAccess.make_dir_recursive_absolute(csv_path.get_base_dir())
		var file := FileAccess.open(csv_path, FileAccess.WRITE)
		if file == null:
			return _send_error(client_id, "Failed to write %s" % csv_path, command_id)
		file.store_csv_line(PackedStringArray(["keys"] + table["locales"]))
		for key in table["rows"]:
			var row := [key]
			for locale in table["locales"]:
				row.append(table["rows"][key].get(locale, ""))
			file.store_csv_line(PackedStringArray(row))
		file = null
		var registered: PackedStringArray = ProjectSettings.get_setting("internationalization/locale/translations", PackedStringArray())
		for locale in table["locales"]:
			var translation_path := "%s.%s.translation" % [csv_path.get_basename(), locale]
			if not translation_path in registered:
				registered.append(translation_path)
		ProjectSettings.set_setting("internationalization/locale/translations", registered)
		ProjectSettings.save()
		# A new CSV is imported by the scan; an edited one is re-imported explicitly, because a change
		# within the same second as the last import kept the old .translation files (no new locale).
		var filesystem := EditorInterface.get_resource_filesystem()
		if existed:
			filesystem.reimport_files(PackedStringArray([csv_path]))
		else:
			filesystem.scan()
	elif action == "set_fallback":
		var locale := str(params.get("locale", ""))
		if locale_pattern.search(locale) == null:
			return _send_error(client_id, "locale should look like en, es or pt_BR", command_id)
		ProjectSettings.set_setting("internationalization/locale/fallback", locale)
		ProjectSettings.save()
	elif action != "list":
		return _send_error(client_id, "action must be list, set_entries or set_fallback", command_id)
	_send_success(client_id, {
		"action": action,
		"csv_path": csv_path,
		"locales": table["locales"],
		"key_count": (table["rows"] as Dictionary).size(),
		"keys": (table["rows"] as Dictionary).keys().slice(0, 50),
		"registered": ProjectSettings.get_setting("internationalization/locale/translations", PackedStringArray()),
		"fallback": ProjectSettings.get_setting("internationalization/locale/fallback", "en"),
	}, command_id)


func _read_translation_csv(csv_path: String) -> Dictionary:
	var table := {"locales": [], "rows": {}}
	var file := FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		return table
	var header := file.get_csv_line()
	table["locales"] = Array(header).slice(1)
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.size() < 1 or row[0].strip_edges().is_empty():
			continue
		var texts := {}
		for i in range(1, mini(row.size(), header.size())):
			texts[header[i]] = row[i]
		table["rows"][row[0]] = texts
	return table


# --- select_in_editor -----------------------------------------------------------------------

func _select_in_editor(client_id: int, params: Dictionary, command_id: String) -> void:
	var selection := EditorInterface.get_selection()
	var node_path := str(params.get("node_path", ""))
	if not node_path.is_empty():
		var node := _get_editor_node(node_path)
		if not node:
			return _send_error(client_id, "Node not found: %s" % node_path, command_id)
		selection.clear()
		selection.add_node(node)
		EditorInterface.edit_node(node)
		if node is Node3D:
			EditorInterface.set_main_screen_editor("3D")
		elif node is CanvasItem:
			EditorInterface.set_main_screen_editor("2D")
	_send_success(client_id, {"selected": selection.get_selected_nodes().map(func(selected): return _to_mcp_path(selected))}, command_id)
