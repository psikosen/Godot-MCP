@tool
class_name MCPBaseCommandProcessor
extends Node

# Signal emitted when a command has completed processing
signal command_completed(client_id, command_type, result, command_id)

# Reference to the server - passed by the command handler
var _websocket_server = null

# Values refused while a command collected its changes (see _capture_property_change). A command
# always ends in _send_success or _send_error; a non-empty list turns its success into an error.
var _refused_values: Array = []


# Must be implemented by subclasses
func process_command(
	client_id: int, command_type: String, params: Dictionary, command_id: String
) -> bool:
	return false


# Helper functions common to all command processors
func _send_success(client_id: int, result: Dictionary, command_id: String) -> void:
	if not _refused_values.is_empty():
		var refused := "; ".join(PackedStringArray(_refused_values))
		var applied: bool = str(result.get("status", "")) != "no_change"
		return _send_error(client_id, "Refused: %s.%s" % [refused, " Other changes in this call were applied." if applied else ""], command_id)
	var response = {"status": "success", "result": result}

	if not command_id.is_empty():
		response["commandId"] = command_id

	# Emit the signal for local processing (useful for testing)
	command_completed.emit(client_id, "success", result, command_id)

	# Send to websocket if available
	if _websocket_server:
		_websocket_server.send_response(client_id, response)


func _send_error(client_id: int, message: String, command_id: String) -> void:
	_refused_values.clear()
	var response = {"status": "error", "message": message}

	if not command_id.is_empty():
		response["commandId"] = command_id

	# Emit the signal for local processing (useful for testing)
	var error_result = {"error": message}
	command_completed.emit(client_id, "error", error_result, command_id)

	# Send to websocket if available
	if _websocket_server:
		_websocket_server.send_response(client_id, response)
	print("Error: %s" % message)


# Common utility methods
func _get_editor_node(path: String) -> Node:
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		print("GodotMCPPlugin not found in Engine metadata")
		return null

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()

	if not edited_scene_root:
		print("No edited scene found")
		return null

	# Handle absolute paths
	if path == "/root" or path == "":
		return edited_scene_root

	if path.begins_with("/root/"):
		path = path.substr(6)  # Remove "/root/"
	elif path.begins_with("/"):
		path = path.substr(1)  # Remove leading "/"

	# Try to find node as child of edited scene root, then among nodes staged by an open transaction.
	var found: Node = edited_scene_root.get_node_or_null(path)
	if found == null:
		found = MCPSceneTransactionManager.find_pending_node("/root/" + path.trim_suffix("/"))
	# In a running game the scene root sits under /root ("/root/Level/Player"), and AIs write paths
	# that way; here /root is the scene root itself, so accept that form too.
	var root_name := String(edited_scene_root.name)
	if found == null and path == root_name:
		return edited_scene_root
	if found == null and path.begins_with(root_name + "/"):
		return _get_editor_node("/root/" + path.substr(root_name.length() + 1))
	return found


# Path as MCP clients address it ("/root" = edited scene root), not the editor-internal tree path.
func _to_mcp_path(node: Node) -> String:
	if node == null:
		return "/root"
	if not node.is_inside_tree():
		return "<detached:%s>" % str(node.name)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if plugin == null:
		return str(node.get_path())

	var editor_interface = plugin.get_editor_interface()
	if editor_interface == null:
		return str(node.get_path())

	var edited_scene_root = editor_interface.get_edited_scene_root()
	if edited_scene_root == null:
		return str(node.get_path())

	if node == edited_scene_root:
		return "/root"

	if edited_scene_root.is_ancestor_of(node):
		return "/root/" + str(edited_scene_root.get_path_to(node))

	return str(node.get_path())


# Simplified res:// path, or "" when it resolves outside the project. See ResourceUtils.
func _contained_res_path(path: String) -> String:
	return ResourceUtils.contained_res_path(path)

# ResourceSaver.save, refused (ERR_FILE_BAD_PATH) when the path is outside the project.
func _save_resource_contained(resource: Resource, path: String) -> int:
	var contained := _contained_res_path(path)
	if contained.is_empty():
		push_error("Refusing to save outside the project (res://): " + path)
		return ERR_FILE_BAD_PATH
	var result := ResourceSaver.save(resource, contained)
	if result == OK and not (resource is PackedScene):
		resource.take_over_path(contained)  # reference the file, not an embedded copy (see ResourceUtils.safe_save)
	return result

# Groups a user can see: Godot adds viewport-internal groups ("_vp_unhandled_input<id>") to nodes.
# Godot adds internal groups ("_vp_*", "_root_canvas*", "__cameras_*"); user groups never start with "_".
func _user_groups(node: Node) -> Array:
	return node.get_groups().filter(func(group): return not str(group).begins_with("_"))

# Folders Godot itself skips (.gdignore, hidden like .godot/.git) plus node_modules: walking the
# server's ~12k dependency files made project resources time out.
func _is_ignored_dir(relative_path: String, dir_name: String) -> bool:
	if dir_name.begins_with(".") or dir_name == "node_modules":
		return true
	return FileAccess.file_exists("res://" + relative_path + "/.gdignore")

func _scan_directory(dir: DirAccess, path: String, extensions: Array, files: Array) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			var subdir = DirAccess.open("res://" + path + file_name)
			if subdir and not _is_ignored_dir(path + file_name, file_name):
				_scan_directory(subdir, path + file_name + "/", extensions, files)
		else:
			var file_path = path + file_name
			var has_valid_extension = extensions.is_empty()
			
			for ext in extensions:
				if file_name.ends_with(ext):
					has_valid_extension = true
					break
			
			if has_valid_extension:
				files.append("res://" + file_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()


# Shared by the workflow and builder processors.
func _unique_child_name(parent: Node, wanted: String) -> String:
	var name := wanted
	var suffix := 2
	while parent.has_node(NodePath(name)):
		name = "%s%d" % [wanted, suffix]
		suffix += 1
	return name


func _join_path(parent_path: String, child: String) -> String:
	return parent_path.trim_suffix("/") + "/" + child


func _godot_version() -> String:
	var version: Dictionary = Engine.get_version_info()
	return "%d.%d.%d" % [version["major"], version["minor"], version["patch"]]


# A change to a node inside an instanced scene (an imported model, say) saves only with Editable
# Children on for that instance; turns it on where needed. Returns the instances it opened.
func _open_instances(transaction, nodes: Array) -> Array:
	var scene_root := EditorInterface.get_edited_scene_root()
	var seen: Array = []
	var opened: Array = []
	for node in nodes:
		var instance: Node = node.owner
		while instance and instance != scene_root and not instance in seen:
			seen.append(instance)
			if not scene_root.is_editable_instance(instance):
				transaction.add_do_method(scene_root, "set_editable_instance", [instance, true])
				transaction.add_undo_method(scene_root, "set_editable_instance", [instance, false])
				opened.append(_to_mcp_path(instance))
			instance = instance.owner
	return opened


# The Skeleton3D at node_path, or the first one under it (imported models nest it deep).
func _find_skeleton(path: String) -> Skeleton3D:
	var node := _get_editor_node(path)
	if node == null:
		return null
	if node is Skeleton3D:
		return node
	var found := node.find_children("*", "Skeleton3D", true, true)
	return found[0] as Skeleton3D if not found.is_empty() else null


func _skeleton_error(path: String) -> String:
	return "No Skeleton3D at or under %s" % path


# Waits (a coroutine: call it with await) until Godot has imported newly written files, so the next
# command can load them. A file in a folder the editor has not seen yet needs a full scan, which
# runs in the background; replying before it ends made the next tool fail. False on timeout.
func _await_imports(paths: Array, timeout_ms := 10000) -> bool:
	var filesystem := EditorInterface.get_resource_filesystem()
	for path in paths:
		filesystem.update_file(path)
	var deadline := Time.get_ticks_msec() + timeout_ms
	var scanned := false
	while true:
		var pending := paths.filter(func(path): return not FileAccess.file_exists(path + ".import") or not ResourceLoader.exists(path))
		if pending.is_empty():
			return true
		if Time.get_ticks_msec() > deadline:
			return false
		if not scanned and not filesystem.is_scanning():
			filesystem.scan()
			scanned = true
		await Engine.get_main_loop().process_frame
	return false


# Removes node on commit; undo puts it back at its index with its owners. The node stays in memory
# while that undo exists (freeing it at once left undo nothing to put back).
func _remove_with_undo(transaction, node: Node) -> void:
	var parent := node.get_parent()
	transaction.add_do_method(parent, "remove_child", [node])
	transaction.add_undo_method(parent, "add_child", [node, true])
	transaction.add_undo_method(parent, "move_child", [node, node.get_index()])
	var owned: Array = [node]
	owned.append_array(node.find_children("*", "", true, false))
	for item in owned:
		if item.owner:
			transaction.add_undo_method(item, "set_owner", [item.owner])
	transaction.add_undo_reference(node)


# Adds a new node (and its own new children) on commit, owned by the scene so it saves; undo removes it.
func _add_owned(transaction, parent: Node, node: Node, owner: Node) -> void:
	transaction.add_do_method(parent, "add_child", [node, true])
	transaction.add_do_method(node, "set_owner", [owner])
	transaction.add_do_reference(node)
	transaction.add_undo_method(parent, "remove_child", [node])


func _transaction(action_name: String, transaction_id: String, metadata: Dictionary):
	if transaction_id.is_empty():
		return MCPSceneTransactionManager.begin_inline(action_name, metadata)
	var existing = MCPSceneTransactionManager.get_transaction(transaction_id)
	return existing if existing else MCPSceneTransactionManager.begin_registered(transaction_id, action_name, metadata)


func _finish_transaction(client_id: int, command_id: String, transaction, transaction_id: String, response: Dictionary) -> void:
	response["transaction_id"] = transaction.transaction_id
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit the change", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"
	_send_success(client_id, response, command_id)


# MultiMesh transforms as one buffer (12 floats each: one row of the 3x4 matrix at a time). A
# --headless editor drops set_instance_transform, so fields built there were empty on save; a buffer
# assigned in one go is kept.
func _multimesh_buffer_3d(transforms: Array) -> PackedFloat32Array:
	var data := PackedFloat32Array()
	data.resize(transforms.size() * 12)
	for i in range(transforms.size()):
		var t: Transform3D = transforms[i]
		var o := i * 12
		data[o] = t.basis.x.x
		data[o + 1] = t.basis.y.x
		data[o + 2] = t.basis.z.x
		data[o + 3] = t.origin.x
		data[o + 4] = t.basis.x.y
		data[o + 5] = t.basis.y.y
		data[o + 6] = t.basis.z.y
		data[o + 7] = t.origin.y
		data[o + 8] = t.basis.x.z
		data[o + 9] = t.basis.y.z
		data[o + 10] = t.basis.z.z
		data[o + 11] = t.origin.z
	return data


# Paths the MCP itself depends on (its addon code, approvals, project file, import cache): tools
# must not delete, move or rewrite them.
const PROTECTED_PATHS := ["res://project.godot", "res://addons/godot_mcp/", "res://project-manager/", "res://.godot/"]


# macOS and Windows file systems ignore case, so "res://ADDONS/..." is the same folder.
func _is_protected_path(path: String) -> bool:
	for protected in PROTECTED_PATHS:
		if path.to_lower() == protected or path.to_lower().begins_with(protected):
			return true
	return false


# The recent-errors buffer (utils/godot45/error_log.gd), or null before Godot 4.5.
func _error_log():
	return Engine.get_meta("GodotMCPErrorLog") if Engine.has_meta("GodotMCPErrorLog") else null


# Returns why a saved .gd file does not compile, or "". Writing a file never parsed it, so broken
# scripts were reported as created successfully. reload_cached reloads the loaded script (so the
# editor runs the new code); otherwise a throwaway copy is compiled, because reloading a script
# while it runs (an editor plugin, this addon) crashed the editor.
func _gdscript_compile_error(script_path: String, reload_cached := true) -> String:
	var error_log = _error_log()
	var mark: int = error_log.mark() if error_log else 0
	var err: int = ERR_PARSE_ERROR
	if not reload_cached:
		var probe := GDScript.new()
		# The copy gets the file's path without entering the resource cache, so the real script is
		# untouched while class_name checks, relative preloads and the addon warning rules still apply.
		probe.set_path_cache(script_path)
		probe.source_code = FileAccess.get_file_as_string(script_path)
		err = probe.reload()
	else:
		var script = ResourceLoader.load(script_path, "", ResourceLoader.CACHE_MODE_REUSE)
		if script is GDScript:
			script.source_code = FileAccess.get_file_as_string(script_path)
			err = script.reload(true)
		elif script is Script:
			return ""
	if err == OK:
		return ""
	var reasons: Array = []
	if error_log:
		for entry in error_log.entries_since(mark):
			var reason := "line %d: %s" % [entry["line"], str(entry["message"]).trim_suffix(".")]
			# Loading and reloading both report the same parse error.
			if (entry["type"] == "script" or entry["file"] == script_path) and not reasons.has(reason):
				reasons.append(reason)
	return "; ".join(PackedStringArray(reasons)) if not reasons.is_empty() else error_string(err)


# Editor helper nodes (e.g. the "@AnimationPlayer@20382" an AnimationTree preview adds) have no
# owner and an auto-generated "@" name; they are not part of the user's scene.
func _is_editor_internal_node(node: Node) -> bool:
	return node.owner == null and str(node.name).begins_with("@")

# Edits to a node inside an instanced scene are saved as overrides only when that instance has
# "editable children"; without it save_scene dropped them (null mesh/material at runtime).
func _ensure_saved_override(target: Object) -> void:
	if not (target is Node):
		return
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root == null or target == scene_root:
		return
	var instance_root: Node = target.owner
	while instance_root != null and instance_root != scene_root:
		if instance_root.scene_file_path != "" and scene_root.is_ancestor_of(instance_root):
			scene_root.set_editable_instance(instance_root, true)
		instance_root = instance_root.owner

# Helper function to mark a scene as modified
func _mark_scene_modified() -> void:
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		print("GodotMCPPlugin not found in Engine metadata")
		return

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()

	if edited_scene_root:
		# This internally marks the scene as modified in the editor
		editor_interface.mark_scene_as_unsaved()


# Helper function to access the EditorUndoRedoManager
func _get_undo_redo():
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin or not plugin.has_method("get_undo_redo"):
		print("Cannot access UndoRedo from plugin")
		return null

	return plugin.get_undo_redo()


# Helper function to parse property values from string to proper Godot types
func _parse_property_value(value):
	# Only try to parse strings that look like they could be Godot types
	if (
		typeof(value) == TYPE_STRING
		and (
			value.begins_with("Vector")
			or value.begins_with("Transform")
			or value.begins_with("Rect")
			or value.begins_with("Color")
			or value.begins_with("Quat")
			or value.begins_with("Basis")
			or value.begins_with("Plane")
			or value.begins_with("AABB")
			or value.begins_with("Projection")
			or value.begins_with("Callable")
			or value.begins_with("Signal")
			or value.begins_with("PackedVector")
			or value.begins_with("PackedString")
			or value.begins_with("PackedFloat")
			or value.begins_with("PackedInt")
			or value.begins_with("PackedColor")
			or value.begins_with("PackedByteArray")
			or value.begins_with("Dictionary")
			or value.begins_with("Array")
		)
	):
		var expression = Expression.new()
		var error = expression.parse(value, [])

		if error == OK:
			var result = expression.execute([], null, true)
			if not expression.has_execute_failed():
				print("Successfully parsed %s as %s" % [value, result])
				return result
			else:
				print("Failed to execute expression for: %s" % value)
		else:
			print("Failed to parse expression: %s (Error: %d)" % [value, error])

	# Otherwise, return value as is
	return value


func _get_property_info(target: Object, property_name: String) -> Dictionary:
	for property_info in target.get_property_list():
		if property_info.get("name", "") == property_name:
			return property_info
	return {}


func _convert_property_value(target: Object, property_name: String, value):
	var property_info := _get_property_info(target, property_name)
	if property_info.is_empty():
		return _parse_property_value(value)

	var property_type: int = property_info.get("type", TYPE_NIL)
	var property_class_name: String = property_info.get("class_name", "")
	return _coerce_value_to_type(_with_missing_components(target.get(property_name), value), property_type, property_class_name)


# Converts and stores a value on a node or resource the command is building. A direct typed
# assignment of a value that cannot convert (a float for a Color) raises a script error and
# stops the command, so such values are refused and the property keeps its default.
func _assign_converted(target: Object, property_name: String, value) -> void:
	var converted = _convert_property_value(target, property_name, value)
	var error := _property_value_error(target, property_name, converted)
	if error.is_empty():
		target.set(property_name, converted)
	elif not _refused_values.has(error):
		_refused_values.append(error)


func _coerce_value_to_type(value, value_type: int, property_class_name: String = ""):
	# AIs sometimes quote a value twice ("\"Vector3(1, 2, 3)\"") or write "null" for nothing.
	if typeof(value) == TYPE_STRING and not (value_type in [TYPE_NIL, TYPE_STRING, TYPE_STRING_NAME]):
		var text: String = value.strip_edges()
		if text.length() >= 2 and text.begins_with("\"") and text.ends_with("\""):
			value = text.substr(1, text.length() - 2)
		if value_type == TYPE_OBJECT and text == "null":
			return null
	match value_type:
		TYPE_NIL:
			return value
		# Values that cannot be converted are returned unchanged so _property_value_error can
		# refuse them; set() would otherwise store a silent default (false, 0, black).
		TYPE_BOOL:
			if typeof(value) == TYPE_BOOL:
				return value
			if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
				return value != 0
			if typeof(value) == TYPE_STRING:
				var lowered: String = value.strip_edges().to_lower()
				if lowered in ["true", "1", "yes", "on"]:
					return true
				if lowered in ["false", "0", "no", "off"]:
					return false
			return value
		TYPE_INT:
			if typeof(value) == TYPE_STRING:
				return value.to_int() if value.strip_edges().is_valid_int() else value
			if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_BOOL:
				return int(value)
			return value
		TYPE_FLOAT:
			if typeof(value) == TYPE_STRING:
				return value.to_float() if value.strip_edges().is_valid_float() else value
			if typeof(value) == TYPE_INT or typeof(value) == TYPE_BOOL:
				return float(value)
			return value
		TYPE_STRING:
			return str(value)
		TYPE_VECTOR2:
			return _coerce_to_vector2(value)
		TYPE_VECTOR2I:
			return _coerce_to_vector2i(value)
		TYPE_VECTOR3:
			return _coerce_to_vector3(value)
		TYPE_VECTOR3I:
			return _coerce_to_vector3i(value)
		TYPE_VECTOR4:
			return _coerce_to_vector4(value)
		TYPE_VECTOR4I:
			return _coerce_to_vector4i(value)
		TYPE_COLOR:
			return _coerce_to_color(value)
		TYPE_RECT2:
			return _coerce_to_rect2(value)
		TYPE_RECT2I:
			return _coerce_to_rect2i(value)
		TYPE_NODE_PATH:
			return value if value is NodePath else NodePath(str(value))
		TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY:
			var packed = _points_to_packed(value, value_type == TYPE_PACKED_VECTOR3_ARRAY)
			return packed if packed != null else value
		TYPE_PACKED_COLOR_ARRAY:
			# set() turned [r, g, b, a] lists and {r, g, b} maps into black. Convert each element; an
			# element that is not a color leaves the value unconverted so it is refused.
			if value is Array:
				var colors := PackedColorArray()
				for item in value:
					var color = _coerce_to_color(item)
					if not (color is Color):
						return value
					colors.append(color)
				return colors
			return value
		TYPE_ARRAY:
			# Arrays of point lists (NavigationPolygon.outlines): [x, y] pairs cannot become Vector2 on
			# their own, so Godot stored zeros. Convert each inner list when every element is a point list.
			if value is Array and not value.is_empty() and value.all(func(item): return item is Array):
				var converted: Array = []
				for item in value:
					var packed = _points_to_packed(item, false)
					if packed == null:
						return value
					converted.append(packed)
				return converted
			return value
		TYPE_DICTIONARY:
			return value
		TYPE_OBJECT:
			if typeof(value) == TYPE_STRING and value.begins_with("res://"):
				var resource = ResourceLoader.load(value)
				return resource if resource != null else value
			# A new built-in resource: "BoxMesh", or {"type": "BoxMesh", "size": [2, 1, 2]}.
			var spec = {"type": value} if typeof(value) == TYPE_STRING else value
			# {"sky_material": {...}} for a Sky property: the property's own class is the type when it can be made.
			if spec is Dictionary and not spec.has("type") and not spec.is_empty() and ClassDB.class_exists(property_class_name) and ClassDB.can_instantiate(property_class_name):
				spec = spec.duplicate()
				spec["type"] = property_class_name
			if spec is Dictionary and spec.has("type"):
				var built = _new_resource(spec, property_class_name)
				return built if built != null else value
			return value
		_:
			return _parse_property_value(value)


func _example_class(base_class: String) -> String:
	for candidate in ["BoxMesh", "BoxShape3D", "RectangleShape2D", "StandardMaterial3D", "Gradient", "Curve"]:
		if not base_class.is_empty() and ClassDB.is_parent_class(candidate, base_class):
			return candidate
	return "BoxMesh"


# Resource of spec.type (a subclass of base_class when given) with spec's other keys as its
# properties, converted like node properties and nested the same way. Null when spec does not fit.
func _new_resource(spec: Dictionary, base_class: String):
	var resource_class := str(spec["type"])
	if not ClassDB.class_exists(resource_class) or not ClassDB.can_instantiate(resource_class) or not ClassDB.is_parent_class(resource_class, "Resource"):
		return null
	if not base_class.is_empty() and ClassDB.class_exists(base_class) and not ClassDB.is_parent_class(resource_class, base_class):
		return null
	var resource: Resource = ClassDB.instantiate(resource_class)
	for key in spec:
		if key == "type":
			continue
		if _get_property_info(resource, str(key)).is_empty():
			return null
		var converted = _convert_property_value(resource, str(key), spec[key])
		if not _property_value_error(resource, str(key), converted).is_empty():
			return null
		resource.set(str(key), converted)
	return resource


func _coerce_to_vector2(value):
	if value is Vector2:
		return value
	if value is Dictionary and value.has("x"):
		return Vector2(value.get("x", 0.0), value.get("y", 0.0))
	if value is Array and value.size() >= 2:
		return Vector2(value[0], value[1])
	var numbers := _numbers_from_text(value, 2)
	if not numbers.is_empty():
		return Vector2(numbers[0], numbers[1])
	return _parse_property_value(value)


func _coerce_to_vector2i(value):
	if value is Vector2i:
		return value
	if value is Dictionary and value.has("x"):
		return Vector2i(value.get("x", 0), value.get("y", 0))
	if value is Array and value.size() >= 2:
		return Vector2i(value[0], value[1])
	return _parse_property_value(value)


func _coerce_to_vector3(value):
	if value is Vector3:
		return value
	if value is Dictionary and value.has("x"):
		return Vector3(value.get("x", 0.0), value.get("y", 0.0), value.get("z", 0.0))
	if value is Array and value.size() >= 3:
		return Vector3(value[0], value[1], value[2])
	var numbers := _numbers_from_text(value, 3)
	if not numbers.is_empty():
		return Vector3(numbers[0], numbers[1], numbers[2])
	return _parse_property_value(value)


func _coerce_to_vector3i(value):
	if value is Vector3i:
		return value
	if value is Dictionary and value.has("x"):
		return Vector3i(value.get("x", 0), value.get("y", 0), value.get("z", 0))
	if value is Array and value.size() >= 3:
		return Vector3i(value[0], value[1], value[2])
	return _parse_property_value(value)


func _coerce_to_vector4(value):
	if value is Vector4:
		return value
	if value is Dictionary and value.has("x"):
		return Vector4(
			value.get("x", 0.0), value.get("y", 0.0), value.get("z", 0.0), value.get("w", 0.0)
		)
	if value is Array and value.size() >= 4:
		return Vector4(value[0], value[1], value[2], value[3])
	var numbers := _numbers_from_text(value, 4)
	if not numbers.is_empty():
		return Vector4(numbers[0], numbers[1], numbers[2], numbers[3])
	return _parse_property_value(value)


func _coerce_to_vector4i(value):
	if value is Vector4i:
		return value
	if value is Dictionary and value.has("x"):
		return Vector4i(value.get("x", 0), value.get("y", 0), value.get("z", 0), value.get("w", 0))
	if value is Array and value.size() >= 4:
		return Vector4i(value[0], value[1], value[2], value[3])
	return _parse_property_value(value)


func _coerce_to_color(value):
	if value is Color:
		return value
	if value is Dictionary and (value.has("r") or value.has("g") or value.has("b")):
		return Color(
			value.get("r", 0.0), value.get("g", 0.0), value.get("b", 0.0), value.get("a", 1.0)
		)
	if value is Array and value.size() >= 3 and value.all(func(n): return n is float or n is int):
		var alpha: float = float(value[3]) if value.size() >= 4 else 1.0
		return Color(value[0], value[1], value[2], alpha)
	if typeof(value) == TYPE_STRING:
		var text: String = value.strip_edges()
		if text.begins_with("Color"):
			return _parse_property_value(text)
		if Color.html_is_valid(text):
			return Color.html(text)
		# Named colors ("blue"): from_string returns the fallback when it cannot parse, so two
		# different fallbacks agree only for a real color.
		var parsed_a := Color.from_string(text, Color(0, 0, 0, 0))
		var parsed_b := Color.from_string(text, Color(1, 1, 1, 1))
		if parsed_a == parsed_b:
			return parsed_a
		return value
	return _parse_property_value(value)


# [[x, y], {x, y}, ...] -> PackedVector2Array (or 3D), or null when any element is not a point.
# A flat number list [x1, y1, x2, y2, ...] works too.
func _points_to_packed(value, three_d: bool):
	if not (value is Array):
		return null
	var width := 3 if three_d else 2
	if not value.is_empty() and value.size() % width == 0 and value.all(func(n): return n is float or n is int):
		var grouped: Array = []
		for start in range(0, value.size(), width):
			grouped.append(value.slice(start, start + width))
		value = grouped
	var points: Array = []
	for item in value:
		var point = _coerce_to_vector3(item) if three_d else _coerce_to_vector2(item)
		if not (point is Vector3 if three_d else point is Vector2):
			return null
		points.append(point)
	return PackedVector3Array(points) if three_d else PackedVector2Array(points)


# "(4, 5, 6)" or "4,5,6" -> [4.0, 5.0, 6.0] when it holds exactly `count` numbers, else [].
func _numbers_from_text(value, count: int) -> Array:
	if typeof(value) != TYPE_STRING:
		return []
	var parts: PackedStringArray = value.strip_edges().trim_prefix("(").trim_suffix(")").split(",")
	if parts.size() != count:
		return []
	var numbers: Array = []
	for part in parts:
		if not part.strip_edges().is_valid_float():
			return []
		numbers.append(part.strip_edges().to_float())
	return numbers


# Why `value` cannot be stored in `property_name`, or "" when it can. set() silently falls back
# to a default (0, false, black) on a type mismatch and ignores out-of-range values the inspector
# would refuse, so tools that only called set() reported success for changes that never happened.
func _property_value_error(target: Object, property_name: String, value) -> String:
	var info := _get_property_info(target, property_name)
	if info.is_empty():
		return ""
	var expected: int = info.get("type", TYPE_NIL)
	var actual := typeof(value)
	if expected == TYPE_NIL:
		return ""
	if expected == TYPE_OBJECT:
		var wanted := str(info.get("class_name", ""))
		if value == null or (value is Object and (wanted.is_empty() or not ClassDB.class_exists(wanted) or value.is_class(wanted))):
			return ""
		if value is Object:
			return "Property %s expects a %s, got a %s" % [property_name, wanted, value.get_class()]
		return "Property %s expects a %s: a res:// file, a class name like \"%s\", or {\"type\": class, other properties...}, got %s" % [
			property_name, wanted if not wanted.is_empty() else "Object", _example_class(wanted), JSON.stringify(value)]
	var numeric := [TYPE_INT, TYPE_FLOAT]
	# Packed vector and color arrays are left out on purpose: an Array that _points_to_packed could not convert
	# would otherwise be stored as zeros.
	var listish := [TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY,
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY]
	var stringish := [TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH]
	var compatible: bool = (
		actual == expected
		or (expected in numeric and actual in numeric)
		or (expected in listish and actual in listish)
		or (expected in stringish and actual in stringish)
		or [expected, actual] in [[TYPE_VECTOR2I, TYPE_VECTOR2], [TYPE_VECTOR2, TYPE_VECTOR2I],
			[TYPE_VECTOR3I, TYPE_VECTOR3], [TYPE_VECTOR3, TYPE_VECTOR3I], [TYPE_VECTOR4I, TYPE_VECTOR4],
			[TYPE_VECTOR4, TYPE_VECTOR4I], [TYPE_RECT2I, TYPE_RECT2], [TYPE_RECT2, TYPE_RECT2I]]
	)
	if not compatible:
		return "Property %s expects %s, got %s" % [property_name, type_string(expected), JSON.stringify(value)]
	# Vectors Godot silently refuses but gives no range hint for.
	if value is Vector2 or value is Vector3:
		var components: Array = [value.x, value.y] if value is Vector2 else [value.x, value.y, value.z]
		match property_name:
			"up_direction":
				if value.is_zero_approx():
					return "Property up_direction must not be a zero vector"
			"zoom":
				if components.any(func(c): return c <= 0.0):
					return "Property zoom must be greater than 0 on every axis, got %s" % str(value)
			"repeat_size":
				if components.any(func(c): return c < 0.0):
					return "Property repeat_size must not be negative, got %s" % str(value)
	var hint := int(info.get("hint", 0))
	if expected == TYPE_INT and hint == PROPERTY_HINT_ENUM:
		var allowed: Array = []
		var items: PackedStringArray = str(info.get("hint_string", "")).split(",")
		for index in items.size():
			var parts_enum: PackedStringArray = items[index].split(":")
			allowed.append(int(parts_enum[1]) if parts_enum.size() > 1 and parts_enum[1].is_valid_int() else index)
		if not allowed.is_empty() and not int(value) in allowed:
			return "Property %s must be one of %s (%s), got %s" % [property_name, str(allowed), str(info.get("hint_string", "")), str(value)]
	if expected == TYPE_INT and hint in [PROPERTY_HINT_LAYERS_2D_PHYSICS, PROPERTY_HINT_LAYERS_3D_PHYSICS,
			PROPERTY_HINT_LAYERS_2D_RENDER, PROPERTY_HINT_LAYERS_3D_RENDER, PROPERTY_HINT_LAYERS_2D_NAVIGATION,
			PROPERTY_HINT_LAYERS_3D_NAVIGATION, PROPERTY_HINT_LAYERS_AVOIDANCE]:
		if int(value) < 0 or int(value) > 0xFFFFFFFF:
			return "Property %s is a 32-bit layer mask (0 to 4294967295), got %s" % [property_name, str(value)]
	if expected in numeric and hint == PROPERTY_HINT_RANGE:
		var parts: PackedStringArray = str(info.get("hint_string", "")).split(",")
		if parts.size() >= 2 and parts[0].strip_edges().is_valid_float() and parts[1].strip_edges().is_valid_float():
			var low := parts[0].to_float()
			var high := parts[1].to_float()
			if value < low and not parts.has("or_less"):
				return "Property %s must be >= %s, got %s" % [property_name, str(low), str(value)]
			if value > high and not parts.has("or_greater"):
				return "Property %s must be <= %s, got %s" % [property_name, str(high), str(value)]
	return ""


func _coerce_to_rect2(value):
	if value is Rect2:
		return value
	if value is Dictionary:
		var position_value = value.get("position")
		var size_value = value.get("size")
		return Rect2(_coerce_to_vector2(position_value), _coerce_to_vector2(size_value))
	return _parse_property_value(value)


func _coerce_to_rect2i(value):
	if value is Rect2i:
		return value
	if value is Dictionary:
		var position_value = value.get("position")
		var size_value = value.get("size")
		return Rect2i(_coerce_to_vector2i(position_value), _coerce_to_vector2i(size_value))
	return _parse_property_value(value)


func _coerce_value_to_match(existing_value, new_value):
	if typeof(existing_value) == TYPE_NIL:
		return new_value
	return _coerce_value_to_type(_with_missing_components(existing_value, new_value), typeof(existing_value))


# {"x": 2, "y": 2} for a Vector3 keeps the current z instead of zeroing it (same for colors).
func _with_missing_components(existing_value, new_value):
	if not (new_value is Dictionary):
		return new_value
	var keys: Array = []
	match typeof(existing_value):
		TYPE_VECTOR2, TYPE_VECTOR2I:
			keys = ["x", "y"]
		TYPE_VECTOR3, TYPE_VECTOR3I:
			keys = ["x", "y", "z"]
		TYPE_VECTOR4, TYPE_VECTOR4I:
			keys = ["x", "y", "z", "w"]
		TYPE_COLOR:
			keys = ["r", "g", "b", "a"]
		_:
			return new_value
	var named := false
	for key in keys:
		if new_value.has(key):
			named = true
	if not named:
		return new_value  # wrong keys (e.g. x/y/z for a color): leave it for the type check to refuse
	var filled: Dictionary = new_value.duplicate()
	for key in keys:
		if not filled.has(key):
			filled[key] = existing_value[key]
	return filled


func _apply_nested_property_value(base_value, path: Array, new_value):
	if path.is_empty():
		return {
			"ok": true,
			"value": new_value,
			"leaf_previous": base_value,
			"leaf_value": new_value,
		}

	var key = path[0]
	var remaining = path.slice(1, path.size())

	# Vector/color components are numbers; float("bad") silently became 0.
	var component_types := [TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4,
		TYPE_VECTOR4I, TYPE_COLOR, TYPE_QUATERNION, TYPE_RECT2, TYPE_RECT2I]
	if typeof(base_value) in component_types and remaining.is_empty():
		var is_number: bool = typeof(new_value) == TYPE_INT or typeof(new_value) == TYPE_FLOAT \
			or (typeof(new_value) == TYPE_STRING and new_value.strip_edges().is_valid_float())
		if not is_number:
			return {"ok": false, "error": "Component %s expects a number, got %s" % [key, JSON.stringify(new_value)]}

	match typeof(base_value):
		TYPE_DICTIONARY:
			var dict_copy: Dictionary = base_value.duplicate(true)
			if remaining.is_empty():
				var previous_value = dict_copy.get(key)
				dict_copy[key] = _coerce_value_to_match(previous_value, new_value)
				return {
					"ok": true,
					"value": dict_copy,
					"leaf_previous": previous_value,
					"leaf_value": dict_copy.get(key),
				}
			elif not dict_copy.has(key):
				return {"ok": false, "error": "Dictionary missing key %s" % key}
			var nested_dict = _apply_nested_property_value(dict_copy[key], remaining, new_value)
			if not nested_dict.get("ok", false):
				return nested_dict
			dict_copy[key] = nested_dict.get("value")
			nested_dict["value"] = dict_copy
			return nested_dict
		TYPE_ARRAY:
			var index = int(key)
			var array_copy: Array = base_value.duplicate()
			if index < 0 or index >= array_copy.size():
				return {"ok": false, "error": "Array index out of range: %s" % key}
			if remaining.is_empty():
				var previous_element = array_copy[index]
				array_copy[index] = _coerce_value_to_match(previous_element, new_value)
				return {
					"ok": true,
					"value": array_copy,
					"leaf_previous": previous_element,
					"leaf_value": array_copy[index],
				}
			var nested_array = _apply_nested_property_value(array_copy[index], remaining, new_value)
			if not nested_array.get("ok", false):
				return nested_array
			array_copy[index] = nested_array.get("value")
			nested_array["value"] = array_copy
			return nested_array
		TYPE_VECTOR2:
			if remaining.size() > 0:
				return {"ok": false, "error": "Vector2 only supports single-level components"}
			var vector2_value: Vector2 = base_value
			var previous_component: float
			var new_component: float = float(new_value)
			match key:
				"x":
					previous_component = vector2_value.x
					vector2_value.x = new_component
				"y":
					previous_component = vector2_value.y
					vector2_value.y = new_component
				_:
					return {"ok": false, "error": "Unsupported Vector2 component: %s" % key}
			return {
				"ok": true,
				"value": vector2_value,
				"leaf_previous": previous_component,
				"leaf_value": new_component,
			}
		TYPE_VECTOR3:
			if remaining.size() > 0:
				return {"ok": false, "error": "Vector3 only supports single-level components"}
			var vector3_value: Vector3 = base_value
			var previous_vector3_component: float
			var new_vector3_component: float = float(new_value)
			match key:
				"x":
					previous_vector3_component = vector3_value.x
					vector3_value.x = new_vector3_component
				"y":
					previous_vector3_component = vector3_value.y
					vector3_value.y = new_vector3_component
				"z":
					previous_vector3_component = vector3_value.z
					vector3_value.z = new_vector3_component
				_:
					return {"ok": false, "error": "Unsupported Vector3 component: %s" % key}
			return {
				"ok": true,
				"value": vector3_value,
				"leaf_previous": previous_vector3_component,
				"leaf_value": new_vector3_component,
			}
		TYPE_VECTOR4:
			if remaining.size() > 0:
				return {"ok": false, "error": "Vector4 only supports single-level components"}
			var vector4_value: Vector4 = base_value
			var previous_vector4_component: float
			var new_vector4_component: float = float(new_value)
			match key:
				"x":
					previous_vector4_component = vector4_value.x
					vector4_value.x = new_vector4_component
				"y":
					previous_vector4_component = vector4_value.y
					vector4_value.y = new_vector4_component
				"z":
					previous_vector4_component = vector4_value.z
					vector4_value.z = new_vector4_component
				"w":
					previous_vector4_component = vector4_value.w
					vector4_value.w = new_vector4_component
				_:
					return {"ok": false, "error": "Unsupported Vector4 component: %s" % key}
			return {
				"ok": true,
				"value": vector4_value,
				"leaf_previous": previous_vector4_component,
				"leaf_value": new_vector4_component,
			}
		TYPE_COLOR:
			if remaining.size() > 0:
				return {"ok": false, "error": "Color only supports single-level components"}
			var color_value: Color = base_value
			var previous_color_component: float
			var new_color_component: float = float(new_value)
			match key:
				"r":
					previous_color_component = color_value.r
					color_value.r = new_color_component
				"g":
					previous_color_component = color_value.g
					color_value.g = new_color_component
				"b":
					previous_color_component = color_value.b
					color_value.b = new_color_component
				"a":
					previous_color_component = color_value.a
					color_value.a = new_color_component
				_:
					return {"ok": false, "error": "Unsupported Color component: %s" % key}
			return {
				"ok": true,
				"value": color_value,
				"leaf_previous": previous_color_component,
				"leaf_value": new_color_component,
			}
		_:
			return {
				"ok": false,
				"error": "Unsupported property path segment on type %s" % typeof(base_value)
			}
