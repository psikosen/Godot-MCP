@tool
class_name MCPSceneCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager
const LOG_FILENAME := "addons/godot_mcp/commands/scene_commands.gd"
const DEFAULT_SYSTEM_SECTION := "scene_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"save_scene":
			_save_scene(client_id, params, command_id)
			return true
		"open_scene":
			_open_scene(client_id, params, command_id)
			return true
		"get_current_scene":
			_get_current_scene(client_id, params, command_id)
			return true
		"get_scene_structure":
			_get_scene_structure(client_id, params, command_id)
			return true
                "create_scene":
                        _create_scene(client_id, params, command_id)
                        return true
                "begin_scene_transaction":
                        _begin_scene_transaction(client_id, params, command_id)
                        return true
                "commit_scene_transaction":
                        _commit_scene_transaction(client_id, params, command_id)
                        return true
                "rollback_scene_transaction":
                        _rollback_scene_transaction(client_id, params, command_id)
                        return true
                "list_scene_transactions":
                        _list_scene_transactions(client_id, params, command_id)
                        return true
		"configure_physics_body":
			_configure_physics_body(client_id, params, command_id)
			return true
		"configure_physics_area":
			_configure_physics_area(client_id, params, command_id)
			return true
		"configure_physics_joint":
			_configure_physics_joint(client_id, params, command_id)
			return true
        return false  # Command not handled

func _save_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var path = params.get("path", "")
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	
	# If no path provided, use the current scene path
	if path.is_empty() and edited_scene_root:
		path = edited_scene_root.scene_file_path
	
	# Validation
	if path.is_empty():
		return _send_error(client_id, "Scene path cannot be empty", command_id)
	
	# Make sure we have an absolute path
	if not path.begins_with("res://"):
		path = "res://" + path
	
	if not path.ends_with(".tscn"):
		path += ".tscn"
	
	# Check if we have an edited scene
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)
	
	# Save the scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(edited_scene_root)
	if result != OK:
		return _send_error(client_id, "Failed to pack scene: %d" % result, command_id)
	
	result = ResourceSaver.save(packed_scene, path)
	if result != OK:
		return _send_error(client_id, "Failed to save scene: %d" % result, command_id)
	
	_send_success(client_id, {
		"scene_path": path
	}, command_id)

func _open_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var path = params.get("path", "")
	
	# Validation
	if path.is_empty():
		return _send_error(client_id, "Scene path cannot be empty", command_id)
	
	# Make sure we have an absolute path
	if not path.begins_with("res://"):
		path = "res://" + path
	
	# Check if the file exists
	if not FileAccess.file_exists(path):
		return _send_error(client_id, "Scene file not found: %s" % path, command_id)
	
	# Since we can't directly open scenes in tool scripts,
	# we need to defer to the plugin which has access to EditorInterface
	var plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
	
	if plugin and plugin.has_method("get_editor_interface"):
		var editor_interface = plugin.get_editor_interface()
		editor_interface.open_scene_from_path(path)
		_send_success(client_id, {
			"scene_path": path
		}, command_id)
	else:
		_send_error(client_id, "Cannot access EditorInterface. Please open the scene manually: %s" % path, command_id)

func _get_current_scene(client_id: int, _params: Dictionary, command_id: String) -> void:
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	
	if not edited_scene_root:
		print("No scene is currently being edited")
		# Instead of returning an error, return a valid response with empty/default values
		_send_success(client_id, {
			"scene_path": "None",
			"root_node_type": "None",
			"root_node_name": "None"
		}, command_id)
		return
	
	var scene_path = edited_scene_root.scene_file_path
	if scene_path.is_empty():
		scene_path = "Untitled"
	
	print("Current scene path: ", scene_path)
	print("Root node type: ", edited_scene_root.get_class())
	print("Root node name: ", edited_scene_root.name)
	
	_send_success(client_id, {
		"scene_path": scene_path,
		"root_node_type": edited_scene_root.get_class(),
		"root_node_name": edited_scene_root.name
	}, command_id)

func _get_scene_structure(client_id: int, params: Dictionary, command_id: String) -> void:
	var path = params.get("path", "")
	
	# Validation
	if path.is_empty():
		return _send_error(client_id, "Scene path cannot be empty", command_id)
	
	if not path.begins_with("res://"):
		path = "res://" + path
	
	if not FileAccess.file_exists(path):
		return _send_error(client_id, "Scene file not found: " + path, command_id)
	
	# Load the scene to analyze its structure
	var packed_scene = load(path)
	if not packed_scene:
		return _send_error(client_id, "Failed to load scene: " + path, command_id)
	
	# Create a temporary instance to analyze
	var scene_instance = packed_scene.instantiate()
	if not scene_instance:
		return _send_error(client_id, "Failed to instantiate scene: " + path, command_id)
	
	# Get the scene structure
	var structure = _get_node_structure(scene_instance)
	
	# Clean up the temporary instance
	scene_instance.queue_free()
	
	# Return the structure
	_send_success(client_id, {
		"path": path,
		"structure": structure
	}, command_id)

func _get_node_structure(node: Node) -> Dictionary:
	var structure = {
		"name": node.name,
		"type": node.get_class(),
		"path": node.get_path()
	}
	
	# Get script information
	var script = node.get_script()
	if script:
		structure["script"] = script.resource_path
	
	# Get important properties
	var properties = {}
	var property_list = node.get_property_list()
	
	for prop in property_list:
		var name = prop["name"]
		# Filter to include only the most useful properties
		if not name.begins_with("_") and name not in ["script", "children", "position", "rotation", "scale"]:
			continue
		
		# Skip properties that are default values
		if name == "position" and node.position == Vector2():
			continue
		if name == "rotation" and node.rotation == 0:
			continue
		if name == "scale" and node.scale == Vector2(1, 1):
			continue
		
		properties[name] = node.get(name)
	
	structure["properties"] = properties
	
	# Get children
	var children = []
	for child in node.get_children():
		children.append(_get_node_structure(child))
	
	structure["children"] = children
	
	return structure

func _create_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var path = params.get("path", "")
	var root_node_type = params.get("root_node_type", "Node")
	
	# Validation
	if path.is_empty():
		return _send_error(client_id, "Scene path cannot be empty", command_id)
	
	# Make sure we have an absolute path
	if not path.begins_with("res://"):
		path = "res://" + path
	
	# Ensure path ends with .tscn
	if not path.ends_with(".tscn"):
		path += ".tscn"
	
	# Create directory structure if it doesn't exist
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var dir = DirAccess.open("res://")
		if dir:
			dir.make_dir_recursive(dir_path.trim_prefix("res://"))
	
	# Check if file already exists
	if FileAccess.file_exists(path):
		return _send_error(client_id, "Scene file already exists: %s" % path, command_id)
	
	# Create the root node of the specified type
	var root_node = null
	
	match root_node_type:
		"Node":
			root_node = Node.new()
		"Node2D":
			root_node = Node2D.new()
		"Node3D", "Spatial":
			root_node = Node3D.new()
		"Control":
			root_node = Control.new()
		"CanvasLayer":
			root_node = CanvasLayer.new()
		"Panel":
			root_node = Panel.new()
		_:
			# Attempt to create a custom class if built-in type not recognized
			if ClassDB.class_exists(root_node_type):
				root_node = ClassDB.instantiate(root_node_type)
			else:
				return _send_error(client_id, "Invalid root node type: %s" % root_node_type, command_id)
	
	# Give the root node a name based on the file name
	var file_name = path.get_file().get_basename()
	root_node.name = file_name
	
	# Create a packed scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(root_node)
	if result != OK:
		root_node.free()
		return _send_error(client_id, "Failed to pack scene: %d" % result, command_id)
	
	# Save the packed scene to disk
	result = ResourceSaver.save(packed_scene, path)
	if result != OK:
		root_node.free()
		return _send_error(client_id, "Failed to save scene: %d" % result, command_id)
	
	# Clean up
	root_node.free()
	
	# Try to open the scene in the editor
	var plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
	if plugin and plugin.has_method("get_editor_interface"):
		var editor_interface = plugin.get_editor_interface()
		editor_interface.open_scene_from_path(path)
	
        _send_success(client_id, {
                "scene_path": path,
                "root_node_type": root_node_type
        }, command_id)

func _begin_scene_transaction(client_id: int, params: Dictionary, command_id: String) -> void:
        var transaction_id = params.get("transaction_id", "")
        var action_name = params.get("action_name", "Scene Transaction")
        var metadata_param = params.get("metadata", {})

        var metadata := {}
        if typeof(metadata_param) == TYPE_DICTIONARY:
                metadata = metadata_param.duplicate(true)

        metadata["client_id"] = client_id
        metadata["command_id"] = command_id
        metadata["command"] = "begin_scene_transaction"

        var transaction = SceneTransactionManager.begin_registered(transaction_id, action_name, metadata)
        if not transaction:
                return _send_error(client_id, "Unable to begin scene transaction", command_id)

        _send_success(client_id, {
                "transaction_id": transaction.transaction_id,
                "action_name": action_name
        }, command_id)

func _commit_scene_transaction(client_id: int, params: Dictionary, command_id: String) -> void:
        var transaction_id = params.get("transaction_id", "")
        if transaction_id.is_empty():
                return _send_error(client_id, "Transaction ID is required to commit", command_id)

        var result = SceneTransactionManager.commit_registered(transaction_id)
        if not result:
                return _send_error(client_id, "Failed to commit scene transaction: %s" % transaction_id, command_id)

        _send_success(client_id, {
                "transaction_id": transaction_id,
                "status": "committed"
        }, command_id)

func _rollback_scene_transaction(client_id: int, params: Dictionary, command_id: String) -> void:
        var transaction_id = params.get("transaction_id", "")
        if transaction_id.is_empty():
                return _send_error(client_id, "Transaction ID is required to rollback", command_id)

        var result = SceneTransactionManager.rollback_registered(transaction_id)
        if not result:
                return _send_error(client_id, "Failed to rollback scene transaction: %s" % transaction_id, command_id)

        _send_success(client_id, {
                "transaction_id": transaction_id,
                "status": "rolled_back"
        }, command_id)

func _list_scene_transactions(client_id: int, _params: Dictionary, command_id: String) -> void:
        var transactions = SceneTransactionManager.list_transactions()
        _send_success(client_id, {
                "transactions": transactions
        }, command_id)

func _configure_physics_body(client_id: int, params: Dictionary, command_id: String) -> void:
	_configure_physics_node(
		client_id,
		params,
		command_id,
		"body",
		"Configure Physics Body",
		"configure_physics_body",
		"_configure_physics_body"
	)

func _configure_physics_area(client_id: int, params: Dictionary, command_id: String) -> void:
	_configure_physics_node(
		client_id,
		params,
		command_id,
		"area",
		"Configure Physics Area",
		"configure_physics_area",
		"_configure_physics_area"
	)

func _configure_physics_joint(client_id: int, params: Dictionary, command_id: String) -> void:
	_configure_physics_node(
		client_id,
		params,
		command_id,
		"joint",
		"Configure Physics Joint",
		"configure_physics_joint",
		"_configure_physics_joint"
	)

func _configure_physics_node(
	client_id: int,
	params: Dictionary,
	command_id: String,
	expected_category: String,
	action_name: String,
	command_identifier: String,
	function_name: String
) -> void:
	var node_path := String(params.get("node_path", ""))
	var properties_param = params.get("properties", {})
	var transaction_id := String(params.get("transaction_id", ""))

	if node_path.is_empty():
		_log("Node path cannot be empty", function_name, {"command": command_identifier, "client_id": client_id}, true)
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if typeof(properties_param) != TYPE_DICTIONARY:
		_log(
			"Physics configuration requires a dictionary of properties",
			function_name,
			{"command": command_identifier, "client_id": client_id, "node_path": node_path},
			true
		)
		return _send_error(client_id, "Physics configuration requires a dictionary of properties", command_id)

	var properties: Dictionary = properties_param.duplicate(true)
	if properties.is_empty():
		_log(
			"No properties provided for physics configuration",
			function_name,
			{"command": command_identifier, "client_id": client_id, "node_path": node_path},
			true
		)
		return _send_error(client_id, "No properties provided for physics configuration", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		_log(
			"Target node not found",
			function_name,
			{"command": command_identifier, "client_id": client_id, "node_path": node_path},
			true
		)
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var classification := _classify_physics_node(node)
	if classification.is_empty() or classification.get("category", "") != expected_category:
		_log(
			"Node is not a supported %s" % expected_category,
			function_name,
			{
				"command": command_identifier,
				"client_id": client_id,
				"node_path": node_path,
				"node_type": node.get_class(),
			},
			true
		)
		return _send_error(client_id, "Node at path is not a physics %s" % expected_category, command_id)

	var transaction_metadata := {
		"command": command_identifier,
		"node_path": node_path,
		"category": expected_category,
		"client_id": client_id,
		"command_id": command_id,
		"dimension": classification.get("dimension", "unknown"),
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline(action_name, transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, action_name, transaction_metadata)

	if not transaction:
		_log(
			"Failed to obtain scene transaction for physics configuration",
			function_name,
			{
				"command": command_identifier,
				"client_id": client_id,
				"node_path": node_path,
				"transaction_id": transaction_id,
			},
			true
		)
		return _send_error(client_id, "Failed to obtain scene transaction for physics configuration", command_id)

	var property_changes: Array = []
	for property_name in properties.keys():
		if not property_name in node:
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"Node is missing requested property",
				function_name,
				{
					"command": command_identifier,
					"client_id": client_id,
					"node_path": node_path,
					"property": property_name,
				},
				true
			)
			return _send_error(client_id, "Node does not have property: %s" % property_name, command_id)

		var raw_value = properties[property_name]
		var parsed_value = _parse_property_value(raw_value)
		var old_value = node.get(property_name)
		var coerced_value = _coerce_property_value(old_value, parsed_value)

		if old_value == coerced_value:
			continue

		property_changes.append({
			"property": property_name,
			"input_value": raw_value,
			"parsed_value": parsed_value,
			"new_value": coerced_value,
			"old_value": old_value,
		})

	for change in property_changes:
		transaction.add_do_property(node, change["property"], change["new_value"])
		transaction.add_undo_property(node, change["property"], change["old_value"])

	var serialized_changes: Array = []
	for change in property_changes:
		serialized_changes.append({
			"property": change["property"],
			"input_value": change["input_value"],
			"new_value": str(change["new_value"]),
			"new_type": Variant.get_type_name(typeof(change["new_value"])),
			"old_value": str(change["old_value"]),
			"old_type": Variant.get_type_name(typeof(change["old_value"])),
		})

	var log_payload := {
		"command": command_identifier,
		"node_path": node_path,
		"node_type": node.get_class(),
		"dimension": classification.get("dimension", "unknown"),
		"change_count": serialized_changes.size(),
		"transaction_id": transaction.transaction_id,
		"category": expected_category,
	}

	var commit_changes := []
	for change in serialized_changes:
		commit_changes.append(change.duplicate(true))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Committed physics configuration", function_name, payload)
	)

	transaction.register_on_rollback(func():
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Rolled back physics configuration", function_name, payload)
	)

	if property_changes.is_empty():
		if transaction_id.is_empty():
			transaction.rollback()
		_log("No physics property changes were required", function_name, log_payload)
		return _send_success(client_id, {
			"node_path": node_path,
			"node_type": node.get_class(),
			"dimension": classification.get("dimension", "unknown"),
			"changes": [],
			"transaction_id": transaction.transaction_id,
			"status": "no_changes",
		}, command_id)

	var status := "pending"
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log(
				"Failed to commit physics configuration",
				function_name,
				log_payload,
				true
			)
			return _send_error(client_id, "Failed to commit physics configuration", command_id)
		status = "committed"

	_send_success(client_id, {
		"node_path": node_path,
		"node_type": node.get_class(),
		"dimension": classification.get("dimension", "unknown"),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
		"status": status,
	}, command_id)

func _classify_physics_node(node: Node) -> Dictionary:
	if node is PhysicsBody2D:
		return {"category": "body", "dimension": "2d"}
	if node is PhysicsBody3D:
		return {"category": "body", "dimension": "3d"}
	if node is Area2D:
		return {"category": "area", "dimension": "2d"}
	if node is Area3D:
		return {"category": "area", "dimension": "3d"}
	if node is Joint2D:
		return {"category": "joint", "dimension": "2d"}
	if node is Joint3D:
		return {"category": "joint", "dimension": "3d"}
	return {}

func _coerce_property_value(old_value, new_value):
	var target_type := typeof(old_value)
	match target_type:
		TYPE_BOOL:
			return _convert_to_bool(new_value, old_value)
		TYPE_INT:
			return _convert_to_int(new_value, old_value)
		TYPE_FLOAT:
			return _convert_to_float(new_value, old_value)
		TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I:
			return new_value
		TYPE_NODE_PATH:
			if typeof(new_value) == TYPE_STRING:
				return NodePath(new_value)
			return new_value
		_:
			return new_value

func _convert_to_bool(value, fallback):
	if typeof(value) == TYPE_BOOL:
		return value
	if typeof(value) == TYPE_INT:
		return value != 0
	if typeof(value) == TYPE_FLOAT:
		return value != 0.0
	if typeof(value) == TYPE_STRING:
		var normalized := value.strip_edges().to_lower()
		if ["true", "1", "yes", "on"].has(normalized):
			return true
		if ["false", "0", "no", "off"].has(normalized):
			return false
	return fallback

func _convert_to_int(value, fallback):
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return value ? 1 : 0
		TYPE_STRING:
			return int(value)
		_:
			return fallback

func _convert_to_float(value, fallback):
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(value)
		TYPE_BOOL:
			return value ? 1.0 : 0.0
		TYPE_STRING:
			return float(value)
		_:
			return fallback

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPSceneCommands",
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
