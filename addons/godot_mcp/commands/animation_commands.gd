@tool
class_name MCPAnimationCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/animation_commands.gd"
const DEFAULT_SYSTEM_SECTION := "animation_commands"
const SceneTransactionManager := MCPSceneTransactionManager

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"list_animation_players":
			_list_animation_players(client_id, params, command_id)
			return true
		"describe_animation_tracks":
			_describe_animation_tracks(client_id, params, command_id)
			return true
		"describe_animation_state_machines":
			_describe_animation_state_machines(client_id, params, command_id)
			return true
		"edit_animation":
			_edit_animation(client_id, params, command_id)
			return true
		"configure_animation_tree":
			_configure_animation_tree(client_id, params, command_id)
			return true
		"bake_skeleton_pose":
			_bake_skeleton_pose(client_id, params, command_id)
			return true
		"generate_tween_sequence":
			_generate_tween_sequence(client_id, params, command_id)
			return true
		"sync_particles_with_animation":
			_sync_particles_with_animation(client_id, params, command_id)
			return true
	return false

func _list_animation_players(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_list_animation_players"
	var include_tracks := params.get("include_tracks", false)
	var include_keys := params.get("include_keys", false)
	var node_path := params.get("node_path", "")
	var root := _resolve_search_root(node_path)
	if root == null:
		_log("Unable to resolve animation search root", function_name, {
			"requested_path": node_path,
			"system_section": "animation_player_enumeration",
		}, true)
		return _send_error(client_id, "Unable to resolve animation search root", command_id)

	var players: Array = []
	var queue: Array = [root]
	var visited_paths := {}
	while not queue.is_empty():
		var current: Node = queue.pop_front()
		if current == null:
			continue

		var serialized_path := _path_to_string(current)
		if visited_paths.has(serialized_path):
			continue
		visited_paths[serialized_path] = true

		if current is AnimationPlayer:
			players.append(_serialize_animation_player(current, include_tracks, include_keys))
		for child in current.get_children():
			if child is Node:
				queue.append(child)

	_log("Enumerated AnimationPlayer nodes", function_name, {
		"count": players.size(),
		"include_tracks": include_tracks,
		"include_keys": include_keys,
		"root_path": node_path,
	})

	_send_success(client_id, {
		"players": players,
		"include_tracks": include_tracks,
		"include_keys": include_keys,
	}, command_id)

func _describe_animation_tracks(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_describe_animation_tracks"
	var node_path := params.get("node_path", "")
	var include_keys := params.get("include_keys", true)
	var include_tracks := true
	var target_root := _resolve_search_root(node_path)
	if target_root == null:
		_log("Unable to resolve animation track root", function_name, {
			"requested_path": node_path,
			"system_section": "animation_track_description",
		}, true)
		return _send_error(client_id, "Unable to resolve animation track root", command_id)

	var payload := _collect_animation_players(target_root, include_tracks, include_keys)
	_log("Described animation tracks", function_name, {
		"player_count": payload.size(),
		"include_keys": include_keys,
		"root_path": node_path,
	})

	_send_success(client_id, {
		"players": payload,
		"include_keys": include_keys,
	}, command_id)

func _describe_animation_state_machines(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_describe_animation_state_machines"
	var node_path := params.get("node_path", "")
	var include_nested := params.get("include_nested", true)
	var include_graph := params.get("include_graph", true)
	var include_transitions := params.get("include_transitions", true)
	var root := _resolve_search_root(node_path)
	if root == null:
		_log("Unable to resolve animation tree root", function_name, {
			"requested_path": node_path,
			"system_section": "animation_state_machine_description",
		}, true)
		return _send_error(client_id, "Unable to resolve animation tree root", command_id)

	var state_machines: Array = []
	var queue: Array = [root]
	var visited_paths := {}
	while not queue.is_empty():
		var current: Node = queue.pop_front()
		if current == null:
			continue

		var serialized_path := _path_to_string(current)
		if visited_paths.has(serialized_path):
			continue
		visited_paths[serialized_path] = true

		if current is AnimationTree:
			state_machines.append(_serialize_animation_tree(current, include_nested, include_graph, include_transitions))
		for child in current.get_children():
			if child is Node:
				queue.append(child)

	_log("Described animation state machines", function_name, {
		"tree_count": state_machines.size(),
		"include_nested": include_nested,
		"include_graph": include_graph,
		"include_transitions": include_transitions,
		"root_path": node_path,
	})

	_send_success(client_id, {
		"animation_trees": state_machines,
		"include_nested": include_nested,
		"include_graph": include_graph,
		"include_transitions": include_transitions,
	}, command_id)

func _edit_animation(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_edit_animation"
	var player_path := String(params.get("player_path", ""))
	var animation_name := String(params.get("animation", ""))
	var operations_param = params.get("operations", [])
	var transaction_id := String(params.get("transaction_id", ""))

	if player_path.is_empty():
		_log("Animation player path missing", function_name, {"client_id": client_id}, true)
		return _send_error(client_id, "Animation player path is required", command_id)

	if animation_name.is_empty():
		_log("Animation name missing", function_name, {"client_id": client_id, "player_path": player_path}, true)
		return _send_error(client_id, "Animation name is required", command_id)

	var player = _get_editor_node(player_path)
	if not player or not (player is AnimationPlayer):
		_log("Animation player not found", function_name, {
			"client_id": client_id,
			"player_path": player_path,
			"requested_animation": animation_name,
		}, true)
		return _send_error(client_id, "AnimationPlayer not found: %s" % player_path, command_id)

	var animation: Animation = player.get_animation(animation_name)
	if animation == null:
		_log("Animation missing on player", function_name, {
			"client_id": client_id,
			"player_path": player_path,
			"animation": animation_name,
		}, true)
		return _send_error(client_id, "Animation '%s' not found on player" % animation_name, command_id)

	var operations: Array = []
	var operations_type := typeof(operations_param)
	if operations_type == TYPE_ARRAY:
		operations = operations_param.duplicate(true)
	elif operations_type == TYPE_DICTIONARY:
		operations.append(operations_param.duplicate(true))
	else:
		_log("Animation operations payload invalid", function_name, {
			"client_id": client_id,
			"player_path": player_path,
			"animation": animation_name,
			"operations_type": operations_type,
		}, true)
		return _send_error(client_id, "Animation operations must be an array or dictionary", command_id)

	if operations.is_empty():
		_log("No animation operations supplied", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction_id,
		})
		return _send_success(client_id, {
			"player_path": player_path,
			"animation": animation_name,
			"status": "no_operations",
			"operations": [],
		}, command_id)

	var rename_operations: Array = []
	var data_operations: Array = []
	for entry in operations:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var op_type := String(entry.get("type", ""))
		if op_type == "rename" or op_type == "rename_animation":
			rename_operations.append(entry.duplicate(true))
		else:
			data_operations.append(entry.duplicate(true))

	var working_copy: Animation = animation.duplicate(true)
	var apply_summary := _apply_animation_operations(working_copy, data_operations)
	var animation_changed := bool(apply_summary.get("changed", false))

	var metadata := {
		"command": "edit_animation",
		"player_path": player_path,
		"animation": animation_name,
		"operations": operations,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Edit Animation", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Edit Animation", metadata)

	if not transaction:
		_log("Unable to acquire transaction for animation edit", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction_id,
		}, true)
		return _send_error(client_id, "Unable to acquire undo transaction for animation edit", command_id)

	var final_animation_name := animation_name
	var rename_summary: Array = []

	if animation_changed:
		var original_copy: Animation = animation.duplicate(true)
		var updated_copy: Animation = working_copy.duplicate(true)
		transaction.add_do_reference(original_copy)
		transaction.add_do_reference(updated_copy)
		transaction.add_do_method(self, "_apply_animation_clone", [animation, updated_copy])
		transaction.add_undo_method(self, "_apply_animation_clone", [animation, original_copy])

	for rename_operation in rename_operations:
		var requested_name := String(rename_operation.get("new_name", rename_operation.get("name", "")))
		if requested_name.is_empty():
			continue
		if requested_name == final_animation_name:
			continue
		transaction.add_do_method(player, "rename_animation", [final_animation_name, requested_name])
		transaction.add_undo_method(player, "rename_animation", [requested_name, final_animation_name])
		rename_summary.append({
			"previous_name": final_animation_name,
			"new_name": requested_name,
		})
		final_animation_name = requested_name

	if not animation_changed and rename_summary.is_empty():
		_log("Animation edit produced no changes", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction.transaction_id,
		})
		if transaction_id.is_empty():
			transaction.rollback()
		return _send_success(client_id, {
			"player_path": player_path,
			"animation": animation_name,
			"status": "no_change",
			"operations": [],
		}, command_id)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Committed animation edit", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"final_animation": final_animation_name,
			"operation_count": operations.size(),
			"transaction_id": transaction.transaction_id,
		})
	)

	var response_payload := {
		"player_path": player_path,
		"animation": animation_name,
		"final_animation": final_animation_name,
		"operations": apply_summary.get("operations", []),
		"renames": rename_summary,
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit animation edit", function_name, {
				"player_path": player_path,
				"animation": animation_name,
				"transaction_id": transaction.transaction_id,
			}, true)
			return _send_error(client_id, "Failed to commit animation changes", command_id)
		response_payload["status"] = "committed"
	else:
		response_payload["status"] = "pending"

	_send_success(client_id, response_payload, command_id)

func _configure_animation_tree(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_configure_animation_tree"
	var tree_path := String(params.get("tree_path", params.get("node_path", "")))
	var property_updates = params.get("properties", {})
	var parameter_updates = params.get("parameters", {})
	var transitions: Array = params.get("state_transitions", [])
	var transaction_id := String(params.get("transaction_id", ""))

	if tree_path.is_empty():
		_log("AnimationTree path missing", function_name, {"client_id": client_id}, true)
		return _send_error(client_id, "AnimationTree path is required", command_id)

	var tree = _get_editor_node(tree_path)
	if not tree or not (tree is AnimationTree):
		_log("AnimationTree node missing", function_name, {
			"tree_path": tree_path,
			"client_id": client_id,
		}, true)
		return _send_error(client_id, "AnimationTree not found at %s" % tree_path, command_id)

	var metadata := {
		"command": "configure_animation_tree",
		"tree_path": tree_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure AnimationTree", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure AnimationTree", metadata)

	if not transaction:
		_log("Unable to acquire transaction for animation tree configuration", function_name, {
			"tree_path": tree_path,
			"transaction_id": transaction_id,
		}, true)
		return _send_error(client_id, "Unable to acquire undo transaction for animation tree configuration", command_id)

	var applied_operations: Array = []

	if typeof(property_updates) == TYPE_DICTIONARY:
		for property_name in property_updates.keys():
			var new_value = _parse_property_value(property_updates[property_name])
			var previous_value = tree.get(property_name)
			if previous_value == new_value:
				continue
			transaction.add_do_method(tree, "set", [property_name, new_value])
			transaction.add_undo_method(tree, "set", [property_name, previous_value])
			applied_operations.append({
				"type": "property",
				"property": property_name,
				"value": _serialize_variant(new_value),
				"previous": _serialize_variant(previous_value),
			})

	if typeof(parameter_updates) == TYPE_DICTIONARY:
		for parameter_key in parameter_updates.keys():
			var parameter_path := parameter_key
			if not String(parameter_path).begins_with("parameters/"):
				parameter_path = "parameters/%s" % parameter_key
			var new_parameter = _parse_property_value(parameter_updates[parameter_key])
			var previous_parameter = tree.get(parameter_path)
			if previous_parameter == new_parameter:
				continue
			transaction.add_do_method(tree, "set", [parameter_path, new_parameter])
			transaction.add_undo_method(tree, "set", [parameter_path, previous_parameter])
			applied_operations.append({
				"type": "parameter",
				"path": String(parameter_path),
				"value": _serialize_variant(new_parameter),
				"previous": _serialize_variant(previous_parameter),
			})

	if typeof(transitions) == TYPE_ARRAY:
		for entry in transitions:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var playback_path := String(entry.get("playback_path", entry.get("path", "")))
			var target_state := String(entry.get("state", entry.get("target", "")))
			if playback_path.is_empty() or target_state.is_empty():
				continue
			if not playback_path.begins_with("parameters/"):
				playback_path = "parameters/%s" % playback_path
			var previous_state = tree.get(playback_path)
			transaction.add_do_method(tree, "set", [playback_path, target_state])
			transaction.add_undo_method(tree, "set", [playback_path, previous_state])
			applied_operations.append({
				"type": "state_transition",
				"path": playback_path,
				"target": target_state,
				"previous": previous_state,
			})

	if applied_operations.is_empty():
		_log("AnimationTree configuration produced no changes", function_name, {
			"tree_path": tree_path,
			"transaction_id": transaction.transaction_id,
		})
		if transaction_id.is_empty():
			transaction.rollback()
		return _send_success(client_id, {
			"tree_path": tree_path,
			"status": "no_change",
			"operations": [],
			"transaction_id": transaction.transaction_id,
		}, command_id)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Committed AnimationTree configuration", function_name, {
			"tree_path": tree_path,
			"operation_count": applied_operations.size(),
			"transaction_id": transaction.transaction_id,
		})
	)

	var response := {
		"tree_path": tree_path,
		"transaction_id": transaction.transaction_id,
		"operations": applied_operations,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit AnimationTree configuration", function_name, {
				"tree_path": tree_path,
				"transaction_id": transaction.transaction_id,
			}, true)
			return _send_error(client_id, "Failed to commit AnimationTree changes", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)

func _bake_skeleton_pose(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_bake_skeleton_pose"
	var skeleton_path := String(params.get("skeleton_path", ""))
	var player_path := String(params.get("player_path", params.get("animation_player", "")))
	var animation_name := String(params.get("animation", params.get("animation_name", "")))
	var bones_param = params.get("bones", [])
	var capture_space := String(params.get("space", "local")).to_lower()
	var transaction_id := String(params.get("transaction_id", ""))
	var overwrite := bool(params.get("overwrite", true))
	var pose_time := float(params.get("time", 0.0))

	if skeleton_path.is_empty():
		_log("Skeleton path missing", function_name, {"client_id": client_id}, true)
		return _send_error(client_id, "Skeleton path is required", command_id)

	if player_path.is_empty():
		_log("AnimationPlayer path missing for pose bake", function_name, {
			"client_id": client_id,
			"skeleton_path": skeleton_path,
		}, true)
		return _send_error(client_id, "AnimationPlayer path is required", command_id)

	if animation_name.is_empty():
		_log("Animation name missing for pose bake", function_name, {
			"client_id": client_id,
			"skeleton_path": skeleton_path,
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "Animation name is required", command_id)

	var skeleton = _get_editor_node(skeleton_path)
	if not skeleton or (not (skeleton is Skeleton3D) and not (skeleton is Skeleton2D)):
		_log("Skeleton node not found or unsupported", function_name, {
			"client_id": client_id,
			"skeleton_path": skeleton_path,
		}, true)
		return _send_error(client_id, "Skeleton node not found or unsupported type", command_id)

	var player = _get_editor_node(player_path)
	if not player or not (player is AnimationPlayer):
		_log("AnimationPlayer for pose bake missing", function_name, {
			"client_id": client_id,
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "AnimationPlayer not found at %s" % player_path, command_id)

	var available_bones := _collect_bone_names(skeleton)
	if available_bones.is_empty():
		_log("No bones detected on skeleton", function_name, {
			"skeleton_path": skeleton_path,
		}, true)
		return _send_error(client_id, "Skeleton has no bones to capture", command_id)

	var target_bones: Array = []
	if typeof(bones_param) == TYPE_ARRAY and not bones_param.is_empty():
		for value in bones_param:
			var bone_name := String(value)
			if available_bones.has(bone_name):
				target_bones.append(bone_name)
	else:
		target_bones = available_bones

	if target_bones.is_empty():
		_log("Requested bones unavailable on skeleton", function_name, {
			"skeleton_path": skeleton_path,
			"requested": bones_param,
		}, true)
		return _send_error(client_id, "None of the requested bones were found on the skeleton", command_id)

	var existing_animation: Animation = player.get_animation(animation_name)
	var animation_exists := existing_animation != null
	if not animation_exists:
		existing_animation = Animation.new()

	var working_copy: Animation = existing_animation.duplicate(true)
	if not animation_exists:
		working_copy.length = max(working_copy.length, pose_time)

	var created_tracks: Array = []
	for bone_name in target_bones:
			var pose_value = _capture_bone_pose(skeleton, bone_name, capture_space)
			if pose_value == null:
				continue

			var track_path := _build_bone_track_path(player, skeleton, bone_name)
			if String(track_path) == "":
				continue

			var track_type := skeleton is Skeleton3D ? Animation.TYPE_TRANSFORM3D : Animation.TYPE_TRANSFORM2D
			var track_index := working_copy.find_track(track_path)
			if track_index == -1:
				track_index = working_copy.add_track(track_type)
				working_copy.track_set_path(track_index, track_path)
				created_tracks.append({"track_index": track_index, "track_path": String(track_path)})
			else:
				if working_copy.track_get_type(track_index) != track_type:
					working_copy.remove_track(track_index)
					track_index = working_copy.add_track(track_type)
					working_copy.track_set_path(track_index, track_path)
				if overwrite:
					var key_total := working_copy.track_get_key_count(track_index)
					for key_index in range(key_total - 1, -1, -1):
						working_copy.track_remove_key(track_index, key_index)

			working_copy.track_insert_key(track_index, pose_time, pose_value, 0.0)

	var metadata := {
		"command": "bake_skeleton_pose",
		"skeleton_path": skeleton_path,
		"player_path": player_path,
		"animation": animation_name,
		"bones": target_bones,
		"space": capture_space,
		"client_id": client_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Bake Skeleton Pose", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Bake Skeleton Pose", metadata)

	if not transaction:
		_log("Unable to acquire transaction for skeleton pose bake", function_name, {
			"skeleton_path": skeleton_path,
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction_id,
		}, true)
		return _send_error(client_id, "Unable to acquire undo transaction for skeleton pose bake", command_id)

	var response := {
		"skeleton_path": skeleton_path,
		"player_path": player_path,
		"animation": animation_name,
		"bones_captured": target_bones,
		"space": capture_space,
		"created_tracks": created_tracks,
		"transaction_id": transaction.transaction_id,
	}

	if animation_exists:
		var original_copy := player.get_animation(animation_name).duplicate(true)
		var updated_copy := working_copy.duplicate(true)
		transaction.add_do_reference(original_copy)
		transaction.add_do_reference(updated_copy)
		transaction.add_do_method(self, "_apply_animation_clone", [player.get_animation(animation_name), updated_copy])
		transaction.add_undo_method(self, "_apply_animation_clone", [player.get_animation(animation_name), original_copy])
	else:
		var new_animation_resource := working_copy.duplicate(true)
		transaction.add_do_reference(new_animation_resource)
		transaction.add_do_method(player, "add_animation", [animation_name, new_animation_resource])
		transaction.add_undo_method(player, "remove_animation", [animation_name])
		response["animation_created"] = true

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Baked skeleton pose", function_name, {
			"skeleton_path": skeleton_path,
			"player_path": player_path,
			"animation": animation_name,
			"bone_count": target_bones.size(),
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit skeleton pose bake", function_name, {
				"skeleton_path": skeleton_path,
				"animation": animation_name,
			}, true)
			return _send_error(client_id, "Failed to commit skeleton pose bake", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)

func _generate_tween_sequence(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_generate_tween_sequence"
	var player_path := String(params.get("player_path", params.get("animation_player_path", "")))
	var animation_name := String(params.get("animation", params.get("animation_name", "")))
	var sequence: Array = params.get("sequence", [])
	var transaction_id := String(params.get("transaction_id", ""))
	var overwrite := bool(params.get("overwrite", true))
	var loop := bool(params.get("loop", false))
	var default_target := String(params.get("target_path", ""))

	if player_path.is_empty():
		_log("AnimationPlayer path missing for tween sequence", function_name, {"client_id": client_id}, true)
		return _send_error(client_id, "AnimationPlayer path is required", command_id)

	if animation_name.is_empty():
		_log("Animation name missing for tween sequence", function_name, {
			"client_id": client_id,
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "Animation name is required", command_id)

	if typeof(sequence) != TYPE_ARRAY or sequence.is_empty():
		_log("Tween sequence payload invalid", function_name, {
			"player_path": player_path,
			"animation": animation_name,
		}, true)
		return _send_error(client_id, "Sequence array is required to generate tween animation", command_id)

	var player = _get_editor_node(player_path)
	if not player or not (player is AnimationPlayer):
		_log("AnimationPlayer not found for tween sequence", function_name, {
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "AnimationPlayer not found at %s" % player_path, command_id)

	var existing_animation: Animation = player.get_animation(animation_name)
	var animation_exists := existing_animation != null
	if not animation_exists:
		existing_animation = Animation.new()

	var working_copy: Animation = existing_animation.duplicate(true)
	if overwrite:
		while working_copy.get_track_count() > 0:
			working_copy.remove_track(working_copy.get_track_count() - 1)

	var operations: Array = []
	var current_time := 0.0
	var max_time := 0.0

	for step_entry in sequence:
		if typeof(step_entry) != TYPE_DICTIONARY:
			continue

		var target_path := String(step_entry.get("target_path", default_target))
		var property_name := String(step_entry.get("property", step_entry.get("attribute", "")))
		var duration := float(step_entry.get("duration", 0.0))
		var delay := float(step_entry.get("delay", 0.0))
		var from_value_raw = step_entry.get("from", step_entry.get("start", null))
		var to_value_raw = step_entry.get("to", step_entry.get("value", null))

		if property_name.is_empty():
			continue
		if to_value_raw == null and from_value_raw == null:
			continue

		var target_node: Node = null
		if target_path.is_empty():
			target_node = player
		else:
			target_node = _get_editor_node(target_path)
			if target_node == null:
				target_node = player

		var track_path := _build_property_track_path(player, target_node, property_name)
		if String(track_path) == "":
			continue

		var track_index := working_copy.find_track(track_path)
		if track_index == -1:
			track_index = working_copy.add_track(Animation.TYPE_VALUE)
			working_copy.track_set_path(track_index, track_path)
		elif overwrite:
			var key_total := working_copy.track_get_key_count(track_index)
			for key_index in range(key_total - 1, -1, -1):
				working_copy.track_remove_key(track_index, key_index)

		var interpolation := String(step_entry.get("interpolation", step_entry.get("ease", "linear")))
		_apply_interpolation_mode(working_copy, track_index, interpolation)

		current_time += max(delay, 0.0)

		var from_value = _parse_property_value(from_value_raw)
		if from_value != null:
			working_copy.track_insert_key(track_index, current_time, from_value, 0.0)
			operations.append({
				"type": "key",
				"time": current_time,
				"value": _serialize_variant(from_value),
				"track_path": String(track_path),
			})

		var to_value = _parse_property_value(to_value_raw)
		var end_time := current_time + max(duration, 0.0)
		working_copy.track_insert_key(track_index, end_time, to_value, 0.0)
		operations.append({
			"type": "key",
			"time": end_time,
			"value": _serialize_variant(to_value),
			"track_path": String(track_path),
		})

		current_time = end_time
		max_time = max(max_time, end_time)

	working_copy.length = max(working_copy.length, max_time)
	working_copy.loop_mode = loop ? Animation.LOOP_LINEAR : Animation.LOOP_NONE

	var metadata := {
		"command": "generate_tween_sequence",
		"player_path": player_path,
		"animation": animation_name,
		"sequence_length": sequence.size(),
		"client_id": client_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Tween Sequence", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Tween Sequence", metadata)

	if not transaction:
		_log("Unable to acquire transaction for tween sequence", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction_id,
		}, true)
		return _send_error(client_id, "Unable to acquire undo transaction for tween sequence", command_id)

	var response := {
		"player_path": player_path,
		"animation": animation_name,
		"operations": operations,
		"length": working_copy.length,
		"loop": loop,
		"transaction_id": transaction.transaction_id,
	}

	if animation_exists:
		var original_copy := player.get_animation(animation_name).duplicate(true)
		var updated_copy := working_copy.duplicate(true)
		transaction.add_do_reference(original_copy)
		transaction.add_do_reference(updated_copy)
		transaction.add_do_method(self, "_apply_animation_clone", [player.get_animation(animation_name), updated_copy])
		transaction.add_undo_method(self, "_apply_animation_clone", [player.get_animation(animation_name), original_copy])
	else:
		var new_resource := working_copy.duplicate(true)
		transaction.add_do_reference(new_resource)
		transaction.add_do_method(player, "add_animation", [animation_name, new_resource])
		transaction.add_undo_method(player, "remove_animation", [animation_name])
		response["animation_created"] = true

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated tween sequence", function_name, {
			"player_path": player_path,
			"animation": animation_name,
			"track_count": working_copy.get_track_count(),
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit tween sequence", function_name, {
				"player_path": player_path,
				"animation": animation_name,
			}, true)
			return _send_error(client_id, "Failed to commit tween sequence", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)

func _sync_particles_with_animation(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_sync_particles_with_animation"
	var particles_path := String(params.get("particles_path", params.get("node_path", "")))
	var player_path := String(params.get("player_path", params.get("animation_player_path", "")))
	var animation_name := String(params.get("animation", params.get("animation_name", "")))
	var emission_settings = params.get("emission", {})
	var transaction_id := String(params.get("transaction_id", ""))
	var overwrite_keys := bool(params.get("overwrite_keys", true))
	var sync_keys := bool(params.get("add_animation_keys", true))

	if particles_path.is_empty():
		_log("Particles path missing for synchronization", function_name, {"client_id": client_id}, true)
		return _send_error(client_id, "Particles node path is required", command_id)

	if player_path.is_empty():
		_log("AnimationPlayer path missing for particle sync", function_name, {
			"client_id": client_id,
			"particles_path": particles_path,
		}, true)
		return _send_error(client_id, "AnimationPlayer path is required", command_id)

	if animation_name.is_empty():
		_log("Animation name missing for particle sync", function_name, {
			"client_id": client_id,
			"particles_path": particles_path,
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "Animation name is required", command_id)

	var particles = _get_editor_node(particles_path)
	if not particles or not (particles is GPUParticles3D or particles is GPUParticles2D or particles is CPUParticles3D or particles is CPUParticles2D):
		_log("Particles node not found or unsupported", function_name, {
			"particles_path": particles_path,
		}, true)
		return _send_error(client_id, "Particles node not found or unsupported type", command_id)

	var player = _get_editor_node(player_path)
	if not player or not (player is AnimationPlayer):
		_log("AnimationPlayer not found for particle sync", function_name, {
			"player_path": player_path,
		}, true)
		return _send_error(client_id, "AnimationPlayer not found at %s" % player_path, command_id)

	var animation: Animation = player.get_animation(animation_name)
	if animation == null:
		_log("Animation missing for particle sync", function_name, {
			"player_path": player_path,
			"animation": animation_name,
		}, true)
		return _send_error(client_id, "Animation '%s' not found on player" % animation_name, command_id)

	var animation_length := animation.length
	if animation_length <= 0.0:
		var detected_length := 0.0
		var track_total := animation.get_track_count()
		for track_index in track_total:
			var key_total := animation.track_get_key_count(track_index)
			if key_total > 0:
				detected_length = max(detected_length, animation.track_get_key_time(track_index, key_total - 1))
		animation_length = max(detected_length, 1.0)

	var particle_updates := {}
	if typeof(emission_settings) == TYPE_DICTIONARY:
		for key in emission_settings.keys():
			particle_updates[String(key)] = _parse_property_value(emission_settings[key])

	if not particle_updates.has("one_shot"):
		particle_updates["one_shot"] = true
	if not particle_updates.has("emitting"):
		particle_updates["emitting"] = false
	if not particle_updates.has("lifetime"):
		particle_updates["lifetime"] = max(animation_length, 0.01)
	if not particle_updates.has("preprocess"):
		particle_updates["preprocess"] = 0.0

	var metadata := {
		"command": "sync_particles_with_animation",
		"particles_path": particles_path,
		"player_path": player_path,
		"animation": animation_name,
		"client_id": client_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Sync Particles With Animation", metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Sync Particles With Animation", metadata)

	if not transaction:
		_log("Unable to acquire transaction for particle sync", function_name, {
			"particles_path": particles_path,
			"player_path": player_path,
			"animation": animation_name,
			"transaction_id": transaction_id,
		}, true)
		return _send_error(client_id, "Unable to acquire undo transaction for particle synchronization", command_id)

	var applied_particle_properties: Array = []
	for property_name in particle_updates.keys():
		if not _has_property(particles, property_name):
			continue
		var new_value = particle_updates[property_name]
		var previous_value = particles.get(property_name)
		if previous_value == new_value:
			continue
		transaction.add_do_property(particles, property_name, new_value)
		transaction.add_undo_property(particles, property_name, previous_value)
		applied_particle_properties.append({
			"property": property_name,
			"value": _serialize_variant(new_value),
			"previous": _serialize_variant(previous_value),
		})

	var animation_summary := {}
	var animation_changed := false
	if sync_keys:
		var operations: Array = []
		var track_path := _build_property_track_path(player, particles, "emitting")
		if String(track_path) != "":
			operations.append({"type": "ensure_track", "track_path": String(track_path)})
			if overwrite_keys:
				operations.append({"type": "clear_track", "track_path": String(track_path)})
			operations.append({"type": "insert_key", "track_path": String(track_path), "time": 0.0, "value": true})
			operations.append({"type": "insert_key", "track_path": String(track_path), "time": animation_length, "value": false})

		if operations.size() > 0:
			var working_copy := animation.duplicate(true)
			animation_summary = _apply_animation_operations(working_copy, operations)
			animation_changed = bool(animation_summary.get("changed", false))
			if animation_changed:
				var original_copy := animation.duplicate(true)
				var updated_copy := working_copy.duplicate(true)
				transaction.add_do_reference(original_copy)
				transaction.add_do_reference(updated_copy)
				transaction.add_do_method(self, "_apply_animation_clone", [animation, updated_copy])
				transaction.add_undo_method(self, "_apply_animation_clone", [animation, original_copy])

	if applied_particle_properties.is_empty() and not animation_changed:
		_log("Particle synchronization produced no changes", function_name, {
			"particles_path": particles_path,
			"animation": animation_name,
			"transaction_id": transaction.transaction_id,
		})
		if transaction_id.is_empty():
			transaction.rollback()
		return _send_success(client_id, {
			"particles_path": particles_path,
			"player_path": player_path,
			"animation": animation_name,
			"status": "no_change",
			"transaction_id": transaction.transaction_id,
		}, command_id)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Synchronized particles with animation", function_name, {
			"particles_path": particles_path,
			"player_path": player_path,
			"animation": animation_name,
			"particle_property_count": applied_particle_properties.size(),
			"animation_updated": animation_changed,
			"transaction_id": transaction.transaction_id,
		})
	)

	var response := {
		"particles_path": particles_path,
		"player_path": player_path,
		"animation": animation_name,
		"particle_properties": applied_particle_properties,
		"animation_operations": animation_summary.get("operations", []),
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit particle synchronization", function_name, {
				"particles_path": particles_path,
				"animation": animation_name,
			}, true)
			return _send_error(client_id, "Failed to commit particle synchronization", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)

func _apply_animation_operations(animation: Animation, operations: Array) -> Dictionary:
	var summary := {
		"changed": false,
		"operations": [],
	}

	if animation == null or operations.is_empty():
		return summary

	for entry in operations:
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var op_type := String(entry.get("type", ""))
		match op_type:
			"set_property":
				var property_name := String(entry.get("property", ""))
				if property_name.is_empty():
					continue
				var new_value = _parse_property_value(entry.get("value"))
				var previous_value = animation.get(property_name)
				if previous_value == new_value:
					continue
				animation.set(property_name, new_value)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"property": property_name,
					"value": _serialize_variant(new_value),
					"previous": _serialize_variant(previous_value),
				})
			"ensure_track":
				var ensure_result := _ensure_animation_track(animation, entry)
				if ensure_result.get("changed", false):
					summary["changed"] = true
				if ensure_result.size() > 0:
					summary.operations.append(ensure_result)
			"remove_track":
				var track_index := _resolve_animation_track_index(animation, entry)
				if track_index < 0:
					continue
				var removed_info := _serialize_animation_track(animation, track_index)
				animation.remove_track(track_index)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"track_index": track_index,
					"track": removed_info,
				})
			"clear_track":
				var clear_index := _resolve_animation_track_index(animation, entry)
				if clear_index < 0:
					continue
				var key_count := animation.track_get_key_count(clear_index)
				if key_count == 0:
					continue
				for key_idx in range(key_count - 1, -1, -1):
					animation.track_remove_key(clear_index, key_idx)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"track_index": clear_index,
					"removed_keys": key_count,
				})
			"set_track_enabled":
				var enable_index := _resolve_animation_track_index(animation, entry)
				if enable_index < 0 or not animation.has_method("track_set_enabled"):
					continue
				var enable_value := bool(entry.get("enabled", true))
				if animation.track_is_enabled(enable_index) == enable_value:
					continue
				animation.track_set_enabled(enable_index, enable_value)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"track_index": enable_index,
					"enabled": enable_value,
				})
			"set_key":
				var set_index := _resolve_animation_track_index(animation, entry)
				var key_index := int(entry.get("key_index", entry.get("index", -1)))
				if set_index < 0 or key_index < 0 or key_index >= animation.track_get_key_count(set_index):
					continue
				var key_result := {}
				if entry.has("value"):
					var parsed_value = _parse_property_value(entry.get("value"))
					var previous_value = animation.track_get_key_value(set_index, key_index)
					if previous_value != parsed_value:
						animation.track_set_key_value(set_index, key_index, parsed_value)
						key_result["value"] = _serialize_variant(parsed_value)
						key_result["previous_value"] = _serialize_variant(previous_value)
						summary["changed"] = true
				if entry.has("time"):
					var new_time := float(entry.get("time"))
					var previous_time := animation.track_get_key_time(set_index, key_index)
					if !is_equal_approx(previous_time, new_time):
						animation.track_set_key_time(set_index, key_index, new_time)
						key_result["time"] = new_time
						key_result["previous_time"] = previous_time
						summary["changed"] = true
				if entry.has("transition") and animation.has_method("track_set_key_transition"):
					var new_transition := float(entry.get("transition"))
					var previous_transition := animation.track_get_key_transition(set_index, key_index)
					if !is_equal_approx(previous_transition, new_transition):
						animation.track_set_key_transition(set_index, key_index, new_transition)
						key_result["transition"] = new_transition
						key_result["previous_transition"] = previous_transition
						summary["changed"] = true
				if key_result.size() > 0:
					key_result["type"] = op_type
					key_result["track_index"] = set_index
					key_result["key_index"] = key_index
					summary.operations.append(key_result)
			"insert_key":
				var insert_index := _resolve_animation_track_index(animation, entry)
				if insert_index < 0:
					continue
				var insert_time := float(entry.get("time", 0.0))
				var insert_value = _parse_property_value(entry.get("value"))
				var transition_value := 0.0
				if entry.has("transition"):
					transition_value = float(entry.get("transition"))
				var inserted_position := animation.track_insert_key(insert_index, insert_time, insert_value, transition_value)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"track_index": insert_index,
					"key_index": inserted_position,
					"time": insert_time,
					"value": _serialize_variant(insert_value),
					"transition": transition_value,
				})
			"remove_key":
				var remove_index := _resolve_animation_track_index(animation, entry)
				var remove_key := int(entry.get("key_index", entry.get("index", -1)))
				if remove_index < 0 or remove_key < 0 or remove_key >= animation.track_get_key_count(remove_index):
					continue
				var removed_snapshot := _serialize_animation_key(animation, remove_index, remove_key)
				animation.track_remove_key(remove_index, remove_key)
				summary["changed"] = true
				summary.operations.append({
					"type": op_type,
					"track_index": remove_index,
					"key_index": remove_key,
					"removed": removed_snapshot,
				})
			_:
				continue

	return summary

func _apply_animation_clone(target: Animation, source: Animation) -> void:
	if target == null or source == null:
		return

	target.length = source.length
	target.loop_mode = source.loop_mode
	target.step = source.step

	while target.get_track_count() > 0:
		target.remove_track(target.get_track_count() - 1)

	var track_count := source.get_track_count()
	for track_index in track_count:
		var track_type := source.track_get_type(track_index)
		var new_index := target.add_track(track_type)
		target.track_set_path(new_index, source.track_get_path(track_index))
		if source.has_method("track_get_interpolation_type") and target.has_method("track_set_interpolation_type"):
			target.track_set_interpolation_type(new_index, source.track_get_interpolation_type(track_index))
		if source.has_method("track_get_wrap_mode") and target.has_method("track_set_wrap_mode"):
			target.track_set_wrap_mode(new_index, source.track_get_wrap_mode(track_index))
		if source.has_method("track_is_enabled") and target.has_method("track_set_enabled"):
			target.track_set_enabled(new_index, source.track_is_enabled(track_index))

		var key_total := source.track_get_key_count(track_index)
		for key_index in key_total:
			var key_time := source.track_get_key_time(track_index, key_index)
			var key_value := source.track_get_key_value(track_index, key_index)
			var key_transition := 0.0
			if source.has_method("track_get_key_transition"):
				key_transition = source.track_get_key_transition(track_index, key_index)
			target.track_insert_key(new_index, key_time, key_value, key_transition)

func _ensure_animation_track(animation: Animation, payload: Dictionary) -> Dictionary:
	var result := {
		"type": "ensure_track",
		"changed": false,
	}

	if animation == null:
		return result

	var track_path_value = payload.get("track_path", payload.get("path", ""))
	var track_path := _normalise_track_path(track_path_value)
	if String(track_path) == "":
		result["status"] = "invalid_path"
		return result

	var requested_type := int(payload.get("track_type", Animation.TYPE_VALUE))
	var existing_index := animation.find_track(track_path)

	if existing_index == -1:
		existing_index = animation.add_track(requested_type)
		animation.track_set_path(existing_index, track_path)
		result["changed"] = true
		result["created"] = true
		result["track_index"] = existing_index
		result["track_path"] = String(track_path)
	else:
		result["track_index"] = existing_index
		result["track_path"] = String(track_path)
		if animation.track_get_type(existing_index) != requested_type and payload.get("force_type", false):
			animation.remove_track(existing_index)
			existing_index = animation.add_track(requested_type)
			animation.track_set_path(existing_index, track_path)
			result["changed"] = true
			result["recreated"] = true
			result["track_index"] = existing_index

	if payload.has("interpolation") and animation.has_method("track_set_interpolation_type"):
		animation.track_set_interpolation_type(existing_index, int(payload.get("interpolation")))
		result["changed"] = true

	if payload.has("wrap_mode") and animation.has_method("track_set_wrap_mode"):
		animation.track_set_wrap_mode(existing_index, int(payload.get("wrap_mode")))
		result["changed"] = true

	return result

func _resolve_animation_track_index(animation: Animation, payload: Dictionary) -> int:
	if animation == null or payload == null:
		return -1

	if payload.has("track_index"):
		return int(payload.get("track_index"))

	if payload.has("index"):
		return int(payload.get("index"))

	if payload.has("track_path") or payload.has("path"):
		var path := _normalise_track_path(payload.get("track_path", payload.get("path", "")))
		if String(path) == "":
			return -1
		return animation.find_track(path)

	return -1

func _serialize_animation_track(animation: Animation, track_index: int) -> Dictionary:
	var info := {
		"type": animation.track_get_type(track_index),
		"path": _serialize_node_path(animation.track_get_path(track_index)),
		"key_count": animation.track_get_key_count(track_index),
	}

	if animation.has_method("track_get_interpolation_type"):
		info["interpolation"] = animation.track_get_interpolation_type(track_index)
	if animation.has_method("track_get_wrap_mode"):
		info["wrap_mode"] = animation.track_get_wrap_mode(track_index)
	if animation.has_method("track_is_enabled"):
		info["enabled"] = animation.track_is_enabled(track_index)

	return info

func _serialize_animation_key(animation: Animation, track_index: int, key_index: int) -> Dictionary:
	var snapshot := {
		"time": animation.track_get_key_time(track_index, key_index),
		"value": _serialize_variant(animation.track_get_key_value(track_index, key_index)),
	}

	if animation.has_method("track_get_key_transition"):
		snapshot["transition"] = animation.track_get_key_transition(track_index, key_index)

	return snapshot

func _normalise_track_path(value) -> NodePath:
	if typeof(value) == TYPE_NODE_PATH:
		return value
	if typeof(value) == TYPE_STRING and not String(value).is_empty():
		return NodePath(String(value))
	return NodePath("")

func _collect_bone_names(skeleton) -> Array:
	var bones: Array = []
	if skeleton is Skeleton3D:
		var bone_count := skeleton.get_bone_count()
		for bone_index in bone_count:
			bones.append(skeleton.get_bone_name(bone_index))
	elif skeleton is Skeleton2D:
		var bone_count_2d := skeleton.get_bone_count()
		for bone_index in bone_count_2d:
			bones.append(skeleton.get_bone_name(bone_index))
	return bones

func _capture_bone_pose(skeleton, bone_name: String, space: String) -> Variant:
	var use_global := space == "global"
	if skeleton is Skeleton3D:
		var bone_index := skeleton.find_bone(bone_name)
		if bone_index == -1:
			return null
		if use_global:
			return skeleton.get_bone_global_pose(bone_index)
		return skeleton.get_bone_pose(bone_index)
	elif skeleton is Skeleton2D:
		var bone_index_2d := skeleton.find_bone(bone_name)
		if bone_index_2d == -1:
			return null
		if use_global and skeleton.has_method("get_bone_global_pose"):
			return skeleton.get_bone_global_pose(bone_index_2d)
		if skeleton.has_method("get_bone_pose"):
			return skeleton.get_bone_pose(bone_index_2d)
	return null

func _build_bone_track_path(player: AnimationPlayer, skeleton, bone_name: String) -> NodePath:
	if player == null or skeleton == null:
			return NodePath("")
	var relative_path = player.get_path_to(skeleton)
	var relative_string := String(relative_path)
	if relative_string.is_empty():
		relative_string = "."
	return NodePath("%s:%s" % [relative_string, bone_name])

func _build_property_track_path(player: AnimationPlayer, target_node: Node, property_name: String) -> NodePath:
	if player == null or target_node == null or property_name.is_empty():
		return NodePath("")
	var relative_path = player.get_path_to(target_node)
	var relative_string := String(relative_path)
	if relative_string.is_empty():
		relative_string = "."
	return NodePath("%s:%s" % [relative_string, property_name])

func _apply_interpolation_mode(animation: Animation, track_index: int, interpolation: String) -> void:
	if animation == null or not animation.has_method("track_set_interpolation_type"):
		return

	var mode := interpolation.to_lower()
	match mode:
		"linear":
			animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_LINEAR)
		"cubic":
			animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_CUBIC)
		"nearest":
			animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_NEAREST)
		_:
			animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_LINEAR)

func _has_property(target: Object, property_name: String) -> bool:
	if target == null or property_name.is_empty():
		return false
	var property_list := target.get_property_list()
	for entry in property_list:
		if String(entry.name) == property_name:
			return true
	return false

func _collect_animation_players(root: Node, include_tracks: bool, include_keys: bool) -> Array:
	var players: Array = []
	var queue: Array = [root]
	var visited_paths := {}
	while not queue.is_empty():
		var current: Node = queue.pop_front()
		if current == null:
			continue

		var serialized_path := _path_to_string(current)
		if visited_paths.has(serialized_path):
			continue
		visited_paths[serialized_path] = true

		if current is AnimationPlayer:
			players.append(_serialize_animation_player(current, include_tracks, include_keys))
		for child in current.get_children():
			if child is Node:
				queue.append(child)
	return players

func _serialize_animation_player(player: AnimationPlayer, include_tracks: bool, include_keys: bool) -> Dictionary:
	var animations: Array = []
	for animation_name in player.get_animation_list():
		var animation: Animation = player.get_animation(animation_name)
		if animation == null:
			continue

		var entry := {
			"name": String(animation_name),
			"length": animation.length,
			"loop_mode": animation.loop_mode,
			"tracks": [],
			"track_count": animation.get_track_count(),
		}

		if include_tracks:
			entry["tracks"] = _serialize_animation_tracks(animation, include_keys)

		animations.append(entry)

	return {
		"node_path": _path_to_string(player),
		"name": String(player.name),
		"autoplay": player.autoplay,
		"process_mode": player.process_mode,
		"playback_speed": player.playback_speed,
		"animation_count": animations.size(),
		"animations": animations,
	}

func _serialize_animation_tracks(animation: Animation, include_keys: bool) -> Array:
	var tracks: Array = []
	var track_count := animation.get_track_count()
	for track_index in track_count:
		var track_type := animation.track_get_type(track_index)
		var track := {
			"index": track_index,
			"type": _animation_track_type_to_string(track_type),
			"path": _serialize_node_path(animation.track_get_path(track_index)),
			"key_count": animation.track_get_key_count(track_index),
			"loop_wrap": animation.track_get_wrap_mode(track_index),
		}

		if animation.has_method("track_is_enabled"):
			track["enabled"] = animation.track_is_enabled(track_index)

		if include_keys:
			var keys: Array = []
			for key_index in animation.track_get_key_count(track_index):
				var key_data := {
					"index": key_index,
					"time": animation.track_get_key_time(track_index, key_index),
					"transition": animation.track_get_key_transition(track_index, key_index),
					"value": _serialize_variant(animation.track_get_key_value(track_index, key_index)),
				}
				if animation.has_method("track_get_key_value_tangent"): # Godot 4 specific tangents
					key_data["in_tangent"] = _serialize_variant(animation.track_get_key_value_tangent(track_index, key_index, true))
					key_data["out_tangent"] = _serialize_variant(animation.track_get_key_value_tangent(track_index, key_index, false))
				keys.append(key_data)
			track["keys"] = keys

		tracks.append(track)
	return tracks

func _serialize_animation_tree(tree: AnimationTree, include_nested: bool, include_graph: bool, include_transitions: bool) -> Dictionary:
	var parameters_value = {}
	if tree.has_method("get"):
		parameters_value = tree.get("parameters")
	var anim_player_path = ""
	if tree.has_method("get"):
		anim_player_path = _serialize_node_path(tree.get("anim_player"))

	var data := {
		"node_path": _path_to_string(tree),
		"name": String(tree.name),
		"active": tree.active,
		"process_mode": tree.process_mode,
		"parameters": _serialize_variant(parameters_value),
		"animation_player": anim_player_path,
		"root_type": tree.tree_root.get_class() if tree.tree_root else "",
		"state_machines": [],
	}

	if tree.tree_root and tree.tree_root is AnimationNodeStateMachine:
		data["state_machines"].append(_serialize_state_machine(tree.tree_root, "root", include_nested, include_graph, include_transitions))
	elif tree.tree_root:
		data["state_machines"] = _collect_nested_state_machines(tree.tree_root, include_nested, include_graph, include_transitions)

	return data

func _collect_nested_state_machines(node: AnimationNode, include_nested: bool, include_graph: bool, include_transitions: bool) -> Array:
	var machines: Array = []
	if node is AnimationNodeStateMachine:
		machines.append(_serialize_state_machine(node, node.resource_name, include_nested, include_graph, include_transitions))
	if not include_nested:
		return machines

	if node.has_method("_get_child_nodes"):
		var children = node.call("_get_child_nodes")
		if typeof(children) == TYPE_DICTIONARY:
			for child_name in children.keys():
				var child_node: AnimationNode = children[child_name]
				if child_node:
					machines += _collect_nested_state_machines(child_node, include_nested, include_graph, include_transitions)
	return machines

func _serialize_state_machine(state_machine: AnimationNodeStateMachine, label, include_nested: bool, include_graph: bool, include_transitions: bool) -> Dictionary:
	var machine := {
		"name": String(label if typeof(label) == TYPE_STRING and not String(label).is_empty() else state_machine.resource_name),
		"start_node": String(state_machine.get("start_node")) if state_machine else "",
		"states": [],
		"transitions": [],
		"allow_transition_to_self": state_machine.is_allow_transition_to_self() if state_machine.has_method("is_allow_transition_to_self") else false,
	}

	var state_names := []
	if state_machine.has_method("get_node_list"):
		state_names = state_machine.get_node_list()

	for state_name in state_names:
		var animation_node: AnimationNode = state_machine.get_node(state_name)
		if animation_node == null:
			continue

		var state_entry := {
			"name": String(state_name),
			"type": animation_node.get_class(),
		}

		if include_graph:
			state_entry["graph_position"] = _serialize_variant(state_machine.get_node_position(state_name))

		if animation_node is AnimationNodeAnimation:
			state_entry["animation"] = animation_node.animation
		elif animation_node is AnimationNodeBlendSpace1D:
			state_entry["blend_space_type"] = "BlendSpace1D"
		elif animation_node is AnimationNodeBlendSpace2D:
			state_entry["blend_space_type"] = "BlendSpace2D"
		elif animation_node is AnimationNodeBlendTree:
			state_entry["blend_tree"] = _serialize_variant(animation_node.get("nodes"))

		if include_nested and animation_node is AnimationNodeStateMachine:
			state_entry["sub_state_machine"] = _serialize_state_machine(animation_node, state_name, include_nested, include_graph, include_transitions)

		machine["states"].append(state_entry)

	if include_transitions and state_machine.has_method("get_transition_count"):
		var transition_count := state_machine.get_transition_count()
		for transition_index in transition_count:
			var transition_info := {
				"index": transition_index,
				"from": String(state_machine.get_transition_from(transition_index)),
				"to": String(state_machine.get_transition_to(transition_index)),
			}
			if state_machine.has_method("get_transition"):
				var transition_resource: AnimationNodeStateMachineTransition = state_machine.get_transition(transition_index)
				if transition_resource:
					transition_info["properties"] = _serialize_resource_properties(transition_resource)
			machine["transitions"].append(transition_info)

	return machine

func _serialize_resource_properties(resource: Resource) -> Dictionary:
	if resource == null:
		return {}
	var data := {}
	for property_info in resource.get_property_list():
		if typeof(property_info) != TYPE_DICTIONARY or not property_info.has("name"):
			continue
		var property_name: String = property_info["name"]
		if ["resource_path", "script", "resource_local_to_scene", "resource_name"].has(property_name):
			continue
		var usage := property_info.get("usage", PROPERTY_USAGE_DEFAULT)
		if (usage & PROPERTY_USAGE_STORAGE) == 0 and (usage & PROPERTY_USAGE_EDITOR) == 0:
			continue
		data[property_name] = _serialize_variant(resource.get(property_name))
	return data

func _resolve_search_root(node_path: String) -> Node:
	var plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
	if not plugin:
		return null
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if edited_scene_root == null:
			return null
	if node_path.is_empty():
		return edited_scene_root
	var node := _get_editor_node(node_path)
	return node

func _animation_track_type_to_string(track_type: int) -> String:
	match track_type:
		Animation.TYPE_VALUE:
			return "value"
		Animation.TYPE_TRANSFORM2D:
			return "transform_2d"
		Animation.TYPE_TRANSFORM3D:
			return "transform_3d"
		Animation.TYPE_BLEND_SHAPE:
			return "blend_shape"
		Animation.TYPE_METHOD:
			return "method"
		Animation.TYPE_BEZIER:
			return "bezier"
		Animation.TYPE_AUDIO:
			return "audio"
		Animation.TYPE_ANIMATION:
			return "animation"
		Animation.TYPE_SCALE_3D:
			return "scale_3d"
		_:
			return "unknown"

func _serialize_node_path(path) -> String:
	if typeof(path) == TYPE_NODE_PATH:
		return String(path)
	if typeof(path) == TYPE_STRING:
		return path
	return String(path)

func _serialize_variant(value):
	match typeof(value):
		TYPE_NIL:
			return null
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value
		TYPE_VECTOR2:
			return {"x": value.x, "y": value.y}
		TYPE_VECTOR3:
			return {"x": value.x, "y": value.y, "z": value.z}
		TYPE_VECTOR2I:
			return {"x": value.x, "y": value.y}
		TYPE_VECTOR3I:
			return {"x": value.x, "y": value.y, "z": value.z}
		TYPE_QUAT:
			return {"x": value.x, "y": value.y, "z": value.z, "w": value.w}
		TYPE_BASIS:
			return {"x": _serialize_variant(value.x), "y": _serialize_variant(value.y), "z": _serialize_variant(value.z)}
		TYPE_TRANSFORM3D:
			return {"basis": _serialize_variant(value.basis), "origin": _serialize_variant(value.origin)}
		TYPE_TRANSFORM2D:
			return {"x": _serialize_variant(value.x), "y": _serialize_variant(value.y), "origin": _serialize_variant(value.origin)}
		TYPE_COLOR:
			return {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
		TYPE_ARRAY:
			var result: Array = []
			for element in value:
				result.append(_serialize_variant(element))
			return result
		TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY:
			var packed_result: Array = []
			for element in value:
				packed_result.append(_serialize_variant(element))
			return packed_result
		TYPE_DICTIONARY:
			var dict_result := {}
			for key in value.keys():
				dict_result[String(key)] = _serialize_variant(value[key])
			return dict_result
		TYPE_OBJECT:
			if value is Node or value is Resource:
				if value.has_method("serialize"):
					return value.serialize()
				if value is Resource:
					return value.resource_path if value.resource_path != "" else value.resource_name
				if value is Node:
					return _path_to_string(value)
			return String(value)
		_:
			return String(value)

func _path_to_string(node: Node) -> String:
	if node == null:
		return ""
	var node_path = node.get_path()
	if typeof(node_path) == TYPE_NODE_PATH:
		return String(node_path)
	return str(node_path)

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPAnimationCommands",
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
