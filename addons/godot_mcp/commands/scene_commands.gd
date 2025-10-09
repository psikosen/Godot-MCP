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
                "author_audio_stream_player":
                        _author_audio_stream_player(client_id, params, command_id)
                        return true
                "author_interactive_music_graph":
                        _author_interactive_music_graph(client_id, params, command_id)
                        return true
                "generate_dynamic_music_layer":
                        _generate_dynamic_music_layer(client_id, params, command_id)
                        return true
                "configure_csg_shape":
                        _configure_csg_shape(client_id, params, command_id)
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
