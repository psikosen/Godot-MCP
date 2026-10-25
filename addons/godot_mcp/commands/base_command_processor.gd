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

	# Try to find node as child of edited scene root
	return edited_scene_root.get_node_or_null(path)


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
	return ResourceSaver.save(resource, contained)

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


func _coerce_value_to_type(value, value_type: int, property_class_name: String = ""):
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
		TYPE_ARRAY, TYPE_DICTIONARY:
			return value
		TYPE_OBJECT:
			if typeof(value) == TYPE_STRING and value.begins_with("res://"):
				var resource = ResourceLoader.load(value)
				return resource if resource != null else value
			return value
		_:
			return _parse_property_value(value)


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
	if value is Array and value.size() >= 3:
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
		if value == null or value is Object:
			return ""
		return "Property %s expects a %s (for a resource, a res:// path to an existing file), got %s" % [
			property_name, str(info.get("class_name", "Object")), JSON.stringify(value)]
	var numeric := [TYPE_INT, TYPE_FLOAT]
	var listish := [TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY,
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY,
		TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY]
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
