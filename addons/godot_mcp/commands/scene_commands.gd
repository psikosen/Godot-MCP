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
