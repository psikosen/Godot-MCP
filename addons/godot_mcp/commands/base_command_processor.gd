@tool
class_name MCPBaseCommandProcessor
extends Node

# Signal emitted when a command has completed processing
signal command_completed(client_id, command_type, result, command_id)

# Reference to the server - passed by the command handler
var _websocket_server = null


# Must be implemented by subclasses
func process_command(
	client_id: int, command_type: String, params: Dictionary, command_id: String
) -> bool:
	push_error("BaseCommandProcessor.process_command called directly")
	return false


# Helper functions common to all command processors
func _send_success(client_id: int, result: Dictionary, command_id: String) -> void:
	var response = {"status": "success", "result": result}

	if not command_id.is_empty():
		response["commandId"] = command_id

	# Emit the signal for local processing (useful for testing)
	command_completed.emit(client_id, "success", result, command_id)

	# Send to websocket if available
	if _websocket_server:
		_websocket_server.send_response(client_id, response)


func _send_error(client_id: int, message: String, command_id: String) -> void:
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
	var class_name: String = property_info.get("class_name", "")
	return _coerce_value_to_type(value, property_type, class_name)


func _coerce_value_to_type(value, value_type: int, class_name: String = ""):
	match value_type:
		TYPE_NIL:
			return value
		TYPE_BOOL:
			return bool(value)
		TYPE_INT:
			if typeof(value) == TYPE_STRING:
				return value.to_int()
			return int(value)
		TYPE_FLOAT:
			if typeof(value) == TYPE_STRING:
				return value.to_float()
			return float(value)
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
	if value is Dictionary:
		return Vector2(value.get("x", 0.0), value.get("y", 0.0))
	if value is Array and value.size() >= 2:
		return Vector2(value[0], value[1])
	return _parse_property_value(value)


func _coerce_to_vector2i(value):
	if value is Vector2i:
		return value
	if value is Dictionary:
		return Vector2i(value.get("x", 0), value.get("y", 0))
	if value is Array and value.size() >= 2:
		return Vector2i(value[0], value[1])
	return _parse_property_value(value)


func _coerce_to_vector3(value):
	if value is Vector3:
		return value
	if value is Dictionary:
		return Vector3(value.get("x", 0.0), value.get("y", 0.0), value.get("z", 0.0))
	if value is Array and value.size() >= 3:
		return Vector3(value[0], value[1], value[2])
	return _parse_property_value(value)


func _coerce_to_vector3i(value):
	if value is Vector3i:
		return value
	if value is Dictionary:
		return Vector3i(value.get("x", 0), value.get("y", 0), value.get("z", 0))
	if value is Array and value.size() >= 3:
		return Vector3i(value[0], value[1], value[2])
	return _parse_property_value(value)


func _coerce_to_vector4(value):
	if value is Vector4:
		return value
	if value is Dictionary:
		return Vector4(
			value.get("x", 0.0), value.get("y", 0.0), value.get("z", 0.0), value.get("w", 0.0)
		)
	if value is Array and value.size() >= 4:
		return Vector4(value[0], value[1], value[2], value[3])
	return _parse_property_value(value)


func _coerce_to_vector4i(value):
	if value is Vector4i:
		return value
	if value is Dictionary:
		return Vector4i(value.get("x", 0), value.get("y", 0), value.get("z", 0), value.get("w", 0))
	if value is Array and value.size() >= 4:
		return Vector4i(value[0], value[1], value[2], value[3])
	return _parse_property_value(value)


func _coerce_to_color(value):
	if value is Color:
		return value
	if value is Dictionary:
		return Color(
			value.get("r", 0.0), value.get("g", 0.0), value.get("b", 0.0), value.get("a", 1.0)
		)
	if value is Array and value.size() >= 3:
		var alpha := value[3] if value.size() >= 4 else 1.0
		return Color(value[0], value[1], value[2], alpha)
	return Color(value) if typeof(value) == TYPE_STRING else _parse_property_value(value)


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
	var existing_type := typeof(existing_value)
	if existing_type == TYPE_NIL:
		return new_value
	match existing_type:
		TYPE_BOOL:
			return bool(new_value)
		TYPE_INT:
			if typeof(new_value) == TYPE_STRING:
				return new_value.to_int()
			return int(new_value)
		TYPE_FLOAT:
			if typeof(new_value) == TYPE_STRING:
				return new_value.to_float()
			return float(new_value)
		TYPE_STRING:
			return str(new_value)
		TYPE_VECTOR2:
			return _coerce_to_vector2(new_value)
		TYPE_VECTOR2I:
			return _coerce_to_vector2i(new_value)
		TYPE_VECTOR3:
			return _coerce_to_vector3(new_value)
		TYPE_VECTOR3I:
			return _coerce_to_vector3i(new_value)
		TYPE_VECTOR4:
			return _coerce_to_vector4(new_value)
		TYPE_VECTOR4I:
			return _coerce_to_vector4i(new_value)
		TYPE_COLOR:
			return _coerce_to_color(new_value)
		TYPE_DICTIONARY, TYPE_ARRAY:
			return new_value
		TYPE_OBJECT:
			if typeof(new_value) == TYPE_STRING and new_value.begins_with("res://"):
				var resource = ResourceLoader.load(new_value)
				return resource if resource != null else new_value
			return new_value
		_:
			return new_value


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
			var previous_component
			match key:
				"x":
					previous_component = vector2_value.x
					vector2_value.x = float(new_value)
				"y":
					previous_component = vector2_value.y
					vector2_value.y = float(new_value)
				_:
					return {"ok": false, "error": "Unsupported Vector2 component: %s" % key}
			return {
				"ok": true,
				"value": vector2_value,
				"leaf_previous": previous_component,
				"leaf_value": vector2_value.get(key),
			}
		TYPE_VECTOR3:
			if remaining.size() > 0:
				return {"ok": false, "error": "Vector3 only supports single-level components"}
			var vector3_value: Vector3 = base_value
			var previous_vector3_component
			match key:
				"x":
					previous_vector3_component = vector3_value.x
					vector3_value.x = float(new_value)
				"y":
					previous_vector3_component = vector3_value.y
					vector3_value.y = float(new_value)
				"z":
					previous_vector3_component = vector3_value.z
					vector3_value.z = float(new_value)
				_:
					return {"ok": false, "error": "Unsupported Vector3 component: %s" % key}
			return {
				"ok": true,
				"value": vector3_value,
				"leaf_previous": previous_vector3_component,
				"leaf_value": vector3_value.get(key),
			}
		TYPE_VECTOR4:
			if remaining.size() > 0:
				return {"ok": false, "error": "Vector4 only supports single-level components"}
			var vector4_value: Vector4 = base_value
			var previous_vector4_component
			match key:
				"x":
					previous_vector4_component = vector4_value.x
					vector4_value.x = float(new_value)
				"y":
					previous_vector4_component = vector4_value.y
					vector4_value.y = float(new_value)
				"z":
					previous_vector4_component = vector4_value.z
					vector4_value.z = float(new_value)
				"w":
					previous_vector4_component = vector4_value.w
					vector4_value.w = float(new_value)
				_:
					return {"ok": false, "error": "Unsupported Vector4 component: %s" % key}
			return {
				"ok": true,
				"value": vector4_value,
				"leaf_previous": previous_vector4_component,
				"leaf_value": vector4_value.get(key),
			}
		TYPE_COLOR:
			if remaining.size() > 0:
				return {"ok": false, "error": "Color only supports single-level components"}
			var color_value: Color = base_value
			var previous_color_component
			match key:
				"r":
					previous_color_component = color_value.r
					color_value.r = float(new_value)
				"g":
					previous_color_component = color_value.g
					color_value.g = float(new_value)
				"b":
					previous_color_component = color_value.b
					color_value.b = float(new_value)
				"a":
					previous_color_component = color_value.a
					color_value.a = float(new_value)
				_:
					return {"ok": false, "error": "Unsupported Color component: %s" % key}
			return {
				"ok": true,
				"value": color_value,
				"leaf_previous": previous_color_component,
				"leaf_value": color_value.get(key),
			}
		_:
			return {
				"ok": false,
				"error": "Unsupported property path segment on type %s" % typeof(base_value)
			}
