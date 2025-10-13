@tool
class_name MCPSceneCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager
const LOG_FILENAME := "addons/godot_mcp/commands/scene_commands.gd"
const DEFAULT_SYSTEM_SECTION := "scene_commands"

const PHYSICS_BODY_PROPERTY_CANDIDATES := [
	"mass",
	"inertia",
	"center_of_mass",
	"center_of_mass_mode",
	"gravity_scale",
	"linear_velocity",
	"angular_velocity",
	"velocity",
	"constant_force",
	"constant_torque",
	"body_mode",
	"custom_integrator",
	"can_sleep",
	"sleeping",
	"lock_rotation",
	"freeze",
	"freeze_mode",
	"axis_lock_linear_x",
	"axis_lock_linear_y",
	"axis_lock_linear_z",
	"axis_lock_angular_x",
	"axis_lock_angular_y",
	"axis_lock_angular_z",
	"max_contacts_reported",
	"contact_monitor",
	"continuous_cd",
	"safe_margin",
]

const PHYSICS_AREA_PROPERTY_CANDIDATES := [
	"monitorable",
	"monitoring",
	"gravity",
	"gravity_vector",
	"gravity_is_point",
	"gravity_space_override",
	"priority",
	"angular_damp",
	"linear_damp",
	"space_override_mode",
	"audio_bus_override",
	"audio_bus_name",
]

const PHYSICS_JOINT_PROPERTY_CANDIDATES := [
	"node_a",
	"node_b",
	"bias",
	"disable_collisions",
	"max_force",
	"solver_priority",
	"solver_velocity_iterations",
	"solver_position_iterations",
]

const AUDIO_STREAM_PLAYER_TYPES := [
	"AudioStreamPlayer",
	"AudioStreamPlayer2D",
	"AudioStreamPlayer3D",
	"AudioStreamPlayerMicrophone",
]

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
		"get_physics_world_snapshot":
			_get_physics_world_snapshot(client_id, params, command_id)
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
		"link_joint_bodies":
			_link_joint_bodies(client_id, params, command_id)
			return true
		"rebuild_physics_shapes":
			_rebuild_physics_shapes(client_id, params, command_id)
			return true
		"profile_physics_step":
			_profile_physics_step(client_id, params, command_id)
			return true
		"author_audio_stream_player":
			_author_audio_stream_player(client_id, params, command_id)
			return true
		"author_interactive_music_graph":
			_author_interactive_music_graph(client_id, params, command_id)
			return true
		"generate_dynamic_music_layer":
			_generate_dynamic_music_layer(client_id, params, command_id)
			return true
		"analyze_waveform":
			_analyze_waveform(client_id, params, command_id)
			return true
		"batch_import_audio_assets":
			_batch_import_audio_assets(client_id, params, command_id)
			return true
		"configure_csg_shape":
			_configure_csg_shape(client_id, params, command_id)
			return true
		"configure_material_resource":
			_configure_material_resource(client_id, params, command_id)
			return true
		"paint_gridmap_cells":
			_paint_gridmap_cells(client_id, params, command_id)
			return true
"clear_gridmap_cells":
_clear_gridmap_cells(client_id, params, command_id)
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

func _get_physics_world_snapshot(client_id: int, _params: Dictionary, command_id: String) -> void:
	var function_name := "_get_physics_world_snapshot"
	var log_context := {
		"system_section": "scene_commands.physics_snapshot",
		"method": "GET",
	}

	var plugin = Engine.has_meta("GodotMCPPlugin") ? Engine.get_meta("GodotMCPPlugin") : null
	if not plugin:
		_log("GodotMCPPlugin not found while capturing physics world snapshot", function_name, log_context, true)
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()

	var snapshot := _build_physics_world_snapshot(edited_scene_root)
	var counts: Dictionary = snapshot.get("counts", {})
	var overall: Dictionary = counts.get("overall", {
		"spaces": 0,
		"bodies": 0,
		"areas": 0,
		"joints": 0,
	})

	if edited_scene_root == null:
		_log("No edited scene available; returning empty physics world snapshot", function_name, log_context)
	else:
		var scene_label := String(snapshot.get("scene_path", "EditedScene"))
		var space_total := int(overall.get("spaces", 0))
		var body_total := int(overall.get("bodies", 0))
		var area_total := int(overall.get("areas", 0))
		var joint_total := int(overall.get("joints", 0))
		_log("Captured physics world snapshot for %s (%d spaces, %d bodies, %d areas, %d joints)" % [
			scene_label,
			space_total,
			body_total,
			area_total,
			joint_total,
		], function_name, log_context)

	_send_success(client_id, snapshot, command_id)

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

func _build_physics_world_snapshot(root: Node) -> Dictionary:
	var timestamp := Time.get_datetime_string_from_system(true, true)
	var counts := {
		"2d": {"spaces": 0, "bodies": 0, "areas": 0, "joints": 0},
		"3d": {"spaces": 0, "bodies": 0, "areas": 0, "joints": 0},
	}
	var spaces_2d := {}
	var spaces_3d := {}

	if root == null:
		return {
			"scene_path": "None",
			"scene_name": "",
			"captured_at": timestamp,
			"spaces": {
				"2d": [],
				"3d": [],
			},
			"counts": {
				"2d": counts["2d"],
				"3d": counts["3d"],
				"overall": {
					"spaces": 0,
					"bodies": 0,
					"areas": 0,
					"joints": 0,
				},
			},
			"notes": ["No scene is currently open in the editor."],
		}

	var notes: Array = []
	var queue: Array = [root]
	while queue.size() > 0:
		var current: Node = queue.pop_front()
		for child in current.get_children():
			queue.push_back(child)

		if not current.is_inside_tree():
			continue

		var classification := _classify_physics_node(current)
		if classification.is_empty():
			continue

		var dimension := String(classification.get("dimension", ""))
		var category := String(classification.get("category", ""))
		if dimension.is_empty() or category.is_empty():
			continue

		var counts_ref: Dictionary = counts[dimension]
		var space_map = dimension == "2d" ? spaces_2d : spaces_3d
		var space_entry := _ensure_physics_space_entry(space_map, dimension, current, counts_ref)
		var entry := {}

		match category:
			"body":
				entry = _serialize_physics_body(current)
			"area":
				entry = _serialize_physics_area(current)
			"joint":
				entry = _serialize_physics_joint(current)
			_:
				entry = {}

		if entry.is_empty():
			continue

		entry["category"] = category
		entry["dimension"] = dimension
		entry["space_id"] = space_entry.get("space_id", "%s::unknown" % dimension)
		entry["space_label"] = space_entry.get("label", entry["space_id"])
		entry["space_rid"] = space_entry.get("space_rid", _serialize_rid(RID()))

		match category:
			"body":
				counts_ref["bodies"] = counts_ref.get("bodies", 0) + 1
				space_entry["bodies"].append(entry)
			"area":
				counts_ref["areas"] = counts_ref.get("areas", 0) + 1
				space_entry["areas"].append(entry)
			"joint":
				counts_ref["joints"] = counts_ref.get("joints", 0) + 1
				space_entry["joints"].append(entry)

	var spaces := {
		"2d": _physics_space_map_to_array(spaces_2d),
		"3d": _physics_space_map_to_array(spaces_3d),
	}

	var overall := {
		"spaces": counts["2d"].get("spaces", 0) + counts["3d"].get("spaces", 0),
		"bodies": counts["2d"].get("bodies", 0) + counts["3d"].get("bodies", 0),
		"areas": counts["2d"].get("areas", 0) + counts["3d"].get("areas", 0),
		"joints": counts["2d"].get("joints", 0) + counts["3d"].get("joints", 0),
	}

	var scene_path := String(root.scene_file_path)
	if scene_path.is_empty():
		scene_path = String(root.get_path())
		notes.append("Edited scene has not been saved to disk yet.")

	var snapshot := {
		"scene_path": scene_path,
		"scene_name": root.name,
		"captured_at": timestamp,
		"spaces": spaces,
		"counts": {
			"2d": counts["2d"],
			"3d": counts["3d"],
			"overall": overall,
		},
	}

	if notes.size() > 0:
		snapshot["notes"] = notes

	return snapshot

func _ensure_physics_space_entry(space_map: Dictionary, dimension: String, node: Node, counts: Dictionary) -> Dictionary:
	var space_rid := _extract_space_rid(node, dimension)
	var space_id := _space_identifier_from_rid(space_rid, dimension)

	if space_map.has(space_id):
		return space_map[space_id]

	var numeric_id := space_rid.is_valid() ? str(space_rid.get_id()) : "unassigned"
	var label := "%s Space %s" % [dimension.to_upper(), numeric_id]
	if numeric_id == "unassigned":
		label = "%s Space (unassigned)" % dimension.to_upper()

	var gravity_info := _get_space_gravity_info(dimension, space_rid)

	var entry := {
		"space_id": space_id,
		"space_numeric_id": numeric_id,
		"dimension": dimension,
		"label": label,
		"space_rid": _serialize_rid(space_rid),
		"gravity": gravity_info.get("magnitude"),
		"gravity_vector": gravity_info.get("vector"),
		"linear_damp": gravity_info.get("linear_damp"),
		"angular_damp": gravity_info.get("angular_damp"),
		"active": gravity_info.get("active", false),
		"bodies": [],
		"areas": [],
		"joints": [],
	}

	if not space_rid.is_valid():
		entry["notes"] = ["Nodes grouped here are not associated with an active physics space."]

	space_map[space_id] = _prune_null_fields(entry)
	counts["spaces"] = counts.get("spaces", 0) + 1
	return space_map[space_id]

func _extract_space_rid(node: Node, dimension: String) -> RID:
	var rid := RID()

	if dimension == "2d" and node is Node2D:
		var world_2d = node.get_world_2d()
		if world_2d:
			rid = world_2d.space
	elif dimension == "3d" and node is Node3D:
		var world_3d = node.get_world_3d()
		if world_3d:
			rid = world_3d.space

	return rid

func _space_identifier_from_rid(space_rid: RID, dimension: String) -> String:
	if space_rid.is_valid():
		return "%s::%s" % [dimension, str(space_rid.get_id())]
	return "%s::unassigned" % dimension

func _serialize_rid(rid: RID) -> Dictionary:
	var info := {
		"rid": str(rid),
		"valid": rid.is_valid(),
	}

	if rid.is_valid():
		info["id"] = rid.get_id()

	return info

func _get_space_gravity_info(dimension: String, space_rid: RID) -> Dictionary:
	var info := {
		"magnitude": null,
		"vector": null,
		"linear_damp": null,
		"angular_damp": null,
		"active": false,
	}

	if not space_rid.is_valid():
		return info

	if dimension == "2d":
		info["magnitude"] = PhysicsServer2D.space_get_param(space_rid, PhysicsServer2D.SPACE_PARAM_GRAVITY)
		info["vector"] = _serialize_variant(PhysicsServer2D.space_get_param(space_rid, PhysicsServer2D.SPACE_PARAM_GRAVITY_VECTOR))
		info["linear_damp"] = PhysicsServer2D.space_get_param(space_rid, PhysicsServer2D.SPACE_PARAM_LINEAR_DAMP)
		info["angular_damp"] = PhysicsServer2D.space_get_param(space_rid, PhysicsServer2D.SPACE_PARAM_ANGULAR_DAMP)
		info["active"] = PhysicsServer2D.space_is_active(space_rid)
	else:
		info["magnitude"] = PhysicsServer3D.space_get_param(space_rid, PhysicsServer3D.SPACE_PARAM_GRAVITY)
		info["vector"] = _serialize_variant(PhysicsServer3D.space_get_param(space_rid, PhysicsServer3D.SPACE_PARAM_GRAVITY_VECTOR))
		info["linear_damp"] = PhysicsServer3D.space_get_param(space_rid, PhysicsServer3D.SPACE_PARAM_LINEAR_DAMP)
		info["angular_damp"] = PhysicsServer3D.space_get_param(space_rid, PhysicsServer3D.SPACE_PARAM_ANGULAR_DAMP)
		info["active"] = PhysicsServer3D.space_is_active(space_rid)

	return info

func _collect_common_physics_node(node: Node) -> Dictionary:
	var data := {
		"name": node.name,
		"class": node.get_class(),
		"path": _node_path_to_string(node, node.name),
	}

	if node.owner:
		var owner_path := _node_path_to_string(node.owner, "")
		if not owner_path.is_empty():
			data["owner"] = owner_path

	var groups: Array = []
	for group_name in node.get_groups():
		groups.append(String(group_name))
	if groups.size() > 0:
		data["groups"] = groups

	if not node.scene_file_path.is_empty():
		data["scene_file_path"] = node.scene_file_path

	if node.has_method("get_script"):
		var script = node.get_script()
		if script and script is Resource:
			var resource: Resource = script
			var script_info := {
				"resource_type": resource.get_class(),
			}
			if not resource.resource_path.is_empty():
				script_info["resource_path"] = resource.resource_path
			data["script"] = script_info

	if node.has_method("is_physics_processing"):
		data["physics_processing"] = node.is_physics_processing()

	return data

func _serialize_physics_body(node: Node) -> Dictionary:
	var data := _collect_common_physics_node(node)

	if node.has_method("get_rid"):
		data["rid"] = _serialize_rid(node.get_rid())

	if _has_property(node, "collision_layer"):
		data["collision_layer"] = node.get("collision_layer")
	if _has_property(node, "collision_mask"):
		data["collision_mask"] = node.get("collision_mask")

	var material_override = _get_property_if_exists(node, "physics_material_override")
	if material_override != null:
		data["physics_material_override"] = material_override

	for property_name in PHYSICS_BODY_PROPERTY_CANDIDATES:
		var value = _get_property_if_exists(node, property_name)
		if value != null:
			data[property_name] = value

	return _prune_null_fields(data)

func _serialize_physics_area(node: Node) -> Dictionary:
	var data := _collect_common_physics_node(node)

	if node.has_method("get_rid"):
		data["rid"] = _serialize_rid(node.get_rid())

	if _has_property(node, "collision_layer"):
		data["collision_layer"] = node.get("collision_layer")
	if _has_property(node, "collision_mask"):
		data["collision_mask"] = node.get("collision_mask")

	for property_name in PHYSICS_AREA_PROPERTY_CANDIDATES:
		var value = _get_property_if_exists(node, property_name)
		if value != null:
			data[property_name] = value

	return _prune_null_fields(data)

func _serialize_physics_joint(node: Node) -> Dictionary:
	var data := _collect_common_physics_node(node)

	if node.has_method("get_rid"):
		data["rid"] = _serialize_rid(node.get_rid())

	for property_name in PHYSICS_JOINT_PROPERTY_CANDIDATES:
		var value = _get_property_if_exists(node, property_name)
		if value != null:
			data[property_name] = value

	return _prune_null_fields(data)

func _get_property_if_exists(target: Object, property_name: String):
	if target == null:
		return null

	if _has_property(target, property_name):
		return _serialize_variant(target.get(property_name))

	return null

func _serialize_variant(value):
	match typeof(value):
		TYPE_NIL:
			return null
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT:
			return value
		TYPE_STRING, TYPE_STRING_NAME:
			return String(value)
		TYPE_VECTOR2:
			var vector2: Vector2 = value
			return {"x": vector2.x, "y": vector2.y}
		TYPE_VECTOR2I:
			var vector2i: Vector2i = value
			return {"x": vector2i.x, "y": vector2i.y}
		TYPE_VECTOR3:
			var vector3: Vector3 = value
			return {"x": vector3.x, "y": vector3.y, "z": vector3.z}
		TYPE_VECTOR3I:
			var vector3i: Vector3i = value
			return {"x": vector3i.x, "y": vector3i.y, "z": vector3i.z}
		TYPE_VECTOR4:
			var vector4: Vector4 = value
			return {"x": vector4.x, "y": vector4.y, "z": vector4.z, "w": vector4.w}
		TYPE_VECTOR4I:
			var vector4i: Vector4i = value
			return {"x": vector4i.x, "y": vector4i.y, "z": vector4i.z, "w": vector4i.w}
		TYPE_RECT2:
			var rect2: Rect2 = value
			return {"position": _serialize_variant(rect2.position), "size": _serialize_variant(rect2.size)}
		TYPE_RECT2I:
			var rect2i: Rect2i = value
			return {"position": _serialize_variant(rect2i.position), "size": _serialize_variant(rect2i.size)}
		TYPE_COLOR:
			var color: Color = value
			return {"r": color.r, "g": color.g, "b": color.b, "a": color.a}
		TYPE_QUATERNION:
			var quat: Quaternion = value
			return {"x": quat.x, "y": quat.y, "z": quat.z, "w": quat.w}
		TYPE_NODE_PATH:
			return String(value)
		TYPE_RID:
			return _serialize_rid(value)
		TYPE_DICTIONARY:
			var dict_result := {}
			for key in value.keys():
				dict_result[key] = _serialize_variant(value[key])
			return dict_result
		TYPE_ARRAY:
			var array_result: Array = []
			for element in value:
				array_result.append(_serialize_variant(element))
			return array_result
		TYPE_PACKED_STRING_ARRAY:
			var packed_strings: PackedStringArray = value
			var string_array: Array = []
			for element in packed_strings:
				string_array.append(String(element))
			return string_array
		TYPE_PACKED_VECTOR2_ARRAY:
			var packed_vector2: PackedVector2Array = value
			var vector2_array: Array = []
			for element in packed_vector2:
				vector2_array.append(_serialize_variant(element))
			return vector2_array
		TYPE_PACKED_VECTOR3_ARRAY:
			var packed_vector3: PackedVector3Array = value
			var vector3_array: Array = []
			for element in packed_vector3:
				vector3_array.append(_serialize_variant(element))
			return vector3_array
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY:
			var packed_numeric_array: Array = []
			for element in value:
				packed_numeric_array.append(element)
			return packed_numeric_array
		TYPE_OBJECT:
			if value == null:
				return null
			if value is Resource:
				var resource: Resource = value
				var resource_info := {
					"resource_type": resource.get_class(),
				}
				if not resource.resource_path.is_empty():
					resource_info["resource_path"] = resource.resource_path
				return resource_info
			return value.get_class()
		TYPE_TRANSFORM2D, TYPE_TRANSFORM3D, TYPE_BASIS, TYPE_PLANE, TYPE_AABB, TYPE_PROJECTION:
			return String(value)
		TYPE_CALLABLE, TYPE_SIGNAL:
			return String(value)
		_:
			return String(value)

func _prune_null_fields(data: Dictionary) -> Dictionary:
	var cleaned := {}
	for key in data.keys():
		var value = data[key]
		if value == null:
			continue
		cleaned[key] = value
	return cleaned

func _physics_space_map_to_array(space_map: Dictionary) -> Array:
	var results: Array = []
	var keys := space_map.keys()
	keys.sort()

	for key in keys:
		var entry: Dictionary = space_map[key]
		entry["counts"] = {
			"bodies": entry.get("bodies", []).size(),
			"areas": entry.get("areas", []).size(),
			"joints": entry.get("joints", []).size(),
		}
		entry["bodies"] = _sort_snapshot_entries(entry.get("bodies", []))
		entry["areas"] = _sort_snapshot_entries(entry.get("areas", []))
		entry["joints"] = _sort_snapshot_entries(entry.get("joints", []))
		results.append(entry)

	return results

func _sort_snapshot_entries(entries: Array) -> Array:
	var sorted := entries.duplicate()
	sorted.sort_custom(Callable(self, "_compare_snapshot_entries"))
	return sorted

func _compare_snapshot_entries(a, b) -> bool:
	var path_a := String(a.get("path", ""))
	var path_b := String(b.get("path", ""))
	if path_a == path_b:
		var name_a := String(a.get("name", ""))
		var name_b := String(b.get("name", ""))
		return name_a < name_b
	return path_a < path_b

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

func _link_joint_bodies(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_link_joint_bodies"
	var joint_path := String(params.get("joint_path", ""))
	var transaction_id := String(params.get("transaction_id", ""))
	var context := {
		"command": "link_joint_bodies",
		"client_id": client_id,
		"joint_path": joint_path,
		"transaction_id": transaction_id,
	}

	if joint_path.is_empty():
		_log("Joint path cannot be empty", function_name, context, true)
		return _send_error(client_id, "Joint path cannot be empty", command_id)

	var joint = _get_editor_node(joint_path)
	if not joint:
		_log("Joint node not found", function_name, context, true)
		return _send_error(client_id, "Joint not found: %s" % joint_path, command_id)

	var classification := _classify_physics_node(joint)
	if classification.get("category", "") != "joint":
		context["joint_type"] = joint.get_class()
		_log("Requested node is not a physics joint", function_name, context, true)
		return _send_error(client_id, "Node at path is not a physics joint", command_id)

	context["dimension"] = classification.get("dimension", "unknown")

	var property_overrides: Dictionary = {}

	if params.has("body_a_path"):
		var body_a_path := String(params.get("body_a_path", ""))
		context["body_a_path"] = body_a_path

		if body_a_path.is_empty():
			property_overrides["node_a"] = NodePath("")
		else:
			var body_a = _get_editor_node(body_a_path)
			if not body_a:
				_log("Body A node not found", function_name, context, true)
				return _send_error(client_id, "Body A not found: %s" % body_a_path, command_id)

			if classification.get("dimension", "") == "2d" and not (body_a is PhysicsBody2D):
				context["body_a_type"] = body_a.get_class()
				_log("Body A is not a 2D physics body", function_name, context, true)
				return _send_error(client_id, "Body A must be a 2D physics body", command_id)

			if classification.get("dimension", "") == "3d" and not (body_a is PhysicsBody3D):
				context["body_a_type"] = body_a.get_class()
				_log("Body A is not a 3D physics body", function_name, context, true)
				return _send_error(client_id, "Body A must be a 3D physics body", command_id)

			var relative_path_a := joint.get_path_to(body_a)
			context["relative_body_a_path"] = str(relative_path_a)
			property_overrides["node_a"] = relative_path_a

	if params.has("body_b_path"):
		var body_b_path := String(params.get("body_b_path", ""))
		context["body_b_path"] = body_b_path

		if body_b_path.is_empty():
			property_overrides["node_b"] = NodePath("")
		else:
			var body_b = _get_editor_node(body_b_path)
			if not body_b:
				_log("Body B node not found", function_name, context, true)
				return _send_error(client_id, "Body B not found: %s" % body_b_path, command_id)

			if classification.get("dimension", "") == "2d" and not (body_b is PhysicsBody2D):
				context["body_b_type"] = body_b.get_class()
				_log("Body B is not a 2D physics body", function_name, context, true)
				return _send_error(client_id, "Body B must be a 2D physics body", command_id)

			if classification.get("dimension", "") == "3d" and not (body_b is PhysicsBody3D):
				context["body_b_type"] = body_b.get_class()
				_log("Body B is not a 3D physics body", function_name, context, true)
				return _send_error(client_id, "Body B must be a 3D physics body", command_id)

			var relative_path_b := joint.get_path_to(body_b)
			context["relative_body_b_path"] = str(relative_path_b)
			property_overrides["node_b"] = relative_path_b

	var additional_properties_param = params.get("properties", {})
	if params.has("properties") and typeof(additional_properties_param) != TYPE_DICTIONARY:
		context["properties_type"] = Variant.get_type_name(typeof(additional_properties_param))
		_log("Joint configuration expects a dictionary of properties", function_name, context, true)
		return _send_error(client_id, "Joint configuration expects a dictionary of properties", command_id)

	if typeof(additional_properties_param) == TYPE_DICTIONARY:
		var additional_properties: Dictionary = additional_properties_param.duplicate(true)
		for key in additional_properties.keys():
			property_overrides[key] = additional_properties[key]

	if property_overrides.is_empty():
		_log("No joint link updates were provided", function_name, context, true)
		return _send_error(client_id, "No joint link updates were provided", command_id)

	var config_params := {
		"node_path": joint_path,
		"transaction_id": transaction_id,
		"properties": property_overrides,
	}

	_configure_physics_node(
		client_id,
		config_params,
		command_id,
		"joint",
		"Link Joint Bodies",
		"link_joint_bodies",
		function_name
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



func _rebuild_physics_shapes(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_rebuild_physics_shapes"
	var node_path := String(params.get("node_path", ""))
	var mesh_node_path := String(params.get("mesh_node_path", ""))
	var mesh_resource_path := String(params.get("mesh_resource_path", ""))
	var shape_type := String(params.get("shape_type", "convex")).to_lower()
	var transaction_id := String(params.get("transaction_id", ""))

	var context := {
		"command": "rebuild_physics_shapes",
		"client_id": client_id,
		"node_path": node_path,
		"mesh_node_path": mesh_node_path,
		"mesh_resource_path": mesh_resource_path,
		"shape_type": shape_type,
		"transaction_id": transaction_id,
	}

	if node_path.is_empty():
		_log("Shape node path cannot be empty", function_name, context, true)
		return _send_error(client_id, "Shape node path cannot be empty", command_id)

	var shape_node = _get_editor_node(node_path)
	if not shape_node:
		_log("Shape node not found", function_name, context, true)
		return _send_error(client_id, "Shape node not found: %s" % node_path, command_id)

	if not (shape_node is CollisionShape3D):
		context["node_type"] = shape_node.get_class()
		_log(
			"Physics shape rebuild currently supports CollisionShape3D nodes",
			function_name,
			context,
			true
		)
		return _send_error(
			client_id,
			"Physics shape rebuild currently supports CollisionShape3D nodes",
			command_id
		)

	if shape_type != "convex" and shape_type != "trimesh":
		_log("Unsupported shape_type provided", function_name, context, true)
		return _send_error(client_id, "shape_type must be 'convex' or 'trimesh'", command_id)

	var mesh: Mesh = null
	var mesh_source := ""

	if not mesh_resource_path.is_empty():
		if ResourceLoader.exists(mesh_resource_path):
			var loaded = ResourceLoader.load(mesh_resource_path)
			if loaded is Mesh:
				mesh = loaded
				mesh_source = mesh_resource_path
			else:
				context["loaded_resource_type"] = loaded ? loaded.get_class() : "null"
				_log("Resource is not a Mesh", function_name, context, true)
				return _send_error(client_id, "Resource is not a Mesh: %s" % mesh_resource_path, command_id)
		else:
			_log("Mesh resource path not found", function_name, context, true)
			return _send_error(client_id, "Mesh resource not found: %s" % mesh_resource_path, command_id)

	if mesh == null and not mesh_node_path.is_empty():
		var mesh_node = _get_editor_node(mesh_node_path)
		if not mesh_node:
			_log("Mesh node path could not be resolved", function_name, context, true)
			return _send_error(client_id, "Mesh node not found: %s" % mesh_node_path, command_id)

		if _has_property(mesh_node, "mesh"):
			var candidate = mesh_node.get("mesh")
			if candidate is Mesh:
				mesh = candidate
				mesh_source = _node_path_to_string(mesh_node, mesh_node_path)
			else:
				context["candidate_type"] = candidate ? candidate.get_class() : "null"
				_log("Mesh node does not expose a Mesh resource", function_name, context, true)
				return _send_error(client_id, "Mesh node does not expose a Mesh resource", command_id)
		elif mesh_node is Mesh:
			mesh = mesh_node
			mesh_source = _node_path_to_string(mesh_node, mesh_node_path)
		else:
			context["mesh_node_type"] = mesh_node.get_class()
			_log("Mesh node is not compatible", function_name, context, true)
			return _send_error(client_id, "Mesh node is not compatible with shape rebuild", command_id)

	if mesh == null:
		var parent = shape_node.get_parent()
		if parent and _has_property(parent, "mesh"):
			var parent_mesh = parent.get("mesh")
			if parent_mesh is Mesh:
				mesh = parent_mesh
				mesh_source = _node_path_to_string(parent, "")

	if mesh == null:
		if shape_node.get_parent():
			context["parent_path"] = _node_path_to_string(shape_node.get_parent(), "")
		_log("Unable to resolve mesh for physics rebuild", function_name, context, true)
		return _send_error(client_id, "Unable to locate a Mesh resource to rebuild the shape", command_id)

	var new_shape: Shape3D = null
	if shape_type == "convex":
		new_shape = mesh.create_convex_shape()
	else:
		new_shape = mesh.create_trimesh_shape()

	if new_shape == null:
		context["mesh_surface_count"] = mesh.get_surface_count()
		_log("Mesh could not generate the requested shape", function_name, context, true)
		return _send_error(client_id, "Mesh could not generate the requested shape", command_id)

	var metadata := {
		"command": "rebuild_physics_shapes",
		"node_path": node_path,
		"shape_type": shape_type,
		"mesh_source": mesh_source,
		"client_id": client_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Rebuild Physics Shape", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(
				transaction_id,
				"Rebuild Physics Shape",
				metadata
			)

	if not transaction:
		_log("Failed to obtain scene transaction for physics shape rebuild", function_name, context, true)
		return _send_error(
			client_id,
			"Failed to obtain scene transaction for physics shape rebuild",
			command_id
		)

	var previous_shape = shape_node.shape
	transaction.add_do_property(shape_node, "shape", new_shape)
	transaction.add_undo_property(shape_node, "shape", previous_shape)
	transaction.add_do_reference(new_shape)

	var log_payload := metadata.duplicate(true)
	log_payload["shape_class"] = new_shape.get_class()
	log_payload["mesh_surface_count"] = mesh.get_surface_count()
	if previous_shape:
		log_payload["previous_shape_class"] = previous_shape.get_class()

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Rebuilt physics shape from mesh", function_name, log_payload)
	)

	transaction.register_on_rollback(func():
		_log("Rolled back physics shape rebuild", function_name, log_payload)
	)

	var status := "pending"
	if transaction_id.is_empty():
		if transaction.has_operations():
			if transaction.commit():
				status = "committed"
			else:
				transaction.rollback()
				_log("Failed to commit physics shape rebuild", function_name, log_payload, true)
				return _send_error(client_id, "Failed to commit physics shape rebuild", command_id)
		else:
			transaction.rollback()
			_log("No operations recorded for physics shape rebuild", function_name, log_payload)
			return _send_success(client_id, {
				"node_path": node_path,
				"shape_type": shape_type,
				"shape_class": new_shape.get_class(),
				"mesh_source": mesh_source,
				"transaction_id": transaction.transaction_id,
				"status": "no_changes",
			}, command_id)

	_send_success(client_id, {
		"node_path": node_path,
		"shape_type": shape_type,
		"shape_class": new_shape.get_class(),
		"mesh_source": mesh_source,
		"transaction_id": transaction.transaction_id,
		"status": status,
	}, command_id)



func _profile_physics_step(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_profile_physics_step"
	var include_2d := bool(params.get("include_2d", true))
	var include_3d := bool(params.get("include_3d", true))
	var include_performance := bool(params.get("include_performance", true))

	var snapshot := {
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"include_2d": include_2d,
		"include_3d": include_3d,
		"include_performance": include_performance,
	}

	if include_performance:
		var performance_metrics := {
			"time_physics_process": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
			"physics_2d_active_objects": Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
			"physics_2d_collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
			"physics_3d_active_objects": Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS),
			"physics_3d_collision_pairs": Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS),
		}
		snapshot["performance"] = performance_metrics

	if include_2d:
		var physics2d := {
			"active_objects": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_ACTIVE_OBJECTS),
			"active_islands": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_ACTIVE_ISLANDS),
			"active_constraints": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_ACTIVE_CONSTRAINTS),
			"island_count": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_ISLAND_COUNT),
			"step_count": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_STEP_COUNT),
			"broadphase_pairs": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_BROADPHASE_PAIRS),
			"broadphase_pair_attempts": PhysicsServer2D.get_process_info(PhysicsServer2D.PROCESS_INFO_BROADPHASE_PAIR_ATTEMPTS),
		}
		snapshot["physics_2d"] = physics2d

	if include_3d:
		var physics3d := {
			"active_objects": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_ACTIVE_OBJECTS),
			"active_islands": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_ACTIVE_ISLANDS),
			"active_constraints": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_ACTIVE_CONSTRAINTS),
			"island_count": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_ISLAND_COUNT),
			"step_count": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_STEP_COUNT),
			"broadphase_pairs": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_BROADPHASE_PAIRS),
			"broadphase_pair_attempts": PhysicsServer3D.get_process_info(PhysicsServer3D.PROCESS_INFO_BROADPHASE_PAIR_ATTEMPTS),
		}
		snapshot["physics_3d"] = physics3d

	_log("Captured physics profiling snapshot", function_name, snapshot)

	_send_success(client_id, snapshot, command_id)



func _author_audio_stream_player(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_author_audio_stream_player"
	var requested_node_path := String(params.get("node_path", ""))
	var parent_path := String(params.get("parent_path", ""))
	var player_name := String(params.get("player_name", ""))
	var player_type := String(params.get("player_type", "AudioStreamPlayer"))
	var transaction_id := String(params.get("transaction_id", ""))
	var provided_stream_path := String(params.get("stream_path", ""))
	var create_if_missing := bool(params.get("create_if_missing", requested_node_path.is_empty()))
	var properties_param = params.get("properties", {})

	if player_type.is_empty():
		player_type = "AudioStreamPlayer"

	if not ClassDB.class_exists(player_type):
		var context := {
			"command": "author_audio_stream_player",
			"player_type": player_type,
			"client_id": client_id,
			"command_id": command_id,
		}
		_log("Requested audio stream player type does not exist", function_name, context, true)
		return _send_error(client_id, "Unknown audio stream player type: %s" % player_type, command_id)

	if not ClassDB.is_parent_class("Node", player_type):
		var context := {
			"command": "author_audio_stream_player",
			"player_type": player_type,
			"client_id": client_id,
			"command_id": command_id,
		}
		_log("Audio stream player type does not inherit from Node", function_name, context, true)
		return _send_error(client_id, "Audio stream player type must inherit from Node", command_id)

	if not AUDIO_STREAM_PLAYER_TYPES.has(player_type) and not ClassDB.class_has_property(player_type, "stream"):
		var context := {
			"command": "author_audio_stream_player",
			"player_type": player_type,
			"client_id": client_id,
		}
		_log("Audio stream player type does not expose a stream property", function_name, context, true)
		return _send_error(client_id, "Audio stream player type must expose a `stream` property", command_id)

	var plugin = Engine.has_meta("GodotMCPPlugin") ? Engine.get_meta("GodotMCPPlugin") : null
	if not plugin:
		var context := {
			"command": "author_audio_stream_player",
			"client_id": client_id,
		}
		_log("GodotMCPPlugin not found in Engine metadata", function_name, context, true)
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		var context := {
			"command": "author_audio_stream_player",
			"client_id": client_id,
		}
		_log("No scene is currently being edited", function_name, context, true)
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var property_overrides: Dictionary = {}
	if typeof(properties_param) == TYPE_DICTIONARY:
		property_overrides = (properties_param as Dictionary).duplicate(true)
	elif typeof(properties_param) != TYPE_NIL and properties_param != null:
		var context := {
			"command": "author_audio_stream_player",
			"client_id": client_id,
		}
		_log("Audio stream player configuration expects a dictionary of properties", function_name, context, true)
		return _send_error(client_id, "Audio stream player configuration expects a dictionary of properties", command_id)

	var inline_property_keys := [
		"autoplay",
		"bus",
		"volume_db",
		"pitch_scale",
		"max_polyphony",
		"stream_paused",
		"mix_target",
		"doppler_tracking",
		"unit_size",
		"max_distance",
		"attenuation",
		"attenuation_filter_cutoff_hz",
		"attenuation_filter_db",
		"emission_angle",
		"emission_angle_filter_attenuation_db",
		"area_mask",
	]
	for property_key in inline_property_keys:
		if params.has(property_key):
			property_overrides[property_key] = params[property_key]

	var inline_stream_requested := false
	var inline_stream_null := false
	var inline_stream_value = null
	if property_overrides.has("stream"):
		inline_stream_requested = true
		inline_stream_value = property_overrides["stream"]
		inline_stream_null = inline_stream_value == null
		property_overrides.erase("stream")

	var node: Node = null
	var parent: Node = null
	var was_created := false
	var resolved_parent_path := parent_path
	var node_lookup_path := requested_node_path

	if not requested_node_path.is_empty():
		node = _get_editor_node(requested_node_path)
		if node:
			if not _is_supported_audio_stream_player(node):
				var context := {
					"command": "author_audio_stream_player",
					"client_id": client_id,
					"node_path": requested_node_path,
					"node_type": node.get_class(),
				}
				_log("Target node is not an AudioStreamPlayer", function_name, context, true)
				return _send_error(client_id, "Node at path is not an audio stream player", command_id)
			if resolved_parent_path.is_empty():
				var parent_node := node.get_parent()
				if parent_node:
					resolved_parent_path = _node_path_to_string(parent_node, resolved_parent_path)
		else:
			if not create_if_missing:
				var context := {
					"command": "author_audio_stream_player",
					"client_id": client_id,
					"node_path": requested_node_path,
				}
				_log("Audio stream player not found and creation disabled", function_name, context, true)
				return _send_error(client_id, "Audio stream player not found at path", command_id)
			node_lookup_path = ""

	if not node:
		if resolved_parent_path.is_empty():
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
			}
			_log("Parent path is required when creating an audio stream player", function_name, context, true)
			return _send_error(client_id, "Parent path is required when creating an audio stream player", command_id)

		parent = _get_editor_node(resolved_parent_path)
		if not parent:
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
				"parent_path": resolved_parent_path,
			}
			_log("Parent node not found for audio stream player creation", function_name, context, true)
			return _send_error(client_id, "Parent node not found: %s" % resolved_parent_path, command_id)

		if not ClassDB.can_instantiate(player_type):
			var context := {
				"command": "author_audio_stream_player",
				"player_type": player_type,
				"client_id": client_id,
			}
			_log("Audio stream player type cannot be instantiated", function_name, context, true)
			return _send_error(client_id, "Cannot instantiate audio stream player type: %s" % player_type, command_id)

		node = ClassDB.instantiate(player_type)
		if not node:
			var context := {
				"command": "author_audio_stream_player",
				"player_type": player_type,
				"client_id": client_id,
			}
			_log("Failed to instantiate audio stream player", function_name, context, true)
			return _send_error(client_id, "Failed to instantiate audio stream player of type %s" % player_type, command_id)

		if not _is_supported_audio_stream_player(node):
			var context := {
				"command": "author_audio_stream_player",
				"player_type": player_type,
				"client_id": client_id,
			}
			_log("Instantiated node is not an AudioStreamPlayer subtype", function_name, context, true)
			return _send_error(client_id, "Audio stream player type must inherit from AudioStreamPlayer", command_id)

		was_created = true
		if player_name.is_empty():
			player_name = player_type
		node.name = player_name
	else:
		parent = node.get_parent()

	var stream_requested := false
	var stream_null_requested := false
	var stream_resource: AudioStream = null
	var stream_path_for_change := ""

	if inline_stream_requested and provided_stream_path.is_empty():
		stream_requested = true
		stream_null_requested = inline_stream_null
		match typeof(inline_stream_value):
			TYPE_NIL:
				stream_null_requested = true
			TYPE_OBJECT:
				if inline_stream_value is AudioStream:
					stream_resource = inline_stream_value
					stream_path_for_change = stream_resource.resource_path
				else:
					var context := {
						"command": "author_audio_stream_player",
						"client_id": client_id,
					}
					_log("Inline stream override must be an AudioStream resource", function_name, context, true)
					return _send_error(client_id, "Inline stream override must be an AudioStream resource", command_id)
			TYPE_STRING, TYPE_STRING_NAME:
				provided_stream_path = String(inline_stream_value)
				stream_null_requested = false
			TYPE_DICTIONARY:
				provided_stream_path = String(inline_stream_value.get("path", ""))
				stream_null_requested = false
			_:
				stream_requested = false
				stream_null_requested = false

	if not provided_stream_path.is_empty():
		var normalized_stream_path := _normalize_resource_path(provided_stream_path)
		if not ResourceLoader.exists(normalized_stream_path):
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
				"stream_path": normalized_stream_path,
			}
			_log("Audio stream resource does not exist", function_name, context, true)
			return _send_error(client_id, "Audio stream resource not found: %s" % normalized_stream_path, command_id)

		var loaded_stream := ResourceLoader.load(normalized_stream_path)
		if not loaded_stream or not (loaded_stream is AudioStream):
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
				"stream_path": normalized_stream_path,
			}
			_log("Resource is not an AudioStream", function_name, context, true)
			return _send_error(client_id, "Resource is not an AudioStream: %s" % normalized_stream_path, command_id)

		stream_resource = loaded_stream
		stream_requested = true
		stream_null_requested = false
		stream_path_for_change = stream_resource.resource_path
		if stream_path_for_change.is_empty():
			stream_path_for_change = normalized_stream_path

	var property_changes: Array = []
	for property_name in property_overrides.keys():
		if not property_name in node:
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
				"property": property_name,
				"node_path": requested_node_path,
			}
			_log("Audio stream player is missing requested property", function_name, context, true)
			return _send_error(client_id, "Audio stream player does not have property: %s" % property_name, command_id)

		var raw_value = property_overrides[property_name]
		var parsed_value = _parse_property_value(raw_value)
		var old_value = node.get(property_name)
		var coerced_value = _coerce_property_value(old_value, parsed_value)
		if old_value == coerced_value:
			continue
		property_changes.append({
			"property": property_name,
			"input_value": raw_value,
			"parsed_value": parsed_value,
			"old_value": old_value,
			"new_value": coerced_value,
		})

	if stream_requested:
		if not ("stream" in node):
			var context := {
				"command": "author_audio_stream_player",
				"client_id": client_id,
			}
			_log("Audio stream player does not expose a stream property", function_name, context, true)
			return _send_error(client_id, "Audio stream player does not expose a stream property", command_id)

		var old_stream = node.get("stream")
		var new_stream_value = stream_null_requested ? null : stream_resource
		if old_stream != new_stream_value:
			property_changes.append({
				"property": "stream",
				"input_value": stream_null_requested ? null : stream_path_for_change,
				"parsed_value": stream_null_requested ? null : stream_path_for_change,
				"old_value": old_stream,
				"new_value": new_stream_value,
				"stream_path": stream_null_requested ? "" : stream_path_for_change,
			})
		else:
			stream_requested = false
			stream_null_requested = false
			stream_path_for_change = ""

	if not was_created and property_changes.is_empty():
		var log_payload := {
			"command": "author_audio_stream_player",
			"client_id": client_id,
			"node_path": requested_node_path,
			"player_type": node.get_class(),
			"mode": "configure",
			"change_count": 0,
		}
		if not resolved_parent_path.is_empty():
			log_payload["parent_path"] = resolved_parent_path
		_log("No audio stream player changes were required", function_name, log_payload)
		return _send_success(client_id, {
			"node_path": requested_node_path,
			"requested_path": requested_node_path,
			"node_type": node.get_class(),
			"changes": [],
			"transaction_id": transaction_id,
			"status": "no_changes",
			"was_created": false,
		}, command_id)

	var transaction_metadata := {
		"command": "author_audio_stream_player",
		"mode": was_created ? "create" : "configure",
		"requested_path": requested_node_path,
		"player_type": player_type,
		"client_id": client_id,
	}
	if not command_id.is_empty():
		transaction_metadata["command_id"] = command_id
	if not resolved_parent_path.is_empty():
		transaction_metadata["parent_path"] = resolved_parent_path

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Author Audio Stream Player", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Author Audio Stream Player", transaction_metadata)

	if not transaction:
		var context := {
			"command": "author_audio_stream_player",
			"client_id": client_id,
			"transaction_id": transaction_id,
		}
		_log("Failed to obtain scene transaction for audio stream player", function_name, context, true)
		return _send_error(client_id, "Failed to obtain scene transaction for audio stream player", command_id)

	if was_created:
		transaction.add_do_method(parent, "add_child", [node])
		transaction.add_do_method(node, "set_owner", [edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [node])
		transaction.add_undo_method(node, "queue_free")
		transaction.add_do_reference(node)

	for change in property_changes:
		var property_name: String = change["property"]
		var new_value = change["new_value"]
		var old_value = change["old_value"]
		if property_name == "stream" and new_value and new_value is AudioStream:
			transaction.add_do_reference(new_value)
		if was_created:
			node.set(property_name, new_value)
		else:
			transaction.add_do_property(node, property_name, new_value)
			transaction.add_undo_property(node, property_name, old_value)

	var serialized_changes := _serialize_audio_player_changes(property_changes)
	var commit_changes := serialized_changes.duplicate(true)
	var log_payload := {
		"command": "author_audio_stream_player",
		"client_id": client_id,
		"requested_path": requested_node_path,
		"player_type": node.get_class(),
		"mode": was_created ? "create" : "configure",
		"transaction_id": transaction.transaction_id,
		"change_count": serialized_changes.size(),
	}
	if not resolved_parent_path.is_empty():
		log_payload["parent_path"] = resolved_parent_path
	if stream_path_for_change != "":
		log_payload["stream_path"] = stream_path_for_change
	if was_created:
		log_payload["created_name"] = node.name

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var payload = log_payload.duplicate(true)
		payload["status"] = "committed"
		payload["changes"] = commit_changes.duplicate(true)
		_log("Committed audio stream player authoring", function_name, payload)
	)

	transaction.register_on_rollback(func():
		var payload = log_payload.duplicate(true)
		payload["status"] = "rolled_back"
		payload["changes"] = commit_changes.duplicate(true)
		_log("Rolled back audio stream player authoring", function_name, payload)
	)

	var status := "pending"
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			var error_payload := log_payload.duplicate(true)
			error_payload["status"] = "failed_commit"
			_log("Failed to commit audio stream player authoring", function_name, error_payload, true)
			return _send_error(client_id, "Failed to commit audio stream player authoring", command_id)
		status = "committed"

	var fallback_node_path := node_lookup_path
	if fallback_node_path.is_empty():
		if resolved_parent_path.ends_with("/"):
			fallback_node_path = resolved_parent_path + String(node.name)
		else:
			fallback_node_path = resolved_parent_path + "/" + String(node.name)

	var resolved_node_path := fallback_node_path
	if status == "committed":
		resolved_node_path = _node_path_to_string(node, fallback_node_path)

	var response := {
		"node_path": resolved_node_path,
		"requested_path": requested_node_path,
		"node_type": node.get_class(),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
		"status": status,
		"was_created": was_created,
	}
	if not resolved_parent_path.is_empty():
		response["parent_path"] = resolved_parent_path
	if stream_requested or stream_null_requested or stream_path_for_change != "":
		response["stream_path"] = stream_null_requested ? "" : stream_path_for_change
		response["stream_cleared"] = stream_null_requested

	_send_success(client_id, response, command_id)

func _author_interactive_music_graph(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_author_interactive_music_graph"
	var context := {
		"command": "author_interactive_music_graph",
		"client_id": client_id,
		"command_id": command_id,
		"system_section": "interactive_music",
	}

	if not ClassDB.class_exists("AudioStreamInteractive"):
		_log(
			"AudioStreamInteractive class is unavailable. Ensure the interactive_music module is enabled.",
			function_name,
			context,
			true
		)
		return _send_error(client_id, "Interactive music module is not available in this project", command_id)

	var resource_path := String(params.get("resource_path", ""))
	if resource_path.is_empty():
		_log("Interactive music resource path is required", function_name, context, true)
		return _send_error(client_id, "Interactive music resource path is required", command_id)

	var normalized_path := _normalize_resource_path(resource_path)
	context["resource_path"] = normalized_path

	var clips_param = params.get("clips", [])
	if typeof(clips_param) != TYPE_ARRAY:
		_log("Interactive music clips must be provided as an array", function_name, context, true)
		return _send_error(client_id, "Interactive music clips must be provided as an array", command_id)

	var clip_entries: Array = (clips_param as Array).duplicate(true)
	if clip_entries.is_empty():
		_log("At least one clip definition is required for interactive music authoring", function_name, context, true)
		return _send_error(client_id, "At least one clip definition is required", command_id)

	var transitions_param = params.get("transitions", [])
	if typeof(transitions_param) != TYPE_ARRAY and typeof(transitions_param) != TYPE_NIL:
		_log("Interactive music transitions must be an array if provided", function_name, context, true)
		return _send_error(client_id, "Interactive music transitions must be an array if provided", command_id)

	var interactive_stream: AudioStreamInteractive = null
	var was_created := false

	if ResourceLoader.exists(normalized_path):
		var loaded_resource = ResourceLoader.load(normalized_path)
		if loaded_resource is AudioStreamInteractive:
			interactive_stream = loaded_resource
		else:
			context["loaded_type"] = loaded_resource.get_class() if loaded_resource else "null"
			_log("Existing resource is not an AudioStreamInteractive", function_name, context, true)
			return _send_error(client_id, "Resource is not an AudioStreamInteractive: %s" % normalized_path, command_id)
	else:
		interactive_stream = AudioStreamInteractive.new()
		was_created = true

	if not interactive_stream:
		_log("Failed to initialize AudioStreamInteractive resource", function_name, context, true)
		return _send_error(client_id, "Failed to initialize AudioStreamInteractive resource", command_id)

	var auto_advance_maps := _get_interactive_auto_advance_maps()
	var transition_from_maps := _get_interactive_transition_from_time_maps()
	var transition_to_maps := _get_interactive_transition_to_time_maps()
	var fade_mode_maps := _get_interactive_fade_mode_maps()
	var clip_any_constant := _get_interactive_clip_any_constant()

	var clip_name_map: Dictionary = {}
	for i in clip_entries.size():
		var entry = clip_entries[i]
		if typeof(entry) != TYPE_DICTIONARY:
			context["clip_index"] = i
			context["clip_type"] = typeof(entry)
			_log("Interactive music clip definitions must be dictionaries", function_name, context, true)
			return _send_error(client_id, "Interactive music clip definitions must be dictionaries", command_id)
		var clip_dict: Dictionary = (entry as Dictionary).duplicate(true)
		clip_entries[i] = clip_dict
		var clip_name := String(clip_dict.get("name", ""))
		if not clip_name.is_empty():
			clip_name_map[clip_name] = i
			var trimmed_name := clip_name.strip_edges()
			if not trimmed_name.is_empty():
				clip_name_map[trimmed_name] = i
				clip_name_map[trimmed_name.to_lower()] = i

	var previous_clip_count := interactive_stream.get_clip_count()
	var requested_clip_count := clip_entries.size()
	if requested_clip_count != previous_clip_count:
		interactive_stream.set_clip_count(requested_clip_count)

	var clip_summaries: Array = []
	var clip_display_names: Array = []

	for i in clip_entries.size():
		var clip_config: Dictionary = clip_entries[i]
		var clip_summary := {
			"index": i,
		}

		var clip_name := String(clip_config.get("name", ""))
		if not clip_name.is_empty():
			interactive_stream.set_clip_name(i, clip_name)
			clip_summary["name"] = clip_name
			clip_display_names.append(clip_name)
		else:
			var existing_name := String(interactive_stream.get_clip_name(i))
			if not existing_name.is_empty():
				clip_display_names.append(existing_name)
				clip_summary["name"] = existing_name
				clip_name_map[existing_name] = i
				var trimmed_existing := existing_name.strip_edges()
				if not trimmed_existing.is_empty():
					clip_name_map[trimmed_existing] = i
					clip_name_map[trimmed_existing.to_lower()] = i
			else:
				clip_display_names.append(str(i))
				clip_summary["name"] = str(i)

		if clip_config.has("stream_path"):
			var stream_request = clip_config["stream_path"]
			var stream_result := _load_audio_stream_for_interactive_clip(stream_request, normalized_path)
			if not stream_result["ok"]:
				var stream_error_context := context.duplicate(true)
				stream_error_context["clip_index"] = i
				stream_error_context["stream_error"] = stream_result.duplicate(true)
				_log(
					"Failed to load interactive music clip stream",
					function_name,
					stream_error_context,
					true
				)
				return _send_error(client_id, stream_result.get("error_message", "Failed to load audio stream"), command_id)

			interactive_stream.set_clip_stream(i, stream_result["stream"])
			clip_summary["stream_path"] = stream_result.get("path", "")
			clip_summary["stream_cleared"] = stream_result.get("cleared", false)
			if stream_result.get("cleared", false):
				clip_summary["stream_path"] = ""

		if clip_config.has("auto_advance_mode"):
			var auto_mode_value = clip_config["auto_advance_mode"]
			var auto_mode_result := _parse_interactive_enum_value(auto_mode_value, auto_advance_maps, "auto_advance_mode")
			if not auto_mode_result["ok"]:
				var auto_error_context := context.duplicate(true)
				auto_error_context["clip_index"] = i
				auto_error_context["resource_path"] = normalized_path
				auto_error_context["auto_advance_mode"] = auto_mode_value
				auto_error_context["error_detail"] = auto_mode_result.duplicate(true)
				_log("Invalid interactive music auto advance mode", function_name, auto_error_context, true)
				return _send_error(client_id, auto_mode_result.get("error_message", "Invalid auto advance mode"), command_id)
			interactive_stream.set_clip_auto_advance(i, auto_mode_result["value"])
			clip_summary["auto_advance_mode"] = auto_mode_result["label"]

			if clip_config.has("auto_advance_next_clip"):
				var next_reference = clip_config["auto_advance_next_clip"]
				var next_result := _resolve_interactive_clip_reference(
					next_reference,
					clip_name_map,
					clip_entries.size(),
					false,
					clip_any_constant
				)
				if not next_result["ok"]:
					var next_error_context := context.duplicate(true)
					next_error_context["clip_index"] = i
					next_error_context["resource_path"] = normalized_path
					next_error_context["auto_advance_next_clip"] = next_reference
					next_error_context["error_detail"] = next_result.duplicate(true)
					_log("Invalid interactive music auto advance target clip", function_name, next_error_context, true)
					return _send_error(client_id, next_result.get("error_message", "Invalid auto advance next clip"), command_id)
				interactive_stream.set_clip_auto_advance_next_clip(i, next_result["index"])
				clip_summary["auto_advance_next_clip"] = _interactive_clip_label(next_result["index"], clip_display_names, clip_any_constant)

		clip_summaries.append(clip_summary)

	var initial_clip_reference = params.get("initial_clip", null)
	if initial_clip_reference != null:
		var initial_result := _resolve_interactive_clip_reference(
			initial_clip_reference,
			clip_name_map,
			clip_entries.size(),
			false,
			clip_any_constant
		)
		if not initial_result["ok"]:
			var initial_error_context := context.duplicate(true)
			initial_error_context["resource_path"] = normalized_path
			initial_error_context["initial_clip"] = initial_clip_reference
			initial_error_context["error_detail"] = initial_result.duplicate(true)
			_log("Invalid interactive music initial clip reference", function_name, initial_error_context, true)
			return _send_error(client_id, initial_result.get("error_message", "Invalid initial clip reference"), command_id)
		interactive_stream.set_initial_clip(initial_result["index"])
		context["initial_clip"] = initial_result["label"]

	var transition_entries: Array = []
	if typeof(transitions_param) == TYPE_ARRAY:
		transition_entries = (transitions_param as Array).duplicate(true)

	var clear_missing_transitions := bool(params.get("clear_missing_transitions", false))
	var existing_transition_pairs: Array = []
	var existing_transition_lookup: Dictionary = {}

	var transition_list := interactive_stream.get_transition_list()
	for i in range(0, transition_list.size(), 2):
		var from_index := transition_list[i]
		var to_index := transition_list[i + 1]
		existing_transition_pairs.append({
			"from": from_index,
			"to": to_index,
		})
		existing_transition_lookup["%d->%d" % [from_index, to_index]] = true

	var transition_summaries: Array = []
	var transition_keep_lookup: Dictionary = {}

	for i in transition_entries.size():
		var transition_config = transition_entries[i]
		if typeof(transition_config) != TYPE_DICTIONARY:
			context["transition_index"] = i
			context["transition_type"] = typeof(transition_config)
			_log("Interactive music transitions must be dictionaries", function_name, context, true)
			return _send_error(client_id, "Interactive music transitions must be dictionaries", command_id)

		var transition_dict: Dictionary = (transition_config as Dictionary).duplicate(true)
		transition_entries[i] = transition_dict

		var from_reference = transition_dict.get("from_clip", transition_dict.get("from", null))
		var to_reference = transition_dict.get("to_clip", transition_dict.get("to", null))

		var from_result := _resolve_interactive_clip_reference(
			from_reference,
			clip_name_map,
			clip_entries.size(),
			true,
			clip_any_constant
		)
		if not from_result["ok"]:
			var from_error_context := context.duplicate(true)
			from_error_context["transition_index"] = i
			from_error_context["resource_path"] = normalized_path
			from_error_context["from_reference"] = from_reference
			from_error_context["error_detail"] = from_result.duplicate(true)
			_log("Invalid interactive music transition source clip", function_name, from_error_context, true)
			return _send_error(client_id, from_result.get("error_message", "Invalid transition source clip"), command_id)

		var to_result := _resolve_interactive_clip_reference(
			to_reference,
			clip_name_map,
			clip_entries.size(),
			true,
			clip_any_constant
		)
		if not to_result["ok"]:
			var to_error_context := context.duplicate(true)
			to_error_context["transition_index"] = i
			to_error_context["resource_path"] = normalized_path
			to_error_context["to_reference"] = to_reference
			to_error_context["error_detail"] = to_result.duplicate(true)
			_log("Invalid interactive music transition destination clip", function_name, to_error_context, true)
			return _send_error(client_id, to_result.get("error_message", "Invalid transition destination clip"), command_id)

		var from_time_value = transition_dict.get("from_time", "immediate")
		var from_time_result := _parse_interactive_enum_value(from_time_value, transition_from_maps, "from_time")
		if not from_time_result["ok"]:
			var from_time_context := context.duplicate(true)
			from_time_context["transition_index"] = i
			from_time_context["from_time"] = from_time_value
			from_time_context["error_detail"] = from_time_result.duplicate(true)
			_log("Invalid interactive music transition from_time", function_name, from_time_context, true)
			return _send_error(client_id, from_time_result.get("error_message", "Invalid from_time value"), command_id)

		var to_time_value = transition_dict.get("to_time", "same_position")
		var to_time_result := _parse_interactive_enum_value(to_time_value, transition_to_maps, "to_time")
		if not to_time_result["ok"]:
			var to_time_context := context.duplicate(true)
			to_time_context["transition_index"] = i
			to_time_context["to_time"] = to_time_value
			to_time_context["error_detail"] = to_time_result.duplicate(true)
			_log("Invalid interactive music transition to_time", function_name, to_time_context, true)
			return _send_error(client_id, to_time_result.get("error_message", "Invalid to_time value"), command_id)

		var fade_mode_value = transition_dict.get("fade_mode", "automatic")
		var fade_mode_result := _parse_interactive_enum_value(fade_mode_value, fade_mode_maps, "fade_mode")
		if not fade_mode_result["ok"]:
			var fade_mode_context := context.duplicate(true)
			fade_mode_context["transition_index"] = i
			fade_mode_context["fade_mode"] = fade_mode_value
			fade_mode_context["error_detail"] = fade_mode_result.duplicate(true)
			_log("Invalid interactive music transition fade_mode", function_name, fade_mode_context, true)
			return _send_error(client_id, fade_mode_result.get("error_message", "Invalid fade_mode value"), command_id)

		var fade_beats := float(transition_dict.get("fade_beats", 0.0))
		var use_filler_clip := bool(transition_dict.get("use_filler_clip", false))
		var hold_previous := bool(transition_dict.get("hold_previous", false))

		var filler_clip_index := clip_any_constant
		var filler_label := ""
		if use_filler_clip and not transition_dict.has("filler_clip"):
			var filler_missing_context := context.duplicate(true)
			filler_missing_context["transition_index"] = i
			filler_missing_context["use_filler_clip"] = use_filler_clip
			_log("Filler clip reference is required when use_filler_clip is true", function_name, filler_missing_context, true)
			return _send_error(client_id, "Filler clip reference is required when use_filler_clip is true", command_id)

		if use_filler_clip and transition_dict.has("filler_clip"):
			var filler_result := _resolve_interactive_clip_reference(
				transition_dict["filler_clip"],
				clip_name_map,
				clip_entries.size(),
				false,
				clip_any_constant
			)
			if not filler_result["ok"]:
				var filler_context := context.duplicate(true)
				filler_context["transition_index"] = i
				filler_context["filler_clip"] = transition_dict["filler_clip"]
				filler_context["error_detail"] = filler_result.duplicate(true)
				_log("Invalid interactive music transition filler clip", function_name, filler_context, true)
				return _send_error(client_id, filler_result.get("error_message", "Invalid filler clip reference"), command_id)
			filler_clip_index = filler_result["index"]
			filler_label = filler_result["label"]

		var transition_key := "%d->%d" % [from_result["index"], to_result["index"]]
		transition_keep_lookup[transition_key] = true

		if interactive_stream.has_transition(from_result["index"], to_result["index"]):
			interactive_stream.erase_transition(from_result["index"], to_result["index"])

		interactive_stream.add_transition(
			from_result["index"],
			to_result["index"],
			from_time_result["value"],
			to_time_result["value"],
			fade_mode_result["value"],
			fade_beats,
			use_filler_clip,
			filler_clip_index,
			hold_previous
		)

		var transition_summary := {
			"from_index": from_result["index"],
			"to_index": to_result["index"],
			"from_label": _interactive_clip_label(from_result["index"], clip_display_names, clip_any_constant),
			"to_label": _interactive_clip_label(to_result["index"], clip_display_names, clip_any_constant),
			"from_time": from_time_result["label"],
			"to_time": to_time_result["label"],
			"fade_mode": fade_mode_result["label"],
			"fade_beats": fade_beats,
			"use_filler_clip": use_filler_clip,
			"hold_previous": hold_previous,
			"status": existing_transition_lookup.has(transition_key) ? "updated" : "added",
		}
		if use_filler_clip:
			transition_summary["filler_clip"] = filler_label if filler_label != "" else _interactive_clip_label(filler_clip_index, clip_display_names, clip_any_constant)

		transition_summaries.append(transition_summary)

	if clear_missing_transitions:
		var removed_transitions: Array = []
		for transition_pair in existing_transition_pairs:
			var key := "%d->%d" % [transition_pair["from"], transition_pair["to"]]
			if transition_keep_lookup.has(key):
				continue
			interactive_stream.erase_transition(transition_pair["from"], transition_pair["to"])
			removed_transitions.append({
				"from_index": transition_pair["from"],
				"to_index": transition_pair["to"],
				"from_label": _interactive_clip_label(transition_pair["from"], clip_display_names, clip_any_constant),
				"to_label": _interactive_clip_label(transition_pair["to"], clip_display_names, clip_any_constant),
				"status": "removed",
			})

		for removed_transition in removed_transitions:
			transition_summaries.append(removed_transition)

	var save_result := ResourceSaver.save(interactive_stream, normalized_path)
	if save_result != OK:
		context["save_error"] = save_result
		_log("Failed to save AudioStreamInteractive resource", function_name, context, true)
		return _send_error(client_id, "Failed to save interactive music resource: %s" % normalized_path, command_id)

	var response := {
		"resource_path": normalized_path,
		"clip_count": requested_clip_count,
		"clips": clip_summaries,
		"transitions": transition_summaries,
		"status": was_created ? "created" : "updated",
	}

	context["clip_count"] = requested_clip_count
	context["transition_count"] = transition_summaries.size()
	context["clear_missing_transitions"] = clear_missing_transitions
	context["status"] = response["status"]

	_log("Authored interactive music graph", function_name, context)
	_send_success(client_id, response, command_id)

func _generate_dynamic_music_layer(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_generate_dynamic_music_layer"
	var context := {
		"command": "generate_dynamic_music_layer",
		"client_id": client_id,
		"command_id": command_id,
		"system_section": "interactive_music",
	}

	if not ClassDB.class_exists("AudioStreamInteractive"):
		_log(
			"AudioStreamInteractive class is unavailable. Ensure the interactive_music module is enabled.",
			function_name,
			context,
			true
		)
		return _send_error(client_id, "Interactive music module is not available in this project", command_id)

	var resource_path := String(params.get("resource_path", ""))
	if resource_path.is_empty():
		_log("Interactive music resource path is required", function_name, context, true)
		return _send_error(client_id, "Interactive music resource path is required", command_id)

	var normalized_path := _normalize_resource_path(resource_path)
	context["resource_path"] = normalized_path

	if not ResourceLoader.exists(normalized_path):
		_log("Interactive music resource was not found", function_name, context, true)
		return _send_error(client_id, "Interactive music resource not found: %s" % normalized_path, command_id)

	var loaded_resource = ResourceLoader.load(normalized_path)
	if not (loaded_resource is AudioStreamInteractive):
		context["loaded_type"] = loaded_resource.get_class() if loaded_resource else "null"
		_log("Resource is not an AudioStreamInteractive", function_name, context, true)
		return _send_error(client_id, "Resource is not an AudioStreamInteractive: %s" % normalized_path, command_id)

	var interactive_stream: AudioStreamInteractive = loaded_resource
	var clip_count := interactive_stream.get_clip_count()
	var clip_name_map: Dictionary = {}
	var clip_display_names: Array = []

	for i in clip_count:
		var clip_name := String(interactive_stream.get_clip_name(i))
		if clip_name.is_empty():
			clip_display_names.append(str(i))
		else:
			clip_display_names.append(clip_name)
			clip_name_map[clip_name] = i
			var trimmed := clip_name.strip_edges()
			if not trimmed.is_empty():
				clip_name_map[trimmed] = i
				clip_name_map[trimmed.to_lower()] = i

	var clip_any_constant := _get_interactive_clip_any_constant()
	if clip_any_constant == -1:
		_log("Interactive music clip constants are unavailable", function_name, context, true)
		return _send_error(client_id, "Interactive music clip metadata is unavailable", command_id)

	var base_reference = params.get("base_clip")
	var base_result := _resolve_interactive_clip_reference(
		base_reference,
		clip_name_map,
		clip_count,
		false,
		clip_any_constant
	)
	if not base_result["ok"]:
		var base_context := context.duplicate(true)
		base_context["base_clip"] = base_reference
		base_context["error_detail"] = base_result.duplicate(true)
		_log("Invalid base clip reference for dynamic layer", function_name, base_context, true)
		return _send_error(client_id, base_result.get("error_message", "Invalid base clip reference"), command_id)

	var base_summary := {
		"index": base_result["index"],
		"label": base_result.get(
			"label",
			_interactive_clip_label(base_result["index"], clip_display_names, clip_any_constant)
		),
	}
	context["base_clip"] = base_summary.duplicate(true)

	var layer_options := params.get("layer_clip", params.get("layer", {}))
	if typeof(layer_options) != TYPE_DICTIONARY:
		var layer_type_context := context.duplicate(true)
		layer_type_context["layer_clip_type"] = typeof(layer_options)
		_log("Layer clip configuration must be a dictionary", function_name, layer_type_context, true)
		return _send_error(client_id, "Layer clip configuration must be a dictionary", command_id)

	var layer_dict: Dictionary = (layer_options as Dictionary).duplicate(true)
	var layer_name := String(layer_dict.get("name", ""))
	var layer_index := -1

	if layer_dict.has("reference"):
		var layer_reference := layer_dict["reference"]
		var layer_result := _resolve_interactive_clip_reference(
			layer_reference,
			clip_name_map,
			clip_count,
			false,
			clip_any_constant
		)
		if not layer_result["ok"]:
			var layer_context := context.duplicate(true)
			layer_context["layer_reference"] = layer_reference
			layer_context["error_detail"] = layer_result.duplicate(true)
			_log("Invalid layer clip reference", function_name, layer_context, true)
			return _send_error(client_id, layer_result.get("error_message", "Invalid layer clip reference"), command_id)
		layer_index = layer_result["index"]
		if layer_name.is_empty():
			layer_name = String(layer_result.get("label", ""))

	if layer_index == -1 and not layer_name.is_empty():
		var normalized_name := layer_name.strip_edges()
		if clip_name_map.has(normalized_name):
			layer_index = int(clip_name_map[normalized_name])
		elif clip_name_map.has(normalized_name.to_lower()):
			layer_index = int(clip_name_map[normalized_name.to_lower()])

	var created_layer := false
	if layer_index == -1:
		layer_index = clip_count
		clip_count += 1
		interactive_stream.set_clip_count(clip_count)
		var provisional_label := layer_name.strip_edges()
		if provisional_label.is_empty():
			provisional_label = str(layer_index)
		clip_display_names.append(provisional_label)
		created_layer = true

	if layer_index >= clip_display_names.size():
		clip_display_names.resize(layer_index + 1)
		clip_display_names[layer_index] = layer_name.is_empty() ? str(layer_index) : layer_name

	if not layer_name.is_empty():
		interactive_stream.set_clip_name(layer_index, layer_name)
		clip_display_names[layer_index] = layer_name
		clip_name_map[layer_name] = layer_index
		var trimmed_layer := layer_name.strip_edges()
		if not trimmed_layer.is_empty():
			clip_name_map[trimmed_layer] = layer_index
			clip_name_map[trimmed_layer.to_lower()] = layer_index

	var layer_label := _interactive_clip_label(layer_index, clip_display_names, clip_any_constant)
	var layer_summary := {
		"index": layer_index,
		"label": layer_label,
		"was_created": created_layer,
		"status": created_layer ? "created" : "updated",
	}
	if not layer_name.is_empty():
		layer_summary["name"] = layer_name

	if layer_dict.has("stream_path"):
		var stream_result := _load_audio_stream_for_interactive_clip(layer_dict["stream_path"], normalized_path)
		if not stream_result["ok"]:
			var stream_context := context.duplicate(true)
			stream_context["layer_index"] = layer_index
			stream_context["stream_error"] = stream_result.duplicate(true)
			_log("Failed to load audio stream for dynamic layer", function_name, stream_context, true)
			return _send_error(client_id, stream_result.get("error_message", "Failed to load audio stream"), command_id)
		interactive_stream.set_clip_stream(layer_index, stream_result["stream"])
		layer_summary["stream_path"] = stream_result.get("path", "")
		layer_summary["stream_cleared"] = stream_result.get("cleared", false)

	context["layer_clip"] = layer_summary.duplicate(true)

	var entry_transition_param = params.get("entry_transition", {})
	if typeof(entry_transition_param) != TYPE_DICTIONARY and typeof(entry_transition_param) != TYPE_NIL:
		var entry_type_context := context.duplicate(true)
		entry_type_context["entry_transition_type"] = typeof(entry_transition_param)
		_log("Entry transition configuration must be a dictionary", function_name, entry_type_context, true)
		return _send_error(client_id, "Entry transition configuration must be a dictionary", command_id)
	var entry_config: Dictionary = typeof(entry_transition_param) == TYPE_DICTIONARY ? (entry_transition_param as Dictionary) : {}

	var exit_transition_param = params.get("exit_transition", {})
	if typeof(exit_transition_param) != TYPE_DICTIONARY and typeof(exit_transition_param) != TYPE_NIL:
		var exit_type_context := context.duplicate(true)
		exit_type_context["exit_transition_type"] = typeof(exit_transition_param)
		_log("Exit transition configuration must be a dictionary", function_name, exit_type_context, true)
		return _send_error(client_id, "Exit transition configuration must be a dictionary", command_id)
	var exit_config: Dictionary = typeof(exit_transition_param) == TYPE_DICTIONARY ? (exit_transition_param as Dictionary) : {}

	context["entry_transition"] = entry_config.duplicate(true)
	context["exit_transition"] = exit_config.duplicate(true)

	var transition_from_maps := _get_interactive_transition_from_time_maps()
	var transition_to_maps := _get_interactive_transition_to_time_maps()
	var fade_mode_maps := _get_interactive_fade_mode_maps()

	var entry_from_value = entry_config.get("from_time", "next_bar")
	var entry_from := _parse_interactive_enum_value(entry_from_value, transition_from_maps, "from_time")
	if not entry_from["ok"]:
		var entry_from_context := context.duplicate(true)
		entry_from_context["entry_from_time"] = entry_from_value
		entry_from_context["error_detail"] = entry_from.duplicate(true)
		_log("Invalid entry transition from_time", function_name, entry_from_context, true)
		return _send_error(client_id, entry_from.get("error_message", "Invalid entry transition from_time"), command_id)

	var entry_to_value = entry_config.get("to_time", "same_position")
	var entry_to := _parse_interactive_enum_value(entry_to_value, transition_to_maps, "to_time")
	if not entry_to["ok"]:
		var entry_to_context := context.duplicate(true)
		entry_to_context["entry_to_time"] = entry_to_value
		entry_to_context["error_detail"] = entry_to.duplicate(true)
		_log("Invalid entry transition to_time", function_name, entry_to_context, true)
		return _send_error(client_id, entry_to.get("error_message", "Invalid entry transition to_time"), command_id)

	var entry_fade_value = entry_config.get("fade_mode", "cross")
	var entry_fade := _parse_interactive_enum_value(entry_fade_value, fade_mode_maps, "fade_mode")
	if not entry_fade["ok"]:
		var entry_fade_context := context.duplicate(true)
		entry_fade_context["entry_fade_mode"] = entry_fade_value
		entry_fade_context["error_detail"] = entry_fade.duplicate(true)
		_log("Invalid entry transition fade_mode", function_name, entry_fade_context, true)
		return _send_error(client_id, entry_fade.get("error_message", "Invalid entry transition fade_mode"), command_id)

	var entry_beats := float(entry_config.get("fade_beats", 4.0))
	var entry_use_filler := bool(entry_config.get("use_filler_clip", false))
	var entry_hold_previous := bool(entry_config.get("hold_previous", false))
	var entry_filler_index := clip_any_constant
	var entry_filler_label := ""
	if entry_use_filler:
		if not entry_config.has("filler_clip"):
			var entry_missing_context := context.duplicate(true)
			entry_missing_context["entry_transition"] = entry_config.duplicate(true)
			_log("Entry transition filler clip is required when use_filler_clip is true", function_name, entry_missing_context, true)
			return _send_error(client_id, "Entry transition requires a filler_clip when use_filler_clip is true", command_id)
		var entry_filler_result := _resolve_interactive_clip_reference(
			entry_config["filler_clip"],
			clip_name_map,
			clip_count,
			false,
			clip_any_constant
		)
		if not entry_filler_result["ok"]:
			var entry_filler_context := context.duplicate(true)
			entry_filler_context["entry_filler_clip"] = entry_config["filler_clip"]
			entry_filler_context["error_detail"] = entry_filler_result.duplicate(true)
			_log("Invalid entry transition filler clip", function_name, entry_filler_context, true)
			return _send_error(client_id, entry_filler_result.get("error_message", "Invalid entry filler clip"), command_id)
		entry_filler_index = entry_filler_result["index"]
		entry_filler_label = entry_filler_result.get(
			"label",
			_interactive_clip_label(entry_filler_index, clip_display_names, clip_any_constant)
		)

	if interactive_stream.has_transition(base_result["index"], layer_index):
		interactive_stream.erase_transition(base_result["index"], layer_index)
	interactive_stream.add_transition(
		base_result["index"],
		layer_index,
		entry_from["value"],
		entry_to["value"],
		entry_fade["value"],
		entry_beats,
		entry_use_filler,
		entry_filler_index,
		entry_hold_previous
	)

	var exit_from_value = exit_config.get("from_time", "immediate")
	var exit_from := _parse_interactive_enum_value(exit_from_value, transition_from_maps, "from_time")
	if not exit_from["ok"]:
		var exit_from_context := context.duplicate(true)
		exit_from_context["exit_from_time"] = exit_from_value
		exit_from_context["error_detail"] = exit_from.duplicate(true)
		_log("Invalid exit transition from_time", function_name, exit_from_context, true)
		return _send_error(client_id, exit_from.get("error_message", "Invalid exit transition from_time"), command_id)

	var exit_to_value = exit_config.get("to_time", "same_position")
	var exit_to := _parse_interactive_enum_value(exit_to_value, transition_to_maps, "to_time")
	if not exit_to["ok"]:
		var exit_to_context := context.duplicate(true)
		exit_to_context["exit_to_time"] = exit_to_value
		exit_to_context["error_detail"] = exit_to.duplicate(true)
		_log("Invalid exit transition to_time", function_name, exit_to_context, true)
		return _send_error(client_id, exit_to.get("error_message", "Invalid exit transition to_time"), command_id)

	var exit_fade_value = exit_config.get("fade_mode", "cross")
	var exit_fade := _parse_interactive_enum_value(exit_fade_value, fade_mode_maps, "fade_mode")
	if not exit_fade["ok"]:
		var exit_fade_context := context.duplicate(true)
		exit_fade_context["exit_fade_mode"] = exit_fade_value
		exit_fade_context["error_detail"] = exit_fade.duplicate(true)
		_log("Invalid exit transition fade_mode", function_name, exit_fade_context, true)
		return _send_error(client_id, exit_fade.get("error_message", "Invalid exit transition fade_mode"), command_id)

	var exit_beats := float(exit_config.get("fade_beats", 2.0))
	var exit_use_filler := bool(exit_config.get("use_filler_clip", false))
	var exit_hold_previous := bool(exit_config.get("hold_previous", false))
	var exit_filler_index := clip_any_constant
	var exit_filler_label := ""
	if exit_use_filler:
		if not exit_config.has("filler_clip"):
			var exit_missing_context := context.duplicate(true)
			exit_missing_context["exit_transition"] = exit_config.duplicate(true)
			_log("Exit transition filler clip is required when use_filler_clip is true", function_name, exit_missing_context, true)
			return _send_error(client_id, "Exit transition requires a filler_clip when use_filler_clip is true", command_id)
		var exit_filler_result := _resolve_interactive_clip_reference(
			exit_config["filler_clip"],
			clip_name_map,
			clip_count,
			false,
			clip_any_constant
		)
		if not exit_filler_result["ok"]:
			var exit_filler_context := context.duplicate(true)
			exit_filler_context["exit_filler_clip"] = exit_config["filler_clip"]
			exit_filler_context["error_detail"] = exit_filler_result.duplicate(true)
			_log("Invalid exit transition filler clip", function_name, exit_filler_context, true)
			return _send_error(client_id, exit_filler_result.get("error_message", "Invalid exit filler clip"), command_id)
		exit_filler_index = exit_filler_result["index"]
		exit_filler_label = exit_filler_result.get(
			"label",
			_interactive_clip_label(exit_filler_index, clip_display_names, clip_any_constant)
		)

	if interactive_stream.has_transition(layer_index, base_result["index"]):
		interactive_stream.erase_transition(layer_index, base_result["index"])
	interactive_stream.add_transition(
		layer_index,
		base_result["index"],
		exit_from["value"],
		exit_to["value"],
		exit_fade["value"],
		exit_beats,
		exit_use_filler,
		exit_filler_index,
		exit_hold_previous
	)

	if bool(params.get("make_initial", false)):
		interactive_stream.set_initial_clip(layer_index)
		context["initial_clip"] = layer_label
		layer_summary["made_initial"] = true

	var save_status := ResourceSaver.save(interactive_stream, normalized_path)
	if save_status != OK:
		context["save_error"] = save_status
		_log("Failed to persist dynamic music layer", function_name, context, true)
		return _send_error(client_id, "Failed to save interactive music resource: %s" % normalized_path, command_id)

	var entry_summary := {
		"from": base_summary["label"],
		"to": layer_label,
		"from_time": entry_from.get("label", entry_from_value),
		"to_time": entry_to.get("label", entry_to_value),
		"fade_mode": entry_fade.get("label", entry_fade_value),
		"fade_beats": entry_beats,
		"use_filler_clip": entry_use_filler,
		"hold_previous": entry_hold_previous,
	}
	if entry_use_filler:
		entry_summary["filler_clip"] = entry_filler_label

	var exit_summary := {
		"from": layer_label,
		"to": base_summary["label"],
		"from_time": exit_from.get("label", exit_from_value),
		"to_time": exit_to.get("label", exit_to_value),
		"fade_mode": exit_fade.get("label", exit_fade_value),
		"fade_beats": exit_beats,
		"use_filler_clip": exit_use_filler,
		"hold_previous": exit_hold_previous,
	}
	if exit_use_filler:
		exit_summary["filler_clip"] = exit_filler_label

	var response := {
		"resource_path": normalized_path,
		"base_clip": base_summary,
		"layer_clip": layer_summary,
		"transitions": [entry_summary, exit_summary],
	}
	if layer_summary.get("made_initial", false):
		response["initial_clip"] = layer_label

	context["layer_clip"] = layer_summary.duplicate(true)
	context["transitions"] = response["transitions"].duplicate(true)
	context["make_initial"] = bool(params.get("make_initial", false))

	_log("Generated dynamic music layer", function_name, context)
	_send_success(client_id, response, command_id)

func _analyze_waveform(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_analyze_waveform"
	var context := {
		"command": "analyze_waveform",
		"client_id": client_id,
		"command_id": command_id,
		"system_section": "audio_analysis",
	}

	var resource_path := String(params.get("resource_path", ""))
	if resource_path.is_empty():
		_log("Audio resource path is required for waveform analysis", function_name, context, true)
		return _send_error(client_id, "Audio resource path is required", command_id)

	var normalized_path := _normalize_resource_path(resource_path)
	context["resource_path"] = normalized_path

	if not ResourceLoader.exists(normalized_path):
		context["resource_missing"] = true
		_log("Audio resource not found for waveform analysis", function_name, context, true)
		return _send_error(client_id, "Audio resource not found: %s" % normalized_path, command_id)

	var audio_resource := ResourceLoader.load(normalized_path)
	if audio_resource == null or not (audio_resource is AudioStream):
		context["resource_type"] = audio_resource.get_class() if audio_resource else "null"
		_log("Resource is not an AudioStream", function_name, context, true)
		return _send_error(client_id, "Resource is not an AudioStream: %s" % normalized_path, command_id)

	var audio_stream: AudioStream = audio_resource
	var mix_rate := float(audio_stream.get_mix_rate()) if audio_stream.has_method("get_mix_rate") else 0.0
	var channel_count := audio_stream.get_channel_count() if audio_stream.has_method("get_channel_count") else 0
	if channel_count <= 0 and _has_property(audio_stream, "stereo"):
		channel_count = bool(audio_stream.stereo) ? 2 : 1
	if channel_count <= 0:
		channel_count = 1

	var duration_seconds := audio_stream.get_length() if audio_stream.has_method("get_length") else 0.0
	var loop_enabled := _has_property(audio_stream, "loop") and bool(audio_stream.loop)

	var metadata := {
		"resource_path": normalized_path,
		"stream_type": audio_stream.get_class(),
		"mix_rate": mix_rate,
		"channel_count": channel_count,
		"length_seconds": duration_seconds,
		"loop": loop_enabled,
	}

	var silence_threshold := clamp(float(params.get("silence_threshold", 0.0005)), 0.000001, 0.1)
	var envelope_bins := int(params.get("envelope_bins", 256))
	envelope_bins = clamp(envelope_bins, 16, 4096)
	var analysis_mode := "metadata_only"
	var limited_reason := ""
	var sample_frames := 0
	var total_samples := 0
	var channel_summaries: Array = []
	var overall_summary := {}
	var analysis_started_ms := Time.get_ticks_msec()

	if audio_stream is AudioStreamSample:
		var sample_stream: AudioStreamSample = audio_stream
		var format := sample_stream.format
		var pcm_supported := format == AudioStreamSample.FORMAT_8_BITS or format == AudioStreamSample.FORMAT_16_BITS
		if not pcm_supported:
			limited_reason = "Unsupported PCM format for inline analysis"
		else:
			var data: PackedByteArray = sample_stream.data
			if data.is_empty():
				limited_reason = "Audio stream contains no PCM frames"
			else:
				analysis_mode = "pcm_samples"
				var bytes_per_sample := format == AudioStreamSample.FORMAT_16_BITS ? 2 : 1
				var total_values := data.size() / bytes_per_sample
				if channel_count <= 0:
					channel_count = sample_stream.stereo ? 2 : 1
					if channel_count <= 0:
						channel_count = 1
				sample_frames = int(total_values / max(channel_count, 1))
				total_samples = sample_frames * channel_count

				if mix_rate <= 0.0 and sample_stream.mix_rate > 0:
					mix_rate = float(sample_stream.mix_rate)
				if duration_seconds <= 0.0 and mix_rate > 0.0:
					duration_seconds = float(sample_frames) / mix_rate
					metadata["length_seconds"] = duration_seconds
				metadata["mix_rate"] = mix_rate
				metadata["channel_count"] = channel_count

				var stats: Array = []
				var envelopes: Array = []
				for channel_index in channel_count:
					stats.append({
						"min": 1.0,
						"max": -1.0,
						"sum": 0.0,
						"sum_sq": 0.0,
						"peak": 0.0,
						"samples": 0,
						"silent": 0,
						"zero_crossings": 0,
						"previous_sign": 0,
					})
					var bins: Array = []
					for bin_index in envelope_bins:
						bins.append({"min": 1.0, "max": -1.0, "samples": 0})
					envelopes.append(bins)

				var buffer := StreamPeerBuffer.new()
				buffer.big_endian = false
				buffer.data_array = data

				var overall_peak := 0.0
				var overall_sum := 0.0
				var overall_sum_sq := 0.0

				for frame_index in sample_frames:
					var envelope_bin := -1
					if envelope_bins > 0 and sample_frames > 0:
						envelope_bin = int(floor(float(frame_index) * envelope_bins / sample_frames))
						if envelope_bin >= envelope_bins:
							envelope_bin = envelope_bins - 1

					for channel_index in channel_count:
						if buffer.get_position() >= buffer.get_size():
							break

						var sample_value := 0.0
						if format == AudioStreamSample.FORMAT_16_BITS:
							sample_value = clamp(buffer.get_16() / 32768.0, -1.0, 1.0)
						else:
							sample_value = (buffer.get_u8() - 128.0) / 128.0

						var channel_stats: Dictionary = stats[channel_index]
						channel_stats["samples"] += 1
						channel_stats["sum"] += sample_value
						channel_stats["sum_sq"] += sample_value * sample_value
						if sample_value < channel_stats["min"]:
							channel_stats["min"] = sample_value
						if sample_value > channel_stats["max"]:
							channel_stats["max"] = sample_value
						var abs_value := abs(sample_value)
						if abs_value > channel_stats["peak"]:
							channel_stats["peak"] = abs_value
						if abs_value <= silence_threshold:
							channel_stats["silent"] += 1

						var previous_sign := int(channel_stats["previous_sign"])
						var sign := 0
						if sample_value > silence_threshold:
							sign = 1
						elif sample_value < -silence_threshold:
							sign = -1
						if previous_sign != 0 and sign != 0 and previous_sign != sign:
							channel_stats["zero_crossings"] += 1
						if sign != 0:
							channel_stats["previous_sign"] = sign

						if envelope_bin >= 0:
							var bin_stats: Dictionary = envelopes[channel_index][envelope_bin]
							bin_stats["samples"] += 1
							if sample_value < bin_stats["min"]:
								bin_stats["min"] = sample_value
							if sample_value > bin_stats["max"]:
								bin_stats["max"] = sample_value
							envelopes[channel_index][envelope_bin] = bin_stats

						stats[channel_index] = channel_stats

						if abs_value > overall_peak:
							overall_peak = abs_value
						overall_sum += sample_value
						overall_sum_sq += sample_value * sample_value

				var total_sample_count := max(total_samples, 1)
				var overall_rms := sqrt(overall_sum_sq / total_sample_count)
				var overall_mean := overall_sum / total_sample_count
				var overall_peak_db := _amplitude_to_decibels(overall_peak)
				var overall_rms_db := _amplitude_to_decibels(overall_rms)
				overall_summary = {
					"peak_amplitude": overall_peak,
					"peak_db": overall_peak_db,
					"rms_amplitude": overall_rms,
					"rms_db": overall_rms_db,
					"mean_amplitude": overall_mean,
					"dynamic_range_db": overall_peak_db - overall_rms_db,
				}

				channel_summaries = []
				for channel_index in channel_count:
					var channel_stats: Dictionary = stats[channel_index]
					var sample_count := int(channel_stats["samples"])
					var mean_amplitude := sample_count > 0 ? channel_stats["sum"] / sample_count : 0.0
					var rms_amplitude := sample_count > 0 ? sqrt(channel_stats["sum_sq"] / sample_count) : 0.0
					var peak_amplitude := channel_stats["peak"]
					var peak_db := _amplitude_to_decibels(peak_amplitude)
					var rms_db := _amplitude_to_decibels(rms_amplitude)
					var crest_factor := peak_db - rms_db
					var silence_ratio := sample_count > 0 ? float(channel_stats["silent"]) / sample_count : 0.0
					var zero_crossing_rate := 0.0
					if duration_seconds > 0.0:
						zero_crossing_rate = float(channel_stats["zero_crossings"]) / duration_seconds

					var envelope: Array = []
					if envelope_bins > 0:
						for bin_stats in envelopes[channel_index]:
							var bin_samples := int(bin_stats["samples"])
							if bin_samples == 0:
								envelope.append({"min": 0.0, "max": 0.0, "samples": 0})
							else:
								envelope.append({
									"min": bin_stats["min"],
									"max": bin_stats["max"],
									"samples": bin_samples,
								})

					channel_summaries.append({
						"channel_index": channel_index,
						"sample_count": sample_count,
						"min_amplitude": channel_stats["min"] if sample_count > 0 else 0.0,
						"max_amplitude": channel_stats["max"] if sample_count > 0 else 0.0,
						"peak_amplitude": peak_amplitude,
						"peak_db": peak_db,
						"rms_amplitude": rms_amplitude,
						"rms_db": rms_db,
						"mean_amplitude": mean_amplitude,
						"crest_factor_db": crest_factor,
						"silence_ratio": silence_ratio,
						"zero_crossings": channel_stats["zero_crossings"],
						"zero_crossings_per_second": zero_crossing_rate,
						"envelope": envelope,
					})

	var analysis_elapsed_ms := Time.get_ticks_msec() - analysis_started_ms

	var response := {
		"metadata": metadata,
		"analysis_mode": analysis_mode,
		"silence_threshold": silence_threshold,
		"envelope_bins": envelope_bins,
		"sample_frames": sample_frames,
		"total_samples": total_samples,
		"analysis_duration_ms": analysis_elapsed_ms,
	}

	if not channel_summaries.is_empty():
		response["channel_summaries"] = channel_summaries
	if not overall_summary.is_empty():
		response["overall"] = overall_summary
	if not limited_reason.is_empty():
		response["limited"] = true
		response["limited_reason"] = limited_reason
	else:
		response["limited"] = analysis_mode != "pcm_samples"

	context["analysis_mode"] = analysis_mode
	context["channel_count"] = channel_count
	context["sample_frames"] = sample_frames
	context["analysis_duration_ms"] = analysis_elapsed_ms
	if not limited_reason.is_empty():
		context["limited_reason"] = limited_reason

	_log("Completed waveform analysis", function_name, context)
	_send_success(client_id, response, command_id)

func _batch_import_audio_assets(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_batch_import_audio_assets"
	var context := {
		"command": "batch_import_audio_assets",
		"client_id": client_id,
		"command_id": command_id,
		"system_section": "audio_import",
	}

	var assets_param = params.get("assets", params.get("paths", []))
	if typeof(assets_param) != TYPE_ARRAY:
		context["assets_type"] = typeof(assets_param)
		_log("Audio batch import expects an array of asset definitions", function_name, context, true)
		return _send_error(client_id, "Audio batch import expects an array of asset definitions", command_id)

	var asset_entries: Array = []
	for entry in assets_param:
		match typeof(entry):
			TYPE_STRING, TYPE_STRING_NAME:
				asset_entries.append({"path": String(entry)})
			TYPE_DICTIONARY:
				asset_entries.append((entry as Dictionary).duplicate(true))
			_:
				var entry_context := context.duplicate(true)
				entry_context["entry_type"] = typeof(entry)
				_log("Unsupported audio import entry type", function_name, entry_context, true)
				return _send_error(client_id, "Unsupported audio import entry type", command_id)

	if asset_entries.is_empty():
		_log("No audio assets were supplied for batch import", function_name, context, true)
		return _send_error(client_id, "Provide at least one audio asset to import", command_id)

	var filesystem := EditorFileSystem.get_singleton()
	if filesystem == null:
		_log("EditorFileSystem is unavailable for audio import", function_name, context, true)
		return _send_error(client_id, "EditorFileSystem is unavailable", command_id)

	var normalized_paths := PackedStringArray()
	var asset_results: Array = []
	var config_updates := 0
	var errors: Array = []

	for asset in asset_entries:
		var asset_dict: Dictionary = asset
		var raw_path := String(asset_dict.get("path", ""))
		if raw_path.is_empty():
			errors.append({"error": "Missing path", "asset": asset_dict.duplicate(true)})
			continue

		var normalized_path := _normalize_resource_path(raw_path)
		if not ResourceLoader.exists(normalized_path):
			errors.append({
				"error": "Resource not found",
				"resource_path": normalized_path,
			})
			continue

		normalized_paths.append(normalized_path)

		var asset_summary := {
			"resource_path": normalized_path,
			"preset": String(asset_dict.get("preset", "")),
			"options_applied": 0,
			"config_status": "unchanged",
		}

		var options_value = asset_dict.get("options", asset_dict.get("import_settings", {}))
		var options_dict: Dictionary = {}
		if typeof(options_value) == TYPE_DICTIONARY:
			options_dict = (options_value as Dictionary).duplicate(true)
		elif typeof(options_value) != TYPE_NIL:
			errors.append({
				"error": "Import options must be a dictionary",
				"resource_path": normalized_path,
			})
			asset_results.append(asset_summary)
			continue

		var preset_name := asset_summary["preset"]
		if not preset_name.is_empty() or not options_dict.is_empty():
			var import_config_path := normalized_path + ".import"
			var global_import_path := ProjectSettings.globalize_path(import_config_path)
			var config := ConfigFile.new()
			var load_status := config.load(global_import_path)
			if load_status != OK:
				ResourceLoader.load(normalized_path)
				load_status = config.load(global_import_path)

			if load_status != OK:
				errors.append({
					"error": "Failed to load import configuration",
					"resource_path": normalized_path,
					"status": load_status,
				})
			else:
				if not preset_name.is_empty():
					config.set_value("remap", "preset", preset_name)
				if not options_dict.is_empty():
					for option_key in options_dict.keys():
						config.set_value("params", String(option_key), options_dict[option_key])
					asset_summary["options_applied"] = options_dict.size()

				var save_status := config.save(global_import_path)
				if save_status != OK:
					errors.append({
						"error": "Failed to save import configuration",
						"resource_path": normalized_path,
						"status": save_status,
					})
				else:
					asset_summary["config_status"] = "updated"
					config_updates += 1

		asset_results.append(asset_summary)

	if normalized_paths.is_empty():
		context["errors"] = errors.duplicate(true)
		_log("No valid audio assets resolved for reimport", function_name, context, true)
		return _send_error(client_id, "No valid audio assets to import", command_id)

	filesystem.reimport_files(normalized_paths)

	context["reimported"] = normalized_paths.size()
	context["config_updates"] = config_updates
	context["error_count"] = errors.size()
	if not errors.is_empty():
		context["errors"] = errors.duplicate(true)

	_log("Triggered batch audio asset import", function_name, context)

	var response := {
		"reimported": normalized_paths.size(),
		"assets": asset_results,
		"config_updates": config_updates,
	}
	if not errors.is_empty():
		response["errors"] = errors

	_send_success(client_id, response, command_id)
func _serialize_audio_player_changes(changes: Array) -> Array:
	var serialized: Array = []
	for change in changes:
		var property_name := change.get("property", "")
		var new_value = change.get("new_value")
		var old_value = change.get("old_value")
		var entry := {
			"property": property_name,
			"input_value": change.get("input_value"),
			"parsed_value": _stringify_audio_variant(change.get("parsed_value")),
			"new_value": _stringify_audio_variant(new_value),
			"new_type": Variant.get_type_name(typeof(new_value)),
			"old_value": _stringify_audio_variant(old_value),
			"old_type": Variant.get_type_name(typeof(old_value)),
		}
		if change.has("stream_path"):
			entry["stream_path"] = change["stream_path"]
		serialized.append(entry)
	return serialized

func _stringify_audio_variant(value) -> String:
	if value == null:
		return "null"
	if value is Resource:
		var resource := value as Resource
		var path := resource.resource_path
		if path.is_empty():
			return "%s (unsaved)" % resource.get_class()
		return "%s (%s)" % [resource.get_class(), path]
	return str(value)

func _load_audio_stream_for_interactive_clip(stream_request, _resource_path: String) -> Dictionary:
	if stream_request == null:
		return {
			"ok": true,
			"stream": null,
			"path": "",
			"cleared": true,
		}

	match typeof(stream_request):
		TYPE_STRING, TYPE_STRING_NAME:
			var stream_path := String(stream_request)
			if stream_path.is_empty():
				return {
					"ok": false,
					"error_message": "Audio stream path cannot be empty",
					"path": stream_path,
				}
			var normalized_path := _normalize_resource_path(stream_path)
			if not ResourceLoader.exists(normalized_path):
				return {
					"ok": false,
					"error_message": "Audio stream resource not found: %s" % normalized_path,
					"path": normalized_path,
				}
			var loaded_stream := ResourceLoader.load(normalized_path)
			if not loaded_stream or not (loaded_stream is AudioStream):
				return {
					"ok": false,
					"error_message": "Resource is not an AudioStream: %s" % normalized_path,
					"path": normalized_path,
				}
			return {
				"ok": true,
				"stream": loaded_stream,
				"path": normalized_path,
				"cleared": false,
			}
		TYPE_OBJECT:
			if stream_request is AudioStream:
				var audio_stream := stream_request as AudioStream
				var resolved_path := audio_stream.resource_path
				return {
					"ok": true,
					"stream": audio_stream,
					"path": resolved_path,
					"cleared": false,
				}
			return {
				"ok": false,
				"error_message": "Interactive music stream override must be an AudioStream resource",
				"path": "",
			}
		TYPE_DICTIONARY:
			var dict_request: Dictionary = stream_request
			if dict_request.has("path"):
				return _load_audio_stream_for_interactive_clip(dict_request["path"], resource_path)
			if dict_request.has("stream") and dict_request["stream"] is AudioStream:
				return _load_audio_stream_for_interactive_clip(dict_request["stream"], resource_path)
			if dict_request.has("resource") and dict_request["resource"] is AudioStream:
				return _load_audio_stream_for_interactive_clip(dict_request["resource"], resource_path)
			return {
				"ok": false,
				"error_message": "Interactive music stream dictionary must include a path or AudioStream resource",
				"path": "",
			}
		TYPE_INT, TYPE_FLOAT:
			return {
				"ok": false,
				"error_message": "Audio stream descriptor must not be numeric",
				"path": "",
			}
		_:
			return {
				"ok": false,
				"error_message": "Unsupported audio stream descriptor",
				"path": "",
			}

func _parse_interactive_enum_value(value, enum_maps: Dictionary, field_name: String) -> Dictionary:
	var forward: Dictionary = enum_maps.get("forward", {})
	var reverse: Dictionary = enum_maps.get("reverse", {})
	if forward.is_empty() and reverse.is_empty():
		return {
			"ok": false,
			"error_message": "Interactive music enums are unavailable for %s" % field_name,
		}

	if value == null:
		return {
			"ok": false,
			"error_message": "%s value cannot be null" % field_name,
		}

	match typeof(value):
		TYPE_STRING, TYPE_STRING_NAME:
			var normalized_key := String(value).strip_edges().to_lower()
			if forward.has(normalized_key):
				return {
					"ok": true,
					"value": forward[normalized_key],
					"label": normalized_key,
				}
			return {
				"ok": false,
				"error_message": "Unknown %s: %s" % [field_name, value],
			}
		TYPE_INT:
			var int_value := int(value)
			if reverse.has(int_value):
				return {
					"ok": true,
					"value": int_value,
					"label": reverse[int_value],
				}
			return {
				"ok": false,
				"error_message": "Unsupported %s value: %d" % [field_name, int_value],
			}
		TYPE_FLOAT:
			var float_value := float(value)
			var rounded := int(float_value)
			if float_value != float(rounded):
				return {
					"ok": false,
					"error_message": "%s must be an integer" % field_name,
				}
			return _parse_interactive_enum_value(rounded, enum_maps, field_name)
		TYPE_DICTIONARY:
			var dict_value: Dictionary = value
			if dict_value.has("value"):
				return _parse_interactive_enum_value(dict_value["value"], enum_maps, field_name)
			if dict_value.has("name"):
				return _parse_interactive_enum_value(dict_value["name"], enum_maps, field_name)
			return {
				"ok": false,
				"error_message": "Dictionary enum descriptor for %s must include `value` or `name`" % field_name,
			}
		_:
			return {
				"ok": false,
				"error_message": "Unsupported %s descriptor" % field_name,
			}

func _resolve_interactive_clip_reference(reference, clip_name_map: Dictionary, clip_count: int, allow_any: bool, clip_any_constant: int) -> Dictionary:
	if reference == null:
		return {
			"ok": false,
			"error_message": "Clip reference is required",
		}

	match typeof(reference):
		TYPE_INT:
			var int_index := int(reference)
			if allow_any and int_index == clip_any_constant:
				return {
					"ok": true,
					"index": clip_any_constant,
					"label": "any",
				}
			if int_index >= 0 and int_index < clip_count:
				return {
					"ok": true,
					"index": int_index,
					"label": str(int_index),
				}
			return {
				"ok": false,
				"error_message": "Clip index %d is out of range" % int_index,
			}
		TYPE_FLOAT:
			var float_index := float(reference)
			var rounded := int(float_index)
			if float_index != float(rounded):
				return {
					"ok": false,
					"error_message": "Clip index must be an integer",
				}
			return _resolve_interactive_clip_reference(rounded, clip_name_map, clip_count, allow_any, clip_any_constant)
		TYPE_STRING, TYPE_STRING_NAME:
			var clip_name := String(reference)
			var normalized := clip_name.strip_edges()
			if allow_any and normalized.to_lower() == "any":
				return {
					"ok": true,
					"index": clip_any_constant,
					"label": "any",
				}
			if clip_name_map.has(normalized):
				return {
					"ok": true,
					"index": clip_name_map[normalized],
					"label": normalized,
				}
			var lower_name := normalized.to_lower()
			if clip_name_map.has(lower_name):
				return {
					"ok": true,
					"index": clip_name_map[lower_name],
					"label": normalized,
				}
			if clip_name_map.has(clip_name):
				return {
					"ok": true,
					"index": clip_name_map[clip_name],
					"label": clip_name,
				}
			return {
				"ok": false,
				"error_message": "Unknown clip name: %s" % clip_name,
			}
		TYPE_DICTIONARY:
			var dict_ref: Dictionary = reference
			if dict_ref.has("index"):
				return _resolve_interactive_clip_reference(dict_ref["index"], clip_name_map, clip_count, allow_any, clip_any_constant)
			if dict_ref.has("name"):
				return _resolve_interactive_clip_reference(dict_ref["name"], clip_name_map, clip_count, allow_any, clip_any_constant)
			return {
				"ok": false,
				"error_message": "Clip dictionary reference must include `index` or `name`",
			}
		_:
			return {
				"ok": false,
				"error_message": "Unsupported clip reference",
			}

func _interactive_clip_label(index: int, clip_display_names: Array, clip_any_constant: int) -> String:
	if index == clip_any_constant:
		return "any"
	if index >= 0 and index < clip_display_names.size():
		return String(clip_display_names[index])
	return str(index)

func _get_interactive_auto_advance_maps() -> Dictionary:
	return _build_interactive_enum_map([
		{"constant": "AUTO_ADVANCE_DISABLED", "labels": ["disabled", "off"]},
		{"constant": "AUTO_ADVANCE_ENABLED", "labels": ["enabled", "on"]},
		{"constant": "AUTO_ADVANCE_RETURN_TO_HOLD", "labels": ["return_to_hold", "return", "hold"]},
	])

func _get_interactive_transition_from_time_maps() -> Dictionary:
	return _build_interactive_enum_map([
		{"constant": "TRANSITION_FROM_TIME_IMMEDIATE", "labels": ["immediate"]},
		{"constant": "TRANSITION_FROM_TIME_NEXT_BEAT", "labels": ["next_beat", "beat"]},
		{"constant": "TRANSITION_FROM_TIME_NEXT_BAR", "labels": ["next_bar", "bar"]},
		{"constant": "TRANSITION_FROM_TIME_END", "labels": ["end"]},
	])

func _get_interactive_transition_to_time_maps() -> Dictionary:
	return _build_interactive_enum_map([
		{"constant": "TRANSITION_TO_TIME_SAME_POSITION", "labels": ["same_position", "position"]},
		{"constant": "TRANSITION_TO_TIME_START", "labels": ["start"]},
	])

func _get_interactive_fade_mode_maps() -> Dictionary:
	return _build_interactive_enum_map([
		{"constant": "FADE_DISABLED", "labels": ["disabled", "none"]},
		{"constant": "FADE_IN", "labels": ["fade_in", "in"]},
		{"constant": "FADE_OUT", "labels": ["fade_out", "out"]},
		{"constant": "FADE_CROSS", "labels": ["cross", "crossfade"]},
		{"constant": "FADE_AUTOMATIC", "labels": ["automatic", "auto"]},
	])

func _get_interactive_clip_any_constant() -> int:
	if not ClassDB.class_exists("AudioStreamInteractive"):
		return -1
	return ClassDB.get_integer_constant("AudioStreamInteractive", "CLIP_ANY")

func _build_interactive_enum_map(entries: Array) -> Dictionary:
	var forward: Dictionary = {}
	var reverse: Dictionary = {}
	if not ClassDB.class_exists("AudioStreamInteractive"):
		return {
			"forward": forward,
			"reverse": reverse,
		}

	for entry in entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var constant_name := String(entry.get("constant", ""))
		if constant_name.is_empty():
			continue
		var labels := entry.get("labels", [])
		if typeof(labels) != TYPE_ARRAY:
			continue
		var constant_value := ClassDB.get_integer_constant("AudioStreamInteractive", constant_name)
		var primary_label := ""
		for label in labels:
			var normalized_label := String(label).strip_edges().to_lower()
			if normalized_label.is_empty():
				continue
			forward[normalized_label] = constant_value
			if primary_label == "":
				primary_label = normalized_label
		if primary_label != "":
			reverse[constant_value] = primary_label

	return {
		"forward": forward,
		"reverse": reverse,
	}

func _normalize_resource_path(path: String) -> String:
	if path.is_empty():
		return path
	if path.begins_with("res://") or path.begins_with("user://"):
		return path
	return "res://" + path

func _material_has_property(material: Object, property_name: String) -> bool:
	if material == null:
		return false
	var property_list: Array = material.get_property_list()
	for property_info in property_list:
		if typeof(property_info) != TYPE_DICTIONARY:
			continue
		if String(property_info.get("name", "")) == property_name:
			return true
	return false

func _resolve_material_input_value(raw_value) -> Dictionary:
	var result := {"ok": true, "value": raw_value}
	var value_type := typeof(raw_value)
	match value_type:
		TYPE_DICTIONARY:
			var dict_value: Dictionary = raw_value
			if dict_value.has("resource_path") or dict_value.has("path"):
				var resource_path := String(dict_value.get("resource_path", dict_value.get("path", "")))
				resource_path = _normalize_resource_path(resource_path)
				if resource_path.is_empty():
					return {"ok": false, "error_message": "Resource path cannot be empty"}
				var resource := ResourceLoader.load(resource_path)
				if resource == null:
					return {"ok": false, "error_message": "Resource not found: %s" % resource_path}
				var expected_class := String(dict_value.get("expected_class", "")).strip_edges()
				if not expected_class.is_empty() and not resource.is_class(expected_class):
					return {
						"ok": false,
						"error_message": "Resource at %s is not of type %s" % [resource_path, expected_class],
					}
				result["value"] = resource
				result["resource_path"] = resource_path
				result["resource_class"] = resource.get_class()
				return result
			if dict_value.has("value") and dict_value.size() == 1:
				return _resolve_material_input_value(dict_value["value"])
			result["value"] = dict_value.duplicate(true)
			return result
		TYPE_ARRAY:
			result["value"] = raw_value.duplicate(true)
			return result
		TYPE_STRING, TYPE_STRING_NAME:
			result["value"] = _parse_property_value(raw_value)
			return result
		TYPE_OBJECT:
			result["value"] = raw_value
			return result
		_:
			result["value"] = _parse_property_value(raw_value)
			return result

func _stringify_variant(value) -> String:
	var value_type := typeof(value)
	match value_type:
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return value ? "true" : "false"
		TYPE_DICTIONARY, TYPE_ARRAY:
			return JSON.stringify(value)
		TYPE_OBJECT:
			if value == null:
				return "null"
			if value is Resource:
				var resource: Resource = value
				if not resource.resource_path.is_empty():
					return "%s(%s)" % [resource.get_class(), resource.resource_path]
				return resource.get_class()
			return value.get_class()
		_:
			return str(value)

func _sanitize_metadata_dictionary(data) -> Variant:
	var data_type := typeof(data)
	match data_type:
		TYPE_DICTIONARY:
			var sanitized := {}
			for key in data.keys():
				sanitized[key] = _sanitize_metadata_dictionary(data[key])
			return sanitized
		TYPE_ARRAY:
			var sanitized_array: Array = []
			for element in data:
				sanitized_array.append(_sanitize_metadata_dictionary(element))
			return sanitized_array
		TYPE_OBJECT:
			if data is Resource:
				var resource: Resource = data
				if not resource.resource_path.is_empty():
					return resource.resource_path
				return resource.get_class()
			return data.get_class()
		_:
			return data

func _is_supported_audio_stream_player(node: Node) -> bool:
	if node is AudioStreamPlayer:
		return true
	var class_name := node.get_class()
	return class_name == "AudioStreamPlayer2D" or class_name == "AudioStreamPlayer3D" or class_name == "AudioStreamPlayerMicrophone"

func _configure_csg_shape(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := String(params.get("node_path", ""))
	var properties_param = params.get("properties", {})
	var transaction_id := String(params.get("transaction_id", ""))

	if node_path.is_empty():
		_log(
			"Node path cannot be empty for CSG configuration",
			"_configure_csg_shape",
			{"command": "configure_csg_shape", "client_id": client_id, "command_id": command_id, "system_section": "csg"},
			true
		)
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if typeof(properties_param) != TYPE_DICTIONARY:
		_log(
			"CSG configuration requires a dictionary of properties",
			"_configure_csg_shape",
			{
				"command": "configure_csg_shape",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "csg",
			},
			true
		)
		return _send_error(client_id, "CSG configuration requires a dictionary of properties", command_id)

	var properties: Dictionary = properties_param.duplicate(true)
	if properties.is_empty():
		_log(
			"No properties provided for CSG configuration",
			"_configure_csg_shape",
			{
				"command": "configure_csg_shape",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "csg",
			},
			true
		)
		return _send_error(client_id, "No properties provided for CSG configuration", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		_log(
			"Target node not found for CSG configuration",
			"_configure_csg_shape",
			{
				"command": "configure_csg_shape",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "csg",
			},
			true
		)
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not _is_csg_node(node):
		_log(
			"Node is not a supported CSG shape",
			"_configure_csg_shape",
			{
				"command": "configure_csg_shape",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "csg",
			},
			true
		)
		return _send_error(client_id, "Node at path is not a CSG shape", command_id)

	var classification := _classify_csg_node(node)
	var resolved_node_path := _node_path_to_string(node, node_path)
	var transaction_metadata := {
		"command": "configure_csg_shape",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
		"dimension": classification.get("dimension", "unknown"),
		"node_type": node.get_class(),
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure CSG Shape", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure CSG Shape", transaction_metadata)

	if not transaction:
		_log(
			"Failed to obtain scene transaction for CSG configuration",
			"_configure_csg_shape",
			{
				"command": "configure_csg_shape",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "csg",
			},
			true
		)
		return _send_error(client_id, "Failed to obtain scene transaction for CSG configuration", command_id)

	var property_changes: Array = []
	for property_name in properties.keys():
		if not _has_property(node, property_name):
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"Node is missing requested CSG property",
				"_configure_csg_shape",
				{
					"command": "configure_csg_shape",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"property": property_name,
					"node_type": node.get_class(),
					"system_section": "csg",
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

	var log_payload := {
		"command": "configure_csg_shape",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
		"dimension": classification.get("dimension", "unknown"),
		"system_section": "csg",
		"client_id": client_id,
		"command_id": command_id,
		"change_count": property_changes.size(),
		"transaction_id": transaction.transaction_id,
	}

	var serialized_changes: Array = []
	for change in property_changes:
		transaction.add_do_property(node, change["property"], change["new_value"])
		transaction.add_undo_property(node, change["property"], change["old_value"])
		serialized_changes.append({
			"property": change["property"],
			"input_value": change["input_value"],
			"new_value": str(change["new_value"]),
			"new_type": Variant.get_type_name(typeof(change["new_value"])),
			"old_value": str(change["old_value"]),
			"old_type": Variant.get_type_name(typeof(change["old_value"])),
		})

	var commit_changes := []
	for change in serialized_changes:
		commit_changes.append(change.duplicate(true))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Committed CSG configuration", "_configure_csg_shape", payload)
	)

	transaction.register_on_rollback(func():
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Rolled back CSG configuration", "_configure_csg_shape", payload)
	)

	if property_changes.is_empty():
		if transaction_id.is_empty():
			transaction.rollback()
		_log("No CSG property changes were required", "_configure_csg_shape", log_payload)
		return _send_success(client_id, {
			"node_path": resolved_node_path,
			"requested_path": node_path,
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
				"Failed to commit CSG configuration",
				"_configure_csg_shape",
				log_payload,
				true
			)
			return _send_error(client_id, "Failed to commit CSG configuration", command_id)
		status = "committed"

	_send_success(client_id, {
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
		"dimension": classification.get("dimension", "unknown"),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
		"status": status,
	}, command_id)

func _configure_material_resource(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_configure_material_resource"
	var command_identifier := "configure_material_resource"
	var materials_section := "%s.materials" % DEFAULT_SYSTEM_SECTION
	var log_context := {
		"command": command_identifier,
		"client_id": client_id,
		"command_id": command_id,
		"system_section": materials_section,
	}

	var resource_path := String(params.get("resource_path", ""))
	if resource_path.is_empty():
		_log("Material resource path is required", function_name, log_context, true)
		return _send_error(client_id, "Material resource path is required", command_id)

	resource_path = _normalize_resource_path(resource_path)
	if not resource_path.ends_with(".tres") and not resource_path.ends_with(".res"):
		resource_path += ".tres"

	var directory_path := ""
	var slash_index := resource_path.rfind("/")
	if slash_index != -1:
		directory_path = resource_path.substr(0, slash_index)
	if not directory_path.is_empty():
		var make_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory_path))
		if make_error != OK and make_error != ERR_ALREADY_EXISTS:
			var dir_payload := log_context.duplicate(true)
			dir_payload["resource_path"] = resource_path
			dir_payload["directory_path"] = directory_path
			dir_payload["error_code"] = make_error
			_log("Failed to ensure directory for material resource", function_name, dir_payload, true)
			return _send_error(client_id, "Failed to prepare directory for material resource", command_id)

	var existing_resource: Resource = null
	if ResourceLoader.exists(resource_path):
		existing_resource = ResourceLoader.load(resource_path)
		if existing_resource == null:
			var load_payload := log_context.duplicate(true)
			load_payload["resource_path"] = resource_path
			_log("Failed to load existing material resource", function_name, load_payload, true)
			return _send_error(client_id, "Failed to load existing material resource", command_id)

	var material_type := String(params.get("material_type", ""))
	var material: Material = null
	var created_new := false

	if existing_resource:
		if not (existing_resource is Material):
			var type_payload := log_context.duplicate(true)
			type_payload["resource_path"] = resource_path
			type_payload["resource_class"] = existing_resource.get_class()
			_log("Existing resource is not a Material", function_name, type_payload, true)
			return _send_error(client_id, "Existing resource is not a Material", command_id)
		material = existing_resource
		material_type = material.get_class()
	else:
		if material_type.is_empty():
			material_type = "StandardMaterial3D"
		if not ClassDB.class_exists(material_type):
			var type_payload := log_context.duplicate(true)
			type_payload["resource_path"] = resource_path
			type_payload["requested_type"] = material_type
			_log("Requested material type does not exist", function_name, type_payload, true)
			return _send_error(client_id, "Material type does not exist: %s" % material_type, command_id)
		var instance = ClassDB.instantiate(material_type)
		if instance == null:
			var type_payload := log_context.duplicate(true)
			type_payload["resource_path"] = resource_path
			type_payload["requested_type"] = material_type
			_log("Failed to instantiate requested material type", function_name, type_payload, true)
			return _send_error(client_id, "Failed to instantiate material type: %s" % material_type, command_id)
		if not (instance is Material):
			var type_payload := log_context.duplicate(true)
			type_payload["resource_path"] = resource_path
			type_payload["requested_type"] = material_type
			_log("Requested class does not inherit from Material", function_name, type_payload, true)
			return _send_error(client_id, "Requested class does not inherit from Material", command_id)
		material = instance
		created_new = true

	var change_records: Array = []
	if created_new:
		change_records.append({
			"type": "material_created",
			"material_type": material.get_class(),
			"new_value": material.get_class(),
			"old_value": "",
			"new_type": material.get_class(),
			"old_type": "",
		})

	var requested_name = params.get("resource_name", null)
	if requested_name != null:
		var resolved_name := String(requested_name)
		if material.resource_name != resolved_name:
			var old_name := material.resource_name
			material.resource_name = resolved_name
			change_records.append({
				"type": "resource_name",
				"property": "resource_name",
				"input_value": resolved_name,
				"new_value": resolved_name,
				"old_value": old_name,
				"new_type": "String",
				"old_type": "String",
			})

	var metadata_param = params.get("metadata", null)
	if metadata_param != null:
		if typeof(metadata_param) != TYPE_DICTIONARY:
			var metadata_payload := log_context.duplicate(true)
			metadata_payload["resource_path"] = resource_path
			_log("Material metadata must be a dictionary", function_name, metadata_payload, true)
			return _send_error(client_id, "Material metadata must be a dictionary", command_id)
		var metadata_dict: Dictionary = metadata_param
		for meta_key in metadata_dict.keys():
			var meta_value = metadata_dict[meta_key]
			var existing_meta := material.has_meta(meta_key) ? material.get_meta(meta_key) : null
			if existing_meta == meta_value:
				continue
			material.set_meta(meta_key, meta_value)
			change_records.append({
				"type": "metadata",
				"property": String(meta_key),
				"input_value": _stringify_variant(meta_value),
				"new_value": _stringify_variant(meta_value),
				"old_value": _stringify_variant(existing_meta),
				"new_type": Variant.get_type_name(typeof(meta_value)),
				"old_type": Variant.get_type_name(typeof(existing_meta)),
			})

	var material_properties_param = params.get("material_properties", null)
	if material_properties_param != null:
		if typeof(material_properties_param) != TYPE_DICTIONARY:
			var properties_payload := log_context.duplicate(true)
			properties_payload["resource_path"] = resource_path
			_log("Material properties must be provided as a dictionary", function_name, properties_payload, true)
			return _send_error(client_id, "Material properties must be provided as a dictionary", command_id)
		var properties_dict: Dictionary = material_properties_param
		for property_name in properties_dict.keys():
			var normalized_property := String(property_name)
			if not _material_has_property(material, normalized_property):
				var missing_payload := log_context.duplicate(true)
				missing_payload["resource_path"] = resource_path
				missing_payload["property"] = normalized_property
				_log("Material does not expose requested property", function_name, missing_payload, true)
				return _send_error(client_id, "Material missing property: %s" % normalized_property, command_id)
			var raw_value = properties_dict[property_name]
			var resolved_value := _resolve_material_input_value(raw_value)
			if not resolved_value.get("ok", false):
				var resolution_payload := log_context.duplicate(true)
				resolution_payload["resource_path"] = resource_path
				resolution_payload["property"] = normalized_property
				resolution_payload["error_message"] = resolved_value.get("error_message", "resolution_failed")
				_log("Failed to resolve material property value", function_name, resolution_payload, true)
				return _send_error(client_id, String(resolution_payload["error_message"]), command_id)
			var parsed_value = resolved_value.get("value", null)
			var old_value = material.get(normalized_property)
			var coerced_value = _coerce_property_value(old_value, parsed_value)
			if old_value == coerced_value:
				continue
			material.set(normalized_property, coerced_value)
			var change := {
				"type": "property",
				"property": normalized_property,
				"input_value": _stringify_variant(raw_value),
				"parsed_value": _stringify_variant(parsed_value),
				"new_value": _stringify_variant(coerced_value),
				"old_value": _stringify_variant(old_value),
				"new_type": Variant.get_type_name(typeof(coerced_value)),
				"old_type": Variant.get_type_name(typeof(old_value)),
			}
			if resolved_value.has("resource_path"):
				change["resource_path"] = resolved_value["resource_path"]
			if resolved_value.has("resource_class"):
				change["resource_class"] = resolved_value["resource_class"]
			change_records.append(change)

	var glslang_config = params.get("glslang_shader", {})
	if typeof(glslang_config) != TYPE_DICTIONARY:
		glslang_config = {}
	var shader_code := String(glslang_config.get("code", params.get("shader_code", "")))
	var shader_path := String(glslang_config.get("path", params.get("shader_path", "")))
	var shader_resource: Shader = null

	if not shader_path.is_empty():
		shader_path = _normalize_resource_path(shader_path)
		var shader_loaded = ResourceLoader.load(shader_path)
		if shader_loaded == null or not (shader_loaded is Shader):
			var shader_payload := log_context.duplicate(true)
			shader_payload["resource_path"] = resource_path
			shader_payload["shader_path"] = shader_path
			_log("Shader resource was not found or is not a Shader", function_name, shader_payload, true)
			return _send_error(client_id, "Shader resource not found or invalid", command_id)
		shader_resource = shader_loaded
	elif not shader_code.is_empty():
		if not (material is ShaderMaterial):
			var shader_payload := log_context.duplicate(true)
			shader_payload["resource_path"] = resource_path
			shader_payload["material_type"] = material.get_class()
			_log("Shader code can only be applied to ShaderMaterial resources", function_name, shader_payload, true)
			return _send_error(client_id, "Shader code requires a ShaderMaterial", command_id)
		shader_resource = (material as ShaderMaterial).shader
		if shader_resource == null:
			shader_resource = Shader.new()
		var previous_code := String(shader_resource.code)
		if previous_code != shader_code:
			shader_resource.code = shader_code
			change_records.append({
				"type": "shader_code",
				"property": "shader.code",
				"input_value": str(shader_code.length()),
				"parsed_value": str(shader_code.length()),
				"new_value": str(shader_code.length()),
				"old_value": str(previous_code.length()),
				"new_type": "String",
				"old_type": "String",
			})
	
	if shader_resource != null:
		if not (material is ShaderMaterial):
			var shader_payload := log_context.duplicate(true)
			shader_payload["resource_path"] = resource_path
			shader_payload["material_type"] = material.get_class()
			_log("Shader assignment requires a ShaderMaterial", function_name, shader_payload, true)
			return _send_error(client_id, "Shader assignment requires a ShaderMaterial", command_id)
		var shader_material := material as ShaderMaterial
		var previous_shader := shader_material.shader
		if previous_shader != shader_resource:
			var previous_path := ""
			if previous_shader != null:
				previous_path = previous_shader.resource_path
				if previous_path.is_empty():
					previous_path = "inline"
			var new_shader_path := shader_resource.resource_path
			if new_shader_path.is_empty():
				new_shader_path = "inline"
			shader_material.shader = shader_resource
			change_records.append({
				"type": "shader_reference",
				"property": "shader",
				"input_value": shader_path.is_empty() ? "inline" : shader_path,
				"parsed_value": shader_path.is_empty() ? "inline" : shader_path,
				"new_value": new_shader_path,
				"old_value": previous_path,
				"new_type": shader_resource.get_class(),
				"old_type": previous_shader and previous_shader.get_class() or "",
			})

	var glslang_metadata = glslang_config.get("metadata", {})
	if typeof(glslang_metadata) == TYPE_DICTIONARY and not glslang_metadata.is_empty():
		var previous_metadata := material.has_meta("glslang_metadata") ? material.get_meta("glslang_metadata") : {}
		if previous_metadata != glslang_metadata:
			material.set_meta("glslang_metadata", glslang_metadata.duplicate(true))
			change_records.append({
				"type": "metadata",
				"property": "glslang_metadata",
				"input_value": JSON.stringify(glslang_metadata),
				"new_value": JSON.stringify(glslang_metadata),
				"old_value": JSON.stringify(previous_metadata),
				"new_type": "Dictionary",
				"old_type": "Dictionary",
			})

	var shader_parameter_sources: Dictionary = {}
	var shader_parameters_param = params.get("shader_parameters", null)
	if typeof(shader_parameters_param) == TYPE_DICTIONARY:
		shader_parameter_sources = shader_parameters_param.duplicate(true)
	if glslang_config.has("parameters") and typeof(glslang_config["parameters"]) == TYPE_DICTIONARY:
		var glslang_parameters: Dictionary = glslang_config["parameters"]
		for key in glslang_parameters.keys():
				shader_parameter_sources[key] = glslang_parameters[key]

	if not shader_parameter_sources.is_empty():
		if not (material is ShaderMaterial):
			var shader_payload := log_context.duplicate(true)
			shader_payload["resource_path"] = resource_path
			shader_payload["material_type"] = material.get_class()
			_log("Shader parameters are only supported on ShaderMaterial resources", function_name, shader_payload, true)
			return _send_error(client_id, "Shader parameters require a ShaderMaterial", command_id)
		var shader_material := material as ShaderMaterial
		if shader_material.shader == null:
			var shader_payload := log_context.duplicate(true)
			shader_payload["resource_path"] = resource_path
			_log("Shader parameters cannot be applied without an assigned shader", function_name, shader_payload, true)
			return _send_error(client_id, "Assign a shader before configuring shader parameters", command_id)
		for parameter_name in shader_parameter_sources.keys():
			var raw_value = shader_parameter_sources[parameter_name]
			var resolved := _resolve_material_input_value(raw_value)
			if not resolved.get("ok", false):
				var resolution_payload := log_context.duplicate(true)
				resolution_payload["resource_path"] = resource_path
				resolution_payload["parameter"] = String(parameter_name)
				resolution_payload["error_message"] = resolved.get("error_message", "resolution_failed")
				_log("Failed to resolve shader parameter value", function_name, resolution_payload, true)
				return _send_error(client_id, String(resolution_payload["error_message"]), command_id)
			var parsed_value = resolved.get("value", null)
			if not shader_material.shader.has_param(parameter_name):
				var missing_payload := log_context.duplicate(true)
				missing_payload["resource_path"] = resource_path
				missing_payload["parameter"] = String(parameter_name)
				_log("Shader does not expose requested parameter", function_name, missing_payload, true)
				return _send_error(client_id, "Shader does not expose parameter: %s" % String(parameter_name), command_id)
			var old_value = shader_material.get_shader_parameter(parameter_name)
			if old_value == parsed_value:
				continue
			shader_material.set_shader_parameter(parameter_name, parsed_value)
			var change := {
				"type": "shader_parameter",
				"parameter": String(parameter_name),
				"input_value": _stringify_variant(raw_value),
				"parsed_value": _stringify_variant(parsed_value),
				"new_value": _stringify_variant(parsed_value),
				"old_value": _stringify_variant(old_value),
				"new_type": Variant.get_type_name(typeof(parsed_value)),
				"old_type": Variant.get_type_name(typeof(old_value)),
			}
			if resolved.has("resource_path"):
				change["resource_path"] = resolved["resource_path"]
			if resolved.has("resource_class"):
				change["resource_class"] = resolved["resource_class"]
			change_records.append(change)

	var lightmapper_config = params.get("lightmapper_rd", {})
	if typeof(lightmapper_config) == TYPE_DICTIONARY:
		var lightmapper_textures = lightmapper_config.get("texture_slots", {})
		if typeof(lightmapper_textures) == TYPE_DICTIONARY:
			for slot_name in lightmapper_textures.keys():
				var raw_value = lightmapper_textures[slot_name]
				var resolved := _resolve_material_input_value(raw_value)
				if not resolved.get("ok", false):
					var texture_payload := log_context.duplicate(true)
					texture_payload["resource_path"] = resource_path
					texture_payload["slot"] = String(slot_name)
					texture_payload["error_message"] = resolved.get("error_message", "resolution_failed")
					_log("Failed to resolve lightmapper texture", function_name, texture_payload, true)
					return _send_error(client_id, String(texture_payload["error_message"]), command_id)
				var texture_value = resolved.get("value", null)
				var applied := false
				if material is ShaderMaterial:
					var shader_material := material as ShaderMaterial
					if not shader_material.shader.has_param(slot_name):
						var shader_slot_payload := log_context.duplicate(true)
						shader_slot_payload["resource_path"] = resource_path
						shader_slot_payload["slot"] = String(slot_name)
						_log("Shader does not expose requested lightmapper texture parameter", function_name, shader_slot_payload, true)
						return _send_error(client_id, "Shader missing texture parameter: %s" % String(slot_name), command_id)
					var previous_texture := shader_material.get_shader_parameter(slot_name)
					if previous_texture == texture_value:
						continue
					shader_material.set_shader_parameter(slot_name, texture_value)
					applied = true
					change_records.append({
						"type": "lightmapper_texture",
						"parameter": String(slot_name),
						"input_value": _stringify_variant(raw_value),
						"parsed_value": _stringify_variant(texture_value),
						"new_value": _stringify_variant(texture_value),
						"old_value": _stringify_variant(previous_texture),
						"new_type": Variant.get_type_name(typeof(texture_value)),
						"old_type": Variant.get_type_name(typeof(previous_texture)),
						"resource_path": resolved.get("resource_path", ""),
						"resource_class": resolved.get("resource_class", ""),
					})
				elif _material_has_property(material, String(slot_name)):
					var old_value = material.get(String(slot_name))
					if old_value == texture_value:
						continue
					material.set(String(slot_name), texture_value)
					applied = true
					var change := {
						"type": "lightmapper_texture",
						"property": String(slot_name),
						"input_value": _stringify_variant(raw_value),
						"parsed_value": _stringify_variant(texture_value),
						"new_value": _stringify_variant(texture_value),
						"old_value": _stringify_variant(old_value),
						"new_type": Variant.get_type_name(typeof(texture_value)),
						"old_type": Variant.get_type_name(typeof(old_value)),
					}
					if resolved.has("resource_path"):
						change["resource_path"] = resolved["resource_path"]
					if resolved.has("resource_class"):
						change["resource_class"] = resolved["resource_class"]
					change_records.append(change)
				else:
					var texture_payload := log_context.duplicate(true)
					texture_payload["resource_path"] = resource_path
					texture_payload["slot"] = String(slot_name)
					_log("Material cannot accept requested lightmapper texture slot", function_name, texture_payload, true)
					return _send_error(client_id, "Material cannot accept lightmapper texture slot: %s" % String(slot_name), command_id)
				if applied:
					continue

		var lightmapper_scalars = lightmapper_config.get("scalar_parameters", {})
		if typeof(lightmapper_scalars) == TYPE_DICTIONARY:
			for scalar_name in lightmapper_scalars.keys():
				var raw_scalar = lightmapper_scalars[scalar_name]
				var resolved_scalar := _resolve_material_input_value(raw_scalar)
				if not resolved_scalar.get("ok", false):
					var scalar_payload := log_context.duplicate(true)
					scalar_payload["resource_path"] = resource_path
					scalar_payload["parameter"] = String(scalar_name)
					scalar_payload["error_message"] = resolved_scalar.get("error_message", "resolution_failed")
					_log("Failed to resolve lightmapper scalar", function_name, scalar_payload, true)
					return _send_error(client_id, String(scalar_payload["error_message"]), command_id)
				var scalar_value = resolved_scalar.get("value", null)
				var handled := false
				if material is ShaderMaterial:
					var shader_material := material as ShaderMaterial
					if not shader_material.shader.has_param(scalar_name):
						var scalar_slot_payload := log_context.duplicate(true)
						scalar_slot_payload["resource_path"] = resource_path
						scalar_slot_payload["parameter"] = String(scalar_name)
						_log("Shader does not expose requested lightmapper scalar parameter", function_name, scalar_slot_payload, true)
						return _send_error(client_id, "Shader missing scalar parameter: %s" % String(scalar_name), command_id)
					var previous_value := shader_material.get_shader_parameter(scalar_name)
					if previous_value == scalar_value:
						continue
					shader_material.set_shader_parameter(scalar_name, scalar_value)
					handled = true
					change_records.append({
						"type": "lightmapper_scalar",
						"parameter": String(scalar_name),
						"input_value": _stringify_variant(raw_scalar),
						"parsed_value": _stringify_variant(scalar_value),
						"new_value": _stringify_variant(scalar_value),
						"old_value": _stringify_variant(previous_value),
						"new_type": Variant.get_type_name(typeof(scalar_value)),
						"old_type": Variant.get_type_name(typeof(previous_value)),
					})
				elif _material_has_property(material, String(scalar_name)):
					var previous_value = material.get(String(scalar_name))
					if previous_value == scalar_value:
						continue
					material.set(String(scalar_name), scalar_value)
					handled = true
					change_records.append({
						"type": "lightmapper_scalar",
						"property": String(scalar_name),
						"input_value": _stringify_variant(raw_scalar),
						"parsed_value": _stringify_variant(scalar_value),
						"new_value": _stringify_variant(scalar_value),
						"old_value": _stringify_variant(previous_value),
						"new_type": Variant.get_type_name(typeof(scalar_value)),
						"old_type": Variant.get_type_name(typeof(previous_value)),
					})
				else:
					var scalar_payload := log_context.duplicate(true)
					scalar_payload["resource_path"] = resource_path
					scalar_payload["parameter"] = String(scalar_name)
					_log("Material cannot accept requested lightmapper scalar", function_name, scalar_payload, true)
					return _send_error(client_id, "Material cannot accept lightmapper scalar: %s" % String(scalar_name), command_id)

		var previous_lightmapper_meta := material.has_meta("lightmapper_rd") ? material.get_meta("lightmapper_rd") : {}
		var sanitized_lightmapper_meta := _sanitize_metadata_dictionary(lightmapper_config)
		if previous_lightmapper_meta != sanitized_lightmapper_meta:
			material.set_meta("lightmapper_rd", sanitized_lightmapper_meta)
			change_records.append({
				"type": "metadata",
				"property": "lightmapper_rd",
				"input_value": JSON.stringify(sanitized_lightmapper_meta),
				"new_value": JSON.stringify(sanitized_lightmapper_meta),
				"old_value": JSON.stringify(previous_lightmapper_meta),
				"new_type": "Dictionary",
				"old_type": "Dictionary",
			})

	var meshoptimizer_config = params.get("meshoptimizer", {})
	if typeof(meshoptimizer_config) == TYPE_DICTIONARY:
		var lod_array_param = meshoptimizer_config.get("lod_meshes", [])
		if typeof(lod_array_param) == TYPE_ARRAY:
			var lod_summaries: Array = []
			for lod_entry in lod_array_param:
				if typeof(lod_entry) != TYPE_DICTIONARY:
					continue
				var lod_dict: Dictionary = lod_entry
				var mesh_path := String(lod_dict.get("mesh_path", lod_dict.get("resource_path", lod_dict.get("path", ""))))
				mesh_path = _normalize_resource_path(mesh_path)
				if mesh_path.is_empty():
					continue
				var mesh_resource = ResourceLoader.load(mesh_path)
				if mesh_resource == null:
					var lod_payload := log_context.duplicate(true)
					lod_payload["resource_path"] = resource_path
					lod_payload["lod_mesh_path"] = mesh_path
					_log("Failed to load meshoptimizer LOD mesh", function_name, lod_payload, true)
					return _send_error(client_id, "Failed to load meshoptimizer LOD mesh: %s" % mesh_path, command_id)
				lod_summaries.append({
					"path": mesh_path,
					"class": mesh_resource.get_class(),
					"screen_ratio": float(lod_dict.get("screen_ratio", lod_dict.get("ratio", 0.0))),
				})
			if not lod_summaries.is_empty():
				var previous_lods := material.has_meta("meshoptimizer_lods") ? material.get_meta("meshoptimizer_lods") : []
				if previous_lods != lod_summaries:
					material.set_meta("meshoptimizer_lods", lod_summaries)
					change_records.append({
						"type": "metadata",
						"property": "meshoptimizer_lods",
						"input_value": JSON.stringify(lod_summaries),
						"new_value": JSON.stringify(lod_summaries),
						"old_value": JSON.stringify(previous_lods),
						"new_type": "Array",
						"old_type": "Array",
					})
		var previous_meshoptimizer_meta := material.has_meta("meshoptimizer_metadata") ? material.get_meta("meshoptimizer_metadata") : {}
		var sanitized_meshoptimizer_meta := _sanitize_metadata_dictionary(meshoptimizer_config)
		if previous_meshoptimizer_meta != sanitized_meshoptimizer_meta:
			material.set_meta("meshoptimizer_metadata", sanitized_meshoptimizer_meta)
			change_records.append({
				"type": "metadata",
				"property": "meshoptimizer_metadata",
				"input_value": JSON.stringify(sanitized_meshoptimizer_meta),
				"new_value": JSON.stringify(sanitized_meshoptimizer_meta),
				"old_value": JSON.stringify(previous_meshoptimizer_meta),
				"new_type": "Dictionary",
				"old_type": "Dictionary",
			})

	if change_records.is_empty():
		var noop_payload := log_context.duplicate(true)
		noop_payload["resource_path"] = resource_path
		noop_payload["material_type"] = material.get_class()
		_log("No material updates were required", function_name, noop_payload)
		return _send_success(client_id, {
			"resource_path": resource_path,
			"material_type": material.get_class(),
			"changes": [],
			"status": "no_changes",
		}, command_id)

	var save_error := ResourceSaver.save(material, resource_path)
	if save_error != OK:
		var save_payload := log_context.duplicate(true)
		save_payload["resource_path"] = resource_path
		save_payload["error_code"] = save_error
		_log("Failed to save material resource", function_name, save_payload, true)
		return _send_error(client_id, "Failed to save material resource", command_id)

	var log_payload := log_context.duplicate(true)
	log_payload["resource_path"] = resource_path
	log_payload["material_type"] = material.get_class()
	log_payload["created_new"] = created_new
	log_payload["change_count"] = change_records.size()
	log_payload["changes"] = change_records
	_log("Configured material resource", function_name, log_payload)

	_send_success(client_id, {
		"resource_path": resource_path,
		"material_type": material.get_class(),
		"created_new": created_new,
		"changes": change_records,
		"status": created_new ? "created" : "updated",
	}, command_id)

func _paint_gridmap_cells(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := String(params.get("node_path", ""))
	var cells_param = params.get("cells", [])
	var transaction_id := String(params.get("transaction_id", ""))

	if node_path.is_empty():
		_log(
			"GridMap painting requires a node path",
			"_paint_gridmap_cells",
			{"command": "paint_gridmap_cells", "client_id": client_id, "command_id": command_id, "system_section": "gridmap"},
			true
		)
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if typeof(cells_param) != TYPE_ARRAY:
		_log(
			"GridMap painting expects an array of cell dictionaries",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "GridMap updates require an array of cell definitions", command_id)

	var cells: Array = cells_param.duplicate(true)
	if cells.is_empty():
		_log(
			"GridMap painting received an empty cell list",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "No GridMap cells provided for update", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		_log(
			"GridMap node not found",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not (node is GridMap):
		_log(
			"Node is not a GridMap",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Node at path is not a GridMap", command_id)

	if not node.has_method("set_cell_item"):
		_log(
			"GridMap is missing set_cell_item method",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "GridMap does not support cell painting", command_id)

	var mesh_library = null
	if _has_property(node, "mesh_library"):
		mesh_library = node.mesh_library

	var resolved_node_path := _node_path_to_string(node, node_path)
	var transaction_metadata := {
		"command": "paint_gridmap_cells",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
		"cell_count": cells.size(),
		"node_type": node.get_class(),
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Paint GridMap Cells", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Paint GridMap Cells", transaction_metadata)

	if not transaction:
		_log(
			"Failed to obtain scene transaction for GridMap painting",
			"_paint_gridmap_cells",
			{
				"command": "paint_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Failed to obtain scene transaction for GridMap painting", command_id)

	var change_entries: Array = []
	for i in cells.size():
		var cell_entry = cells[i]
		if typeof(cell_entry) != TYPE_DICTIONARY:
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap cell entry must be a dictionary",
				"_paint_gridmap_cells",
				{
					"command": "paint_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "Each GridMap cell must be provided as a dictionary", command_id)

		var parsed_position = _parse_gridmap_position(cell_entry)
		if parsed_position.is_empty():
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap cell definition is missing position coordinates",
				"_paint_gridmap_cells",
				{
					"command": "paint_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "GridMap cell definition requires a position", command_id)

		if not cell_entry.has("item"):
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap cell definition is missing item identifier",
				"_paint_gridmap_cells",
				{
					"command": "paint_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "GridMap cell definition must include an item id", command_id)

		var item_value = _to_int(cell_entry.get("item"))
		if item_value == null:
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap cell item could not be converted to an integer",
				"_paint_gridmap_cells",
				{
					"command": "paint_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"raw_item": cell_entry.get("item"),
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "GridMap cell item must be an integer", command_id)

		var orientation_value = _to_int(cell_entry.get("orientation", 0))
		if orientation_value == null:
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap cell orientation could not be converted to an integer",
				"_paint_gridmap_cells",
				{
					"command": "paint_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"raw_orientation": cell_entry.get("orientation", 0),
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "GridMap cell orientation must be an integer", command_id)

		if item_value != GridMap.INVALID_CELL_ITEM:
			if mesh_library == null:
				if transaction_id.is_empty():
					transaction.rollback()
				_log(
					"GridMap mesh library is required to paint items",
					"_paint_gridmap_cells",
					{
						"command": "paint_gridmap_cells",
						"client_id": client_id,
						"command_id": command_id,
						"node_path": node_path,
						"index": i,
						"system_section": "gridmap",
					},
					true
				)
				return _send_error(client_id, "GridMap has no MeshLibrary configured", command_id)
			elif mesh_library.has_method("has_item") and not mesh_library.has_item(item_value):
				if transaction_id.is_empty():
					transaction.rollback()
				_log(
					"Requested GridMap item is not present in the mesh library",
					"_paint_gridmap_cells",
					{
						"command": "paint_gridmap_cells",
						"client_id": client_id,
						"command_id": command_id,
						"node_path": node_path,
						"index": i,
						"item": item_value,
						"system_section": "gridmap",
					},
					true
				)
				return _send_error(client_id, "MeshLibrary does not contain the requested item", command_id)

		var position_vector: Vector3i = parsed_position["vector"]
		var position_dict: Dictionary = parsed_position["components"].duplicate(true)
		var previous_item := node.has_method("get_cell_item") ? node.get_cell_item(position_vector) : GridMap.INVALID_CELL_ITEM
		var previous_orientation := 0
		if node.has_method("get_cell_item_orientation"):
			previous_orientation = node.get_cell_item_orientation(position_vector)

		if previous_item == item_value and previous_orientation == orientation_value:
			continue

		change_entries.append({
			"position": position_vector,
			"position_dict": position_dict,
			"previous_item": previous_item,
			"previous_orientation": previous_orientation,
			"item": item_value,
			"orientation": orientation_value,
		})

		transaction.add_do_method(node, "set_cell_item", [position_vector, item_value, orientation_value])
		transaction.add_undo_method(node, "set_cell_item", [position_vector, previous_item, previous_orientation])

	var log_payload := {
		"command": "paint_gridmap_cells",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
		"system_section": "gridmap",
		"client_id": client_id,
		"command_id": command_id,
		"requested_cells": cells.size(),
		"transaction_id": transaction.transaction_id,
	}

	var serialized_changes: Array = []
	for change in change_entries:
		serialized_changes.append({
			"position": change["position_dict"].duplicate(true),
			"previous_item": change["previous_item"],
			"previous_orientation": change["previous_orientation"],
			"item": change["item"],
			"orientation": change["orientation"],
		})

	log_payload["change_count"] = serialized_changes.size()

	var commit_changes := []
	for change in serialized_changes:
		commit_changes.append(change.duplicate(true))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Painted GridMap cells", "_paint_gridmap_cells", payload)
	)

	transaction.register_on_rollback(func():
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Rolled back GridMap painting", "_paint_gridmap_cells", payload)
	)

	if change_entries.is_empty():
		if transaction_id.is_empty():
			transaction.rollback()
		_log("No GridMap cell changes were required", "_paint_gridmap_cells", log_payload)
		return _send_success(client_id, {
			"node_path": resolved_node_path,
			"requested_path": node_path,
			"node_type": node.get_class(),
			"changes": [],
			"transaction_id": transaction.transaction_id,
			"status": "no_changes",
		}, command_id)

	var status := "pending"
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log(
				"Failed to commit GridMap painting",
				"_paint_gridmap_cells",
				log_payload,
				true
			)
			return _send_error(client_id, "Failed to commit GridMap painting", command_id)
		status = "committed"

	_send_success(client_id, {
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
		"status": status,
	}, command_id)

func _clear_gridmap_cells(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := String(params.get("node_path", ""))
	var cells_param = params.get("cells", [])
	var transaction_id := String(params.get("transaction_id", ""))

	if node_path.is_empty():
		_log(
			"GridMap clearing requires a node path",
			"_clear_gridmap_cells",
			{"command": "clear_gridmap_cells", "client_id": client_id, "command_id": command_id, "system_section": "gridmap"},
			true
		)
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if typeof(cells_param) != TYPE_ARRAY:
		_log(
			"GridMap clearing expects an array of positions",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "GridMap clearing requires an array of positions", command_id)

	var cells: Array = cells_param.duplicate(true)
	if cells.is_empty():
		_log(
			"GridMap clearing received an empty cell list",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "No GridMap cells provided for clearing", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		_log(
			"GridMap node not found",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not (node is GridMap):
		_log(
			"Node is not a GridMap",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Node at path is not a GridMap", command_id)

	if not node.has_method("set_cell_item"):
		_log(
			"GridMap is missing set_cell_item method",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "GridMap does not support cell clearing", command_id)

	var resolved_node_path := _node_path_to_string(node, node_path)
	var transaction_metadata := {
		"command": "clear_gridmap_cells",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
		"cell_count": cells.size(),
		"node_type": node.get_class(),
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Clear GridMap Cells", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Clear GridMap Cells", transaction_metadata)

	if not transaction:
		_log(
			"Failed to obtain scene transaction for GridMap clearing",
			"_clear_gridmap_cells",
			{
				"command": "clear_gridmap_cells",
				"client_id": client_id,
				"command_id": command_id,
				"node_path": node_path,
				"node_type": node.get_class(),
				"system_section": "gridmap",
			},
			true
		)
		return _send_error(client_id, "Failed to obtain scene transaction for GridMap clearing", command_id)

	var change_entries: Array = []
	for i in cells.size():
		var cell_entry = cells[i]
		var parsed_position = _parse_gridmap_position(cell_entry)
		if parsed_position.is_empty():
			if transaction_id.is_empty():
				transaction.rollback()
			_log(
				"GridMap clearing entry is missing position coordinates",
				"_clear_gridmap_cells",
				{
					"command": "clear_gridmap_cells",
					"client_id": client_id,
					"command_id": command_id,
					"node_path": node_path,
					"index": i,
					"system_section": "gridmap",
				},
				true
			)
			return _send_error(client_id, "GridMap clearing requires explicit positions", command_id)

		var position_vector: Vector3i = parsed_position["vector"]
		var position_dict: Dictionary = parsed_position["components"].duplicate(true)
		var previous_item := node.has_method("get_cell_item") ? node.get_cell_item(position_vector) : GridMap.INVALID_CELL_ITEM
		if previous_item == GridMap.INVALID_CELL_ITEM:
			continue

		var previous_orientation := 0
		if node.has_method("get_cell_item_orientation"):
			previous_orientation = node.get_cell_item_orientation(position_vector)

		change_entries.append({
			"position": position_vector,
			"position_dict": position_dict,
			"previous_item": previous_item,
			"previous_orientation": previous_orientation,
		})

		transaction.add_do_method(node, "set_cell_item", [position_vector, GridMap.INVALID_CELL_ITEM, 0])
		transaction.add_undo_method(node, "set_cell_item", [position_vector, previous_item, previous_orientation])

	var log_payload := {
		"command": "clear_gridmap_cells",
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
		"system_section": "gridmap",
		"client_id": client_id,
		"command_id": command_id,
		"requested_cells": cells.size(),
		"transaction_id": transaction.transaction_id,
	}

	var serialized_changes: Array = []
	for change in change_entries:
		serialized_changes.append({
			"position": change["position_dict"].duplicate(true),
			"cleared_item": change["previous_item"],
			"previous_orientation": change["previous_orientation"],
		})

	log_payload["change_count"] = serialized_changes.size()

	var commit_changes := []
	for change in serialized_changes:
		commit_changes.append(change.duplicate(true))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Cleared GridMap cells", "_clear_gridmap_cells", payload)
	)

	transaction.register_on_rollback(func():
		var payload = log_payload.duplicate(true)
		payload["changes"] = commit_changes.duplicate(true)
		_log("Rolled back GridMap clearing", "_clear_gridmap_cells", payload)
	)

	if change_entries.is_empty():
		if transaction_id.is_empty():
			transaction.rollback()
		_log("No GridMap cells required clearing", "_clear_gridmap_cells", log_payload)
		return _send_success(client_id, {
			"node_path": resolved_node_path,
			"requested_path": node_path,
			"node_type": node.get_class(),
			"changes": [],
			"transaction_id": transaction.transaction_id,
			"status": "no_changes",
		}, command_id)

	var status := "pending"
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log(
				"Failed to commit GridMap clearing",
				"_clear_gridmap_cells",
				log_payload,
				true
			)
			return _send_error(client_id, "Failed to commit GridMap clearing", command_id)
		status = "committed"

	_send_success(client_id, {
		"node_path": resolved_node_path,
		"requested_path": node_path,
		"node_type": node.get_class(),
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


func _is_csg_node(node: Object) -> bool:
	if node == null:
		return false
	var node_class := node.get_class()
	if ClassDB.is_parent_class(node_class, "CSGShape3D"):
		return true
	if ClassDB.class_exists("CSGPolygon2D") and ClassDB.is_parent_class(node_class, "CSGPolygon2D"):
		return true
	return false

func _classify_csg_node(node: Node) -> Dictionary:
	if node is Node3D:
		return {"dimension": "3d"}
	if node is Node2D:
		return {"dimension": "2d"}
	return {"dimension": "unknown"}

func _has_property(target: Object, property_name: String) -> bool:
	if target == null:
		return false
	var property_list = target.get_property_list()
	for property_info in property_list:
		if typeof(property_info) == TYPE_DICTIONARY and property_info.has("name"):
			if String(property_info["name"]) == property_name:
				return true
	return false

func _to_int(value) -> Variant:
	match typeof(value):
		TYPE_NIL:
			return null
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_BOOL:
			return value ? 1 : 0
		TYPE_STRING, TYPE_STRING_NAME:
			var text := String(value).strip_edges()
			if text.is_empty():
				return null
			if text.is_valid_int():
				return int(text)
			if text.is_valid_float():
				return int(round(float(text)))
			return null
		_:
			return null

func _convert_to_vector3i(value) -> Dictionary:
	match typeof(value):
		TYPE_VECTOR3I:
			return {"vector": value, "components": _vector3i_to_dictionary(value)}
		TYPE_VECTOR3:
			var vector := Vector3i(int(round(value.x)), int(round(value.y)), int(round(value.z)))
			return {"vector": vector, "components": _vector3i_to_dictionary(vector)}
		TYPE_DICTIONARY:
			var dictionary: Dictionary = value
			if dictionary.has("x") and dictionary.has("y") and dictionary.has("z"):
				var x_value = _to_int(dictionary.get("x"))
				var y_value = _to_int(dictionary.get("y"))
				var z_value = _to_int(dictionary.get("z"))
				if x_value == null or y_value == null or z_value == null:
					return {}
				var vector := Vector3i(x_value, y_value, z_value)
				return {"vector": vector, "components": _vector3i_to_dictionary(vector)}
		_:
			return {}
	return {}

func _parse_gridmap_position(data) -> Dictionary:
	match typeof(data):
		TYPE_DICTIONARY:
			var dictionary: Dictionary = data
			if dictionary.has("position"):
				var converted = _convert_to_vector3i(dictionary["position"])
				if not converted.is_empty():
					return converted
			if dictionary.has("x") and dictionary.has("y") and dictionary.has("z"):
				return _convert_to_vector3i(dictionary)
			return {}
		TYPE_VECTOR3I, TYPE_VECTOR3:
			return _convert_to_vector3i(data)
		_:
			return {}

func _vector3i_to_dictionary(vector: Vector3i) -> Dictionary:
	return {"x": vector.x, "y": vector.y, "z": vector.z}

func _node_path_to_string(node: Node, fallback: String) -> String:
	if node:
		var node_path_value = node.get_path()
		if typeof(node_path_value) == TYPE_NODE_PATH:
			return String(node_path_value)
		return str(node_path_value)
	return fallback


func _amplitude_to_decibels(amplitude: float) -> float:
	if amplitude <= 0.0:
		return -144.0
	return 20.0 * (log(amplitude) / log(10.0))


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
