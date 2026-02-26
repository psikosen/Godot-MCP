@tool
class_name MCPNodeCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"

var SceneTransactionManager = preload("res://addons/godot_mcp/utils/scene_transaction_manager.gd")
const ScriptUtils := preload("res://addons/godot_mcp/utils/script_utils.gd")
const LOG_FILENAME := "addons/godot_mcp/commands/node_commands.gd"
const DEFAULT_SYSTEM_SECTION := "node_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"create_node":
			_create_node(client_id, params, command_id)
			return true
		"delete_node":
			_delete_node(client_id, params, command_id)
			return true
		"update_node_property":
			_update_node_property(client_id, params, command_id)
			return true
		"get_node_properties":
			_get_node_properties(client_id, params, command_id)
			return true
		"list_nodes":
			_list_nodes(client_id, params, command_id)
			return true
		"duplicate_node":
			_duplicate_node(client_id, params, command_id)
			return true
		"reparent_node":
			_reparent_node(client_id, params, command_id)
			return true
		"move_node_in_parent":
			_move_node_in_parent(client_id, params, command_id)
			return true
		"instantiate_scene":
			_instantiate_scene(client_id, params, command_id)
			return true
		"query_nodes":
			_query_nodes(client_id, params, command_id)
			return true
		"bulk_update_node_properties":
			_bulk_update_node_properties(client_id, params, command_id)
			return true
		"batch_create_nodes":
			_batch_create_nodes(client_id, params, command_id)
			return true
		"batch_delete_nodes":
			_batch_delete_nodes(client_id, params, command_id)
			return true
		"set_node_script":
			_set_node_script(client_id, params, command_id)
			return true
		"clear_node_script":
			_clear_node_script(client_id, params, command_id)
			return true
		"set_node_owner_recursive":
			_set_node_owner_recursive(client_id, params, command_id)
			return true
		"paint_tilemap_cells_2d":
			_paint_tilemap_cells_2d(client_id, params, command_id)
			return true
		"clear_tilemap_cells_2d":
			_clear_tilemap_cells_2d(client_id, params, command_id)
			return true
		"configure_camera2d_follow":
			_configure_camera2d_follow(client_id, params, command_id)
			return true
		"set_animation_tree_state":
			_set_animation_tree_state(client_id, params, command_id)
			return true
		"set_animation_tree_parameters":
			_set_animation_tree_parameters(client_id, params, command_id)
			return true
		"build_wave_spawner_2d":
			_build_wave_spawner_2d(client_id, params, command_id)
			return true
		"build_wave_spawner_3d":
			_build_wave_spawner_3d(client_id, params, command_id)
			return true
		"simulate_wave_spawner_step_2d":
			_simulate_wave_spawner_step_2d(client_id, params, command_id)
			return true
		"simulate_wave_spawner_step_3d":
			_simulate_wave_spawner_step_3d(client_id, params, command_id)
			return true
		"simulate_camera2d_shake":
			_simulate_camera2d_shake(client_id, params, command_id)
			return true
		"simulate_camera3d_shake":
			_simulate_camera3d_shake(client_id, params, command_id)
			return true
		"configure_parallax_2d":
			_configure_parallax_2d(client_id, params, command_id)
			return true
		"configure_animated_sprite_2d":
			_configure_animated_sprite_2d(client_id, params, command_id)
			return true
		"configure_sprite_2d":
			_configure_sprite_2d(client_id, params, command_id)
			return true
		"configure_characterbody2d_controller":
			_configure_characterbody2d_controller(client_id, params, command_id)
			return true
		"configure_area2d_sensor":
			_configure_area2d_sensor(client_id, params, command_id)
			return true
		"fill_tilemap_rect_2d":
			_fill_tilemap_rect_2d(client_id, params, command_id)
			return true
		"generate_tilemap_noise_2d":
			_generate_tilemap_noise_2d(client_id, params, command_id)
			return true
		"tilemap_terrain_autopaint_2d":
			_tilemap_terrain_autopaint_2d(client_id, params, command_id)
			return true
		"generate_heightmap_gridmap_3d":
			_generate_heightmap_gridmap_3d(client_id, params, command_id)
			return true
		"scatter_scene_instances_2d":
			_scatter_scene_instances_2d(client_id, params, command_id)
			return true
		"scatter_scene_instances_3d":
			_scatter_scene_instances_3d(client_id, params, command_id)
			return true
		"configure_characterbody3d_controller":
			_configure_characterbody3d_controller(client_id, params, command_id)
			return true
		"configure_camera3d_rig":
			_configure_camera3d_rig(client_id, params, command_id)
			return true
		"configure_springarm3d":
			_configure_springarm3d(client_id, params, command_id)
			return true
		"configure_navigation_agent_2d":
			_configure_navigation_agent_2d(client_id, params, command_id)
			return true
		"configure_navigation_agent_3d":
			_configure_navigation_agent_3d(client_id, params, command_id)
			return true
		"configure_navigation_obstacle_2d":
			_configure_navigation_obstacle_2d(client_id, params, command_id)
			return true
		"configure_navigation_obstacle_3d":
			_configure_navigation_obstacle_3d(client_id, params, command_id)
			return true
		"advance_pathfollow2d":
			_advance_pathfollow2d(client_id, params, command_id)
			return true
		"advance_pathfollow3d":
			_advance_pathfollow3d(client_id, params, command_id)
			return true
		"configure_path2d_followers":
			_configure_path2d_followers(client_id, params, command_id)
			return true
		"configure_path3d_followers":
			_configure_path3d_followers(client_id, params, command_id)
			return true
		"configure_topdown_movement_2d":
			_configure_topdown_movement_2d(client_id, params, command_id)
			return true
		"simulate_characterbody2d_movement":
			_simulate_characterbody2d_movement(client_id, params, command_id)
			return true
		"simulate_characterbody3d_movement":
			_simulate_characterbody3d_movement(client_id, params, command_id)
			return true
		"simulate_navigation_chase_step_2d":
			_simulate_navigation_chase_step_2d(client_id, params, command_id)
			return true
		"simulate_navigation_chase_step_3d":
			_simulate_navigation_chase_step_3d(client_id, params, command_id)
			return true
		"set_navigation_target_to_node_2d":
			_set_navigation_target_to_node_2d(client_id, params, command_id)
			return true
		"set_navigation_target_to_node_3d":
			_set_navigation_target_to_node_3d(client_id, params, command_id)
			return true
		"configure_light_node":
			_configure_light_node(client_id, params, command_id)
			return true
		"build_water_body_2d":
			_build_water_body_2d(client_id, params, command_id)
			return true
		"build_smoke_effect_2d":
			_build_smoke_effect_2d(client_id, params, command_id)
			return true
		"configure_particles_3d":
			_configure_particles_3d(client_id, params, command_id)
			return true
		"build_smoke_effect_3d":
			_build_smoke_effect_3d(client_id, params, command_id)
			return true
		"build_light_occluder_2d":
			_build_light_occluder_2d(client_id, params, command_id)
			return true
		"edit_light_occluder_polygon_2d":
			_edit_light_occluder_polygon_2d(client_id, params, command_id)
			return true
		"build_subviewport_minimap":
			_build_subviewport_minimap(client_id, params, command_id)
			return true
		"build_weather_system_2d":
			_build_weather_system_2d(client_id, params, command_id)
			return true
		"build_water_body_3d":
			_build_water_body_3d(client_id, params, command_id)
			return true
		"build_sand_field_3d":
			_build_sand_field_3d(client_id, params, command_id)
			return true
		"build_cave_2d":
			_build_cave_2d(client_id, params, command_id)
			return true
		"build_sand_field_2d":
			_build_sand_field_2d(client_id, params, command_id)
			return true
		"generate_platformer_blockout_2d":
			_generate_platformer_blockout_2d(client_id, params, command_id)
			return true
		"generate_topdown_dungeon_2d":
			_generate_topdown_dungeon_2d(client_id, params, command_id)
			return true
		"generate_isometric_tile_blockout_2d":
			_generate_isometric_tile_blockout_2d(client_id, params, command_id)
			return true
		"generate_tentacle_waypoints_2d":
			_generate_tentacle_waypoints_2d(client_id, params, command_id)
			return true
		"build_creature_parts_2d":
			_build_creature_parts_2d(client_id, params, command_id)
			return true
		"build_slime_mold_colony_2d":
			_build_slime_mold_colony_2d(client_id, params, command_id)
			return true
		"simulate_slime_mold_growth_step_2d":
			_simulate_slime_mold_growth_step_2d(client_id, params, command_id)
			return true
		"simulate_weather_step_2d":
			_simulate_weather_step_2d(client_id, params, command_id)
			return true
		"simulate_water_current_step_2d":
			_simulate_water_current_step_2d(client_id, params, command_id)
			return true
		"simulate_water_current_step_3d":
			_simulate_water_current_step_3d(client_id, params, command_id)
			return true
		"settle_sand_field_3d":
			_settle_sand_field_3d(client_id, params, command_id)
			return true
		"build_stage_blockout_2d":
			_build_stage_blockout_2d(client_id, params, command_id)
			return true
		"build_hud_ui_2d":
			_build_hud_ui_2d(client_id, params, command_id)
			return true
		"author_enemy_ai_2d":
			_author_enemy_ai_2d(client_id, params, command_id)
			return true
		"author_enemy_ai_3d":
			_author_enemy_ai_3d(client_id, params, command_id)
			return true
		"build_menu_ui_flow_2d":
			_build_menu_ui_flow_2d(client_id, params, command_id)
			return true
		"set_menu_ui_flow_state":
			_set_menu_ui_flow_state(client_id, params, command_id)
			return true
		"rename_node":
			_rename_node(client_id, params, command_id)
			return true
		"add_node_to_group":
			_add_node_to_group(client_id, params, command_id)
			return true
		"remove_node_from_group":
			_remove_node_from_group(client_id, params, command_id)
			return true
		"configure_camera2d_limits":
			_configure_camera2d_limits(client_id, params, command_id)
			return true
		"list_node_groups":
			_list_node_groups(client_id, params, command_id)
			return true
		"list_nodes_in_group":
			_list_nodes_in_group(client_id, params, command_id)
			return true
		"create_theme_override":
			_create_theme_override(client_id, params, command_id)
			return true
		"wire_signal_handler":
			_wire_signal_handler(client_id, params, command_id)
			return true
		"layout_ui_grid":
			_layout_ui_grid(client_id, params, command_id)
			return true
		"validate_accessibility":
			_validate_accessibility(client_id, params, command_id)
			return true
	return false  # Command not handled

func _duplicate_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var source_path: String = params.get("source_path", "")
	var parent_path: String = params.get("parent_path", "")
	var requested_name: String = String(params.get("new_name", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var duplicate_groups: bool = params.get("duplicate_groups", true)
	var duplicate_signals: bool = params.get("duplicate_signals", true)
	var duplicate_scripts: bool = params.get("duplicate_scripts", true)
	var use_instantiation: bool = params.get("use_instantiation", false)

	if source_path.is_empty():
		return _send_error(client_id, "Source path cannot be empty", command_id)

	var source_node = _get_editor_node(source_path)
	if not source_node:
		return _send_error(client_id, "Source node not found: %s" % source_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	if source_node == edited_scene_root:
		return _send_error(client_id, "Duplicating the scene root is not supported", command_id)

	var target_parent = source_node.get_parent()
	if not parent_path.is_empty():
		target_parent = _get_editor_node(parent_path)

	if not target_parent:
		var resolved_parent_path = parent_path if not parent_path.is_empty() else "<source_parent>"
		return _send_error(client_id, "Target parent not found: %s" % resolved_parent_path, command_id)

	if source_node.is_ancestor_of(target_parent):
		return _send_error(client_id, "Cannot duplicate a node into one of its descendants", command_id)

	var duplicate_flags := 0
	if duplicate_signals:
		duplicate_flags |= Node.DUPLICATE_SIGNALS
	if duplicate_groups:
		duplicate_flags |= Node.DUPLICATE_GROUPS
	if duplicate_scripts:
		duplicate_flags |= Node.DUPLICATE_SCRIPTS
	if use_instantiation:
		duplicate_flags |= Node.DUPLICATE_USE_INSTANTIATION

	var duplicated_node = source_node.duplicate(duplicate_flags)
	if not duplicated_node:
		return _send_error(client_id, "Failed to duplicate node at %s" % source_path, command_id)

	var base_name := requested_name if not requested_name.is_empty() else "%sCopy" % String(source_node.name)
	var final_name := _resolve_unique_child_name(target_parent, base_name)
	duplicated_node.name = final_name

	var target_parent_path: String = _to_mcp_path(target_parent)
	var expected_path := _join_mcp_path(target_parent_path, final_name)
	var transaction_metadata := {
		"command": "duplicate_node",
		"source_path": source_path,
		"parent_path": target_parent_path,
		"new_name": final_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Duplicate Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Duplicate Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node duplication", command_id)

	transaction.add_do_method(target_parent, "add_child", [duplicated_node])
	transaction.add_do_method(duplicated_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(target_parent, "remove_child", [duplicated_node])
	transaction.add_undo_method(duplicated_node, "queue_free")
	transaction.add_do_reference(duplicated_node)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			selection.add_node(duplicated_node)
		_log("Duplicated node", "_duplicate_node", {
			"source_path": source_path,
			"node_path": _to_mcp_path(duplicated_node),
			"parent_path": target_parent_path,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"source_path": source_path,
		"parent_path": target_parent_path,
		"node_name": final_name,
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node duplication", command_id)

		response["node_path"] = _to_mcp_path(duplicated_node)
		response["status"] = "committed"
	else:
		response["node_path"] = expected_path
		response["expected_path"] = expected_path
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _reparent_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var new_parent_path: String = params.get("new_parent_path", "")
	var requested_name: String = String(params.get("new_name", "")).strip_edges()
	var child_index_variant = params.get("child_index", null)
	var keep_global_transform: bool = params.get("keep_global_transform", true)
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if new_parent_path.is_empty():
		return _send_error(client_id, "New parent path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var new_parent = _get_editor_node(new_parent_path)
	if not new_parent:
		return _send_error(client_id, "New parent not found: %s" % new_parent_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	if node == edited_scene_root:
		return _send_error(client_id, "Cannot reparent the scene root", command_id)
	if node == new_parent:
		return _send_error(client_id, "A node cannot be reparented to itself", command_id)
	if node.is_ancestor_of(new_parent):
		return _send_error(client_id, "Cannot reparent a node under its own descendant", command_id)

	var old_parent = node.get_parent()
	if not old_parent:
		return _send_error(client_id, "Node has no parent: %s" % node_path, command_id)

	var old_parent_path: String = _to_mcp_path(old_parent)
	var old_index: int = old_parent.get_children().find(node)
	var old_name: String = String(node.name)
	var has_parent_change: bool = old_parent != new_parent
	var has_child_index: bool = child_index_variant != null
	var target_index := -1
	if has_child_index:
		var requested_index: int = int(child_index_variant)
		var max_index: int = new_parent.get_child_count()
		if not has_parent_change:
			max_index = max(0, max_index - 1)
		target_index = int(clamp(requested_index, 0, max_index))

	var resolved_name := old_name
	if not requested_name.is_empty():
		resolved_name = _resolve_unique_child_name(
			new_parent, requested_name, (node if not has_parent_change else null)
		)
	elif has_parent_change and _has_child_with_name(new_parent, old_name):
		resolved_name = _resolve_unique_child_name(new_parent, old_name)

	var has_name_change: bool = resolved_name != old_name
	var has_index_change: bool = has_child_index and target_index != old_index
	if not has_parent_change and not has_name_change and not has_index_change:
		return _send_success(client_id, {
			"node_path": node_path,
			"parent_path": _to_mcp_path(new_parent),
			"new_name": old_name,
			"new_index": old_index,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "reparent_node",
		"node_path": node_path,
		"new_parent_path": _to_mcp_path(new_parent),
		"keep_global_transform": keep_global_transform,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Reparent Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Reparent Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node reparenting", command_id)

	if has_parent_change:
		transaction.add_do_method(node, "reparent", [new_parent, keep_global_transform])
	if has_name_change:
		transaction.add_do_property(node, "name", resolved_name)
	if has_child_index and (has_parent_change or has_index_change):
		var move_parent = new_parent if has_parent_change else old_parent
		transaction.add_do_method(move_parent, "move_child", [node, target_index])

	if has_name_change:
		transaction.add_undo_property(node, "name", old_name)
	if has_parent_change:
		transaction.add_undo_method(node, "reparent", [old_parent, keep_global_transform])
	if has_parent_change or has_index_change:
		transaction.add_undo_method(old_parent, "move_child", [node, old_index])

	var predicted_index: int = old_index
	if has_parent_change:
		predicted_index = target_index if has_child_index else new_parent.get_child_count()
	elif has_index_change:
		predicted_index = target_index

	var response := {
		"node_path": _join_mcp_path(_to_mcp_path(new_parent), resolved_name),
		"new_parent_path": _to_mcp_path(new_parent),
		"previous_parent_path": old_parent_path,
		"new_name": resolved_name,
		"previous_name": old_name,
		"new_index": predicted_index,
		"previous_index": old_index,
		"transaction_id": transaction.transaction_id,
	}

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			selection.add_node(node)
		_log("Reparented node", "_reparent_node", {
			"node_path": _to_mcp_path(node),
			"previous_parent_path": old_parent_path,
			"new_parent_path": _to_mcp_path(new_parent),
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node reparenting", command_id)
		response["node_path"] = _to_mcp_path(node)
		response["new_index"] = node.get_index()
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _move_node_in_parent(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var target_index: int = int(params.get("index", -1))
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if target_index < 0:
		return _send_error(client_id, "Index must be greater than or equal to zero", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var parent = node.get_parent()
	if not parent:
		return _send_error(client_id, "Node has no parent: %s" % node_path, command_id)

	var old_index: int = parent.get_children().find(node)
	var max_index: int = max(0, parent.get_child_count() - 1)
	var clamped_target_index: int = int(clamp(target_index, 0, max_index))
	if old_index == clamped_target_index:
		return _send_success(client_id, {
			"node_path": node_path,
			"parent_path": _to_mcp_path(parent),
			"index": old_index,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "move_node_in_parent",
		"node_path": node_path,
		"target_index": clamped_target_index,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Move Node In Parent", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Move Node In Parent", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node reordering", command_id)

	transaction.add_do_method(parent, "move_child", [node, clamped_target_index])
	transaction.add_undo_method(parent, "move_child", [node, old_index])
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Reordered node in parent", "_move_node_in_parent", {
			"node_path": _to_mcp_path(node),
			"parent_path": _to_mcp_path(parent),
			"from_index": old_index,
			"to_index": clamped_target_index,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_path": node_path,
		"parent_path": _to_mcp_path(parent),
		"previous_index": old_index,
		"index": clamped_target_index,
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node reordering", command_id)
		response["index"] = node.get_index()
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _instantiate_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var scene_path: String = params.get("scene_path", "")
	var parent_path: String = params.get("parent_path", "/root")
	var requested_name: String = String(params.get("node_name", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")

	if scene_path.is_empty():
		return _send_error(client_id, "Scene path cannot be empty", command_id)
	if not scene_path.begins_with("res://"):
		return _send_error(client_id, "Scene path must be within the project (res://)", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var packed_resource = ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
	if not packed_resource or not (packed_resource is PackedScene):
		return _send_error(client_id, "Failed to load PackedScene at %s" % scene_path, command_id)

	var scene_instance = packed_resource.instantiate()
	if not scene_instance or not (scene_instance is Node):
		return _send_error(client_id, "Failed to instantiate scene at %s" % scene_path, command_id)

	var instance_node: Node = scene_instance
	var base_name := requested_name if not requested_name.is_empty() else String(instance_node.name)
	if base_name.is_empty():
		base_name = "InstancedScene"
	var final_name := _resolve_unique_child_name(parent, base_name)
	instance_node.name = final_name

	var parent_mcp_path: String = _to_mcp_path(parent)
	var expected_path := _join_mcp_path(parent_mcp_path, final_name)
	var transaction_metadata := {
		"command": "instantiate_scene",
		"scene_path": scene_path,
		"parent_path": parent_mcp_path,
		"node_name": final_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Instantiate Scene", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Instantiate Scene", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for scene instancing", command_id)

	transaction.add_do_method(parent, "add_child", [instance_node])
	transaction.add_do_method(instance_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [instance_node])
	transaction.add_undo_method(instance_node, "queue_free")
	transaction.add_do_reference(instance_node)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			selection.add_node(instance_node)
		_log("Instantiated scene", "_instantiate_scene", {
			"scene_path": scene_path,
			"node_path": _to_mcp_path(instance_node),
			"parent_path": parent_mcp_path,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"scene_path": scene_path,
		"parent_path": parent_mcp_path,
		"node_name": final_name,
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit scene instancing", command_id)
		response["node_path"] = _to_mcp_path(instance_node)
		response["status"] = "committed"
	else:
		response["node_path"] = expected_path
		response["expected_path"] = expected_path
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _query_nodes(client_id: int, params: Dictionary, command_id: String) -> void:
	var root_path: String = params.get("root_path", "/root")
	var name_contains: String = String(params.get("name_contains", "")).strip_edges().to_lower()
	var node_type: String = String(params.get("node_type", "")).strip_edges()
	var group_name: String = String(params.get("group_name", "")).strip_edges()
	var include_root: bool = params.get("include_root", true)
	var include_internal: bool = params.get("include_internal", false)
	var max_results: int = int(params.get("max_results", 500))

	if max_results <= 0:
		max_results = 1
	elif max_results > 5000:
		max_results = 5000

	var root = _get_editor_node(root_path)
	if not root:
		return _send_error(client_id, "Root node not found: %s" % root_path, command_id)

	var filters := {
		"name_contains": name_contains,
		"node_type": node_type,
		"group_name": group_name,
	}
	var results: Array = []
	if include_root:
		_query_nodes_recursive(root, filters, results, include_internal, max_results)
	else:
		for child in root.get_children(include_internal):
			if results.size() >= max_results:
				break
			if child is Node:
				_query_nodes_recursive(child, filters, results, include_internal, max_results)

	_send_success(client_id, {
		"root_path": _to_mcp_path(root),
		"requested_root_path": root_path,
		"filters": {
			"name_contains": name_contains,
			"node_type": node_type,
			"group_name": group_name,
			"include_root": include_root,
			"include_internal": include_internal,
			"max_results": max_results,
		},
		"count": results.size(),
		"truncated": results.size() >= max_results,
		"nodes": results,
	}, command_id)


func _bulk_update_node_properties(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var properties_param = params.get("properties", {})
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if typeof(properties_param) != TYPE_DICTIONARY:
		return _send_error(client_id, "Properties must be provided as a dictionary", command_id)

	var properties: Dictionary = (properties_param as Dictionary).duplicate(true)
	if properties.is_empty():
		return _send_error(client_id, "Properties dictionary cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var staged_base_values: Dictionary = {}
	var original_base_values: Dictionary = {}
	var leaf_changes: Array = []
	var property_paths: Array = properties.keys()
	property_paths.sort()

	for key in property_paths:
		var property_path: String = String(key)
		if property_path.strip_edges().is_empty():
			return _send_error(client_id, "Property names cannot be empty", command_id)

		var raw_value = properties[key]
		if raw_value == null:
			return _send_error(client_id, "Property value for %s cannot be null" % property_path, command_id)

		var property_segments: PackedStringArray = property_path.split(".")
		for segment in property_segments:
			if String(segment).is_empty():
				return _send_error(client_id, "Invalid property path: %s" % property_path, command_id)

		var base_property_name: String = property_segments[0]
		if not base_property_name in node:
			return _send_error(client_id, "Property %s does not exist on node %s" % [base_property_name, node_path], command_id)

		var current_base_value = staged_base_values.get(base_property_name, node.get(base_property_name))
		var conversion_result: Dictionary
		if property_segments.size() == 1:
			var parsed_value = _convert_property_value(node, base_property_name, raw_value)
			conversion_result = {
				"ok": true,
				"value": parsed_value,
				"leaf_previous": current_base_value,
				"leaf_value": parsed_value,
			}
		else:
			var nested_path: Array = []
			for i in range(1, property_segments.size()):
				nested_path.append(property_segments[i])
			conversion_result = _apply_nested_property_value(current_base_value, nested_path, raw_value)
			if not conversion_result.get("ok", false):
				return _send_error(
					client_id,
					"Failed to update %s: %s" % [property_path, conversion_result.get("error", "Invalid nested property update")],
					command_id
				)

		var updated_base_value = conversion_result.get("value")
		if current_base_value == updated_base_value:
			continue

		if not original_base_values.has(base_property_name):
			original_base_values[base_property_name] = node.get(base_property_name)

		staged_base_values[base_property_name] = updated_base_value
		leaf_changes.append({
			"property_path": property_path,
			"base_property": base_property_name,
			"previous_value": var_to_str(conversion_result.get("leaf_previous")),
			"new_value": var_to_str(conversion_result.get("leaf_value")),
		})

	if leaf_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "bulk_update_node_properties",
		"node_path": node_path,
		"change_count": leaf_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Bulk Update Node Properties", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Bulk Update Node Properties", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for bulk property updates", command_id)

	var base_properties: Array = staged_base_values.keys()
	base_properties.sort()
	for base_property in base_properties:
		var base_property_name: String = String(base_property)
		transaction.add_do_property(node, base_property_name, staged_base_values[base_property_name])
		transaction.add_undo_property(node, base_property_name, original_base_values[base_property_name])

	var commit_changes := leaf_changes.duplicate(true)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Applied bulk property updates", "_bulk_update_node_properties", {
			"node_path": _to_mcp_path(node),
			"change_count": commit_changes.size(),
			"changes": commit_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_path": node_path,
		"changes": commit_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit bulk property updates", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _batch_create_nodes(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var nodes_param = params.get("nodes", [])
	var transaction_id: String = params.get("transaction_id", "")

	if typeof(nodes_param) != TYPE_ARRAY:
		return _send_error(client_id, "nodes must be an array", command_id)

	var node_entries: Array = nodes_param
	if node_entries.is_empty():
		return _send_error(client_id, "nodes array cannot be empty", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var reserved_names := _collect_child_name_set(parent)
	var pending_nodes: Array = []
	var created_nodes: Array = []

	for index in range(node_entries.size()):
		var entry_raw = node_entries[index]
		if typeof(entry_raw) != TYPE_DICTIONARY:
			return _send_error(client_id, "nodes[%d] must be a dictionary" % index, command_id)

		var entry: Dictionary = entry_raw
		var node_type: String = String(entry.get("node_type", "")).strip_edges()
		var requested_name: String = String(entry.get("node_name", "")).strip_edges()
		var properties_param = entry.get("properties", {})

		if node_type.is_empty():
			return _send_error(client_id, "nodes[%d].node_type is required" % index, command_id)
		if not ClassDB.class_exists(node_type):
			return _send_error(client_id, "Invalid node type at nodes[%d]: %s" % [index, node_type], command_id)
		if not ClassDB.can_instantiate(node_type):
			return _send_error(client_id, "Cannot instantiate node type at nodes[%d]: %s" % [index, node_type], command_id)

		var new_node = ClassDB.instantiate(node_type)
		if not new_node or not (new_node is Node):
			return _send_error(client_id, "Failed to instantiate node type at nodes[%d]: %s" % [index, node_type], command_id)

		var node_instance: Node = new_node
		if requested_name.is_empty():
			requested_name = "New%s" % node_type
		var final_name := _resolve_unique_name_in_set(requested_name, reserved_names)
		node_instance.name = final_name

		if properties_param != null:
			if typeof(properties_param) != TYPE_DICTIONARY:
				return _send_error(client_id, "nodes[%d].properties must be a dictionary" % index, command_id)
			var properties_dict: Dictionary = properties_param
			for property_key in properties_dict.keys():
				var property_name: String = String(property_key)
				if property_name.strip_edges().is_empty():
					return _send_error(client_id, "nodes[%d] contains an empty property name" % index, command_id)
				if not property_name in node_instance:
					return _send_error(client_id, "Property %s does not exist on node type %s" % [property_name, node_type], command_id)
				var raw_value = properties_dict[property_key]
				if raw_value == null:
					return _send_error(client_id, "Property %s for nodes[%d] cannot be null" % [property_name, index], command_id)
				var converted_value = _convert_property_value(node_instance, property_name, raw_value)
				node_instance.set(property_name, converted_value)

		pending_nodes.append(node_instance)
		created_nodes.append({
			"index": index,
			"node_name": final_name,
			"node_type": node_type,
			"requested_name": requested_name,
			"node_path": _join_mcp_path(_to_mcp_path(parent), final_name),
		})

	var transaction_metadata := {
		"command": "batch_create_nodes",
		"parent_path": _to_mcp_path(parent),
		"count": pending_nodes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Batch Create Nodes", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Batch Create Nodes", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for batch node creation", command_id)

	for node_entry in pending_nodes:
		var child_node: Node = node_entry
		transaction.add_do_method(parent, "add_child", [child_node])
		transaction.add_do_method(child_node, "set_owner", [edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	var commit_entries := created_nodes.duplicate(true)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			if pending_nodes.size() > 0:
				selection.add_node(pending_nodes[pending_nodes.size() - 1])
		for idx in range(commit_entries.size()):
			var entry: Dictionary = commit_entries[idx]
			if idx < pending_nodes.size():
				entry["node_path"] = _to_mcp_path(pending_nodes[idx])
			commit_entries[idx] = entry
		_log("Batch created nodes", "_batch_create_nodes", {
			"parent_path": _to_mcp_path(parent),
			"count": commit_entries.size(),
			"created_nodes": commit_entries,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": _to_mcp_path(parent),
		"created_nodes": created_nodes,
		"count": created_nodes.size(),
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit batch node creation", command_id)
		for idx in range(created_nodes.size()):
			var entry: Dictionary = created_nodes[idx]
			if idx < pending_nodes.size():
				entry["node_path"] = _to_mcp_path(pending_nodes[idx])
			created_nodes[idx] = entry
		response["created_nodes"] = created_nodes
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _batch_delete_nodes(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_paths_param = params.get("node_paths", [])
	var transaction_id: String = params.get("transaction_id", "")

	if typeof(node_paths_param) != TYPE_ARRAY:
		return _send_error(client_id, "node_paths must be an array", command_id)

	var node_paths: Array = node_paths_param
	if node_paths.is_empty():
		return _send_error(client_id, "node_paths array cannot be empty", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var unique_paths: Dictionary = {}
	for path_value in node_paths:
		var requested_path: String = String(path_value).strip_edges()
		if requested_path.is_empty():
			return _send_error(client_id, "node_paths cannot contain empty values", command_id)
		unique_paths[requested_path] = true

	var selected_nodes: Array = []
	for requested_path in unique_paths.keys():
		var node = _get_editor_node(String(requested_path))
		if not node:
			return _send_error(client_id, "Node not found: %s" % requested_path, command_id)
		if node == edited_scene_root:
			return _send_error(client_id, "Cannot delete the scene root via batch_delete_nodes", command_id)
		if not node.get_parent():
			return _send_error(client_id, "Node has no parent: %s" % requested_path, command_id)
		selected_nodes.append(node)

	var nodes_to_delete: Array = []
	var skipped_descendants: Array = []
	for candidate in selected_nodes:
		var skip := false
		for other in selected_nodes:
			if candidate == other:
				continue
			if other.is_ancestor_of(candidate):
				skip = true
				break
		if skip:
			skipped_descendants.append(_to_mcp_path(candidate))
		else:
			nodes_to_delete.append(candidate)

	if nodes_to_delete.is_empty():
		return _send_success(client_id, {
			"deleted_nodes": [],
			"requested_count": unique_paths.size(),
			"deleted_count": 0,
			"skipped_descendants": skipped_descendants,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "batch_delete_nodes",
		"requested_count": unique_paths.size(),
		"deleted_count": nodes_to_delete.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Batch Delete Nodes", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Batch Delete Nodes", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for batch node deletion", command_id)

	var deleted_entries: Array = []
	for node in nodes_to_delete:
		var parent = node.get_parent()
		var child_index = parent.get_children().find(node)
		var previous_owner = node.owner
		transaction.add_do_method(parent, "remove_child", [node])
		transaction.add_do_method(node, "queue_free")
		transaction.add_undo_method(parent, "add_child", [node])
		transaction.add_undo_method(parent, "move_child", [node, child_index])
		transaction.add_undo_property(node, "owner", previous_owner)
		transaction.add_do_reference(node)
		deleted_entries.append({
			"node_path": _to_mcp_path(node),
			"parent_path": _to_mcp_path(parent),
			"index": child_index,
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			selection.add_node(edited_scene_root)
		_log("Batch deleted nodes", "_batch_delete_nodes", {
			"requested_count": unique_paths.size(),
			"deleted_count": deleted_entries.size(),
			"skipped_descendants": skipped_descendants,
			"deleted_nodes": deleted_entries,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"requested_count": unique_paths.size(),
		"deleted_count": deleted_entries.size(),
		"deleted_nodes": deleted_entries,
		"skipped_descendants": skipped_descendants,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit batch node deletion", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_node_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var script_path: String = params.get("script_path", "")
	var create_script: bool = params.get("create_script", false)
	var extends_type: String = String(params.get("extends_type", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if script_path.is_empty():
		return _send_error(client_id, "Script path cannot be empty", command_id)
	if not script_path.begins_with("res://"):
		return _send_error(client_id, "Script path must be within the project (res://)", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if create_script and not FileAccess.file_exists(script_path):
		var script_extends := extends_type if not extends_type.is_empty() else node.get_class()
		if not ScriptUtils.create_script_file(script_path, "", script_extends):
			return _send_error(client_id, "Failed to create script at %s" % script_path, command_id)

	var script_resource = ResourceLoader.load(script_path, "Script", ResourceLoader.CACHE_MODE_REPLACE)
	if not script_resource or not (script_resource is Script):
		return _send_error(client_id, "Failed to load script at %s" % script_path, command_id)

	var new_script: Script = script_resource
	var previous_script: Script = node.get_script()
	if previous_script == new_script:
		return _send_success(client_id, {
			"node_path": node_path,
			"script_path": script_path,
			"status": "no_change",
		}, command_id)

	var previous_script_path := (
		previous_script.resource_path if previous_script and previous_script.resource_path != "" else ""
	)
	var transaction_metadata := {
		"command": "set_node_script",
		"node_path": node_path,
		"script_path": script_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set Node Script", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set Node Script", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for script assignment", command_id)

	transaction.add_do_property(node, "script", new_script)
	transaction.add_undo_property(node, "script", previous_script)
	transaction.add_do_reference(new_script)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Assigned script to node", "_set_node_script", {
			"node_path": _to_mcp_path(node),
			"script_path": script_path,
			"previous_script_path": previous_script_path,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_path": node_path,
		"script_path": script_path,
		"previous_script_path": previous_script_path,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit script assignment", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _clear_node_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var previous_script: Script = node.get_script()
	if not previous_script:
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
		}, command_id)

	var previous_script_path := previous_script.resource_path if previous_script.resource_path != "" else ""
	var transaction_metadata := {
		"command": "clear_node_script",
		"node_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Clear Node Script", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Clear Node Script", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for script removal", command_id)

	transaction.add_do_property(node, "script", null)
	transaction.add_undo_property(node, "script", previous_script)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Cleared script from node", "_clear_node_script", {
			"node_path": _to_mcp_path(node),
			"previous_script_path": previous_script_path,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_path": node_path,
		"previous_script_path": previous_script_path,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit script removal", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_node_owner_recursive(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var owner_path: String = params.get("owner_path", "/root")
	var include_root: bool = params.get("include_root", true)
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if owner_path.is_empty():
		return _send_error(client_id, "Owner path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var owner_node = _get_editor_node(owner_path)
	if not owner_node:
		return _send_error(client_id, "Owner node not found: %s" % owner_path, command_id)

	var targets: Array = []
	_collect_node_subtree(node, targets, include_root)

	var pending_changes: Array = []
	for target_node in targets:
		var target: Node = target_node
		if target != owner_node and not owner_node.is_ancestor_of(target):
			return _send_error(
				client_id,
				"Owner node %s must be an ancestor of %s" % [_to_mcp_path(owner_node), _to_mcp_path(target)],
				command_id
			)
		var previous_owner = target.owner
		if previous_owner == owner_node:
			continue
		pending_changes.append({
			"node": target,
			"path": _to_mcp_path(target),
			"previous_owner": previous_owner,
			"previous_owner_path": (_to_mcp_path(previous_owner) if previous_owner else ""),
		})

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"owner_path": _to_mcp_path(owner_node),
			"changed_count": 0,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "set_node_owner_recursive",
		"node_path": node_path,
		"owner_path": _to_mcp_path(owner_node),
		"include_root": include_root,
		"changed_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set Node Owner Recursive", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set Node Owner Recursive", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for owner assignment", command_id)

	for change in pending_changes:
		var change_node: Node = change["node"]
		transaction.add_do_property(change_node, "owner", owner_node)
		transaction.add_undo_property(change_node, "owner", change["previous_owner"])

	var changed_paths: Array = []
	for change in pending_changes:
		changed_paths.append(change["path"])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Updated node owner recursively", "_set_node_owner_recursive", {
			"node_path": node_path,
			"owner_path": _to_mcp_path(owner_node),
			"changed_count": changed_paths.size(),
			"changed_nodes": changed_paths,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_path": node_path,
		"owner_path": _to_mcp_path(owner_node),
		"changed_count": changed_paths.size(),
		"changed_nodes": changed_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit owner assignment", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _paint_tilemap_cells_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var requested_layer: int = int(params.get("layer", 0))
	var cells_param = params.get("cells", [])
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if typeof(cells_param) != TYPE_ARRAY:
		return _send_error(client_id, "cells must be an array", command_id)

	var cells: Array = cells_param
	if cells.is_empty():
		return _send_error(client_id, "cells array cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not _is_supported_tilemap_node(node):
		return _send_error(client_id, "Node at %s must be TileMapLayer or TileMap" % node_path, command_id)

	var layer := requested_layer
	if node is TileMapLayer:
		layer = 0
	elif node is TileMap:
		var tilemap: TileMap = node
		var layer_count: int = tilemap.get_layers_count()
		if layer < 0 or layer >= layer_count:
			return _send_error(client_id, "TileMap layer index out of bounds: %d" % layer, command_id)

	var pending_changes: Array = []
	for idx in range(cells.size()):
		var entry_raw = cells[idx]
		if typeof(entry_raw) != TYPE_DICTIONARY:
			return _send_error(client_id, "cells[%d] must be a dictionary" % idx, command_id)
		var entry: Dictionary = entry_raw
		var coords_result := _parse_tilemap_coords(entry)
		if not coords_result.get("ok", false):
			return _send_error(client_id, "cells[%d]: %s" % [idx, coords_result.get("error", "Invalid cell coordinates")], command_id)

		if not entry.has("source_id"):
			return _send_error(client_id, "cells[%d].source_id is required" % idx, command_id)

		var coords: Vector2i = coords_result.get("coords")
		var source_id: int = int(entry.get("source_id", -1))
		var atlas_result := _parse_vector2i_with_default(entry.get("atlas_coords", Vector2i(-1, -1)))
		if not atlas_result.get("ok", false):
			return _send_error(client_id, "cells[%d]: invalid atlas_coords" % idx, command_id)
		var atlas_coords: Vector2i = atlas_result.get("value")
		var alternative_tile: int = int(entry.get("alternative_tile", 0))

		var new_cell := _make_tilemap_cell_data(source_id, atlas_coords, alternative_tile)
		var previous_cell := _get_tilemap_cell_data(node, layer, coords)
		if _tilemap_cell_data_equal(previous_cell, new_cell):
			continue

		pending_changes.append({
			"coords": coords,
			"new_cell": new_cell,
			"previous_cell": previous_cell,
		})

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"layer": layer,
			"status": "no_change",
			"changes": [],
		}, command_id)

	var transaction_metadata := {
		"command": "paint_tilemap_cells_2d",
		"node_path": node_path,
		"layer": layer,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Paint TileMap Cells 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Paint TileMap Cells 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for TileMap painting", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		var coords: Vector2i = change["coords"]
		var previous_cell: Dictionary = change["previous_cell"]
		var new_cell: Dictionary = change["new_cell"]

		if _tilemap_cell_is_empty(new_cell):
			transaction.add_do_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_do_method(self, "_apply_tilemap_set_cell", [node, layer, coords, new_cell])

		if _tilemap_cell_is_empty(previous_cell):
			transaction.add_undo_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_undo_method(self, "_apply_tilemap_set_cell", [node, layer, coords, previous_cell])

		serialized_changes.append({
			"coords": _vector2i_to_dict(coords),
			"previous_cell": _serialize_tilemap_cell_data(previous_cell),
			"new_cell": _serialize_tilemap_cell_data(new_cell),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Painted TileMap cells", "_paint_tilemap_cells_2d", {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "tilemap_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"change_count": serialized_changes.size(),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit TileMap painting", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _clear_tilemap_cells_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var requested_layer: int = int(params.get("layer", 0))
	var cells_param = params.get("cells", [])
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if typeof(cells_param) != TYPE_ARRAY:
		return _send_error(client_id, "cells must be an array", command_id)

	var cells: Array = cells_param
	if cells.is_empty():
		return _send_error(client_id, "cells array cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not _is_supported_tilemap_node(node):
		return _send_error(client_id, "Node at %s must be TileMapLayer or TileMap" % node_path, command_id)

	var layer := requested_layer
	if node is TileMapLayer:
		layer = 0
	elif node is TileMap:
		var tilemap: TileMap = node
		var layer_count: int = tilemap.get_layers_count()
		if layer < 0 or layer >= layer_count:
			return _send_error(client_id, "TileMap layer index out of bounds: %d" % layer, command_id)

	var pending_changes: Array = []
	for idx in range(cells.size()):
		var entry_raw = cells[idx]
		var coords_result: Dictionary
		if typeof(entry_raw) == TYPE_DICTIONARY:
			coords_result = _parse_tilemap_coords(entry_raw)
		else:
			coords_result = _parse_vector2i_with_default(entry_raw)
			if coords_result.get("ok", false):
				coords_result = {
					"ok": true,
					"coords": coords_result.get("value"),
				}
		if not coords_result.get("ok", false):
			return _send_error(client_id, "cells[%d]: invalid coordinates" % idx, command_id)

		var coords: Vector2i = coords_result.get("coords")
		var previous_cell := _get_tilemap_cell_data(node, layer, coords)
		if _tilemap_cell_is_empty(previous_cell):
			continue

		pending_changes.append({
			"coords": coords,
			"previous_cell": previous_cell,
		})

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"layer": layer,
			"status": "no_change",
			"changes": [],
		}, command_id)

	var transaction_metadata := {
		"command": "clear_tilemap_cells_2d",
		"node_path": node_path,
		"layer": layer,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Clear TileMap Cells 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Clear TileMap Cells 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for TileMap clearing", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		var coords: Vector2i = change["coords"]
		var previous_cell: Dictionary = change["previous_cell"]
		transaction.add_do_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		transaction.add_undo_method(self, "_apply_tilemap_set_cell", [node, layer, coords, previous_cell])

		serialized_changes.append({
			"coords": _vector2i_to_dict(coords),
			"previous_cell": _serialize_tilemap_cell_data(previous_cell),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Cleared TileMap cells", "_clear_tilemap_cells_2d", {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "tilemap_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"change_count": serialized_changes.size(),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit TileMap clearing", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_camera2d_follow(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Camera2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Camera2D):
		return _send_error(client_id, "Node at %s is not a Camera2D" % node_path, command_id)

	var camera: Camera2D = node
	var pending_changes: Array = []

	if params.has("zoom"):
		var zoom_value := _parse_vector2_param(params.get("zoom"))
		pending_changes.append_array(_capture_property_change(camera, "zoom", zoom_value))

	if params.has("offset"):
		var offset_value := _parse_vector2_param(params.get("offset"))
		pending_changes.append_array(_capture_property_change(camera, "offset", offset_value))

	if params.has("enabled"):
		pending_changes.append_array(_capture_property_change(camera, "enabled", bool(params.get("enabled"))))

	if params.has("ignore_rotation"):
		pending_changes.append_array(_capture_property_change(camera, "ignore_rotation", bool(params.get("ignore_rotation"))))

	if params.has("position_smoothing_enabled"):
		pending_changes.append_array(
			_capture_property_change(camera, "position_smoothing_enabled", bool(params.get("position_smoothing_enabled")))
		)
	if params.has("position_smoothing_speed"):
		pending_changes.append_array(
			_capture_property_change(camera, "position_smoothing_speed", float(params.get("position_smoothing_speed")))
		)
	if params.has("rotation_smoothing_enabled"):
		pending_changes.append_array(
			_capture_property_change(camera, "rotation_smoothing_enabled", bool(params.get("rotation_smoothing_enabled")))
		)
	if params.has("rotation_smoothing_speed"):
		pending_changes.append_array(
			_capture_property_change(camera, "rotation_smoothing_speed", float(params.get("rotation_smoothing_speed")))
		)

	var drag_enabled_param = params.get("drag_enabled", null)
	if drag_enabled_param != null:
		if typeof(drag_enabled_param) != TYPE_DICTIONARY:
			return _send_error(client_id, "drag_enabled must be a dictionary", command_id)
		var drag_enabled: Dictionary = drag_enabled_param
		if drag_enabled.has("horizontal"):
			pending_changes.append_array(
				_capture_property_change(camera, "drag_horizontal_enabled", bool(drag_enabled["horizontal"]))
			)
		if drag_enabled.has("vertical"):
			pending_changes.append_array(
				_capture_property_change(camera, "drag_vertical_enabled", bool(drag_enabled["vertical"]))
			)

	var drag_margins_param = params.get("drag_margins", null)
	if drag_margins_param != null:
		if typeof(drag_margins_param) != TYPE_DICTIONARY:
			return _send_error(client_id, "drag_margins must be a dictionary", command_id)
		var drag_margins: Dictionary = drag_margins_param
		if drag_margins.has("left"):
			pending_changes.append_array(_capture_property_change(camera, "drag_left_margin", float(drag_margins["left"])))
		if drag_margins.has("right"):
			pending_changes.append_array(_capture_property_change(camera, "drag_right_margin", float(drag_margins["right"])))
		if drag_margins.has("top"):
			pending_changes.append_array(_capture_property_change(camera, "drag_top_margin", float(drag_margins["top"])))
		if drag_margins.has("bottom"):
			pending_changes.append_array(_capture_property_change(camera, "drag_bottom_margin", float(drag_margins["bottom"])))

	var drag_offsets_param = params.get("drag_offsets", null)
	if drag_offsets_param != null:
		if typeof(drag_offsets_param) != TYPE_DICTIONARY:
			return _send_error(client_id, "drag_offsets must be a dictionary", command_id)
		var drag_offsets: Dictionary = drag_offsets_param
		if drag_offsets.has("horizontal"):
			pending_changes.append_array(
				_capture_property_change(camera, "drag_horizontal_offset", float(drag_offsets["horizontal"]))
			)
		if drag_offsets.has("vertical"):
			pending_changes.append_array(
				_capture_property_change(camera, "drag_vertical_offset", float(drag_offsets["vertical"]))
			)

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_camera2d_follow",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Camera2D Follow", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Camera2D Follow", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Camera2D follow configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(camera, change.property, change.value)
		transaction.add_undo_property(camera, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Camera2D follow", "_configure_camera2d_follow", {
			"node_path": _to_mcp_path(camera),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "camera2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(camera),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Camera2D follow configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_animation_tree_state(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var state_name: String = String(params.get("state_name", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "AnimationTree node path cannot be empty", command_id)
	if state_name.is_empty():
		return _send_error(client_id, "state_name cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is AnimationTree):
		return _send_error(client_id, "Node at %s is not an AnimationTree" % node_path, command_id)

	var tree: AnimationTree = node
	var playback = tree.get("parameters/playback")
	if playback == null or not (playback is AnimationNodeStateMachinePlayback):
		return _send_error(client_id, "AnimationTree does not expose AnimationNodeStateMachine playback at parameters/playback", command_id)

	var state_machine_playback: AnimationNodeStateMachinePlayback = playback
	var previous_state: String = ""
	if state_machine_playback.has_method("get_current_node"):
		previous_state = String(state_machine_playback.get_current_node())

	var pending_changes: Array = []
	if params.has("active"):
		pending_changes.append_array(_capture_property_change(tree, "active", bool(params.get("active"))))
	if params.has("process_callback"):
		pending_changes.append_array(_capture_property_change(tree, "process_callback", int(params.get("process_callback"))))

	var should_travel: bool = previous_state != state_name
	var use_start: bool = bool(params.get("use_start", false))
	var reset_on_teleport: bool = bool(params.get("reset_on_teleport", true))

	if pending_changes.is_empty() and not should_travel:
		return _send_success(client_id, {
			"node_path": node_path,
			"state_name": state_name,
			"previous_state": previous_state,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "set_animation_tree_state",
		"node_path": node_path,
		"state_name": state_name,
		"previous_state": previous_state,
		"property_change_count": pending_changes.size(),
		"will_travel": should_travel,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set AnimationTree State", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set AnimationTree State", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for AnimationTree state update", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(tree, change.property, change.value)
		transaction.add_undo_property(tree, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	if should_travel:
		if use_start:
			transaction.add_do_method(state_machine_playback, "start", [state_name, reset_on_teleport])
		else:
			transaction.add_do_method(state_machine_playback, "travel", [state_name])

		if previous_state.is_empty():
			if state_machine_playback.has_method("stop"):
				transaction.add_undo_method(state_machine_playback, "stop")
		else:
			transaction.add_undo_method(state_machine_playback, "travel", [previous_state])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Set AnimationTree state", "_set_animation_tree_state", {
			"node_path": _to_mcp_path(tree),
			"state_name": state_name,
			"previous_state": previous_state,
			"property_change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "animation_tree",
			"line_num": 0,
		})
	)

	var current_state = state_machine_playback.get_current_node() if state_machine_playback.has_method("get_current_node") else state_name
	var response := {
		"node_path": _to_mcp_path(tree),
		"state_name": state_name,
		"previous_state": previous_state,
		"current_state": String(current_state),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit AnimationTree state update", command_id)
		var committed_state = state_machine_playback.get_current_node() if state_machine_playback.has_method("get_current_node") else state_name
		response["current_state"] = String(committed_state)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_animation_tree_parameters(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")
	var parameters_raw = params.get("parameters", {})

	if node_path.is_empty():
		return _send_error(client_id, "AnimationTree node path cannot be empty", command_id)
	if typeof(parameters_raw) != TYPE_DICTIONARY:
		return _send_error(client_id, "parameters must be a dictionary", command_id)
	var parameter_values: Dictionary = parameters_raw
	if parameter_values.is_empty():
		return _send_error(client_id, "parameters cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is AnimationTree):
		return _send_error(client_id, "Node at %s is not an AnimationTree" % node_path, command_id)

	var tree: AnimationTree = node
	var pending_changes: Array = []
	for raw_key in parameter_values.keys():
		var parameter_path: String = String(raw_key).strip_edges()
		if parameter_path.is_empty():
			return _send_error(client_id, "Parameter key cannot be empty", command_id)
		var new_value = parameter_values[raw_key]
		var previous_value = tree.get(parameter_path)
		if previous_value == new_value:
			continue
		pending_changes.append({
			"property": parameter_path,
			"previous": previous_value,
			"value": new_value,
		})

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
			"changes": [],
		}, command_id)

	var transaction_metadata := {
		"command": "set_animation_tree_parameters",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set AnimationTree Parameters", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set AnimationTree Parameters", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for AnimationTree parameter update", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(tree, change.property, change.value)
		transaction.add_undo_property(tree, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Set AnimationTree parameters", "_set_animation_tree_parameters", {
			"node_path": _to_mcp_path(tree),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "animation_tree",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(tree),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit AnimationTree parameter update", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_wave_spawner_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var spawner_name: String = String(params.get("spawner_name", "WaveSpawner2D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var spawn_points_raw = params.get("spawn_points", [])
	var create_timer: bool = bool(params.get("create_timer", true))
	var timer_name: String = String(params.get("timer_name", "WaveTimer")).strip_edges()
	var create_spawn_nodes: bool = bool(params.get("create_spawn_nodes", true))
	var spawn_nodes_parent_name: String = String(params.get("spawn_nodes_parent_name", "SpawnPoints")).strip_edges()

	if spawner_name.is_empty():
		spawner_name = "WaveSpawner2D"
	if timer_name.is_empty():
		timer_name = "WaveTimer"
	if spawn_nodes_parent_name.is_empty():
		spawn_nodes_parent_name = "SpawnPoints"
	if typeof(spawn_points_raw) != TYPE_ARRAY:
		return _send_error(client_id, "spawn_points must be an array", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var spawn_points: Array = []
	var spawn_points_input: Array = spawn_points_raw
	for idx in range(spawn_points_input.size()):
		var point = _parse_vector2_param(spawn_points_input[idx])
		spawn_points.append(point)

	var spawner_root := Node2D.new()
	spawner_root.name = _resolve_unique_child_name(parent, spawner_name)

	var attach_plans: Array = [{"parent": parent, "node": spawner_root}]
	var created_nodes: Array = [spawner_root]

	var spawn_parent: Node2D = spawner_root
	if create_spawn_nodes:
		var spawn_container := Node2D.new()
		spawn_container.name = _resolve_unique_child_name(spawner_root, spawn_nodes_parent_name)
		attach_plans.append({"parent": spawner_root, "node": spawn_container})
		created_nodes.append(spawn_container)
		spawn_parent = spawn_container

	var serialized_spawn_points: Array = []
	for idx in range(spawn_points.size()):
		var point: Vector2 = spawn_points[idx]
		serialized_spawn_points.append(_vector2_to_dict(point))
		if create_spawn_nodes:
			var marker := Marker2D.new()
			marker.name = _resolve_unique_child_name(spawn_parent, "SpawnPoint%02d" % (idx + 1))
			marker.position = point
			attach_plans.append({"parent": spawn_parent, "node": marker})
			created_nodes.append(marker)

	if create_timer:
		var timer := Timer.new()
		timer.name = _resolve_unique_child_name(spawner_root, timer_name)
		timer.one_shot = false
		timer.autostart = false
		timer.wait_time = max(0.01, float(params.get("wave_interval", 2.0)))
		attach_plans.append({"parent": spawner_root, "node": timer})
		created_nodes.append(timer)

	var meta_changes: Array = []
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawner_type", "wave_spawner_2d"))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_wave_interval", max(0.01, float(params.get("wave_interval", 2.0)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_enemies_per_wave", max(1, int(params.get("enemies_per_wave", 3)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_max_waves", max(1, int(params.get("max_waves", 5)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_current_wave", max(0, int(params.get("current_wave", 0)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawn_point_cursor", 0))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawn_points_2d", serialized_spawn_points))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_auto_start", bool(params.get("auto_start", false))))
	var enemy_scene_path: String = String(params.get("enemy_scene_path", "")).strip_edges()
	if not enemy_scene_path.is_empty():
		meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_enemy_scene_path", enemy_scene_path))

	var transaction_metadata := {
		"command": "build_wave_spawner_2d",
		"parent_path": _to_mcp_path(parent),
		"spawner_name": spawner_root.name,
		"spawn_point_count": spawn_points.size(),
		"created_count": created_nodes.size(),
		"meta_change_count": meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Wave Spawner 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Wave Spawner 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for wave spawner 2D generation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(spawner_root, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(spawner_root, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(spawner_root, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built wave spawner 2D", "_build_wave_spawner_2d", {
			"spawner_path": _to_mcp_path(spawner_root),
			"spawn_point_count": spawn_points.size(),
			"created_count": created_nodes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "wave_spawner_2d",
			"line_num": 0,
		})
	)

	var predicted_spawner_path: String = _join_mcp_path(_to_mcp_path(parent), spawner_root.name)
	var response := {
		"spawner_path": predicted_spawner_path,
		"spawner_name": spawner_root.name,
		"spawn_points": serialized_spawn_points,
		"spawn_point_count": serialized_spawn_points.size(),
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit wave spawner 2D generation", command_id)
		response["spawner_path"] = _to_mcp_path(spawner_root)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_wave_spawner_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var spawner_name: String = String(params.get("spawner_name", "WaveSpawner3D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var spawn_points_raw = params.get("spawn_points", [])
	var create_timer: bool = bool(params.get("create_timer", true))
	var timer_name: String = String(params.get("timer_name", "WaveTimer")).strip_edges()
	var create_spawn_nodes: bool = bool(params.get("create_spawn_nodes", true))
	var spawn_nodes_parent_name: String = String(params.get("spawn_nodes_parent_name", "SpawnPoints")).strip_edges()

	if spawner_name.is_empty():
		spawner_name = "WaveSpawner3D"
	if timer_name.is_empty():
		timer_name = "WaveTimer"
	if spawn_nodes_parent_name.is_empty():
		spawn_nodes_parent_name = "SpawnPoints"
	if typeof(spawn_points_raw) != TYPE_ARRAY:
		return _send_error(client_id, "spawn_points must be an array", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var spawn_points: Array = []
	var spawn_points_input: Array = spawn_points_raw
	for idx in range(spawn_points_input.size()):
		var point = _parse_vector3_param(spawn_points_input[idx])
		spawn_points.append(point)

	var spawner_root := Node3D.new()
	spawner_root.name = _resolve_unique_child_name(parent, spawner_name)

	var attach_plans: Array = [{"parent": parent, "node": spawner_root}]
	var created_nodes: Array = [spawner_root]

	var spawn_parent: Node3D = spawner_root
	if create_spawn_nodes:
		var spawn_container := Node3D.new()
		spawn_container.name = _resolve_unique_child_name(spawner_root, spawn_nodes_parent_name)
		attach_plans.append({"parent": spawner_root, "node": spawn_container})
		created_nodes.append(spawn_container)
		spawn_parent = spawn_container

	var serialized_spawn_points: Array = []
	for idx in range(spawn_points.size()):
		var point: Vector3 = spawn_points[idx]
		serialized_spawn_points.append(_vector3_to_dict(point))
		if create_spawn_nodes:
			var marker := Marker3D.new()
			marker.name = _resolve_unique_child_name(spawn_parent, "SpawnPoint%02d" % (idx + 1))
			marker.position = point
			attach_plans.append({"parent": spawn_parent, "node": marker})
			created_nodes.append(marker)

	if create_timer:
		var timer := Timer.new()
		timer.name = _resolve_unique_child_name(spawner_root, timer_name)
		timer.one_shot = false
		timer.autostart = false
		timer.wait_time = max(0.01, float(params.get("wave_interval", 2.0)))
		attach_plans.append({"parent": spawner_root, "node": timer})
		created_nodes.append(timer)

	var meta_changes: Array = []
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawner_type", "wave_spawner_3d"))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_wave_interval", max(0.01, float(params.get("wave_interval", 2.0)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_enemies_per_wave", max(1, int(params.get("enemies_per_wave", 3)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_max_waves", max(1, int(params.get("max_waves", 5)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_current_wave", max(0, int(params.get("current_wave", 0)))))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawn_point_cursor", 0))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_spawn_points_3d", serialized_spawn_points))
	meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_auto_start", bool(params.get("auto_start", false))))
	var enemy_scene_path: String = String(params.get("enemy_scene_path", "")).strip_edges()
	if not enemy_scene_path.is_empty():
		meta_changes.append_array(_capture_meta_change(spawner_root, "mcp_enemy_scene_path", enemy_scene_path))

	var transaction_metadata := {
		"command": "build_wave_spawner_3d",
		"parent_path": _to_mcp_path(parent),
		"spawner_name": spawner_root.name,
		"spawn_point_count": spawn_points.size(),
		"created_count": created_nodes.size(),
		"meta_change_count": meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Wave Spawner 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Wave Spawner 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for wave spawner 3D generation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(spawner_root, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(spawner_root, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(spawner_root, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built wave spawner 3D", "_build_wave_spawner_3d", {
			"spawner_path": _to_mcp_path(spawner_root),
			"spawn_point_count": spawn_points.size(),
			"created_count": created_nodes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "wave_spawner_3d",
			"line_num": 0,
		})
	)

	var predicted_spawner_path: String = _join_mcp_path(_to_mcp_path(parent), spawner_root.name)
	var response := {
		"spawner_path": predicted_spawner_path,
		"spawner_name": spawner_root.name,
		"spawn_points": serialized_spawn_points,
		"spawn_point_count": serialized_spawn_points.size(),
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit wave spawner 3D generation", command_id)
		response["spawner_path"] = _to_mcp_path(spawner_root)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_wave_spawner_step_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var spawner_path: String = params.get("spawner_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if spawner_path.is_empty():
		return _send_error(client_id, "spawner_path cannot be empty", command_id)

	var node = _get_editor_node(spawner_path)
	if not node:
		return _send_error(client_id, "Spawner node not found: %s" % spawner_path, command_id)
	if not (node is Node2D):
		return _send_error(client_id, "Spawner at %s must inherit Node2D" % spawner_path, command_id)
	var spawner: Node2D = node

	var spawn_points_data = spawner.get_meta("mcp_spawn_points_2d") if spawner.has_meta("mcp_spawn_points_2d") else []
	if typeof(spawn_points_data) != TYPE_ARRAY:
		return _send_error(client_id, "Spawner metadata mcp_spawn_points_2d must be an array", command_id)
	var spawn_points_raw: Array = spawn_points_data
	if spawn_points_raw.is_empty():
		return _send_error(client_id, "Spawner has no configured spawn points", command_id)

	var spawn_count: int = max(1, int(params.get("spawn_count", spawner.get_meta("mcp_enemies_per_wave") if spawner.has_meta("mcp_enemies_per_wave") else 1)))
	var current_wave: int = int(spawner.get_meta("mcp_current_wave")) if spawner.has_meta("mcp_current_wave") else 0
	var max_waves: int = max(1, int(spawner.get_meta("mcp_max_waves")) if spawner.has_meta("mcp_max_waves") else 1)
	var cursor: int = int(spawner.get_meta("mcp_spawn_point_cursor")) if spawner.has_meta("mcp_spawn_point_cursor") else 0
	var advance_wave: bool = bool(params.get("advance_wave", true))

	var selected_points: Array = []
	var spawn_points_count: int = spawn_points_raw.size()
	for idx in range(spawn_count):
		var source_idx = posmod(cursor + idx, spawn_points_count)
		selected_points.append(_parse_vector2_param(spawn_points_raw[source_idx]))
	var next_cursor: int = posmod(cursor + spawn_count, spawn_points_count)
	var next_wave: int = current_wave + 1 if advance_wave else current_wave
	var reached_limit: bool = next_wave >= max_waves

	var instantiate_enemy: bool = bool(params.get("instantiate_enemy", false))
	var enemy_scene_path: String = String(params.get("enemy_scene_path", spawner.get_meta("mcp_enemy_scene_path") if spawner.has_meta("mcp_enemy_scene_path") else "")).strip_edges()
	var spawned_nodes: Array = []
	var created_nodes: Array = []
	var attach_plans: Array = []

	if instantiate_enemy:
		if enemy_scene_path.is_empty():
			return _send_error(client_id, "enemy_scene_path is required when instantiate_enemy=true", command_id)
		if not enemy_scene_path.begins_with("res://"):
			return _send_error(client_id, "enemy_scene_path must be within the project (res://)", command_id)
		var packed_scene = ResourceLoader.load(enemy_scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
		if not packed_scene or not (packed_scene is PackedScene):
			return _send_error(client_id, "Failed to load PackedScene at %s" % enemy_scene_path, command_id)
		for idx in range(selected_points.size()):
			var point: Vector2 = selected_points[idx]
			var instance = (packed_scene as PackedScene).instantiate()
			if not instance or not (instance is Node2D):
				return _send_error(client_id, "Spawned scene instance must inherit Node2D for wave spawner 2D", command_id)
			var enemy_instance: Node2D = instance
			enemy_instance.name = _resolve_unique_child_name(spawner.get_parent(), String(enemy_instance.name))
			enemy_instance.global_position = point
			attach_plans.append({
				"parent": spawner.get_parent(),
				"node": enemy_instance,
			})
			created_nodes.append(enemy_instance)
			spawned_nodes.append(enemy_instance)

	var meta_changes: Array = []
	meta_changes.append_array(_capture_meta_change(spawner, "mcp_spawn_point_cursor", next_cursor))
	if advance_wave:
		meta_changes.append_array(_capture_meta_change(spawner, "mcp_current_wave", next_wave))
		meta_changes.append_array(_capture_meta_change(spawner, "mcp_wave_complete", reached_limit))

	if meta_changes.is_empty() and attach_plans.is_empty():
		return _send_success(client_id, {
			"spawner_path": spawner_path,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_wave_spawner_step_2d",
		"spawner_path": spawner_path,
		"spawn_count": spawn_count,
		"selected_count": selected_points.size(),
		"created_count": created_nodes.size(),
		"current_wave": current_wave,
		"next_wave": next_wave,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Wave Spawner Step 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Wave Spawner Step 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for wave spawner 2D simulation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	var edited_scene_root = plugin.get_editor_interface().get_edited_scene_root() if plugin else null
	if edited_scene_root:
		for created in created_nodes:
			var created_node: Node = created
			transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(spawner, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(spawner, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(spawner, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_points: Array = []
	for point in selected_points:
		serialized_points.append(_vector2_to_dict(point))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated wave spawner step 2D", "_simulate_wave_spawner_step_2d", {
			"spawner_path": _to_mcp_path(spawner),
			"selected_count": serialized_points.size(),
			"created_count": created_nodes.size(),
			"current_wave": current_wave,
			"next_wave": next_wave,
			"transaction_id": transaction.transaction_id,
			"system_section": "wave_spawner_2d",
			"line_num": 0,
		})
	)

	var spawned_paths: Array = []
	for created in spawned_nodes:
		var created_node: Node = created
		spawned_paths.append(_to_mcp_path(created_node))

	var response := {
		"spawner_path": _to_mcp_path(spawner),
		"current_wave": current_wave,
		"next_wave": next_wave,
		"reached_wave_limit": reached_limit,
		"spawn_positions": serialized_points,
		"spawn_count": serialized_points.size(),
		"spawned_nodes": spawned_paths,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit wave spawner 2D simulation", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_wave_spawner_step_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var spawner_path: String = params.get("spawner_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if spawner_path.is_empty():
		return _send_error(client_id, "spawner_path cannot be empty", command_id)

	var node = _get_editor_node(spawner_path)
	if not node:
		return _send_error(client_id, "Spawner node not found: %s" % spawner_path, command_id)
	if not (node is Node3D):
		return _send_error(client_id, "Spawner at %s must inherit Node3D" % spawner_path, command_id)
	var spawner: Node3D = node

	var spawn_points_data = spawner.get_meta("mcp_spawn_points_3d") if spawner.has_meta("mcp_spawn_points_3d") else []
	if typeof(spawn_points_data) != TYPE_ARRAY:
		return _send_error(client_id, "Spawner metadata mcp_spawn_points_3d must be an array", command_id)
	var spawn_points_raw: Array = spawn_points_data
	if spawn_points_raw.is_empty():
		return _send_error(client_id, "Spawner has no configured spawn points", command_id)

	var spawn_count: int = max(1, int(params.get("spawn_count", spawner.get_meta("mcp_enemies_per_wave") if spawner.has_meta("mcp_enemies_per_wave") else 1)))
	var current_wave: int = int(spawner.get_meta("mcp_current_wave")) if spawner.has_meta("mcp_current_wave") else 0
	var max_waves: int = max(1, int(spawner.get_meta("mcp_max_waves")) if spawner.has_meta("mcp_max_waves") else 1)
	var cursor: int = int(spawner.get_meta("mcp_spawn_point_cursor")) if spawner.has_meta("mcp_spawn_point_cursor") else 0
	var advance_wave: bool = bool(params.get("advance_wave", true))

	var selected_points: Array = []
	var spawn_points_count: int = spawn_points_raw.size()
	for idx in range(spawn_count):
		var source_idx = posmod(cursor + idx, spawn_points_count)
		selected_points.append(_parse_vector3_param(spawn_points_raw[source_idx]))
	var next_cursor: int = posmod(cursor + spawn_count, spawn_points_count)
	var next_wave: int = current_wave + 1 if advance_wave else current_wave
	var reached_limit: bool = next_wave >= max_waves

	var instantiate_enemy: bool = bool(params.get("instantiate_enemy", false))
	var enemy_scene_path: String = String(params.get("enemy_scene_path", spawner.get_meta("mcp_enemy_scene_path") if spawner.has_meta("mcp_enemy_scene_path") else "")).strip_edges()
	var spawned_nodes: Array = []
	var created_nodes: Array = []
	var attach_plans: Array = []

	if instantiate_enemy:
		if enemy_scene_path.is_empty():
			return _send_error(client_id, "enemy_scene_path is required when instantiate_enemy=true", command_id)
		if not enemy_scene_path.begins_with("res://"):
			return _send_error(client_id, "enemy_scene_path must be within the project (res://)", command_id)
		var packed_scene = ResourceLoader.load(enemy_scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
		if not packed_scene or not (packed_scene is PackedScene):
			return _send_error(client_id, "Failed to load PackedScene at %s" % enemy_scene_path, command_id)
		for idx in range(selected_points.size()):
			var point: Vector3 = selected_points[idx]
			var instance = (packed_scene as PackedScene).instantiate()
			if not instance or not (instance is Node3D):
				return _send_error(client_id, "Spawned scene instance must inherit Node3D for wave spawner 3D", command_id)
			var enemy_instance: Node3D = instance
			enemy_instance.name = _resolve_unique_child_name(spawner.get_parent(), String(enemy_instance.name))
			enemy_instance.global_position = point
			attach_plans.append({
				"parent": spawner.get_parent(),
				"node": enemy_instance,
			})
			created_nodes.append(enemy_instance)
			spawned_nodes.append(enemy_instance)

	var meta_changes: Array = []
	meta_changes.append_array(_capture_meta_change(spawner, "mcp_spawn_point_cursor", next_cursor))
	if advance_wave:
		meta_changes.append_array(_capture_meta_change(spawner, "mcp_current_wave", next_wave))
		meta_changes.append_array(_capture_meta_change(spawner, "mcp_wave_complete", reached_limit))

	if meta_changes.is_empty() and attach_plans.is_empty():
		return _send_success(client_id, {
			"spawner_path": spawner_path,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_wave_spawner_step_3d",
		"spawner_path": spawner_path,
		"spawn_count": spawn_count,
		"selected_count": selected_points.size(),
		"created_count": created_nodes.size(),
		"current_wave": current_wave,
		"next_wave": next_wave,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Wave Spawner Step 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Wave Spawner Step 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for wave spawner 3D simulation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	var edited_scene_root = plugin.get_editor_interface().get_edited_scene_root() if plugin else null
	if edited_scene_root:
		for created in created_nodes:
			var created_node: Node = created
			transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(spawner, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(spawner, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(spawner, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_points: Array = []
	for point in selected_points:
		serialized_points.append(_vector3_to_dict(point))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated wave spawner step 3D", "_simulate_wave_spawner_step_3d", {
			"spawner_path": _to_mcp_path(spawner),
			"selected_count": serialized_points.size(),
			"created_count": created_nodes.size(),
			"current_wave": current_wave,
			"next_wave": next_wave,
			"transaction_id": transaction.transaction_id,
			"system_section": "wave_spawner_3d",
			"line_num": 0,
		})
	)

	var spawned_paths: Array = []
	for created in spawned_nodes:
		var created_node: Node = created
		spawned_paths.append(_to_mcp_path(created_node))

	var response := {
		"spawner_path": _to_mcp_path(spawner),
		"current_wave": current_wave,
		"next_wave": next_wave,
		"reached_wave_limit": reached_limit,
		"spawn_positions": serialized_points,
		"spawn_count": serialized_points.size(),
		"spawned_nodes": spawned_paths,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit wave spawner 3D simulation", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_camera2d_shake(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Camera2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Camera2D):
		return _send_error(client_id, "Node at %s is not a Camera2D" % node_path, command_id)

	var camera: Camera2D = node
	var trauma: float = clampf(float(params.get("trauma", 1.0)), 0.0, 1.0)
	var amplitude: float = max(0.0, float(params.get("amplitude", 12.0)))
	var rotation_amplitude_degrees: float = max(0.0, float(params.get("rotation_amplitude_degrees", 3.0)))
	var add_to_existing: bool = bool(params.get("add_to_existing", true))

	var rng := RandomNumberGenerator.new()
	if params.has("seed"):
		rng.seed = int(params.get("seed"))
	else:
		rng.randomize()

	var intensity: float = trauma * amplitude
	var shake_x: float = rng.randf_range(-1.0, 1.0) * intensity
	var shake_y: float = rng.randf_range(-1.0, 1.0) * intensity
	var rotation_delta: float = deg_to_rad(rng.randf_range(-1.0, 1.0) * trauma * rotation_amplitude_degrees)

	var target_offset: Vector2 = Vector2(shake_x, shake_y)
	var target_rotation: float = rotation_delta
	if add_to_existing:
		target_offset += camera.offset
		target_rotation += camera.rotation

	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(camera, "offset", target_offset))
	pending_changes.append_array(_capture_property_change(camera, "rotation", target_rotation))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
			"offset": _vector2_to_dict(camera.offset),
			"rotation_radians": camera.rotation,
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_camera2d_shake",
		"node_path": node_path,
		"trauma": trauma,
		"amplitude": amplitude,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Camera2D Shake", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Camera2D Shake", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Camera2D shake simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(camera, change.property, change.value)
		transaction.add_undo_property(camera, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated Camera2D shake", "_simulate_camera2d_shake", {
			"node_path": _to_mcp_path(camera),
			"offset": _vector2_to_dict(camera.offset),
			"rotation": camera.rotation,
			"transaction_id": transaction.transaction_id,
			"system_section": "camera2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(camera),
		"offset": _vector2_to_dict(target_offset),
		"rotation_radians": target_rotation,
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Camera2D shake simulation", command_id)
		response["offset"] = _vector2_to_dict(camera.offset)
		response["rotation_radians"] = camera.rotation
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_camera3d_shake(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Camera3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Camera3D):
		return _send_error(client_id, "Node at %s is not a Camera3D" % node_path, command_id)

	var camera: Camera3D = node
	var trauma: float = clampf(float(params.get("trauma", 1.0)), 0.0, 1.0)
	var horizontal_amplitude: float = max(0.0, float(params.get("horizontal_amplitude", 0.2)))
	var vertical_amplitude: float = max(0.0, float(params.get("vertical_amplitude", 0.2)))
	var roll_amplitude_degrees: float = max(0.0, float(params.get("roll_amplitude_degrees", 2.0)))
	var fov_pulse: float = max(0.0, float(params.get("fov_pulse", 0.0)))
	var add_to_existing: bool = bool(params.get("add_to_existing", true))

	var rng := RandomNumberGenerator.new()
	if params.has("seed"):
		rng.seed = int(params.get("seed"))
	else:
		rng.randomize()

	var offset_x_delta: float = rng.randf_range(-1.0, 1.0) * trauma * horizontal_amplitude
	var offset_y_delta: float = rng.randf_range(-1.0, 1.0) * trauma * vertical_amplitude
	var roll_delta: float = deg_to_rad(rng.randf_range(-1.0, 1.0) * trauma * roll_amplitude_degrees)
	var fov_delta: float = rng.randf_range(0.0, 1.0) * trauma * fov_pulse

	var target_h_offset: float = offset_x_delta
	var target_v_offset: float = offset_y_delta
	var target_rotation: Vector3 = Vector3(camera.rotation.x, camera.rotation.y, roll_delta)
	var target_fov: float = camera.fov + fov_delta
	if add_to_existing:
		target_h_offset += camera.h_offset
		target_v_offset += camera.v_offset
		target_rotation = Vector3(camera.rotation.x, camera.rotation.y, camera.rotation.z + roll_delta)

	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(camera, "h_offset", target_h_offset))
	pending_changes.append_array(_capture_property_change(camera, "v_offset", target_v_offset))
	pending_changes.append_array(_capture_property_change(camera, "rotation", target_rotation))
	if fov_pulse > 0.0:
		pending_changes.append_array(_capture_property_change(camera, "fov", target_fov))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
			"h_offset": camera.h_offset,
			"v_offset": camera.v_offset,
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_camera3d_shake",
		"node_path": node_path,
		"trauma": trauma,
		"horizontal_amplitude": horizontal_amplitude,
		"vertical_amplitude": vertical_amplitude,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Camera3D Shake", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Camera3D Shake", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Camera3D shake simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(camera, change.property, change.value)
		transaction.add_undo_property(camera, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated Camera3D shake", "_simulate_camera3d_shake", {
			"node_path": _to_mcp_path(camera),
			"h_offset": camera.h_offset,
			"v_offset": camera.v_offset,
			"rotation": _vector3_to_dict(camera.rotation),
			"transaction_id": transaction.transaction_id,
			"system_section": "camera3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(camera),
		"h_offset": target_h_offset,
		"v_offset": target_v_offset,
		"rotation": _vector3_to_dict(target_rotation),
		"fov": target_fov,
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Camera3D shake simulation", command_id)
		response["h_offset"] = camera.h_offset
		response["v_offset"] = camera.v_offset
		response["rotation"] = _vector3_to_dict(camera.rotation)
		response["fov"] = camera.fov
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_parallax_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Parallax node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not node.is_class("Parallax2D"):
		return _send_error(client_id, "Node at %s is not a Parallax2D" % node_path, command_id)

	var pending_changes: Array = []
	if params.has("scroll_scale"):
		pending_changes.append_array(_capture_property_change(node, "scroll_scale", _parse_vector2_param(params.get("scroll_scale"))))
	if params.has("scroll_offset"):
		pending_changes.append_array(_capture_property_change(node, "scroll_offset", _parse_vector2_param(params.get("scroll_offset"))))
	if params.has("autoscroll"):
		pending_changes.append_array(_capture_property_change(node, "autoscroll", _parse_vector2_param(params.get("autoscroll"))))
	if params.has("repeat_size"):
		pending_changes.append_array(_capture_property_change(node, "repeat_size", _parse_vector2_param(params.get("repeat_size"))))
	if params.has("follow_viewport"):
		pending_changes.append_array(_capture_property_change(node, "follow_viewport", bool(params.get("follow_viewport"))))
	if params.has("ignore_camera_scroll"):
		pending_changes.append_array(_capture_property_change(node, "ignore_camera_scroll", bool(params.get("ignore_camera_scroll"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_parallax_2d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Parallax2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Parallax2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Parallax2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(node, change.property, change.value)
		transaction.add_undo_property(node, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Parallax2D", "_configure_parallax_2d", {
			"node_path": _to_mcp_path(node),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "parallax_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(node),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Parallax2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_animated_sprite_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "AnimatedSprite2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is AnimatedSprite2D):
		return _send_error(client_id, "Node at %s is not an AnimatedSprite2D" % node_path, command_id)

	var sprite: AnimatedSprite2D = node
	var pending_changes: Array = []
	var new_frames: SpriteFrames = null

	if params.has("sprite_frames_path"):
		var sprite_frames_path: String = String(params.get("sprite_frames_path", "")).strip_edges()
		if sprite_frames_path.is_empty():
			return _send_error(client_id, "sprite_frames_path cannot be empty", command_id)
		if not sprite_frames_path.begins_with("res://"):
			return _send_error(client_id, "sprite_frames_path must use res://", command_id)
		var loaded_frames = ResourceLoader.load(sprite_frames_path, "SpriteFrames", ResourceLoader.CACHE_MODE_REPLACE)
		if not loaded_frames or not (loaded_frames is SpriteFrames):
			return _send_error(client_id, "Failed to load SpriteFrames at %s" % sprite_frames_path, command_id)
		new_frames = loaded_frames
		pending_changes.append_array(_capture_property_change(sprite, "sprite_frames", new_frames))

	if params.has("animation"):
		var animation_name: String = String(params.get("animation", "")).strip_edges()
		if animation_name.is_empty():
			return _send_error(client_id, "animation cannot be empty when provided", command_id)
		var frames_source: SpriteFrames = new_frames if new_frames != null else sprite.sprite_frames
		if frames_source == null:
			return _send_error(client_id, "Cannot set animation without sprite_frames assigned", command_id)
		if not frames_source.has_animation(animation_name):
			return _send_error(client_id, "Animation %s does not exist in SpriteFrames" % animation_name, command_id)
		pending_changes.append_array(_capture_property_change(sprite, "animation", animation_name))

	if params.has("autoplay"):
		pending_changes.append_array(_capture_property_change(sprite, "autoplay", String(params.get("autoplay", ""))))
	if params.has("speed_scale"):
		pending_changes.append_array(_capture_property_change(sprite, "speed_scale", float(params.get("speed_scale"))))
	if params.has("centered"):
		pending_changes.append_array(_capture_property_change(sprite, "centered", bool(params.get("centered"))))
	if params.has("offset"):
		pending_changes.append_array(_capture_property_change(sprite, "offset", _parse_vector2_param(params.get("offset"))))
	if params.has("flip_h"):
		pending_changes.append_array(_capture_property_change(sprite, "flip_h", bool(params.get("flip_h"))))
	if params.has("flip_v"):
		pending_changes.append_array(_capture_property_change(sprite, "flip_v", bool(params.get("flip_v"))))
	if params.has("frame"):
		pending_changes.append_array(_capture_property_change(sprite, "frame", int(params.get("frame"))))
	if params.has("frame_progress"):
		pending_changes.append_array(_capture_property_change(sprite, "frame_progress", float(params.get("frame_progress"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_animated_sprite_2d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure AnimatedSprite2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure AnimatedSprite2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for AnimatedSprite2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(sprite, change.property, change.value)
		transaction.add_undo_property(sprite, change.property, change.previous)
		if change.property == "sprite_frames" and change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured AnimatedSprite2D", "_configure_animated_sprite_2d", {
			"node_path": _to_mcp_path(sprite),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "animation_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(sprite),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit AnimatedSprite2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_sprite_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Sprite2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Sprite2D):
		return _send_error(client_id, "Node at %s is not a Sprite2D" % node_path, command_id)

	var sprite: Sprite2D = node
	var pending_changes: Array = []

	if params.has("texture_path"):
		var texture_path: String = String(params.get("texture_path", "")).strip_edges()
		if texture_path.is_empty():
			pending_changes.append_array(_capture_property_change(sprite, "texture", null))
		else:
			if not texture_path.begins_with("res://"):
				return _send_error(client_id, "texture_path must use res://", command_id)
			var texture_resource = ResourceLoader.load(texture_path, "Texture2D", ResourceLoader.CACHE_MODE_REPLACE)
			if not texture_resource or not (texture_resource is Texture2D):
				return _send_error(client_id, "Failed to load Texture2D at %s" % texture_path, command_id)
			pending_changes.append_array(_capture_property_change(sprite, "texture", texture_resource))

	if params.has("centered"):
		pending_changes.append_array(_capture_property_change(sprite, "centered", bool(params.get("centered"))))
	if params.has("offset"):
		pending_changes.append_array(_capture_property_change(sprite, "offset", _parse_vector2_param(params.get("offset"))))
	if params.has("flip_h"):
		pending_changes.append_array(_capture_property_change(sprite, "flip_h", bool(params.get("flip_h"))))
	if params.has("flip_v"):
		pending_changes.append_array(_capture_property_change(sprite, "flip_v", bool(params.get("flip_v"))))
	if params.has("hframes"):
		pending_changes.append_array(_capture_property_change(sprite, "hframes", int(params.get("hframes"))))
	if params.has("vframes"):
		pending_changes.append_array(_capture_property_change(sprite, "vframes", int(params.get("vframes"))))
	if params.has("frame"):
		pending_changes.append_array(_capture_property_change(sprite, "frame", int(params.get("frame"))))
	if params.has("frame_coords"):
		var frame_coords_result := _parse_vector2i_with_default(params.get("frame_coords"))
		if not frame_coords_result.get("ok", false):
			return _send_error(client_id, "frame_coords must be Vector2i-compatible", command_id)
		pending_changes.append_array(_capture_property_change(sprite, "frame_coords", frame_coords_result.get("value")))
	if params.has("region_enabled"):
		pending_changes.append_array(_capture_property_change(sprite, "region_enabled", bool(params.get("region_enabled"))))
	if params.has("region_filter_clip_enabled"):
		pending_changes.append_array(
			_capture_property_change(sprite, "region_filter_clip_enabled", bool(params.get("region_filter_clip_enabled")))
		)
	if params.has("region_rect"):
		var rect_result := _parse_rect2_with_default(params.get("region_rect"))
		if not rect_result.get("ok", false):
			return _send_error(client_id, "region_rect must be Rect2-compatible", command_id)
		pending_changes.append_array(_capture_property_change(sprite, "region_rect", rect_result.get("value")))
	if params.has("modulate"):
		var modulate_value = _convert_property_value(sprite, "modulate", params.get("modulate"))
		pending_changes.append_array(_capture_property_change(sprite, "modulate", modulate_value))
	if params.has("self_modulate"):
		var self_modulate_value = _convert_property_value(sprite, "self_modulate", params.get("self_modulate"))
		pending_changes.append_array(_capture_property_change(sprite, "self_modulate", self_modulate_value))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_sprite_2d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Sprite2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Sprite2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Sprite2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(sprite, change.property, change.value)
		transaction.add_undo_property(sprite, change.property, change.previous)
		if change.property == "texture" and change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Sprite2D", "_configure_sprite_2d", {
			"node_path": _to_mcp_path(sprite),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "sprite_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(sprite),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Sprite2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_characterbody2d_controller(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "CharacterBody2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is CharacterBody2D):
		return _send_error(client_id, "Node at %s is not a CharacterBody2D" % node_path, command_id)

	var body: CharacterBody2D = node
	var pending_changes: Array = []

	if params.has("up_direction"):
		pending_changes.append_array(_capture_property_change(body, "up_direction", _parse_vector2_param(params.get("up_direction"))))
	if params.has("motion_mode"):
		pending_changes.append_array(_capture_property_change(body, "motion_mode", int(params.get("motion_mode"))))
	if params.has("floor_stop_on_slope"):
		pending_changes.append_array(_capture_property_change(body, "floor_stop_on_slope", bool(params.get("floor_stop_on_slope"))))
	if params.has("floor_constant_speed"):
		pending_changes.append_array(_capture_property_change(body, "floor_constant_speed", bool(params.get("floor_constant_speed"))))
	if params.has("floor_block_on_wall"):
		pending_changes.append_array(_capture_property_change(body, "floor_block_on_wall", bool(params.get("floor_block_on_wall"))))
	if params.has("floor_snap_length"):
		pending_changes.append_array(_capture_property_change(body, "floor_snap_length", float(params.get("floor_snap_length"))))
	if params.has("floor_max_angle"):
		pending_changes.append_array(_capture_property_change(body, "floor_max_angle", float(params.get("floor_max_angle"))))
	if params.has("wall_min_slide_angle"):
		pending_changes.append_array(_capture_property_change(body, "wall_min_slide_angle", float(params.get("wall_min_slide_angle"))))
	if params.has("max_slides"):
		pending_changes.append_array(_capture_property_change(body, "max_slides", int(params.get("max_slides"))))
	if params.has("safe_margin"):
		pending_changes.append_array(_capture_property_change(body, "safe_margin", float(params.get("safe_margin"))))
	if params.has("slide_on_ceiling"):
		pending_changes.append_array(_capture_property_change(body, "slide_on_ceiling", bool(params.get("slide_on_ceiling"))))
	if params.has("platform_on_leave"):
		pending_changes.append_array(_capture_property_change(body, "platform_on_leave", int(params.get("platform_on_leave"))))
	if params.has("platform_floor_layers"):
		pending_changes.append_array(_capture_property_change(body, "platform_floor_layers", int(params.get("platform_floor_layers"))))
	if params.has("platform_wall_layers"):
		pending_changes.append_array(_capture_property_change(body, "platform_wall_layers", int(params.get("platform_wall_layers"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_characterbody2d_controller",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure CharacterBody2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure CharacterBody2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for CharacterBody2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(body, change.property, change.value)
		transaction.add_undo_property(body, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured CharacterBody2D controller", "_configure_characterbody2d_controller", {
			"node_path": _to_mcp_path(body),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "characterbody2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(body),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit CharacterBody2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_area2d_sensor(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Area2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Area2D):
		return _send_error(client_id, "Node at %s is not an Area2D" % node_path, command_id)

	var area: Area2D = node
	var pending_changes: Array = []

	if params.has("monitoring"):
		pending_changes.append_array(_capture_property_change(area, "monitoring", bool(params.get("monitoring"))))
	if params.has("monitorable"):
		pending_changes.append_array(_capture_property_change(area, "monitorable", bool(params.get("monitorable"))))
	if params.has("collision_layer"):
		pending_changes.append_array(_capture_property_change(area, "collision_layer", int(params.get("collision_layer"))))
	if params.has("collision_mask"):
		pending_changes.append_array(_capture_property_change(area, "collision_mask", int(params.get("collision_mask"))))
	if params.has("priority"):
		pending_changes.append_array(_capture_property_change(area, "priority", float(params.get("priority"))))
	if params.has("gravity_space_override"):
		pending_changes.append_array(_capture_property_change(area, "gravity_space_override", int(params.get("gravity_space_override"))))
	if params.has("gravity_point"):
		pending_changes.append_array(_capture_property_change(area, "gravity_point", bool(params.get("gravity_point"))))
	if params.has("gravity_point_center"):
		pending_changes.append_array(_capture_property_change(area, "gravity_point_center", _parse_vector2_param(params.get("gravity_point_center"))))
	if params.has("gravity_point_unit_distance"):
		pending_changes.append_array(_capture_property_change(area, "gravity_point_unit_distance", float(params.get("gravity_point_unit_distance"))))
	if params.has("gravity_direction"):
		pending_changes.append_array(_capture_property_change(area, "gravity_direction", _parse_vector2_param(params.get("gravity_direction"))))
	if params.has("gravity"):
		pending_changes.append_array(_capture_property_change(area, "gravity", float(params.get("gravity"))))
	if params.has("linear_damp_space_override"):
		pending_changes.append_array(_capture_property_change(area, "linear_damp_space_override", int(params.get("linear_damp_space_override"))))
	if params.has("linear_damp"):
		pending_changes.append_array(_capture_property_change(area, "linear_damp", float(params.get("linear_damp"))))
	if params.has("angular_damp_space_override"):
		pending_changes.append_array(_capture_property_change(area, "angular_damp_space_override", int(params.get("angular_damp_space_override"))))
	if params.has("angular_damp"):
		pending_changes.append_array(_capture_property_change(area, "angular_damp", float(params.get("angular_damp"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_area2d_sensor",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Area2D Sensor", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Area2D Sensor", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Area2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(area, change.property, change.value)
		transaction.add_undo_property(area, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Area2D sensor", "_configure_area2d_sensor", {
			"node_path": _to_mcp_path(area),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "area2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(area),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Area2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _fill_tilemap_rect_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var requested_layer: int = int(params.get("layer", 0))
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not _is_supported_tilemap_node(node):
		return _send_error(client_id, "Node at %s must be TileMapLayer or TileMap" % node_path, command_id)

	var layer := requested_layer
	if node is TileMapLayer:
		layer = 0
	elif node is TileMap:
		var tilemap: TileMap = node
		var layer_count: int = tilemap.get_layers_count()
		if layer < 0 or layer >= layer_count:
			return _send_error(client_id, "TileMap layer index out of bounds: %d" % layer, command_id)

	var origin_result := _parse_vector2i_with_default(params.get("origin", null), Vector2i.ZERO)
	var size_result := _parse_vector2i_with_default(params.get("size", null), Vector2i.ZERO)
	var rect_param = params.get("rect", null)
	if rect_param != null:
		var rect_result := _parse_rect2_with_default(rect_param)
		if not rect_result.get("ok", false):
			return _send_error(client_id, "rect must be Rect2-compatible", command_id)
		var rect_value: Rect2 = rect_result.get("value")
		origin_result = {"ok": true, "value": Vector2i(int(round(rect_value.position.x)), int(round(rect_value.position.y)))}
		size_result = {"ok": true, "value": Vector2i(int(round(rect_value.size.x)), int(round(rect_value.size.y)))}

	if not origin_result.get("ok", false):
		return _send_error(client_id, "origin must be Vector2i-compatible", command_id)
	if not size_result.get("ok", false):
		return _send_error(client_id, "size must be Vector2i-compatible", command_id)

	var origin: Vector2i = origin_result.get("value")
	var size: Vector2i = size_result.get("value")
	if size.x <= 0 or size.y <= 0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)

	var clear: bool = params.get("clear", false)
	var source_id: int = -1
	var atlas_coords: Vector2i = Vector2i(-1, -1)
	var alternative_tile: int = 0
	if not clear:
		if not params.has("source_id"):
			return _send_error(client_id, "source_id is required unless clear=true", command_id)
		source_id = int(params.get("source_id", -1))
		var atlas_result := _parse_vector2i_with_default(params.get("atlas_coords", Vector2i(-1, -1)), Vector2i(-1, -1))
		if not atlas_result.get("ok", false):
			return _send_error(client_id, "atlas_coords must be Vector2i-compatible", command_id)
		atlas_coords = atlas_result.get("value")
		alternative_tile = int(params.get("alternative_tile", 0))

	var target_cell = _make_tilemap_cell_data(source_id, atlas_coords, alternative_tile)
	var pending_changes: Array = []
	for y in range(origin.y, origin.y + size.y):
		for x in range(origin.x, origin.x + size.x):
			var coords := Vector2i(x, y)
			var previous_cell := _get_tilemap_cell_data(node, layer, coords)
			if _tilemap_cell_data_equal(previous_cell, target_cell):
				continue
			pending_changes.append({
				"coords": coords,
				"previous_cell": previous_cell,
			})

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"rect": {"origin": _vector2i_to_dict(origin), "size": _vector2i_to_dict(size)},
			"change_count": 0,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "fill_tilemap_rect_2d",
		"node_path": node_path,
		"layer": layer,
		"origin": _vector2i_to_dict(origin),
		"size": _vector2i_to_dict(size),
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Fill TileMap Rect 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Fill TileMap Rect 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for TileMap fill", command_id)

	var preview_changes: Array = []
	for change in pending_changes:
		var coords: Vector2i = change["coords"]
		var previous_cell: Dictionary = change["previous_cell"]
		if clear:
			transaction.add_do_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_do_method(self, "_apply_tilemap_set_cell", [node, layer, coords, target_cell])

		if _tilemap_cell_is_empty(previous_cell):
			transaction.add_undo_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_undo_method(self, "_apply_tilemap_set_cell", [node, layer, coords, previous_cell])

		if preview_changes.size() < 64:
			preview_changes.append({
				"coords": _vector2i_to_dict(coords),
				"previous_cell": _serialize_tilemap_cell_data(previous_cell),
			})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Filled TileMap rect", "_fill_tilemap_rect_2d", {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"origin": _vector2i_to_dict(origin),
			"size": _vector2i_to_dict(size),
			"clear": clear,
			"change_count": pending_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "tilemap_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"rect": {"origin": _vector2i_to_dict(origin), "size": _vector2i_to_dict(size)},
		"clear": clear,
		"target_cell": _serialize_tilemap_cell_data(target_cell),
		"change_count": pending_changes.size(),
		"preview_changes": preview_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit TileMap fill", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _generate_tilemap_noise_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var requested_layer: int = int(params.get("layer", 0))
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	if not params.has("source_id"):
		return _send_error(client_id, "source_id is required", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not _is_supported_tilemap_node(node):
		return _send_error(client_id, "Node at %s must be TileMapLayer or TileMap" % node_path, command_id)

	var layer := requested_layer
	if node is TileMapLayer:
		layer = 0
	elif node is TileMap:
		var tilemap: TileMap = node
		var layer_count: int = tilemap.get_layers_count()
		if layer < 0 or layer >= layer_count:
			return _send_error(client_id, "TileMap layer index out of bounds: %d" % layer, command_id)

	var origin_result := _parse_vector2i_with_default(params.get("origin", null), Vector2i.ZERO)
	var size_result := _parse_vector2i_with_default(params.get("size", null), Vector2i.ZERO)
	var rect_param = params.get("rect", null)
	if rect_param != null:
		var rect_result := _parse_rect2_with_default(rect_param)
		if not rect_result.get("ok", false):
			return _send_error(client_id, "rect must be Rect2-compatible", command_id)
		var rect_value: Rect2 = rect_result.get("value")
		origin_result = {"ok": true, "value": Vector2i(int(round(rect_value.position.x)), int(round(rect_value.position.y)))}
		size_result = {"ok": true, "value": Vector2i(int(round(rect_value.size.x)), int(round(rect_value.size.y)))}

	if not origin_result.get("ok", false):
		return _send_error(client_id, "origin must be Vector2i-compatible", command_id)
	if not size_result.get("ok", false):
		return _send_error(client_id, "size must be Vector2i-compatible", command_id)

	var origin: Vector2i = origin_result.get("value")
	var size: Vector2i = size_result.get("value")
	if size.x <= 0 or size.y <= 0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)

	var source_id: int = int(params.get("source_id", -1))
	var atlas_result := _parse_vector2i_with_default(params.get("atlas_coords", Vector2i.ZERO), Vector2i.ZERO)
	if not atlas_result.get("ok", false):
		return _send_error(client_id, "atlas_coords must be Vector2i-compatible", command_id)
	var atlas_coords: Vector2i = atlas_result.get("value")
	var alternative_tile: int = int(params.get("alternative_tile", 0))
	var target_cell := _make_tilemap_cell_data(source_id, atlas_coords, alternative_tile)
	var empty_cell := _make_tilemap_cell_data(-1, Vector2i(-1, -1), -1)

	var threshold: float = clampf(float(params.get("threshold", 0.0)), -1.0, 1.0)
	var invert: bool = bool(params.get("invert", false))
	var clear_unselected: bool = bool(params.get("clear_unselected", false))
	var sample_offset: Vector2 = _parse_vector2_param(params.get("sample_offset", Vector2.ZERO))
	var noise_seed: int = int(params.get("noise_seed", int(Time.get_unix_time_from_system()) % 2147483647))
	var frequency: float = max(0.00001, float(params.get("frequency", 0.08)))
	var fractal_octaves: int = max(1, int(params.get("fractal_octaves", 1)))
	var fractal_lacunarity: float = max(0.0, float(params.get("fractal_lacunarity", 2.0)))
	var fractal_gain: float = max(0.0, float(params.get("fractal_gain", 0.5)))

	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = frequency
	noise.fractal_octaves = fractal_octaves
	noise.fractal_lacunarity = fractal_lacunarity
	noise.fractal_gain = fractal_gain
	if params.has("noise_type"):
		noise.noise_type = int(params.get("noise_type"))
	if params.has("fractal_type"):
		noise.fractal_type = int(params.get("fractal_type"))

	var pending_changes: Array = []
	var painted_count := 0
	var cleared_count := 0
	var selected_count := 0
	for y in range(origin.y, origin.y + size.y):
		for x in range(origin.x, origin.x + size.x):
			var coords := Vector2i(x, y)
			var noise_value := noise.get_noise_2d(float(x) + sample_offset.x, float(y) + sample_offset.y)
			var should_fill := noise_value >= threshold
			if invert:
				should_fill = not should_fill
			if should_fill:
				selected_count += 1

			if not should_fill and not clear_unselected:
				continue

			var desired_cell: Dictionary = target_cell if should_fill else empty_cell
			var previous_cell := _get_tilemap_cell_data(node, layer, coords)
			if _tilemap_cell_data_equal(previous_cell, desired_cell):
				continue

			pending_changes.append({
				"coords": coords,
				"noise_value": noise_value,
				"previous_cell": previous_cell,
				"next_cell": desired_cell,
			})

			if should_fill:
				painted_count += 1
			else:
				cleared_count += 1

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"rect": {"origin": _vector2i_to_dict(origin), "size": _vector2i_to_dict(size)},
			"selected_count": selected_count,
			"painted_count": 0,
			"cleared_count": 0,
			"change_count": 0,
			"noise_seed": noise_seed,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "generate_tilemap_noise_2d",
		"node_path": node_path,
		"layer": layer,
		"origin": _vector2i_to_dict(origin),
		"size": _vector2i_to_dict(size),
		"threshold": threshold,
		"invert": invert,
		"clear_unselected": clear_unselected,
		"noise_seed": noise_seed,
		"change_count": pending_changes.size(),
		"painted_count": painted_count,
		"cleared_count": cleared_count,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate TileMap Noise 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate TileMap Noise 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for TileMap noise generation", command_id)

	var preview_changes: Array = []
	for change in pending_changes:
		var coords: Vector2i = change["coords"]
		var previous_cell: Dictionary = change["previous_cell"]
		var next_cell: Dictionary = change["next_cell"]
		if _tilemap_cell_is_empty(next_cell):
			transaction.add_do_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_do_method(self, "_apply_tilemap_set_cell", [node, layer, coords, next_cell])

		if _tilemap_cell_is_empty(previous_cell):
			transaction.add_undo_method(self, "_apply_tilemap_erase_cell", [node, layer, coords])
		else:
			transaction.add_undo_method(self, "_apply_tilemap_set_cell", [node, layer, coords, previous_cell])

		if preview_changes.size() < 64:
			preview_changes.append({
				"coords": _vector2i_to_dict(coords),
				"noise_value": change["noise_value"],
				"previous_cell": _serialize_tilemap_cell_data(previous_cell),
				"next_cell": _serialize_tilemap_cell_data(next_cell),
			})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated TileMap noise 2D", "_generate_tilemap_noise_2d", {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"origin": _vector2i_to_dict(origin),
			"size": _vector2i_to_dict(size),
			"selected_count": selected_count,
			"painted_count": painted_count,
			"cleared_count": cleared_count,
			"change_count": pending_changes.size(),
			"noise_seed": noise_seed,
			"transaction_id": transaction.transaction_id,
			"system_section": "tilemap_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"rect": {"origin": _vector2i_to_dict(origin), "size": _vector2i_to_dict(size)},
		"selected_count": selected_count,
		"painted_count": painted_count,
		"cleared_count": cleared_count,
		"change_count": pending_changes.size(),
		"noise_seed": noise_seed,
		"threshold": threshold,
		"invert": invert,
		"clear_unselected": clear_unselected,
		"preview_changes": preview_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit TileMap noise generation", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _tilemap_terrain_autopaint_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = String(params.get("node_path", "")).strip_edges()
	var requested_layer: int = int(params.get("layer", 0))
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var preview_only: bool = bool(params.get("preview_only", false))
	var clear_unselected: bool = bool(params.get("clear_unselected", false))

	if node_path.is_empty():
		return _send_error(client_id, "node_path cannot be empty", command_id)
	if not params.has("terrain_set"):
		return _send_error(client_id, "terrain_set is required", command_id)
	if not params.has("terrain"):
		return _send_error(client_id, "terrain is required", command_id)

	var mode: String = String(params.get("mode", "connect")).strip_edges().to_lower()
	if mode != "connect" and mode != "path":
		return _send_error(client_id, "mode must be connect or path", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not _is_supported_tilemap_node(node):
		return _send_error(client_id, "Node at %s must be TileMapLayer or TileMap" % node_path, command_id)

	var layer := requested_layer
	if node is TileMapLayer:
		layer = 0
	elif node is TileMap:
		var tilemap: TileMap = node
		var layer_count: int = tilemap.get_layers_count()
		if layer < 0 or layer >= layer_count:
			return _send_error(client_id, "TileMap layer index out of bounds: %d" % layer, command_id)

	var terrain_set: int = int(params.get("terrain_set", 0))
	var terrain: int = int(params.get("terrain", 0))
	var ignore_empty_terrains: bool = bool(params.get("ignore_empty_terrains", true))
	var neighbor_margin: int = max(0, int(params.get("neighbor_margin", 1)))

	var selected_coords: Array = []
	var selected_lookup: Dictionary = {}
	var selection_origin := Vector2i.ZERO
	var selection_size := Vector2i.ZERO

	if params.has("cells"):
		var cells_value = params.get("cells")
		if typeof(cells_value) != TYPE_ARRAY:
			return _send_error(client_id, "cells must be an array of Vector2i-compatible entries", command_id)
		var cells_array: Array = cells_value
		for idx in range(cells_array.size()):
			var parse_result := _parse_vector2i_with_default(cells_array[idx])
			if not parse_result.get("ok", false):
				return _send_error(client_id, "cells[%d] is not Vector2i-compatible" % idx, command_id)
			var coords: Vector2i = parse_result.get("value", Vector2i.ZERO)
			var key := _mcp_grid_key_from_vec2i(coords)
			if selected_lookup.has(key):
				continue
			selected_lookup[key] = true
			selected_coords.append(coords)
	else:
		var origin_result := _parse_vector2i_with_default(params.get("origin", null), Vector2i.ZERO)
		var size_result := _parse_vector2i_with_default(params.get("size", null), Vector2i.ZERO)
		var rect_param = params.get("rect", null)
		if rect_param != null:
			var rect_result := _parse_rect2_with_default(rect_param)
			if not rect_result.get("ok", false):
				return _send_error(client_id, "rect must be Rect2-compatible", command_id)
			var rect_value: Rect2 = rect_result.get("value")
			origin_result = {"ok": true, "value": Vector2i(int(round(rect_value.position.x)), int(round(rect_value.position.y)))}
			size_result = {"ok": true, "value": Vector2i(int(round(rect_value.size.x)), int(round(rect_value.size.y)))}

		if not origin_result.get("ok", false):
			return _send_error(client_id, "origin must be Vector2i-compatible", command_id)
		if not size_result.get("ok", false):
			return _send_error(client_id, "size must be Vector2i-compatible", command_id)

		selection_origin = origin_result.get("value", Vector2i.ZERO)
		selection_size = size_result.get("value", Vector2i.ZERO)
		if selection_size.x <= 0 or selection_size.y <= 0:
			return _send_error(client_id, "size must be greater than zero when cells are not provided", command_id)

		var threshold: float = clampf(float(params.get("threshold", 0.0)), -1.0, 1.0)
		var invert: bool = bool(params.get("invert", false))
		var sample_offset: Vector2 = _parse_vector2_param(params.get("sample_offset", Vector2.ZERO))
		var use_noise: bool = bool(params.get("use_noise", true))
		var fill_probability: float = clampf(float(params.get("fill_probability", 1.0)), 0.0, 1.0)
		var rng := RandomNumberGenerator.new()
		if params.has("seed"):
			rng.seed = int(params.get("seed"))
		else:
			rng.randomize()

		var noise := FastNoiseLite.new()
		noise.seed = int(params.get("noise_seed", int(rng.seed) % 2147483647))
		noise.frequency = max(0.00001, float(params.get("frequency", 0.1)))
		noise.fractal_octaves = max(1, int(params.get("fractal_octaves", 1)))
		noise.fractal_lacunarity = max(0.0, float(params.get("fractal_lacunarity", 2.0)))
		noise.fractal_gain = max(0.0, float(params.get("fractal_gain", 0.5)))
		if params.has("noise_type"):
			noise.noise_type = int(params.get("noise_type"))
		if params.has("fractal_type"):
			noise.fractal_type = int(params.get("fractal_type"))

		for y in range(selection_origin.y, selection_origin.y + selection_size.y):
			for x in range(selection_origin.x, selection_origin.x + selection_size.x):
				var should_select := true
				if use_noise:
					var noise_value := noise.get_noise_2d(float(x) + sample_offset.x, float(y) + sample_offset.y)
					should_select = noise_value >= threshold
					if invert:
						should_select = not should_select
				elif fill_probability < 1.0:
					should_select = rng.randf() <= fill_probability

				if not should_select:
					continue
				var coords := Vector2i(x, y)
				var key := _mcp_grid_key_from_vec2i(coords)
				if selected_lookup.has(key):
					continue
				selected_lookup[key] = true
				selected_coords.append(coords)

	if selected_coords.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"mode": mode,
			"terrain_set": terrain_set,
			"terrain": terrain,
			"selected_count": 0,
			"status": "no_change",
		}, command_id)

	var supports_method := false
	if mode == "path":
		supports_method = node.has_method("set_cells_terrain_path")
	else:
		supports_method = node.has_method("set_cells_terrain_connect")
	if not supports_method:
		return _send_error(client_id, "Terrain autopaint is unavailable for this tilemap node", command_id)

	if preview_only:
		var preview_cells: Array = []
		var preview_limit: int = min(selected_coords.size(), 256)
		for idx in range(preview_limit):
			preview_cells.append(_vector2i_to_dict(selected_coords[idx]))
		return _send_success(client_id, {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"mode": mode,
			"terrain_set": terrain_set,
			"terrain": terrain,
			"selected_count": selected_coords.size(),
			"preview_cells": preview_cells,
			"preview_truncated": selected_coords.size() > preview_limit,
			"status": "preview",
		}, command_id)

	var first_selected: Vector2i = selected_coords[0]
	var min_x: int = first_selected.x
	var min_y: int = first_selected.y
	var max_x: int = first_selected.x
	var max_y: int = first_selected.y
	for coords_entry in selected_coords:
		var coords: Vector2i = coords_entry
		min_x = min(min_x, coords.x)
		min_y = min(min_y, coords.y)
		max_x = max(max_x, coords.x)
		max_y = max(max_y, coords.y)

	var snapshot: Array = []
	for y in range(min_y - neighbor_margin, max_y + neighbor_margin + 1):
		for x in range(min_x - neighbor_margin, max_x + neighbor_margin + 1):
			var sample_coords := Vector2i(x, y)
			snapshot.append({
				"coords": sample_coords,
				"cell_data": _get_tilemap_cell_data(node, layer, sample_coords),
			})

	var transaction_metadata := {
		"command": "tilemap_terrain_autopaint_2d",
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"mode": mode,
		"terrain_set": terrain_set,
		"terrain": terrain,
		"selected_count": selected_coords.size(),
		"snapshot_count": snapshot.size(),
		"clear_unselected": clear_unselected,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("TileMap Terrain Autopaint 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "TileMap Terrain Autopaint 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for terrain autopaint", command_id)

	transaction.add_do_method(
		self,
		"_apply_tilemap_terrain_autopaint_2d",
		[
			node,
			layer,
			selected_coords.duplicate(true),
			terrain_set,
			terrain,
			mode,
			ignore_empty_terrains,
			clear_unselected,
			selection_origin,
			selection_size,
		]
	)
	transaction.add_undo_method(self, "_restore_tilemap_cells_2d_snapshot", [node, layer, snapshot.duplicate(true)])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Auto-painted TileMap terrain", "_tilemap_terrain_autopaint_2d", {
			"node_path": _to_mcp_path(node),
			"layer": layer,
			"mode": mode,
			"terrain_set": terrain_set,
			"terrain": terrain,
			"selected_count": selected_coords.size(),
			"snapshot_count": snapshot.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "tilemap_2d",
			"line_num": 0,
		})
	)

	var preview_cells: Array = []
	var preview_limit: int = min(selected_coords.size(), 256)
	for idx in range(preview_limit):
		preview_cells.append(_vector2i_to_dict(selected_coords[idx]))

	var response := {
		"node_path": _to_mcp_path(node),
		"layer": layer,
		"mode": mode,
		"terrain_set": terrain_set,
		"terrain": terrain,
		"selected_count": selected_coords.size(),
		"snapshot_count": snapshot.size(),
		"preview_cells": preview_cells,
		"preview_truncated": selected_coords.size() > preview_limit,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit terrain autopaint", command_id)
		var changed_count := 0
		for snapshot_entry in snapshot:
			var coords: Vector2i = snapshot_entry.get("coords", Vector2i.ZERO)
			var previous_cell: Dictionary = snapshot_entry.get("cell_data", _make_tilemap_cell_data(-1, Vector2i(-1, -1), -1))
			var current_cell := _get_tilemap_cell_data(node, layer, coords)
			if not _tilemap_cell_data_equal(previous_cell, current_cell):
				changed_count += 1
		response["changed_count"] = changed_count
		response["status"] = "committed"
	else:
		response["changed_count"] = -1
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _apply_tilemap_terrain_autopaint_2d(
	node: Node,
	layer: int,
	cells: Array,
	terrain_set: int,
	terrain: int,
	mode: String,
	ignore_empty_terrains: bool,
	clear_unselected: bool,
	selection_origin: Vector2i,
	selection_size: Vector2i
) -> void:
	if node == null:
		return
	if cells.is_empty():
		return

	var coords_array: Array = []
	var selected_lookup: Dictionary = {}
	for entry in cells:
		if not (entry is Vector2i):
			continue
		var coords: Vector2i = entry
		coords_array.append(coords)
		selected_lookup[_mcp_grid_key_from_vec2i(coords)] = true

	if coords_array.is_empty():
		return

	if clear_unselected and selection_size.x > 0 and selection_size.y > 0:
		for y in range(selection_origin.y, selection_origin.y + selection_size.y):
			for x in range(selection_origin.x, selection_origin.x + selection_size.x):
				var coords := Vector2i(x, y)
				if selected_lookup.has(_mcp_grid_key_from_vec2i(coords)):
					continue
				_apply_tilemap_erase_cell(node, layer, coords)

	if node is TileMapLayer:
		if mode == "path" and node.has_method("set_cells_terrain_path"):
			node.call("set_cells_terrain_path", coords_array, terrain_set, terrain, ignore_empty_terrains)
		elif node.has_method("set_cells_terrain_connect"):
			node.call("set_cells_terrain_connect", coords_array, terrain_set, terrain, ignore_empty_terrains)
	elif node is TileMap:
		if mode == "path" and node.has_method("set_cells_terrain_path"):
			node.call("set_cells_terrain_path", layer, coords_array, terrain_set, terrain, ignore_empty_terrains)
		elif node.has_method("set_cells_terrain_connect"):
			node.call("set_cells_terrain_connect", layer, coords_array, terrain_set, terrain, ignore_empty_terrains)

	_refresh_tilemap_node(node)


func _restore_tilemap_cells_2d_snapshot(node: Node, layer: int, snapshot: Array) -> void:
	if node == null:
		return
	for entry in snapshot:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var snapshot_entry: Dictionary = entry
		var coords: Vector2i = snapshot_entry.get("coords", Vector2i.ZERO)
		var cell_data: Dictionary = snapshot_entry.get("cell_data", _make_tilemap_cell_data(-1, Vector2i(-1, -1), -1))
		if _tilemap_cell_is_empty(cell_data):
			_apply_tilemap_erase_cell(node, layer, coords)
		else:
			_apply_tilemap_set_cell(node, layer, coords, cell_data)


func _generate_heightmap_gridmap_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "GridMap node path cannot be empty", command_id)
	if not params.has("item_id"):
		return _send_error(client_id, "item_id is required", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is GridMap):
		return _send_error(client_id, "Node at %s is not a GridMap" % node_path, command_id)
	var gridmap: GridMap = node

	var origin_result := _parse_vector3i_with_default(params.get("origin", null), Vector3i.ZERO)
	if not origin_result.get("ok", false):
		return _send_error(client_id, "origin must be Vector3i-compatible", command_id)
	var size_result := _parse_vector2i_with_default(params.get("size", null), Vector2i.ZERO)
	if not size_result.get("ok", false):
		return _send_error(client_id, "size must be Vector2i-compatible", command_id)
	var origin: Vector3i = origin_result.get("value")
	var size: Vector2i = size_result.get("value")
	if size.x <= 0 or size.y <= 0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)

	var item_id: int = int(params.get("item_id", -1))
	if item_id < 0:
		return _send_error(client_id, "item_id must be >= 0", command_id)
	var orientation: int = int(params.get("orientation", 0))

	var min_height: int = int(params.get("min_height", 0))
	var max_height: int = int(params.get("max_height", 4))
	if max_height < min_height:
		var swapped := min_height
		min_height = max_height
		max_height = swapped
	var local_min_y: int = origin.y + min_height
	var local_max_y: int = origin.y + max_height

	var surface_only: bool = bool(params.get("surface_only", false))
	var clear_unselected: bool = bool(params.get("clear_unselected", true))
	var sample_offset: Vector2 = _parse_vector2_param(params.get("sample_offset", Vector2.ZERO))
	var noise_seed: int = int(params.get("noise_seed", int(Time.get_unix_time_from_system()) % 2147483647))
	var frequency: float = max(0.00001, float(params.get("frequency", 0.08)))
	var fractal_octaves: int = max(1, int(params.get("fractal_octaves", 1)))
	var fractal_lacunarity: float = max(0.0, float(params.get("fractal_lacunarity", 2.0)))
	var fractal_gain: float = max(0.0, float(params.get("fractal_gain", 0.5)))

	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = frequency
	noise.fractal_octaves = fractal_octaves
	noise.fractal_lacunarity = fractal_lacunarity
	noise.fractal_gain = fractal_gain
	if params.has("noise_type"):
		noise.noise_type = int(params.get("noise_type"))
	if params.has("fractal_type"):
		noise.fractal_type = int(params.get("fractal_type"))

	var pending_changes: Array = []
	var placed_count := 0
	var cleared_count := 0
	var min_generated_height := local_max_y
	var max_generated_height := local_min_y

	for z_offset in range(size.y):
		for x_offset in range(size.x):
			var x_coord: int = origin.x + x_offset
			var z_coord: int = origin.z + z_offset
			var noise_value := noise.get_noise_2d(float(x_coord) + sample_offset.x, float(z_coord) + sample_offset.y)
			var normalized := clampf((noise_value + 1.0) * 0.5, 0.0, 1.0)
			var top_y := int(round(lerpf(float(local_min_y), float(local_max_y), normalized)))
			min_generated_height = min(min_generated_height, top_y)
			max_generated_height = max(max_generated_height, top_y)

			for y_coord in range(local_min_y, local_max_y + 1):
				var should_fill := y_coord == top_y if surface_only else y_coord <= top_y
				var coords := Vector3i(x_coord, y_coord, z_coord)
				var previous_item: int = gridmap.get_cell_item(coords)
				var previous_orientation: int = 0
				if previous_item >= 0:
					previous_orientation = gridmap.get_cell_item_orientation(coords)

				if should_fill:
					if previous_item == item_id and previous_orientation == orientation:
						continue
					pending_changes.append({
						"coords": coords,
						"previous_item": previous_item,
						"previous_orientation": previous_orientation,
						"next_item": item_id,
						"next_orientation": orientation,
					})
					placed_count += 1
				elif clear_unselected and previous_item >= 0:
					pending_changes.append({
						"coords": coords,
						"previous_item": previous_item,
						"previous_orientation": previous_orientation,
						"next_item": -1,
						"next_orientation": 0,
					})
					cleared_count += 1

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(gridmap),
			"origin": _vector3i_to_dict(origin),
			"size": _vector2i_to_dict(size),
			"height_range": {"min": min_generated_height, "max": max_generated_height},
			"placed_count": 0,
			"cleared_count": 0,
			"change_count": 0,
			"noise_seed": noise_seed,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "generate_heightmap_gridmap_3d",
		"node_path": node_path,
		"origin": _vector3i_to_dict(origin),
		"size": _vector2i_to_dict(size),
		"item_id": item_id,
		"orientation": orientation,
		"surface_only": surface_only,
		"clear_unselected": clear_unselected,
		"noise_seed": noise_seed,
		"change_count": pending_changes.size(),
		"placed_count": placed_count,
		"cleared_count": cleared_count,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Heightmap GridMap 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Heightmap GridMap 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for GridMap heightmap generation", command_id)

	var preview_changes: Array = []
	for change in pending_changes:
		var coords: Vector3i = change["coords"]
		var previous_item: int = change["previous_item"]
		var previous_orientation: int = change["previous_orientation"]
		var next_item: int = change["next_item"]
		var next_orientation: int = change["next_orientation"]

		if next_item < 0:
			transaction.add_do_method(self, "_apply_gridmap_clear_cell", [gridmap, coords])
		else:
			transaction.add_do_method(self, "_apply_gridmap_set_cell_item", [gridmap, coords, next_item, next_orientation])

		if previous_item < 0:
			transaction.add_undo_method(self, "_apply_gridmap_clear_cell", [gridmap, coords])
		else:
			transaction.add_undo_method(self, "_apply_gridmap_set_cell_item", [gridmap, coords, previous_item, previous_orientation])

		if preview_changes.size() < 64:
			preview_changes.append({
				"coords": _vector3i_to_dict(coords),
				"previous_item": previous_item,
				"previous_orientation": previous_orientation,
				"next_item": next_item,
				"next_orientation": next_orientation,
			})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated GridMap heightmap 3D", "_generate_heightmap_gridmap_3d", {
			"node_path": _to_mcp_path(gridmap),
			"origin": _vector3i_to_dict(origin),
			"size": _vector2i_to_dict(size),
			"height_range": {"min": min_generated_height, "max": max_generated_height},
			"placed_count": placed_count,
			"cleared_count": cleared_count,
			"change_count": pending_changes.size(),
			"noise_seed": noise_seed,
			"transaction_id": transaction.transaction_id,
			"system_section": "gridmap_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(gridmap),
		"origin": _vector3i_to_dict(origin),
		"size": _vector2i_to_dict(size),
		"item_id": item_id,
		"orientation": orientation,
		"surface_only": surface_only,
		"clear_unselected": clear_unselected,
		"height_range": {"min": min_generated_height, "max": max_generated_height},
		"placed_count": placed_count,
		"cleared_count": cleared_count,
		"change_count": pending_changes.size(),
		"noise_seed": noise_seed,
		"preview_changes": preview_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit GridMap heightmap generation", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _scatter_scene_instances_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var scene_path: String = String(params.get("scene_path", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")

	if scene_path.is_empty():
		return _send_error(client_id, "scene_path cannot be empty", command_id)
	if not scene_path.begins_with("res://"):
		return _send_error(client_id, "scene_path must be within the project (res://)", command_id)
	if not params.has("rect"):
		return _send_error(client_id, "rect is required", command_id)

	var count: int = max(1, int(params.get("count", 1)))
	var min_distance: float = max(0.0, float(params.get("min_distance", 0.0)))
	var max_attempts: int = max(count, int(params.get("max_attempts", count * 24)))
	var require_full_count: bool = bool(params.get("require_full_count", false))
	var name_prefix: String = String(params.get("name_prefix", "Scatter2D")).strip_edges()
	if name_prefix.is_empty():
		name_prefix = "Scatter2D"

	var random_rotation: bool = bool(params.get("random_rotation", false))
	var rotation_range: Vector2 = _parse_vector2_param(params.get("rotation_range_degrees", Vector2(-180.0, 180.0)))
	var rotation_min: float = min(rotation_range.x, rotation_range.y)
	var rotation_max: float = max(rotation_range.x, rotation_range.y)
	var random_scale: bool = bool(params.get("random_scale", false))
	var scale_range: Vector2 = _parse_vector2_param(params.get("scale_range", Vector2.ONE))
	var scale_min: float = max(0.001, min(scale_range.x, scale_range.y))
	var scale_max: float = max(scale_min, max(scale_range.x, scale_range.y))

	var rect_result := _parse_rect2_with_default(params.get("rect"))
	if not rect_result.get("ok", false):
		return _send_error(client_id, "rect must be Rect2-compatible", command_id)
	var scatter_rect: Rect2 = rect_result.get("value")
	if scatter_rect.size.x <= 0.0 or scatter_rect.size.y <= 0.0:
		return _send_error(client_id, "rect size must be greater than zero on both axes", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var packed_scene = ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
	if not packed_scene or not (packed_scene is PackedScene):
		return _send_error(client_id, "Failed to load PackedScene at %s" % scene_path, command_id)

	var rng := RandomNumberGenerator.new()
	var scatter_seed: int
	if params.has("seed"):
		scatter_seed = int(params.get("seed"))
		rng.seed = scatter_seed
	else:
		rng.randomize()
		scatter_seed = int(rng.seed)

	var accepted_points: Array = []
	var attempts := 0
	while accepted_points.size() < count and attempts < max_attempts:
		attempts += 1
		var sample_point := Vector2(
			rng.randf_range(scatter_rect.position.x, scatter_rect.position.x + scatter_rect.size.x),
			rng.randf_range(scatter_rect.position.y, scatter_rect.position.y + scatter_rect.size.y)
		)
		var too_close := false
		if min_distance > 0.0:
			for existing in accepted_points:
				var existing_point: Vector2 = existing
				if existing_point.distance_to(sample_point) < min_distance:
					too_close = true
					break
		if too_close:
			continue
		accepted_points.append(sample_point)

	if accepted_points.is_empty():
		return _send_error(client_id, "Failed to find any valid scatter positions in the requested rect", command_id)
	if require_full_count and accepted_points.size() < count:
		return _send_error(client_id, "Unable to place requested count (%d/%d) with current constraints" % [accepted_points.size(), count], command_id)

	var attach_plans: Array = []
	var created_nodes: Array = []
	for idx in range(accepted_points.size()):
		var point: Vector2 = accepted_points[idx]
		var instance = (packed_scene as PackedScene).instantiate()
		if not instance or not (instance is Node2D):
			return _send_error(client_id, "Scene at %s must instantiate to Node2D for 2D scattering" % scene_path, command_id)
		var node_2d: Node2D = instance
		node_2d.name = _resolve_unique_child_name(parent, "%s%02d" % [name_prefix, idx + 1])
		node_2d.position = point
		if random_rotation:
			node_2d.rotation_degrees = rng.randf_range(rotation_min, rotation_max)
		if random_scale:
			var scale_value := rng.randf_range(scale_min, scale_max)
			node_2d.scale = Vector2(scale_value, scale_value)
		attach_plans.append({"parent": parent, "node": node_2d})
		created_nodes.append(node_2d)

	var transaction_metadata := {
		"command": "scatter_scene_instances_2d",
		"parent_path": _to_mcp_path(parent),
		"scene_path": scene_path,
		"requested_count": count,
		"created_count": created_nodes.size(),
		"attempts": attempts,
		"max_attempts": max_attempts,
		"min_distance": min_distance,
		"seed": scatter_seed,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Scatter Scene Instances 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Scatter Scene Instances 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D scatter generation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_paths: Array = []
	var placements: Array = []
	for idx in range(created_nodes.size()):
		var created_node: Node2D = created_nodes[idx]
		predicted_paths.append(_join_mcp_path(parent_mcp_path, created_node.name))
		if placements.size() < 128:
			placements.append({
				"path": _join_mcp_path(parent_mcp_path, created_node.name),
				"position": _vector2_to_dict(accepted_points[idx]),
			})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Scattered scene instances 2D", "_scatter_scene_instances_2d", {
			"parent_path": _to_mcp_path(parent),
			"scene_path": scene_path,
			"requested_count": count,
			"created_count": created_nodes.size(),
			"attempts": attempts,
			"max_attempts": max_attempts,
			"seed": scatter_seed,
			"transaction_id": transaction.transaction_id,
			"system_section": "procedural_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"scene_path": scene_path,
		"requested_count": count,
		"created_count": created_nodes.size(),
		"attempts": attempts,
		"max_attempts": max_attempts,
		"min_distance": min_distance,
		"seed": scatter_seed,
		"exhausted": accepted_points.size() < count,
		"created_nodes": predicted_paths,
		"placements": placements,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D scatter generation", command_id)
		var committed_paths: Array = []
		for created in created_nodes:
			var created_node: Node = created
			committed_paths.append(_to_mcp_path(created_node))
		response["created_nodes"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _scatter_scene_instances_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var scene_path: String = String(params.get("scene_path", "")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")

	if scene_path.is_empty():
		return _send_error(client_id, "scene_path cannot be empty", command_id)
	if not scene_path.begins_with("res://"):
		return _send_error(client_id, "scene_path must be within the project (res://)", command_id)
	if not params.has("size"):
		return _send_error(client_id, "size is required", command_id)

	var count: int = max(1, int(params.get("count", 1)))
	var min_distance: float = max(0.0, float(params.get("min_distance", 0.0)))
	var max_attempts: int = max(count, int(params.get("max_attempts", count * 24)))
	var require_full_count: bool = bool(params.get("require_full_count", false))
	var name_prefix: String = String(params.get("name_prefix", "Scatter3D")).strip_edges()
	if name_prefix.is_empty():
		name_prefix = "Scatter3D"

	var origin: Vector3 = _parse_vector3_param(params.get("origin", Vector3.ZERO))
	var size: Vector3 = _parse_vector3_param(params.get("size", Vector3.ZERO))
	if size.x <= 0.0 or size.y <= 0.0 or size.z <= 0.0:
		return _send_error(client_id, "size must be greater than zero on all axes", command_id)

	var random_yaw: bool = bool(params.get("random_yaw", false))
	var yaw_range: Vector2 = _parse_vector2_param(params.get("yaw_range_degrees", Vector2(-180.0, 180.0)))
	var yaw_min: float = min(yaw_range.x, yaw_range.y)
	var yaw_max: float = max(yaw_range.x, yaw_range.y)
	var random_scale: bool = bool(params.get("random_scale", false))
	var scale_range: Vector2 = _parse_vector2_param(params.get("scale_range", Vector2.ONE))
	var scale_min: float = max(0.001, min(scale_range.x, scale_range.y))
	var scale_max: float = max(scale_min, max(scale_range.x, scale_range.y))

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var packed_scene = ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE)
	if not packed_scene or not (packed_scene is PackedScene):
		return _send_error(client_id, "Failed to load PackedScene at %s" % scene_path, command_id)

	var rng := RandomNumberGenerator.new()
	var scatter_seed: int
	if params.has("seed"):
		scatter_seed = int(params.get("seed"))
		rng.seed = scatter_seed
	else:
		rng.randomize()
		scatter_seed = int(rng.seed)

	var accepted_points: Array = []
	var attempts := 0
	while accepted_points.size() < count and attempts < max_attempts:
		attempts += 1
		var sample_point := Vector3(
			rng.randf_range(origin.x, origin.x + size.x),
			rng.randf_range(origin.y, origin.y + size.y),
			rng.randf_range(origin.z, origin.z + size.z)
		)
		var too_close := false
		if min_distance > 0.0:
			for existing in accepted_points:
				var existing_point: Vector3 = existing
				if existing_point.distance_to(sample_point) < min_distance:
					too_close = true
					break
		if too_close:
			continue
		accepted_points.append(sample_point)

	if accepted_points.is_empty():
		return _send_error(client_id, "Failed to find any valid scatter positions in the requested volume", command_id)
	if require_full_count and accepted_points.size() < count:
		return _send_error(client_id, "Unable to place requested count (%d/%d) with current constraints" % [accepted_points.size(), count], command_id)

	var attach_plans: Array = []
	var created_nodes: Array = []
	for idx in range(accepted_points.size()):
		var point: Vector3 = accepted_points[idx]
		var instance = (packed_scene as PackedScene).instantiate()
		if not instance or not (instance is Node3D):
			return _send_error(client_id, "Scene at %s must instantiate to Node3D for 3D scattering" % scene_path, command_id)
		var node_3d: Node3D = instance
		node_3d.name = _resolve_unique_child_name(parent, "%s%02d" % [name_prefix, idx + 1])
		node_3d.position = point
		if random_yaw:
			node_3d.rotation_degrees.y = rng.randf_range(yaw_min, yaw_max)
		if random_scale:
			var scale_value := rng.randf_range(scale_min, scale_max)
			node_3d.scale = Vector3(scale_value, scale_value, scale_value)
		attach_plans.append({"parent": parent, "node": node_3d})
		created_nodes.append(node_3d)

	var transaction_metadata := {
		"command": "scatter_scene_instances_3d",
		"parent_path": _to_mcp_path(parent),
		"scene_path": scene_path,
		"requested_count": count,
		"created_count": created_nodes.size(),
		"attempts": attempts,
		"max_attempts": max_attempts,
		"min_distance": min_distance,
		"seed": scatter_seed,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Scatter Scene Instances 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Scatter Scene Instances 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 3D scatter generation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_paths: Array = []
	var placements: Array = []
	for idx in range(created_nodes.size()):
		var created_node: Node3D = created_nodes[idx]
		predicted_paths.append(_join_mcp_path(parent_mcp_path, created_node.name))
		if placements.size() < 128:
			placements.append({
				"path": _join_mcp_path(parent_mcp_path, created_node.name),
				"position": _vector3_to_dict(accepted_points[idx]),
			})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Scattered scene instances 3D", "_scatter_scene_instances_3d", {
			"parent_path": _to_mcp_path(parent),
			"scene_path": scene_path,
			"requested_count": count,
			"created_count": created_nodes.size(),
			"attempts": attempts,
			"max_attempts": max_attempts,
			"seed": scatter_seed,
			"transaction_id": transaction.transaction_id,
			"system_section": "procedural_3d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"scene_path": scene_path,
		"origin": _vector3_to_dict(origin),
		"size": _vector3_to_dict(size),
		"requested_count": count,
		"created_count": created_nodes.size(),
		"attempts": attempts,
		"max_attempts": max_attempts,
		"min_distance": min_distance,
		"seed": scatter_seed,
		"exhausted": accepted_points.size() < count,
		"created_nodes": predicted_paths,
		"placements": placements,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 3D scatter generation", command_id)
		var committed_paths: Array = []
		for created in created_nodes:
			var created_node: Node = created
			committed_paths.append(_to_mcp_path(created_node))
		response["created_nodes"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_characterbody3d_controller(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "CharacterBody3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is CharacterBody3D):
		return _send_error(client_id, "Node at %s is not a CharacterBody3D" % node_path, command_id)

	var body: CharacterBody3D = node
	var pending_changes: Array = []

	if params.has("up_direction"):
		pending_changes.append_array(_capture_property_change(body, "up_direction", _parse_vector3_param(params.get("up_direction"))))
	if params.has("motion_mode"):
		pending_changes.append_array(_capture_property_change(body, "motion_mode", int(params.get("motion_mode"))))
	if params.has("floor_stop_on_slope"):
		pending_changes.append_array(_capture_property_change(body, "floor_stop_on_slope", bool(params.get("floor_stop_on_slope"))))
	if params.has("floor_constant_speed"):
		pending_changes.append_array(_capture_property_change(body, "floor_constant_speed", bool(params.get("floor_constant_speed"))))
	if params.has("floor_block_on_wall"):
		pending_changes.append_array(_capture_property_change(body, "floor_block_on_wall", bool(params.get("floor_block_on_wall"))))
	if params.has("floor_snap_length"):
		pending_changes.append_array(_capture_property_change(body, "floor_snap_length", float(params.get("floor_snap_length"))))
	if params.has("floor_max_angle"):
		pending_changes.append_array(_capture_property_change(body, "floor_max_angle", float(params.get("floor_max_angle"))))
	if params.has("wall_min_slide_angle"):
		pending_changes.append_array(_capture_property_change(body, "wall_min_slide_angle", float(params.get("wall_min_slide_angle"))))
	if params.has("max_slides"):
		pending_changes.append_array(_capture_property_change(body, "max_slides", int(params.get("max_slides"))))
	if params.has("safe_margin"):
		pending_changes.append_array(_capture_property_change(body, "safe_margin", float(params.get("safe_margin"))))
	if params.has("slide_on_ceiling"):
		pending_changes.append_array(_capture_property_change(body, "slide_on_ceiling", bool(params.get("slide_on_ceiling"))))
	if params.has("platform_on_leave"):
		pending_changes.append_array(_capture_property_change(body, "platform_on_leave", int(params.get("platform_on_leave"))))
	if params.has("platform_floor_layers"):
		pending_changes.append_array(_capture_property_change(body, "platform_floor_layers", int(params.get("platform_floor_layers"))))
	if params.has("platform_wall_layers"):
		pending_changes.append_array(_capture_property_change(body, "platform_wall_layers", int(params.get("platform_wall_layers"))))
	if params.has("velocity"):
		pending_changes.append_array(_capture_property_change(body, "velocity", _parse_vector3_param(params.get("velocity"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_characterbody3d_controller",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure CharacterBody3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure CharacterBody3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for CharacterBody3D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(body, change.property, change.value)
		transaction.add_undo_property(body, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured CharacterBody3D controller", "_configure_characterbody3d_controller", {
			"node_path": _to_mcp_path(body),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "characterbody3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(body),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit CharacterBody3D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_camera3d_rig(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Camera3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is Camera3D):
		return _send_error(client_id, "Node at %s is not a Camera3D" % node_path, command_id)

	var camera: Camera3D = node
	var pending_changes: Array = []

	if params.has("position"):
		pending_changes.append_array(_capture_property_change(camera, "position", _parse_vector3_param(params.get("position"))))
	if params.has("rotation_degrees"):
		pending_changes.append_array(
			_capture_property_change(camera, "rotation_degrees", _parse_vector3_param(params.get("rotation_degrees")))
		)
	if params.has("global_position"):
		pending_changes.append_array(_capture_property_change(camera, "global_position", _parse_vector3_param(params.get("global_position"))))
	if params.has("global_rotation_degrees"):
		pending_changes.append_array(
			_capture_property_change(camera, "global_rotation_degrees", _parse_vector3_param(params.get("global_rotation_degrees")))
		)
	if params.has("current"):
		pending_changes.append_array(_capture_property_change(camera, "current", bool(params.get("current"))))
	if params.has("projection"):
		pending_changes.append_array(_capture_property_change(camera, "projection", int(params.get("projection"))))
	if params.has("fov"):
		pending_changes.append_array(_capture_property_change(camera, "fov", float(params.get("fov"))))
	if params.has("size"):
		pending_changes.append_array(_capture_property_change(camera, "size", float(params.get("size"))))
	if params.has("near"):
		pending_changes.append_array(_capture_property_change(camera, "near", float(params.get("near"))))
	if params.has("far"):
		pending_changes.append_array(_capture_property_change(camera, "far", float(params.get("far"))))
	if params.has("keep_aspect"):
		pending_changes.append_array(_capture_property_change(camera, "keep_aspect", int(params.get("keep_aspect"))))
	if params.has("h_offset"):
		pending_changes.append_array(_capture_property_change(camera, "h_offset", float(params.get("h_offset"))))
	if params.has("v_offset"):
		pending_changes.append_array(_capture_property_change(camera, "v_offset", float(params.get("v_offset"))))
	if params.has("cull_mask"):
		pending_changes.append_array(_capture_property_change(camera, "cull_mask", int(params.get("cull_mask"))))
	if params.has("doppler_tracking"):
		pending_changes.append_array(_capture_property_change(camera, "doppler_tracking", int(params.get("doppler_tracking"))))
	if params.has("environment_path"):
		var environment_path: String = String(params.get("environment_path", "")).strip_edges()
		var environment_resource = null
		if not environment_path.is_empty():
			if not environment_path.begins_with("res://"):
				return _send_error(client_id, "environment_path must be within the project (res://)", command_id)
			environment_resource = ResourceLoader.load(environment_path, "Environment", ResourceLoader.CACHE_MODE_REPLACE)
			if not environment_resource or not (environment_resource is Environment):
				return _send_error(client_id, "Failed to load Environment at %s" % environment_path, command_id)
		pending_changes.append_array(_capture_property_change(camera, "environment", environment_resource))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_camera3d_rig",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Camera3D Rig", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Camera3D Rig", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Camera3D rig configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(camera, change.property, change.value)
		transaction.add_undo_property(camera, change.property, change.previous)
		if change.property == "environment" and change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Camera3D rig", "_configure_camera3d_rig", {
			"node_path": _to_mcp_path(camera),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "camera3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(camera),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Camera3D rig configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_springarm3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "SpringArm3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is SpringArm3D):
		return _send_error(client_id, "Node at %s is not a SpringArm3D" % node_path, command_id)

	var spring_arm: SpringArm3D = node
	var pending_changes: Array = []

	if params.has("spring_length"):
		pending_changes.append_array(_capture_property_change(spring_arm, "spring_length", float(params.get("spring_length"))))
	if params.has("margin"):
		pending_changes.append_array(_capture_property_change(spring_arm, "margin", float(params.get("margin"))))
	if params.has("collision_mask"):
		pending_changes.append_array(_capture_property_change(spring_arm, "collision_mask", int(params.get("collision_mask"))))
	if params.has("shape_path"):
		var shape_path: String = String(params.get("shape_path", "")).strip_edges()
		var shape_resource = null
		if not shape_path.is_empty():
			if not shape_path.begins_with("res://"):
				return _send_error(client_id, "shape_path must be within the project (res://)", command_id)
			shape_resource = ResourceLoader.load(shape_path, "Shape3D", ResourceLoader.CACHE_MODE_REPLACE)
			if not shape_resource or not (shape_resource is Shape3D):
				return _send_error(client_id, "Failed to load Shape3D at %s" % shape_path, command_id)
		pending_changes.append_array(_capture_property_change(spring_arm, "shape", shape_resource))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_springarm3d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure SpringArm3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure SpringArm3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for SpringArm3D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(spring_arm, change.property, change.value)
		transaction.add_undo_property(spring_arm, change.property, change.previous)
		if change.property == "shape" and change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured SpringArm3D", "_configure_springarm3d", {
			"node_path": _to_mcp_path(spring_arm),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "springarm3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(spring_arm),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit SpringArm3D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_navigation_agent_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "NavigationAgent2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is NavigationAgent2D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent2D" % node_path, command_id)

	var agent: NavigationAgent2D = node
	var pending_changes: Array = []

	if params.has("target_position"):
		pending_changes.append_array(_capture_property_change(agent, "target_position", _parse_vector2_param(params.get("target_position"))))
	if params.has("navigation_layers"):
		pending_changes.append_array(_capture_property_change(agent, "navigation_layers", int(params.get("navigation_layers"))))
	if params.has("pathfinding_algorithm"):
		pending_changes.append_array(_capture_property_change(agent, "pathfinding_algorithm", int(params.get("pathfinding_algorithm"))))
	if params.has("path_postprocessing"):
		pending_changes.append_array(_capture_property_change(agent, "path_postprocessing", int(params.get("path_postprocessing"))))
	if params.has("path_metadata_flags"):
		pending_changes.append_array(_capture_property_change(agent, "path_metadata_flags", int(params.get("path_metadata_flags"))))
	if params.has("path_desired_distance"):
		pending_changes.append_array(_capture_property_change(agent, "path_desired_distance", float(params.get("path_desired_distance"))))
	if params.has("target_desired_distance"):
		pending_changes.append_array(_capture_property_change(agent, "target_desired_distance", float(params.get("target_desired_distance"))))
	if params.has("path_max_distance"):
		pending_changes.append_array(_capture_property_change(agent, "path_max_distance", float(params.get("path_max_distance"))))
	if params.has("radius"):
		pending_changes.append_array(_capture_property_change(agent, "radius", float(params.get("radius"))))
	if params.has("max_speed"):
		pending_changes.append_array(_capture_property_change(agent, "max_speed", float(params.get("max_speed"))))
	if params.has("avoidance_enabled"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_enabled", bool(params.get("avoidance_enabled"))))
	if params.has("neighbor_distance"):
		pending_changes.append_array(_capture_property_change(agent, "neighbor_distance", float(params.get("neighbor_distance"))))
	if params.has("max_neighbors"):
		pending_changes.append_array(_capture_property_change(agent, "max_neighbors", int(params.get("max_neighbors"))))
	if params.has("time_horizon"):
		pending_changes.append_array(_capture_property_change(agent, "time_horizon", float(params.get("time_horizon"))))
	if params.has("time_horizon_agents"):
		pending_changes.append_array(_capture_property_change(agent, "time_horizon_agents", float(params.get("time_horizon_agents"))))
	if params.has("time_horizon_obstacles"):
		pending_changes.append_array(
			_capture_property_change(agent, "time_horizon_obstacles", float(params.get("time_horizon_obstacles")))
		)
	if params.has("avoidance_layers"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_layers", int(params.get("avoidance_layers"))))
	if params.has("avoidance_mask"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_mask", int(params.get("avoidance_mask"))))
	if params.has("avoidance_priority"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_priority", float(params.get("avoidance_priority"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_navigation_agent_2d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure NavigationAgent2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure NavigationAgent2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for NavigationAgent2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(agent, change.property, change.value)
		transaction.add_undo_property(agent, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured NavigationAgent2D", "_configure_navigation_agent_2d", {
			"node_path": _to_mcp_path(agent),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(agent),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit NavigationAgent2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_navigation_agent_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "NavigationAgent3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is NavigationAgent3D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent3D" % node_path, command_id)

	var agent: NavigationAgent3D = node
	var pending_changes: Array = []

	if params.has("target_position"):
		pending_changes.append_array(_capture_property_change(agent, "target_position", _parse_vector3_param(params.get("target_position"))))
	if params.has("navigation_layers"):
		pending_changes.append_array(_capture_property_change(agent, "navigation_layers", int(params.get("navigation_layers"))))
	if params.has("pathfinding_algorithm"):
		pending_changes.append_array(_capture_property_change(agent, "pathfinding_algorithm", int(params.get("pathfinding_algorithm"))))
	if params.has("path_postprocessing"):
		pending_changes.append_array(_capture_property_change(agent, "path_postprocessing", int(params.get("path_postprocessing"))))
	if params.has("path_metadata_flags"):
		pending_changes.append_array(_capture_property_change(agent, "path_metadata_flags", int(params.get("path_metadata_flags"))))
	if params.has("path_desired_distance"):
		pending_changes.append_array(_capture_property_change(agent, "path_desired_distance", float(params.get("path_desired_distance"))))
	if params.has("target_desired_distance"):
		pending_changes.append_array(_capture_property_change(agent, "target_desired_distance", float(params.get("target_desired_distance"))))
	if params.has("path_max_distance"):
		pending_changes.append_array(_capture_property_change(agent, "path_max_distance", float(params.get("path_max_distance"))))
	if params.has("radius"):
		pending_changes.append_array(_capture_property_change(agent, "radius", float(params.get("radius"))))
	if params.has("height"):
		pending_changes.append_array(_capture_property_change(agent, "height", float(params.get("height"))))
	if params.has("max_speed"):
		pending_changes.append_array(_capture_property_change(agent, "max_speed", float(params.get("max_speed"))))
	if params.has("avoidance_enabled"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_enabled", bool(params.get("avoidance_enabled"))))
	if params.has("neighbor_distance"):
		pending_changes.append_array(_capture_property_change(agent, "neighbor_distance", float(params.get("neighbor_distance"))))
	if params.has("max_neighbors"):
		pending_changes.append_array(_capture_property_change(agent, "max_neighbors", int(params.get("max_neighbors"))))
	if params.has("time_horizon"):
		pending_changes.append_array(_capture_property_change(agent, "time_horizon", float(params.get("time_horizon"))))
	if params.has("time_horizon_agents"):
		pending_changes.append_array(_capture_property_change(agent, "time_horizon_agents", float(params.get("time_horizon_agents"))))
	if params.has("time_horizon_obstacles"):
		pending_changes.append_array(
			_capture_property_change(agent, "time_horizon_obstacles", float(params.get("time_horizon_obstacles")))
		)
	if params.has("avoidance_layers"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_layers", int(params.get("avoidance_layers"))))
	if params.has("avoidance_mask"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_mask", int(params.get("avoidance_mask"))))
	if params.has("avoidance_priority"):
		pending_changes.append_array(_capture_property_change(agent, "avoidance_priority", float(params.get("avoidance_priority"))))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_navigation_agent_3d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure NavigationAgent3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure NavigationAgent3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for NavigationAgent3D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(agent, change.property, change.value)
		transaction.add_undo_property(agent, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured NavigationAgent3D", "_configure_navigation_agent_3d", {
			"node_path": _to_mcp_path(agent),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(agent),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit NavigationAgent3D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_navigation_obstacle_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "NavigationObstacle2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is NavigationObstacle2D):
		return _send_error(client_id, "Node at %s is not a NavigationObstacle2D" % node_path, command_id)

	var obstacle: NavigationObstacle2D = node
	var pending_changes: Array = []

	if params.has("avoidance_enabled"):
		pending_changes.append_array(_capture_property_change(obstacle, "avoidance_enabled", bool(params.get("avoidance_enabled"))))
	if params.has("avoidance_layers"):
		pending_changes.append_array(_capture_property_change(obstacle, "avoidance_layers", int(params.get("avoidance_layers"))))
	if params.has("radius"):
		pending_changes.append_array(_capture_property_change(obstacle, "radius", float(params.get("radius"))))
	if params.has("velocity"):
		pending_changes.append_array(_capture_property_change(obstacle, "velocity", _parse_vector2_param(params.get("velocity"))))
	if params.has("use_3d_avoidance"):
		pending_changes.append_array(_capture_property_change(obstacle, "use_3d_avoidance", bool(params.get("use_3d_avoidance"))))
	if params.has("vertices"):
		var vertices_result := _parse_vector2_array_param(params.get("vertices"))
		if not vertices_result.get("ok", false):
			return _send_error(client_id, vertices_result.get("error", "Invalid vertices array"), command_id)
		pending_changes.append_array(_capture_property_change(obstacle, "vertices", vertices_result.get("value", PackedVector2Array())))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_navigation_obstacle_2d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure NavigationObstacle2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure NavigationObstacle2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for NavigationObstacle2D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(obstacle, change.property, change.value)
		transaction.add_undo_property(obstacle, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured NavigationObstacle2D", "_configure_navigation_obstacle_2d", {
			"node_path": _to_mcp_path(obstacle),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(obstacle),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit NavigationObstacle2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_navigation_obstacle_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "NavigationObstacle3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is NavigationObstacle3D):
		return _send_error(client_id, "Node at %s is not a NavigationObstacle3D" % node_path, command_id)

	var obstacle: NavigationObstacle3D = node
	var pending_changes: Array = []

	if params.has("avoidance_enabled"):
		pending_changes.append_array(_capture_property_change(obstacle, "avoidance_enabled", bool(params.get("avoidance_enabled"))))
	if params.has("avoidance_layers"):
		pending_changes.append_array(_capture_property_change(obstacle, "avoidance_layers", int(params.get("avoidance_layers"))))
	if params.has("radius"):
		pending_changes.append_array(_capture_property_change(obstacle, "radius", float(params.get("radius"))))
	if params.has("height"):
		pending_changes.append_array(_capture_property_change(obstacle, "height", float(params.get("height"))))
	if params.has("velocity"):
		pending_changes.append_array(_capture_property_change(obstacle, "velocity", _parse_vector3_param(params.get("velocity"))))
	if params.has("vertices"):
		var vertices_result := _parse_vector3_array_param(params.get("vertices"))
		if not vertices_result.get("ok", false):
			return _send_error(client_id, vertices_result.get("error", "Invalid vertices array"), command_id)
		pending_changes.append_array(_capture_property_change(obstacle, "vertices", vertices_result.get("value", PackedVector3Array())))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_navigation_obstacle_3d",
		"node_path": node_path,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure NavigationObstacle3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure NavigationObstacle3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for NavigationObstacle3D configuration", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(obstacle, change.property, change.value)
		transaction.add_undo_property(obstacle, change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured NavigationObstacle3D", "_configure_navigation_obstacle_3d", {
			"node_path": _to_mcp_path(obstacle),
			"change_count": serialized_changes.size(),
			"changes": serialized_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(obstacle),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit NavigationObstacle3D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _advance_pathfollow2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "PathFollow2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is PathFollow2D):
		return _send_error(client_id, "Node at %s is not a PathFollow2D" % node_path, command_id)

	var path_follow: PathFollow2D = node
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []

	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var reverse: bool = bool(params.get("reverse", false))
	var direction_multiplier: float = -1.0 if reverse else 1.0
	var stored_speed: float = float(path_follow.get_meta("mcp_path_speed_2d")) if path_follow.has_meta("mcp_path_speed_2d") else 0.0
	var speed: float = float(params.get("speed", stored_speed))
	var progress_delta: float = float(params.get("progress_delta", speed * delta)) * direction_multiplier
	var progress_ratio_delta: float = float(params.get("progress_ratio_delta", 0.0)) * direction_multiplier

	if params.has("progress"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "progress", float(params.get("progress"))))
	elif absf(progress_delta) > 0.000001:
		pending_property_changes.append_array(_capture_property_change(path_follow, "progress", path_follow.progress + progress_delta))

	if params.has("progress_ratio"):
		pending_property_changes.append_array(
			_capture_property_change(path_follow, "progress_ratio", float(params.get("progress_ratio")))
		)
	elif absf(progress_ratio_delta) > 0.000001:
		pending_property_changes.append_array(
			_capture_property_change(path_follow, "progress_ratio", path_follow.progress_ratio + progress_ratio_delta)
		)

	if params.has("loop"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "loop", bool(params.get("loop"))))
	if params.has("cubic_interp"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "cubic_interp", bool(params.get("cubic_interp"))))
	if params.has("rotates"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "rotates", bool(params.get("rotates"))))
	if params.has("h_offset"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "h_offset", float(params.get("h_offset"))))
	if params.has("v_offset"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "v_offset", float(params.get("v_offset"))))

	if params.has("speed"):
		pending_meta_changes.append_array(_capture_meta_change(path_follow, "mcp_path_speed_2d", speed))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
			"progress": path_follow.progress,
			"progress_ratio": path_follow.progress_ratio,
		}, command_id)

	var transaction_metadata := {
		"command": "advance_pathfollow2d",
		"node_path": node_path,
		"delta": delta,
		"speed": speed,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Advance PathFollow2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Advance PathFollow2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for PathFollow2D advance", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		transaction.add_do_property(path_follow, change.property, change.value)
		transaction.add_undo_property(path_follow, change.property, change.previous)
		serialized_property_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(path_follow, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(path_follow, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(path_follow, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Advanced PathFollow2D", "_advance_pathfollow2d", {
			"node_path": _to_mcp_path(path_follow),
			"progress": path_follow.progress,
			"progress_ratio": path_follow.progress_ratio,
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "pathfollow_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(path_follow),
		"progress": path_follow.progress + progress_delta,
		"progress_ratio": path_follow.progress_ratio + progress_ratio_delta,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit PathFollow2D advance", command_id)
		response["progress"] = path_follow.progress
		response["progress_ratio"] = path_follow.progress_ratio
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _advance_pathfollow3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "PathFollow3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is PathFollow3D):
		return _send_error(client_id, "Node at %s is not a PathFollow3D" % node_path, command_id)

	var path_follow: PathFollow3D = node
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []

	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var reverse: bool = bool(params.get("reverse", false))
	var direction_multiplier: float = -1.0 if reverse else 1.0
	var stored_speed: float = float(path_follow.get_meta("mcp_path_speed_3d")) if path_follow.has_meta("mcp_path_speed_3d") else 0.0
	var speed: float = float(params.get("speed", stored_speed))
	var progress_delta: float = float(params.get("progress_delta", speed * delta)) * direction_multiplier
	var progress_ratio_delta: float = float(params.get("progress_ratio_delta", 0.0)) * direction_multiplier

	if params.has("progress"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "progress", float(params.get("progress"))))
	elif absf(progress_delta) > 0.000001:
		pending_property_changes.append_array(_capture_property_change(path_follow, "progress", path_follow.progress + progress_delta))

	if params.has("progress_ratio"):
		pending_property_changes.append_array(
			_capture_property_change(path_follow, "progress_ratio", float(params.get("progress_ratio")))
		)
	elif absf(progress_ratio_delta) > 0.000001:
		pending_property_changes.append_array(
			_capture_property_change(path_follow, "progress_ratio", path_follow.progress_ratio + progress_ratio_delta)
		)

	if params.has("loop"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "loop", bool(params.get("loop"))))
	if params.has("cubic_interp"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "cubic_interp", bool(params.get("cubic_interp"))))
	if params.has("rotation_mode"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "rotation_mode", int(params.get("rotation_mode"))))
	if params.has("tilt_enabled"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "tilt_enabled", bool(params.get("tilt_enabled"))))
	if params.has("use_model_front"):
		pending_property_changes.append_array(_capture_property_change(path_follow, "use_model_front", bool(params.get("use_model_front"))))

	if params.has("speed"):
		pending_meta_changes.append_array(_capture_meta_change(path_follow, "mcp_path_speed_3d", speed))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"status": "no_change",
			"progress": path_follow.progress,
			"progress_ratio": path_follow.progress_ratio,
		}, command_id)

	var transaction_metadata := {
		"command": "advance_pathfollow3d",
		"node_path": node_path,
		"delta": delta,
		"speed": speed,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Advance PathFollow3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Advance PathFollow3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for PathFollow3D advance", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		transaction.add_do_property(path_follow, change.property, change.value)
		transaction.add_undo_property(path_follow, change.property, change.previous)
		serialized_property_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(path_follow, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(path_follow, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(path_follow, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Advanced PathFollow3D", "_advance_pathfollow3d", {
			"node_path": _to_mcp_path(path_follow),
			"progress": path_follow.progress,
			"progress_ratio": path_follow.progress_ratio,
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "pathfollow_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(path_follow),
		"progress": path_follow.progress + progress_delta,
		"progress_ratio": path_follow.progress_ratio + progress_ratio_delta,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit PathFollow3D advance", command_id)
		response["progress"] = path_follow.progress
		response["progress_ratio"] = path_follow.progress_ratio
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_path2d_followers(client_id: int, params: Dictionary, command_id: String) -> void:
	var path_path: String = String(params.get("path_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if path_path.is_empty():
		return _send_error(client_id, "path_path cannot be empty", command_id)

	var path_node = _get_editor_node(path_path)
	if path_node == null:
		return _send_error(client_id, "Path node not found: %s" % path_path, command_id)
	if not (path_node is Path2D):
		return _send_error(client_id, "Node at %s is not a Path2D" % path_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var follower_count: int = max(0, int(params.get("follower_count", 0)))
	var create_missing: bool = bool(params.get("create_missing", true))
	var base_name: String = String(params.get("base_name", "PathFollower2D")).strip_edges()
	if base_name.is_empty():
		base_name = "PathFollower2D"

	var use_progress_ratio: bool = bool(params.get("use_progress_ratio", false))
	var spacing: float = float(params.get("spacing", 0.12 if use_progress_ratio else 96.0))
	var start_progress: float = float(params.get("start_progress", 0.0))

	var followers: Array = []
	for child in path_node.get_children():
		if child is PathFollow2D:
			followers.append(child)

	var created_followers: Array = []
	if follower_count > followers.size():
		if not create_missing:
			return _send_error(client_id, "follower_count exceeds existing PathFollow2D children and create_missing=false", command_id)
		var reserved_names := _collect_child_name_set(path_node)
		for idx in range(followers.size(), follower_count):
			var follower := PathFollow2D.new()
			var desired_name := "%s%02d" % [base_name, idx + 1]
			follower.name = _resolve_unique_name_in_set(desired_name, reserved_names)
			created_followers.append(follower)
			followers.append(follower)

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	var follower_limit: int = followers.size()
	if follower_count > 0:
		follower_limit = min(follower_limit, follower_count)

	var has_global_speed: bool = params.has("speed")
	var global_speed: float = float(params.get("speed", 0.0))
	for idx in range(follower_limit):
		var follower: PathFollow2D = followers[idx]
		if params.has("spacing") or params.has("start_progress") or params.has("use_progress_ratio"):
			var spacing_value := start_progress + float(idx) * spacing
			if use_progress_ratio:
				pending_property_changes.append_array(_capture_property_change(follower, "progress_ratio", spacing_value))
			else:
				pending_property_changes.append_array(_capture_property_change(follower, "progress", spacing_value))
		if params.has("loop"):
			pending_property_changes.append_array(_capture_property_change(follower, "loop", bool(params.get("loop"))))
		if params.has("cubic_interp"):
			pending_property_changes.append_array(_capture_property_change(follower, "cubic_interp", bool(params.get("cubic_interp"))))
		if params.has("rotates"):
			pending_property_changes.append_array(_capture_property_change(follower, "rotates", bool(params.get("rotates"))))
		if params.has("h_offset"):
			pending_property_changes.append_array(_capture_property_change(follower, "h_offset", float(params.get("h_offset"))))
		if params.has("v_offset"):
			pending_property_changes.append_array(_capture_property_change(follower, "v_offset", float(params.get("v_offset"))))
		if has_global_speed:
			var speed_meta_changes := _capture_meta_change(follower, "mcp_path_speed_2d", global_speed)
			for speed_change in speed_meta_changes:
				speed_change["target"] = follower
				pending_meta_changes.append(speed_change)

	if params.has("followers"):
		var followers_value = params.get("followers")
		if typeof(followers_value) != TYPE_ARRAY:
			return _send_error(client_id, "followers must be an array", command_id)
		var follower_overrides: Array = followers_value
		for override_value in follower_overrides:
			if typeof(override_value) != TYPE_DICTIONARY:
				return _send_error(client_id, "followers entries must be dictionaries", command_id)
			var override: Dictionary = override_value

			var follower_target: PathFollow2D = null
			if override.has("node_path"):
				var explicit_node_path: String = String(override.get("node_path", "")).strip_edges()
				if explicit_node_path.is_empty():
					return _send_error(client_id, "followers.node_path cannot be empty", command_id)
				var explicit_node = _get_editor_node(explicit_node_path)
				if explicit_node == null or not (explicit_node is PathFollow2D):
					return _send_error(client_id, "followers.node_path must reference a PathFollow2D", command_id)
				follower_target = explicit_node
			elif override.has("index"):
				var target_index: int = int(override.get("index", -1))
				if target_index < 0 or target_index >= followers.size():
					return _send_error(client_id, "followers.index out of range: %d" % target_index, command_id)
				follower_target = followers[target_index]
			elif override.has("name"):
				var target_name: String = String(override.get("name", "")).strip_edges()
				for follower_entry in followers:
					if String((follower_entry as PathFollow2D).name) == target_name:
						follower_target = follower_entry
						break
				if follower_target == null:
					return _send_error(client_id, "No PathFollow2D child named %s" % target_name, command_id)
			else:
				return _send_error(client_id, "Each followers entry must include node_path, index, or name", command_id)

			if override.has("progress"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "progress", float(override.get("progress"))))
			if override.has("progress_ratio"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "progress_ratio", float(override.get("progress_ratio"))))
			if override.has("loop"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "loop", bool(override.get("loop"))))
			if override.has("cubic_interp"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "cubic_interp", bool(override.get("cubic_interp"))))
			if override.has("rotates"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "rotates", bool(override.get("rotates"))))
			if override.has("h_offset"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "h_offset", float(override.get("h_offset"))))
			if override.has("v_offset"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "v_offset", float(override.get("v_offset"))))
			if override.has("speed"):
				var override_speed_changes := _capture_meta_change(follower_target, "mcp_path_speed_2d", float(override.get("speed")))
				for speed_change in override_speed_changes:
					speed_change["target"] = follower_target
					pending_meta_changes.append(speed_change)

	if created_followers.is_empty() and pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		var no_change_paths: Array = []
		for follower_entry in followers:
			var follower_node: PathFollow2D = follower_entry
			no_change_paths.append(_to_mcp_path(follower_node))
		return _send_success(client_id, {
			"path_path": _to_mcp_path(path_node),
			"follower_count": no_change_paths.size(),
			"created_count": 0,
			"updated_count": 0,
			"follower_paths": no_change_paths,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_path2d_followers",
		"path_path": _to_mcp_path(path_node),
		"created_count": created_followers.size(),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Path2D Followers", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Path2D Followers", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Path2D follower configuration", command_id)

	for created_entry in created_followers:
		var created_follower: PathFollow2D = created_entry
		transaction.add_do_method(path_node, "add_child", [created_follower])
		transaction.add_do_method(created_follower, "set_owner", [edited_scene_root])
		transaction.add_undo_method(path_node, "remove_child", [created_follower])
		transaction.add_undo_method(created_follower, "queue_free")
		transaction.add_do_reference(created_follower)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target")
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		var meta_target: Object = change.get("target")
		transaction.add_do_method(meta_target, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(meta_target, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(meta_target, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _describe_object_path(meta_target),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Path2D followers", "_configure_path2d_followers", {
			"path_path": _to_mcp_path(path_node),
			"created_count": created_followers.size(),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "pathfollow_2d",
			"line_num": 0,
		})
	)

	var predicted_paths: Array = []
	var path_mcp_path: String = _to_mcp_path(path_node)
	for follower_entry in followers:
		var follower_node: PathFollow2D = follower_entry
		if follower_node.is_inside_tree():
			predicted_paths.append(_to_mcp_path(follower_node))
		else:
			predicted_paths.append(_join_mcp_path(path_mcp_path, String(follower_node.name)))

	var response := {
		"path_path": path_mcp_path,
		"follower_count": predicted_paths.size(),
		"created_count": created_followers.size(),
		"updated_count": serialized_property_changes.size() + serialized_meta_changes.size(),
		"follower_paths": predicted_paths,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Path2D follower configuration", command_id)
		var committed_paths: Array = []
		for follower_entry in followers:
			var follower_node: PathFollow2D = follower_entry
			committed_paths.append(_to_mcp_path(follower_node))
		response["follower_paths"] = committed_paths
		response["follower_count"] = committed_paths.size()
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_path3d_followers(client_id: int, params: Dictionary, command_id: String) -> void:
	var path_path: String = String(params.get("path_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if path_path.is_empty():
		return _send_error(client_id, "path_path cannot be empty", command_id)

	var path_node = _get_editor_node(path_path)
	if path_node == null:
		return _send_error(client_id, "Path node not found: %s" % path_path, command_id)
	if not (path_node is Path3D):
		return _send_error(client_id, "Node at %s is not a Path3D" % path_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var follower_count: int = max(0, int(params.get("follower_count", 0)))
	var create_missing: bool = bool(params.get("create_missing", true))
	var base_name: String = String(params.get("base_name", "PathFollower3D")).strip_edges()
	if base_name.is_empty():
		base_name = "PathFollower3D"

	var use_progress_ratio: bool = bool(params.get("use_progress_ratio", false))
	var spacing: float = float(params.get("spacing", 0.12 if use_progress_ratio else 4.0))
	var start_progress: float = float(params.get("start_progress", 0.0))

	var followers: Array = []
	for child in path_node.get_children():
		if child is PathFollow3D:
			followers.append(child)

	var created_followers: Array = []
	if follower_count > followers.size():
		if not create_missing:
			return _send_error(client_id, "follower_count exceeds existing PathFollow3D children and create_missing=false", command_id)
		var reserved_names := _collect_child_name_set(path_node)
		for idx in range(followers.size(), follower_count):
			var follower := PathFollow3D.new()
			var desired_name := "%s%02d" % [base_name, idx + 1]
			follower.name = _resolve_unique_name_in_set(desired_name, reserved_names)
			created_followers.append(follower)
			followers.append(follower)

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	var follower_limit: int = followers.size()
	if follower_count > 0:
		follower_limit = min(follower_limit, follower_count)

	var has_global_speed: bool = params.has("speed")
	var global_speed: float = float(params.get("speed", 0.0))
	for idx in range(follower_limit):
		var follower: PathFollow3D = followers[idx]
		if params.has("spacing") or params.has("start_progress") or params.has("use_progress_ratio"):
			var spacing_value := start_progress + float(idx) * spacing
			if use_progress_ratio:
				pending_property_changes.append_array(_capture_property_change(follower, "progress_ratio", spacing_value))
			else:
				pending_property_changes.append_array(_capture_property_change(follower, "progress", spacing_value))
		if params.has("loop"):
			pending_property_changes.append_array(_capture_property_change(follower, "loop", bool(params.get("loop"))))
		if params.has("cubic_interp"):
			pending_property_changes.append_array(_capture_property_change(follower, "cubic_interp", bool(params.get("cubic_interp"))))
		if params.has("rotation_mode"):
			pending_property_changes.append_array(_capture_property_change(follower, "rotation_mode", int(params.get("rotation_mode"))))
		if params.has("tilt_enabled"):
			pending_property_changes.append_array(_capture_property_change(follower, "tilt_enabled", bool(params.get("tilt_enabled"))))
		if params.has("use_model_front"):
			pending_property_changes.append_array(_capture_property_change(follower, "use_model_front", bool(params.get("use_model_front"))))
		if has_global_speed:
			var speed_meta_changes := _capture_meta_change(follower, "mcp_path_speed_3d", global_speed)
			for speed_change in speed_meta_changes:
				speed_change["target"] = follower
				pending_meta_changes.append(speed_change)

	if params.has("followers"):
		var followers_value = params.get("followers")
		if typeof(followers_value) != TYPE_ARRAY:
			return _send_error(client_id, "followers must be an array", command_id)
		var follower_overrides: Array = followers_value
		for override_value in follower_overrides:
			if typeof(override_value) != TYPE_DICTIONARY:
				return _send_error(client_id, "followers entries must be dictionaries", command_id)
			var override: Dictionary = override_value

			var follower_target: PathFollow3D = null
			if override.has("node_path"):
				var explicit_node_path: String = String(override.get("node_path", "")).strip_edges()
				if explicit_node_path.is_empty():
					return _send_error(client_id, "followers.node_path cannot be empty", command_id)
				var explicit_node = _get_editor_node(explicit_node_path)
				if explicit_node == null or not (explicit_node is PathFollow3D):
					return _send_error(client_id, "followers.node_path must reference a PathFollow3D", command_id)
				follower_target = explicit_node
			elif override.has("index"):
				var target_index: int = int(override.get("index", -1))
				if target_index < 0 or target_index >= followers.size():
					return _send_error(client_id, "followers.index out of range: %d" % target_index, command_id)
				follower_target = followers[target_index]
			elif override.has("name"):
				var target_name: String = String(override.get("name", "")).strip_edges()
				for follower_entry in followers:
					if String((follower_entry as PathFollow3D).name) == target_name:
						follower_target = follower_entry
						break
				if follower_target == null:
					return _send_error(client_id, "No PathFollow3D child named %s" % target_name, command_id)
			else:
				return _send_error(client_id, "Each followers entry must include node_path, index, or name", command_id)

			if override.has("progress"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "progress", float(override.get("progress"))))
			if override.has("progress_ratio"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "progress_ratio", float(override.get("progress_ratio"))))
			if override.has("loop"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "loop", bool(override.get("loop"))))
			if override.has("cubic_interp"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "cubic_interp", bool(override.get("cubic_interp"))))
			if override.has("rotation_mode"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "rotation_mode", int(override.get("rotation_mode"))))
			if override.has("tilt_enabled"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "tilt_enabled", bool(override.get("tilt_enabled"))))
			if override.has("use_model_front"):
				pending_property_changes.append_array(_capture_property_change(follower_target, "use_model_front", bool(override.get("use_model_front"))))
			if override.has("speed"):
				var override_speed_changes := _capture_meta_change(follower_target, "mcp_path_speed_3d", float(override.get("speed")))
				for speed_change in override_speed_changes:
					speed_change["target"] = follower_target
					pending_meta_changes.append(speed_change)

	if created_followers.is_empty() and pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		var no_change_paths: Array = []
		for follower_entry in followers:
			var follower_node: PathFollow3D = follower_entry
			no_change_paths.append(_to_mcp_path(follower_node))
		return _send_success(client_id, {
			"path_path": _to_mcp_path(path_node),
			"follower_count": no_change_paths.size(),
			"created_count": 0,
			"updated_count": 0,
			"follower_paths": no_change_paths,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_path3d_followers",
		"path_path": _to_mcp_path(path_node),
		"created_count": created_followers.size(),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Path3D Followers", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Path3D Followers", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for Path3D follower configuration", command_id)

	for created_entry in created_followers:
		var created_follower: PathFollow3D = created_entry
		transaction.add_do_method(path_node, "add_child", [created_follower])
		transaction.add_do_method(created_follower, "set_owner", [edited_scene_root])
		transaction.add_undo_method(path_node, "remove_child", [created_follower])
		transaction.add_undo_method(created_follower, "queue_free")
		transaction.add_do_reference(created_follower)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target")
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		var meta_target: Object = change.get("target")
		transaction.add_do_method(meta_target, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(meta_target, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(meta_target, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _describe_object_path(meta_target),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Path3D followers", "_configure_path3d_followers", {
			"path_path": _to_mcp_path(path_node),
			"created_count": created_followers.size(),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "pathfollow_3d",
			"line_num": 0,
		})
	)

	var predicted_paths: Array = []
	var path_mcp_path: String = _to_mcp_path(path_node)
	for follower_entry in followers:
		var follower_node: PathFollow3D = follower_entry
		if follower_node.is_inside_tree():
			predicted_paths.append(_to_mcp_path(follower_node))
		else:
			predicted_paths.append(_join_mcp_path(path_mcp_path, String(follower_node.name)))

	var response := {
		"path_path": path_mcp_path,
		"follower_count": predicted_paths.size(),
		"created_count": created_followers.size(),
		"updated_count": serialized_property_changes.size() + serialized_meta_changes.size(),
		"follower_paths": predicted_paths,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit Path3D follower configuration", command_id)
		var committed_paths: Array = []
		for follower_entry in followers:
			var follower_node: PathFollow3D = follower_entry
			committed_paths.append(_to_mcp_path(follower_node))
		response["follower_paths"] = committed_paths
		response["follower_count"] = committed_paths.size()
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_topdown_movement_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")
	var apply_defaults: bool = params.get("apply_defaults", true)

	if node_path.is_empty():
		return _send_error(client_id, "CharacterBody2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is CharacterBody2D):
		return _send_error(client_id, "Node at %s is not a CharacterBody2D" % node_path, command_id)

	var body: CharacterBody2D = node
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []

	if apply_defaults and not params.has("motion_mode"):
		pending_property_changes.append_array(
			_capture_property_change(body, "motion_mode", CharacterBody2D.MOTION_MODE_FLOATING)
		)
	if apply_defaults and not params.has("up_direction"):
		pending_property_changes.append_array(_capture_property_change(body, "up_direction", Vector2.UP))
	if apply_defaults and not params.has("floor_stop_on_slope"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_stop_on_slope", false))
	if apply_defaults and not params.has("floor_constant_speed"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_constant_speed", false))
	if apply_defaults and not params.has("floor_block_on_wall"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_block_on_wall", false))
	if apply_defaults and not params.has("floor_snap_length"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_snap_length", 0.0))
	if apply_defaults and not params.has("platform_floor_layers"):
		pending_property_changes.append_array(_capture_property_change(body, "platform_floor_layers", 0))
	if apply_defaults and not params.has("platform_wall_layers"):
		pending_property_changes.append_array(_capture_property_change(body, "platform_wall_layers", 0))

	if params.has("motion_mode"):
		pending_property_changes.append_array(_capture_property_change(body, "motion_mode", int(params.get("motion_mode"))))
	if params.has("up_direction"):
		pending_property_changes.append_array(_capture_property_change(body, "up_direction", _parse_vector2_param(params.get("up_direction"))))
	if params.has("floor_stop_on_slope"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_stop_on_slope", bool(params.get("floor_stop_on_slope"))))
	if params.has("floor_constant_speed"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_constant_speed", bool(params.get("floor_constant_speed"))))
	if params.has("floor_block_on_wall"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_block_on_wall", bool(params.get("floor_block_on_wall"))))
	if params.has("floor_snap_length"):
		pending_property_changes.append_array(_capture_property_change(body, "floor_snap_length", float(params.get("floor_snap_length"))))
	if params.has("max_slides"):
		pending_property_changes.append_array(_capture_property_change(body, "max_slides", int(params.get("max_slides"))))
	if params.has("safe_margin"):
		pending_property_changes.append_array(_capture_property_change(body, "safe_margin", float(params.get("safe_margin"))))
	if params.has("slide_on_ceiling"):
		pending_property_changes.append_array(_capture_property_change(body, "slide_on_ceiling", bool(params.get("slide_on_ceiling"))))
	if params.has("platform_on_leave"):
		pending_property_changes.append_array(_capture_property_change(body, "platform_on_leave", int(params.get("platform_on_leave"))))
	if params.has("platform_floor_layers"):
		pending_property_changes.append_array(_capture_property_change(body, "platform_floor_layers", int(params.get("platform_floor_layers"))))
	if params.has("platform_wall_layers"):
		pending_property_changes.append_array(_capture_property_change(body, "platform_wall_layers", int(params.get("platform_wall_layers"))))
	if params.has("velocity"):
		pending_property_changes.append_array(_capture_property_change(body, "velocity", _parse_vector2_param(params.get("velocity"))))

	var speed_value = params.get("speed", (200.0 if apply_defaults else null))
	var acceleration_value = params.get("acceleration", (1400.0 if apply_defaults else null))
	var deceleration_value = params.get("deceleration", (1800.0 if apply_defaults else null))
	if speed_value != null:
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_topdown_speed", float(speed_value)))
	if acceleration_value != null:
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_topdown_acceleration", float(acceleration_value)))
	if deceleration_value != null:
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_topdown_deceleration", float(deceleration_value)))

	var default_input_actions := {
		"up": "move_up",
		"down": "move_down",
		"left": "move_left",
		"right": "move_right",
	}
	var input_actions_data: Dictionary = {}
	if apply_defaults:
		input_actions_data = default_input_actions.duplicate(true)
	if params.has("input_actions"):
		var input_actions_value = params.get("input_actions")
		if typeof(input_actions_value) != TYPE_DICTIONARY:
			return _send_error(client_id, "input_actions must be a dictionary", command_id)
		var user_input_actions: Dictionary = input_actions_value
		for key in user_input_actions.keys():
			input_actions_data[String(key)] = user_input_actions[key]
	if not input_actions_data.is_empty():
		var normalized_actions: Dictionary = {}
		for direction in ["up", "down", "left", "right"]:
			if input_actions_data.has(direction):
				var action_name: String = String(input_actions_data.get(direction, "")).strip_edges()
				if action_name.is_empty():
					return _send_error(client_id, "input_actions.%s cannot be empty" % direction, command_id)
				normalized_actions[direction] = action_name
		if normalized_actions.is_empty():
			return _send_error(client_id, "input_actions must include at least one of up/down/left/right", command_id)
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_topdown_input_actions", normalized_actions))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"meta_changes": [],
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_topdown_movement_2d",
		"node_path": node_path,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Top-Down Movement 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Top-Down Movement 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for top-down configuration", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		transaction.add_do_property(body, change.property, change.value)
		transaction.add_undo_property(body, change.property, change.previous)
		serialized_property_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(body, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(body, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(body, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured top-down movement 2D", "_configure_topdown_movement_2d", {
			"node_path": _to_mcp_path(body),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"property_changes": serialized_property_changes,
			"meta_changes": serialized_meta_changes,
			"transaction_id": transaction.transaction_id,
			"system_section": "topdown_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(body),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit top-down 2D configuration", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_characterbody2d_movement(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "CharacterBody2D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is CharacterBody2D):
		return _send_error(client_id, "Node at %s is not a CharacterBody2D" % node_path, command_id)

	var body: CharacterBody2D = node
	var direction := _parse_vector2_param(params.get("direction", Vector2.ZERO))
	if direction.length() > 1.0:
		direction = direction.normalized()

	var speed: float = float(params.get("speed", body.get_meta("mcp_topdown_speed") if body.has_meta("mcp_topdown_speed") else 200.0))
	var acceleration: float = float(params.get("acceleration", body.get_meta("mcp_topdown_acceleration") if body.has_meta("mcp_topdown_acceleration") else speed * 7.0))
	var deceleration: float = float(params.get("deceleration", body.get_meta("mcp_topdown_deceleration") if body.has_meta("mcp_topdown_deceleration") else speed * 9.0))
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var set_rotation: bool = bool(params.get("set_rotation", false))
	var flip_sprite_h: bool = bool(params.get("flip_sprite_h", true))

	var current_velocity: Vector2 = body.velocity
	var target_velocity: Vector2 = direction * speed
	var interpolation: float = (acceleration if direction.length() > 0.001 else deceleration) * delta
	var new_velocity: Vector2 = current_velocity.move_toward(target_velocity, interpolation)
	var new_position: Vector2 = body.position + new_velocity * delta

	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(body, "velocity", new_velocity))
	pending_changes.append_array(_capture_property_change(body, "position", new_position))

	if set_rotation and direction.length() > 0.001:
		pending_changes.append_array(_capture_property_change(body, "rotation", direction.angle()))

	var sprite_path: String = String(params.get("sprite_path", "")).strip_edges()
	var sprite_node = _resolve_sprite_node_for_movement(body, sprite_path)
	if sprite_node and flip_sprite_h and absf(direction.x) > 0.001 and (sprite_node is Sprite2D or sprite_node is AnimatedSprite2D):
		pending_changes.append_array(_capture_property_change(sprite_node, "flip_h", direction.x < 0.0))

	if sprite_node and sprite_node is AnimatedSprite2D and params.has("animation_map"):
		var animation_map_raw = params.get("animation_map")
		if typeof(animation_map_raw) != TYPE_DICTIONARY:
			return _send_error(client_id, "animation_map must be a dictionary", command_id)
		var animation_map: Dictionary = animation_map_raw
		var animation_key := "move" if direction.length() > 0.001 else "idle"
		if animation_map.has(animation_key):
			var animation_name: String = String(animation_map.get(animation_key, "")).strip_edges()
			if not animation_name.is_empty():
				pending_changes.append_array(_capture_property_change(sprite_node, "animation", animation_name))
				if bool(params.get("play_animation", true)):
					pending_changes.append_array(_capture_property_change(sprite_node, "playing", true))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(body),
			"position": _vector2_to_dict(body.position),
			"velocity": _vector2_to_dict(body.velocity),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_characterbody2d_movement",
		"node_path": node_path,
		"delta": delta,
		"speed": speed,
		"acceleration": acceleration,
		"deceleration": deceleration,
		"direction": _vector2_to_dict(direction),
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate CharacterBody2D Movement", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate CharacterBody2D Movement", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for CharacterBody2D simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(change.get("target", body), change.property, change.value)
		transaction.add_undo_property(change.get("target", body), change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated CharacterBody2D movement", "_simulate_characterbody2d_movement", {
			"node_path": _to_mcp_path(body),
			"position": _vector2_to_dict(body.position),
			"velocity": _vector2_to_dict(body.velocity),
			"change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "movement_2d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(body),
		"direction": _vector2_to_dict(direction),
		"delta": delta,
		"speed": speed,
		"position": _vector2_to_dict(new_position),
		"velocity": _vector2_to_dict(new_velocity),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit CharacterBody2D simulation", command_id)
		response["position"] = _vector2_to_dict(body.position)
		response["velocity"] = _vector2_to_dict(body.velocity)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_characterbody3d_movement(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "CharacterBody3D node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is CharacterBody3D):
		return _send_error(client_id, "Node at %s is not a CharacterBody3D" % node_path, command_id)

	var body: CharacterBody3D = node
	var direction := _parse_vector3_param(params.get("direction", Vector3.ZERO))
	var planar_only: bool = bool(params.get("planar_only", true))
	var preserve_vertical_velocity: bool = bool(params.get("preserve_vertical_velocity", true))
	if planar_only:
		direction.y = 0.0
	if direction.length() > 1.0:
		direction = direction.normalized()

	var speed: float = float(params.get("speed", body.get_meta("mcp_3d_speed") if body.has_meta("mcp_3d_speed") else 6.0))
	var acceleration: float = float(params.get("acceleration", body.get_meta("mcp_3d_acceleration") if body.has_meta("mcp_3d_acceleration") else speed * 10.0))
	var deceleration: float = float(params.get("deceleration", body.get_meta("mcp_3d_deceleration") if body.has_meta("mcp_3d_deceleration") else speed * 14.0))
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var yaw_to_direction: bool = bool(params.get("yaw_to_direction", false))

	var current_velocity: Vector3 = body.velocity
	var target_velocity: Vector3 = direction * speed
	var interpolation: float = (acceleration if direction.length() > 0.001 else deceleration) * delta

	var new_velocity: Vector3
	if planar_only:
		var current_horizontal := Vector3(current_velocity.x, 0.0, current_velocity.z)
		var target_horizontal := Vector3(target_velocity.x, 0.0, target_velocity.z)
		var next_horizontal := current_horizontal.move_toward(target_horizontal, interpolation)
		var next_vertical := current_velocity.y if preserve_vertical_velocity else move_toward(current_velocity.y, target_velocity.y, interpolation)
		new_velocity = Vector3(next_horizontal.x, next_vertical, next_horizontal.z)
	else:
		new_velocity = current_velocity.move_toward(target_velocity, interpolation)

	var new_position: Vector3 = body.position + new_velocity * delta
	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(body, "velocity", new_velocity))
	pending_changes.append_array(_capture_property_change(body, "position", new_position))

	var horizontal_direction := Vector2(direction.x, direction.z)
	if yaw_to_direction and horizontal_direction.length() > 0.001:
		pending_changes.append_array(_capture_property_change(body, "rotation", Vector3(body.rotation.x, atan2(direction.x, direction.z), body.rotation.z)))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(body),
			"position": _vector3_to_dict(body.position),
			"velocity": _vector3_to_dict(body.velocity),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_characterbody3d_movement",
		"node_path": node_path,
		"delta": delta,
		"speed": speed,
		"acceleration": acceleration,
		"deceleration": deceleration,
		"direction": _vector3_to_dict(direction),
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate CharacterBody3D Movement", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate CharacterBody3D Movement", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for CharacterBody3D simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		transaction.add_do_property(change.get("target", body), change.property, change.value)
		transaction.add_undo_property(change.get("target", body), change.property, change.previous)
		serialized_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated CharacterBody3D movement", "_simulate_characterbody3d_movement", {
			"node_path": _to_mcp_path(body),
			"position": _vector3_to_dict(body.position),
			"velocity": _vector3_to_dict(body.velocity),
			"change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "movement_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(body),
		"direction": _vector3_to_dict(direction),
		"delta": delta,
		"speed": speed,
		"position": _vector3_to_dict(new_position),
		"velocity": _vector3_to_dict(new_velocity),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit CharacterBody3D simulation", command_id)
		response["position"] = _vector3_to_dict(body.position)
		response["velocity"] = _vector3_to_dict(body.velocity)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_navigation_chase_step_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var agent_path: String = String(params.get("agent_path", "")).strip_edges()
	var body_path: String = String(params.get("body_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()

	if agent_path.is_empty():
		return _send_error(client_id, "agent_path cannot be empty", command_id)

	var agent_node = _get_editor_node(agent_path)
	if not agent_node:
		return _send_error(client_id, "NavigationAgent2D not found: %s" % agent_path, command_id)
	if not (agent_node is NavigationAgent2D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent2D" % agent_path, command_id)

	var body_node = null
	if body_path.is_empty():
		body_node = agent_node.get_parent()
	else:
		body_node = _get_editor_node(body_path)
	if not body_node:
		var resolved_body_path = body_path if not body_path.is_empty() else "<agent_parent>"
		return _send_error(client_id, "CharacterBody2D not found: %s" % resolved_body_path, command_id)
	if not (body_node is CharacterBody2D):
		return _send_error(client_id, "Body node at %s is not a CharacterBody2D" % _to_mcp_path(body_node), command_id)

	var agent: NavigationAgent2D = agent_node
	var body: CharacterBody2D = body_node
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var speed_default = body.get_meta("mcp_enemy_movement_speed") if body.has_meta("mcp_enemy_movement_speed") else (
		body.get_meta("mcp_topdown_speed") if body.has_meta("mcp_topdown_speed") else agent.max_speed
	)
	var speed: float = float(params.get("speed", speed_default))
	var acceleration_default = body.get_meta("mcp_enemy_acceleration") if body.has_meta("mcp_enemy_acceleration") else speed * 8.0
	var acceleration: float = float(params.get("acceleration", acceleration_default))
	var deceleration: float = float(params.get("deceleration", speed * 10.0))
	var stop_distance: float = max(0.0, float(params.get("stop_distance", agent.path_desired_distance)))
	var set_rotation: bool = bool(params.get("set_rotation", false))
	var update_agent_velocity: bool = bool(params.get("update_agent_velocity", true))
	var sync_agent_to_body: bool = bool(params.get("sync_agent_to_body", true))
	var stop_on_navigation_finished: bool = bool(params.get("stop_on_navigation_finished", true))
	var allow_direct_fallback: bool = bool(params.get("allow_direct_fallback", true))

	var next_path_position: Vector2 = agent.get_next_path_position()
	var to_next: Vector2 = next_path_position - body.global_position
	var distance_to_next: float = to_next.length()
	var to_target: Vector2 = agent.target_position - body.global_position
	var distance_to_target: float = to_target.length()
	var navigation_finished: bool = agent.is_navigation_finished()

	var direction := Vector2.ZERO
	if distance_to_next > stop_distance and (not stop_on_navigation_finished or not navigation_finished):
		direction = to_next / distance_to_next
	elif allow_direct_fallback and distance_to_target > stop_distance:
		direction = to_target / distance_to_target

	var target_velocity: Vector2 = direction * speed
	var interpolation: float = (acceleration if direction.length() > 0.001 else deceleration) * delta
	var new_velocity: Vector2 = body.velocity.move_toward(target_velocity, interpolation)
	var new_global_position: Vector2 = body.global_position + new_velocity * delta

	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(body, "velocity", new_velocity))
	pending_changes.append_array(_capture_property_change(body, "global_position", new_global_position))

	if set_rotation and direction.length() > 0.001:
		pending_changes.append_array(_capture_property_change(body, "rotation", direction.angle()))
	if update_agent_velocity:
		pending_changes.append_array(_capture_property_change(agent, "velocity", new_velocity))
	if sync_agent_to_body:
		if agent.get_parent() == body:
			pending_changes.append_array(_capture_property_change(agent, "position", Vector2.ZERO))
		else:
			pending_changes.append_array(_capture_property_change(agent, "global_position", new_global_position))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"agent_path": _to_mcp_path(agent),
			"body_path": _to_mcp_path(body),
			"status": "no_change",
			"position": _vector2_to_dict(body.global_position),
			"velocity": _vector2_to_dict(body.velocity),
			"next_path_position": _vector2_to_dict(next_path_position),
			"distance_to_next": distance_to_next,
			"distance_to_target": distance_to_target,
			"navigation_finished": navigation_finished,
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_navigation_chase_step_2d",
		"agent_path": agent_path,
		"body_path": _to_mcp_path(body),
		"delta": delta,
		"speed": speed,
		"acceleration": acceleration,
		"deceleration": deceleration,
		"stop_distance": stop_distance,
		"navigation_finished": navigation_finished,
		"allow_direct_fallback": allow_direct_fallback,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Navigation Chase Step 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Navigation Chase Step 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D navigation chase simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		var change_target: Object = change.get("target", body)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated navigation chase step 2D", "_simulate_navigation_chase_step_2d", {
			"agent_path": _to_mcp_path(agent),
			"body_path": _to_mcp_path(body),
			"position": _vector2_to_dict(body.global_position),
			"velocity": _vector2_to_dict(body.velocity),
			"next_path_position": _vector2_to_dict(next_path_position),
			"distance_to_next": distance_to_next,
			"distance_to_target": distance_to_target,
			"navigation_finished": navigation_finished,
			"change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_2d",
			"line_num": 0,
		})
	)

	var response := {
		"agent_path": _to_mcp_path(agent),
		"body_path": _to_mcp_path(body),
		"next_path_position": _vector2_to_dict(next_path_position),
		"distance_to_next": distance_to_next,
		"distance_to_target": distance_to_target,
		"navigation_finished": navigation_finished,
		"position": _vector2_to_dict(new_global_position),
		"velocity": _vector2_to_dict(new_velocity),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D navigation chase simulation", command_id)
		response["position"] = _vector2_to_dict(body.global_position)
		response["velocity"] = _vector2_to_dict(body.velocity)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_navigation_chase_step_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var agent_path: String = String(params.get("agent_path", "")).strip_edges()
	var body_path: String = String(params.get("body_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()

	if agent_path.is_empty():
		return _send_error(client_id, "agent_path cannot be empty", command_id)

	var agent_node = _get_editor_node(agent_path)
	if not agent_node:
		return _send_error(client_id, "NavigationAgent3D not found: %s" % agent_path, command_id)
	if not (agent_node is NavigationAgent3D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent3D" % agent_path, command_id)

	var body_node = null
	if body_path.is_empty():
		body_node = agent_node.get_parent()
	else:
		body_node = _get_editor_node(body_path)
	if not body_node:
		var resolved_body_path = body_path if not body_path.is_empty() else "<agent_parent>"
		return _send_error(client_id, "CharacterBody3D not found: %s" % resolved_body_path, command_id)
	if not (body_node is CharacterBody3D):
		return _send_error(client_id, "Body node at %s is not a CharacterBody3D" % _to_mcp_path(body_node), command_id)

	var agent: NavigationAgent3D = agent_node
	var body: CharacterBody3D = body_node
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var speed_default = body.get_meta("mcp_enemy_movement_speed") if body.has_meta("mcp_enemy_movement_speed") else (
		body.get_meta("mcp_3d_speed") if body.has_meta("mcp_3d_speed") else agent.max_speed
	)
	var speed: float = float(params.get("speed", speed_default))
	var acceleration_default = body.get_meta("mcp_enemy_acceleration") if body.has_meta("mcp_enemy_acceleration") else speed * 8.0
	var acceleration: float = float(params.get("acceleration", acceleration_default))
	var deceleration: float = float(params.get("deceleration", speed * 10.0))
	var stop_distance: float = max(0.0, float(params.get("stop_distance", agent.path_desired_distance)))
	var planar_only: bool = bool(params.get("planar_only", true))
	var preserve_vertical_velocity: bool = bool(params.get("preserve_vertical_velocity", true))
	var yaw_to_direction: bool = bool(params.get("yaw_to_direction", false))
	var update_agent_velocity: bool = bool(params.get("update_agent_velocity", true))
	var sync_agent_to_body: bool = bool(params.get("sync_agent_to_body", true))
	var stop_on_navigation_finished: bool = bool(params.get("stop_on_navigation_finished", true))
	var allow_direct_fallback: bool = bool(params.get("allow_direct_fallback", true))

	var next_path_position: Vector3 = agent.get_next_path_position()
	var to_next: Vector3 = next_path_position - body.global_position
	if planar_only:
		to_next.y = 0.0
	var distance_to_next: float = to_next.length()
	var to_target: Vector3 = agent.target_position - body.global_position
	if planar_only:
		to_target.y = 0.0
	var distance_to_target: float = to_target.length()
	var navigation_finished: bool = agent.is_navigation_finished()

	var direction := Vector3.ZERO
	if distance_to_next > stop_distance and (not stop_on_navigation_finished or not navigation_finished):
		direction = to_next / distance_to_next
	elif allow_direct_fallback and distance_to_target > stop_distance:
		direction = to_target / distance_to_target

	var target_velocity: Vector3 = direction * speed
	var interpolation: float = (acceleration if direction.length() > 0.001 else deceleration) * delta
	var current_velocity: Vector3 = body.velocity
	var new_velocity: Vector3
	if planar_only:
		var current_horizontal := Vector3(current_velocity.x, 0.0, current_velocity.z)
		var target_horizontal := Vector3(target_velocity.x, 0.0, target_velocity.z)
		var next_horizontal := current_horizontal.move_toward(target_horizontal, interpolation)
		var next_vertical := current_velocity.y if preserve_vertical_velocity else move_toward(current_velocity.y, target_velocity.y, interpolation)
		new_velocity = Vector3(next_horizontal.x, next_vertical, next_horizontal.z)
	else:
		new_velocity = current_velocity.move_toward(target_velocity, interpolation)

	var new_global_position: Vector3 = body.global_position + new_velocity * delta
	var pending_changes: Array = []
	pending_changes.append_array(_capture_property_change(body, "velocity", new_velocity))
	pending_changes.append_array(_capture_property_change(body, "global_position", new_global_position))

	var horizontal_direction := Vector2(direction.x, direction.z)
	if yaw_to_direction and horizontal_direction.length() > 0.001:
		pending_changes.append_array(_capture_property_change(body, "rotation", Vector3(body.rotation.x, atan2(direction.x, direction.z), body.rotation.z)))
	if update_agent_velocity:
		pending_changes.append_array(_capture_property_change(agent, "velocity", new_velocity))
	if sync_agent_to_body:
		if agent.get_parent() == body:
			pending_changes.append_array(_capture_property_change(agent, "position", Vector3.ZERO))
		else:
			pending_changes.append_array(_capture_property_change(agent, "global_position", new_global_position))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"agent_path": _to_mcp_path(agent),
			"body_path": _to_mcp_path(body),
			"status": "no_change",
			"position": _vector3_to_dict(body.global_position),
			"velocity": _vector3_to_dict(body.velocity),
			"next_path_position": _vector3_to_dict(next_path_position),
			"distance_to_next": distance_to_next,
			"distance_to_target": distance_to_target,
			"navigation_finished": navigation_finished,
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_navigation_chase_step_3d",
		"agent_path": agent_path,
		"body_path": _to_mcp_path(body),
		"delta": delta,
		"speed": speed,
		"acceleration": acceleration,
		"deceleration": deceleration,
		"stop_distance": stop_distance,
		"navigation_finished": navigation_finished,
		"allow_direct_fallback": allow_direct_fallback,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Navigation Chase Step 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Navigation Chase Step 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 3D navigation chase simulation", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		var change_target: Object = change.get("target", body)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated navigation chase step 3D", "_simulate_navigation_chase_step_3d", {
			"agent_path": _to_mcp_path(agent),
			"body_path": _to_mcp_path(body),
			"position": _vector3_to_dict(body.global_position),
			"velocity": _vector3_to_dict(body.velocity),
			"next_path_position": _vector3_to_dict(next_path_position),
			"distance_to_next": distance_to_next,
			"distance_to_target": distance_to_target,
			"navigation_finished": navigation_finished,
			"change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_3d",
			"line_num": 0,
		})
	)

	var response := {
		"agent_path": _to_mcp_path(agent),
		"body_path": _to_mcp_path(body),
		"next_path_position": _vector3_to_dict(next_path_position),
		"distance_to_next": distance_to_next,
		"distance_to_target": distance_to_target,
		"navigation_finished": navigation_finished,
		"position": _vector3_to_dict(new_global_position),
		"velocity": _vector3_to_dict(new_velocity),
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 3D navigation chase simulation", command_id)
		response["position"] = _vector3_to_dict(body.global_position)
		response["velocity"] = _vector3_to_dict(body.velocity)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_navigation_target_to_node_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var agent_path: String = params.get("agent_path", "")
	var target_path: String = params.get("target_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if agent_path.is_empty():
		return _send_error(client_id, "agent_path cannot be empty", command_id)
	if target_path.is_empty():
		return _send_error(client_id, "target_path cannot be empty", command_id)

	var agent_node = _get_editor_node(agent_path)
	if not agent_node:
		return _send_error(client_id, "Navigation agent not found: %s" % agent_path, command_id)
	if not (agent_node is NavigationAgent2D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent2D" % agent_path, command_id)

	var target_node = _get_editor_node(target_path)
	if not target_node:
		return _send_error(client_id, "Target node not found: %s" % target_path, command_id)
	if not (target_node is Node2D):
		return _send_error(client_id, "Target node at %s must inherit Node2D" % target_path, command_id)

	var offset := _parse_vector2_param(params.get("offset", Vector2.ZERO))
	var target_position: Vector2 = (target_node as Node2D).global_position + offset
	var remember_target: bool = bool(params.get("remember_target", true))

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	pending_property_changes.append_array(_capture_property_change(agent_node, "target_position", target_position))
	if remember_target:
		pending_meta_changes.append_array(_capture_meta_change(agent_node, "mcp_target_node_path_2d", _to_mcp_path(target_node)))
		pending_meta_changes.append_array(_capture_meta_change(agent_node, "mcp_target_offset_2d", _vector2_to_dict(offset)))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"agent_path": _to_mcp_path(agent_node),
			"target_path": _to_mcp_path(target_node),
			"target_position": _vector2_to_dict(target_position),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "set_navigation_target_to_node_2d",
		"agent_path": agent_path,
		"target_path": target_path,
		"target_position": _vector2_to_dict(target_position),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set Navigation Target To Node 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set Navigation Target To Node 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D navigation targeting", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		transaction.add_do_property(agent_node, change.property, change.value)
		transaction.add_undo_property(agent_node, change.property, change.previous)
		serialized_property_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(agent_node, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(agent_node, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(agent_node, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Set NavigationAgent2D target from node", "_set_navigation_target_to_node_2d", {
			"agent_path": _to_mcp_path(agent_node),
			"target_path": _to_mcp_path(target_node),
			"target_position": _vector2_to_dict((agent_node as NavigationAgent2D).target_position),
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_2d",
			"line_num": 0,
		})
	)

	var response := {
		"agent_path": _to_mcp_path(agent_node),
		"target_path": _to_mcp_path(target_node),
		"target_position": _vector2_to_dict(target_position),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D navigation targeting", command_id)
		response["target_position"] = _vector2_to_dict((agent_node as NavigationAgent2D).target_position)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_navigation_target_to_node_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var agent_path: String = params.get("agent_path", "")
	var target_path: String = params.get("target_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if agent_path.is_empty():
		return _send_error(client_id, "agent_path cannot be empty", command_id)
	if target_path.is_empty():
		return _send_error(client_id, "target_path cannot be empty", command_id)

	var agent_node = _get_editor_node(agent_path)
	if not agent_node:
		return _send_error(client_id, "Navigation agent not found: %s" % agent_path, command_id)
	if not (agent_node is NavigationAgent3D):
		return _send_error(client_id, "Node at %s is not a NavigationAgent3D" % agent_path, command_id)

	var target_node = _get_editor_node(target_path)
	if not target_node:
		return _send_error(client_id, "Target node not found: %s" % target_path, command_id)
	if not (target_node is Node3D):
		return _send_error(client_id, "Target node at %s must inherit Node3D" % target_path, command_id)

	var offset := _parse_vector3_param(params.get("offset", Vector3.ZERO))
	var target_position: Vector3 = (target_node as Node3D).global_position + offset
	var remember_target: bool = bool(params.get("remember_target", true))

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	pending_property_changes.append_array(_capture_property_change(agent_node, "target_position", target_position))
	if remember_target:
		pending_meta_changes.append_array(_capture_meta_change(agent_node, "mcp_target_node_path_3d", _to_mcp_path(target_node)))
		pending_meta_changes.append_array(_capture_meta_change(agent_node, "mcp_target_offset_3d", _vector3_to_dict(offset)))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"agent_path": _to_mcp_path(agent_node),
			"target_path": _to_mcp_path(target_node),
			"target_position": _vector3_to_dict(target_position),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "set_navigation_target_to_node_3d",
		"agent_path": agent_path,
		"target_path": target_path,
		"target_position": _vector3_to_dict(target_position),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set Navigation Target To Node 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set Navigation Target To Node 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 3D navigation targeting", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		transaction.add_do_property(agent_node, change.property, change.value)
		transaction.add_undo_property(agent_node, change.property, change.previous)
		serialized_property_changes.append({
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(agent_node, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(agent_node, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(agent_node, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Set NavigationAgent3D target from node", "_set_navigation_target_to_node_3d", {
			"agent_path": _to_mcp_path(agent_node),
			"target_path": _to_mcp_path(target_node),
			"target_position": _vector3_to_dict((agent_node as NavigationAgent3D).target_position),
			"transaction_id": transaction.transaction_id,
			"system_section": "navigation_3d",
			"line_num": 0,
		})
	)

	var response := {
		"agent_path": _to_mcp_path(agent_node),
		"target_path": _to_mcp_path(target_node),
		"target_position": _vector3_to_dict(target_position),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 3D navigation targeting", command_id)
		response["target_position"] = _vector3_to_dict((agent_node as NavigationAgent3D).target_position)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_light_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = String(params.get("node_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if node_path.is_empty():
		return _send_error(client_id, "node_path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if node == null:
		return _send_error(client_id, "Light node not found: %s" % node_path, command_id)
	if not (node is Light2D or node is Light3D):
		return _send_error(client_id, "Node at %s must inherit Light2D or Light3D" % node_path, command_id)

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []

	if params.has("enabled"):
		var enabled_value: bool = bool(params.get("enabled"))
		if node is Light3D:
			pending_property_changes.append_array(_capture_property_change(node, "light_enabled", enabled_value))
		else:
			pending_property_changes.append_array(_capture_property_change(node, "enabled", enabled_value))

	if params.has("color"):
		var parsed_color = _coerce_color(params.get("color"))
		if parsed_color == null:
			return _send_error(client_id, "color must be a valid Color-compatible value", command_id)
		if node is Light3D:
			pending_property_changes.append_array(_capture_property_change(node, "light_color", parsed_color))
		else:
			pending_property_changes.append_array(_capture_property_change(node, "color", parsed_color))

	if node is Light2D:
		var light2d_float_map := {
			"energy": "energy",
			"texture_scale": "texture_scale",
			"height": "height",
			"shadow_filter_smooth": "shadow_filter_smooth",
		}
		for param_key in light2d_float_map.keys():
			if params.has(param_key):
				pending_property_changes.append_array(_capture_property_change(node, String(light2d_float_map[param_key]), float(params.get(param_key))))

		var light2d_int_map := {
			"blend_mode": "blend_mode",
			"range_item_cull_mask": "range_item_cull_mask",
			"range_layer_min": "range_layer_min",
			"range_layer_max": "range_layer_max",
			"range_z_min": "range_z_min",
			"range_z_max": "range_z_max",
			"shadow_filter": "shadow_filter",
		}
		for int_key in light2d_int_map.keys():
			if params.has(int_key):
				pending_property_changes.append_array(_capture_property_change(node, String(light2d_int_map[int_key]), int(params.get(int_key))))

		if params.has("shadow_enabled"):
			pending_property_changes.append_array(_capture_property_change(node, "shadow_enabled", bool(params.get("shadow_enabled"))))
		if params.has("shadow_color"):
			var shadow_color = _coerce_color(params.get("shadow_color"))
			if shadow_color == null:
				return _send_error(client_id, "shadow_color must be a valid Color-compatible value", command_id)
			pending_property_changes.append_array(_capture_property_change(node, "shadow_color", shadow_color))
	else:
		var light3d_float_map := {
			"energy": "light_energy",
			"indirect_energy": "light_indirect_energy",
			"volumetric_fog_energy": "light_volumetric_fog_energy",
			"specular": "light_specular",
			"temperature": "light_temperature",
			"shadow_blur": "shadow_blur",
			"shadow_bias": "shadow_bias",
			"shadow_normal_bias": "shadow_normal_bias",
			"distance_fade_begin": "distance_fade_begin",
			"distance_fade_length": "distance_fade_length",
			"distance_fade_shadow": "distance_fade_shadow",
			"omni_range": "omni_range",
			"omni_attenuation": "omni_attenuation",
			"spot_range": "spot_range",
			"spot_attenuation": "spot_attenuation",
			"spot_angle": "spot_angle",
			"spot_angle_attenuation": "spot_angle_attenuation",
		}
		for float_key in light3d_float_map.keys():
			if params.has(float_key):
				pending_property_changes.append_array(_capture_property_change(node, String(light3d_float_map[float_key]), float(params.get(float_key))))

		if params.has("shadow_enabled"):
			pending_property_changes.append_array(_capture_property_change(node, "shadow_enabled", bool(params.get("shadow_enabled"))))
		if params.has("distance_fade_enabled"):
			pending_property_changes.append_array(_capture_property_change(node, "distance_fade_enabled", bool(params.get("distance_fade_enabled"))))
		if params.has("cull_mask"):
			pending_property_changes.append_array(_capture_property_change(node, "cull_mask", int(params.get("cull_mask"))))
		if params.has("projector_path"):
			var projector_path: String = String(params.get("projector_path", "")).strip_edges()
			if projector_path.is_empty():
				pending_property_changes.append_array(_capture_property_change(node, "light_projector", null))
			else:
				var projector_resource = ResourceLoader.load(projector_path)
				if projector_resource == null or not (projector_resource is Texture2D):
					return _send_error(client_id, "projector_path must point to a Texture2D resource", command_id)
				pending_property_changes.append_array(_capture_property_change(node, "light_projector", projector_resource))

	var profile_name: String = String(params.get("profile_name", "")).strip_edges()
	if not profile_name.is_empty():
		pending_meta_changes.append_array(_capture_meta_change(node, "mcp_light_profile_name", profile_name))
	pending_meta_changes.append_array(_capture_meta_change(node, "mcp_light_last_config_command", "configure_light_node"))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(node),
			"light_type": node.get_class(),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_light_node",
		"node_path": _to_mcp_path(node),
		"light_type": node.get_class(),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Light Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Light Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for light configuration", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", node)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(node, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(node, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(node, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(node),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured light node", "_configure_light_node", {
			"node_path": _to_mcp_path(node),
			"light_type": node.get_class(),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "lighting",
			"line_num": 0,
		})
	)

	var result_color = node.get("color") if node is Light2D else node.get("light_color")
	var result_energy = node.get("energy") if node is Light2D else node.get("light_energy")
	var result_enabled = node.get("enabled") if node is Light2D else node.get("light_enabled")
	var response := {
		"node_path": _to_mcp_path(node),
		"light_type": node.get_class(),
		"enabled": result_enabled,
		"color": _mcp_color_to_dict(result_color) if result_color is Color else {},
		"energy": float(result_energy) if result_energy != null else 0.0,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit light configuration", command_id)
		var committed_color = node.get("color") if node is Light2D else node.get("light_color")
		var committed_energy = node.get("energy") if node is Light2D else node.get("light_energy")
		var committed_enabled = node.get("enabled") if node is Light2D else node.get("light_enabled")
		response["enabled"] = committed_enabled
		response["color"] = _mcp_color_to_dict(committed_color) if committed_color is Color else {}
		response["energy"] = float(committed_energy) if committed_energy != null else 0.0
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_smoke_effect_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var smoke_name: String = String(params.get("smoke_name", "SmokeEffect2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))
	var area_size: Vector2 = _parse_vector2_param(params.get("area_size", Vector2(960.0, 540.0)))
	if area_size.x <= 0.0 or area_size.y <= 0.0:
		return _send_error(client_id, "area_size must be greater than zero on both axes", command_id)

	var intensity: float = clampf(float(params.get("intensity", 0.65)), 0.0, 1.0)
	var wind_direction: Vector2 = _parse_vector2_param(params.get("wind_direction", Vector2(1.0, -0.15)))
	if wind_direction.length_squared() <= 0.000001:
		wind_direction = Vector2(1.0, -0.15)
	wind_direction = wind_direction.normalized()
	var wind_strength: float = clampf(float(params.get("wind_strength", 0.35)), 0.0, 1.0)
	var max_particles: int = clampi(int(params.get("max_particles", 1600)), 0, 50000)
	var particle_lifetime: float = max(0.05, float(params.get("particle_lifetime", 3.8)))
	var rise_speed_min: float = max(0.0, float(params.get("rise_speed_min", 24.0)))
	var rise_speed_max: float = max(rise_speed_min, float(params.get("rise_speed_max", 92.0)))
	var spread_degrees: float = clampf(float(params.get("spread_degrees", 26.0)), 0.0, 180.0)
	var rise_acceleration: float = max(0.0, float(params.get("rise_acceleration", 64.0)))
	var damping_min: float = max(0.0, float(params.get("damping_min", 6.0)))
	var damping_max: float = max(damping_min, float(params.get("damping_max", 16.0)))
	var particle_scale_min: Vector2 = _parse_vector2_param(params.get("particle_scale_min", Vector2(1.3, 1.3)))
	var particle_scale_max: Vector2 = _parse_vector2_param(params.get("particle_scale_max", Vector2(3.8, 3.8)))
	particle_scale_min.x = max(0.01, particle_scale_min.x)
	particle_scale_min.y = max(0.01, particle_scale_min.y)
	particle_scale_max.x = max(particle_scale_min.x, particle_scale_max.x)
	particle_scale_max.y = max(particle_scale_min.y, particle_scale_max.y)
	var smoke_roundness: float = clampf(float(params.get("smoke_roundness", 0.62)), 0.0, 1.0)
	var smoke_softness: float = clampf(float(params.get("smoke_softness", 0.82)), 0.0, 1.0)
	var smoke_noise_strength: float = clampf(float(params.get("smoke_noise_strength", 0.46)), 0.0, 1.0)
	var smoke_noise_scale: float = max(0.01, float(params.get("smoke_noise_scale", 3.2)))
	var smoke_texture_size: int = clampi(int(params.get("smoke_texture_size", 64)), 16, 256)

	var smoke_color = _coerce_color(params.get("smoke_color", Color(0.66, 0.68, 0.72, 0.42)))
	if smoke_color == null:
		smoke_color = Color(0.66, 0.68, 0.72, 0.42)
	var create_overlay: bool = bool(params.get("create_overlay", true))
	var overlay_density: float = clampf(float(params.get("overlay_density", 0.18)), 0.0, 1.0)
	var overlay_color = _coerce_color(params.get("overlay_color", Color(0.57, 0.6, 0.64, 0.22)))
	if overlay_color == null:
		overlay_color = Color(0.57, 0.6, 0.64, 0.22)
	var canvas_layer_index: int = int(params.get("canvas_layer", 0))

	var particle_amount := int(round(float(max_particles) * intensity))
	var can_emit: bool = max_particles > 0 and particle_amount > 0

	if smoke_name.is_empty():
		smoke_name = "SmokeEffect2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var smoke_root := Node2D.new()
	smoke_root.name = _resolve_unique_child_name(parent, smoke_name)
	smoke_root.position = origin
	smoke_root.set_meta("mcp_smoke_type", "smoke_effect_2d")
	smoke_root.set_meta("mcp_smoke_source", "procedural_authoring")
	smoke_root.set_meta("mcp_smoke_seed", seed_value)
	smoke_root.set_meta("mcp_smoke_area_size", _vector2_to_dict(area_size))
	smoke_root.set_meta("mcp_smoke_intensity", intensity)
	smoke_root.set_meta("mcp_smoke_wind_direction", _vector2_to_dict(wind_direction))
	smoke_root.set_meta("mcp_smoke_wind_strength", wind_strength)
	smoke_root.set_meta("mcp_smoke_max_particles", max_particles)
	smoke_root.set_meta("mcp_smoke_particle_lifetime", particle_lifetime)
	smoke_root.set_meta("mcp_smoke_rise_speed_min", rise_speed_min)
	smoke_root.set_meta("mcp_smoke_rise_speed_max", rise_speed_max)
	smoke_root.set_meta("mcp_smoke_spread_degrees", spread_degrees)
	smoke_root.set_meta("mcp_smoke_rise_acceleration", rise_acceleration)
	smoke_root.set_meta("mcp_smoke_particle_scale_min", _vector2_to_dict(particle_scale_min))
	smoke_root.set_meta("mcp_smoke_particle_scale_max", _vector2_to_dict(particle_scale_max))
	smoke_root.set_meta("mcp_smoke_roundness", smoke_roundness)
	smoke_root.set_meta("mcp_smoke_softness", smoke_softness)
	smoke_root.set_meta("mcp_smoke_noise_strength", smoke_noise_strength)
	smoke_root.set_meta("mcp_smoke_noise_scale", smoke_noise_scale)
	smoke_root.set_meta("mcp_smoke_texture_size", smoke_texture_size)
	smoke_root.set_meta("mcp_smoke_create_overlay", create_overlay)
	smoke_root.set_meta("mcp_smoke_overlay_density", overlay_density)

	var created_nodes: Array = [smoke_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_smoke_path: String = _join_mcp_path(parent_mcp_path, smoke_root.name)
	var predicted_paths := {
		"smoke_path": predicted_smoke_path,
	}

	var smoke_particles := GPUParticles2D.new()
	smoke_particles.name = _resolve_unique_child_name(smoke_root, "SmokeParticles")
	smoke_particles.position = Vector2(area_size.x * 0.5, area_size.y + 24.0)
	smoke_particles.one_shot = false
	smoke_particles.local_coords = false
	smoke_particles.fixed_fps = int(params.get("particle_fixed_fps", 24))
	smoke_particles.lifetime = particle_lifetime
	smoke_particles.amount = max(1, particle_amount)
	smoke_particles.preprocess = clampf(particle_lifetime * 0.45, 0.0, particle_lifetime)
	smoke_particles.visibility_rect = Rect2(-area_size.x * 0.7, -area_size.y * 1.2, area_size.x * 1.4, area_size.y * 2.0)
	var smoke_material := ParticleProcessMaterial.new()
	_mcp_configure_smoke_particle_material_2d(
		smoke_material,
		area_size,
		smoke_color,
		wind_direction,
		wind_strength,
		rise_speed_min,
		rise_speed_max,
		spread_degrees,
		particle_scale_min,
		particle_scale_max,
		rise_acceleration,
		damping_min,
		damping_max
	)
	smoke_particles.process_material = smoke_material
	smoke_particles.texture = _mcp_make_smoke_particle_texture_2d(
		smoke_texture_size,
		smoke_roundness,
		smoke_softness,
		smoke_noise_strength,
		smoke_noise_scale,
		seed_value
	)
	smoke_particles.emitting = can_emit
	smoke_root.add_child(smoke_particles)
	created_nodes.append(smoke_particles)
	predicted_paths["smoke_particles_path"] = _join_mcp_path(predicted_smoke_path, smoke_particles.name)

	var overlay_layer = null
	var overlay_rect = null
	if create_overlay:
		overlay_layer = CanvasLayer.new()
		overlay_layer.name = _resolve_unique_child_name(smoke_root, "OverlayLayer")
		overlay_layer.layer = canvas_layer_index
		smoke_root.add_child(overlay_layer)
		created_nodes.append(overlay_layer)
		predicted_paths["overlay_layer_path"] = _join_mcp_path(predicted_smoke_path, overlay_layer.name)

		var overlay_root := Control.new()
		overlay_root.name = "Root"
		_configure_control_full_rect(overlay_root)
		overlay_layer.add_child(overlay_root)
		created_nodes.append(overlay_root)
		predicted_paths["overlay_root_path"] = _join_mcp_path(String(predicted_paths["overlay_layer_path"]), overlay_root.name)

		overlay_rect = ColorRect.new()
		overlay_rect.name = "SmokeOverlay"
		_configure_control_full_rect(overlay_rect)
		overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var overlay_tint: Color = overlay_color
		overlay_tint.a = clampf(overlay_density * intensity, 0.0, 0.92)
		overlay_rect.color = _convert_property_value(overlay_rect, "color", overlay_tint)
		overlay_root.add_child(overlay_rect)
		created_nodes.append(overlay_rect)
		predicted_paths["overlay_rect_path"] = _join_mcp_path(String(predicted_paths["overlay_root_path"]), overlay_rect.name)

	smoke_root.set_meta("mcp_smoke_particles_node_name", smoke_particles.name)
	smoke_root.set_meta("mcp_smoke_overlay_layer_name", overlay_layer.name if overlay_layer else "")
	smoke_root.set_meta("mcp_smoke_overlay_rect_name", overlay_rect.name if overlay_rect else "")

	var transaction_metadata := {
		"command": "build_smoke_effect_2d",
		"parent_path": parent_mcp_path,
		"smoke_name": smoke_root.name,
		"intensity": intensity,
		"max_particles": max_particles,
		"particle_amount": particle_amount,
		"can_emit": can_emit,
		"create_overlay": create_overlay,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Smoke Effect 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Smoke Effect 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for smoke generation", command_id)

	transaction.add_do_method(parent, "add_child", [smoke_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [smoke_root])
	transaction.add_undo_method(smoke_root, "queue_free")
	transaction.add_do_reference(smoke_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built smoke effect 2D", "_build_smoke_effect_2d", {
			"smoke_path": _to_mcp_path(smoke_root),
			"parent_path": parent_mcp_path,
			"intensity": intensity,
			"max_particles": max_particles,
			"particle_amount": particle_amount,
			"can_emit": can_emit,
			"transaction_id": transaction.transaction_id,
			"system_section": "smoke_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"smoke_name": smoke_root.name,
		"smoke_path": predicted_paths.get("smoke_path", ""),
		"origin": _vector2_to_dict(origin),
		"area_size": _vector2_to_dict(area_size),
		"intensity": intensity,
		"wind_direction": _vector2_to_dict(wind_direction),
		"wind_strength": wind_strength,
		"max_particles": max_particles,
		"particle_amount": particle_amount,
		"can_emit": can_emit,
		"smoke_roundness": smoke_roundness,
		"smoke_softness": smoke_softness,
		"smoke_noise_strength": smoke_noise_strength,
		"smoke_noise_scale": smoke_noise_scale,
		"smoke_texture_size": smoke_texture_size,
		"create_overlay": create_overlay,
		"seed": seed_value,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit smoke generation", command_id)
		var committed_paths := {
			"smoke_path": _to_mcp_path(smoke_root),
			"smoke_particles_path": _to_mcp_path(smoke_particles),
		}
		if overlay_layer:
			committed_paths["overlay_layer_path"] = _to_mcp_path(overlay_layer)
		if overlay_rect:
			committed_paths["overlay_rect_path"] = _to_mcp_path(overlay_rect)
		response["smoke_path"] = _to_mcp_path(smoke_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _configure_particles_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = String(params.get("node_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if node_path.is_empty():
		return _send_error(client_id, "node_path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if node == null:
		return _send_error(client_id, "Particles node not found: %s" % node_path, command_id)
	if not (node is GPUParticles3D):
		return _send_error(client_id, "Node at %s must inherit GPUParticles3D" % node_path, command_id)

	var particles: GPUParticles3D = node
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []

	var particles_float_map := {
		"amount_ratio": "amount_ratio",
		"lifetime": "lifetime",
		"preprocess": "preprocess",
		"speed_scale": "speed_scale",
		"explosiveness": "explosiveness",
		"randomness": "randomness",
		"interp_to_end": "interp_to_end",
		"trail_lifetime": "trail_lifetime",
	}
	for float_key in particles_float_map.keys():
		if params.has(float_key):
			pending_property_changes.append_array(_capture_property_change(particles, String(particles_float_map[float_key]), float(params.get(float_key))))

	var particles_int_map := {
		"amount": "amount",
		"fixed_fps": "fixed_fps",
		"draw_order": "draw_order",
	}
	for int_key in particles_int_map.keys():
		if params.has(int_key):
			pending_property_changes.append_array(_capture_property_change(particles, String(particles_int_map[int_key]), int(params.get(int_key))))

	if params.has("emitting"):
		pending_property_changes.append_array(_capture_property_change(particles, "emitting", bool(params.get("emitting"))))
	if params.has("one_shot"):
		pending_property_changes.append_array(_capture_property_change(particles, "one_shot", bool(params.get("one_shot"))))
	if params.has("local_coords"):
		pending_property_changes.append_array(_capture_property_change(particles, "local_coords", bool(params.get("local_coords"))))
	if params.has("trail_enabled"):
		pending_property_changes.append_array(_capture_property_change(particles, "trail_enabled", bool(params.get("trail_enabled"))))

	if params.has("visibility_aabb"):
		var aabb_value = params.get("visibility_aabb")
		var parsed_aabb := AABB(Vector3(-4.0, -1.0, -4.0), Vector3(8.0, 12.0, 8.0))
		var parsed_ok := false
		if aabb_value is AABB:
			parsed_aabb = aabb_value
			parsed_ok = true
		elif typeof(aabb_value) == TYPE_DICTIONARY:
			var aabb_dict: Dictionary = aabb_value
			if aabb_dict.has("position") and aabb_dict.has("size"):
				parsed_aabb = AABB(
					_parse_vector3_param(aabb_dict.get("position", Vector3.ZERO)),
					_parse_vector3_param(aabb_dict.get("size", Vector3.ONE))
				)
				parsed_ok = true
			elif aabb_dict.has("x") and aabb_dict.has("y") and aabb_dict.has("z") and aabb_dict.has("width") and aabb_dict.has("height") and aabb_dict.has("depth"):
				parsed_aabb = AABB(
					Vector3(
						float(aabb_dict.get("x", 0.0)),
						float(aabb_dict.get("y", 0.0)),
						float(aabb_dict.get("z", 0.0))
					),
					Vector3(
						float(aabb_dict.get("width", 0.0)),
						float(aabb_dict.get("height", 0.0)),
						float(aabb_dict.get("depth", 0.0))
					)
				)
				parsed_ok = true
		if not parsed_ok:
			return _send_error(client_id, "visibility_aabb must be AABB-compatible", command_id)
		pending_property_changes.append_array(_capture_property_change(particles, "visibility_aabb", parsed_aabb))

	if params.has("draw_pass_1_path"):
		var mesh_path: String = String(params.get("draw_pass_1_path", "")).strip_edges()
		if mesh_path.is_empty():
			pending_property_changes.append_array(_capture_property_change(particles, "draw_pass_1", null))
		else:
			var mesh_resource = ResourceLoader.load(mesh_path)
			if mesh_resource == null or not (mesh_resource is Mesh):
				return _send_error(client_id, "draw_pass_1_path must point to a Mesh resource", command_id)
			pending_property_changes.append_array(_capture_property_change(particles, "draw_pass_1", mesh_resource))

	var ensure_process_material: bool = bool(params.get("ensure_process_material", true))
	var has_process_override := false
	for key_name in [
		"direction",
		"spread",
		"gravity",
		"initial_velocity_min",
		"initial_velocity_max",
		"angular_velocity_min",
		"angular_velocity_max",
		"damping_min",
		"damping_max",
		"scale_min",
		"scale_max",
		"color",
		"emission_shape",
		"emission_box_extents",
		"color_ramp_path",
	]:
		if params.has(key_name):
			has_process_override = true
			break

	var process_material = particles.process_material
	if has_process_override and process_material == null and ensure_process_material:
		var new_material := ParticleProcessMaterial.new()
		pending_property_changes.append_array(_capture_property_change(particles, "process_material", new_material))
		process_material = new_material

	if has_process_override and process_material != null and not (process_material is ParticleProcessMaterial):
		return _send_error(client_id, "process_material must be ParticleProcessMaterial to apply material overrides", command_id)

	if process_material != null and process_material is ParticleProcessMaterial:
		var particle_material: ParticleProcessMaterial = process_material
		var material_float_map := {
			"spread": "spread",
			"initial_velocity_min": "initial_velocity_min",
			"initial_velocity_max": "initial_velocity_max",
			"angular_velocity_min": "angular_velocity_min",
			"angular_velocity_max": "angular_velocity_max",
			"damping_min": "damping_min",
			"damping_max": "damping_max",
			"scale_min": "scale_min",
			"scale_max": "scale_max",
		}
		for float_key in material_float_map.keys():
			if params.has(float_key):
				pending_property_changes.append_array(_capture_property_change(particle_material, String(material_float_map[float_key]), float(params.get(float_key))))

		if params.has("direction"):
			pending_property_changes.append_array(_capture_property_change(particle_material, "direction", _parse_vector3_param(params.get("direction"))))
		if params.has("gravity"):
			pending_property_changes.append_array(_capture_property_change(particle_material, "gravity", _parse_vector3_param(params.get("gravity"))))
		if params.has("emission_shape"):
			pending_property_changes.append_array(_capture_property_change(particle_material, "emission_shape", int(params.get("emission_shape"))))
		if params.has("emission_box_extents"):
			pending_property_changes.append_array(_capture_property_change(particle_material, "emission_box_extents", _parse_vector3_param(params.get("emission_box_extents"))))
		if params.has("color"):
			var particles_color = _coerce_color(params.get("color"))
			if particles_color == null:
				return _send_error(client_id, "color must be a valid Color-compatible value", command_id)
			pending_property_changes.append_array(_capture_property_change(particle_material, "color", particles_color))
		if params.has("color_ramp_path"):
			var ramp_path: String = String(params.get("color_ramp_path", "")).strip_edges()
			if ramp_path.is_empty():
				pending_property_changes.append_array(_capture_property_change(particle_material, "color_ramp", null))
			else:
				var ramp_resource = ResourceLoader.load(ramp_path)
				if ramp_resource == null or not (ramp_resource is Texture2D):
					return _send_error(client_id, "color_ramp_path must point to a Texture2D resource", command_id)
				pending_property_changes.append_array(_capture_property_change(particle_material, "color_ramp", ramp_resource))

	var profile_name: String = String(params.get("profile_name", "")).strip_edges()
	if not profile_name.is_empty():
		pending_meta_changes.append_array(_capture_meta_change(particles, "mcp_particles_profile_name", profile_name))
	pending_meta_changes.append_array(_capture_meta_change(particles, "mcp_particles_last_config_command", "configure_particles_3d"))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"node_path": _to_mcp_path(particles),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "configure_particles_3d",
		"node_path": _to_mcp_path(particles),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Particles 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Particles 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for particles configuration", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", particles)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(particles, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(particles, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(particles, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(particles),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured particles 3D", "_configure_particles_3d", {
			"node_path": _to_mcp_path(particles),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "particles_3d",
			"line_num": 0,
		})
	)

	var response := {
		"node_path": _to_mcp_path(particles),
		"emitting": particles.emitting,
		"amount": particles.amount,
		"lifetime": particles.lifetime,
		"has_process_material": particles.process_material != null,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit particles configuration", command_id)
		response["emitting"] = particles.emitting
		response["amount"] = particles.amount
		response["lifetime"] = particles.lifetime
		response["has_process_material"] = particles.process_material != null
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_smoke_effect_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var smoke_name: String = String(params.get("smoke_name", "SmokeEffect3D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var position: Vector3 = _parse_vector3_param(params.get("position", Vector3.ZERO))
	var volume_size: Vector3 = _parse_vector3_param(params.get("volume_size", Vector3(8.0, 5.0, 8.0)))
	if volume_size.x <= 0.0 or volume_size.y <= 0.0 or volume_size.z <= 0.0:
		return _send_error(client_id, "volume_size must be greater than zero on all axes", command_id)

	var intensity: float = clampf(float(params.get("intensity", 0.68)), 0.0, 1.0)
	var wind_direction: Vector3 = _parse_vector3_param(params.get("wind_direction", Vector3(1.0, 0.0, 0.3)))
	wind_direction.y = 0.0
	if wind_direction.length_squared() <= 0.000001:
		wind_direction = Vector3(1.0, 0.0, 0.3)
	wind_direction = wind_direction.normalized()
	var wind_strength: float = clampf(float(params.get("wind_strength", 0.34)), 0.0, 1.0)
	var max_particles: int = clampi(int(params.get("max_particles", 2200)), 0, 50000)
	var particle_lifetime: float = max(0.05, float(params.get("particle_lifetime", 5.2)))
	var rise_speed_min: float = max(0.0, float(params.get("rise_speed_min", 0.7)))
	var rise_speed_max: float = max(rise_speed_min, float(params.get("rise_speed_max", 2.2)))
	var spread_degrees: float = clampf(float(params.get("spread_degrees", 38.0)), 0.0, 180.0)
	var damping_min: float = max(0.0, float(params.get("damping_min", 0.8)))
	var damping_max: float = max(damping_min, float(params.get("damping_max", 2.6)))
	var smoke_roundness: float = clampf(float(params.get("smoke_roundness", 0.62)), 0.0, 1.0)
	var smoke_softness: float = clampf(float(params.get("smoke_softness", 0.82)), 0.0, 1.0)
	var smoke_noise_strength: float = clampf(float(params.get("smoke_noise_strength", 0.46)), 0.0, 1.0)
	var smoke_noise_scale: float = max(0.01, float(params.get("smoke_noise_scale", 3.2)))
	var smoke_texture_size: int = clampi(int(params.get("smoke_texture_size", 64)), 16, 256)
	var smoke_color = _coerce_color(params.get("smoke_color", Color(0.68, 0.7, 0.74, 0.45)))
	if smoke_color == null:
		smoke_color = Color(0.68, 0.7, 0.74, 0.45)
	var create_ground_haze: bool = bool(params.get("create_ground_haze", true))
	var haze_color = _coerce_color(params.get("haze_color", Color(0.42, 0.44, 0.47, 0.16)))
	if haze_color == null:
		haze_color = Color(0.42, 0.44, 0.47, 0.16)

	var particle_amount := int(round(float(max_particles) * intensity))
	var can_emit: bool = max_particles > 0 and particle_amount > 0

	if smoke_name.is_empty():
		smoke_name = "SmokeEffect3D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var smoke_root := Node3D.new()
	smoke_root.name = _resolve_unique_child_name(parent, smoke_name)
	smoke_root.position = position
	smoke_root.set_meta("mcp_smoke_type", "smoke_effect_3d")
	smoke_root.set_meta("mcp_smoke_source", "procedural_authoring")
	smoke_root.set_meta("mcp_smoke_seed", seed_value)
	smoke_root.set_meta("mcp_smoke_volume_size", _vector3_to_dict(volume_size))
	smoke_root.set_meta("mcp_smoke_intensity", intensity)
	smoke_root.set_meta("mcp_smoke_wind_direction", _vector3_to_dict(wind_direction))
	smoke_root.set_meta("mcp_smoke_wind_strength", wind_strength)
	smoke_root.set_meta("mcp_smoke_max_particles", max_particles)
	smoke_root.set_meta("mcp_smoke_particle_lifetime", particle_lifetime)
	smoke_root.set_meta("mcp_smoke_rise_speed_min", rise_speed_min)
	smoke_root.set_meta("mcp_smoke_rise_speed_max", rise_speed_max)
	smoke_root.set_meta("mcp_smoke_spread_degrees", spread_degrees)
	smoke_root.set_meta("mcp_smoke_roundness", smoke_roundness)
	smoke_root.set_meta("mcp_smoke_softness", smoke_softness)
	smoke_root.set_meta("mcp_smoke_noise_strength", smoke_noise_strength)
	smoke_root.set_meta("mcp_smoke_noise_scale", smoke_noise_scale)
	smoke_root.set_meta("mcp_smoke_texture_size", smoke_texture_size)

	var created_nodes: Array = [smoke_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_smoke_path: String = _join_mcp_path(parent_mcp_path, smoke_root.name)
	var predicted_paths := {
		"smoke_path": predicted_smoke_path,
	}

	var smoke_particles := GPUParticles3D.new()
	smoke_particles.name = _resolve_unique_child_name(smoke_root, "SmokeParticles3D")
	smoke_particles.one_shot = false
	smoke_particles.local_coords = false
	smoke_particles.fixed_fps = int(params.get("particle_fixed_fps", 30))
	smoke_particles.lifetime = particle_lifetime
	smoke_particles.amount = max(1, particle_amount)
	smoke_particles.preprocess = clampf(particle_lifetime * 0.45, 0.0, particle_lifetime)
	smoke_particles.visibility_aabb = AABB(
		Vector3(-volume_size.x * 0.7, -0.5, -volume_size.z * 0.7),
		Vector3(volume_size.x * 1.4, volume_size.y * 2.2 + 1.0, volume_size.z * 1.4)
	)
	smoke_particles.emitting = can_emit

	var smoke_material := ParticleProcessMaterial.new()
	_mcp_configure_smoke_particle_material_3d(
		smoke_material,
		volume_size,
		smoke_color,
		wind_direction,
		wind_strength,
		rise_speed_min,
		rise_speed_max,
		spread_degrees,
		damping_min,
		damping_max
	)
	smoke_particles.process_material = smoke_material
	var smoke_texture := _mcp_make_smoke_particle_texture_2d(
		smoke_texture_size,
		smoke_roundness,
		smoke_softness,
		smoke_noise_strength,
		smoke_noise_scale,
		seed_value + 137
	)

	var draw_mesh := QuadMesh.new()
	draw_mesh.size = Vector2(float(params.get("particle_quad_size", 0.9)), float(params.get("particle_quad_size", 0.9)))
	var quad_material := StandardMaterial3D.new()
	quad_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad_material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	quad_material.vertex_color_use_as_albedo = true
	quad_material.albedo_texture = smoke_texture
	draw_mesh.material = quad_material
	smoke_particles.draw_pass_1 = draw_mesh
	smoke_root.add_child(smoke_particles)
	created_nodes.append(smoke_particles)
	predicted_paths["smoke_particles_path"] = _join_mcp_path(predicted_smoke_path, smoke_particles.name)

	var haze_node = null
	if create_ground_haze:
		haze_node = MeshInstance3D.new()
		haze_node.name = _resolve_unique_child_name(smoke_root, "GroundHaze")
		var haze_mesh := QuadMesh.new()
		haze_mesh.size = Vector2(volume_size.x * 1.2, volume_size.z * 1.2)
		var haze_material := StandardMaterial3D.new()
		haze_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		haze_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		haze_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		haze_material.albedo_color = haze_color
		haze_mesh.material = haze_material
		haze_node.mesh = haze_mesh
		haze_node.position = Vector3(0.0, 0.02, 0.0)
		haze_node.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		smoke_root.add_child(haze_node)
		created_nodes.append(haze_node)
		predicted_paths["ground_haze_path"] = _join_mcp_path(predicted_smoke_path, haze_node.name)

	smoke_root.set_meta("mcp_smoke_particles_node_name", smoke_particles.name)
	smoke_root.set_meta("mcp_smoke_ground_haze_node_name", haze_node.name if haze_node else "")

	var transaction_metadata := {
		"command": "build_smoke_effect_3d",
		"parent_path": parent_mcp_path,
		"smoke_name": smoke_root.name,
		"intensity": intensity,
		"max_particles": max_particles,
		"particle_amount": particle_amount,
		"can_emit": can_emit,
		"create_ground_haze": create_ground_haze,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Smoke Effect 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Smoke Effect 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for smoke 3D generation", command_id)

	transaction.add_do_method(parent, "add_child", [smoke_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [smoke_root])
	transaction.add_undo_method(smoke_root, "queue_free")
	transaction.add_do_reference(smoke_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built smoke effect 3D", "_build_smoke_effect_3d", {
			"smoke_path": _to_mcp_path(smoke_root),
			"parent_path": parent_mcp_path,
			"intensity": intensity,
			"max_particles": max_particles,
			"particle_amount": particle_amount,
			"can_emit": can_emit,
			"transaction_id": transaction.transaction_id,
			"system_section": "smoke_3d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"smoke_name": smoke_root.name,
		"smoke_path": predicted_paths.get("smoke_path", ""),
		"position": _vector3_to_dict(position),
		"volume_size": _vector3_to_dict(volume_size),
		"intensity": intensity,
		"wind_direction": _vector3_to_dict(wind_direction),
		"wind_strength": wind_strength,
		"max_particles": max_particles,
		"particle_amount": particle_amount,
		"can_emit": can_emit,
		"smoke_roundness": smoke_roundness,
		"smoke_softness": smoke_softness,
		"smoke_noise_strength": smoke_noise_strength,
		"smoke_noise_scale": smoke_noise_scale,
		"smoke_texture_size": smoke_texture_size,
		"create_ground_haze": create_ground_haze,
		"seed": seed_value,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit smoke 3D generation", command_id)
		var committed_paths := {
			"smoke_path": _to_mcp_path(smoke_root),
			"smoke_particles_path": _to_mcp_path(smoke_particles),
		}
		if haze_node:
			committed_paths["ground_haze_path"] = _to_mcp_path(haze_node)
		response["smoke_path"] = _to_mcp_path(smoke_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_light_occluder_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var occluder_name: String = String(params.get("occluder_name", "LightOccluder2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var position: Vector2 = _parse_vector2_param(params.get("position", Vector2.ZERO))

	if occluder_name.is_empty():
		occluder_name = "LightOccluder2D"

	var polygon_points: PackedVector2Array = PackedVector2Array()
	if params.has("polygon_points"):
		var points_result := _parse_vector2_array_param(params.get("polygon_points"))
		if not points_result.get("ok", false):
			return _send_error(client_id, "polygon_points must be an array of Vector2-compatible entries", command_id)
		polygon_points = points_result.get("value", PackedVector2Array())
	else:
		var size: Vector2 = _parse_vector2_param(params.get("size", Vector2(320.0, 72.0)))
		size.x = max(1.0, size.x)
		size.y = max(1.0, size.y)
		var half := size * 0.5
		polygon_points = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y),
			Vector2(half.x, half.y),
			Vector2(-half.x, half.y),
		])
	if polygon_points.size() < 3:
		return _send_error(client_id, "polygon_points must contain at least 3 points", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var light_occluder := LightOccluder2D.new()
	light_occluder.name = _resolve_unique_child_name(parent, occluder_name)
	light_occluder.position = position
	if params.has("occluder_light_mask"):
		light_occluder.occluder_light_mask = int(params.get("occluder_light_mask"))
	if params.has("sdf_collision"):
		light_occluder.sdf_collision = bool(params.get("sdf_collision"))

	var occluder_polygon := OccluderPolygon2D.new()
	occluder_polygon.polygon = polygon_points
	occluder_polygon.closed = bool(params.get("closed", true))
	occluder_polygon.cull_mode = int(params.get("cull_mode", 0))
	light_occluder.occluder = occluder_polygon

	light_occluder.set_meta("mcp_light_occluder_source", "procedural_authoring")
	light_occluder.set_meta("mcp_light_occluder_point_count", polygon_points.size())

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_path: String = _join_mcp_path(parent_mcp_path, light_occluder.name)

	var transaction_metadata := {
		"command": "build_light_occluder_2d",
		"parent_path": parent_mcp_path,
		"occluder_name": light_occluder.name,
		"point_count": polygon_points.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Light Occluder 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Light Occluder 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for light occluder generation", command_id)

	transaction.add_do_method(parent, "add_child", [light_occluder])
	transaction.add_do_method(light_occluder, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [light_occluder])
	transaction.add_undo_method(light_occluder, "queue_free")
	transaction.add_do_reference(light_occluder)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built light occluder 2D", "_build_light_occluder_2d", {
			"occluder_path": _to_mcp_path(light_occluder),
			"point_count": polygon_points.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "lighting",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"occluder_name": light_occluder.name,
		"occluder_path": predicted_path,
		"position": _vector2_to_dict(position),
		"point_count": polygon_points.size(),
		"closed": occluder_polygon.closed,
		"cull_mode": occluder_polygon.cull_mode,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit light occluder generation", command_id)
		response["occluder_path"] = _to_mcp_path(light_occluder)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _edit_light_occluder_polygon_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var occluder_path: String = String(params.get("occluder_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if occluder_path.is_empty():
		return _send_error(client_id, "occluder_path cannot be empty", command_id)

	var node = _get_editor_node(occluder_path)
	if node == null:
		return _send_error(client_id, "LightOccluder2D not found: %s" % occluder_path, command_id)
	if not (node is LightOccluder2D):
		return _send_error(client_id, "Node at %s must inherit LightOccluder2D" % occluder_path, command_id)

	var occluder_node: LightOccluder2D = node
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	var polygon_resource := occluder_node.occluder

	if polygon_resource == null:
		polygon_resource = OccluderPolygon2D.new()
		pending_property_changes.append_array(_capture_property_change(occluder_node, "occluder", polygon_resource))

	if not (polygon_resource is OccluderPolygon2D):
		return _send_error(client_id, "LightOccluder2D.occluder must be an OccluderPolygon2D", command_id)

	var occluder_polygon: OccluderPolygon2D = polygon_resource
	var next_polygon: PackedVector2Array = occluder_polygon.polygon
	var polygon_modified := false

	if params.has("polygon_points"):
		var replace_result := _parse_vector2_array_param(params.get("polygon_points"))
		if not replace_result.get("ok", false):
			return _send_error(client_id, "polygon_points must be an array of Vector2-compatible entries", command_id)
		next_polygon = replace_result.get("value", PackedVector2Array())
		polygon_modified = true

	if params.has("append_points"):
		var append_result := _parse_vector2_array_param(params.get("append_points"))
		if not append_result.get("ok", false):
			return _send_error(client_id, "append_points must be an array of Vector2-compatible entries", command_id)
		if not polygon_modified:
			next_polygon = occluder_polygon.polygon
			polygon_modified = true
		var append_points: PackedVector2Array = append_result.get("value", PackedVector2Array())
		for point in append_points:
			next_polygon.append(point)

	if params.has("offset"):
		var offset_value: Vector2 = _parse_vector2_param(params.get("offset"))
		if not polygon_modified:
			next_polygon = occluder_polygon.polygon
			polygon_modified = true
		for idx in range(next_polygon.size()):
			next_polygon[idx] = next_polygon[idx] + offset_value

	if polygon_modified:
		if next_polygon.size() < 3:
			return _send_error(client_id, "Resulting polygon must contain at least 3 points", command_id)
		pending_property_changes.append_array(_capture_property_change(occluder_polygon, "polygon", next_polygon))

	if params.has("closed"):
		pending_property_changes.append_array(_capture_property_change(occluder_polygon, "closed", bool(params.get("closed"))))
	if params.has("cull_mode"):
		pending_property_changes.append_array(_capture_property_change(occluder_polygon, "cull_mode", int(params.get("cull_mode"))))

	var profile_name: String = String(params.get("profile_name", "")).strip_edges()
	if not profile_name.is_empty():
		pending_meta_changes.append_array(_capture_meta_change(occluder_node, "mcp_light_occluder_profile", profile_name))
	pending_meta_changes.append_array(_capture_meta_change(occluder_node, "mcp_light_occluder_last_edit_command", "edit_light_occluder_polygon_2d"))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"occluder_path": _to_mcp_path(occluder_node),
			"point_count": occluder_polygon.polygon.size(),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "edit_light_occluder_polygon_2d",
		"occluder_path": _to_mcp_path(occluder_node),
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Edit Light Occluder Polygon 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Edit Light Occluder Polygon 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for light occluder editing", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", occluder_node)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(occluder_node, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(occluder_node, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(occluder_node, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(occluder_node),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Edited light occluder polygon 2D", "_edit_light_occluder_polygon_2d", {
			"occluder_path": _to_mcp_path(occluder_node),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "lighting",
			"line_num": 0,
		})
	)

	var response := {
		"occluder_path": _to_mcp_path(occluder_node),
		"point_count": next_polygon.size() if polygon_modified else occluder_polygon.polygon.size(),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit light occluder edit", command_id)
		var committed_polygon: PackedVector2Array = (occluder_node.occluder as OccluderPolygon2D).polygon if occluder_node.occluder else PackedVector2Array()
		response["point_count"] = committed_polygon.size()
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_subviewport_minimap(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var minimap_name: String = String(params.get("minimap_name", "MiniMap")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if minimap_name.is_empty():
		minimap_name = "MiniMap"

	var panel_size: Vector2 = _parse_vector2_param(params.get("size", Vector2(256.0, 256.0)))
	panel_size.x = max(64.0, panel_size.x)
	panel_size.y = max(64.0, panel_size.y)
	var panel_size_i := Vector2i(int(round(panel_size.x)), int(round(panel_size.y)))
	var margin: float = max(0.0, float(params.get("margin", 16.0)))
	var anchor_mode: String = String(params.get("anchor", "top_right")).strip_edges().to_lower()
	if anchor_mode != "top_left" and anchor_mode != "top_right" and anchor_mode != "bottom_left" and anchor_mode != "bottom_right":
		return _send_error(client_id, "anchor must be one of top_left, top_right, bottom_left, bottom_right", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var target_path: String = String(params.get("target_path", "")).strip_edges()
	var target_node = _get_editor_node(target_path) if not target_path.is_empty() else null

	var requested_mode: String = String(params.get("mode", "auto")).strip_edges().to_lower()
	var resolved_mode: String = requested_mode
	if resolved_mode == "auto":
		if target_node and target_node is Node3D:
			resolved_mode = "topdown3d"
		elif target_node and target_node is Node2D:
			resolved_mode = "2d"
		elif edited_scene_root is Node3D:
			resolved_mode = "topdown3d"
		else:
			resolved_mode = "2d"
	if resolved_mode != "2d" and resolved_mode != "topdown3d" and resolved_mode != "isometric3d":
		return _send_error(client_id, "mode must be auto, 2d, topdown3d, or isometric3d", command_id)

	var minimap_root := CanvasLayer.new()
	minimap_root.name = _resolve_unique_child_name(parent, minimap_name)
	minimap_root.layer = int(params.get("canvas_layer", 50))
	minimap_root.set_meta("mcp_minimap_mode", resolved_mode)
	minimap_root.set_meta("mcp_minimap_target_path", _to_mcp_path(target_node) if target_node else "")

	var ui_root := Control.new()
	ui_root.name = "Root"
	_configure_control_full_rect(ui_root)
	minimap_root.add_child(ui_root)

	var frame := PanelContainer.new()
	frame.name = "Frame"
	frame.custom_minimum_size = panel_size
	frame.anchor_left = 0.0
	frame.anchor_right = 0.0
	frame.anchor_top = 0.0
	frame.anchor_bottom = 0.0
	match anchor_mode:
		"top_left":
			frame.anchor_left = 0.0
			frame.anchor_right = 0.0
			frame.anchor_top = 0.0
			frame.anchor_bottom = 0.0
			frame.offset_left = margin
			frame.offset_top = margin
			frame.offset_right = margin + panel_size.x
			frame.offset_bottom = margin + panel_size.y
		"bottom_left":
			frame.anchor_left = 0.0
			frame.anchor_right = 0.0
			frame.anchor_top = 1.0
			frame.anchor_bottom = 1.0
			frame.offset_left = margin
			frame.offset_top = -margin - panel_size.y
			frame.offset_right = margin + panel_size.x
			frame.offset_bottom = -margin
		"bottom_right":
			frame.anchor_left = 1.0
			frame.anchor_right = 1.0
			frame.anchor_top = 1.0
			frame.anchor_bottom = 1.0
			frame.offset_left = -margin - panel_size.x
			frame.offset_top = -margin - panel_size.y
			frame.offset_right = -margin
			frame.offset_bottom = -margin
		_:
			frame.anchor_left = 1.0
			frame.anchor_right = 1.0
			frame.anchor_top = 0.0
			frame.anchor_bottom = 0.0
			frame.offset_left = -margin - panel_size.x
			frame.offset_top = margin
			frame.offset_right = -margin
			frame.offset_bottom = margin + panel_size.y
	ui_root.add_child(frame)

	var viewport_container := SubViewportContainer.new()
	viewport_container.name = "ViewportContainer"
	_configure_control_full_rect(viewport_container)
	frame.add_child(viewport_container)

	var minimap_viewport := SubViewport.new()
	minimap_viewport.name = "Viewport"
	minimap_viewport.size = panel_size_i
	minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	minimap_viewport.transparent_bg = true
	minimap_viewport.disable_3d = resolved_mode == "2d"
	viewport_container.add_child(minimap_viewport)

	var camera_node = null
	if resolved_mode == "2d":
		var camera2d := Camera2D.new()
		camera2d.name = "MiniCamera2D"
		camera2d.enabled = true
		var zoom_value: float = clampf(float(params.get("zoom_2d", 0.28)), 0.02, 20.0)
		camera2d.zoom = Vector2(zoom_value, zoom_value)
		if target_node and target_node is Node2D:
			camera2d.position = (target_node as Node2D).global_position
		minimap_viewport.add_child(camera2d)
		camera_node = camera2d
		minimap_viewport.world_2d = edited_scene_root.get_viewport().world_2d
	else:
		var camera3d := Camera3D.new()
		camera3d.name = "MiniCamera3D"
		camera3d.current = true
		camera3d.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera3d.size = max(1.0, float(params.get("camera_size", 24.0)))
		camera3d.near = max(0.01, float(params.get("near", 0.1)))
		camera3d.far = max(camera3d.near + 1.0, float(params.get("far", 1024.0)))
		if target_node and target_node is Node3D:
			var target_position: Vector3 = (target_node as Node3D).global_position
			if resolved_mode == "isometric3d":
				var iso_distance: float = max(1.0, float(params.get("isometric_distance", 28.0)))
				camera3d.global_position = target_position + Vector3(-iso_distance, iso_distance, iso_distance)
				camera3d.look_at(target_position, Vector3.UP)
			else:
				var camera_height: float = max(1.0, float(params.get("camera_height", 36.0)))
				camera3d.global_position = target_position + Vector3(0.0, camera_height, 0.0)
				camera3d.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		else:
			if resolved_mode == "isometric3d":
				camera3d.position = Vector3(-24.0, 24.0, 24.0)
				camera3d.rotation_degrees = Vector3(-35.264, 45.0, 0.0)
			else:
				camera3d.position = Vector3(0.0, 36.0, 0.0)
				camera3d.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		minimap_viewport.add_child(camera3d)
		camera_node = camera3d
		minimap_viewport.world_3d = edited_scene_root.get_viewport().world_3d

	minimap_root.set_meta("mcp_minimap_anchor", anchor_mode)
	minimap_root.set_meta("mcp_minimap_size", _vector2_to_dict(panel_size))
	minimap_root.set_meta("mcp_minimap_camera_name", camera_node.name if camera_node else "")
	minimap_root.set_meta("mcp_minimap_viewport_name", minimap_viewport.name)

	var created_nodes: Array = [minimap_root, ui_root, frame, viewport_container, minimap_viewport]
	if camera_node:
		created_nodes.append(camera_node)

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_minimap_path: String = _join_mcp_path(parent_mcp_path, minimap_root.name)
	var predicted_paths := {
		"minimap_path": predicted_minimap_path,
		"root_path": _join_mcp_path(predicted_minimap_path, ui_root.name),
		"frame_path": _join_mcp_path(predicted_minimap_path, "%s/%s" % [ui_root.name, frame.name]),
		"viewport_container_path": _join_mcp_path(predicted_minimap_path, "%s/%s/%s" % [ui_root.name, frame.name, viewport_container.name]),
		"viewport_path": _join_mcp_path(predicted_minimap_path, "%s/%s/%s/%s" % [ui_root.name, frame.name, viewport_container.name, minimap_viewport.name]),
	}
	if camera_node:
		predicted_paths["camera_path"] = _join_mcp_path(String(predicted_paths["viewport_path"]), String(camera_node.name))

	var transaction_metadata := {
		"command": "build_subviewport_minimap",
		"parent_path": parent_mcp_path,
		"minimap_name": minimap_root.name,
		"mode": resolved_mode,
		"anchor": anchor_mode,
		"size": _vector2_to_dict(panel_size),
		"target_path": _to_mcp_path(target_node) if target_node else "",
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build SubViewport Minimap", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build SubViewport Minimap", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for minimap generation", command_id)

	transaction.add_do_method(parent, "add_child", [minimap_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [minimap_root])
	transaction.add_undo_method(minimap_root, "queue_free")
	transaction.add_do_reference(minimap_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built subviewport minimap", "_build_subviewport_minimap", {
			"minimap_path": _to_mcp_path(minimap_root),
			"mode": resolved_mode,
			"anchor": anchor_mode,
			"size": _vector2_to_dict(panel_size),
			"target_path": _to_mcp_path(target_node) if target_node else "",
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_minimap",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"minimap_name": minimap_root.name,
		"minimap_path": predicted_paths.get("minimap_path", ""),
		"mode": resolved_mode,
		"anchor": anchor_mode,
		"size": _vector2_to_dict(panel_size),
		"target_path": _to_mcp_path(target_node) if target_node else "",
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit minimap generation", command_id)
		var committed_paths := {
			"minimap_path": _to_mcp_path(minimap_root),
			"root_path": _to_mcp_path(ui_root),
			"frame_path": _to_mcp_path(frame),
			"viewport_container_path": _to_mcp_path(viewport_container),
			"viewport_path": _to_mcp_path(minimap_viewport),
		}
		if camera_node:
			committed_paths["camera_path"] = _to_mcp_path(camera_node)
		response["minimap_path"] = _to_mcp_path(minimap_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_weather_system_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var weather_name: String = String(params.get("weather_name", "WeatherSystem2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))
	var area_size: Vector2 = _parse_vector2_param(params.get("area_size", Vector2(1280.0, 720.0)))
	if area_size.x <= 0.0 or area_size.y <= 0.0:
		return _send_error(client_id, "area_size must be greater than zero on both axes", command_id)

	var requested_preset: String = String(params.get("preset", "rain")).strip_edges()
	var normalized_preset: String = _mcp_normalize_weather_preset_2d(requested_preset)
	if normalized_preset.is_empty():
		return _send_error(client_id, "Unsupported weather preset: %s" % requested_preset, command_id)

	var preset_profile: Dictionary = _mcp_weather_profile_2d(normalized_preset)
	if preset_profile.is_empty():
		return _send_error(client_id, "Failed to resolve weather preset profile for %s" % normalized_preset, command_id)

	var intensity: float = clampf(float(params.get("intensity", float(preset_profile.get("default_intensity", 0.65)))), 0.0, 1.0)
	var transition_rate: float = max(0.01, float(params.get("transition_rate", 2.2)))
	var wind_direction: Vector2 = _parse_vector2_param(params.get("wind_direction", Vector2(-0.12, 1.0)))
	if wind_direction.length_squared() <= 0.000001:
		wind_direction = Vector2(0.0, 1.0)
	wind_direction = wind_direction.normalized()
	var wind_strength: float = clampf(float(params.get("wind_strength", 0.4)), 0.0, 1.0)
	var canvas_layer_index: int = int(params.get("canvas_layer", 0))

	var enable_precipitation: bool = bool(params.get("enable_precipitation", true))
	var enable_fog: bool = bool(params.get("enable_fog", true))
	var enable_ambient_modulate: bool = bool(params.get("enable_ambient_modulate", true))
	var enable_lightning_overlay: bool = bool(params.get("enable_lightning_overlay", true))
	if not enable_precipitation and not enable_fog and not enable_ambient_modulate and not enable_lightning_overlay:
		return _send_error(client_id, "Enable at least one weather subsystem", command_id)

	var precipitation_mode: String = String(params.get("precipitation_mode", String(preset_profile.get("precipitation_mode", "none")))).strip_edges().to_lower()
	if not _mcp_is_valid_weather_precipitation_mode_2d(precipitation_mode):
		precipitation_mode = String(preset_profile.get("precipitation_mode", "none"))
	var precipitation_intensity_scale: float = clampf(
		float(params.get("precipitation_intensity_scale", float(preset_profile.get("precipitation_intensity", 1.0)))),
		0.0,
		2.0
	)
	var max_particles: int = clampi(int(params.get("max_particles", 2200)), 0, 50000)
	var particle_lifetime: float = max(0.05, float(params.get("particle_lifetime", float(preset_profile.get("particle_lifetime", 1.8)))))
	var particle_speed_min: float = max(0.0, float(params.get("particle_speed_min", float(preset_profile.get("particle_speed_min", 260.0)))))
	var particle_speed_max: float = max(particle_speed_min, float(params.get("particle_speed_max", float(preset_profile.get("particle_speed_max", 560.0)))))
	var spread_degrees: float = clampf(float(params.get("spread_degrees", float(preset_profile.get("spread_degrees", 4.0)))), 0.0, 180.0)
	var gravity_strength: float = max(0.0, float(params.get("gravity_strength", float(preset_profile.get("gravity_strength", 980.0)))))
	var particle_scale_min: Vector2 = _parse_vector2_param(params.get("particle_scale_min", preset_profile.get("particle_scale_min", Vector2(0.7, 5.2))))
	var particle_scale_max: Vector2 = _parse_vector2_param(params.get("particle_scale_max", preset_profile.get("particle_scale_max", Vector2(1.2, 12.0))))
	particle_scale_min.x = max(0.01, particle_scale_min.x)
	particle_scale_min.y = max(0.01, particle_scale_min.y)
	particle_scale_max.x = max(particle_scale_min.x, particle_scale_max.x)
	particle_scale_max.y = max(particle_scale_min.y, particle_scale_max.y)

	var fog_density: float = clampf(float(params.get("fog_density", float(preset_profile.get("fog_density", 0.18)))), 0.0, 1.0)
	var fog_color = _coerce_color(params.get("fog_color", preset_profile.get("fog_color", Color(0.74, 0.8, 0.86, 0.24))))
	if fog_color == null:
		fog_color = preset_profile.get("fog_color", Color(0.74, 0.8, 0.86, 0.24))
	var ambient_color = _coerce_color(params.get("ambient_color", preset_profile.get("ambient_color", Color(0.93, 0.95, 1.0, 1.0))))
	if ambient_color == null:
		ambient_color = preset_profile.get("ambient_color", Color(0.93, 0.95, 1.0, 1.0))
	var precipitation_color = _coerce_color(params.get("precipitation_color", preset_profile.get("precipitation_color", Color(0.86, 0.9, 1.0, 0.92))))
	if precipitation_color == null:
		precipitation_color = preset_profile.get("precipitation_color", Color(0.86, 0.9, 1.0, 0.92))

	var lightning_enabled: bool = bool(params.get("lightning_enabled", bool(preset_profile.get("lightning_enabled", false))))
	var lightning_chance: float = clampf(float(params.get("lightning_chance", float(preset_profile.get("lightning_chance", 0.0)))), 0.0, 1.0)
	var lightning_flash_strength: float = clampf(float(params.get("lightning_flash_strength", float(preset_profile.get("lightning_flash_strength", 0.82)))), 0.0, 1.0)
	if lightning_enabled and lightning_flash_strength <= 0.0:
		lightning_flash_strength = 0.82
	var lightning_decay: float = max(0.01, float(params.get("lightning_decay", 2.4)))
	var lightning_color = _coerce_color(params.get("lightning_color", Color(1.0, 1.0, 1.0, 1.0)))
	if lightning_color == null:
		lightning_color = Color(1.0, 1.0, 1.0, 1.0)

	if weather_name.is_empty():
		weather_name = "WeatherSystem2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var precipitation_amount := int(round(float(max_particles) * clampf(intensity * precipitation_intensity_scale, 0.0, 1.0)))
	var can_emit_precipitation: bool = (
		enable_precipitation and
		precipitation_mode != "none" and
		max_particles > 0 and
		precipitation_amount > 0
	)

	var weather_root := Node2D.new()
	weather_root.name = _resolve_unique_child_name(parent, weather_name)
	weather_root.position = origin
	weather_root.set_meta("mcp_weather_type", "weather_system_2d")
	weather_root.set_meta("mcp_weather_source", "procedural_authoring")
	weather_root.set_meta("mcp_weather_seed", seed_value)
	weather_root.set_meta("mcp_weather_preset", normalized_preset)
	weather_root.set_meta("mcp_weather_intensity", intensity)
	weather_root.set_meta("mcp_weather_target_intensity", intensity)
	weather_root.set_meta("mcp_weather_transition_rate", transition_rate)
	weather_root.set_meta("mcp_weather_area_size", _vector2_to_dict(area_size))
	weather_root.set_meta("mcp_weather_wind_direction", _vector2_to_dict(wind_direction))
	weather_root.set_meta("mcp_weather_wind_strength", wind_strength)
	weather_root.set_meta("mcp_weather_precipitation_mode", precipitation_mode)
	weather_root.set_meta("mcp_weather_precipitation_intensity_scale", precipitation_intensity_scale)
	weather_root.set_meta("mcp_weather_particle_lifetime", particle_lifetime)
	weather_root.set_meta("mcp_weather_particle_speed_min", particle_speed_min)
	weather_root.set_meta("mcp_weather_particle_speed_max", particle_speed_max)
	weather_root.set_meta("mcp_weather_particle_scale_min", _vector2_to_dict(particle_scale_min))
	weather_root.set_meta("mcp_weather_particle_scale_max", _vector2_to_dict(particle_scale_max))
	weather_root.set_meta("mcp_weather_spread_degrees", spread_degrees)
	weather_root.set_meta("mcp_weather_gravity_strength", gravity_strength)
	weather_root.set_meta("mcp_weather_max_particles", max_particles)
	weather_root.set_meta("mcp_weather_fog_density", fog_density)
	weather_root.set_meta("mcp_weather_fog_color", fog_color)
	weather_root.set_meta("mcp_weather_ambient_color", ambient_color)
	weather_root.set_meta("mcp_weather_lightning_enabled", lightning_enabled)
	weather_root.set_meta("mcp_weather_lightning_chance", lightning_chance)
	weather_root.set_meta("mcp_weather_lightning_flash_strength", lightning_flash_strength)
	weather_root.set_meta("mcp_weather_lightning_decay", lightning_decay)
	weather_root.set_meta("mcp_weather_lightning_color", lightning_color)
	weather_root.set_meta("mcp_weather_lightning_flash", 0.0)
	weather_root.set_meta("mcp_weather_step_count", 0)

	var created_nodes: Array = [weather_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_weather_path: String = _join_mcp_path(parent_mcp_path, weather_root.name)
	var predicted_paths := {
		"weather_path": predicted_weather_path,
	}

	var precipitation_node = null
	if enable_precipitation:
		precipitation_node = GPUParticles2D.new()
		precipitation_node.name = _resolve_unique_child_name(weather_root, "Precipitation")
		precipitation_node.position = Vector2(area_size.x * 0.5, -12.0)
		precipitation_node.one_shot = false
		precipitation_node.local_coords = false
		precipitation_node.fixed_fps = int(params.get("particle_fixed_fps", 30))
		precipitation_node.lifetime = particle_lifetime
		precipitation_node.amount = max(1, precipitation_amount)
		precipitation_node.preprocess = clampf(particle_lifetime * 0.45, 0.0, particle_lifetime)
		precipitation_node.visibility_rect = Rect2(
			-area_size.x * 0.6,
			-64.0,
			area_size.x * 1.2,
			area_size.y + 196.0
		)
		var particle_material := ParticleProcessMaterial.new()
		_mcp_configure_weather_particle_material_2d(
			particle_material,
			area_size,
			precipitation_mode,
			precipitation_color,
			wind_direction,
			wind_strength,
			particle_speed_min,
			particle_speed_max,
			spread_degrees,
			particle_scale_min,
			particle_scale_max,
			gravity_strength
		)
		precipitation_node.process_material = particle_material
		precipitation_node.texture = _mcp_make_weather_particle_texture_2d(precipitation_mode)
		precipitation_node.emitting = can_emit_precipitation
		weather_root.add_child(precipitation_node)
		created_nodes.append(precipitation_node)
		predicted_paths["precipitation_path"] = _join_mcp_path(predicted_weather_path, precipitation_node.name)

	var effects_layer := CanvasLayer.new()
	effects_layer.name = _resolve_unique_child_name(weather_root, "ScreenEffects")
	effects_layer.layer = canvas_layer_index
	weather_root.add_child(effects_layer)
	created_nodes.append(effects_layer)
	predicted_paths["screen_effects_layer_path"] = _join_mcp_path(predicted_weather_path, effects_layer.name)

	var effects_root := Control.new()
	effects_root.name = "Root"
	_configure_control_full_rect(effects_root)
	effects_layer.add_child(effects_root)
	created_nodes.append(effects_root)
	predicted_paths["screen_effects_root_path"] = _join_mcp_path(String(predicted_paths["screen_effects_layer_path"]), effects_root.name)

	var fog_overlay = null
	if enable_fog:
		fog_overlay = ColorRect.new()
		fog_overlay.name = "FogOverlay"
		_configure_control_full_rect(fog_overlay)
		fog_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fog_color_with_alpha: Color = fog_color
		fog_color_with_alpha.a = clampf(fog_density * intensity, 0.0, 0.95)
		fog_overlay.color = _convert_property_value(fog_overlay, "color", fog_color_with_alpha)
		effects_root.add_child(fog_overlay)
		created_nodes.append(fog_overlay)
		predicted_paths["fog_overlay_path"] = _join_mcp_path(String(predicted_paths["screen_effects_root_path"]), fog_overlay.name)

	var lightning_overlay = null
	if enable_lightning_overlay:
		lightning_overlay = ColorRect.new()
		lightning_overlay.name = "LightningFlash"
		_configure_control_full_rect(lightning_overlay)
		lightning_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var flash_color: Color = lightning_color
		flash_color.a = 0.0
		lightning_overlay.color = _convert_property_value(lightning_overlay, "color", flash_color)
		lightning_overlay.visible = lightning_enabled
		effects_root.add_child(lightning_overlay)
		created_nodes.append(lightning_overlay)
		predicted_paths["lightning_overlay_path"] = _join_mcp_path(String(predicted_paths["screen_effects_root_path"]), lightning_overlay.name)

	var ambient_modulate = null
	if enable_ambient_modulate:
		ambient_modulate = CanvasModulate.new()
		ambient_modulate.name = _resolve_unique_child_name(weather_root, "AmbientModulate")
		ambient_modulate.color = _mcp_weather_ambient_color_for_intensity(ambient_color, intensity)
		weather_root.add_child(ambient_modulate)
		created_nodes.append(ambient_modulate)
		predicted_paths["ambient_modulate_path"] = _join_mcp_path(predicted_weather_path, ambient_modulate.name)

	weather_root.set_meta("mcp_weather_enable_precipitation", enable_precipitation)
	weather_root.set_meta("mcp_weather_enable_fog", enable_fog)
	weather_root.set_meta("mcp_weather_enable_ambient_modulate", enable_ambient_modulate)
	weather_root.set_meta("mcp_weather_enable_lightning_overlay", enable_lightning_overlay)
	weather_root.set_meta("mcp_weather_screen_layer_name", effects_layer.name)
	weather_root.set_meta("mcp_weather_screen_root_name", effects_root.name)
	weather_root.set_meta("mcp_weather_precipitation_node_name", precipitation_node.name if precipitation_node else "")
	weather_root.set_meta("mcp_weather_fog_node_name", fog_overlay.name if fog_overlay else "")
	weather_root.set_meta("mcp_weather_lightning_node_name", lightning_overlay.name if lightning_overlay else "")
	weather_root.set_meta("mcp_weather_ambient_node_name", ambient_modulate.name if ambient_modulate else "")

	var transaction_metadata := {
		"command": "build_weather_system_2d",
		"parent_path": parent_mcp_path,
		"weather_name": weather_root.name,
		"preset": normalized_preset,
		"intensity": intensity,
		"precipitation_mode": precipitation_mode,
		"max_particles": max_particles,
		"can_emit_precipitation": can_emit_precipitation,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Weather System 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Weather System 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D weather generation", command_id)

	transaction.add_do_method(parent, "add_child", [weather_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [weather_root])
	transaction.add_undo_method(weather_root, "queue_free")
	transaction.add_do_reference(weather_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built weather system 2D", "_build_weather_system_2d", {
			"weather_path": _to_mcp_path(weather_root),
			"parent_path": parent_mcp_path,
			"preset": normalized_preset,
			"intensity": intensity,
			"precipitation_mode": precipitation_mode,
			"can_emit_precipitation": can_emit_precipitation,
			"transaction_id": transaction.transaction_id,
			"system_section": "weather_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"weather_name": weather_root.name,
		"weather_path": predicted_paths.get("weather_path", ""),
		"origin": _vector2_to_dict(origin),
		"area_size": _vector2_to_dict(area_size),
		"preset": normalized_preset,
		"intensity": intensity,
		"transition_rate": transition_rate,
		"wind_direction": _vector2_to_dict(wind_direction),
		"wind_strength": wind_strength,
		"precipitation_mode": precipitation_mode,
		"can_emit_precipitation": can_emit_precipitation,
		"particle_amount": precipitation_amount,
		"max_particles": max_particles,
		"fog_density": fog_density,
		"lightning_enabled": lightning_enabled,
		"seed": seed_value,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D weather generation", command_id)
		var committed_paths := {
			"weather_path": _to_mcp_path(weather_root),
			"screen_effects_layer_path": _to_mcp_path(effects_layer),
			"screen_effects_root_path": _to_mcp_path(effects_root),
		}
		if precipitation_node:
			committed_paths["precipitation_path"] = _to_mcp_path(precipitation_node)
		if fog_overlay:
			committed_paths["fog_overlay_path"] = _to_mcp_path(fog_overlay)
		if lightning_overlay:
			committed_paths["lightning_overlay_path"] = _to_mcp_path(lightning_overlay)
		if ambient_modulate:
			committed_paths["ambient_modulate_path"] = _to_mcp_path(ambient_modulate)
		response["weather_path"] = _to_mcp_path(weather_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_water_body_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var water_name: String = String(params.get("water_name", "Water2D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var position: Vector2 = _parse_vector2_param(params.get("position", Vector2.ZERO))
	var size: Vector2 = _parse_vector2_param(params.get("size", Vector2(640.0, 160.0)))
	var create_visual: bool = bool(params.get("create_visual", true))
	var create_area: bool = bool(params.get("create_area", true))
	var create_collision: bool = bool(params.get("create_collision", true))

	if water_name.is_empty():
		water_name = "Water2D"
	if size.x <= 0.0 or size.y <= 0.0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)
	if create_collision and not create_area:
		create_area = true

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var flow_direction := _parse_vector2_param(params.get("flow_direction", Vector2.RIGHT))
	if flow_direction.length_squared() <= 0.000001:
		flow_direction = Vector2.RIGHT
	flow_direction = flow_direction.normalized()
	var flow_speed: float = float(params.get("flow_speed", 42.0))
	var buoyancy: float = float(params.get("buoyancy", 1.0))
	var drag: float = float(params.get("drag", 0.18))
	var wave_amplitude: float = float(params.get("wave_amplitude", 8.0))
	var wave_speed: float = float(params.get("wave_speed", 1.1))
	var wave_length: float = max(1.0, float(params.get("wave_length", 96.0)))

	var water_root := Node2D.new()
	water_root.name = _resolve_unique_child_name(parent, water_name)
	water_root.position = position

	water_root.set_meta("mcp_water_type", "water_body_2d")
	water_root.set_meta("mcp_water_size", _vector2_to_dict(size))
	water_root.set_meta("mcp_water_flow_direction", _vector2_to_dict(flow_direction))
	water_root.set_meta("mcp_water_flow_speed", flow_speed)
	water_root.set_meta("mcp_water_buoyancy", buoyancy)
	water_root.set_meta("mcp_water_drag", drag)
	water_root.set_meta("mcp_water_wave_amplitude", wave_amplitude)
	water_root.set_meta("mcp_water_wave_speed", wave_speed)
	water_root.set_meta("mcp_water_wave_length", wave_length)
	water_root.set_meta("mcp_water_source", "procedural_authoring")

	var created_nodes: Array = [water_root]
	var predicted_paths: Dictionary = {}

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_water_path: String = _join_mcp_path(parent_mcp_path, water_root.name)
	predicted_paths["water_path"] = predicted_water_path

	if create_area:
		var area := Area2D.new()
		area.name = _resolve_unique_child_name(water_root, "WaterArea2D")
		area.monitoring = true
		area.monitorable = true
		if params.has("collision_layer"):
			area.collision_layer = int(params.get("collision_layer"))
		if params.has("collision_mask"):
			area.collision_mask = int(params.get("collision_mask"))
		water_root.add_child(area)
		created_nodes.append(area)
		predicted_paths["area_path"] = _join_mcp_path(predicted_water_path, area.name)

		if create_collision:
			var collision := CollisionShape2D.new()
			collision.name = _resolve_unique_child_name(area, "CollisionShape2D")
			var rect_shape := RectangleShape2D.new()
			rect_shape.size = size
			collision.shape = rect_shape
			collision.position = size * 0.5
			area.add_child(collision)
			created_nodes.append(collision)
			predicted_paths["collision_path"] = _join_mcp_path(String(predicted_paths["area_path"]), collision.name)

	if create_visual:
		var polygon := Polygon2D.new()
		polygon.name = _resolve_unique_child_name(water_root, "Visual")
		polygon.polygon = PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(size.x, 0.0),
			Vector2(size.x, size.y),
			Vector2(0.0, size.y),
		])
		polygon.color = _convert_property_value(polygon, "color", params.get("color", Color(0.16, 0.42, 0.88, 0.55)))
		water_root.add_child(polygon)
		created_nodes.append(polygon)
		predicted_paths["visual_path"] = _join_mcp_path(predicted_water_path, polygon.name)

	var transaction_metadata := {
		"command": "build_water_body_2d",
		"parent_path": parent_mcp_path,
		"water_name": water_root.name,
		"size": _vector2_to_dict(size),
		"create_visual": create_visual,
		"create_area": create_area,
		"create_collision": create_collision,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Water Body 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Water Body 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D water generation", command_id)

	transaction.add_do_method(parent, "add_child", [water_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [water_root])
	transaction.add_undo_method(water_root, "queue_free")
	transaction.add_do_reference(water_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built water body 2D", "_build_water_body_2d", {
			"water_path": _to_mcp_path(water_root),
			"parent_path": parent_mcp_path,
			"size": _vector2_to_dict(size),
			"create_visual": create_visual,
			"create_area": create_area,
			"create_collision": create_collision,
			"transaction_id": transaction.transaction_id,
			"system_section": "water_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"water_name": water_root.name,
		"water_path": predicted_paths.get("water_path", ""),
		"position": _vector2_to_dict(position),
		"size": _vector2_to_dict(size),
		"flow_direction": _vector2_to_dict(flow_direction),
		"flow_speed": flow_speed,
		"buoyancy": buoyancy,
		"drag": drag,
		"wave_amplitude": wave_amplitude,
		"wave_speed": wave_speed,
		"wave_length": wave_length,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D water generation", command_id)
		var committed_paths := {
			"water_path": _to_mcp_path(water_root),
		}
		if create_area:
			var area_node = water_root.get_node_or_null("WaterArea2D")
			if area_node:
				committed_paths["area_path"] = _to_mcp_path(area_node)
			if create_collision:
				var collision_node = water_root.get_node_or_null("WaterArea2D/CollisionShape2D")
				if collision_node:
					committed_paths["collision_path"] = _to_mcp_path(collision_node)
		if create_visual:
			var visual_node = water_root.get_node_or_null("Visual")
			if visual_node:
				committed_paths["visual_path"] = _to_mcp_path(visual_node)
		response["water_path"] = _to_mcp_path(water_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_water_body_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var water_name: String = String(params.get("water_name", "Water3D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var position: Vector3 = _parse_vector3_param(params.get("position", Vector3.ZERO))
	var size_2d: Vector2 = _parse_vector2_param(params.get("size", Vector2(12.0, 12.0)))
	var depth: float = max(0.01, float(params.get("depth", 2.0)))
	var create_visual: bool = bool(params.get("create_visual", true))
	var create_area: bool = bool(params.get("create_area", true))
	var create_collision: bool = bool(params.get("create_collision", true))

	if water_name.is_empty():
		water_name = "Water3D"
	if size_2d.x <= 0.0 or size_2d.y <= 0.0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)
	if create_collision and not create_area:
		create_area = true

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var flow_direction := _parse_vector2_param(params.get("flow_direction", Vector2.RIGHT))
	if flow_direction.length_squared() <= 0.000001:
		flow_direction = Vector2.RIGHT
	flow_direction = flow_direction.normalized()
	var flow_speed: float = float(params.get("flow_speed", 1.8))
	var buoyancy: float = float(params.get("buoyancy", 1.0))
	var drag: float = float(params.get("drag", 0.24))
	var wave_amplitude: float = float(params.get("wave_amplitude", 0.2))
	var wave_speed: float = float(params.get("wave_speed", 1.0))
	var wave_length: float = max(0.01, float(params.get("wave_length", 2.0)))

	var water_root := Node3D.new()
	water_root.name = _resolve_unique_child_name(parent, water_name)
	water_root.position = position

	water_root.set_meta("mcp_water_type", "water_body_3d")
	water_root.set_meta("mcp_water_size", _vector2_to_dict(size_2d))
	water_root.set_meta("mcp_water_depth", depth)
	water_root.set_meta("mcp_water_flow_direction", _vector2_to_dict(flow_direction))
	water_root.set_meta("mcp_water_flow_speed", flow_speed)
	water_root.set_meta("mcp_water_buoyancy", buoyancy)
	water_root.set_meta("mcp_water_drag", drag)
	water_root.set_meta("mcp_water_wave_amplitude", wave_amplitude)
	water_root.set_meta("mcp_water_wave_speed", wave_speed)
	water_root.set_meta("mcp_water_wave_length", wave_length)
	water_root.set_meta("mcp_water_source", "procedural_authoring")

	var created_nodes: Array = [water_root]
	var predicted_paths: Dictionary = {}
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_water_path: String = _join_mcp_path(parent_mcp_path, water_root.name)
	predicted_paths["water_path"] = predicted_water_path

	if create_visual:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = _resolve_unique_child_name(water_root, "Surface")
		var plane := PlaneMesh.new()
		plane.size = size_2d
		plane.subdivide_width = max(0, int(params.get("subdivide_width", 24)))
		plane.subdivide_depth = max(0, int(params.get("subdivide_depth", 24)))
		mesh_instance.mesh = plane

		var material := StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.albedo_color = _convert_property_value(material, "albedo_color", params.get("surface_color", Color(0.1, 0.35, 0.7, 0.55)))
		material.roughness = clampf(float(params.get("roughness", 0.08)), 0.0, 1.0)
		material.metallic = clampf(float(params.get("metallic", 0.0)), 0.0, 1.0)
		if params.has("emission_color"):
			material.emission_enabled = true
			material.emission = _convert_property_value(material, "emission", params.get("emission_color"))
			material.emission_energy_multiplier = max(0.0, float(params.get("emission_energy", 0.25)))
		mesh_instance.set_surface_override_material(0, material)

		water_root.add_child(mesh_instance)
		created_nodes.append(mesh_instance)
		predicted_paths["surface_path"] = _join_mcp_path(predicted_water_path, mesh_instance.name)

	if create_area:
		var area := Area3D.new()
		area.name = _resolve_unique_child_name(water_root, "WaterArea3D")
		area.monitoring = true
		area.monitorable = true
		if params.has("collision_layer"):
			area.collision_layer = int(params.get("collision_layer"))
		if params.has("collision_mask"):
			area.collision_mask = int(params.get("collision_mask"))
		water_root.add_child(area)
		created_nodes.append(area)
		predicted_paths["area_path"] = _join_mcp_path(predicted_water_path, area.name)

		if create_collision:
			var collision := CollisionShape3D.new()
			collision.name = _resolve_unique_child_name(area, "CollisionShape3D")
			var box := BoxShape3D.new()
			box.size = Vector3(size_2d.x, depth, size_2d.y)
			collision.shape = box
			collision.position = Vector3(0.0, -depth * 0.5, 0.0)
			area.add_child(collision)
			created_nodes.append(collision)
			predicted_paths["collision_path"] = _join_mcp_path(String(predicted_paths["area_path"]), collision.name)

	var transaction_metadata := {
		"command": "build_water_body_3d",
		"parent_path": parent_mcp_path,
		"water_name": water_root.name,
		"size": _vector2_to_dict(size_2d),
		"depth": depth,
		"create_visual": create_visual,
		"create_area": create_area,
		"create_collision": create_collision,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Water Body 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Water Body 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 3D water generation", command_id)

	transaction.add_do_method(parent, "add_child", [water_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [water_root])
	transaction.add_undo_method(water_root, "queue_free")
	transaction.add_do_reference(water_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built water body 3D", "_build_water_body_3d", {
			"water_path": _to_mcp_path(water_root),
			"parent_path": parent_mcp_path,
			"size": _vector2_to_dict(size_2d),
			"depth": depth,
			"create_visual": create_visual,
			"create_area": create_area,
			"create_collision": create_collision,
			"transaction_id": transaction.transaction_id,
			"system_section": "water_3d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"water_name": water_root.name,
		"water_path": predicted_paths.get("water_path", ""),
		"position": _vector3_to_dict(position),
		"size": _vector2_to_dict(size_2d),
		"depth": depth,
		"flow_direction": _vector2_to_dict(flow_direction),
		"flow_speed": flow_speed,
		"buoyancy": buoyancy,
		"drag": drag,
		"wave_amplitude": wave_amplitude,
		"wave_speed": wave_speed,
		"wave_length": wave_length,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 3D water generation", command_id)
		var committed_paths := {
			"water_path": _to_mcp_path(water_root),
		}
		if create_visual:
			var surface_node = water_root.get_node_or_null("Surface")
			if surface_node:
				committed_paths["surface_path"] = _to_mcp_path(surface_node)
		if create_area:
			var area_node = water_root.get_node_or_null("WaterArea3D")
			if area_node:
				committed_paths["area_path"] = _to_mcp_path(area_node)
			if create_collision:
				var collision_node = water_root.get_node_or_null("WaterArea3D/CollisionShape3D")
				if collision_node:
					committed_paths["collision_path"] = _to_mcp_path(collision_node)
		response["water_path"] = _to_mcp_path(water_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_sand_field_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var field_name: String = String(params.get("field_name", "SandField3D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var origin: Vector3 = _parse_vector3_param(params.get("origin", Vector3.ZERO))
	var size: Vector3 = _parse_vector3_param(params.get("size", Vector3(8.0, 3.0, 8.0)))
	var create_volume_area: bool = bool(params.get("create_volume_area", true))
	var create_visual: bool = bool(params.get("create_visual", true))

	if field_name.is_empty():
		field_name = "SandField3D"
	if size.x <= 0.0 or size.y <= 0.0 or size.z <= 0.0:
		return _send_error(client_id, "size must be greater than zero on all axes", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var grain_spacing: float = max(0.05, float(params.get("grain_spacing", 0.45)))
	var grain_radius: float = max(0.02, float(params.get("grain_radius", grain_spacing * 0.32)))
	var jitter: float = clampf(float(params.get("jitter", grain_spacing * 0.18)), 0.0, grain_spacing * 0.5)
	var max_grains: int = max(1, int(params.get("max_grains", 512)))
	var random_yaw: bool = bool(params.get("random_yaw", true))

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var internal_friction: float = max(0.0, float(params.get("internal_friction", 0.9)))
	var cohesion: float = max(0.0, float(params.get("cohesion", 0.18)))
	var stiffness: float = max(0.0, float(params.get("stiffness", 1500.0)))
	var bulk_density: float = max(0.0, float(params.get("bulk_density", 1600.0)))
	var profile_name: String = String(params.get("profile_name", "homogenized_sand")).strip_edges()
	if profile_name.is_empty():
		profile_name = "homogenized_sand"
	var source_reference: String = String(params.get("source_reference", "numerical_homogenization_granular")).strip_edges()
	if source_reference.is_empty():
		source_reference = "numerical_homogenization_granular"

	var field_root := Node3D.new()
	field_root.name = _resolve_unique_child_name(parent, field_name)
	field_root.position = origin

	field_root.set_meta("mcp_granular_profile", profile_name)
	field_root.set_meta("mcp_granular_internal_friction", internal_friction)
	field_root.set_meta("mcp_granular_cohesion", cohesion)
	field_root.set_meta("mcp_granular_stiffness", stiffness)
	field_root.set_meta("mcp_granular_bulk_density", bulk_density)
	field_root.set_meta("mcp_granular_source", source_reference)
	field_root.set_meta("mcp_granular_size", _vector3_to_dict(size))
	field_root.set_meta("mcp_granular_spacing", grain_spacing)

	var created_nodes: Array = [field_root]
	var predicted_paths: Dictionary = {}
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_field_path: String = _join_mcp_path(parent_mcp_path, field_root.name)
	predicted_paths["field_path"] = predicted_field_path

	var grain_count := 0
	if create_visual:
		var grains_node := MultiMeshInstance3D.new()
		grains_node.name = _resolve_unique_child_name(field_root, "SandGrains")

		var nx := max(1, int(floor(size.x / grain_spacing)) + 1)
		var ny := max(1, int(floor(size.y / grain_spacing)) + 1)
		var nz := max(1, int(floor(size.z / grain_spacing)) + 1)
		var transforms: Array = []
		for y_idx in range(ny):
			for z_idx in range(nz):
				for x_idx in range(nx):
					if transforms.size() >= max_grains:
						break
					var point := Vector3(
						-size.x * 0.5 + float(x_idx) * grain_spacing,
						-size.y * 0.5 + float(y_idx) * grain_spacing,
						-size.z * 0.5 + float(z_idx) * grain_spacing
					)
					if jitter > 0.0:
						point.x = clampf(point.x + rng.randf_range(-jitter, jitter), -size.x * 0.5, size.x * 0.5)
						point.y = clampf(point.y + rng.randf_range(-jitter, jitter), -size.y * 0.5, size.y * 0.5)
						point.z = clampf(point.z + rng.randf_range(-jitter, jitter), -size.z * 0.5, size.z * 0.5)
					var basis := Basis.IDENTITY
					if random_yaw:
						basis = basis.rotated(Vector3.UP, deg_to_rad(rng.randf_range(-180.0, 180.0)))
					transforms.append(Transform3D(basis, point))
				if transforms.size() >= max_grains:
					break
			if transforms.size() >= max_grains:
				break

		grain_count = transforms.size()
		if grain_count <= 0:
			return _send_error(client_id, "Failed to generate any grains with the requested parameters", command_id)

		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = false
		multimesh.use_custom_data = false
		multimesh.instance_count = grain_count

		var sphere_mesh := SphereMesh.new()
		sphere_mesh.radius = grain_radius
		sphere_mesh.height = grain_radius * 2.0
		multimesh.mesh = sphere_mesh

		for idx in range(grain_count):
			multimesh.set_instance_transform(idx, transforms[idx])

		grains_node.multimesh = multimesh

		var material := StandardMaterial3D.new()
		material.albedo_color = _convert_property_value(material, "albedo_color", params.get("grain_color", Color(0.76, 0.68, 0.48, 1.0)))
		material.roughness = clampf(float(params.get("grain_roughness", 0.85)), 0.0, 1.0)
		material.metallic = clampf(float(params.get("grain_metallic", 0.0)), 0.0, 1.0)
		grains_node.material_override = material

		field_root.add_child(grains_node)
		created_nodes.append(grains_node)
		predicted_paths["grains_path"] = _join_mcp_path(predicted_field_path, grains_node.name)

	if create_volume_area:
		var area := Area3D.new()
		area.name = _resolve_unique_child_name(field_root, "SandVolumeArea3D")
		area.monitoring = true
		area.monitorable = true
		if params.has("collision_layer"):
			area.collision_layer = int(params.get("collision_layer"))
		if params.has("collision_mask"):
			area.collision_mask = int(params.get("collision_mask"))

		var collision := CollisionShape3D.new()
		collision.name = _resolve_unique_child_name(area, "CollisionShape3D")
		var box := BoxShape3D.new()
		box.size = size
		collision.shape = box
		area.add_child(collision)

		field_root.add_child(area)
		created_nodes.append(area)
		created_nodes.append(collision)
		predicted_paths["volume_area_path"] = _join_mcp_path(predicted_field_path, area.name)
		predicted_paths["collision_path"] = _join_mcp_path(String(predicted_paths["volume_area_path"]), collision.name)

	field_root.set_meta("mcp_grain_count", grain_count)

	var transaction_metadata := {
		"command": "build_sand_field_3d",
		"parent_path": parent_mcp_path,
		"field_name": field_root.name,
		"grain_count": grain_count,
		"grain_spacing": grain_spacing,
		"seed": seed_value,
		"create_visual": create_visual,
		"create_volume_area": create_volume_area,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Sand Field 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Sand Field 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for sand field generation", command_id)

	transaction.add_do_method(parent, "add_child", [field_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [field_root])
	transaction.add_undo_method(field_root, "queue_free")
	transaction.add_do_reference(field_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built sand field 3D", "_build_sand_field_3d", {
			"field_path": _to_mcp_path(field_root),
			"parent_path": parent_mcp_path,
			"grain_count": grain_count,
			"grain_spacing": grain_spacing,
			"seed": seed_value,
			"create_visual": create_visual,
			"create_volume_area": create_volume_area,
			"transaction_id": transaction.transaction_id,
			"system_section": "granular_3d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"field_name": field_root.name,
		"field_path": predicted_paths.get("field_path", ""),
		"origin": _vector3_to_dict(origin),
		"size": _vector3_to_dict(size),
		"grain_count": grain_count,
		"grain_spacing": grain_spacing,
		"grain_radius": grain_radius,
		"seed": seed_value,
		"profile_name": profile_name,
		"internal_friction": internal_friction,
		"cohesion": cohesion,
		"stiffness": stiffness,
		"bulk_density": bulk_density,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit sand field generation", command_id)
		var committed_paths := {
			"field_path": _to_mcp_path(field_root),
		}
		if create_visual:
			var grains_node = field_root.get_node_or_null("SandGrains")
			if grains_node:
				committed_paths["grains_path"] = _to_mcp_path(grains_node)
		if create_volume_area:
			var area_node = field_root.get_node_or_null("SandVolumeArea3D")
			if area_node:
				committed_paths["volume_area_path"] = _to_mcp_path(area_node)
			var collision_node = field_root.get_node_or_null("SandVolumeArea3D/CollisionShape3D")
			if collision_node:
				committed_paths["collision_path"] = _to_mcp_path(collision_node)
		response["field_path"] = _to_mcp_path(field_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_cave_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var cave_name: String = String(params.get("cave_name", "Cave2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var grid_size_result := _parse_vector2i_with_default(params.get("grid_size", null), Vector2i(48, 28))
	if not grid_size_result.get("ok", false):
		return _send_error(client_id, "grid_size must be Vector2i-compatible", command_id)
	var grid_size: Vector2i = grid_size_result.get("value", Vector2i(48, 28))
	if grid_size.x <= 0 or grid_size.y <= 0:
		return _send_error(client_id, "grid_size must be greater than zero on both axes", command_id)

	var cell_size: Vector2 = _parse_vector2_param(params.get("cell_size", Vector2(32.0, 32.0)))
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return _send_error(client_id, "cell_size must be greater than zero on both axes", command_id)

	var fill_ratio: float = clampf(float(params.get("fill_ratio", 0.45)), 0.0, 1.0)
	var smoothing_steps: int = max(0, int(params.get("smoothing_steps", 4)))
	var birth_limit: int = max(0, min(8, int(params.get("birth_limit", 4))))
	var death_limit: int = max(0, min(8, int(params.get("death_limit", 3))))
	var border_solid: bool = bool(params.get("border_solid", true))
	var create_collision: bool = bool(params.get("create_collision", true))
	var create_visuals: bool = bool(params.get("create_visuals", true))
	var create_background: bool = bool(params.get("create_background", true))
	var create_spawn_marker: bool = bool(params.get("create_spawn_marker", true))
	if not create_collision and not create_visuals:
		return _send_error(client_id, "At least one of create_collision or create_visuals must be enabled", command_id)

	if cave_name.is_empty():
		cave_name = "Cave2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var solid_grid: Array = []
	for y in range(grid_size.y):
		var row: Array = []
		for x in range(grid_size.x):
			var is_border := x == 0 or y == 0 or x == (grid_size.x - 1) or y == (grid_size.y - 1)
			var is_solid := border_solid and is_border
			if not is_solid:
				is_solid = rng.randf() < fill_ratio
			row.append(is_solid)
		solid_grid.append(row)

	for _step in range(smoothing_steps):
		var next_grid: Array = []
		for y in range(grid_size.y):
			var next_row: Array = []
			for x in range(grid_size.x):
				var neighbor_walls := 0
				for offset_y in range(-1, 2):
					for offset_x in range(-1, 2):
						if offset_x == 0 and offset_y == 0:
							continue
						var sample_x: int = x + offset_x
						var sample_y: int = y + offset_y
						var sample_is_wall: bool
						if sample_x < 0 or sample_y < 0 or sample_x >= grid_size.x or sample_y >= grid_size.y:
							sample_is_wall = border_solid
						else:
							var sample_row: Array = solid_grid[sample_y]
							sample_is_wall = bool(sample_row[sample_x])
						if sample_is_wall:
							neighbor_walls += 1

				var current_row: Array = solid_grid[y]
				var current_is_wall: bool = bool(current_row[x])
				var next_is_wall: bool
				if current_is_wall:
					next_is_wall = neighbor_walls > death_limit
				else:
					next_is_wall = neighbor_walls > birth_limit
				if border_solid and (x == 0 or y == 0 or x == (grid_size.x - 1) or y == (grid_size.y - 1)):
					next_is_wall = true
				next_row.append(next_is_wall)
			next_grid.append(next_row)
		solid_grid = next_grid

	var wall_cell_count := 0
	for y in range(grid_size.y):
		var row: Array = solid_grid[y]
		for x in range(grid_size.x):
			if bool(row[x]):
				wall_cell_count += 1
	var open_cell_count: int = grid_size.x * grid_size.y - wall_cell_count
	if open_cell_count <= 0:
		var carve_x: int = clampi(grid_size.x / 2, 0, grid_size.x - 1)
		var carve_y: int = clampi(grid_size.y / 2, 0, grid_size.y - 1)
		var carve_row: Array = solid_grid[carve_y]
		carve_row[carve_x] = false
		solid_grid[carve_y] = carve_row
		wall_cell_count = max(0, wall_cell_count - 1)
		open_cell_count = 1

	var spawn_cell := Vector2i(-1, -1)
	for y in range(grid_size.y):
		var row: Array = solid_grid[y]
		for x in range(grid_size.x):
			if not bool(row[x]):
				spawn_cell = Vector2i(x, y)
				break
		if spawn_cell.x >= 0:
			break

	var cave_root := Node2D.new()
	cave_root.name = _resolve_unique_child_name(parent, cave_name)
	cave_root.position = origin

	cave_root.set_meta("mcp_cave_type", "cave_2d")
	cave_root.set_meta("mcp_cave_grid_size", _vector2i_to_dict(grid_size))
	cave_root.set_meta("mcp_cave_cell_size", _vector2_to_dict(cell_size))
	cave_root.set_meta("mcp_cave_fill_ratio", fill_ratio)
	cave_root.set_meta("mcp_cave_smoothing_steps", smoothing_steps)
	cave_root.set_meta("mcp_cave_birth_limit", birth_limit)
	cave_root.set_meta("mcp_cave_death_limit", death_limit)
	cave_root.set_meta("mcp_cave_border_solid", border_solid)
	cave_root.set_meta("mcp_cave_seed", seed_value)
	cave_root.set_meta("mcp_cave_source", "cellular_automata")

	var created_nodes: Array = [cave_root]
	var cave_parent_path: String = _to_mcp_path(parent)
	var predicted_cave_path: String = _join_mcp_path(cave_parent_path, cave_root.name)
	var predicted_paths := {
		"cave_path": predicted_cave_path,
	}

	var background_node = null
	if create_background:
		background_node = Polygon2D.new()
		background_node.name = _resolve_unique_child_name(cave_root, "Background")
		var half_width: float = float(grid_size.x) * cell_size.x * 0.5
		var half_height: float = float(grid_size.y) * cell_size.y * 0.5
		background_node.polygon = PackedVector2Array([
			Vector2(-half_width, -half_height),
			Vector2(half_width, -half_height),
			Vector2(half_width, half_height),
			Vector2(-half_width, half_height),
		])
		background_node.z_index = -1
		background_node.color = _convert_property_value(
			background_node,
			"color",
			params.get("background_color", Color(0.12, 0.11, 0.09, 0.9))
		)
		cave_root.add_child(background_node)
		created_nodes.append(background_node)
		predicted_paths["background_path"] = _join_mcp_path(predicted_cave_path, background_node.name)

	var walls_container := Node2D.new()
	walls_container.name = _resolve_unique_child_name(cave_root, "Walls")
	cave_root.add_child(walls_container)
	created_nodes.append(walls_container)
	predicted_paths["walls_path"] = _join_mcp_path(predicted_cave_path, walls_container.name)

	var wall_segment_count := 0
	var wall_segment_preview: Array = []
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)
	var wall_color_value = params.get("wall_color", Color(0.27, 0.23, 0.18, 1.0))
	var grid_half_x: float = float(grid_size.x) * 0.5
	var grid_half_y: float = float(grid_size.y) * 0.5

	for y in range(grid_size.y):
		var row: Array = solid_grid[y]
		var run_start := -1
		for x in range(grid_size.x + 1):
			var is_wall: bool = x < grid_size.x and bool(row[x])
			if is_wall and run_start < 0:
				run_start = x
			elif (not is_wall) and run_start >= 0:
				var run_length: int = x - run_start
				var segment_size := Vector2(cell_size.x * float(run_length), cell_size.y)
				var center_x: float = (float(run_start) + float(run_length) * 0.5 - grid_half_x) * cell_size.x
				var center_y: float = (float(y) + 0.5 - grid_half_y) * cell_size.y
				var segment_position := Vector2(center_x, center_y)

				var wall_body := StaticBody2D.new()
				wall_segment_count += 1
				wall_body.name = "WallSegment%04d" % wall_segment_count
				wall_body.position = segment_position
				if collision_layer_value != null:
					wall_body.collision_layer = int(collision_layer_value)
				if collision_mask_value != null:
					wall_body.collision_mask = int(collision_mask_value)

				if create_collision:
					var collision := CollisionShape2D.new()
					collision.name = "CollisionShape2D"
					var shape := RectangleShape2D.new()
					shape.size = segment_size
					collision.shape = shape
					wall_body.add_child(collision)
					created_nodes.append(collision)

				if create_visuals:
					var polygon := Polygon2D.new()
					polygon.name = "Visual"
					var half := segment_size * 0.5
					polygon.polygon = PackedVector2Array([
						Vector2(-half.x, -half.y),
						Vector2(half.x, -half.y),
						Vector2(half.x, half.y),
						Vector2(-half.x, half.y),
					])
					polygon.color = _convert_property_value(polygon, "color", wall_color_value)
					wall_body.add_child(polygon)
					created_nodes.append(polygon)

				walls_container.add_child(wall_body)
				created_nodes.append(wall_body)

				if wall_segment_preview.size() < 64:
					wall_segment_preview.append({
						"path": _join_mcp_path(String(predicted_paths["walls_path"]), wall_body.name),
						"row": y,
						"start_column": run_start,
						"run_length": run_length,
						"position": _vector2_to_dict(segment_position),
						"size": _vector2_to_dict(segment_size),
					})
				run_start = -1

	var spawn_marker = null
	var spawn_position := Vector2.ZERO
	if create_spawn_marker and spawn_cell.x >= 0 and spawn_cell.y >= 0:
		spawn_position = Vector2(
			(float(spawn_cell.x) + 0.5 - grid_half_x) * cell_size.x,
			(float(spawn_cell.y) + 0.5 - grid_half_y) * cell_size.y
		)
		spawn_marker = Marker2D.new()
		spawn_marker.name = _resolve_unique_child_name(cave_root, "SpawnPoint")
		spawn_marker.position = spawn_position
		cave_root.add_child(spawn_marker)
		created_nodes.append(spawn_marker)
		predicted_paths["spawn_path"] = _join_mcp_path(predicted_cave_path, spawn_marker.name)

	cave_root.set_meta("mcp_cave_wall_segments", wall_segment_count)
	cave_root.set_meta("mcp_cave_wall_cells", wall_cell_count)
	cave_root.set_meta("mcp_cave_open_cells", open_cell_count)
	if spawn_cell.x >= 0 and spawn_cell.y >= 0:
		cave_root.set_meta("mcp_cave_spawn_cell", _vector2i_to_dict(spawn_cell))
		cave_root.set_meta("mcp_cave_spawn_position", _vector2_to_dict(spawn_position))

	var transaction_metadata := {
		"command": "build_cave_2d",
		"parent_path": cave_parent_path,
		"cave_name": cave_root.name,
		"grid_size": _vector2i_to_dict(grid_size),
		"cell_size": _vector2_to_dict(cell_size),
		"fill_ratio": fill_ratio,
		"smoothing_steps": smoothing_steps,
		"seed": seed_value,
		"wall_cell_count": wall_cell_count,
		"open_cell_count": open_cell_count,
		"wall_segment_count": wall_segment_count,
		"create_collision": create_collision,
		"create_visuals": create_visuals,
		"create_background": create_background,
		"create_spawn_marker": create_spawn_marker,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Cave 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Cave 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for cave generation", command_id)

	transaction.add_do_method(parent, "add_child", [cave_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [cave_root])
	transaction.add_undo_method(cave_root, "queue_free")
	transaction.add_do_reference(cave_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built cave 2D", "_build_cave_2d", {
			"cave_path": _to_mcp_path(cave_root),
			"parent_path": cave_parent_path,
			"grid_size": _vector2i_to_dict(grid_size),
			"cell_size": _vector2_to_dict(cell_size),
			"seed": seed_value,
			"wall_cell_count": wall_cell_count,
			"open_cell_count": open_cell_count,
			"wall_segment_count": wall_segment_count,
			"transaction_id": transaction.transaction_id,
			"system_section": "cave_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": cave_parent_path,
		"cave_name": cave_root.name,
		"cave_path": predicted_paths.get("cave_path", ""),
		"origin": _vector2_to_dict(origin),
		"grid_size": _vector2i_to_dict(grid_size),
		"cell_size": _vector2_to_dict(cell_size),
		"fill_ratio": fill_ratio,
		"smoothing_steps": smoothing_steps,
		"birth_limit": birth_limit,
		"death_limit": death_limit,
		"border_solid": border_solid,
		"seed": seed_value,
		"wall_cell_count": wall_cell_count,
		"open_cell_count": open_cell_count,
		"wall_segment_count": wall_segment_count,
		"spawn_cell": _vector2i_to_dict(spawn_cell) if spawn_cell.x >= 0 and spawn_cell.y >= 0 else {},
		"spawn_position": _vector2_to_dict(spawn_position) if spawn_cell.x >= 0 and spawn_cell.y >= 0 else {},
		"paths": predicted_paths,
		"segment_preview": wall_segment_preview,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit cave generation", command_id)
		var committed_paths := {
			"cave_path": _to_mcp_path(cave_root),
			"walls_path": _to_mcp_path(walls_container),
		}
		if background_node:
			committed_paths["background_path"] = _to_mcp_path(background_node)
		if spawn_marker:
			committed_paths["spawn_path"] = _to_mcp_path(spawn_marker)
		response["cave_path"] = _to_mcp_path(cave_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_sand_field_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var field_name: String = String(params.get("field_name", "SandField2D")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))
	var size: Vector2 = _parse_vector2_param(params.get("size", Vector2(960.0, 320.0)))
	var create_volume_area: bool = bool(params.get("create_volume_area", true))
	var create_visual: bool = bool(params.get("create_visual", true))

	if field_name.is_empty():
		field_name = "SandField2D"
	if size.x <= 0.0 or size.y <= 0.0:
		return _send_error(client_id, "size must be greater than zero on both axes", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var grain_spacing: float = max(1.0, float(params.get("grain_spacing", 18.0)))
	var grain_radius: float = max(0.5, float(params.get("grain_radius", grain_spacing * 0.35)))
	var jitter: float = clampf(float(params.get("jitter", grain_spacing * 0.22)), 0.0, grain_spacing * 0.5)
	var max_grains: int = max(1, int(params.get("max_grains", 640)))
	var random_rotation: bool = bool(params.get("random_rotation", true))
	var grain_segments: int = max(3, min(24, int(params.get("grain_segments", 10))))
	var grain_color_value = params.get("grain_color", Color(0.83, 0.72, 0.45, 0.92))

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var internal_friction: float = max(0.0, float(params.get("internal_friction", 0.9)))
	var cohesion: float = max(0.0, float(params.get("cohesion", 0.18)))
	var stiffness: float = max(0.0, float(params.get("stiffness", 1300.0)))
	var bulk_density: float = max(0.0, float(params.get("bulk_density", 1600.0)))
	var profile_name: String = String(params.get("profile_name", "homogenized_sand_2d")).strip_edges()
	if profile_name.is_empty():
		profile_name = "homogenized_sand_2d"
	var source_reference: String = String(params.get("source_reference", "homogenized_granular_2d")).strip_edges()
	if source_reference.is_empty():
		source_reference = "homogenized_granular_2d"

	var field_root := Node2D.new()
	field_root.name = _resolve_unique_child_name(parent, field_name)
	field_root.position = origin

	field_root.set_meta("mcp_granular_profile", profile_name)
	field_root.set_meta("mcp_granular_internal_friction", internal_friction)
	field_root.set_meta("mcp_granular_cohesion", cohesion)
	field_root.set_meta("mcp_granular_stiffness", stiffness)
	field_root.set_meta("mcp_granular_bulk_density", bulk_density)
	field_root.set_meta("mcp_granular_source", source_reference)
	field_root.set_meta("mcp_granular_dimension", "2d")
	field_root.set_meta("mcp_granular_size_2d", _vector2_to_dict(size))
	field_root.set_meta("mcp_granular_spacing", grain_spacing)

	var created_nodes: Array = [field_root]
	var predicted_paths: Dictionary = {}
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_field_path: String = _join_mcp_path(parent_mcp_path, field_root.name)
	predicted_paths["field_path"] = predicted_field_path

	var grain_count := 0
	var grains_container = null
	if create_visual:
		grains_container = Node2D.new()
		grains_container.name = _resolve_unique_child_name(field_root, "SandGrains2D")

		var nx := max(1, int(floor(size.x / grain_spacing)) + 1)
		var ny := max(1, int(floor(size.y / grain_spacing)) + 1)
		var grain_polygon_template := PackedVector2Array()
		for point_idx in range(grain_segments):
			var angle := TAU * float(point_idx) / float(grain_segments)
			grain_polygon_template.append(Vector2(cos(angle), sin(angle)) * grain_radius)

		for y_idx in range(ny):
			for x_idx in range(nx):
				if grain_count >= max_grains:
					break
				var point := Vector2(
					-size.x * 0.5 + float(x_idx) * grain_spacing,
					-size.y * 0.5 + float(y_idx) * grain_spacing
				)
				if jitter > 0.0:
					point.x = clampf(point.x + rng.randf_range(-jitter, jitter), -size.x * 0.5, size.x * 0.5)
					point.y = clampf(point.y + rng.randf_range(-jitter, jitter), -size.y * 0.5, size.y * 0.5)

				var grain := Polygon2D.new()
				grain.name = "Grain%04d" % (grain_count + 1)
				grain.polygon = grain_polygon_template
				grain.position = point
				if random_rotation:
					grain.rotation = deg_to_rad(rng.randf_range(-180.0, 180.0))
				grain.color = _convert_property_value(grain, "color", grain_color_value)

				grains_container.add_child(grain)
				created_nodes.append(grain)
				grain_count += 1
			if grain_count >= max_grains:
				break

		if grain_count <= 0:
			return _send_error(client_id, "Failed to generate any 2D grains with requested parameters", command_id)

		field_root.add_child(grains_container)
		created_nodes.append(grains_container)
		predicted_paths["grains_path"] = _join_mcp_path(predicted_field_path, grains_container.name)

	if create_volume_area:
		var area := Area2D.new()
		area.name = _resolve_unique_child_name(field_root, "SandVolumeArea2D")
		area.monitoring = true
		area.monitorable = true
		if params.has("collision_layer"):
			area.collision_layer = int(params.get("collision_layer"))
		if params.has("collision_mask"):
			area.collision_mask = int(params.get("collision_mask"))

		var collision := CollisionShape2D.new()
		collision.name = _resolve_unique_child_name(area, "CollisionShape2D")
		var shape := RectangleShape2D.new()
		shape.size = size
		collision.shape = shape
		area.add_child(collision)

		field_root.add_child(area)
		created_nodes.append(area)
		created_nodes.append(collision)
		predicted_paths["volume_area_path"] = _join_mcp_path(predicted_field_path, area.name)
		predicted_paths["collision_path"] = _join_mcp_path(String(predicted_paths["volume_area_path"]), collision.name)

	field_root.set_meta("mcp_grain_count", grain_count)

	var transaction_metadata := {
		"command": "build_sand_field_2d",
		"parent_path": parent_mcp_path,
		"field_name": field_root.name,
		"grain_count": grain_count,
		"grain_spacing": grain_spacing,
		"seed": seed_value,
		"create_visual": create_visual,
		"create_volume_area": create_volume_area,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Sand Field 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Sand Field 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D sand field generation", command_id)

	transaction.add_do_method(parent, "add_child", [field_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [field_root])
	transaction.add_undo_method(field_root, "queue_free")
	transaction.add_do_reference(field_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built sand field 2D", "_build_sand_field_2d", {
			"field_path": _to_mcp_path(field_root),
			"parent_path": parent_mcp_path,
			"grain_count": grain_count,
			"grain_spacing": grain_spacing,
			"seed": seed_value,
			"create_visual": create_visual,
			"create_volume_area": create_volume_area,
			"transaction_id": transaction.transaction_id,
			"system_section": "granular_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"field_name": field_root.name,
		"field_path": predicted_paths.get("field_path", ""),
		"origin": _vector2_to_dict(origin),
		"size": _vector2_to_dict(size),
		"grain_count": grain_count,
		"grain_spacing": grain_spacing,
		"grain_radius": grain_radius,
		"seed": seed_value,
		"profile_name": profile_name,
		"internal_friction": internal_friction,
		"cohesion": cohesion,
		"stiffness": stiffness,
		"bulk_density": bulk_density,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D sand field generation", command_id)
		var committed_paths := {
			"field_path": _to_mcp_path(field_root),
		}
		if create_visual and grains_container:
			committed_paths["grains_path"] = _to_mcp_path(grains_container)
		if create_volume_area:
			var area_node = field_root.get_node_or_null("SandVolumeArea2D")
			if area_node:
				committed_paths["volume_area_path"] = _to_mcp_path(area_node)
			var collision_node = field_root.get_node_or_null("SandVolumeArea2D/CollisionShape2D")
			if collision_node:
				committed_paths["collision_path"] = _to_mcp_path(collision_node)
		response["field_path"] = _to_mcp_path(field_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _generate_platformer_blockout_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var level_name: String = String(params.get("level_name", "PlatformerBlockout2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var segment_count: int = clampi(int(params.get("segment_count", 18)), 1, 512)
	var min_platform_width: float = max(8.0, float(params.get("min_platform_width", 96.0)))
	var max_platform_width: float = max(min_platform_width, float(params.get("max_platform_width", 224.0)))
	var platform_height: float = max(4.0, float(params.get("platform_height", 32.0)))
	var min_gap: float = max(0.0, float(params.get("min_gap", 36.0)))
	var max_gap: float = max(min_gap, float(params.get("max_gap", 132.0)))
	var base_y: float = float(params.get("base_y", 240.0))
	var min_height_step: float = float(params.get("min_height_step", -64.0))
	var max_height_step: float = float(params.get("max_height_step", 64.0))
	if max_height_step < min_height_step:
		var swap := min_height_step
		min_height_step = max_height_step
		max_height_step = swap
	var min_y: float = float(params.get("min_y", base_y - 220.0))
	var max_y: float = float(params.get("max_y", base_y + 220.0))
	if max_y < min_y:
		var y_swap := min_y
		min_y = max_y
		max_y = y_swap

	var create_collision: bool = bool(params.get("create_collision", true))
	var create_visuals: bool = bool(params.get("create_visuals", true))
	if not create_collision and not create_visuals:
		return _send_error(client_id, "At least one of create_collision or create_visuals must be enabled", command_id)
	var create_spawn_marker: bool = bool(params.get("create_spawn_marker", true))
	var create_goal_marker: bool = bool(params.get("create_goal_marker", true))

	if level_name.is_empty():
		level_name = "PlatformerBlockout2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var level_root := Node2D.new()
	level_root.name = _resolve_unique_child_name(parent, level_name)
	level_root.position = origin
	level_root.set_meta("mcp_level_type", "platformer_blockout_2d")
	level_root.set_meta("mcp_platformer_seed", seed_value)
	level_root.set_meta("mcp_platformer_segment_count", segment_count)
	level_root.set_meta("mcp_platformer_platform_height", platform_height)
	level_root.set_meta("mcp_platformer_gap_range", {"min": min_gap, "max": max_gap})
	level_root.set_meta("mcp_platformer_source", "procedural_blockout")

	var created_nodes: Array = [level_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_level_path: String = _join_mcp_path(parent_mcp_path, level_root.name)
	var predicted_paths := {
		"level_path": predicted_level_path,
	}

	var platforms_container := Node2D.new()
	platforms_container.name = _resolve_unique_child_name(level_root, "Platforms")
	level_root.add_child(platforms_container)
	created_nodes.append(platforms_container)
	predicted_paths["platforms_path"] = _join_mcp_path(predicted_level_path, platforms_container.name)

	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)
	var platform_color_value = params.get("platform_color", Color(0.34, 0.36, 0.41, 0.95))

	var x_cursor := 0.0
	var current_y := clampf(base_y, min_y, max_y)
	var platform_preview: Array = []
	var total_walkable_length := 0.0
	var last_gap := 0.0
	var spawn_position := Vector2.ZERO
	var goal_position := Vector2.ZERO

	for idx in range(segment_count):
		if idx > 0:
			current_y = clampf(current_y + rng.randf_range(min_height_step, max_height_step), min_y, max_y)
		var platform_width := rng.randf_range(min_platform_width, max_platform_width)
		var center := Vector2(x_cursor + platform_width * 0.5, current_y)

		var platform_body := StaticBody2D.new()
		platform_body.name = "Platform%03d" % (idx + 1)
		platform_body.position = center
		if collision_layer_value != null:
			platform_body.collision_layer = int(collision_layer_value)
		if collision_mask_value != null:
			platform_body.collision_mask = int(collision_mask_value)

		if create_collision:
			var collision := CollisionShape2D.new()
			collision.name = "CollisionShape2D"
			var shape := RectangleShape2D.new()
			shape.size = Vector2(platform_width, platform_height)
			collision.shape = shape
			platform_body.add_child(collision)
			created_nodes.append(collision)

		if create_visuals:
			var polygon := Polygon2D.new()
			polygon.name = "Visual"
			var half := Vector2(platform_width * 0.5, platform_height * 0.5)
			polygon.polygon = PackedVector2Array([
				Vector2(-half.x, -half.y),
				Vector2(half.x, -half.y),
				Vector2(half.x, half.y),
				Vector2(-half.x, half.y),
			])
			polygon.color = _convert_property_value(polygon, "color", platform_color_value)
			platform_body.add_child(polygon)
			created_nodes.append(polygon)

		platforms_container.add_child(platform_body)
		created_nodes.append(platform_body)

		var marker_y := center.y - platform_height * 0.5 - 16.0
		if idx == 0:
			spawn_position = Vector2(center.x - platform_width * 0.35, marker_y)
		if idx == segment_count - 1:
			goal_position = Vector2(center.x + platform_width * 0.35, marker_y)

		if platform_preview.size() < 64:
			platform_preview.append({
				"path": _join_mcp_path(String(predicted_paths["platforms_path"]), platform_body.name),
				"index": idx,
				"position": _vector2_to_dict(center),
				"size": _vector2_to_dict(Vector2(platform_width, platform_height)),
			})

		total_walkable_length += platform_width
		var gap := rng.randf_range(min_gap, max_gap)
		last_gap = gap
		x_cursor += platform_width + gap

	if segment_count <= 1:
		last_gap = 0.0

	var spawn_marker = null
	if create_spawn_marker:
		spawn_marker = Marker2D.new()
		spawn_marker.name = _resolve_unique_child_name(level_root, "SpawnPoint")
		spawn_marker.position = spawn_position
		level_root.add_child(spawn_marker)
		created_nodes.append(spawn_marker)
		predicted_paths["spawn_path"] = _join_mcp_path(predicted_level_path, spawn_marker.name)

	var goal_marker = null
	if create_goal_marker:
		goal_marker = Marker2D.new()
		goal_marker.name = _resolve_unique_child_name(level_root, "GoalPoint")
		goal_marker.position = goal_position
		level_root.add_child(goal_marker)
		created_nodes.append(goal_marker)
		predicted_paths["goal_path"] = _join_mcp_path(predicted_level_path, goal_marker.name)

	var estimated_total_length := max(0.0, x_cursor - last_gap)
	level_root.set_meta("mcp_platformer_total_length", estimated_total_length)
	level_root.set_meta("mcp_platformer_spawn_position", _vector2_to_dict(spawn_position))
	level_root.set_meta("mcp_platformer_goal_position", _vector2_to_dict(goal_position))

	var transaction_metadata := {
		"command": "generate_platformer_blockout_2d",
		"parent_path": parent_mcp_path,
		"level_name": level_root.name,
		"segment_count": segment_count,
		"seed": seed_value,
		"total_walkable_length": total_walkable_length,
		"estimated_total_length": estimated_total_length,
		"create_collision": create_collision,
		"create_visuals": create_visuals,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Platformer Blockout 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Platformer Blockout 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for platformer blockout generation", command_id)

	transaction.add_do_method(parent, "add_child", [level_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [level_root])
	transaction.add_undo_method(level_root, "queue_free")
	transaction.add_do_reference(level_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated platformer blockout 2D", "_generate_platformer_blockout_2d", {
			"level_path": _to_mcp_path(level_root),
			"parent_path": parent_mcp_path,
			"segment_count": segment_count,
			"seed": seed_value,
			"total_walkable_length": total_walkable_length,
			"estimated_total_length": estimated_total_length,
			"transaction_id": transaction.transaction_id,
			"system_section": "platformer_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"level_name": level_root.name,
		"level_path": predicted_paths.get("level_path", ""),
		"origin": _vector2_to_dict(origin),
		"segment_count": segment_count,
		"platform_height": platform_height,
		"seed": seed_value,
		"total_walkable_length": total_walkable_length,
		"estimated_total_length": estimated_total_length,
		"spawn_position": _vector2_to_dict(spawn_position),
		"goal_position": _vector2_to_dict(goal_position),
		"platform_preview": platform_preview,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit platformer blockout generation", command_id)
		var committed_paths := {
			"level_path": _to_mcp_path(level_root),
			"platforms_path": _to_mcp_path(platforms_container),
		}
		if spawn_marker:
			committed_paths["spawn_path"] = _to_mcp_path(spawn_marker)
		if goal_marker:
			committed_paths["goal_path"] = _to_mcp_path(goal_marker)
		response["level_path"] = _to_mcp_path(level_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _generate_topdown_dungeon_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var dungeon_name: String = String(params.get("dungeon_name", "TopdownDungeon2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var grid_size_result := _parse_vector2i_with_default(params.get("grid_size", null), Vector2i(64, 64))
	if not grid_size_result.get("ok", false):
		return _send_error(client_id, "grid_size must be Vector2i-compatible", command_id)
	var grid_size: Vector2i = grid_size_result.get("value", Vector2i(64, 64))
	if grid_size.x <= 0 or grid_size.y <= 0:
		return _send_error(client_id, "grid_size must be greater than zero on both axes", command_id)
	if grid_size.x * grid_size.y > 262144:
		return _send_error(client_id, "grid_size is too large; keep total cells <= 262144", command_id)

	var cell_size: Vector2 = _parse_vector2_param(params.get("cell_size", Vector2(24.0, 24.0)))
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return _send_error(client_id, "cell_size must be greater than zero on both axes", command_id)

	var room_attempts: int = clampi(int(params.get("room_attempts", 96)), 1, 2000)
	var room_target: int = clampi(int(params.get("room_target", 12)), 1, 512)
	var corridor_width: int = clampi(int(params.get("corridor_width", 2)), 1, 8)
	var border_walls: bool = bool(params.get("border_walls", true))
	var create_floor_visuals: bool = bool(params.get("create_floor_visuals", true))
	var create_wall_collision: bool = bool(params.get("create_wall_collision", true))
	var create_wall_visuals: bool = bool(params.get("create_wall_visuals", true))
	var create_spawn_marker: bool = bool(params.get("create_spawn_marker", true))
	var create_goal_marker: bool = bool(params.get("create_goal_marker", true))
	if not create_floor_visuals and not create_wall_collision and not create_wall_visuals:
		return _send_error(client_id, "At least one visual/collision output must be enabled", command_id)

	var room_min_result := _parse_vector2i_with_default(params.get("room_min_size", null), Vector2i(6, 6))
	if not room_min_result.get("ok", false):
		return _send_error(client_id, "room_min_size must be Vector2i-compatible", command_id)
	var room_max_result := _parse_vector2i_with_default(params.get("room_max_size", null), Vector2i(14, 14))
	if not room_max_result.get("ok", false):
		return _send_error(client_id, "room_max_size must be Vector2i-compatible", command_id)
	var room_min_size: Vector2i = room_min_result.get("value", Vector2i(6, 6))
	var room_max_size: Vector2i = room_max_result.get("value", Vector2i(14, 14))
	room_min_size.x = max(3, room_min_size.x)
	room_min_size.y = max(3, room_min_size.y)
	room_max_size.x = max(room_min_size.x, room_max_size.x)
	room_max_size.y = max(room_min_size.y, room_max_size.y)
	if room_min_size.x >= grid_size.x - 2 or room_min_size.y >= grid_size.y - 2:
		return _send_error(client_id, "room_min_size is too large for the selected grid_size", command_id)

	if dungeon_name.is_empty():
		dungeon_name = "TopdownDungeon2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var floor_grid: Array = []
	for y in range(grid_size.y):
		var row: Array = []
		row.resize(grid_size.x)
		for x in range(grid_size.x):
			row[x] = false
		floor_grid.append(row)

	var rooms: Array = []
	for _attempt in range(room_attempts):
		if rooms.size() >= room_target:
			break
		var width := rng.randi_range(room_min_size.x, room_max_size.x)
		var height := rng.randi_range(room_min_size.y, room_max_size.y)
		if width >= grid_size.x - 2 or height >= grid_size.y - 2:
			continue

		var min_x := 1
		var max_x := grid_size.x - width - 1
		var min_y := 1
		var max_y := grid_size.y - height - 1
		if max_x < min_x or max_y < min_y:
			continue
		var room_x := rng.randi_range(min_x, max_x)
		var room_y := rng.randi_range(min_y, max_y)

		var intersects_existing := false
		for room_data in rooms:
			var existing: Dictionary = room_data
			var ex: int = int(existing.get("x", 0))
			var ey: int = int(existing.get("y", 0))
			var ew: int = int(existing.get("w", 0))
			var eh: int = int(existing.get("h", 0))
			var separated := (
				room_x + width + 1 <= ex or
				ex + ew + 1 <= room_x or
				room_y + height + 1 <= ey or
				ey + eh + 1 <= room_y
			)
			if not separated:
				intersects_existing = true
				break
		if intersects_existing:
			continue

		var center := Vector2i(room_x + int(width / 2), room_y + int(height / 2))
		rooms.append({
			"x": room_x,
			"y": room_y,
			"w": width,
			"h": height,
			"center": center,
		})

		for yy in range(room_y, room_y + height):
			var floor_row: Array = floor_grid[yy]
			for xx in range(room_x, room_x + width):
				floor_row[xx] = true
			floor_grid[yy] = floor_row

	if rooms.is_empty():
		return _send_error(client_id, "Failed to place any rooms with the requested constraints", command_id)

	var corridor_half_low: int = int(floor(float(corridor_width) * 0.5))
	var corridor_half_high: int = corridor_width - corridor_half_low - 1
	var corridor_count := 0
	for room_idx in range(1, rooms.size()):
		var from_room: Dictionary = rooms[room_idx - 1]
		var to_room: Dictionary = rooms[room_idx]
		var from_center: Vector2i = from_room.get("center", Vector2i.ZERO)
		var to_center: Vector2i = to_room.get("center", Vector2i.ZERO)
		var carve_horizontal_first: bool = rng.randf() < 0.5

		if carve_horizontal_first:
			var x_start := min(from_center.x, to_center.x)
			var x_end := max(from_center.x, to_center.x)
			for xx in range(x_start, x_end + 1):
				for y_offset in range(-corridor_half_low, corridor_half_high + 1):
					var yy := from_center.y + y_offset
					if xx >= 0 and yy >= 0 and xx < grid_size.x and yy < grid_size.y:
						var floor_row: Array = floor_grid[yy]
						floor_row[xx] = true
						floor_grid[yy] = floor_row
			var y_start := min(from_center.y, to_center.y)
			var y_end := max(from_center.y, to_center.y)
			for yy in range(y_start, y_end + 1):
				for x_offset in range(-corridor_half_low, corridor_half_high + 1):
					var xx := to_center.x + x_offset
					if xx >= 0 and yy >= 0 and xx < grid_size.x and yy < grid_size.y:
						var floor_row: Array = floor_grid[yy]
						floor_row[xx] = true
						floor_grid[yy] = floor_row
		else:
			var y_start_alt := min(from_center.y, to_center.y)
			var y_end_alt := max(from_center.y, to_center.y)
			for yy in range(y_start_alt, y_end_alt + 1):
				for x_offset in range(-corridor_half_low, corridor_half_high + 1):
					var xx := from_center.x + x_offset
					if xx >= 0 and yy >= 0 and xx < grid_size.x and yy < grid_size.y:
						var floor_row: Array = floor_grid[yy]
						floor_row[xx] = true
						floor_grid[yy] = floor_row
			var x_start_alt := min(from_center.x, to_center.x)
			var x_end_alt := max(from_center.x, to_center.x)
			for xx in range(x_start_alt, x_end_alt + 1):
				for y_offset in range(-corridor_half_low, corridor_half_high + 1):
					var yy := to_center.y + y_offset
					if xx >= 0 and yy >= 0 and xx < grid_size.x and yy < grid_size.y:
						var floor_row: Array = floor_grid[yy]
						floor_row[xx] = true
						floor_grid[yy] = floor_row
		corridor_count += 1

	var wall_grid: Array = []
	var floor_cell_count := 0
	var wall_cell_count := 0
	for y in range(grid_size.y):
		var wall_row: Array = []
		var floor_row: Array = floor_grid[y]
		for x in range(grid_size.x):
			var is_floor: bool = bool(floor_row[x])
			if is_floor:
				floor_cell_count += 1
				wall_row.append(false)
				continue

			var is_border := x == 0 or y == 0 or x == grid_size.x - 1 or y == grid_size.y - 1
			var is_wall := border_walls and is_border
			if not is_wall:
				for y_offset in range(-1, 2):
					for x_offset in range(-1, 2):
						if x_offset == 0 and y_offset == 0:
							continue
						var sx := x + x_offset
						var sy := y + y_offset
						if sx < 0 or sy < 0 or sx >= grid_size.x or sy >= grid_size.y:
							if border_walls:
								is_wall = true
								break
						else:
							var sample_row: Array = floor_grid[sy]
							if bool(sample_row[sx]):
								is_wall = true
								break
					if is_wall:
						break
			wall_row.append(is_wall)
			if is_wall:
				wall_cell_count += 1
		wall_grid.append(wall_row)

	var dungeon_root := Node2D.new()
	dungeon_root.name = _resolve_unique_child_name(parent, dungeon_name)
	dungeon_root.position = origin
	dungeon_root.set_meta("mcp_level_type", "topdown_dungeon_2d")
	dungeon_root.set_meta("mcp_dungeon_seed", seed_value)
	dungeon_root.set_meta("mcp_dungeon_grid_size", _vector2i_to_dict(grid_size))
	dungeon_root.set_meta("mcp_dungeon_cell_size", _vector2_to_dict(cell_size))
	dungeon_root.set_meta("mcp_dungeon_room_count", rooms.size())
	dungeon_root.set_meta("mcp_dungeon_corridor_count", corridor_count)
	dungeon_root.set_meta("mcp_dungeon_floor_cells", floor_cell_count)
	dungeon_root.set_meta("mcp_dungeon_wall_cells", wall_cell_count)

	var created_nodes: Array = [dungeon_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_dungeon_path: String = _join_mcp_path(parent_mcp_path, dungeon_root.name)
	var predicted_paths := {
		"dungeon_path": predicted_dungeon_path,
	}

	var floor_container = null
	if create_floor_visuals:
		floor_container = Node2D.new()
		floor_container.name = _resolve_unique_child_name(dungeon_root, "Floor")
		dungeon_root.add_child(floor_container)
		created_nodes.append(floor_container)
		predicted_paths["floor_path"] = _join_mcp_path(predicted_dungeon_path, floor_container.name)

	var wall_container := Node2D.new()
	wall_container.name = _resolve_unique_child_name(dungeon_root, "Walls")
	dungeon_root.add_child(wall_container)
	created_nodes.append(wall_container)
	predicted_paths["walls_path"] = _join_mcp_path(predicted_dungeon_path, wall_container.name)

	var floor_color_value = params.get("floor_color", Color(0.24, 0.24, 0.2, 0.9))
	var wall_color_value = params.get("wall_color", Color(0.18, 0.19, 0.23, 0.95))
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)
	var grid_half_x: float = float(grid_size.x) * 0.5
	var grid_half_y: float = float(grid_size.y) * 0.5

	var floor_segment_count := 0
	var wall_segment_count := 0
	for y in range(grid_size.y):
		var floor_row: Array = floor_grid[y]
		var floor_run_start := -1
		for x in range(grid_size.x + 1):
			var is_floor := x < grid_size.x and bool(floor_row[x])
			if is_floor and floor_run_start < 0:
				floor_run_start = x
			elif (not is_floor) and floor_run_start >= 0:
				if create_floor_visuals:
					var floor_run_len := x - floor_run_start
					var floor_size := Vector2(float(floor_run_len) * cell_size.x, cell_size.y)
					var floor_center := Vector2(
						(float(floor_run_start) + float(floor_run_len) * 0.5 - grid_half_x) * cell_size.x,
						(float(y) + 0.5 - grid_half_y) * cell_size.y
					)
					var floor_poly := Polygon2D.new()
					floor_segment_count += 1
					floor_poly.name = "FloorSegment%04d" % floor_segment_count
					floor_poly.position = floor_center
					var floor_half := floor_size * 0.5
					floor_poly.polygon = PackedVector2Array([
						Vector2(-floor_half.x, -floor_half.y),
						Vector2(floor_half.x, -floor_half.y),
						Vector2(floor_half.x, floor_half.y),
						Vector2(-floor_half.x, floor_half.y),
					])
					floor_poly.color = _convert_property_value(floor_poly, "color", floor_color_value)
					floor_container.add_child(floor_poly)
					created_nodes.append(floor_poly)
				floor_run_start = -1

		var wall_row: Array = wall_grid[y]
		var wall_run_start := -1
		for x in range(grid_size.x + 1):
			var is_wall := x < grid_size.x and bool(wall_row[x])
			if is_wall and wall_run_start < 0:
				wall_run_start = x
			elif (not is_wall) and wall_run_start >= 0:
				var wall_run_len := x - wall_run_start
				var wall_size := Vector2(float(wall_run_len) * cell_size.x, cell_size.y)
				var wall_center := Vector2(
					(float(wall_run_start) + float(wall_run_len) * 0.5 - grid_half_x) * cell_size.x,
					(float(y) + 0.5 - grid_half_y) * cell_size.y
				)

				var wall_body := StaticBody2D.new()
				wall_segment_count += 1
				wall_body.name = "WallSegment%04d" % wall_segment_count
				wall_body.position = wall_center
				if collision_layer_value != null:
					wall_body.collision_layer = int(collision_layer_value)
				if collision_mask_value != null:
					wall_body.collision_mask = int(collision_mask_value)

				if create_wall_collision:
					var collision := CollisionShape2D.new()
					collision.name = "CollisionShape2D"
					var shape := RectangleShape2D.new()
					shape.size = wall_size
					collision.shape = shape
					wall_body.add_child(collision)
					created_nodes.append(collision)

				if create_wall_visuals:
					var polygon := Polygon2D.new()
					polygon.name = "Visual"
					var wall_half := wall_size * 0.5
					polygon.polygon = PackedVector2Array([
						Vector2(-wall_half.x, -wall_half.y),
						Vector2(wall_half.x, -wall_half.y),
						Vector2(wall_half.x, wall_half.y),
						Vector2(-wall_half.x, wall_half.y),
					])
					polygon.color = _convert_property_value(polygon, "color", wall_color_value)
					wall_body.add_child(polygon)
					created_nodes.append(polygon)

				wall_container.add_child(wall_body)
				created_nodes.append(wall_body)
				wall_run_start = -1

	var room_preview: Array = []
	for room_idx in range(min(rooms.size(), 64)):
		var room_data: Dictionary = rooms[room_idx]
		var room_center: Vector2i = room_data.get("center", Vector2i.ZERO)
		var local_center := Vector2(
			(float(room_center.x) + 0.5 - grid_half_x) * cell_size.x,
			(float(room_center.y) + 0.5 - grid_half_y) * cell_size.y
		)
		room_preview.append({
			"index": room_idx,
			"x": int(room_data.get("x", 0)),
			"y": int(room_data.get("y", 0)),
			"w": int(room_data.get("w", 0)),
			"h": int(room_data.get("h", 0)),
			"center_cell": _vector2i_to_dict(room_center),
			"center_position": _vector2_to_dict(local_center),
		})

	var spawn_marker = null
	var goal_marker = null
	var spawn_position := Vector2.ZERO
	var goal_position := Vector2.ZERO
	if create_spawn_marker and rooms.size() > 0:
		var first_room: Dictionary = rooms[0]
		var first_center: Vector2i = first_room.get("center", Vector2i.ZERO)
		spawn_position = Vector2(
			(float(first_center.x) + 0.5 - grid_half_x) * cell_size.x,
			(float(first_center.y) + 0.5 - grid_half_y) * cell_size.y
		)
		spawn_marker = Marker2D.new()
		spawn_marker.name = _resolve_unique_child_name(dungeon_root, "SpawnPoint")
		spawn_marker.position = spawn_position
		dungeon_root.add_child(spawn_marker)
		created_nodes.append(spawn_marker)
		predicted_paths["spawn_path"] = _join_mcp_path(predicted_dungeon_path, spawn_marker.name)

	if create_goal_marker and rooms.size() > 0:
		var last_room: Dictionary = rooms[rooms.size() - 1]
		var last_center: Vector2i = last_room.get("center", Vector2i.ZERO)
		goal_position = Vector2(
			(float(last_center.x) + 0.5 - grid_half_x) * cell_size.x,
			(float(last_center.y) + 0.5 - grid_half_y) * cell_size.y
		)
		goal_marker = Marker2D.new()
		goal_marker.name = _resolve_unique_child_name(dungeon_root, "GoalPoint")
		goal_marker.position = goal_position
		dungeon_root.add_child(goal_marker)
		created_nodes.append(goal_marker)
		predicted_paths["goal_path"] = _join_mcp_path(predicted_dungeon_path, goal_marker.name)

	var transaction_metadata := {
		"command": "generate_topdown_dungeon_2d",
		"parent_path": parent_mcp_path,
		"dungeon_name": dungeon_root.name,
		"grid_size": _vector2i_to_dict(grid_size),
		"cell_size": _vector2_to_dict(cell_size),
		"room_count": rooms.size(),
		"corridor_count": corridor_count,
		"floor_cell_count": floor_cell_count,
		"wall_cell_count": wall_cell_count,
		"seed": seed_value,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Topdown Dungeon 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Topdown Dungeon 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for topdown dungeon generation", command_id)

	transaction.add_do_method(parent, "add_child", [dungeon_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [dungeon_root])
	transaction.add_undo_method(dungeon_root, "queue_free")
	transaction.add_do_reference(dungeon_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated topdown dungeon 2D", "_generate_topdown_dungeon_2d", {
			"dungeon_path": _to_mcp_path(dungeon_root),
			"parent_path": parent_mcp_path,
			"grid_size": _vector2i_to_dict(grid_size),
			"room_count": rooms.size(),
			"corridor_count": corridor_count,
			"floor_cell_count": floor_cell_count,
			"wall_cell_count": wall_cell_count,
			"transaction_id": transaction.transaction_id,
			"system_section": "topdown_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"dungeon_name": dungeon_root.name,
		"dungeon_path": predicted_paths.get("dungeon_path", ""),
		"origin": _vector2_to_dict(origin),
		"grid_size": _vector2i_to_dict(grid_size),
		"cell_size": _vector2_to_dict(cell_size),
		"room_count": rooms.size(),
		"corridor_count": corridor_count,
		"floor_cell_count": floor_cell_count,
		"wall_cell_count": wall_cell_count,
		"floor_segment_count": floor_segment_count,
		"wall_segment_count": wall_segment_count,
		"seed": seed_value,
		"spawn_position": _vector2_to_dict(spawn_position) if create_spawn_marker else {},
		"goal_position": _vector2_to_dict(goal_position) if create_goal_marker else {},
		"room_preview": room_preview,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit topdown dungeon generation", command_id)
		var committed_paths := {
			"dungeon_path": _to_mcp_path(dungeon_root),
			"walls_path": _to_mcp_path(wall_container),
		}
		if floor_container:
			committed_paths["floor_path"] = _to_mcp_path(floor_container)
		if spawn_marker:
			committed_paths["spawn_path"] = _to_mcp_path(spawn_marker)
		if goal_marker:
			committed_paths["goal_path"] = _to_mcp_path(goal_marker)
		response["dungeon_path"] = _to_mcp_path(dungeon_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _generate_isometric_tile_blockout_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var level_name: String = String(params.get("level_name", "IsometricTileBlockout2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var grid_size_result := _parse_vector2i_with_default(params.get("grid_size", null), Vector2i(16, 16))
	if not grid_size_result.get("ok", false):
		return _send_error(client_id, "grid_size must be Vector2i-compatible", command_id)
	var grid_size: Vector2i = grid_size_result.get("value", Vector2i(16, 16))
	if grid_size.x <= 0 or grid_size.y <= 0:
		return _send_error(client_id, "grid_size must be greater than zero on both axes", command_id)

	var max_tiles: int = max(1, int(params.get("max_tiles", 1024)))
	var tile_count: int = grid_size.x * grid_size.y
	if tile_count > max_tiles:
		return _send_error(client_id, "Requested grid_size exceeds max_tiles (%d > %d)" % [tile_count, max_tiles], command_id)

	var tile_size: Vector2 = _parse_vector2_param(params.get("tile_size", Vector2(96.0, 48.0)))
	if tile_size.x <= 0.0 or tile_size.y <= 0.0:
		return _send_error(client_id, "tile_size must be greater than zero on both axes", command_id)
	var elevation_step: float = max(0.1, float(params.get("elevation_step", tile_size.y * 0.5)))

	var min_height: int = int(params.get("min_height", 0))
	var max_height: int = int(params.get("max_height", 3))
	if max_height < min_height:
		var h_swap := min_height
		min_height = max_height
		max_height = h_swap

	var create_collision: bool = bool(params.get("create_collision", false))
	var create_side_faces: bool = bool(params.get("create_side_faces", true))
	var top_color_value = params.get("top_color", Color(0.43, 0.62, 0.36, 1.0))
	var left_color_value = params.get("left_color", Color(0.33, 0.48, 0.29, 1.0))
	var right_color_value = params.get("right_color", Color(0.29, 0.43, 0.25, 1.0))
	var height_tint_strength: float = clampf(float(params.get("height_tint_strength", 0.08)), 0.0, 1.0)
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)

	if level_name.is_empty():
		level_name = "IsometricTileBlockout2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var noise_frequency: float = max(0.00001, float(params.get("noise_frequency", 0.12)))
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = noise_frequency
	noise.fractal_octaves = max(1, int(params.get("fractal_octaves", 2)))
	noise.fractal_lacunarity = max(0.0, float(params.get("fractal_lacunarity", 2.0)))
	noise.fractal_gain = max(0.0, float(params.get("fractal_gain", 0.5)))
	if params.has("noise_type"):
		noise.noise_type = int(params.get("noise_type"))
	if params.has("fractal_type"):
		noise.fractal_type = int(params.get("fractal_type"))
	var sample_offset: Vector2 = _parse_vector2_param(params.get("sample_offset", Vector2.ZERO))

	var level_root := Node2D.new()
	level_root.name = _resolve_unique_child_name(parent, level_name)
	level_root.position = origin
	level_root.set_meta("mcp_level_type", "isometric_tile_blockout_2d")
	level_root.set_meta("mcp_isometric_seed", seed_value)
	level_root.set_meta("mcp_isometric_grid_size", _vector2i_to_dict(grid_size))
	level_root.set_meta("mcp_isometric_tile_size", _vector2_to_dict(tile_size))
	level_root.set_meta("mcp_isometric_height_range", {"min": min_height, "max": max_height})
	level_root.set_meta("mcp_isometric_elevation_step", elevation_step)

	var created_nodes: Array = [level_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_level_path: String = _join_mcp_path(parent_mcp_path, level_root.name)
	var predicted_paths := {
		"level_path": predicted_level_path,
	}

	var tiles_container := Node2D.new()
	tiles_container.name = _resolve_unique_child_name(level_root, "Tiles")
	level_root.add_child(tiles_container)
	created_nodes.append(tiles_container)
	predicted_paths["tiles_path"] = _join_mcp_path(predicted_level_path, tiles_container.name)

	var half_w: float = tile_size.x * 0.5
	var half_h: float = tile_size.y * 0.5
	var top_polygon := PackedVector2Array([
		Vector2(0.0, -half_h),
		Vector2(half_w, 0.0),
		Vector2(0.0, half_h),
		Vector2(-half_w, 0.0),
	])

	var preview_tiles: Array = []
	var min_generated_height := 2147483647
	var max_generated_height := -2147483648
	var height_sum := 0.0

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var noise_value := noise.get_noise_2d(float(x) + sample_offset.x, float(y) + sample_offset.y)
			var normalized := clampf((noise_value + 1.0) * 0.5, 0.0, 1.0)
			var height := int(round(lerpf(float(min_height), float(max_height), normalized)))
			min_generated_height = min(min_generated_height, height)
			max_generated_height = max(max_generated_height, height)
			height_sum += float(height)

			var iso_x := (float(x) - float(y)) * half_w
			var iso_y := (float(x) + float(y)) * half_h
			var lift := float(height) * elevation_step
			var tile_position := Vector2(iso_x, iso_y - lift)

			var tile_node := Node2D.new()
			tile_node.name = "Tile_%02d_%02d" % [x, y]
			tile_node.position = tile_position
			tile_node.z_index = int((x + y) * 4 + height * 8)
			tile_node.set_meta("mcp_iso_coords", _vector2i_to_dict(Vector2i(x, y)))
			tile_node.set_meta("mcp_iso_height", height)

			var top_face := Polygon2D.new()
			top_face.name = "Top"
			top_face.polygon = top_polygon
			var top_face_color = _convert_property_value(top_face, "color", top_color_value)
			if top_face_color is Color and height_tint_strength > 0.0:
				var color_value: Color = top_face_color
				var t := clampf(float(height - min_height) / max(1.0, float(max_height - min_height)), 0.0, 1.0)
				color_value = color_value.lerp(Color.WHITE, t * height_tint_strength)
				top_face.color = color_value
			else:
				top_face.color = top_face_color
			tile_node.add_child(top_face)
			created_nodes.append(top_face)

			if create_side_faces and height > 0:
				var depth := float(height) * elevation_step
				var left_face := Polygon2D.new()
				left_face.name = "LeftFace"
				left_face.polygon = PackedVector2Array([
					Vector2(-half_w, 0.0),
					Vector2(0.0, half_h),
					Vector2(0.0, half_h + depth),
					Vector2(-half_w, depth),
				])
				left_face.color = _convert_property_value(left_face, "color", left_color_value)
				tile_node.add_child(left_face)
				created_nodes.append(left_face)

				var right_face := Polygon2D.new()
				right_face.name = "RightFace"
				right_face.polygon = PackedVector2Array([
					Vector2(0.0, half_h),
					Vector2(half_w, 0.0),
					Vector2(half_w, depth),
					Vector2(0.0, half_h + depth),
				])
				right_face.color = _convert_property_value(right_face, "color", right_color_value)
				tile_node.add_child(right_face)
				created_nodes.append(right_face)

			if create_collision:
				var body := StaticBody2D.new()
				body.name = "Collision"
				if collision_layer_value != null:
					body.collision_layer = int(collision_layer_value)
				if collision_mask_value != null:
					body.collision_mask = int(collision_mask_value)
				var collision := CollisionPolygon2D.new()
				collision.name = "CollisionPolygon2D"
				collision.polygon = top_polygon
				body.add_child(collision)
				tile_node.add_child(body)
				created_nodes.append(body)
				created_nodes.append(collision)

			tiles_container.add_child(tile_node)
			created_nodes.append(tile_node)

			if preview_tiles.size() < 64:
				preview_tiles.append({
					"path": _join_mcp_path(String(predicted_paths["tiles_path"]), tile_node.name),
					"coords": _vector2i_to_dict(Vector2i(x, y)),
					"height": height,
					"position": _vector2_to_dict(tile_position),
					"z_index": tile_node.z_index,
				})

	var average_height: float = height_sum / float(max(1, tile_count))
	level_root.set_meta("mcp_isometric_min_height", min_generated_height)
	level_root.set_meta("mcp_isometric_max_height", max_generated_height)
	level_root.set_meta("mcp_isometric_average_height", average_height)

	var transaction_metadata := {
		"command": "generate_isometric_tile_blockout_2d",
		"parent_path": parent_mcp_path,
		"level_name": level_root.name,
		"grid_size": _vector2i_to_dict(grid_size),
		"tile_size": _vector2_to_dict(tile_size),
		"tile_count": tile_count,
		"seed": seed_value,
		"min_height": min_generated_height,
		"max_height": max_generated_height,
		"average_height": average_height,
		"create_collision": create_collision,
		"create_side_faces": create_side_faces,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Isometric Tile Blockout 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Isometric Tile Blockout 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for isometric blockout generation", command_id)

	transaction.add_do_method(parent, "add_child", [level_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [level_root])
	transaction.add_undo_method(level_root, "queue_free")
	transaction.add_do_reference(level_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated isometric tile blockout 2D", "_generate_isometric_tile_blockout_2d", {
			"level_path": _to_mcp_path(level_root),
			"parent_path": parent_mcp_path,
			"grid_size": _vector2i_to_dict(grid_size),
			"tile_count": tile_count,
			"height_range": {"min": min_generated_height, "max": max_generated_height},
			"average_height": average_height,
			"transaction_id": transaction.transaction_id,
			"system_section": "isometric_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"level_name": level_root.name,
		"level_path": predicted_paths.get("level_path", ""),
		"origin": _vector2_to_dict(origin),
		"grid_size": _vector2i_to_dict(grid_size),
		"tile_size": _vector2_to_dict(tile_size),
		"tile_count": tile_count,
		"seed": seed_value,
		"height_range": {"min": min_generated_height, "max": max_generated_height},
		"average_height": average_height,
		"tiles_preview": preview_tiles,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit isometric blockout generation", command_id)
		response["level_path"] = _to_mcp_path(level_root)
		response["paths"] = {
			"level_path": _to_mcp_path(level_root),
			"tiles_path": _to_mcp_path(tiles_container),
		}
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _generate_tentacle_waypoints_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var tentacle_name: String = String(params.get("tentacle_name", "Tentacle2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var waypoint_count: int = clampi(int(params.get("waypoint_count", 8)), 2, 256)
	var segment_length: float = max(1.0, float(params.get("segment_length", 48.0)))
	var lateral_amplitude: float = max(0.0, float(params.get("lateral_amplitude", 36.0)))
	var wave_count: float = max(0.0, float(params.get("wave_count", 1.2)))
	var random_jitter: float = max(0.0, float(params.get("random_jitter", 4.0)))
	var taper: float = clampf(float(params.get("taper", 0.75)), 0.0, 1.0)

	var direction := _parse_vector2_param(params.get("direction", Vector2.RIGHT))
	if direction.length_squared() <= 0.000001:
		direction = Vector2.RIGHT
	direction = direction.normalized()
	var direction_angle: float = direction.angle()

	var create_line: bool = bool(params.get("create_line", true))
	var create_waypoint_markers: bool = bool(params.get("create_waypoint_markers", true))
	var create_segment_markers: bool = bool(params.get("create_segment_markers", false))
	var create_tip_marker: bool = bool(params.get("create_tip_marker", true))

	if tentacle_name.is_empty():
		tentacle_name = "Tentacle2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var tentacle_root := Node2D.new()
	tentacle_root.name = _resolve_unique_child_name(parent, tentacle_name)
	tentacle_root.position = origin
	tentacle_root.set_meta("mcp_tentacle_type", "waypoint_rig_2d")
	tentacle_root.set_meta("mcp_tentacle_seed", seed_value)
	tentacle_root.set_meta("mcp_tentacle_waypoint_count", waypoint_count)
	tentacle_root.set_meta("mcp_tentacle_segment_length", segment_length)
	tentacle_root.set_meta("mcp_tentacle_direction", _vector2_to_dict(direction))
	tentacle_root.set_meta("mcp_tentacle_source", "procedural_waypoints")

	var created_nodes: Array = [tentacle_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_tentacle_path: String = _join_mcp_path(parent_mcp_path, tentacle_root.name)
	var predicted_paths := {
		"tentacle_path": predicted_tentacle_path,
	}

	var points: Array = []
	var curve := Curve2D.new()
	var total_length := 0.0
	var previous_point := Vector2.ZERO

	for idx in range(waypoint_count):
		var t := float(idx) / float(max(1, waypoint_count - 1))
		var base := Vector2(float(idx) * segment_length, 0.0)
		var wave := sin(t * TAU * wave_count + rng.randf_range(-0.12, 0.12)) * lateral_amplitude * (1.0 - t * 0.35)
		var jitter := rng.randf_range(-random_jitter, random_jitter)
		var local_point := Vector2(base.x, wave + jitter).rotated(direction_angle)
		points.append(local_point)
		curve.add_point(local_point)
		if idx > 0:
			total_length += previous_point.distance_to(local_point)
		previous_point = local_point

	var path_node := Path2D.new()
	path_node.name = _resolve_unique_child_name(tentacle_root, "Path")
	path_node.curve = curve
	tentacle_root.add_child(path_node)
	created_nodes.append(path_node)
	predicted_paths["path_path"] = _join_mcp_path(predicted_tentacle_path, path_node.name)

	var line_node = null
	if create_line:
		line_node = Line2D.new()
		line_node.name = _resolve_unique_child_name(tentacle_root, "Line")
		var packed_points := PackedVector2Array()
		for point in points:
			packed_points.append(point)
		line_node.points = packed_points
		line_node.default_color = _convert_property_value(
			line_node,
			"default_color",
			params.get("line_color", Color(0.74, 0.2, 0.46, 0.95))
		)
		line_node.width = max(0.1, float(params.get("line_width_start", 20.0)))
		var line_width_end: float = max(0.1, float(params.get("line_width_end", line_node.width * taper)))
		var width_curve := Curve.new()
		width_curve.add_point(Vector2(0.0, line_node.width))
		width_curve.add_point(Vector2(1.0, line_width_end))
		line_node.width_curve = width_curve
		tentacle_root.add_child(line_node)
		created_nodes.append(line_node)
		predicted_paths["line_path"] = _join_mcp_path(predicted_tentacle_path, line_node.name)

	var waypoints_container = null
	if create_waypoint_markers:
		waypoints_container = Node2D.new()
		waypoints_container.name = _resolve_unique_child_name(tentacle_root, "Waypoints")
		tentacle_root.add_child(waypoints_container)
		created_nodes.append(waypoints_container)
		predicted_paths["waypoints_path"] = _join_mcp_path(predicted_tentacle_path, waypoints_container.name)
		for idx in range(points.size()):
			var point_marker := Marker2D.new()
			point_marker.name = "Waypoint%03d" % (idx + 1)
			point_marker.position = points[idx]
			waypoints_container.add_child(point_marker)
			created_nodes.append(point_marker)

	var segments_container = null
	if create_segment_markers:
		segments_container = Node2D.new()
		segments_container.name = _resolve_unique_child_name(tentacle_root, "Segments")
		tentacle_root.add_child(segments_container)
		created_nodes.append(segments_container)
		predicted_paths["segments_path"] = _join_mcp_path(predicted_tentacle_path, segments_container.name)
		for idx in range(max(0, points.size() - 1)):
			var from_point: Vector2 = points[idx]
			var to_point: Vector2 = points[idx + 1]
			var segment_marker := Marker2D.new()
			segment_marker.name = "Segment%03d" % (idx + 1)
			segment_marker.position = from_point.lerp(to_point, 0.5)
			segment_marker.rotation = (to_point - from_point).angle()
			segments_container.add_child(segment_marker)
			created_nodes.append(segment_marker)

	var tip_marker = null
	if create_tip_marker and points.size() > 0:
		tip_marker = Marker2D.new()
		tip_marker.name = _resolve_unique_child_name(tentacle_root, "Tip")
		tip_marker.position = points[points.size() - 1]
		tentacle_root.add_child(tip_marker)
		created_nodes.append(tip_marker)
		predicted_paths["tip_path"] = _join_mcp_path(predicted_tentacle_path, tip_marker.name)

	var transaction_metadata := {
		"command": "generate_tentacle_waypoints_2d",
		"parent_path": parent_mcp_path,
		"tentacle_name": tentacle_root.name,
		"waypoint_count": waypoint_count,
		"segment_length": segment_length,
		"lateral_amplitude": lateral_amplitude,
		"seed": seed_value,
		"total_length": total_length,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Generate Tentacle Waypoints 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Generate Tentacle Waypoints 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for tentacle generation", command_id)

	transaction.add_do_method(parent, "add_child", [tentacle_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [tentacle_root])
	transaction.add_undo_method(tentacle_root, "queue_free")
	transaction.add_do_reference(tentacle_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Generated tentacle waypoints 2D", "_generate_tentacle_waypoints_2d", {
			"tentacle_path": _to_mcp_path(tentacle_root),
			"parent_path": parent_mcp_path,
			"waypoint_count": waypoint_count,
			"seed": seed_value,
			"total_length": total_length,
			"transaction_id": transaction.transaction_id,
			"system_section": "tentacle_2d",
			"line_num": 0,
		})
	)

	var points_preview: Array = []
	for idx in range(min(points.size(), 32)):
		points_preview.append(_vector2_to_dict(points[idx]))

	var response := {
		"parent_path": parent_mcp_path,
		"tentacle_name": tentacle_root.name,
		"tentacle_path": predicted_paths.get("tentacle_path", ""),
		"origin": _vector2_to_dict(origin),
		"waypoint_count": waypoint_count,
		"segment_length": segment_length,
		"total_length": total_length,
		"seed": seed_value,
		"points_preview": points_preview,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit tentacle generation", command_id)
		var committed_paths := {
			"tentacle_path": _to_mcp_path(tentacle_root),
			"path_path": _to_mcp_path(path_node),
		}
		if line_node:
			committed_paths["line_path"] = _to_mcp_path(line_node)
		if waypoints_container:
			committed_paths["waypoints_path"] = _to_mcp_path(waypoints_container)
		if segments_container:
			committed_paths["segments_path"] = _to_mcp_path(segments_container)
		if tip_marker:
			committed_paths["tip_path"] = _to_mcp_path(tip_marker)
		response["tentacle_path"] = _to_mcp_path(tentacle_root)
		response["paths"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_creature_parts_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var creature_name: String = String(params.get("creature_name", "CreatureParts2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))
	var creature_scale: float = max(0.05, float(params.get("scale", 1.0)))

	var include_tail: bool = bool(params.get("include_tail", true))
	var include_wings: bool = bool(params.get("include_wings", false))
	var include_horns: bool = bool(params.get("include_horns", false))
	var create_visuals: bool = bool(params.get("create_visuals", true))
	var create_collision: bool = bool(params.get("create_collision", true))
	var create_attachment_markers: bool = bool(params.get("create_attachment_markers", true))
	if not create_visuals and not create_collision and not create_attachment_markers:
		return _send_error(client_id, "Enable at least one of create_visuals/create_collision/create_attachment_markers", command_id)

	if creature_name.is_empty():
		creature_name = "CreatureParts2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var root := Node2D.new()
	root.name = _resolve_unique_child_name(parent, creature_name)
	root.position = origin
	root.set_meta("mcp_creature_type", "modular_parts_2d")
	root.set_meta("mcp_creature_scale", creature_scale)
	root.set_meta("mcp_creature_source", "procedural_parts")

	var created_nodes: Array = [root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_root_path: String = _join_mcp_path(parent_mcp_path, root.name)
	var predicted_paths := {
		"creature_path": predicted_root_path,
	}

	var parts_container := Node2D.new()
	parts_container.name = _resolve_unique_child_name(root, "Parts")
	root.add_child(parts_container)
	created_nodes.append(parts_container)
	predicted_paths["parts_path"] = _join_mcp_path(predicted_root_path, parts_container.name)

	var body_color = params.get("body_color", Color(0.48, 0.56, 0.66, 1.0))
	var accent_color = params.get("accent_color", Color(0.78, 0.36, 0.44, 1.0))
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)

	var part_specs: Array = [
		{"name": "Body", "offset": Vector2(0.0, 0.0), "size": Vector2(120.0, 90.0), "accent": false, "shape": "rect"},
		{"name": "Head", "offset": Vector2(0.0, -92.0), "size": Vector2(74.0, 62.0), "accent": false, "shape": "rect"},
		{"name": "LeftArm", "offset": Vector2(-88.0, -12.0), "size": Vector2(40.0, 78.0), "accent": false, "shape": "rect"},
		{"name": "RightArm", "offset": Vector2(88.0, -12.0), "size": Vector2(40.0, 78.0), "accent": false, "shape": "rect"},
		{"name": "LeftLeg", "offset": Vector2(-34.0, 96.0), "size": Vector2(44.0, 86.0), "accent": false, "shape": "rect"},
		{"name": "RightLeg", "offset": Vector2(34.0, 96.0), "size": Vector2(44.0, 86.0), "accent": false, "shape": "rect"},
	]
	if include_tail:
		part_specs.append({"name": "Tail", "offset": Vector2(0.0, 72.0), "size": Vector2(34.0, 96.0), "accent": true, "shape": "diamond"})
	if include_wings:
		part_specs.append({"name": "LeftWing", "offset": Vector2(-122.0, -36.0), "size": Vector2(86.0, 108.0), "accent": true, "shape": "diamond"})
		part_specs.append({"name": "RightWing", "offset": Vector2(122.0, -36.0), "size": Vector2(86.0, 108.0), "accent": true, "shape": "diamond"})
	if include_horns:
		part_specs.append({"name": "LeftHorn", "offset": Vector2(-18.0, -140.0), "size": Vector2(20.0, 36.0), "accent": true, "shape": "triangle"})
		part_specs.append({"name": "RightHorn", "offset": Vector2(18.0, -140.0), "size": Vector2(20.0, 36.0), "accent": true, "shape": "triangle"})

	var parts_preview: Array = []
	for part_data in part_specs:
		var part: Dictionary = part_data
		var part_name: String = String(part.get("name", "Part")).strip_edges()
		var part_offset: Vector2 = (part.get("offset", Vector2.ZERO) as Vector2) * creature_scale
		var part_size: Vector2 = (part.get("size", Vector2(32.0, 32.0)) as Vector2) * creature_scale
		var part_shape: String = String(part.get("shape", "rect"))
		var use_accent: bool = bool(part.get("accent", false))

		var part_node := Node2D.new()
		part_node.name = part_name
		part_node.position = part_offset
		part_node.set_meta("mcp_creature_part_type", part_name)

		if create_visuals:
			var polygon := Polygon2D.new()
			polygon.name = "Visual"
			var half := part_size * 0.5
			if part_shape == "diamond":
				polygon.polygon = PackedVector2Array([
					Vector2(0.0, -half.y),
					Vector2(half.x, 0.0),
					Vector2(0.0, half.y),
					Vector2(-half.x, 0.0),
				])
			elif part_shape == "triangle":
				polygon.polygon = PackedVector2Array([
					Vector2(0.0, -half.y),
					Vector2(half.x, half.y),
					Vector2(-half.x, half.y),
				])
			else:
				polygon.polygon = PackedVector2Array([
					Vector2(-half.x, -half.y),
					Vector2(half.x, -half.y),
					Vector2(half.x, half.y),
					Vector2(-half.x, half.y),
				])
			polygon.color = _convert_property_value(polygon, "color", accent_color if use_accent else body_color)
			part_node.add_child(polygon)
			created_nodes.append(polygon)

		if create_collision:
			var area := Area2D.new()
			area.name = "HitArea"
			if collision_layer_value != null:
				area.collision_layer = int(collision_layer_value)
			if collision_mask_value != null:
				area.collision_mask = int(collision_mask_value)
			var collision := CollisionShape2D.new()
			collision.name = "CollisionShape2D"
			var shape := RectangleShape2D.new()
			shape.size = part_size
			collision.shape = shape
			area.add_child(collision)
			part_node.add_child(area)
			created_nodes.append(area)
			created_nodes.append(collision)

		if create_attachment_markers:
			var attach_marker := Marker2D.new()
			attach_marker.name = "AttachPoint"
			attach_marker.position = Vector2(0.0, -part_size.y * 0.5)
			part_node.add_child(attach_marker)
			created_nodes.append(attach_marker)

		parts_container.add_child(part_node)
		created_nodes.append(part_node)

		if parts_preview.size() < 64:
			parts_preview.append({
				"name": part_name,
				"path": _join_mcp_path(String(predicted_paths["parts_path"]), part_name),
				"position": _vector2_to_dict(part_offset),
				"size": _vector2_to_dict(part_size),
			})

	root.set_meta("mcp_creature_part_count", part_specs.size())

	var transaction_metadata := {
		"command": "build_creature_parts_2d",
		"parent_path": parent_mcp_path,
		"creature_name": root.name,
		"part_count": part_specs.size(),
		"scale": creature_scale,
		"include_tail": include_tail,
		"include_wings": include_wings,
		"include_horns": include_horns,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Creature Parts 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Creature Parts 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for creature parts generation", command_id)

	transaction.add_do_method(parent, "add_child", [root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [root])
	transaction.add_undo_method(root, "queue_free")
	transaction.add_do_reference(root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built creature parts 2D", "_build_creature_parts_2d", {
			"creature_path": _to_mcp_path(root),
			"parent_path": parent_mcp_path,
			"part_count": part_specs.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "creature_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"creature_name": root.name,
		"creature_path": predicted_paths.get("creature_path", ""),
		"origin": _vector2_to_dict(origin),
		"part_count": part_specs.size(),
		"scale": creature_scale,
		"parts_preview": parts_preview,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit creature parts generation", command_id)
		response["creature_path"] = _to_mcp_path(root)
		response["paths"] = {
			"creature_path": _to_mcp_path(root),
			"parts_path": _to_mcp_path(parts_container),
		}
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_slime_mold_colony_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = String(params.get("parent_path", "/root")).strip_edges()
	var colony_name: String = String(params.get("colony_name", "SlimeMoldColony2D")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	var origin: Vector2 = _parse_vector2_param(params.get("origin", Vector2.ZERO))

	var grid_size_result := _parse_vector2i_with_default(params.get("grid_size", null), Vector2i(48, 48))
	if not grid_size_result.get("ok", false):
		return _send_error(client_id, "grid_size must be Vector2i-compatible", command_id)
	var grid_size: Vector2i = grid_size_result.get("value", Vector2i(48, 48))
	if grid_size.x <= 0 or grid_size.y <= 0:
		return _send_error(client_id, "grid_size must be greater than zero on both axes", command_id)

	var cell_size: Vector2 = _parse_vector2_param(params.get("cell_size", Vector2(16.0, 16.0)))
	if cell_size.x <= 0.0 or cell_size.y <= 0.0:
		return _send_error(client_id, "cell_size must be greater than zero on both axes", command_id)

	var initial_cell_count: int = clampi(int(params.get("initial_cell_count", 6)), 1, 4096)
	var initial_radius: int = clampi(int(params.get("initial_radius", 2)), 0, 1024)
	var spread_chance: float = clampf(float(params.get("spread_chance", 0.24)), 0.0, 1.0)
	var growth_rate: float = max(0.0, float(params.get("growth_rate", 0.28)))
	var max_cells: int = max(1, int(params.get("max_cells", grid_size.x * grid_size.y)))
	var create_visuals: bool = bool(params.get("create_visuals", true))
	var create_collision: bool = bool(params.get("create_collision", false))
	var cell_color_value = params.get("cell_color", Color(0.36, 0.87, 0.52, 0.72))
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)

	if colony_name.is_empty():
		colony_name = "SlimeMoldColony2D"

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var colony_root := Node2D.new()
	colony_root.name = _resolve_unique_child_name(parent, colony_name)
	colony_root.position = origin
	colony_root.set_meta("mcp_slime_type", "slime_mold_colony_2d")
	colony_root.set_meta("mcp_slime_grid_size", _vector2i_to_dict(grid_size))
	colony_root.set_meta("mcp_slime_cell_size", _vector2_to_dict(cell_size))
	colony_root.set_meta("mcp_slime_spread_chance", spread_chance)
	colony_root.set_meta("mcp_slime_growth_rate", growth_rate)
	colony_root.set_meta("mcp_slime_max_cells", max_cells)
	colony_root.set_meta("mcp_slime_seed", seed_value)
	colony_root.set_meta("mcp_slime_step_count", 0)
	colony_root.set_meta("mcp_slime_create_visuals", create_visuals)
	colony_root.set_meta("mcp_slime_create_collision", create_collision)
	colony_root.set_meta("mcp_slime_cell_color", cell_color_value)
	colony_root.set_meta("mcp_slime_source", "slow_spread_model")

	var created_nodes: Array = [colony_root]
	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_colony_path: String = _join_mcp_path(parent_mcp_path, colony_root.name)
	var predicted_paths := {
		"colony_path": predicted_colony_path,
	}

	var cells_container := Node2D.new()
	cells_container.name = _resolve_unique_child_name(colony_root, "Cells")
	colony_root.add_child(cells_container)
	created_nodes.append(cells_container)
	predicted_paths["cells_path"] = _join_mcp_path(predicted_colony_path, cells_container.name)

	var center := Vector2i(int(grid_size.x / 2), int(grid_size.y / 2))
	var occupied_lookup: Dictionary = {}
	occupied_lookup[_mcp_grid_key_from_vec2i(center)] = true

	var attempts := 0
	var max_attempts := max(initial_cell_count * 12, 16)
	while occupied_lookup.size() < initial_cell_count and attempts < max_attempts:
		attempts += 1
		var offset := Vector2i(
			rng.randi_range(-initial_radius, initial_radius),
			rng.randi_range(-initial_radius, initial_radius)
		)
		var coords := center + offset
		coords.x = clampi(coords.x, 0, grid_size.x - 1)
		coords.y = clampi(coords.y, 0, grid_size.y - 1)
		occupied_lookup[_mcp_grid_key_from_vec2i(coords)] = true

	var cell_preview: Array = []
	var cell_index := 0
	for key in occupied_lookup.keys():
		var coords := _mcp_grid_key_to_vec2i(String(key))
		var cell_node := _mcp_make_slime_cell_node_2d(
			"Cell%04d" % (cell_index + 1),
			coords,
			grid_size,
			cell_size,
			create_visuals,
			create_collision,
			cell_color_value,
			collision_layer_value,
			collision_mask_value
		)
		cells_container.add_child(cell_node)
		created_nodes.append(cell_node)
		cell_index += 1
		if cell_preview.size() < 64:
			cell_preview.append({
				"path": _join_mcp_path(String(predicted_paths["cells_path"]), cell_node.name),
				"coords": _vector2i_to_dict(coords),
				"position": _vector2_to_dict(cell_node.position),
			})

	colony_root.set_meta("mcp_slime_cells", _mcp_grid_lookup_to_array(occupied_lookup))

	var transaction_metadata := {
		"command": "build_slime_mold_colony_2d",
		"parent_path": parent_mcp_path,
		"colony_name": colony_root.name,
		"seed": seed_value,
		"initial_cell_count": occupied_lookup.size(),
		"spread_chance": spread_chance,
		"growth_rate": growth_rate,
		"max_cells": max_cells,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Slime Mold Colony 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Slime Mold Colony 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for slime colony generation", command_id)

	transaction.add_do_method(parent, "add_child", [colony_root])
	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [colony_root])
	transaction.add_undo_method(colony_root, "queue_free")
	transaction.add_do_reference(colony_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built slime mold colony 2D", "_build_slime_mold_colony_2d", {
			"colony_path": _to_mcp_path(colony_root),
			"parent_path": parent_mcp_path,
			"cell_count": occupied_lookup.size(),
			"seed": seed_value,
			"spread_chance": spread_chance,
			"growth_rate": growth_rate,
			"transaction_id": transaction.transaction_id,
			"system_section": "slime_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"colony_name": colony_root.name,
		"colony_path": predicted_paths.get("colony_path", ""),
		"origin": _vector2_to_dict(origin),
		"grid_size": _vector2i_to_dict(grid_size),
		"cell_size": _vector2_to_dict(cell_size),
		"seed": seed_value,
		"cell_count": occupied_lookup.size(),
		"spread_chance": spread_chance,
		"growth_rate": growth_rate,
		"max_cells": max_cells,
		"cell_preview": cell_preview,
		"paths": predicted_paths,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit slime colony generation", command_id)
		response["colony_path"] = _to_mcp_path(colony_root)
		response["paths"] = {
			"colony_path": _to_mcp_path(colony_root),
			"cells_path": _to_mcp_path(cells_container),
		}
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_slime_mold_growth_step_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var colony_path: String = String(params.get("colony_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if colony_path.is_empty():
		return _send_error(client_id, "colony_path cannot be empty", command_id)

	var colony_node = _get_editor_node(colony_path)
	if not colony_node:
		return _send_error(client_id, "Colony node not found: %s" % colony_path, command_id)
	if not (colony_node is Node2D):
		return _send_error(client_id, "Colony node at %s must inherit Node2D" % colony_path, command_id)
	var colony: Node2D = colony_node

	var cells_container_path: String = String(params.get("cells_path", "")).strip_edges()
	var cells_node = null
	if cells_container_path.is_empty():
		cells_node = colony.get_node_or_null("Cells")
	else:
		cells_node = _get_editor_node(cells_container_path)
	if cells_node == null:
		return _send_error(client_id, "Cells container not found for slime colony", command_id)
	if not (cells_node is Node2D):
		return _send_error(client_id, "Cells container at %s must inherit Node2D" % _to_mcp_path(cells_node), command_id)
	var cells_container: Node2D = cells_node

	var grid_size_result := _parse_vector2i_with_default(
		params.get("grid_size", colony.get_meta("mcp_slime_grid_size") if colony.has_meta("mcp_slime_grid_size") else null),
		Vector2i(48, 48)
	)
	if not grid_size_result.get("ok", false):
		return _send_error(client_id, "grid_size must be Vector2i-compatible", command_id)
	var grid_size: Vector2i = grid_size_result.get("value", Vector2i(48, 48))
	var cell_size := _parse_vector2_param(
		params.get("cell_size", colony.get_meta("mcp_slime_cell_size") if colony.has_meta("mcp_slime_cell_size") else Vector2(16.0, 16.0))
	)

	var spread_chance: float = clampf(float(
		params.get("spread_chance", colony.get_meta("mcp_slime_spread_chance") if colony.has_meta("mcp_slime_spread_chance") else 0.24)
	), 0.0, 1.0)
	var growth_rate: float = max(0.0, float(
		params.get("growth_rate", colony.get_meta("mcp_slime_growth_rate") if colony.has_meta("mcp_slime_growth_rate") else 0.28)
	))
	var max_cells: int = max(1, int(
		params.get("max_cells", colony.get_meta("mcp_slime_max_cells") if colony.has_meta("mcp_slime_max_cells") else grid_size.x * grid_size.y)
	))
	var steps: int = clampi(int(params.get("steps", 1)), 1, 256)
	var max_new_cells_per_step: int = max(1, int(params.get("max_new_cells_per_step", 6)))
	var allow_diagonal: bool = bool(params.get("allow_diagonal", false))
	var create_visuals: bool = bool(params.get("create_visuals", colony.get_meta("mcp_slime_create_visuals") if colony.has_meta("mcp_slime_create_visuals") else true))
	var create_collision: bool = bool(params.get("create_collision", colony.get_meta("mcp_slime_create_collision") if colony.has_meta("mcp_slime_create_collision") else false))
	var cell_color_value = params.get("cell_color", colony.get_meta("mcp_slime_cell_color") if colony.has_meta("mcp_slime_cell_color") else Color(0.36, 0.87, 0.52, 0.72))
	var collision_layer_value = params.get("collision_layer", null)
	var collision_mask_value = params.get("collision_mask", null)

	var seed_base: int = int(colony.get_meta("mcp_slime_seed") if colony.has_meta("mcp_slime_seed") else int(Time.get_unix_time_from_system()) % 2147483647)
	var previous_step_count: int = int(colony.get_meta("mcp_slime_step_count") if colony.has_meta("mcp_slime_step_count") else 0)
	var rng := RandomNumberGenerator.new()
	var step_seed: int = seed_base + previous_step_count + 1
	if params.has("seed"):
		step_seed = int(params.get("seed"))
	rng.seed = step_seed

	var occupied_lookup: Dictionary = {}
	var cells_meta = colony.get_meta("mcp_slime_cells") if colony.has_meta("mcp_slime_cells") else []
	if typeof(cells_meta) != TYPE_ARRAY:
		return _send_error(client_id, "mcp_slime_cells metadata is invalid; expected array", command_id)
	var serialized_cells: Array = cells_meta
	for cell_entry in serialized_cells:
		var parse_result := _parse_vector2i_with_default(cell_entry, Vector2i(-1, -1))
		if not parse_result.get("ok", false):
			continue
		var coords: Vector2i = parse_result.get("value", Vector2i(-1, -1))
		if coords.x < 0 or coords.y < 0 or coords.x >= grid_size.x or coords.y >= grid_size.y:
			continue
		occupied_lookup[_mcp_grid_key_from_vec2i(coords)] = true

	if occupied_lookup.is_empty():
		var center := Vector2i(int(grid_size.x / 2), int(grid_size.y / 2))
		occupied_lookup[_mcp_grid_key_from_vec2i(center)] = true

	var cardinal_dirs := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	var diagonal_dirs := [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	var all_dirs: Array = cardinal_dirs.duplicate()
	if allow_diagonal:
		all_dirs.append_array(diagonal_dirs)

	var newly_added_coords: Array = []
	var applied_steps := 0
	var stalled := false

	for _step in range(steps):
		if occupied_lookup.size() >= max_cells:
			break

		var frontier_keys: Array = []
		for key_value in occupied_lookup.keys():
			var key_string: String = String(key_value)
			var coords := _mcp_grid_key_to_vec2i(key_string)
			var has_open_neighbor := false
			for dir in all_dirs:
				var neighbor: Vector2i = coords + dir
				if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= grid_size.x or neighbor.y >= grid_size.y:
					continue
				if not occupied_lookup.has(_mcp_grid_key_from_vec2i(neighbor)):
					has_open_neighbor = true
					break
			if has_open_neighbor:
				frontier_keys.append(key_string)

		if frontier_keys.is_empty():
			stalled = true
			break

		var growth_budget := max(1, int(round(float(frontier_keys.size()) * growth_rate)))
		growth_budget = min(growth_budget, max_new_cells_per_step, max_cells - occupied_lookup.size())
		if growth_budget <= 0:
			stalled = true
			break

		var step_added_lookup: Dictionary = {}
		var attempts := 0
		var max_attempts := max(32, frontier_keys.size() * all_dirs.size() * 4)
		while step_added_lookup.size() < growth_budget and attempts < max_attempts:
			attempts += 1
			var source_key: String = String(frontier_keys[rng.randi_range(0, frontier_keys.size() - 1)])
			var source_coords := _mcp_grid_key_to_vec2i(source_key)
			var dir: Vector2i = all_dirs[rng.randi_range(0, all_dirs.size() - 1)]
			var candidate := source_coords + dir
			if candidate.x < 0 or candidate.y < 0 or candidate.x >= grid_size.x or candidate.y >= grid_size.y:
				continue
			var candidate_key := _mcp_grid_key_from_vec2i(candidate)
			if occupied_lookup.has(candidate_key) or step_added_lookup.has(candidate_key):
				continue
			if rng.randf() <= spread_chance:
				step_added_lookup[candidate_key] = true
		if step_added_lookup.is_empty():
			stalled = true
			break

		for added_key in step_added_lookup.keys():
			var added_key_string: String = String(added_key)
			occupied_lookup[added_key_string] = true
			newly_added_coords.append(_mcp_grid_key_to_vec2i(added_key_string))
		applied_steps += 1

	if newly_added_coords.is_empty():
		return _send_success(client_id, {
			"colony_path": _to_mcp_path(colony),
			"cells_path": _to_mcp_path(cells_container),
			"added_count": 0,
			"total_cells": occupied_lookup.size(),
			"applied_steps": applied_steps,
			"stalled": stalled,
			"status": "no_change",
		}, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var existing_count := cells_container.get_child_count()
	var new_cell_nodes: Array = []
	for idx in range(newly_added_coords.size()):
		var coords: Vector2i = newly_added_coords[idx]
		var cell_node := _mcp_make_slime_cell_node_2d(
			"Cell%04d" % (existing_count + idx + 1),
			coords,
			grid_size,
			cell_size,
			create_visuals,
			create_collision,
			cell_color_value,
			collision_layer_value,
			collision_mask_value
		)
		new_cell_nodes.append(cell_node)

	var pending_meta_changes: Array = []
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_cells", _mcp_grid_lookup_to_array(occupied_lookup)))
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_step_count", previous_step_count + applied_steps))
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_spread_chance", spread_chance))
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_growth_rate", growth_rate))
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_last_growth_seed", step_seed))
	pending_meta_changes.append_array(_capture_meta_change(colony, "mcp_slime_last_added_count", newly_added_coords.size()))

	var transaction_metadata := {
		"command": "simulate_slime_mold_growth_step_2d",
		"colony_path": _to_mcp_path(colony),
		"cells_path": _to_mcp_path(cells_container),
		"added_count": newly_added_coords.size(),
		"total_cells": occupied_lookup.size(),
		"applied_steps": applied_steps,
		"spread_chance": spread_chance,
		"growth_rate": growth_rate,
		"seed": step_seed,
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Slime Mold Growth Step 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Slime Mold Growth Step 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for slime growth simulation", command_id)

	for node in new_cell_nodes:
		var cell_node: Node = node
		transaction.add_do_method(cells_container, "add_child", [cell_node])
		transaction.add_do_method(cell_node, "set_owner", [edited_scene_root])
		transaction.add_undo_method(cells_container, "remove_child", [cell_node])
		transaction.add_undo_method(cell_node, "queue_free")
		transaction.add_do_reference(cell_node)

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(colony, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(colony, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(colony, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var preview_added: Array = []
	for idx in range(min(newly_added_coords.size(), 64)):
		var coords: Vector2i = newly_added_coords[idx]
		preview_added.append({
			"coords": _vector2i_to_dict(coords),
			"path": _join_mcp_path(_to_mcp_path(cells_container), String(new_cell_nodes[idx].name)),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated slime mold growth step 2D", "_simulate_slime_mold_growth_step_2d", {
			"colony_path": _to_mcp_path(colony),
			"cells_path": _to_mcp_path(cells_container),
			"added_count": newly_added_coords.size(),
			"total_cells": occupied_lookup.size(),
			"applied_steps": applied_steps,
			"spread_chance": spread_chance,
			"growth_rate": growth_rate,
			"seed": step_seed,
			"transaction_id": transaction.transaction_id,
			"system_section": "slime_2d",
			"line_num": 0,
		})
	)

	var response := {
		"colony_path": _to_mcp_path(colony),
		"cells_path": _to_mcp_path(cells_container),
		"added_count": newly_added_coords.size(),
		"total_cells": occupied_lookup.size(),
		"applied_steps": applied_steps,
		"spread_chance": spread_chance,
		"growth_rate": growth_rate,
		"seed": step_seed,
		"added_preview": preview_added,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit slime growth simulation", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _mcp_grid_key_from_vec2i(coords: Vector2i) -> String:
	return "%d,%d" % [coords.x, coords.y]


func _mcp_grid_key_to_vec2i(key: String) -> Vector2i:
	var parts := key.split(",", false, 2)
	if parts.size() < 2:
		return Vector2i(-1, -1)

	var x_string: String = String(parts[0]).strip_edges()
	var y_string: String = String(parts[1]).strip_edges()
	if not x_string.is_valid_int() or not y_string.is_valid_int():
		return Vector2i(-1, -1)

	return Vector2i(int(x_string), int(y_string))


func _mcp_make_slime_cell_node_2d(
	node_name: String,
	coords: Vector2i,
	grid_size: Vector2i,
	cell_size: Vector2,
	create_visuals: bool,
	create_collision: bool,
	cell_color_value,
	collision_layer_value,
	collision_mask_value
) -> Node2D:
	var cell_node := Node2D.new()
	cell_node.name = node_name

	var half_grid := Vector2(float(grid_size.x), float(grid_size.y)) * 0.5
	var local_center := Vector2(
		float(coords.x) + 0.5 - half_grid.x,
		float(coords.y) + 0.5 - half_grid.y
	)
	cell_node.position = Vector2(local_center.x * cell_size.x, local_center.y * cell_size.y)
	cell_node.set_meta("mcp_slime_coords", _vector2i_to_dict(coords))

	if create_visuals:
		var polygon := Polygon2D.new()
		polygon.name = "Visual"
		var half := cell_size * 0.46
		polygon.polygon = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2(half.x, -half.y),
			Vector2(half.x, half.y),
			Vector2(-half.x, half.y),
		])
		polygon.color = _convert_property_value(polygon, "color", cell_color_value)
		cell_node.add_child(polygon)

	if create_collision:
		var area := Area2D.new()
		area.name = "HitArea"
		if collision_layer_value != null:
			area.collision_layer = int(collision_layer_value)
		if collision_mask_value != null:
			area.collision_mask = int(collision_mask_value)

		var collision := CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape := RectangleShape2D.new()
		shape.size = cell_size
		collision.shape = shape
		area.add_child(collision)
		cell_node.add_child(area)

	return cell_node


func _mcp_grid_lookup_to_array(lookup: Dictionary) -> Array:
	var keys: Array = lookup.keys()
	keys.sort()

	var cells: Array = []
	for key_value in keys:
		var coords := _mcp_grid_key_to_vec2i(String(key_value))
		if coords.x < 0 or coords.y < 0:
			continue
		cells.append(_vector2i_to_dict(coords))

	return cells


func _mcp_color_to_dict(color: Color) -> Dictionary:
	return {
		"r": color.r,
		"g": color.g,
		"b": color.b,
		"a": color.a,
	}


func _mcp_smoothstep(edge_0: float, edge_1: float, value: float) -> float:
	if is_equal_approx(edge_0, edge_1):
		return 0.0 if value < edge_0 else 1.0
	var t := clampf((value - edge_0) / (edge_1 - edge_0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _mcp_make_smoke_particle_texture_2d(
	texture_size: int = 64,
	roundness: float = 0.62,
	softness: float = 0.82,
	noise_strength: float = 0.46,
	noise_scale: float = 3.2,
	seed_value: int = 1
) -> Texture2D:
	var width := clampi(texture_size, 16, 256)
	var height := width
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	noise.frequency = max(0.01, noise_scale) / float(width)

	var center := Vector2(float(width - 1) * 0.5, float(height - 1) * 0.5)
	var radius := float(min(width, height)) * 0.5
	var shape_power := lerpf(0.7, 2.8, clampf(roundness, 0.0, 1.0))
	var edge_start := clampf(1.0 - clampf(softness, 0.0, 1.0), 0.0, 0.995)
	var detail_strength := clampf(noise_strength, 0.0, 1.0)
	for y in range(height):
		for x in range(width):
			var pixel := Vector2(float(x), float(y))
			var dist := center.distance_to(pixel) / radius
			var sample := clampf(noise.get_noise_2d(float(x), float(y)) * 0.5 + 0.5, 0.0, 1.0)
			var warped_dist := dist + ((sample - 0.5) * detail_strength * 0.8)
			var radial := clampf(1.0 - pow(clampf(warped_dist, 0.0, 1.6), shape_power), 0.0, 1.0)
			var edge := 1.0 - _mcp_smoothstep(edge_start, 1.0, warped_dist)
			var wispy := lerpf(1.0, 0.35 + sample * 0.65, detail_strength)
			var alpha := clampf(radial * edge * wispy, 0.0, 1.0)
			if alpha <= 0.0:
				continue
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


func _mcp_configure_smoke_particle_material_2d(
	material: ParticleProcessMaterial,
	area_size: Vector2,
	smoke_color: Color,
	wind_direction: Vector2,
	wind_strength: float,
	rise_speed_min: float,
	rise_speed_max: float,
	spread_degrees: float,
	scale_min: Vector2,
	scale_max: Vector2,
	rise_acceleration: float,
	damping_min: float,
	damping_max: float
) -> void:
	var wind := wind_direction
	if wind.length_squared() <= 0.000001:
		wind = Vector2(1.0, -0.15)
	wind = wind.normalized()

	var horizontal_drift := wind.x * (0.18 + wind_strength * 1.05)
	var rise_direction := Vector2(horizontal_drift, -1.0).normalized()
	var drift_gravity := 28.0 + wind_strength * 160.0

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(area_size.x * 0.5, 10.0, 1.0)
	material.direction = Vector3(rise_direction.x, rise_direction.y, 0.0)
	material.spread = spread_degrees
	material.gravity = Vector3(horizontal_drift * drift_gravity, -rise_acceleration, 0.0)
	material.initial_velocity_min = rise_speed_min
	material.initial_velocity_max = rise_speed_max
	material.scale_min = min(scale_min.x, scale_min.y)
	material.scale_max = max(scale_max.x, scale_max.y)
	material.damping_min = damping_min
	material.damping_max = damping_max
	material.color = smoke_color


func _mcp_configure_smoke_particle_material_3d(
	material: ParticleProcessMaterial,
	volume_size: Vector3,
	smoke_color: Color,
	wind_direction: Vector3,
	wind_strength: float,
	rise_speed_min: float,
	rise_speed_max: float,
	spread_degrees: float,
	damping_min: float,
	damping_max: float
) -> void:
	var wind := wind_direction
	wind.y = 0.0
	if wind.length_squared() <= 0.000001:
		wind = Vector3(1.0, 0.0, 0.3)
	wind = wind.normalized()

	var drift_strength := 0.22 + wind_strength * 0.95
	var flow_direction := Vector3(wind.x * drift_strength, 1.0, wind.z * drift_strength).normalized()

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(volume_size.x * 0.5, 0.2, volume_size.z * 0.5)
	material.direction = flow_direction
	material.spread = spread_degrees
	material.gravity = Vector3(
		wind.x * (18.0 + wind_strength * 48.0),
		32.0,
		wind.z * (18.0 + wind_strength * 48.0)
	)
	material.initial_velocity_min = rise_speed_min
	material.initial_velocity_max = rise_speed_max
	material.scale_min = 0.42
	material.scale_max = 1.85
	material.damping_min = damping_min
	material.damping_max = damping_max
	material.color = smoke_color


func _mcp_is_valid_weather_precipitation_mode_2d(mode: String) -> bool:
	match mode:
		"none", "rain", "snow", "ash":
			return true
		_:
			return false


func _mcp_normalize_weather_preset_2d(preset_name: String) -> String:
	var normalized := preset_name.strip_edges().to_lower()
	match normalized:
		"clear", "sunny":
			return "clear"
		"drizzle", "light_rain":
			return "drizzle"
		"rain", "rainy":
			return "rain"
		"storm", "thunderstorm", "thunder":
			return "storm"
		"snow", "snowy":
			return "snow"
		"blizzard", "snowstorm":
			return "blizzard"
		"ash", "dust":
			return "ash"
		_:
			return ""


func _mcp_weather_profile_2d(preset_name: String) -> Dictionary:
	match _mcp_normalize_weather_preset_2d(preset_name):
		"clear":
			return {
				"default_intensity": 0.0,
				"precipitation_mode": "none",
				"precipitation_intensity": 0.0,
				"particle_lifetime": 1.4,
				"particle_speed_min": 120.0,
				"particle_speed_max": 220.0,
				"particle_scale_min": Vector2(0.5, 1.4),
				"particle_scale_max": Vector2(0.9, 2.8),
				"spread_degrees": 3.0,
				"gravity_strength": 240.0,
				"fog_density": 0.02,
				"fog_color": Color(0.78, 0.84, 0.92, 0.06),
				"ambient_color": Color(1.0, 1.0, 1.0, 1.0),
				"precipitation_color": Color(0.88, 0.92, 1.0, 0.78),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		"drizzle":
			return {
				"default_intensity": 0.35,
				"precipitation_mode": "rain",
				"precipitation_intensity": 0.38,
				"particle_lifetime": 1.8,
				"particle_speed_min": 230.0,
				"particle_speed_max": 420.0,
				"particle_scale_min": Vector2(0.6, 4.4),
				"particle_scale_max": Vector2(1.0, 10.0),
				"spread_degrees": 7.0,
				"gravity_strength": 920.0,
				"fog_density": 0.12,
				"fog_color": Color(0.75, 0.82, 0.9, 0.2),
				"ambient_color": Color(0.93, 0.95, 1.0, 1.0),
				"precipitation_color": Color(0.83, 0.9, 1.0, 0.74),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		"rain":
			return {
				"default_intensity": 0.64,
				"precipitation_mode": "rain",
				"precipitation_intensity": 0.72,
				"particle_lifetime": 1.75,
				"particle_speed_min": 280.0,
				"particle_speed_max": 560.0,
				"particle_scale_min": Vector2(0.7, 5.2),
				"particle_scale_max": Vector2(1.2, 13.0),
				"spread_degrees": 8.0,
				"gravity_strength": 1040.0,
				"fog_density": 0.2,
				"fog_color": Color(0.73, 0.79, 0.88, 0.26),
				"ambient_color": Color(0.88, 0.91, 0.97, 1.0),
				"precipitation_color": Color(0.8, 0.88, 0.99, 0.82),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		"storm":
			return {
				"default_intensity": 0.86,
				"precipitation_mode": "rain",
				"precipitation_intensity": 1.0,
				"particle_lifetime": 1.68,
				"particle_speed_min": 320.0,
				"particle_speed_max": 700.0,
				"particle_scale_min": Vector2(0.8, 6.4),
				"particle_scale_max": Vector2(1.4, 16.0),
				"spread_degrees": 12.0,
				"gravity_strength": 1180.0,
				"fog_density": 0.35,
				"fog_color": Color(0.63, 0.7, 0.79, 0.38),
				"ambient_color": Color(0.77, 0.82, 0.9, 1.0),
				"precipitation_color": Color(0.73, 0.84, 0.98, 0.9),
				"lightning_enabled": true,
				"lightning_chance": 0.08,
				"lightning_flash_strength": 0.92,
			}
		"snow":
			return {
				"default_intensity": 0.52,
				"precipitation_mode": "snow",
				"precipitation_intensity": 0.58,
				"particle_lifetime": 3.2,
				"particle_speed_min": 42.0,
				"particle_speed_max": 130.0,
				"particle_scale_min": Vector2(1.6, 1.6),
				"particle_scale_max": Vector2(3.8, 3.8),
				"spread_degrees": 24.0,
				"gravity_strength": 220.0,
				"fog_density": 0.26,
				"fog_color": Color(0.9, 0.94, 1.0, 0.3),
				"ambient_color": Color(0.9, 0.94, 1.0, 1.0),
				"precipitation_color": Color(0.94, 0.97, 1.0, 0.93),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		"blizzard":
			return {
				"default_intensity": 0.9,
				"precipitation_mode": "snow",
				"precipitation_intensity": 1.0,
				"particle_lifetime": 3.0,
				"particle_speed_min": 70.0,
				"particle_speed_max": 190.0,
				"particle_scale_min": Vector2(1.8, 1.8),
				"particle_scale_max": Vector2(4.2, 4.2),
				"spread_degrees": 28.0,
				"gravity_strength": 260.0,
				"fog_density": 0.55,
				"fog_color": Color(0.9, 0.94, 1.0, 0.46),
				"ambient_color": Color(0.82, 0.89, 0.97, 1.0),
				"precipitation_color": Color(0.95, 0.97, 1.0, 0.95),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		"ash":
			return {
				"default_intensity": 0.44,
				"precipitation_mode": "ash",
				"precipitation_intensity": 0.6,
				"particle_lifetime": 2.6,
				"particle_speed_min": 30.0,
				"particle_speed_max": 95.0,
				"particle_scale_min": Vector2(1.0, 1.2),
				"particle_scale_max": Vector2(2.6, 3.4),
				"spread_degrees": 20.0,
				"gravity_strength": 150.0,
				"fog_density": 0.32,
				"fog_color": Color(0.56, 0.53, 0.5, 0.4),
				"ambient_color": Color(0.82, 0.78, 0.74, 1.0),
				"precipitation_color": Color(0.74, 0.7, 0.66, 0.82),
				"lightning_enabled": false,
				"lightning_chance": 0.0,
				"lightning_flash_strength": 0.0,
			}
		_:
			return {}


func _mcp_make_weather_particle_texture_2d(mode: String) -> Texture2D:
	var normalized_mode := String(mode).strip_edges().to_lower()
	var width := 2
	var height := 8
	if normalized_mode == "snow":
		width = 4
		height = 4
	elif normalized_mode == "ash":
		width = 3
		height = 3

	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	if normalized_mode == "rain":
		var center_x := int(width / 2)
		for y in range(height):
			var alpha := lerpf(0.35, 1.0, float(y) / float(max(1, height - 1)))
			image.set_pixel(center_x, y, Color(1.0, 1.0, 1.0, alpha))
	elif normalized_mode == "snow":
		for y in range(height):
			for x in range(width):
				var center_dist: float = abs(float(x) - float(width - 1) * 0.5) + abs(float(y) - float(height - 1) * 0.5)
				var alpha := clampf(1.0 - center_dist * 0.35, 0.0, 1.0)
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	elif normalized_mode == "ash":
		for y in range(height):
			for x in range(width):
				var alpha := 0.45 if (x + y) % 2 == 0 else 0.2
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	else:
		image.fill(Color(1.0, 1.0, 1.0, 0.0))

	return ImageTexture.create_from_image(image)


func _mcp_configure_weather_particle_material_2d(
	material: ParticleProcessMaterial,
	area_size: Vector2,
	mode: String,
	precipitation_color: Color,
	wind_direction: Vector2,
	wind_strength: float,
	speed_min: float,
	speed_max: float,
	spread_degrees: float,
	scale_min: Vector2,
	scale_max: Vector2,
	gravity_strength: float
) -> void:
	var normalized_mode := String(mode).strip_edges().to_lower()
	var wind := wind_direction
	if wind.length_squared() <= 0.000001:
		wind = Vector2(0.0, 1.0)
	wind = wind.normalized()

	var horizontal_drift := wind.x * (0.12 + wind_strength * 1.15)
	var fall_vector := Vector2(horizontal_drift, 1.0).normalized()
	if normalized_mode == "snow" or normalized_mode == "ash":
		fall_vector = Vector2(horizontal_drift, 0.78).normalized()

	var wind_speed_scale := 40.0 + wind_strength * 220.0
	var gravity_vector := Vector3(
		fall_vector.x * wind_speed_scale,
		fall_vector.y * gravity_strength,
		0.0
	)

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(area_size.x * 0.5, 8.0, 1.0)
	material.direction = Vector3(fall_vector.x, fall_vector.y, 0.0)
	material.spread = spread_degrees
	material.gravity = gravity_vector
	material.initial_velocity_min = speed_min
	material.initial_velocity_max = speed_max
	material.scale_min = min(scale_min.x, scale_min.y)
	material.scale_max = max(scale_max.x, scale_max.y)
	material.color = precipitation_color


func _mcp_weather_ambient_color_for_intensity(base_color: Color, intensity: float) -> Color:
	var clamped_intensity := clampf(intensity, 0.0, 1.0)
	return Color.WHITE.lerp(base_color, clamped_intensity)


func _simulate_weather_step_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var weather_path: String = String(params.get("weather_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if weather_path.is_empty():
		return _send_error(client_id, "weather_path cannot be empty", command_id)

	var weather_node = _get_editor_node(weather_path)
	if weather_node == null:
		return _send_error(client_id, "Weather node not found: %s" % weather_path, command_id)
	if not (weather_node is Node2D):
		return _send_error(client_id, "Weather node at %s must inherit Node2D" % weather_path, command_id)
	var weather: Node2D = weather_node

	var current_preset: String = String(weather.get_meta("mcp_weather_preset") if weather.has_meta("mcp_weather_preset") else "clear")
	var target_preset_input: String = String(params.get("target_preset", current_preset)).strip_edges()
	var active_preset: String = _mcp_normalize_weather_preset_2d(target_preset_input)
	if active_preset.is_empty():
		return _send_error(client_id, "Unsupported weather preset: %s" % target_preset_input, command_id)
	var preset_profile: Dictionary = _mcp_weather_profile_2d(active_preset)
	if preset_profile.is_empty():
		return _send_error(client_id, "Failed to resolve weather preset profile for %s" % active_preset, command_id)

	var area_size: Vector2 = _parse_vector2_param(
		params.get("area_size", weather.get_meta("mcp_weather_area_size") if weather.has_meta("mcp_weather_area_size") else Vector2(1280.0, 720.0))
	)
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var transition_rate: float = max(
		0.01,
		float(params.get("transition_rate", weather.get_meta("mcp_weather_transition_rate") if weather.has_meta("mcp_weather_transition_rate") else 2.2))
	)
	var current_intensity: float = clampf(float(weather.get_meta("mcp_weather_intensity") if weather.has_meta("mcp_weather_intensity") else 0.0), 0.0, 1.0)
	var target_intensity: float = clampf(
		float(params.get("target_intensity", weather.get_meta("mcp_weather_target_intensity") if weather.has_meta("mcp_weather_target_intensity") else preset_profile.get("default_intensity", 0.65))),
		0.0,
		1.0
	)
	var new_intensity: float = move_toward(current_intensity, target_intensity, transition_rate * delta)

	var wind_direction: Vector2 = _parse_vector2_param(
		params.get("wind_direction", weather.get_meta("mcp_weather_wind_direction") if weather.has_meta("mcp_weather_wind_direction") else Vector2(-0.12, 1.0))
	)
	if wind_direction.length_squared() <= 0.000001:
		wind_direction = Vector2(0.0, 1.0)
	wind_direction = wind_direction.normalized()
	var wind_strength: float = clampf(
		float(params.get("wind_strength", weather.get_meta("mcp_weather_wind_strength") if weather.has_meta("mcp_weather_wind_strength") else 0.4)),
		0.0,
		1.0
	)

	var precipitation_mode: String = String(params.get(
		"precipitation_mode",
		weather.get_meta("mcp_weather_precipitation_mode") if weather.has_meta("mcp_weather_precipitation_mode") else preset_profile.get("precipitation_mode", "none")
	)).strip_edges().to_lower()
	if not _mcp_is_valid_weather_precipitation_mode_2d(precipitation_mode):
		precipitation_mode = String(preset_profile.get("precipitation_mode", "none"))
	var precipitation_intensity_scale: float = clampf(float(params.get(
		"precipitation_intensity_scale",
		weather.get_meta("mcp_weather_precipitation_intensity_scale") if weather.has_meta("mcp_weather_precipitation_intensity_scale") else preset_profile.get("precipitation_intensity", 1.0)
	)), 0.0, 2.0)
	var max_particles: int = clampi(int(params.get(
		"max_particles",
		weather.get_meta("mcp_weather_max_particles") if weather.has_meta("mcp_weather_max_particles") else 2200
	)), 0, 50000)
	var particle_lifetime: float = max(0.05, float(params.get(
		"particle_lifetime",
		weather.get_meta("mcp_weather_particle_lifetime") if weather.has_meta("mcp_weather_particle_lifetime") else preset_profile.get("particle_lifetime", 1.8)
	)))
	var particle_speed_min: float = max(0.0, float(params.get(
		"particle_speed_min",
		weather.get_meta("mcp_weather_particle_speed_min") if weather.has_meta("mcp_weather_particle_speed_min") else preset_profile.get("particle_speed_min", 260.0)
	)))
	var particle_speed_max: float = max(particle_speed_min, float(params.get(
		"particle_speed_max",
		weather.get_meta("mcp_weather_particle_speed_max") if weather.has_meta("mcp_weather_particle_speed_max") else preset_profile.get("particle_speed_max", 560.0)
	)))
	var spread_degrees: float = clampf(float(params.get(
		"spread_degrees",
		weather.get_meta("mcp_weather_spread_degrees") if weather.has_meta("mcp_weather_spread_degrees") else preset_profile.get("spread_degrees", 6.0)
	)), 0.0, 180.0)
	var gravity_strength: float = max(0.0, float(params.get(
		"gravity_strength",
		weather.get_meta("mcp_weather_gravity_strength") if weather.has_meta("mcp_weather_gravity_strength") else preset_profile.get("gravity_strength", 980.0)
	)))
	var particle_scale_min: Vector2 = _parse_vector2_param(params.get(
		"particle_scale_min",
		weather.get_meta("mcp_weather_particle_scale_min") if weather.has_meta("mcp_weather_particle_scale_min") else preset_profile.get("particle_scale_min", Vector2(0.7, 5.2))
	))
	var particle_scale_max: Vector2 = _parse_vector2_param(params.get(
		"particle_scale_max",
		weather.get_meta("mcp_weather_particle_scale_max") if weather.has_meta("mcp_weather_particle_scale_max") else preset_profile.get("particle_scale_max", Vector2(1.2, 13.0))
	))
	particle_scale_min.x = max(0.01, particle_scale_min.x)
	particle_scale_min.y = max(0.01, particle_scale_min.y)
	particle_scale_max.x = max(particle_scale_min.x, particle_scale_max.x)
	particle_scale_max.y = max(particle_scale_min.y, particle_scale_max.y)

	var fog_density: float = clampf(float(params.get(
		"fog_density",
		weather.get_meta("mcp_weather_fog_density") if weather.has_meta("mcp_weather_fog_density") else preset_profile.get("fog_density", 0.18)
	)), 0.0, 1.0)
	var fog_color = _coerce_color(params.get(
		"fog_color",
		weather.get_meta("mcp_weather_fog_color") if weather.has_meta("mcp_weather_fog_color") else preset_profile.get("fog_color", Color(0.74, 0.8, 0.86, 0.24))
	))
	if fog_color == null:
		fog_color = preset_profile.get("fog_color", Color(0.74, 0.8, 0.86, 0.24))
	var ambient_color = _coerce_color(params.get(
		"ambient_color",
		weather.get_meta("mcp_weather_ambient_color") if weather.has_meta("mcp_weather_ambient_color") else preset_profile.get("ambient_color", Color(0.93, 0.95, 1.0, 1.0))
	))
	if ambient_color == null:
		ambient_color = preset_profile.get("ambient_color", Color(0.93, 0.95, 1.0, 1.0))
	var precipitation_color = _coerce_color(params.get(
		"precipitation_color",
		preset_profile.get("precipitation_color", Color(0.86, 0.9, 1.0, 0.92))
	))
	if precipitation_color == null:
		precipitation_color = preset_profile.get("precipitation_color", Color(0.86, 0.9, 1.0, 0.92))

	var lightning_enabled: bool = bool(params.get(
		"lightning_enabled",
		weather.get_meta("mcp_weather_lightning_enabled") if weather.has_meta("mcp_weather_lightning_enabled") else preset_profile.get("lightning_enabled", false)
	))
	var lightning_chance: float = clampf(float(params.get(
		"lightning_chance",
		weather.get_meta("mcp_weather_lightning_chance") if weather.has_meta("mcp_weather_lightning_chance") else preset_profile.get("lightning_chance", 0.0)
	)), 0.0, 1.0)
	var lightning_flash_strength: float = clampf(float(params.get(
		"lightning_flash_strength",
		weather.get_meta("mcp_weather_lightning_flash_strength") if weather.has_meta("mcp_weather_lightning_flash_strength") else preset_profile.get("lightning_flash_strength", 0.82)
	)), 0.0, 1.0)
	if lightning_enabled and lightning_flash_strength <= 0.0:
		lightning_flash_strength = 0.82
	var lightning_decay: float = max(0.01, float(params.get(
		"lightning_decay",
		weather.get_meta("mcp_weather_lightning_decay") if weather.has_meta("mcp_weather_lightning_decay") else 2.4
	)))
	var lightning_color = _coerce_color(params.get(
		"lightning_color",
		weather.get_meta("mcp_weather_lightning_color") if weather.has_meta("mcp_weather_lightning_color") else Color(1.0, 1.0, 1.0, 1.0)
	))
	if lightning_color == null:
		lightning_color = Color(1.0, 1.0, 1.0, 1.0)

	var enable_precipitation: bool = bool(params.get(
		"enable_precipitation",
		weather.get_meta("mcp_weather_enable_precipitation") if weather.has_meta("mcp_weather_enable_precipitation") else true
	))
	var enable_fog: bool = bool(params.get(
		"enable_fog",
		weather.get_meta("mcp_weather_enable_fog") if weather.has_meta("mcp_weather_enable_fog") else true
	))
	var enable_ambient_modulate: bool = bool(params.get(
		"enable_ambient_modulate",
		weather.get_meta("mcp_weather_enable_ambient_modulate") if weather.has_meta("mcp_weather_enable_ambient_modulate") else true
	))
	var enable_lightning_overlay: bool = bool(params.get(
		"enable_lightning_overlay",
		weather.get_meta("mcp_weather_enable_lightning_overlay") if weather.has_meta("mcp_weather_enable_lightning_overlay") else true
	))

	var precipitation_path: String = String(params.get("precipitation_path", "")).strip_edges()
	var precipitation_node = null
	if not precipitation_path.is_empty():
		precipitation_node = _get_editor_node(precipitation_path)
	else:
		var precipitation_name: String = String(weather.get_meta("mcp_weather_precipitation_node_name") if weather.has_meta("mcp_weather_precipitation_node_name") else "Precipitation")
		if not precipitation_name.is_empty():
			precipitation_node = weather.get_node_or_null(precipitation_name)
	if precipitation_node != null and not (precipitation_node is GPUParticles2D):
		return _send_error(client_id, "Precipitation node must inherit GPUParticles2D", command_id)

	var fog_overlay_path: String = String(params.get("fog_overlay_path", "")).strip_edges()
	var fog_overlay_node = null
	if not fog_overlay_path.is_empty():
		fog_overlay_node = _get_editor_node(fog_overlay_path)
	else:
		var fog_name: String = String(weather.get_meta("mcp_weather_fog_node_name") if weather.has_meta("mcp_weather_fog_node_name") else "FogOverlay")
		if not fog_name.is_empty():
			var screen_layer_name: String = String(weather.get_meta("mcp_weather_screen_layer_name") if weather.has_meta("mcp_weather_screen_layer_name") else "ScreenEffects")
			var screen_root_name: String = String(weather.get_meta("mcp_weather_screen_root_name") if weather.has_meta("mcp_weather_screen_root_name") else "Root")
			fog_overlay_node = weather.get_node_or_null(NodePath("%s/%s/%s" % [screen_layer_name, screen_root_name, fog_name]))
	if fog_overlay_node != null and not (fog_overlay_node is ColorRect):
		return _send_error(client_id, "Fog overlay node must inherit ColorRect", command_id)

	var ambient_path: String = String(params.get("ambient_modulate_path", "")).strip_edges()
	var ambient_node = null
	if not ambient_path.is_empty():
		ambient_node = _get_editor_node(ambient_path)
	else:
		var ambient_name: String = String(weather.get_meta("mcp_weather_ambient_node_name") if weather.has_meta("mcp_weather_ambient_node_name") else "AmbientModulate")
		if not ambient_name.is_empty():
			ambient_node = weather.get_node_or_null(ambient_name)
	if ambient_node != null and not (ambient_node is CanvasModulate):
		return _send_error(client_id, "Ambient node must inherit CanvasModulate", command_id)

	var lightning_path: String = String(params.get("lightning_overlay_path", "")).strip_edges()
	var lightning_node = null
	if not lightning_path.is_empty():
		lightning_node = _get_editor_node(lightning_path)
	else:
		var lightning_name: String = String(weather.get_meta("mcp_weather_lightning_node_name") if weather.has_meta("mcp_weather_lightning_node_name") else "LightningFlash")
		if not lightning_name.is_empty():
			var layer_name: String = String(weather.get_meta("mcp_weather_screen_layer_name") if weather.has_meta("mcp_weather_screen_layer_name") else "ScreenEffects")
			var root_name: String = String(weather.get_meta("mcp_weather_screen_root_name") if weather.has_meta("mcp_weather_screen_root_name") else "Root")
			lightning_node = weather.get_node_or_null(NodePath("%s/%s/%s" % [layer_name, root_name, lightning_name]))
	if lightning_node != null and not (lightning_node is ColorRect):
		return _send_error(client_id, "Lightning overlay node must inherit ColorRect", command_id)

	var previous_step_count: int = int(weather.get_meta("mcp_weather_step_count") if weather.has_meta("mcp_weather_step_count") else 0)
	var next_step_count: int = previous_step_count + 1
	var seed_base: int = int(weather.get_meta("mcp_weather_seed") if weather.has_meta("mcp_weather_seed") else int(Time.get_unix_time_from_system()) % 2147483647)
	var step_seed: int = seed_base + next_step_count * 7919
	if params.has("seed"):
		step_seed = int(params.get("seed"))
	var rng := RandomNumberGenerator.new()
	rng.seed = step_seed

	var previous_flash: float = max(0.0, float(weather.get_meta("mcp_weather_lightning_flash") if weather.has_meta("mcp_weather_lightning_flash") else 0.0))
	var flash_alpha: float = max(0.0, previous_flash - lightning_decay * delta)
	var trigger_lightning: bool = bool(params.get("trigger_lightning", false))
	if trigger_lightning:
		flash_alpha = max(flash_alpha, lightning_flash_strength)
	elif lightning_enabled:
		var chance_this_step := clampf(lightning_chance * delta * 60.0, 0.0, 1.0)
		if rng.randf() <= chance_this_step:
			flash_alpha = max(flash_alpha, lightning_flash_strength)

	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	var precipitation_emitting := false
	var precipitation_amount := 0

	if precipitation_node != null and precipitation_node is GPUParticles2D:
		var precipitation: GPUParticles2D = precipitation_node
		var emission_scale := clampf(new_intensity * precipitation_intensity_scale, 0.0, 1.0)
		precipitation_amount = max(1, int(round(float(max_particles) * emission_scale)))
		precipitation_emitting = (
			enable_precipitation and
			precipitation_mode != "none" and
			max_particles > 0 and
			precipitation_amount > 0
		)
		pending_property_changes.append_array(_capture_property_change(precipitation, "amount", precipitation_amount))
		pending_property_changes.append_array(_capture_property_change(precipitation, "lifetime", particle_lifetime))
		pending_property_changes.append_array(_capture_property_change(precipitation, "emitting", precipitation_emitting))
		pending_property_changes.append_array(_capture_property_change(
			precipitation,
			"visibility_rect",
			Rect2(-area_size.x * 0.6, -64.0, area_size.x * 1.2, area_size.y + 196.0)
		))
		pending_property_changes.append_array(_capture_property_change(
			precipitation,
			"texture",
			_mcp_make_weather_particle_texture_2d(precipitation_mode)
		))

		var next_material := ParticleProcessMaterial.new()
		if precipitation.process_material and precipitation.process_material is ParticleProcessMaterial:
			next_material = (precipitation.process_material as ParticleProcessMaterial).duplicate()
		_mcp_configure_weather_particle_material_2d(
			next_material,
			area_size,
			precipitation_mode,
			precipitation_color,
			wind_direction,
			wind_strength,
			particle_speed_min,
			particle_speed_max,
			spread_degrees,
			particle_scale_min,
			particle_scale_max,
			gravity_strength
		)
		pending_property_changes.append_array(_capture_property_change(precipitation, "process_material", next_material))

	if fog_overlay_node != null and fog_overlay_node is ColorRect:
		var fog_overlay: ColorRect = fog_overlay_node
		var fog_target: Color = fog_color
		var fog_alpha := clampf(fog_density * new_intensity, 0.0, 0.95)
		fog_target.a = fog_alpha
		pending_property_changes.append_array(_capture_property_change(fog_overlay, "color", fog_target))
		pending_property_changes.append_array(_capture_property_change(fog_overlay, "visible", enable_fog and fog_alpha > 0.001))

	if ambient_node != null and ambient_node is CanvasModulate:
		var ambient_modulate: CanvasModulate = ambient_node
		var ambient_target := _mcp_weather_ambient_color_for_intensity(ambient_color, new_intensity)
		pending_property_changes.append_array(_capture_property_change(ambient_modulate, "color", ambient_target))

	if lightning_node != null and lightning_node is ColorRect:
		var lightning_overlay: ColorRect = lightning_node
		var lightning_target: Color = lightning_color
		lightning_target.a = clampf(flash_alpha, 0.0, 1.0)
		pending_property_changes.append_array(_capture_property_change(lightning_overlay, "color", lightning_target))
		pending_property_changes.append_array(_capture_property_change(
			lightning_overlay,
			"visible",
			enable_lightning_overlay and (lightning_enabled or lightning_target.a > 0.001)
		))

	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_preset", active_preset))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_intensity", new_intensity))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_target_intensity", target_intensity))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_transition_rate", transition_rate))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_wind_direction", _vector2_to_dict(wind_direction)))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_wind_strength", wind_strength))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_precipitation_mode", precipitation_mode))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_precipitation_intensity_scale", precipitation_intensity_scale))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_particle_lifetime", particle_lifetime))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_particle_speed_min", particle_speed_min))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_particle_speed_max", particle_speed_max))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_particle_scale_min", _vector2_to_dict(particle_scale_min)))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_particle_scale_max", _vector2_to_dict(particle_scale_max)))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_spread_degrees", spread_degrees))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_gravity_strength", gravity_strength))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_max_particles", max_particles))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_fog_density", fog_density))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_fog_color", fog_color))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_ambient_color", ambient_color))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_enabled", lightning_enabled))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_chance", lightning_chance))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_flash_strength", lightning_flash_strength))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_decay", lightning_decay))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_color", lightning_color))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_lightning_flash", flash_alpha))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_step_count", next_step_count))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_last_step_seed", step_seed))
	pending_meta_changes.append_array(_capture_meta_change(weather, "mcp_weather_last_precipitation_amount", precipitation_amount))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"weather_path": _to_mcp_path(weather),
			"preset": active_preset,
			"intensity": new_intensity,
			"target_intensity": target_intensity,
			"precipitation_mode": precipitation_mode,
			"precipitation_emitting": precipitation_emitting,
			"precipitation_amount": precipitation_amount,
			"flash_alpha": flash_alpha,
			"step_count": next_step_count,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_weather_step_2d",
		"weather_path": _to_mcp_path(weather),
		"preset": active_preset,
		"intensity": new_intensity,
		"target_intensity": target_intensity,
		"precipitation_mode": precipitation_mode,
		"precipitation_emitting": precipitation_emitting,
		"precipitation_amount": precipitation_amount,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Weather Step 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Weather Step 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D weather simulation", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var target: Object = change.get("target", weather)
		transaction.add_do_property(target, change.property, change.value)
		transaction.add_undo_property(target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(weather, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(weather, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(weather, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(weather),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated weather step 2D", "_simulate_weather_step_2d", {
			"weather_path": _to_mcp_path(weather),
			"preset": active_preset,
			"intensity": new_intensity,
			"target_intensity": target_intensity,
			"precipitation_mode": precipitation_mode,
			"precipitation_emitting": precipitation_emitting,
			"precipitation_amount": precipitation_amount,
			"flash_alpha": flash_alpha,
			"step_count": next_step_count,
			"transaction_id": transaction.transaction_id,
			"system_section": "weather_2d",
			"line_num": 0,
		})
	)

	var response := {
		"weather_path": _to_mcp_path(weather),
		"preset": active_preset,
		"intensity": new_intensity,
		"target_intensity": target_intensity,
		"transition_rate": transition_rate,
		"wind_direction": _vector2_to_dict(wind_direction),
		"wind_strength": wind_strength,
		"precipitation_mode": precipitation_mode,
		"precipitation_emitting": precipitation_emitting,
		"precipitation_amount": precipitation_amount,
		"fog_density": fog_density,
		"lightning_enabled": lightning_enabled,
		"flash_alpha": flash_alpha,
		"step_count": next_step_count,
		"seed": step_seed,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit weather simulation step", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_water_current_step_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var water_path: String = String(params.get("water_path", "")).strip_edges()
	var body_path: String = String(params.get("body_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()

	if water_path.is_empty():
		return _send_error(client_id, "water_path cannot be empty", command_id)
	if body_path.is_empty():
		return _send_error(client_id, "body_path cannot be empty", command_id)

	var water_node = _get_editor_node(water_path)
	if not water_node:
		return _send_error(client_id, "Water node not found: %s" % water_path, command_id)
	if not (water_node is Node2D):
		return _send_error(client_id, "Water node at %s must inherit Node2D" % water_path, command_id)

	var body_node = _get_editor_node(body_path)
	if not body_node:
		return _send_error(client_id, "Body node not found: %s" % body_path, command_id)
	if not (body_node is Node2D):
		return _send_error(client_id, "Body node at %s must inherit Node2D" % body_path, command_id)

	var water: Node2D = water_node
	var body: Node2D = body_node
	var water_size := _parse_vector2_param(
		params.get("size", water.get_meta("mcp_water_size") if water.has_meta("mcp_water_size") else Vector2.ZERO)
	)
	if water_size.x <= 0.0 or water_size.y <= 0.0:
		return _send_error(client_id, "Water body size is missing or invalid; provide size or build water with mcp_water_size metadata", command_id)

	var local_position: Vector2 = body.global_position - water.global_position
	var inside_water: bool = (
		local_position.x >= 0.0 and local_position.x <= water_size.x and
		local_position.y >= 0.0 and local_position.y <= water_size.y
	)
	var require_inside: bool = bool(params.get("require_inside", true))
	if not inside_water and require_inside:
		return _send_success(client_id, {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": false,
			"submersion": 0.0,
			"status": "out_of_water",
		}, command_id)

	var submersion: float = clampf(local_position.y / max(0.0001, water_size.y), 0.0, 1.0) if inside_water else 1.0
	var flow_direction := _parse_vector2_param(
		params.get(
			"flow_direction",
			water.get_meta("mcp_water_flow_direction") if water.has_meta("mcp_water_flow_direction") else Vector2.RIGHT
		)
	)
	if flow_direction.length_squared() <= 0.000001:
		flow_direction = Vector2.RIGHT
	flow_direction = flow_direction.normalized()

	var flow_speed: float = float(
		params.get("flow_speed", water.get_meta("mcp_water_flow_speed") if water.has_meta("mcp_water_flow_speed") else 42.0)
	)
	var buoyancy: float = float(
		params.get("buoyancy", water.get_meta("mcp_water_buoyancy") if water.has_meta("mcp_water_buoyancy") else 1.0)
	)
	var drag: float = max(0.0, float(
		params.get("drag", water.get_meta("mcp_water_drag") if water.has_meta("mcp_water_drag") else 0.18)
	))
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var flow_scale: float = float(params.get("flow_scale", 1.0))
	var buoyancy_scale: float = float(params.get("buoyancy_scale", 1.0))
	var drag_scale: float = max(0.0, float(params.get("drag_scale", 1.0)))
	var sink_bias: float = float(params.get("sink_bias", 0.0))
	var clamp_speed: float = max(0.0, float(params.get("clamp_speed", 0.0)))
	var apply_position: bool = bool(params.get("apply_position", true))

	var velocity_property := ""
	var current_velocity := Vector2.ZERO
	if body is CharacterBody2D:
		velocity_property = "velocity"
		current_velocity = (body as CharacterBody2D).velocity
	elif body is RigidBody2D:
		velocity_property = "linear_velocity"
		current_velocity = (body as RigidBody2D).linear_velocity
	elif "velocity" in body:
		velocity_property = "velocity"
		current_velocity = _parse_vector2_param(body.get("velocity"))
	elif body.has_meta("mcp_water_velocity_2d"):
		current_velocity = _parse_vector2_param(body.get_meta("mcp_water_velocity_2d"))

	if params.has("current_velocity"):
		current_velocity = _parse_vector2_param(params.get("current_velocity"))

	var target_flow_velocity: Vector2 = flow_direction * flow_speed * flow_scale
	var damping_factor: float = clampf(drag * drag_scale * delta, 0.0, 1.0)
	var new_velocity: Vector2 = current_velocity.lerp(target_flow_velocity, damping_factor)
	new_velocity.y -= buoyancy * buoyancy_scale * submersion * 98.0 * delta
	new_velocity.y += sink_bias * delta
	if clamp_speed > 0.0 and new_velocity.length() > clamp_speed:
		new_velocity = new_velocity.normalized() * clamp_speed

	var new_global_position: Vector2 = body.global_position + new_velocity * delta
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	if not velocity_property.is_empty():
		pending_property_changes.append_array(_capture_property_change(body, velocity_property, new_velocity))
	else:
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_water_velocity_2d", _vector2_to_dict(new_velocity)))
	if apply_position:
		pending_property_changes.append_array(_capture_property_change(body, "global_position", new_global_position))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": inside_water,
			"submersion": submersion,
			"position": _vector2_to_dict(body.global_position),
			"velocity": _vector2_to_dict(current_velocity),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_water_current_step_2d",
		"water_path": _to_mcp_path(water),
		"body_path": _to_mcp_path(body),
		"inside_water": inside_water,
		"submersion": submersion,
		"delta": delta,
		"flow_speed": flow_speed,
		"buoyancy": buoyancy,
		"drag": drag,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Water Current Step 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Water Current Step 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 2D water simulation", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", body)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(body, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(body, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(body, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(body),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated water current step 2D", "_simulate_water_current_step_2d", {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": inside_water,
			"submersion": submersion,
			"position": _vector2_to_dict(body.global_position),
			"velocity": _vector2_to_dict(
				_parse_vector2_param(body.get(velocity_property)) if not velocity_property.is_empty() else new_velocity
			),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "water_2d",
			"line_num": 0,
		})
	)

	var response := {
		"water_path": _to_mcp_path(water),
		"body_path": _to_mcp_path(body),
		"inside_water": inside_water,
		"submersion": submersion,
		"delta": delta,
		"flow_velocity": _vector2_to_dict(target_flow_velocity),
		"position": _vector2_to_dict(new_global_position),
		"velocity": _vector2_to_dict(new_velocity),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 2D water simulation", command_id)
		response["position"] = _vector2_to_dict(body.global_position)
		if not velocity_property.is_empty():
			response["velocity"] = _vector2_to_dict(_parse_vector2_param(body.get(velocity_property)))
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _simulate_water_current_step_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var water_path: String = String(params.get("water_path", "")).strip_edges()
	var body_path: String = String(params.get("body_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()

	if water_path.is_empty():
		return _send_error(client_id, "water_path cannot be empty", command_id)
	if body_path.is_empty():
		return _send_error(client_id, "body_path cannot be empty", command_id)

	var water_node = _get_editor_node(water_path)
	if not water_node:
		return _send_error(client_id, "Water node not found: %s" % water_path, command_id)
	if not (water_node is Node3D):
		return _send_error(client_id, "Water node at %s must inherit Node3D" % water_path, command_id)

	var body_node = _get_editor_node(body_path)
	if not body_node:
		return _send_error(client_id, "Body node not found: %s" % body_path, command_id)
	if not (body_node is Node3D):
		return _send_error(client_id, "Body node at %s must inherit Node3D" % body_path, command_id)

	var water: Node3D = water_node
	var body: Node3D = body_node
	var water_size_2d := _parse_vector2_param(
		params.get("size", water.get_meta("mcp_water_size") if water.has_meta("mcp_water_size") else Vector2.ZERO)
	)
	var water_depth: float = float(
		params.get("depth", water.get_meta("mcp_water_depth") if water.has_meta("mcp_water_depth") else 0.0)
	)
	if water_size_2d.x <= 0.0 or water_size_2d.y <= 0.0 or water_depth <= 0.0:
		return _send_error(client_id, "Water size/depth is missing or invalid; provide size/depth or build water with metadata", command_id)

	var local_position: Vector3 = body.global_position - water.global_position
	var half_extents := Vector2(water_size_2d.x * 0.5, water_size_2d.y * 0.5)
	var inside_water: bool = (
		absf(local_position.x) <= half_extents.x and
		absf(local_position.z) <= half_extents.y and
		local_position.y <= 0.0 and local_position.y >= -water_depth
	)
	var require_inside: bool = bool(params.get("require_inside", true))
	if not inside_water and require_inside:
		return _send_success(client_id, {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": false,
			"submersion": 0.0,
			"status": "out_of_water",
		}, command_id)

	var submersion: float = clampf((-local_position.y) / max(0.0001, water_depth), 0.0, 1.0) if inside_water else 1.0
	var flow_direction_2d := _parse_vector2_param(
		params.get(
			"flow_direction",
			water.get_meta("mcp_water_flow_direction") if water.has_meta("mcp_water_flow_direction") else Vector2.RIGHT
		)
	)
	if flow_direction_2d.length_squared() <= 0.000001:
		flow_direction_2d = Vector2.RIGHT
	flow_direction_2d = flow_direction_2d.normalized()

	var flow_speed: float = float(
		params.get("flow_speed", water.get_meta("mcp_water_flow_speed") if water.has_meta("mcp_water_flow_speed") else 1.8)
	)
	var buoyancy: float = float(
		params.get("buoyancy", water.get_meta("mcp_water_buoyancy") if water.has_meta("mcp_water_buoyancy") else 1.0)
	)
	var drag: float = max(0.0, float(
		params.get("drag", water.get_meta("mcp_water_drag") if water.has_meta("mcp_water_drag") else 0.24)
	))
	var delta: float = max(0.0001, float(params.get("delta", 1.0 / 60.0)))
	var flow_scale: float = float(params.get("flow_scale", 1.0))
	var buoyancy_scale: float = float(params.get("buoyancy_scale", 1.0))
	var drag_scale: float = max(0.0, float(params.get("drag_scale", 1.0)))
	var sink_bias: float = float(params.get("sink_bias", 0.0))
	var clamp_speed: float = max(0.0, float(params.get("clamp_speed", 0.0)))
	var apply_position: bool = bool(params.get("apply_position", true))
	var preserve_vertical_velocity: bool = bool(params.get("preserve_vertical_velocity", false))

	var velocity_property := ""
	var current_velocity := Vector3.ZERO
	if body is CharacterBody3D:
		velocity_property = "velocity"
		current_velocity = (body as CharacterBody3D).velocity
	elif body is RigidBody3D:
		velocity_property = "linear_velocity"
		current_velocity = (body as RigidBody3D).linear_velocity
	elif "velocity" in body:
		velocity_property = "velocity"
		current_velocity = _parse_vector3_param(body.get("velocity"))
	elif body.has_meta("mcp_water_velocity_3d"):
		current_velocity = _parse_vector3_param(body.get_meta("mcp_water_velocity_3d"))

	if params.has("current_velocity"):
		current_velocity = _parse_vector3_param(params.get("current_velocity"))

	var target_flow_velocity := Vector3(flow_direction_2d.x, 0.0, flow_direction_2d.y) * flow_speed * flow_scale
	var damping_factor: float = clampf(drag * drag_scale * delta, 0.0, 1.0)
	var new_velocity: Vector3 = current_velocity.lerp(target_flow_velocity, damping_factor)
	if preserve_vertical_velocity:
		new_velocity.y = current_velocity.y
	new_velocity.y += buoyancy * buoyancy_scale * submersion * 9.8 * delta
	new_velocity.y -= sink_bias * delta
	if clamp_speed > 0.0 and new_velocity.length() > clamp_speed:
		new_velocity = new_velocity.normalized() * clamp_speed

	var new_global_position: Vector3 = body.global_position + new_velocity * delta
	var pending_property_changes: Array = []
	var pending_meta_changes: Array = []
	if not velocity_property.is_empty():
		pending_property_changes.append_array(_capture_property_change(body, velocity_property, new_velocity))
	else:
		pending_meta_changes.append_array(_capture_meta_change(body, "mcp_water_velocity_3d", _vector3_to_dict(new_velocity)))
	if apply_position:
		pending_property_changes.append_array(_capture_property_change(body, "global_position", new_global_position))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": inside_water,
			"submersion": submersion,
			"position": _vector3_to_dict(body.global_position),
			"velocity": _vector3_to_dict(current_velocity),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "simulate_water_current_step_3d",
		"water_path": _to_mcp_path(water),
		"body_path": _to_mcp_path(body),
		"inside_water": inside_water,
		"submersion": submersion,
		"delta": delta,
		"flow_speed": flow_speed,
		"buoyancy": buoyancy,
		"drag": drag,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Simulate Water Current Step 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Simulate Water Current Step 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for 3D water simulation", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", body)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(body, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(body, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(body, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(body),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Simulated water current step 3D", "_simulate_water_current_step_3d", {
			"water_path": _to_mcp_path(water),
			"body_path": _to_mcp_path(body),
			"inside_water": inside_water,
			"submersion": submersion,
			"position": _vector3_to_dict(body.global_position),
			"velocity": _vector3_to_dict(
				_parse_vector3_param(body.get(velocity_property)) if not velocity_property.is_empty() else new_velocity
			),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "water_3d",
			"line_num": 0,
		})
	)

	var response := {
		"water_path": _to_mcp_path(water),
		"body_path": _to_mcp_path(body),
		"inside_water": inside_water,
		"submersion": submersion,
		"delta": delta,
		"flow_velocity": _vector3_to_dict(target_flow_velocity),
		"position": _vector3_to_dict(new_global_position),
		"velocity": _vector3_to_dict(new_velocity),
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit 3D water simulation", command_id)
		response["position"] = _vector3_to_dict(body.global_position)
		if not velocity_property.is_empty():
			response["velocity"] = _vector3_to_dict(_parse_vector3_param(body.get(velocity_property)))
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _settle_sand_field_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var field_path: String = String(params.get("field_path", "")).strip_edges()
	var grains_path: String = String(params.get("grains_path", "")).strip_edges()
	var transaction_id: String = String(params.get("transaction_id", "")).strip_edges()
	if field_path.is_empty():
		return _send_error(client_id, "field_path cannot be empty", command_id)

	var field_node = _get_editor_node(field_path)
	if not field_node:
		return _send_error(client_id, "Sand field node not found: %s" % field_path, command_id)
	if not (field_node is Node3D):
		return _send_error(client_id, "Sand field at %s must inherit Node3D" % field_path, command_id)
	var field: Node3D = field_node

	var grains_node = null
	if not grains_path.is_empty():
		grains_node = _get_editor_node(grains_path)
	else:
		grains_node = field.get_node_or_null("SandGrains")
		if grains_node == null:
			for child in field.get_children():
				if child is MultiMeshInstance3D:
					grains_node = child
					break
	if not grains_node:
		return _send_error(client_id, "Sand grains node not found; provide grains_path or include a MultiMeshInstance3D child", command_id)
	if not (grains_node is MultiMeshInstance3D):
		return _send_error(client_id, "Node at %s is not a MultiMeshInstance3D" % _to_mcp_path(grains_node), command_id)

	var grains: MultiMeshInstance3D = grains_node
	var source_multimesh: MultiMesh = grains.multimesh
	if source_multimesh == null:
		return _send_error(client_id, "Grains node has no MultiMesh assigned", command_id)
	if source_multimesh.instance_count <= 0:
		return _send_error(client_id, "Grains MultiMesh has no instances to settle", command_id)

	var iterations: int = max(1, int(params.get("iterations", 1)))
	var settle_strength: float = max(0.0, float(params.get("settle_strength", 0.35)))
	var grain_spacing: float = max(0.001, float(field.get_meta("mcp_granular_spacing") if field.has_meta("mcp_granular_spacing") else 0.45))
	var horizontal_jitter: float = max(0.0, float(params.get("horizontal_jitter", grain_spacing * 0.25)))
	var downward_bias: float = max(0.0, float(params.get("downward_bias", grain_spacing * 0.5)))
	var keep_bounds: bool = bool(params.get("keep_bounds", true))
	var field_size := _parse_vector3_param(
		params.get("size", field.get_meta("mcp_granular_size") if field.has_meta("mcp_granular_size") else Vector3.ZERO)
	)
	var has_bounds: bool = field_size.x > 0.0 and field_size.y > 0.0 and field_size.z > 0.0

	var rng := RandomNumberGenerator.new()
	var seed_value: int
	if params.has("seed"):
		seed_value = int(params.get("seed"))
		rng.seed = seed_value
	else:
		rng.randomize()
		seed_value = int(rng.seed)

	var instance_count: int = source_multimesh.instance_count
	var settled_multimesh := MultiMesh.new()
	settled_multimesh.transform_format = source_multimesh.transform_format
	settled_multimesh.use_colors = source_multimesh.use_colors
	settled_multimesh.use_custom_data = source_multimesh.use_custom_data
	settled_multimesh.mesh = source_multimesh.mesh
	settled_multimesh.instance_count = instance_count
	if "visible_instance_count" in source_multimesh and "visible_instance_count" in settled_multimesh:
		settled_multimesh.visible_instance_count = source_multimesh.visible_instance_count
	if "custom_aabb" in source_multimesh and "custom_aabb" in settled_multimesh:
		settled_multimesh.custom_aabb = source_multimesh.custom_aabb
	var moved_instances := 0
	var total_drop := 0.0
	var total_horizontal_shift := 0.0
	var settle_ratio := settle_strength / float(iterations)

	for idx in range(instance_count):
		var current_transform: Transform3D = source_multimesh.get_instance_transform(idx)
		var original_origin: Vector3 = current_transform.origin
		var settled_origin: Vector3 = original_origin
		for step in range(iterations):
			settled_origin.x += rng.randf_range(-horizontal_jitter, horizontal_jitter) * settle_ratio
			settled_origin.z += rng.randf_range(-horizontal_jitter, horizontal_jitter) * settle_ratio
			settled_origin.y -= downward_bias * settle_ratio
		if keep_bounds and has_bounds:
			settled_origin.x = clampf(settled_origin.x, -field_size.x * 0.5, field_size.x * 0.5)
			settled_origin.y = clampf(settled_origin.y, -field_size.y * 0.5, field_size.y * 0.5)
			settled_origin.z = clampf(settled_origin.z, -field_size.z * 0.5, field_size.z * 0.5)

		var delta_vec: Vector3 = settled_origin - original_origin
		if delta_vec.length_squared() > 0.0000001:
			moved_instances += 1
		total_drop += max(0.0, original_origin.y - settled_origin.y)
		total_horizontal_shift += Vector2(delta_vec.x, delta_vec.z).length()

		settled_multimesh.set_instance_transform(idx, Transform3D(current_transform.basis, settled_origin))
		if source_multimesh.use_colors:
			settled_multimesh.set_instance_color(idx, source_multimesh.get_instance_color(idx))
		if source_multimesh.use_custom_data:
			settled_multimesh.set_instance_custom_data(idx, source_multimesh.get_instance_custom_data(idx))

	var pending_property_changes: Array = []
	pending_property_changes.append_array(_capture_property_change(grains, "multimesh", settled_multimesh))
	var pending_meta_changes: Array = []
	pending_meta_changes.append_array(_capture_meta_change(field, "mcp_granular_last_settle_seed", seed_value))
	pending_meta_changes.append_array(_capture_meta_change(field, "mcp_granular_last_settle_iterations", iterations))
	pending_meta_changes.append_array(_capture_meta_change(field, "mcp_granular_last_settle_strength", settle_strength))
	pending_meta_changes.append_array(_capture_meta_change(field, "mcp_granular_last_settle_downward_bias", downward_bias))

	if pending_property_changes.is_empty() and pending_meta_changes.is_empty():
		return _send_success(client_id, {
			"field_path": _to_mcp_path(field),
			"grains_path": _to_mcp_path(grains),
			"instance_count": instance_count,
			"moved_instances": moved_instances,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "settle_sand_field_3d",
		"field_path": _to_mcp_path(field),
		"grains_path": _to_mcp_path(grains),
		"instance_count": instance_count,
		"moved_instances": moved_instances,
		"iterations": iterations,
		"settle_strength": settle_strength,
		"horizontal_jitter": horizontal_jitter,
		"downward_bias": downward_bias,
		"seed": seed_value,
		"property_change_count": pending_property_changes.size(),
		"meta_change_count": pending_meta_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Settle Sand Field 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Settle Sand Field 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for sand settling", command_id)

	var serialized_property_changes: Array = []
	for change in pending_property_changes:
		var change_target: Object = change.get("target", grains)
		transaction.add_do_property(change_target, change.property, change.value)
		transaction.add_undo_property(change_target, change.property, change.previous)
		serialized_property_changes.append({
			"target": _describe_object_path(change_target),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in pending_meta_changes:
		transaction.add_do_method(field, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(field, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(field, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"target": _to_mcp_path(field),
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Settled sand field 3D", "_settle_sand_field_3d", {
			"field_path": _to_mcp_path(field),
			"grains_path": _to_mcp_path(grains),
			"instance_count": instance_count,
			"moved_instances": moved_instances,
			"iterations": iterations,
			"settle_strength": settle_strength,
			"horizontal_jitter": horizontal_jitter,
			"downward_bias": downward_bias,
			"seed": seed_value,
			"transaction_id": transaction.transaction_id,
			"system_section": "granular_3d",
			"line_num": 0,
		})
	)

	var response := {
		"field_path": _to_mcp_path(field),
		"grains_path": _to_mcp_path(grains),
		"instance_count": instance_count,
		"moved_instances": moved_instances,
		"movement_ratio": float(moved_instances) / float(max(1, instance_count)),
		"average_drop": total_drop / float(max(1, instance_count)),
		"average_horizontal_shift": total_horizontal_shift / float(max(1, instance_count)),
		"iterations": iterations,
		"settle_strength": settle_strength,
		"horizontal_jitter": horizontal_jitter,
		"downward_bias": downward_bias,
		"seed": seed_value,
		"changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit sand settling", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_stage_blockout_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var stage_name: String = String(params.get("stage_name", "StageBlockout")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var blocks_param = params.get("blocks", [])
	var create_visuals: bool = bool(params.get("create_visuals", true))

	if stage_name.is_empty():
		stage_name = "StageBlockout"
	if typeof(blocks_param) != TYPE_ARRAY:
		return _send_error(client_id, "blocks must be an array", command_id)
	var blocks: Array = blocks_param
	if blocks.is_empty():
		return _send_error(client_id, "blocks array cannot be empty", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var stage_root := Node2D.new()
	stage_root.name = _resolve_unique_child_name(parent, stage_name)

	var created_nodes: Array = [stage_root]
	var created_blocks: Array = []
	var reserved_block_names: Dictionary = {}
	var global_layer_value = params.get("collision_layer", null)
	var global_mask_value = params.get("collision_mask", null)
	var default_color_value = params.get("default_color", Color(0.32, 0.34, 0.39, 0.8))

	for idx in range(blocks.size()):
		var block_raw = blocks[idx]
		if typeof(block_raw) != TYPE_DICTIONARY:
			return _send_error(client_id, "blocks[%d] must be a dictionary" % idx, command_id)
		var block: Dictionary = block_raw

		var block_name: String = String(block.get("name", "Block%d" % (idx + 1))).strip_edges()
		if block_name.is_empty():
			block_name = "Block%d" % (idx + 1)
		block_name = _resolve_unique_name_in_set(block_name, reserved_block_names)

		var size := _parse_vector2_param(block.get("size", Vector2(96.0, 48.0)))
		if size.x <= 0.0 or size.y <= 0.0:
			return _send_error(client_id, "blocks[%d].size must be greater than zero on both axes" % idx, command_id)
		var position := _parse_vector2_param(block.get("position", Vector2.ZERO))

		var body := StaticBody2D.new()
		body.name = block_name
		body.position = position
		body.collision_layer = int(block.get("collision_layer", global_layer_value if global_layer_value != null else body.collision_layer))
		body.collision_mask = int(block.get("collision_mask", global_mask_value if global_mask_value != null else body.collision_mask))

		var collision := CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = size
		collision.shape = rect_shape
		body.add_child(collision)
		created_nodes.append(body)
		created_nodes.append(collision)

		if create_visuals:
			var polygon := Polygon2D.new()
			polygon.name = "Visual"
			var half := size * 0.5
			polygon.polygon = PackedVector2Array([
				Vector2(-half.x, -half.y),
				Vector2(half.x, -half.y),
				Vector2(half.x, half.y),
				Vector2(-half.x, half.y),
			])
			var color_value = block.get("color", default_color_value)
			polygon.color = _convert_property_value(polygon, "color", color_value)
			body.add_child(polygon)
			created_nodes.append(polygon)

		stage_root.add_child(body)
		created_blocks.append({
			"name": block_name,
			"position": _vector2_to_dict(position),
			"size": _vector2_to_dict(size),
			"path": _join_mcp_path(_join_mcp_path(_to_mcp_path(parent), stage_root.name), block_name),
		})

	var stage_parent_path: String = _to_mcp_path(parent)
	var predicted_stage_path: String = _join_mcp_path(stage_parent_path, stage_root.name)
	var transaction_metadata := {
		"command": "build_stage_blockout_2d",
		"parent_path": stage_parent_path,
		"stage_name": stage_root.name,
		"block_count": created_blocks.size(),
		"create_visuals": create_visuals,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Stage Blockout 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Stage Blockout 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for stage blockout generation", command_id)

	transaction.add_do_method(parent, "add_child", [stage_root])
	for stage_node in created_nodes:
		var child_node: Node = stage_node
		transaction.add_do_method(child_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [stage_root])
	transaction.add_undo_method(stage_root, "queue_free")
	transaction.add_do_reference(stage_root)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built 2D stage blockout", "_build_stage_blockout_2d", {
			"stage_path": _to_mcp_path(stage_root),
			"parent_path": stage_parent_path,
			"block_count": created_blocks.size(),
			"create_visuals": create_visuals,
			"transaction_id": transaction.transaction_id,
			"system_section": "stage_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": stage_parent_path,
		"stage_name": stage_root.name,
		"stage_path": predicted_stage_path,
		"block_count": created_blocks.size(),
		"blocks": created_blocks,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit stage blockout generation", command_id)
		var committed_blocks: Array = []
		for block_node in stage_root.get_children():
			if block_node is StaticBody2D:
				var static_block: StaticBody2D = block_node
				var size_value := Vector2.ZERO
				var collision_shape = static_block.get_node_or_null("CollisionShape2D")
				if collision_shape and collision_shape is CollisionShape2D:
					var collision_shape_node: CollisionShape2D = collision_shape
					if collision_shape_node.shape and collision_shape_node.shape is RectangleShape2D:
						size_value = (collision_shape_node.shape as RectangleShape2D).size
				committed_blocks.append({
					"name": static_block.name,
					"path": _to_mcp_path(static_block),
					"position": _vector2_to_dict(static_block.position),
					"size": _vector2_to_dict(size_value),
				})
		response["stage_path"] = _to_mcp_path(stage_root)
		response["blocks"] = committed_blocks
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_hud_ui_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var hud_name: String = String(params.get("hud_name", "HUD")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var include_health: bool = bool(params.get("include_health", true))
	var include_score: bool = bool(params.get("include_score", true))
	var include_objective: bool = bool(params.get("include_objective", true))
	var include_message: bool = bool(params.get("include_message", false))
	var include_pause_button: bool = bool(params.get("include_pause_button", false))
	var margin: int = max(0, int(params.get("margin", 16)))
	var spacing: int = max(0, int(params.get("spacing", 8)))

	if hud_name.is_empty():
		hud_name = "HUD"
	if not include_health and not include_score and not include_objective and not include_message and not include_pause_button:
		return _send_error(client_id, "At least one HUD element must be enabled", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var canvas_layer := CanvasLayer.new()
	canvas_layer.name = _resolve_unique_child_name(parent, hud_name)

	var root_control := Control.new()
	root_control.name = "Root"
	_configure_control_full_rect(root_control)

	var margin_container := MarginContainer.new()
	margin_container.name = "Margin"
	_configure_control_full_rect(margin_container)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)

	var vbox := VBoxContainer.new()
	vbox.name = "HUDVBox"
	vbox.add_theme_constant_override("separation", spacing)

	margin_container.add_child(vbox)
	root_control.add_child(margin_container)
	canvas_layer.add_child(root_control)

	var created_labels: Array = []
	if include_health:
		var health_label := Label.new()
		health_label.name = "HealthLabel"
		health_label.text = String(params.get("health_text", "Health: 100"))
		vbox.add_child(health_label)
		created_labels.append(health_label)
	if include_score:
		var score_label := Label.new()
		score_label.name = "ScoreLabel"
		score_label.text = String(params.get("score_text", "Score: 0000"))
		vbox.add_child(score_label)
		created_labels.append(score_label)
	if include_objective:
		var objective_label := Label.new()
		objective_label.name = "ObjectiveLabel"
		objective_label.text = String(params.get("objective_text", "Objective: Reach the exit"))
		vbox.add_child(objective_label)
		created_labels.append(objective_label)
	if include_message:
		var message_label := Label.new()
		message_label.name = "MessageLabel"
		message_label.text = String(params.get("message_text", ""))
		vbox.add_child(message_label)
		created_labels.append(message_label)
	if include_pause_button:
		var pause_button := Button.new()
		pause_button.name = "PauseButton"
		pause_button.text = String(params.get("pause_text", "Pause"))
		vbox.add_child(pause_button)

	var created_nodes: Array = [canvas_layer, root_control, margin_container, vbox]
	created_nodes.append_array(created_labels)
	if include_pause_button:
		var pause_button_node = vbox.get_node_or_null("PauseButton")
		if pause_button_node:
			created_nodes.append(pause_button_node)

	var parent_mcp_path: String = _to_mcp_path(parent)
	var predicted_hud_path: String = _join_mcp_path(parent_mcp_path, canvas_layer.name)
	var transaction_metadata := {
		"command": "build_hud_ui_2d",
		"parent_path": parent_mcp_path,
		"hud_name": canvas_layer.name,
		"label_count": created_labels.size(),
		"include_pause_button": include_pause_button,
		"margin": margin,
		"spacing": spacing,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build HUD UI 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build HUD UI 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for HUD generation", command_id)

	transaction.add_do_method(parent, "add_child", [canvas_layer])
	for ui_node in created_nodes:
		var child_node: Node = ui_node
		transaction.add_do_method(child_node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [canvas_layer])
	transaction.add_undo_method(canvas_layer, "queue_free")
	transaction.add_do_reference(canvas_layer)

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built HUD UI 2D", "_build_hud_ui_2d", {
			"hud_path": _to_mcp_path(canvas_layer),
			"parent_path": parent_mcp_path,
			"label_count": created_labels.size(),
			"include_pause_button": include_pause_button,
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_2d",
			"line_num": 0,
		})
	)

	var response := {
		"parent_path": parent_mcp_path,
		"hud_name": canvas_layer.name,
		"hud_path": predicted_hud_path,
		"labels": created_labels.map(func(label): return {"name": label.name, "text": label.text, "path": _join_mcp_path(predicted_hud_path, "Root/Margin/HUDVBox/%s" % label.name)}),
		"include_pause_button": include_pause_button,
		"margin": margin,
		"spacing": spacing,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit HUD generation", command_id)
		var committed_labels: Array = []
		var committed_vbox = canvas_layer.get_node_or_null("Root/Margin/HUDVBox")
		if committed_vbox:
			for child in committed_vbox.get_children():
				if child is Label:
					var label_node: Label = child
					committed_labels.append({
						"name": label_node.name,
						"text": label_node.text,
						"path": _to_mcp_path(label_node),
					})
		response["hud_path"] = _to_mcp_path(canvas_layer)
		response["labels"] = committed_labels
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _author_enemy_ai_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var enemy_path: String = params.get("enemy_path", "")
	var transaction_id: String = params.get("transaction_id", "")
	if enemy_path.is_empty():
		return _send_error(client_id, "enemy_path cannot be empty", command_id)

	var enemy_node = _get_editor_node(enemy_path)
	if not enemy_node:
		return _send_error(client_id, "Enemy node not found: %s" % enemy_path, command_id)
	if not (enemy_node is CharacterBody2D):
		return _send_error(client_id, "Enemy node at %s must be CharacterBody2D" % enemy_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var enemy: CharacterBody2D = enemy_node
	var enemy_mcp_path: String = _to_mcp_path(enemy)
	var create_navigation_agent: bool = bool(params.get("create_navigation_agent", true))
	var create_vision_area: bool = bool(params.get("create_vision_area", true))
	var create_attack_timer: bool = bool(params.get("create_attack_timer", true))
	var connect_signals: bool = bool(params.get("connect_signals", true))
	var movement_speed: float = float(params.get("movement_speed", 160.0))
	var acceleration: float = float(params.get("acceleration", movement_speed * 6.0))
	var attack_cooldown: float = max(0.01, float(params.get("attack_cooldown", 0.8)))
	var vision_radius: float = max(1.0, float(params.get("vision_radius", 160.0)))
	var detection_group: String = String(params.get("detection_group", "player")).strip_edges()
	var signal_flags: int = _build_signal_flags_from_params(params)

	var attach_plans: Array = []
	var created_nodes: Array = []
	var property_changes: Array = []
	var meta_changes: Array = []
	var signal_changes: Array = []

	var navigation_name: String = String(params.get("navigation_agent_name", "NavigationAgent2D")).strip_edges()
	if navigation_name.is_empty():
		navigation_name = "NavigationAgent2D"
	var navigation_node = enemy.get_node_or_null(navigation_name)
	if not navigation_node and create_navigation_agent:
		var new_navigation := NavigationAgent2D.new()
		new_navigation.name = _resolve_unique_child_name(enemy, navigation_name)
		navigation_node = new_navigation
		attach_plans.append({"parent": enemy, "node": new_navigation})
		created_nodes.append(new_navigation)
	if navigation_node and not (navigation_node is NavigationAgent2D):
		return _send_error(client_id, "Node at %s/%s is not NavigationAgent2D" % [enemy_mcp_path, navigation_name], command_id)
	var navigation_agent: NavigationAgent2D = null
	if navigation_node and navigation_node is NavigationAgent2D:
		navigation_agent = navigation_node
		property_changes.append_array(
			_capture_property_change(navigation_agent, "max_speed", float(params.get("navigation_max_speed", movement_speed)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "path_desired_distance", float(params.get("path_desired_distance", 12.0)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "target_desired_distance", float(params.get("target_desired_distance", 10.0)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "avoidance_enabled", bool(params.get("avoidance_enabled", true)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "neighbor_distance", float(params.get("neighbor_distance", 220.0)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "max_neighbors", int(params.get("max_neighbors", 10)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "time_horizon", float(params.get("time_horizon", 1.0)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "time_horizon_agents", float(params.get("time_horizon_agents", 1.0)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "time_horizon_obstacles", float(params.get("time_horizon_obstacles", 0.5)))
		)

	var vision_name: String = String(params.get("vision_area_name", "VisionArea2D")).strip_edges()
	if vision_name.is_empty():
		vision_name = "VisionArea2D"
	var vision_node = enemy.get_node_or_null(vision_name)
	if not vision_node and create_vision_area:
		var new_vision_area := Area2D.new()
		new_vision_area.name = _resolve_unique_child_name(enemy, vision_name)
		vision_node = new_vision_area
		attach_plans.append({"parent": enemy, "node": new_vision_area})
		created_nodes.append(new_vision_area)
	if vision_node and not (vision_node is Area2D):
		return _send_error(client_id, "Node at %s/%s is not Area2D" % [enemy_mcp_path, vision_name], command_id)

	var vision_area: Area2D = null
	if vision_node and vision_node is Area2D:
		vision_area = vision_node
		property_changes.append_array(_capture_property_change(vision_area, "monitoring", true))
		property_changes.append_array(_capture_property_change(vision_area, "monitorable", true))
		if params.has("vision_collision_layer"):
			property_changes.append_array(
				_capture_property_change(vision_area, "collision_layer", int(params.get("vision_collision_layer")))
			)
		if params.has("vision_collision_mask"):
			property_changes.append_array(
				_capture_property_change(vision_area, "collision_mask", int(params.get("vision_collision_mask")))
			)
		if params.has("vision_offset"):
			property_changes.append_array(
				_capture_property_change(vision_area, "position", _parse_vector2_param(params.get("vision_offset")))
			)

		var vision_shape_node: CollisionShape2D = vision_area.get_node_or_null("CollisionShape2D")
		if not vision_shape_node:
			for child in vision_area.get_children():
				if child is CollisionShape2D:
					vision_shape_node = child
					break
		if not vision_shape_node and create_vision_area:
			var new_collision := CollisionShape2D.new()
			new_collision.name = _resolve_unique_child_name(vision_area, "CollisionShape2D")
			var new_circle := CircleShape2D.new()
			new_circle.radius = vision_radius
			new_collision.shape = new_circle
			if vision_area.get_parent() == null:
				vision_area.add_child(new_collision)
			else:
				attach_plans.append({"parent": vision_area, "node": new_collision})
			created_nodes.append(new_collision)
			vision_shape_node = new_collision
		if vision_shape_node:
			if vision_shape_node.shape and vision_shape_node.shape is CircleShape2D:
				property_changes.append_array(
					_capture_property_change(vision_shape_node.shape, "radius", vision_radius)
				)
			else:
				var replacement_circle := CircleShape2D.new()
				replacement_circle.radius = vision_radius
				property_changes.append_array(
					_capture_property_change(vision_shape_node, "shape", replacement_circle)
				)

	var timer_name: String = String(params.get("attack_timer_name", "AttackCooldown")).strip_edges()
	if timer_name.is_empty():
		timer_name = "AttackCooldown"
	var timer_node = enemy.get_node_or_null(timer_name)
	if not timer_node and create_attack_timer:
		var new_timer := Timer.new()
		new_timer.name = _resolve_unique_child_name(enemy, timer_name)
		timer_node = new_timer
		attach_plans.append({"parent": enemy, "node": new_timer})
		created_nodes.append(new_timer)
	if timer_node and not (timer_node is Timer):
		return _send_error(client_id, "Node at %s/%s is not Timer" % [enemy_mcp_path, timer_name], command_id)

	var attack_timer: Timer = null
	if timer_node and timer_node is Timer:
		attack_timer = timer_node
		property_changes.append_array(_capture_property_change(attack_timer, "wait_time", attack_cooldown))
		property_changes.append_array(_capture_property_change(attack_timer, "one_shot", true))
		property_changes.append_array(_capture_property_change(attack_timer, "autostart", false))

	if detection_group.is_empty():
		detection_group = "player"
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_ai_profile", "patrol_chase_2d"))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_movement_speed", movement_speed))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_acceleration", acceleration))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_detection_group", detection_group))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_attack_cooldown", attack_cooldown))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_vision_radius", vision_radius))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_loop", bool(params.get("patrol_loop", true))))
	if navigation_agent:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_navigation_agent_path", _join_mcp_path(enemy_mcp_path, String(navigation_agent.name)))
		)
	if vision_area:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_vision_area_path", _join_mcp_path(enemy_mcp_path, String(vision_area.name)))
		)
	if attack_timer:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_attack_timer_path", _join_mcp_path(enemy_mcp_path, String(attack_timer.name)))
		)
	if params.has("target_path"):
		var target_path: String = String(params.get("target_path", "")).strip_edges()
		if not target_path.is_empty():
			meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_target_path", target_path))

	if params.has("patrol_points"):
		var patrol_points_param = params.get("patrol_points")
		if typeof(patrol_points_param) != TYPE_ARRAY:
			return _send_error(client_id, "patrol_points must be an array", command_id)
		var patrol_points: Array = patrol_points_param
		var serialized_patrol_points: Array = []
		for idx in range(patrol_points.size()):
			serialized_patrol_points.append(_vector2_to_dict(_parse_vector2_param(patrol_points[idx])))
		meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_points", serialized_patrol_points))
		meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_index", 0))

	if connect_signals:
		var signal_target_path: String = String(params.get("signal_target_path", enemy_mcp_path)).strip_edges()
		if signal_target_path.is_empty():
			signal_target_path = enemy_mcp_path
		var signal_target = _get_editor_node(signal_target_path)
		if not signal_target:
			return _send_error(client_id, "Signal target node not found: %s" % signal_target_path, command_id)

		if vision_area:
			var entered_method: String = String(params.get("vision_entered_method", "_on_enemy_vision_body_entered")).strip_edges()
			var exited_method: String = String(params.get("vision_exited_method", "_on_enemy_vision_body_exited")).strip_edges()
			signal_changes.append_array(
				_capture_signal_connection_change(vision_area, "body_entered", signal_target, entered_method, signal_flags)
			)
			signal_changes.append_array(
				_capture_signal_connection_change(vision_area, "body_exited", signal_target, exited_method, signal_flags)
			)
		if attack_timer:
			var timeout_method: String = String(params.get("attack_timeout_method", "_on_enemy_attack_cooldown_timeout")).strip_edges()
			signal_changes.append_array(
				_capture_signal_connection_change(attack_timer, "timeout", signal_target, timeout_method, signal_flags)
			)

	if attach_plans.is_empty() and property_changes.is_empty() and meta_changes.is_empty() and signal_changes.is_empty():
		return _send_success(client_id, {
			"enemy_path": enemy_mcp_path,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "author_enemy_ai_2d",
		"enemy_path": enemy_mcp_path,
		"created_count": created_nodes.size(),
		"property_change_count": property_changes.size(),
		"meta_change_count": meta_changes.size(),
		"signal_change_count": signal_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Author Enemy AI 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Author Enemy AI 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for enemy AI 2D authoring", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_property_changes: Array = []
	for change in property_changes:
		var target_object: Object = change.get("target", enemy)
		transaction.add_do_property(target_object, change.property, change.value)
		transaction.add_undo_property(target_object, change.property, change.previous)
		if change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_property_changes.append({
			"target_type": target_object.get_class(),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(enemy, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(enemy, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(enemy, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_signal_changes: Array = []
	for change in signal_changes:
		transaction.add_do_method(
			self,
			"_connect_signal_change_safe",
			[change]
		)
		transaction.add_undo_method(
			self,
			"_disconnect_signal_change_safe",
			[change]
		)
		serialized_signal_changes.append({
			"emitter": _describe_object_path(change.emitter),
			"signal": change.signal_name,
			"target": _describe_object_path(change.target),
			"method_name": change.method_name,
			"flags": change.flags,
		})

	var predicted_created_paths: Array = []
	for created in created_nodes:
		var created_node: Node = created
		var parent_node = created_node.get_parent()
		if parent_node:
			predicted_created_paths.append(_join_mcp_path(_to_mcp_path(parent_node), String(created_node.name)))
		else:
			predicted_created_paths.append(_join_mcp_path(enemy_mcp_path, String(created_node.name)))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Authored enemy AI 2D", "_author_enemy_ai_2d", {
			"enemy_path": _to_mcp_path(enemy),
			"created_count": created_nodes.size(),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"signal_change_count": serialized_signal_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "enemy_ai_2d",
			"line_num": 0,
		})
	)

	var response := {
		"enemy_path": enemy_mcp_path,
		"created_nodes": predicted_created_paths,
		"property_changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"signal_changes": serialized_signal_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit enemy AI 2D authoring", command_id)
		var committed_paths: Array = []
		for created in created_nodes:
			var created_node: Node = created
			committed_paths.append(_to_mcp_path(created_node))
		response["created_nodes"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _author_enemy_ai_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var enemy_path: String = params.get("enemy_path", "")
	var transaction_id: String = params.get("transaction_id", "")
	if enemy_path.is_empty():
		return _send_error(client_id, "enemy_path cannot be empty", command_id)

	var enemy_node = _get_editor_node(enemy_path)
	if not enemy_node:
		return _send_error(client_id, "Enemy node not found: %s" % enemy_path, command_id)
	if not (enemy_node is CharacterBody3D):
		return _send_error(client_id, "Enemy node at %s must be CharacterBody3D" % enemy_path, command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var enemy: CharacterBody3D = enemy_node
	var enemy_mcp_path: String = _to_mcp_path(enemy)
	var create_navigation_agent: bool = bool(params.get("create_navigation_agent", true))
	var create_vision_area: bool = bool(params.get("create_vision_area", true))
	var create_attack_timer: bool = bool(params.get("create_attack_timer", true))
	var connect_signals: bool = bool(params.get("connect_signals", true))
	var movement_speed: float = float(params.get("movement_speed", 4.5))
	var acceleration: float = float(params.get("acceleration", movement_speed * 6.0))
	var attack_cooldown: float = max(0.01, float(params.get("attack_cooldown", 1.0)))
	var vision_radius: float = max(0.1, float(params.get("vision_radius", 6.0)))
	var detection_group: String = String(params.get("detection_group", "player")).strip_edges()
	var signal_flags: int = _build_signal_flags_from_params(params)

	var attach_plans: Array = []
	var created_nodes: Array = []
	var property_changes: Array = []
	var meta_changes: Array = []
	var signal_changes: Array = []

	var navigation_name: String = String(params.get("navigation_agent_name", "NavigationAgent3D")).strip_edges()
	if navigation_name.is_empty():
		navigation_name = "NavigationAgent3D"
	var navigation_node = enemy.get_node_or_null(navigation_name)
	if not navigation_node and create_navigation_agent:
		var new_navigation := NavigationAgent3D.new()
		new_navigation.name = _resolve_unique_child_name(enemy, navigation_name)
		navigation_node = new_navigation
		attach_plans.append({"parent": enemy, "node": new_navigation})
		created_nodes.append(new_navigation)
	if navigation_node and not (navigation_node is NavigationAgent3D):
		return _send_error(client_id, "Node at %s/%s is not NavigationAgent3D" % [enemy_mcp_path, navigation_name], command_id)
	var navigation_agent: NavigationAgent3D = null
	if navigation_node and navigation_node is NavigationAgent3D:
		navigation_agent = navigation_node
		property_changes.append_array(
			_capture_property_change(navigation_agent, "max_speed", float(params.get("navigation_max_speed", movement_speed)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "path_desired_distance", float(params.get("path_desired_distance", 0.6)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "target_desired_distance", float(params.get("target_desired_distance", 0.8)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "avoidance_enabled", bool(params.get("avoidance_enabled", true)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "neighbor_distance", float(params.get("neighbor_distance", 7.5)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "max_neighbors", int(params.get("max_neighbors", 10)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "radius", float(params.get("agent_radius", 0.45)))
		)
		property_changes.append_array(
			_capture_property_change(navigation_agent, "height", float(params.get("agent_height", 1.8)))
		)

	var vision_name: String = String(params.get("vision_area_name", "VisionArea3D")).strip_edges()
	if vision_name.is_empty():
		vision_name = "VisionArea3D"
	var vision_node = enemy.get_node_or_null(vision_name)
	if not vision_node and create_vision_area:
		var new_vision_area := Area3D.new()
		new_vision_area.name = _resolve_unique_child_name(enemy, vision_name)
		vision_node = new_vision_area
		attach_plans.append({"parent": enemy, "node": new_vision_area})
		created_nodes.append(new_vision_area)
	if vision_node and not (vision_node is Area3D):
		return _send_error(client_id, "Node at %s/%s is not Area3D" % [enemy_mcp_path, vision_name], command_id)

	var vision_area: Area3D = null
	if vision_node and vision_node is Area3D:
		vision_area = vision_node
		property_changes.append_array(_capture_property_change(vision_area, "monitoring", true))
		property_changes.append_array(_capture_property_change(vision_area, "monitorable", true))
		if params.has("vision_collision_layer"):
			property_changes.append_array(
				_capture_property_change(vision_area, "collision_layer", int(params.get("vision_collision_layer")))
			)
		if params.has("vision_collision_mask"):
			property_changes.append_array(
				_capture_property_change(vision_area, "collision_mask", int(params.get("vision_collision_mask")))
			)
		if params.has("vision_offset"):
			property_changes.append_array(
				_capture_property_change(vision_area, "position", _parse_vector3_param(params.get("vision_offset")))
			)

		var vision_shape_node: CollisionShape3D = vision_area.get_node_or_null("CollisionShape3D")
		if not vision_shape_node:
			for child in vision_area.get_children():
				if child is CollisionShape3D:
					vision_shape_node = child
					break
		if not vision_shape_node and create_vision_area:
			var new_collision := CollisionShape3D.new()
			new_collision.name = _resolve_unique_child_name(vision_area, "CollisionShape3D")
			var new_sphere := SphereShape3D.new()
			new_sphere.radius = vision_radius
			new_collision.shape = new_sphere
			if vision_area.get_parent() == null:
				vision_area.add_child(new_collision)
			else:
				attach_plans.append({"parent": vision_area, "node": new_collision})
			created_nodes.append(new_collision)
			vision_shape_node = new_collision
		if vision_shape_node:
			if vision_shape_node.shape and vision_shape_node.shape is SphereShape3D:
				property_changes.append_array(
					_capture_property_change(vision_shape_node.shape, "radius", vision_radius)
				)
			else:
				var replacement_sphere := SphereShape3D.new()
				replacement_sphere.radius = vision_radius
				property_changes.append_array(
					_capture_property_change(vision_shape_node, "shape", replacement_sphere)
				)

	var timer_name: String = String(params.get("attack_timer_name", "AttackCooldown")).strip_edges()
	if timer_name.is_empty():
		timer_name = "AttackCooldown"
	var timer_node = enemy.get_node_or_null(timer_name)
	if not timer_node and create_attack_timer:
		var new_timer := Timer.new()
		new_timer.name = _resolve_unique_child_name(enemy, timer_name)
		timer_node = new_timer
		attach_plans.append({"parent": enemy, "node": new_timer})
		created_nodes.append(new_timer)
	if timer_node and not (timer_node is Timer):
		return _send_error(client_id, "Node at %s/%s is not Timer" % [enemy_mcp_path, timer_name], command_id)

	var attack_timer: Timer = null
	if timer_node and timer_node is Timer:
		attack_timer = timer_node
		property_changes.append_array(_capture_property_change(attack_timer, "wait_time", attack_cooldown))
		property_changes.append_array(_capture_property_change(attack_timer, "one_shot", true))
		property_changes.append_array(_capture_property_change(attack_timer, "autostart", false))

	if detection_group.is_empty():
		detection_group = "player"
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_ai_profile", "patrol_chase_3d"))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_movement_speed", movement_speed))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_acceleration", acceleration))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_detection_group", detection_group))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_attack_cooldown", attack_cooldown))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_vision_radius", vision_radius))
	meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_loop", bool(params.get("patrol_loop", true))))
	if navigation_agent:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_navigation_agent_path", _join_mcp_path(enemy_mcp_path, String(navigation_agent.name)))
		)
	if vision_area:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_vision_area_path", _join_mcp_path(enemy_mcp_path, String(vision_area.name)))
		)
	if attack_timer:
		meta_changes.append_array(
			_capture_meta_change(enemy, "mcp_enemy_attack_timer_path", _join_mcp_path(enemy_mcp_path, String(attack_timer.name)))
		)
	if params.has("target_path"):
		var target_path: String = String(params.get("target_path", "")).strip_edges()
		if not target_path.is_empty():
			meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_target_path", target_path))

	if params.has("patrol_points"):
		var patrol_points_param = params.get("patrol_points")
		if typeof(patrol_points_param) != TYPE_ARRAY:
			return _send_error(client_id, "patrol_points must be an array", command_id)
		var patrol_points: Array = patrol_points_param
		var serialized_patrol_points: Array = []
		for idx in range(patrol_points.size()):
			serialized_patrol_points.append(_vector3_to_dict(_parse_vector3_param(patrol_points[idx])))
		meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_points", serialized_patrol_points))
		meta_changes.append_array(_capture_meta_change(enemy, "mcp_enemy_patrol_index", 0))

	if connect_signals:
		var signal_target_path: String = String(params.get("signal_target_path", enemy_mcp_path)).strip_edges()
		if signal_target_path.is_empty():
			signal_target_path = enemy_mcp_path
		var signal_target = _get_editor_node(signal_target_path)
		if not signal_target:
			return _send_error(client_id, "Signal target node not found: %s" % signal_target_path, command_id)

		if vision_area:
			var entered_method: String = String(params.get("vision_entered_method", "_on_enemy_vision_body_entered")).strip_edges()
			var exited_method: String = String(params.get("vision_exited_method", "_on_enemy_vision_body_exited")).strip_edges()
			signal_changes.append_array(
				_capture_signal_connection_change(vision_area, "body_entered", signal_target, entered_method, signal_flags)
			)
			signal_changes.append_array(
				_capture_signal_connection_change(vision_area, "body_exited", signal_target, exited_method, signal_flags)
			)
		if attack_timer:
			var timeout_method: String = String(params.get("attack_timeout_method", "_on_enemy_attack_cooldown_timeout")).strip_edges()
			signal_changes.append_array(
				_capture_signal_connection_change(attack_timer, "timeout", signal_target, timeout_method, signal_flags)
			)

	if attach_plans.is_empty() and property_changes.is_empty() and meta_changes.is_empty() and signal_changes.is_empty():
		return _send_success(client_id, {
			"enemy_path": enemy_mcp_path,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "author_enemy_ai_3d",
		"enemy_path": enemy_mcp_path,
		"created_count": created_nodes.size(),
		"property_change_count": property_changes.size(),
		"meta_change_count": meta_changes.size(),
		"signal_change_count": signal_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Author Enemy AI 3D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Author Enemy AI 3D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for enemy AI 3D authoring", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_property_changes: Array = []
	for change in property_changes:
		var target_object: Object = change.get("target", enemy)
		transaction.add_do_property(target_object, change.property, change.value)
		transaction.add_undo_property(target_object, change.property, change.previous)
		if change.value is Resource:
			transaction.add_do_reference(change.value)
		serialized_property_changes.append({
			"target_type": target_object.get_class(),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_meta_changes: Array = []
	for change in meta_changes:
		transaction.add_do_method(enemy, "set_meta", [change.key, change.value])
		if change.previous_exists:
			transaction.add_undo_method(enemy, "set_meta", [change.key, change.previous])
		else:
			transaction.add_undo_method(enemy, "remove_meta", [change.key])
		serialized_meta_changes.append({
			"key": change.key,
			"previous_exists": change.previous_exists,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	var serialized_signal_changes: Array = []
	for change in signal_changes:
		transaction.add_do_method(
			self,
			"_connect_signal_change_safe",
			[change]
		)
		transaction.add_undo_method(
			self,
			"_disconnect_signal_change_safe",
			[change]
		)
		serialized_signal_changes.append({
			"emitter": _describe_object_path(change.emitter),
			"signal": change.signal_name,
			"target": _describe_object_path(change.target),
			"method_name": change.method_name,
			"flags": change.flags,
		})

	var predicted_created_paths: Array = []
	for created in created_nodes:
		var created_node: Node = created
		var parent_node = created_node.get_parent()
		if parent_node:
			predicted_created_paths.append(_join_mcp_path(_to_mcp_path(parent_node), String(created_node.name)))
		else:
			predicted_created_paths.append(_join_mcp_path(enemy_mcp_path, String(created_node.name)))

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Authored enemy AI 3D", "_author_enemy_ai_3d", {
			"enemy_path": _to_mcp_path(enemy),
			"created_count": created_nodes.size(),
			"property_change_count": serialized_property_changes.size(),
			"meta_change_count": serialized_meta_changes.size(),
			"signal_change_count": serialized_signal_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "enemy_ai_3d",
			"line_num": 0,
		})
	)

	var response := {
		"enemy_path": enemy_mcp_path,
		"created_nodes": predicted_created_paths,
		"property_changes": serialized_property_changes,
		"meta_changes": serialized_meta_changes,
		"signal_changes": serialized_signal_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit enemy AI 3D authoring", command_id)
		var committed_paths: Array = []
		for created in created_nodes:
			var created_node: Node = created
			committed_paths.append(_to_mcp_path(created_node))
		response["created_nodes"] = committed_paths
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _build_menu_ui_flow_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path: String = params.get("parent_path", "/root")
	var flow_name: String = String(params.get("flow_name", "MenuFlow")).strip_edges()
	var transaction_id: String = params.get("transaction_id", "")
	var include_pause_menu: bool = bool(params.get("include_pause_menu", true))
	var include_game_over_menu: bool = bool(params.get("include_game_over_menu", true))
	var create_background: bool = bool(params.get("create_background", true))
	var connect_signals: bool = bool(params.get("connect_signals", false))
	var panel_size: Vector2 = _parse_vector2_param(params.get("panel_size", Vector2(420.0, 300.0)))
	var signal_flags: int = _build_signal_flags_from_params(params)

	if flow_name.is_empty():
		flow_name = "MenuFlow"
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return _send_error(client_id, "panel_size must be greater than zero on both axes", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)

	var flow_root := CanvasLayer.new()
	flow_root.name = _resolve_unique_child_name(parent, flow_name)

	var root_control := Control.new()
	root_control.name = "Root"
	_configure_control_full_rect(root_control)
	flow_root.add_child(root_control)

	var created_nodes: Array = [flow_root, root_control]
	var attach_plans: Array = [{"parent": parent, "node": flow_root}]
	var signal_changes: Array = []

	if create_background:
		var background := ColorRect.new()
		background.name = "Backdrop"
		_configure_control_full_rect(background)
		background.color = _convert_property_value(background, "color", params.get("background_color", Color(0, 0, 0, 0.55)))
		root_control.add_child(background)
		created_nodes.append(background)

	var menus_root := Control.new()
	menus_root.name = "Menus"
	_configure_control_full_rect(menus_root)
	root_control.add_child(menus_root)
	created_nodes.append(menus_root)

	var button_lookup: Dictionary = {}

	var main_menu := CenterContainer.new()
	main_menu.name = "MainMenu"
	_configure_control_full_rect(main_menu)
	menus_root.add_child(main_menu)
	created_nodes.append(main_menu)
	var main_panel := PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.custom_minimum_size = panel_size
	main_menu.add_child(main_panel)
	created_nodes.append(main_panel)
	var main_margin := MarginContainer.new()
	main_margin.name = "MainMargin"
	main_margin.add_theme_constant_override("margin_left", 24)
	main_margin.add_theme_constant_override("margin_right", 24)
	main_margin.add_theme_constant_override("margin_top", 20)
	main_margin.add_theme_constant_override("margin_bottom", 20)
	main_panel.add_child(main_margin)
	created_nodes.append(main_margin)
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.add_theme_constant_override("separation", 10)
	main_margin.add_child(main_vbox)
	created_nodes.append(main_vbox)
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = String(params.get("title_text", "Game Title"))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(title_label)
	created_nodes.append(title_label)
	var start_button := Button.new()
	start_button.name = "StartButton"
	start_button.text = String(params.get("start_text", "Start"))
	main_vbox.add_child(start_button)
	created_nodes.append(start_button)
	button_lookup["StartButton"] = start_button
	var quit_button := Button.new()
	quit_button.name = "QuitButton"
	quit_button.text = String(params.get("quit_text", "Quit"))
	main_vbox.add_child(quit_button)
	created_nodes.append(quit_button)
	button_lookup["QuitButton"] = quit_button

	var pause_menu: CenterContainer = null
	if include_pause_menu:
		pause_menu = CenterContainer.new()
		pause_menu.name = "PauseMenu"
		pause_menu.visible = false
		_configure_control_full_rect(pause_menu)
		menus_root.add_child(pause_menu)
		created_nodes.append(pause_menu)
		var pause_panel := PanelContainer.new()
		pause_panel.name = "PausePanel"
		pause_panel.custom_minimum_size = panel_size
		pause_menu.add_child(pause_panel)
		created_nodes.append(pause_panel)
		var pause_margin := MarginContainer.new()
		pause_margin.name = "PauseMargin"
		pause_margin.add_theme_constant_override("margin_left", 24)
		pause_margin.add_theme_constant_override("margin_right", 24)
		pause_margin.add_theme_constant_override("margin_top", 20)
		pause_margin.add_theme_constant_override("margin_bottom", 20)
		pause_panel.add_child(pause_margin)
		created_nodes.append(pause_margin)
		var pause_vbox := VBoxContainer.new()
		pause_vbox.name = "PauseVBox"
		pause_vbox.add_theme_constant_override("separation", 10)
		pause_margin.add_child(pause_vbox)
		created_nodes.append(pause_vbox)
		var pause_title := Label.new()
		pause_title.name = "PauseTitleLabel"
		pause_title.text = String(params.get("pause_title_text", "Paused"))
		pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pause_vbox.add_child(pause_title)
		created_nodes.append(pause_title)
		var resume_button := Button.new()
		resume_button.name = "ResumeButton"
		resume_button.text = String(params.get("resume_text", "Resume"))
		pause_vbox.add_child(resume_button)
		created_nodes.append(resume_button)
		button_lookup["ResumeButton"] = resume_button
		var pause_restart_button := Button.new()
		pause_restart_button.name = "PauseRestartButton"
		pause_restart_button.text = String(params.get("pause_restart_text", "Restart"))
		pause_vbox.add_child(pause_restart_button)
		created_nodes.append(pause_restart_button)
		button_lookup["PauseRestartButton"] = pause_restart_button
		var pause_quit_button := Button.new()
		pause_quit_button.name = "PauseQuitToMenuButton"
		pause_quit_button.text = String(params.get("pause_quit_text", "Quit To Menu"))
		pause_vbox.add_child(pause_quit_button)
		created_nodes.append(pause_quit_button)
		button_lookup["PauseQuitToMenuButton"] = pause_quit_button

	var game_over_menu: CenterContainer = null
	if include_game_over_menu:
		game_over_menu = CenterContainer.new()
		game_over_menu.name = "GameOverMenu"
		game_over_menu.visible = false
		_configure_control_full_rect(game_over_menu)
		menus_root.add_child(game_over_menu)
		created_nodes.append(game_over_menu)
		var game_over_panel := PanelContainer.new()
		game_over_panel.name = "GameOverPanel"
		game_over_panel.custom_minimum_size = panel_size
		game_over_menu.add_child(game_over_panel)
		created_nodes.append(game_over_panel)
		var game_over_margin := MarginContainer.new()
		game_over_margin.name = "GameOverMargin"
		game_over_margin.add_theme_constant_override("margin_left", 24)
		game_over_margin.add_theme_constant_override("margin_right", 24)
		game_over_margin.add_theme_constant_override("margin_top", 20)
		game_over_margin.add_theme_constant_override("margin_bottom", 20)
		game_over_panel.add_child(game_over_margin)
		created_nodes.append(game_over_margin)
		var game_over_vbox := VBoxContainer.new()
		game_over_vbox.name = "GameOverVBox"
		game_over_vbox.add_theme_constant_override("separation", 10)
		game_over_margin.add_child(game_over_vbox)
		created_nodes.append(game_over_vbox)
		var game_over_title := Label.new()
		game_over_title.name = "GameOverTitleLabel"
		game_over_title.text = String(params.get("game_over_title_text", "Game Over"))
		game_over_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		game_over_vbox.add_child(game_over_title)
		created_nodes.append(game_over_title)
		var retry_button := Button.new()
		retry_button.name = "RetryButton"
		retry_button.text = String(params.get("retry_text", "Retry"))
		game_over_vbox.add_child(retry_button)
		created_nodes.append(retry_button)
		button_lookup["RetryButton"] = retry_button
		var game_over_quit_button := Button.new()
		game_over_quit_button.name = "GameOverQuitToMenuButton"
		game_over_quit_button.text = String(params.get("game_over_quit_text", "Quit To Menu"))
		game_over_vbox.add_child(game_over_quit_button)
		created_nodes.append(game_over_quit_button)
		button_lookup["GameOverQuitToMenuButton"] = game_over_quit_button

	if connect_signals:
		var controller_path: String = String(params.get("controller_path", "")).strip_edges()
		if controller_path.is_empty():
			return _send_error(client_id, "controller_path is required when connect_signals=true", command_id)
		var controller_node = _get_editor_node(controller_path)
		if not controller_node:
			return _send_error(client_id, "Controller node not found: %s" % controller_path, command_id)

		var method_map := {
			"StartButton": String(params.get("start_pressed_method", "_on_menu_start_pressed")).strip_edges(),
			"QuitButton": String(params.get("quit_pressed_method", "_on_menu_quit_pressed")).strip_edges(),
			"ResumeButton": String(params.get("resume_pressed_method", "_on_pause_resume_pressed")).strip_edges(),
			"PauseRestartButton": String(params.get("pause_restart_pressed_method", "_on_pause_restart_pressed")).strip_edges(),
			"PauseQuitToMenuButton": String(params.get("pause_quit_pressed_method", "_on_pause_quit_to_menu_pressed")).strip_edges(),
			"RetryButton": String(params.get("retry_pressed_method", "_on_game_over_retry_pressed")).strip_edges(),
			"GameOverQuitToMenuButton": String(params.get("game_over_quit_pressed_method", "_on_game_over_quit_to_menu_pressed")).strip_edges(),
		}
		for button_name in method_map.keys():
			if not button_lookup.has(button_name):
				continue
			var method_name: String = method_map[button_name]
			if method_name.is_empty():
				continue
			var button_node: Button = button_lookup[button_name]
			signal_changes.append_array(
				_capture_signal_connection_change(button_node, "pressed", controller_node, method_name, signal_flags)
			)

	if attach_plans.is_empty() and signal_changes.is_empty():
		return _send_success(client_id, {
			"flow_path": _join_mcp_path(_to_mcp_path(parent), flow_root.name),
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "build_menu_ui_flow_2d",
		"parent_path": _to_mcp_path(parent),
		"flow_name": flow_root.name,
		"created_count": created_nodes.size(),
		"signal_change_count": signal_changes.size(),
		"include_pause_menu": include_pause_menu,
		"include_game_over_menu": include_game_over_menu,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Build Menu UI Flow 2D", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Build Menu UI Flow 2D", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for menu UI flow generation", command_id)

	for plan in attach_plans:
		var parent_node: Node = plan["parent"]
		var child_node: Node = plan["node"]
		transaction.add_do_method(parent_node, "add_child", [child_node])
		transaction.add_undo_method(parent_node, "remove_child", [child_node])
		transaction.add_undo_method(child_node, "queue_free")
		transaction.add_do_reference(child_node)

	for created in created_nodes:
		var created_node: Node = created
		transaction.add_do_method(created_node, "set_owner", [edited_scene_root])

	var serialized_signal_changes: Array = []
	for change in signal_changes:
		transaction.add_do_method(
			self,
			"_connect_signal_change_safe",
			[change]
		)
		transaction.add_undo_method(
			self,
			"_disconnect_signal_change_safe",
			[change]
		)
		serialized_signal_changes.append({
			"emitter": _describe_object_path(change.emitter),
			"signal": change.signal_name,
			"target": _describe_object_path(change.target),
			"method_name": change.method_name,
			"flags": change.flags,
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Built menu UI flow 2D", "_build_menu_ui_flow_2d", {
			"flow_path": _to_mcp_path(flow_root),
			"parent_path": _to_mcp_path(parent),
			"created_count": created_nodes.size(),
			"signal_change_count": serialized_signal_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_menu",
			"line_num": 0,
		})
	)

	var predicted_flow_path: String = _join_mcp_path(_to_mcp_path(parent), flow_root.name)
	var response := {
		"flow_name": flow_root.name,
		"flow_path": predicted_flow_path,
		"menus": {
			"main_menu": _join_mcp_path(predicted_flow_path, "Root/Menus/MainMenu"),
			"pause_menu": (_join_mcp_path(predicted_flow_path, "Root/Menus/PauseMenu") if include_pause_menu else ""),
			"game_over_menu": (_join_mcp_path(predicted_flow_path, "Root/Menus/GameOverMenu") if include_game_over_menu else ""),
		},
		"signal_changes": serialized_signal_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit menu UI flow generation", command_id)
		response["flow_path"] = _to_mcp_path(flow_root)
		response["menus"] = {
			"main_menu": _to_mcp_path(main_menu),
			"pause_menu": (_to_mcp_path(pause_menu) if pause_menu else ""),
			"game_over_menu": (_to_mcp_path(game_over_menu) if game_over_menu else ""),
		}
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _set_menu_ui_flow_state(client_id: int, params: Dictionary, command_id: String) -> void:
	var flow_path: String = params.get("flow_path", "")
	var state: String = String(params.get("state", "main")).strip_edges().to_lower()
	var transaction_id: String = params.get("transaction_id", "")

	if flow_path.is_empty():
		return _send_error(client_id, "flow_path cannot be empty", command_id)

	var flow_node = _get_editor_node(flow_path)
	if not flow_node:
		return _send_error(client_id, "Flow node not found: %s" % flow_path, command_id)

	var root_control = flow_node.get_node_or_null("Root")
	if not root_control or not (root_control is Control):
		return _send_error(client_id, "Flow node at %s is missing Root control" % flow_path, command_id)

	var main_menu = root_control.get_node_or_null("Menus/MainMenu")
	if not main_menu:
		main_menu = root_control.get_node_or_null("MainMenu")
	var pause_menu = root_control.get_node_or_null("Menus/PauseMenu")
	if not pause_menu:
		pause_menu = root_control.get_node_or_null("PauseMenu")
	var game_over_menu = root_control.get_node_or_null("Menus/GameOverMenu")
	if not game_over_menu:
		game_over_menu = root_control.get_node_or_null("GameOverMenu")

	var show_main: bool = false
	var show_pause: bool = false
	var show_game_over: bool = false
	match state:
		"main":
			show_main = true
		"pause":
			show_pause = true
		"game_over", "gameover":
			show_game_over = true
		"hidden":
			pass
		_:
			return _send_error(client_id, "state must be one of: main, pause, game_over, hidden", command_id)

	var pending_changes: Array = []
	if main_menu and main_menu is CanvasItem:
		pending_changes.append_array(_capture_property_change(main_menu, "visible", show_main))
	if pause_menu and pause_menu is CanvasItem:
		pending_changes.append_array(_capture_property_change(pause_menu, "visible", show_pause))
	if game_over_menu and game_over_menu is CanvasItem:
		pending_changes.append_array(_capture_property_change(game_over_menu, "visible", show_game_over))

	if pending_changes.is_empty():
		return _send_success(client_id, {
			"flow_path": _to_mcp_path(flow_node),
			"state": state,
			"status": "no_change",
		}, command_id)

	var transaction_metadata := {
		"command": "set_menu_ui_flow_state",
		"flow_path": _to_mcp_path(flow_node),
		"state": state,
		"change_count": pending_changes.size(),
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Set Menu UI Flow State", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Set Menu UI Flow State", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for menu state update", command_id)

	var serialized_changes: Array = []
	for change in pending_changes:
		var target_object: Object = change.get("target", flow_node)
		transaction.add_do_property(target_object, change.property, change.value)
		transaction.add_undo_property(target_object, change.property, change.previous)
		serialized_changes.append({
			"target": (target_object.get_path() if target_object is Node else target_object.get_class()),
			"property": change.property,
			"previous": var_to_str(change.previous),
			"value": var_to_str(change.value),
		})

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Updated menu UI flow state", "_set_menu_ui_flow_state", {
			"flow_path": _to_mcp_path(flow_node),
			"state": state,
			"change_count": serialized_changes.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_menu",
			"line_num": 0,
		})
	)

	var response := {
		"flow_path": _to_mcp_path(flow_node),
		"state": state,
		"changes": serialized_changes,
		"transaction_id": transaction.transaction_id,
	}
	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit menu state update", command_id)
		response["status"] = "committed"
	else:
		response["status"] = "pending"

	_send_success(client_id, response, command_id)


func _rename_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	var new_name = params.get("new_name", "")
	var transaction_id = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if new_name.is_empty():
		return _send_error(client_id, "New node name cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if node.name == new_name:
		_send_success(client_id, {
			"node_path": node_path,
			"new_name": new_name,
			"message": "Node already has the requested name",
			"status": "no_change"
		}, command_id)
		return

	var parent = node.get_parent()
	if parent:
		for sibling in parent.get_children():
			if sibling != node and sibling.name == new_name:
				return _send_error(client_id, "A sibling node with the name %s already exists" % new_name, command_id)

	var old_name = node.name
	var transaction_metadata := {
		"command": "rename_node",
		"node_path": node_path,
		"new_name": new_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Rename Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Rename Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node rename", command_id)

	transaction.add_do_property(node, "name", new_name)
	transaction.add_undo_property(node, "name", old_name)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Renamed node", "_rename_node", {
			"old_name": old_name,
			"new_name": new_name,
			"node_path": node_path,
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node rename", command_id)

		var path_string = _to_mcp_path(node)
		_send_success(client_id, {
			"previous_name": old_name,
			"new_name": new_name,
			"node_path": path_string,
			"transaction_id": transaction.transaction_id,
			"status": "committed"
		}, command_id)
	else:
		_send_success(client_id, {
			"previous_name": old_name,
			"new_name": new_name,
			"node_path": node_path,
			"transaction_id": transaction.transaction_id,
			"status": "pending"
		}, command_id)

func _add_node_to_group(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	var group_name = params.get("group_name", "")
	var persistent = params.get("persistent", true)
	var transaction_id = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if group_name.is_empty():
		return _send_error(client_id, "Group name cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if node.is_in_group(group_name):
		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"persistent": persistent,
			"status": "already_member"
		}, command_id)
		return

	var transaction_metadata := {
		"command": "add_node_to_group",
		"node_path": node_path,
		"group_name": group_name,
		"persistent": persistent,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Add Node To Group", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Add Node To Group", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for group addition", command_id)

	transaction.add_do_method(node, "add_to_group", [group_name, persistent])
	transaction.add_undo_method(node, "remove_from_group", [group_name])
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Added node to group", "_add_node_to_group", {
			"node_path": node_path,
			"group_name": group_name,
			"persistent": persistent,
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit group addition", command_id)

		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"persistent": persistent,
			"transaction_id": transaction.transaction_id,
			"status": "committed"
		}, command_id)
	else:
		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"persistent": persistent,
			"transaction_id": transaction.transaction_id,
			"status": "pending"
		}, command_id)

func _remove_node_from_group(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	var group_name = params.get("group_name", "")
	var transaction_id = params.get("transaction_id", "")
	var restore_persistent = params.get("persistent", true)

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if group_name.is_empty():
		return _send_error(client_id, "Group name cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not node.is_in_group(group_name):
		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"status": "not_member"
		}, command_id)
		return

	var transaction_metadata := {
		"command": "remove_node_from_group",
		"node_path": node_path,
		"group_name": group_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Remove Node From Group", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Remove Node From Group", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for group removal", command_id)

	transaction.add_do_method(node, "remove_from_group", [group_name])
	transaction.add_undo_method(node, "add_to_group", [group_name, restore_persistent])
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Removed node from group", "_remove_node_from_group", {
			"node_path": node_path,
			"group_name": group_name,
			"persistent": restore_persistent,
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit group removal", command_id)

		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"transaction_id": transaction.transaction_id,
			"status": "committed"
		}, command_id)
	else:
		_send_success(client_id, {
			"node_path": node_path,
			"group_name": group_name,
			"transaction_id": transaction.transaction_id,
			"status": "pending"
		}, command_id)

func _configure_camera2d_limits(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := params.get("node_path", "")
	var transaction_id := params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Camera2D node path cannot be empty", command_id)

	var node := _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not (node is Camera2D):
		return _send_error(client_id, "Node at %s is not a Camera2D" % node_path, command_id)

	var limits_input = params.get("limits", null)
	if limits_input != null and typeof(limits_input) != TYPE_DICTIONARY:
		_log("limits must be provided as a dictionary", "_configure_camera2d_limits", {
			"node_path": node_path,
			"system_section": "camera2d",
			"line_num": 0,
		}, true)
		return _send_error(client_id, "limits must be a dictionary of Camera2D properties", command_id)

	var smoothing_input = params.get("smoothing", null)
	if smoothing_input != null and typeof(smoothing_input) != TYPE_DICTIONARY:
		_log("smoothing must be provided as a dictionary", "_configure_camera2d_limits", {
			"node_path": node_path,
			"system_section": "camera2d",
			"line_num": 0,
		}, true)
		return _send_error(client_id, "smoothing must be a dictionary of Camera2D properties", command_id)

	var limit_config: Dictionary = {}
	if typeof(limits_input) == TYPE_DICTIONARY:
		limit_config = (limits_input as Dictionary).duplicate(true)

	var smoothing_config: Dictionary = {}
	if typeof(smoothing_input) == TYPE_DICTIONARY:
		smoothing_config = (smoothing_input as Dictionary).duplicate(true)

	if limit_config.is_empty() and smoothing_config.is_empty():
		_log("No Camera2D configuration changes were provided", "_configure_camera2d_limits", {
			"node_path": node_path,
			"system_section": "camera2d",
			"line_num": 0,
		}, true)
		return _send_error(client_id, "Provide at least one limit or smoothing property to update", command_id)

	var pending_changes: Array = []
	var limit_property_map := {
		"enabled": "limit_enabled",
		"smoothed": "limit_smoothed",
		"draw_limits": "editor_draw_limits",
		"left": "limit_left",
		"right": "limit_right",
		"top": "limit_top",
		"bottom": "limit_bottom",
	}

	for key in limit_property_map.keys():
		if limit_config.has(key):
			var property_name: String = limit_property_map[key]
			var new_value = limit_config[key]
			var current_value = node.get(property_name)
			if current_value != new_value:
				pending_changes.append({
					"property": property_name,
					"previous": current_value,
					"value": new_value,
				})

	var smoothing_property_map := {
		"position_enabled": "position_smoothing_enabled",
		"position_speed": "position_smoothing_speed",
		"rotation_enabled": "rotation_smoothing_enabled",
		"rotation_speed": "rotation_smoothing_speed",
	}

	for key in smoothing_property_map.keys():
		if smoothing_config.has(key):
			var property_name: String = smoothing_property_map[key]
			var new_value = smoothing_config[key]
			var current_value = node.get(property_name)
			if current_value != new_value:
				pending_changes.append({
					"property": property_name,
					"previous": current_value,
					"value": new_value,
				})

	if pending_changes.is_empty():
		_log("Camera2D already matches requested configuration", "_configure_camera2d_limits", {
			"node_path": node_path,
			"system_section": "camera2d",
			"changes": pending_changes,
			"line_num": 0,
		})
		_send_success(client_id, {
			"node_path": node_path,
			"changes": [],
			"status": "no_change"
		}, command_id)
		return

	var transaction_metadata := {
		"command": "configure_camera2d_limits",
		"node_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Configure Camera2D Limits", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Camera2D Limits", transaction_metadata)

	if not transaction:
		_log("Failed to acquire scene transaction for Camera2D limits", "_configure_camera2d_limits", {
			"node_path": node_path,
			"system_section": "camera2d",
			"transaction_id": transaction_id,
			"line_num": 0,
		}, true)
		return _send_error(client_id, "Failed to obtain scene transaction for Camera2D limits", command_id)

	for change in pending_changes:
		transaction.add_do_property(node, change.property, change.value)
		transaction.add_undo_property(node, change.property, change.previous)

	var committed_changes := pending_changes.duplicate(true)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Configured Camera2D limits", "_configure_camera2d_limits", {
			"node_path": node_path,
			"transaction_id": transaction.transaction_id,
			"system_section": "camera2d",
			"changes": committed_changes,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			_log("Failed to commit Camera2D limit configuration", "_configure_camera2d_limits", {
				"node_path": node_path,
				"system_section": "camera2d",
				"line_num": 0,
			}, true)
			return _send_error(client_id, "Failed to commit Camera2D limit configuration", command_id)

		var path_string = _to_mcp_path(node)
		_send_success(client_id, {
			"node_path": path_string,
			"transaction_id": transaction.transaction_id,
			"changes": committed_changes,
			"status": "committed"
		}, command_id)
	else:
		_send_success(client_id, {
			"node_path": node_path,
			"transaction_id": transaction.transaction_id,
			"changes": committed_changes,
			"status": "pending"
		}, command_id)

func _list_node_groups(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	var groups: Array = node.get_groups()
	_send_success(client_id, {
		"node_path": node_path,
		"groups": groups
	}, command_id)

func _list_nodes_in_group(client_id: int, params: Dictionary, command_id: String) -> void:
	var group_name = params.get("group_name", "")
	if group_name.is_empty():
		return _send_error(client_id, "Group name cannot be empty", command_id)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)

	var results: Array = []
	_collect_nodes_in_group(edited_scene_root, group_name, "/root", results)

	_send_success(client_id, {
		"group_name": group_name,
		"nodes": results
	}, command_id)

func _create_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path = params.get("parent_path", "/root")
	var node_type = params.get("node_type", "Node")
	var node_name = params.get("node_name", "NewNode")
	var transaction_id = params.get("transaction_id", "")
	
	# Validation
	if not ClassDB.class_exists(node_type):
		return _send_error(client_id, "Invalid node type: %s" % node_type, command_id)
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)
	
	# Get the parent node using the editor node helper
	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
	
	# Create the node
	var node
	if ClassDB.can_instantiate(node_type):
		node = ClassDB.instantiate(node_type)
	else:
		return _send_error(client_id, "Cannot instantiate node of type: %s" % node_type, command_id)

	if not node:
		return _send_error(client_id, "Failed to create node of type: %s" % node_type, command_id)

	# Set the node name
	node.name = node_name

	var parent_mcp_path: String = _to_mcp_path(parent)
	var expected_child_path: String = parent_mcp_path + "/" + node_name

	var transaction_metadata := {
		"command": "create_node",
		"node_type": node_type,
		"node_name": node_name,
		"parent_path": parent_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Create Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Create Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node creation", command_id)

	transaction.add_do_method(parent, "add_child", [node])
	transaction.add_do_method(node, "set_owner", [edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [node])
	transaction.add_undo_method(node, "queue_free")
	transaction.add_do_reference(node)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.clear()
			selection.add_node(node)
		_log("Created node", "_create_node", {
			"node_path": _to_mcp_path(node),
			"node_type": node_type,
			"parent_path": parent_mcp_path,
			"requested_parent_path": parent_path,
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"node_type": node_type,
		"node_name": node_name,
		"parent_path": parent_mcp_path,
		"requested_parent_path": parent_path,
		"transaction_id": transaction.transaction_id,
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node creation", command_id)
		var path_string = _to_mcp_path(node)
		response["node_path"] = path_string
		response["status"] = "committed"
		_send_success(client_id, response, command_id)
	else:
		response["expected_path"] = expected_child_path
		response["node_path"] = expected_child_path
		response["status"] = "pending"
		_send_success(client_id, response, command_id)

func _delete_node(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	var transaction_id = params.get("transaction_id", "")
	
	# Validation
	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var edited_scene_root = editor_interface.get_edited_scene_root()
	
	if not edited_scene_root:
		return _send_error(client_id, "No scene is currently being edited", command_id)
	
	# Get the node using the editor node helper
	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	
	# Cannot delete the root node
	if node == edited_scene_root:
		return _send_error(client_id, "Cannot delete the root node", command_id)
	
	# Get parent for operation
	var parent = node.get_parent()
	if not parent:
		return _send_error(client_id, "Node has no parent: %s" % node_path, command_id)
	
	var child_index = parent.get_children().find(node)

	var transaction_metadata := {
		"command": "delete_node",
		"node_path": node_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Delete Node", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Delete Node", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for node deletion", command_id)

	transaction.add_do_method(parent, "remove_child", [node])
	transaction.add_do_method(node, "queue_free")
	transaction.add_undo_method(parent, "add_child", [node])
	transaction.add_undo_method(parent, "move_child", [node, child_index])
	transaction.add_undo_method(node, "set_owner", [edited_scene_root])
	transaction.add_do_reference(node)
	transaction.register_on_commit(func():
		_mark_scene_modified()
		var selection: EditorSelection = editor_interface.get_selection()
		if selection:
			selection.remove_node(node)
			selection.add_node(parent)
		_log("Deleted node", "_delete_node", {
			"deleted_node_path": node_path,
			"parent_path": _to_mcp_path(parent),
			"transaction_id": transaction.transaction_id,
			"system_section": DEFAULT_SYSTEM_SECTION,
			"line_num": 0,
		})
	)

	var response := {
		"deleted_node_path": node_path,
		"transaction_id": transaction.transaction_id,
		"parent_path": _to_mcp_path(parent),
	}

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit node deletion", command_id)
		response["status"] = "committed"
		_send_success(client_id, response, command_id)
	else:
		response["status"] = "pending"
		_send_success(client_id, response, command_id)

func _update_node_property(client_id: int, params: Dictionary, command_id: String) -> void:
		var node_path = params.get("node_path", "")
		var property_name: String = params.get("property", "")
		var property_value = params.get("value")
		var transaction_id = params.get("transaction_id", "")

		if node_path.is_empty():
				return _send_error(client_id, "Node path cannot be empty", command_id)

		if property_name.is_empty():
				return _send_error(client_id, "Property name cannot be empty", command_id)

		if property_value == null:
				return _send_error(client_id, "Property value cannot be null", command_id)

		var plugin = Engine.get_meta("GodotMCPPlugin")
		if not plugin:
				return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

		var node = _get_editor_node(node_path)
		if not node:
				return _send_error(client_id, "Node not found: %s" % node_path, command_id)

		var property_segments: PackedStringArray = property_name.split(".")
		var base_property_name: String = property_segments[0]
		if not base_property_name in node:
				return _send_error(client_id, "Property %s does not exist on node %s" % [base_property_name, node_path], command_id)

		var old_base_value = node.get(base_property_name)
		var conversion_result: Dictionary

		if property_segments.size() == 1:
				var parsed_value = _convert_property_value(node, base_property_name, property_value)
				conversion_result = {
						"ok": true,
						"value": parsed_value,
						"leaf_previous": old_base_value,
						"leaf_value": parsed_value,
				}
		else:
				var nested_path: Array = []
				for i in range(1, property_segments.size()):
						nested_path.append(property_segments[i])
				conversion_result = _apply_nested_property_value(old_base_value, nested_path, property_value)
				if not conversion_result.get("ok", false):
						return _send_error(client_id, conversion_result.get("error", "Failed to update nested property"), command_id)

		var updated_value = conversion_result.get("value")
		var previous_leaf = conversion_result.get("leaf_previous")
		var new_leaf_value = conversion_result.get("leaf_value")

		var transaction_metadata := {
				"command": "update_node_property",
				"node_path": node_path,
				"property": property_name,
				"base_property": base_property_name,
				"client_id": client_id,
				"command_id": command_id,
		}

		var transaction
		if transaction_id.is_empty():
				transaction = SceneTransactionManager.begin_inline("Update Node Property", transaction_metadata)
		else:
				transaction = SceneTransactionManager.get_transaction(transaction_id)
				if not transaction:
						transaction = SceneTransactionManager.begin_registered(transaction_id, "Update Node Property", transaction_metadata)

		if not transaction:
				return _send_error(client_id, "Failed to obtain scene transaction for property update", command_id)

		transaction.add_do_property(node, base_property_name, updated_value)
		transaction.add_undo_property(node, base_property_name, old_base_value)
		transaction.register_on_commit(func():
				_mark_scene_modified()
				_log("Updated node property", "_update_node_property", {
						"node_path": node_path,
						"property": property_name,
						"base_property": base_property_name,
						"value": var_to_str(new_leaf_value),
						"previous_value": var_to_str(previous_leaf),
						"transaction_id": transaction.transaction_id,
						"system_section": DEFAULT_SYSTEM_SECTION,
						"line_num": 0,
				})
		)

		var response := {
				"node_path": node_path,
				"property_path": property_name,
				"base_property": base_property_name,
				"raw_value": property_value,
				"new_value": var_to_str(new_leaf_value),
				"previous_value": var_to_str(previous_leaf),
				"transaction_id": transaction.transaction_id,
		}

		if property_segments.size() > 1:
				response["component_path"] = ".".join(property_segments.slice(1, property_segments.size()))

		if transaction_id.is_empty():
				if not transaction.commit():
						transaction.rollback()
						return _send_error(client_id, "Failed to commit property update", command_id)
				response["status"] = "committed"
				response["applied_value"] = var_to_str(node.get(base_property_name))
		else:
				response["status"] = "pending"

		_send_success(client_id, response, command_id)

func _get_node_properties(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path = params.get("node_path", "")
	
	# Validation
	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	
	# Get the node using the editor node helper
	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	
	# Get all properties
	var properties = {}
	var property_list = node.get_property_list()
	
	for prop in property_list:
		var name = prop["name"]
		if not name.begins_with("_"):  # Skip internal properties
			properties[name] = node.get(name)
	
	_send_success(client_id, {
		"node_path": node_path,
		"properties": properties
	}, command_id)

func _list_nodes(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent_path = params.get("parent_path", "/root")

	# Get the parent node using the editor node helper
	var parent = _get_editor_node(parent_path)
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
	
	# Get children
	var children = []
	for child in parent.get_children():
		children.append({
			"name": child.name,
			"type": child.get_class(),
			"path": str(child.get_path()).replace(str(parent.get_path()), parent_path)
		})
	
	_send_success(client_id, {
		"parent_path": parent_path,
		"children": children
	}, command_id)

func _collect_nodes_in_group(node: Node, group_name: String, current_path: String, results: Array) -> void:
	if node.is_in_group(group_name):
		results.append({
			"name": node.name,
			"type": node.get_class(),
			"path": current_path,
		})

	for child in node.get_children():
		if child is Node:
			_collect_nodes_in_group(child, group_name, current_path + "/" + child.name, results)


func _create_theme_override(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path: String = params.get("node_path", "")
	var override_type := String(params.get("override_type", "")).to_lower()
	var override_name: String = params.get("override_name", "")
	var value = params.get("value")
	var resource_path: String = params.get("resource_path", "")
	var transaction_id: String = params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)

	if override_type.is_empty():
		return _send_error(client_id, "Override type cannot be empty", command_id)

	if override_name.is_empty():
		return _send_error(client_id, "Override name cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)

	if not (node is Control):
		return _send_error(client_id, "Theme overrides require a Control-derived node", command_id)

	var control: Control = node
	var parse_result := _parse_theme_override_value(override_type, value, resource_path)
	if not parse_result.get("ok", false):
		return _send_error(client_id, parse_result.get("error", "Unsupported theme override value"), command_id)

	var parsed_value = parse_result.get("value")
	var previous_state := _get_theme_override_state(control, override_type, override_name)
	if previous_state.get("had_override", false) and _theme_override_values_equal(previous_state.get("value"), parsed_value):
		_log("Theme override already matches requested value", "_create_theme_override", {
			"node_path": node_path,
			"override_type": override_type,
			"override_name": override_name,
			"system_section": "ui_theme",
			"line_num": 0,
		})
		return _send_success(client_id, {
			"node_path": node_path,
			"override_type": override_type,
			"override_name": override_name,
			"value": _serialize_theme_override_value(parsed_value, override_type),
			"status": "no_change"
		}, command_id)

	var transaction_metadata := {
		"command": "create_theme_override",
		"node_path": node_path,
		"override_type": override_type,
		"override_name": override_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Create Theme Override", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Create Theme Override", transaction_metadata)

	if not transaction:
		_log("Failed to acquire scene transaction for theme override", "_create_theme_override", {
			"node_path": node_path,
			"override_type": override_type,
			"system_section": "ui_theme",
			"line_num": 0,
		}, true)
		return _send_error(client_id, "Failed to obtain scene transaction for theme override", command_id)

	_register_theme_override_transaction(transaction, control, override_type, override_name, parsed_value, previous_state)

	var serialized_value = _serialize_theme_override_value(parsed_value, override_type)
	var response := {
		"node_path": node_path,
		"override_type": override_type,
		"override_name": override_name,
		"value": serialized_value,
		"transaction_id": transaction.transaction_id,
	}

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Applied theme override to control", "_create_theme_override", {
			"node_path": node_path,
			"override_type": override_type,
			"override_name": override_name,
			"value": serialized_value,
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_theme",
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit theme override", command_id)

		response["status"] = "committed"
		return _send_success(client_id, response, command_id)

	response["status"] = "pending"
	_send_success(client_id, response, command_id)

func _wire_signal_handler(client_id: int, params: Dictionary, command_id: String) -> void:
	var source_path: String = params.get("source_path", "")
	var signal_name: String = params.get("signal_name", "")
	var target_path: String = params.get("target_path", "")
	var method_name: String = params.get("method_name", "")
	var transaction_id: String = params.get("transaction_id", "")
	var script_path: String = params.get("script_path", "")
	var create_script: bool = params.get("create_script", false)
	var binds_param = params.get("binds", [])
	var arguments_param = params.get("arguments", [])
	var deferred: bool = params.get("deferred", false)
	var one_shot: bool = params.get("one_shot", false)
	var reference_counted: bool = params.get("reference_counted", false)

	if source_path.is_empty():
		return _send_error(client_id, "Source path cannot be empty", command_id)

	if signal_name.is_empty():
		return _send_error(client_id, "Signal name cannot be empty", command_id)

	if target_path.is_empty():
		return _send_error(client_id, "Target path cannot be empty", command_id)

	if method_name.is_empty():
		return _send_error(client_id, "Method name cannot be empty", command_id)

	var source_node = _get_editor_node(source_path)
	if not source_node:
		return _send_error(client_id, "Source node not found: %s" % source_path, command_id)

	if not source_node.has_signal(signal_name):
		return _send_error(client_id, "Signal %s is not declared on %s" % [signal_name, source_path], command_id)

	var target_node = _get_editor_node(target_path)
	if not target_node:
		return _send_error(client_id, "Target node not found: %s" % target_path, command_id)

	var binds: Array = []
	if binds_param is Array:
		binds = binds_param.duplicate(true)

	var argument_names := _normalize_argument_names(arguments_param)

	var flags := 0
	if deferred:
		flags |= Object.CONNECT_DEFERRED
	if one_shot:
		flags |= Object.CONNECT_ONE_SHOT
	if reference_counted:
		flags |= Object.CONNECT_REFERENCE_COUNTED

	var script_resource_path := script_path
	var stub_created := false
	var created_script := false
	var previous_script = target_node.get_script()

	if script_resource_path.is_empty() and previous_script and previous_script.resource_path != "":
		script_resource_path = previous_script.resource_path

	if script_resource_path.is_empty():
		if not create_script:
			return _send_error(client_id, "Target node has no script. Provide script_path or enable create_script", command_id)
		return _send_error(client_id, "Script path must be provided when create_script is true", command_id)

	if not script_resource_path.begins_with("res://"):
		return _send_error(client_id, "Script path must be within the project (res://)", command_id)

	if create_script and not FileAccess.file_exists(script_resource_path):
		var extends_type := target_node.get_class()
		if not ScriptUtils.create_script_file(script_resource_path, "", extends_type):
			return _send_error(client_id, "Failed to create script file at %s" % script_resource_path, command_id)
		created_script = true

	var script_resource: Script = null
	if FileAccess.file_exists(script_resource_path):
		script_resource = ResourceLoader.load(script_resource_path, "", ResourceLoader.CACHE_MODE_REPLACE)

	if not script_resource:
		return _send_error(client_id, "Failed to load script resource at %s" % script_resource_path, command_id)

	var stub_result := _ensure_signal_stub(script_resource_path, method_name, argument_names)
	if not stub_result.get("ok", false):
		return _send_error(client_id, stub_result.get("error", "Failed to ensure signal stub"), command_id)

	stub_created = stub_result.get("stub_created", false) or created_script

	if stub_created:
		script_resource = ResourceLoader.load(script_resource_path, "", ResourceLoader.CACHE_MODE_REPLACE)
		if not script_resource:
			return _send_error(client_id, "Failed to reload script resource after stub creation", command_id)

	var callable := Callable(target_node, method_name)
	if source_node.is_connected(signal_name, callable):
		_log("Signal already connected", "_wire_signal_handler", {
			"source_path": source_path,
			"signal_name": signal_name,
			"target_path": target_path,
			"method_name": method_name,
			"system_section": "ui_signals",
			"line_num": 0,
		})
		return _send_success(client_id, {
			"source_path": source_path,
			"signal_name": signal_name,
			"target_path": target_path,
			"method_name": method_name,
			"script_path": script_resource_path,
			"stub_created": stub_created,
			"status": "already_connected"
		}, command_id)

	var transaction_metadata := {
		"command": "wire_signal_handler",
		"source_path": source_path,
		"signal_name": signal_name,
		"target_path": target_path,
		"method_name": method_name,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Wire Signal Handler", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Wire Signal Handler", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for signal wiring", command_id)

	if previous_script != script_resource:
		transaction.add_do_property(target_node, "script", script_resource)
		transaction.add_undo_property(target_node, "script", previous_script)

	transaction.add_do_method(source_node, "connect", [signal_name, callable, binds, flags])
	transaction.add_undo_method(source_node, "disconnect", [signal_name, callable])

	var response := {
		"source_path": source_path,
		"signal_name": signal_name,
		"target_path": target_path,
		"method_name": method_name,
		"script_path": script_resource_path,
		"stub_created": stub_created,
		"transaction_id": transaction.transaction_id,
	}

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Connected signal handler", "_wire_signal_handler", {
			"source_path": source_path,
			"signal_name": signal_name,
			"target_path": target_path,
			"method_name": method_name,
			"flags": flags,
			"binds": binds,
			"stub_created": stub_created,
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_signals",
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit signal wiring", command_id)

		response["status"] = "committed"
		return _send_success(client_id, response, command_id)

	response["status"] = "pending"
	_send_success(client_id, response, command_id)


func _layout_ui_grid(client_id: int, params: Dictionary, command_id: String) -> void:
	var container_path: String = params.get("container_path", "")
	var transaction_id: String = params.get("transaction_id", "")
	var columns: int = params.get("columns", 2)
	var horizontal_gap := float(params.get("horizontal_gap", 16.0))
	var vertical_gap := float(params.get("vertical_gap", 16.0))
	var size_flags_param = params.get("size_flags", {})
	var uniform_size := _parse_vector2_param(params.get("cell_size"))

	if container_path.is_empty():
		return _send_error(client_id, "Container path cannot be empty", command_id)

	if columns <= 0:
		return _send_error(client_id, "Columns must be greater than zero", command_id)

	var node = _get_editor_node(container_path)
	if not node:
		return _send_error(client_id, "Container node not found: %s" % container_path, command_id)

	if not (node is Control):
		return _send_error(client_id, "Container must inherit from Control to layout children", command_id)

	var container: Control = node
	var controls: Array = []
	for child in container.get_children():
		if child is Control:
			controls.append(child)

	if controls.is_empty():
		_log("No Control children found for layout", "_layout_ui_grid", {
			"container_path": container_path,
			"system_section": "ui_layout",
			"line_num": 0,
		})
		return _send_success(client_id, {
			"container_path": container_path,
			"updated_nodes": [],
			"status": "no_controls"
		}, command_id)

	var pending_child_changes: Array = []
	var layout_summary: Array = []

	for idx in range(controls.size()):
		var child: Control = controls[idx]
		var column := idx % columns
		var row := idx / columns
		var minimum := child.get_combined_minimum_size()
		var current_size := child.size
		var target_width := (uniform_size.x if uniform_size.x > 0.0 else max(current_size.x, minimum.x))
		var target_height := (uniform_size.y if uniform_size.y > 0.0 else max(current_size.y, minimum.y))
		var position := Vector2(column * (target_width + horizontal_gap), row * (target_height + vertical_gap))

		var child_changes: Array = []
		child_changes.append_array(_capture_property_change(child, "anchor_left", 0.0))
		child_changes.append_array(_capture_property_change(child, "anchor_right", 0.0))
		child_changes.append_array(_capture_property_change(child, "anchor_top", 0.0))
		child_changes.append_array(_capture_property_change(child, "anchor_bottom", 0.0))
		child_changes.append_array(_capture_property_change(child, "offset_left", position.x))
		child_changes.append_array(_capture_property_change(child, "offset_top", position.y))
		child_changes.append_array(_capture_property_change(child, "offset_right", position.x + target_width))
		child_changes.append_array(_capture_property_change(child, "offset_bottom", position.y + target_height))

		if typeof(size_flags_param) == TYPE_DICTIONARY:
			if size_flags_param.has("horizontal"):
				child_changes.append_array(_capture_property_change(child, "size_flags_horizontal", int(size_flags_param["horizontal"])) )
			if size_flags_param.has("vertical"):
				child_changes.append_array(_capture_property_change(child, "size_flags_vertical", int(size_flags_param["vertical"])) )

		if not child_changes.is_empty():
			pending_child_changes.append({
				"node": child,
				"changes": child_changes,
			})

		layout_summary.append({
			"node_path": _stringify_node_path(child.get_path()),
			"column": column,
			"row": row,
			"position": position,
			"size": Vector2(target_width, target_height),
		})

	var container_changes: Array = []
	if container is GridContainer:
		container_changes.append_array(_capture_property_change(container, "columns", columns))
		container_changes.append_array(_capture_property_change(container, "h_separation", int(round(horizontal_gap))))
		container_changes.append_array(_capture_property_change(container, "v_separation", int(round(vertical_gap))))

	if pending_child_changes.is_empty() and container_changes.is_empty():
		return _send_success(client_id, {
			"container_path": container_path,
			"updated_nodes": layout_summary,
			"status": "no_change"
		}, command_id)

	var transaction_metadata := {
		"command": "layout_ui_grid",
		"container_path": container_path,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Layout UI Grid", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Layout UI Grid", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for UI layout", command_id)

	for entry in pending_child_changes:
		var child = entry["node"]
		for change in entry["changes"]:
			transaction.add_do_property(child, change.property, change.value)
			transaction.add_undo_property(child, change.property, change.previous)

	for change in container_changes:
		transaction.add_do_property(container, change.property, change.value)
		transaction.add_undo_property(container, change.property, change.previous)

	var response := {
		"container_path": container_path,
		"updated_nodes": layout_summary,
		"transaction_id": transaction.transaction_id,
	}

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Applied grid layout to controls", "_layout_ui_grid", {
			"container_path": container_path,
			"node_count": layout_summary.size(),
			"transaction_id": transaction.transaction_id,
			"system_section": "ui_layout",
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit UI layout", command_id)

		response["status"] = "committed"
		return _send_success(client_id, response, command_id)

	response["status"] = "pending"
	_send_success(client_id, response, command_id)


func _validate_accessibility(client_id: int, params: Dictionary, command_id: String) -> void:
	var root_path: String = params.get("root_path", "/root")
	var include_hidden: bool = params.get("include_hidden", false)
	var max_depth: int = params.get("max_depth", 0)

	var root = _get_editor_node(root_path)
	if not root:
		return _send_error(client_id, "Root node not found: %s" % root_path, command_id)

	var collected: Array = []
	_collect_control_nodes(root, 0, max_depth, include_hidden, collected)

	var issues: Array = []
	for entry in collected:
		var control: Control = entry["node"]
		var node_issues := _analyze_accessibility(control)
		if not node_issues.is_empty():
			issues.append({
				"node_path": entry["path"],
				"node_name": control.name,
				"type": control.get_class(),
				"issues": node_issues,
			})

	var response := {
		"root_path": root_path,
		"issue_count": issues.size(),
		"issues": issues,
		"scanned_count": collected.size(),
	}

	_log("Completed accessibility scan", "_validate_accessibility", {
		"root_path": root_path,
		"issue_count": issues.size(),
		"scanned_count": collected.size(),
		"system_section": "ui_accessibility",
		"line_num": 0,
	})

	_send_success(client_id, response, command_id)


func _register_theme_override_transaction(transaction, control: Control, override_type: String, override_name: String, value, previous_state: Dictionary) -> void:
	var method_name := _theme_override_add_method(override_type)
	var removal_method := _theme_override_remove_method(override_type)

	transaction.add_do_method(control, method_name, [override_name, value])

	if previous_state.get("had_override", false):
		transaction.add_undo_method(control, method_name, [override_name, previous_state.get("value")])
	else:
		transaction.add_undo_method(control, removal_method, [override_name])


func _parse_theme_override_value(override_type: String, value, resource_path: String) -> Dictionary:
	match override_type:
		"color":
			var color = _coerce_color(value)
			if color == null:
				return {"ok": false, "error": "Color overrides require a valid color value"}
			return {"ok": true, "value": color}
		"constant":
			if value == null:
				return {"ok": false, "error": "Constant overrides require a numeric value"}
			return {"ok": true, "value": int(round(float(value)))}
		"font_size":
			if value == null:
				return {"ok": false, "error": "Font size overrides require an integer value"}
			return {"ok": true, "value": int(round(float(value)))}
		"font":
			var font_resource = _load_theme_resource(resource_path, value, "Font")
			if font_resource == null:
				return {"ok": false, "error": "Font overrides require a valid Font resource path"}
			return {"ok": true, "value": font_resource}
		"stylebox":
			var stylebox_resource = _load_theme_resource(resource_path, value, "StyleBox")
			if stylebox_resource == null:
				return {"ok": false, "error": "StyleBox overrides require a valid StyleBox resource path"}
			return {"ok": true, "value": stylebox_resource}
		"icon":
			var texture_resource = _load_theme_resource(resource_path, value, "Texture2D")
			if texture_resource == null:
				return {"ok": false, "error": "Icon overrides require a valid Texture2D resource path"}
			return {"ok": true, "value": texture_resource}
		_:
			return {"ok": false, "error": "Unsupported override_type: %s" % override_type}


func _coerce_color(value):
	match typeof(value):
		TYPE_NIL:
			return null
		TYPE_COLOR:
			return value
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			return Color(dict.get("r", 0.0), dict.get("g", 0.0), dict.get("b", 0.0), dict.get("a", 1.0))
		TYPE_STRING:
			var str_value: String = value
			if str_value.is_empty():
				return null
			return Color(str_value)
		TYPE_ARRAY:
			var arr: Array = value
			if arr.size() >= 3:
				var r := float(arr[0])
				var g := float(arr[1])
				var b := float(arr[2])
				var a := (float(arr[3]) if arr.size() > 3 else 1.0)
				return Color(r, g, b, a)
		_:
			return null


func _load_theme_resource(resource_path: String, fallback, expected_class: String) -> Resource:
	var path_to_load := resource_path
	if path_to_load.is_empty() and typeof(fallback) == TYPE_STRING:
		path_to_load = String(fallback)

	if path_to_load.is_empty():
		return null

	var resource = ResourceLoader.load(path_to_load, "", ResourceLoader.CACHE_MODE_REPLACE)
	if resource and resource.is_class(expected_class):
		return resource

	return null


func _get_theme_override_state(control: Control, override_type: String, override_name: String) -> Dictionary:
	match override_type:
		"color":
			if control.has_theme_color_override(override_name):
				return {"had_override": true, "value": control.get_theme_color(override_name)}
			return {"had_override": false}
		"constant":
			if control.has_theme_constant_override(override_name):
				return {"had_override": true, "value": control.get_theme_constant(override_name)}
			return {"had_override": false}
		"font":
			if control.has_theme_font_override(override_name):
				return {"had_override": true, "value": control.get_theme_font(override_name)}
			return {"had_override": false}
		"font_size":
			if control.has_theme_font_size_override(override_name):
				return {"had_override": true, "value": control.get_theme_font_size(override_name)}
			return {"had_override": false}
		"stylebox":
			if control.has_theme_stylebox_override(override_name):
				return {"had_override": true, "value": control.get_theme_stylebox(override_name)}
			return {"had_override": false}
		"icon":
			if control.has_theme_icon_override(override_name):
				return {"had_override": true, "value": control.get_theme_icon(override_name)}
			return {"had_override": false}
		_:
			return {"had_override": false}


func _theme_override_values_equal(a, b) -> bool:
	if typeof(a) != typeof(b):
		return false

	if a is Resource and b is Resource:
		return a.resource_path == b.resource_path

	if typeof(a) == TYPE_COLOR:
		return a == b

	return a == b


func _theme_override_add_method(override_type: String) -> String:
	match override_type:
		"color":
			return "add_theme_color_override"
		"constant":
			return "add_theme_constant_override"
		"font":
			return "add_theme_font_override"
		"font_size":
			return "add_theme_font_size_override"
		"stylebox":
			return "add_theme_stylebox_override"
		"icon":
			return "add_theme_icon_override"
		_:
			return ""


func _theme_override_remove_method(override_type: String) -> String:
	match override_type:
		"color":
			return "remove_theme_color_override"
		"constant":
			return "remove_theme_constant_override"
		"font":
			return "remove_theme_font_override"
		"font_size":
			return "remove_theme_font_size_override"
		"stylebox":
			return "remove_theme_stylebox_override"
		"icon":
			return "remove_theme_icon_override"
		_:
			return ""


func _serialize_theme_override_value(value, override_type: String):
	match override_type:
		"color":
				return (value.to_html(true) if value is Color else value)
		"font":
			if value is Resource:
				return value.resource_path
			return value
		"stylebox":
			if value is Resource:
				return value.resource_path
			return value
		"icon":
			if value is Resource:
				return value.resource_path
			return value
		_:
			return value


func _ensure_signal_stub(script_path: String, method_name: String, argument_names: Array) -> Dictionary:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "Failed to open script for reading: %s" % script_path}

	var content := file.get_as_text()
	file = null

	var regex := RegEx.new()
	regex.compile("func\\s+%s\\s*\\(" % method_name)
	var matches = regex.search(content)
	if matches:
		return {"ok": true, "stub_created": false}

	var stub_arguments := ", ".join(argument_names)
	var stub_line := """
func %s(%s):
	pass
""" % [method_name, stub_arguments]
	var updated_content := content
	if not updated_content.ends_with("\n"):
		updated_content += "\n"

	updated_content += stub_line

	file = FileAccess.open(script_path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "error": "Failed to open script for writing: %s" % script_path}

	file.store_string(updated_content)
	file = null

	return {"ok": true, "stub_created": true}


func _normalize_argument_names(raw_arguments) -> Array:
	var result: Array = []
	if raw_arguments is Array:
		for idx in range(raw_arguments.size()):
			var candidate = raw_arguments[idx]
			if typeof(candidate) == TYPE_STRING and not String(candidate).strip_edges().is_empty():
				result.append(String(candidate).strip_edges())
			else:
				result.append("arg_%d" % idx)
	else:
		result = []

	return result


func _parse_vector2_param(value) -> Vector2:
	if value is Vector2:
		return value
	if typeof(value) == TYPE_DICTIONARY:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	if typeof(value) == TYPE_ARRAY and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return Vector2.ZERO


func _parse_vector3_param(value) -> Vector3:
	if value is Vector3:
		return value
	if typeof(value) == TYPE_DICTIONARY:
		return Vector3(float(value.get("x", 0.0)), float(value.get("y", 0.0)), float(value.get("z", 0.0)))
	if typeof(value) == TYPE_ARRAY and value.size() >= 3:
		return Vector3(float(value[0]), float(value[1]), float(value[2]))
	return Vector3.ZERO


func _parse_vector2_array_param(value) -> Dictionary:
	if value is PackedVector2Array:
		return {
			"ok": true,
			"value": value,
		}
	if typeof(value) != TYPE_ARRAY:
		return {"ok": false, "error": "Expected an array of Vector2-compatible entries"}
	var points: PackedVector2Array = PackedVector2Array()
	var entries: Array = value
	for idx in range(entries.size()):
		var entry = entries[idx]
		if not (entry is Vector2) and typeof(entry) != TYPE_DICTIONARY and typeof(entry) != TYPE_ARRAY:
			return {"ok": false, "error": "vertices[%d] is not Vector2-compatible" % idx}
		points.append(_parse_vector2_param(entry))
	return {
		"ok": true,
		"value": points,
	}


func _parse_vector3_array_param(value) -> Dictionary:
	if value is PackedVector3Array:
		return {
			"ok": true,
			"value": value,
		}
	if typeof(value) != TYPE_ARRAY:
		return {"ok": false, "error": "Expected an array of Vector3-compatible entries"}
	var points: PackedVector3Array = PackedVector3Array()
	var entries: Array = value
	for idx in range(entries.size()):
		var entry = entries[idx]
		if not (entry is Vector3) and typeof(entry) != TYPE_DICTIONARY and typeof(entry) != TYPE_ARRAY:
			return {"ok": false, "error": "vertices[%d] is not Vector3-compatible" % idx}
		points.append(_parse_vector3_param(entry))
	return {
		"ok": true,
		"value": points,
	}


func _parse_vector2i_with_default(value, default_value: Vector2i = Vector2i.ZERO) -> Dictionary:
	if value == null:
		return {"ok": true, "value": default_value}
	if value is Vector2i:
		return {"ok": true, "value": value}
	if value is Vector2:
		return {"ok": true, "value": Vector2i(int(round(value.x)), int(round(value.y)))}
	if typeof(value) == TYPE_DICTIONARY:
		var dict_value: Dictionary = value
		if not dict_value.has("x") or not dict_value.has("y"):
			return {"ok": false, "error": "Dictionary must include x and y"}
		return {"ok": true, "value": Vector2i(int(dict_value["x"]), int(dict_value["y"]))}
	if typeof(value) == TYPE_ARRAY:
		var arr: Array = value
		if arr.size() < 2:
			return {"ok": false, "error": "Array must contain x and y"}
		return {"ok": true, "value": Vector2i(int(arr[0]), int(arr[1]))}
	return {"ok": false, "error": "Expected Vector2i-compatible value"}


func _parse_vector3i_with_default(value, default_value: Vector3i = Vector3i.ZERO) -> Dictionary:
	if value == null:
		return {"ok": true, "value": default_value}
	if value is Vector3i:
		return {"ok": true, "value": value}
	if value is Vector3:
		return {"ok": true, "value": Vector3i(int(round(value.x)), int(round(value.y)), int(round(value.z)))}
	if typeof(value) == TYPE_DICTIONARY:
		var dict_value: Dictionary = value
		if not dict_value.has("x") or not dict_value.has("y") or not dict_value.has("z"):
			return {"ok": false, "error": "Dictionary must include x, y, and z"}
		return {"ok": true, "value": Vector3i(int(dict_value["x"]), int(dict_value["y"]), int(dict_value["z"]))}
	if typeof(value) == TYPE_ARRAY:
		var arr: Array = value
		if arr.size() < 3:
			return {"ok": false, "error": "Array must contain x, y, and z"}
		return {"ok": true, "value": Vector3i(int(arr[0]), int(arr[1]), int(arr[2]))}
	return {"ok": false, "error": "Expected Vector3i-compatible value"}


func _parse_rect2_with_default(value, default_value: Rect2 = Rect2()) -> Dictionary:
	if value == null:
		return {"ok": true, "value": default_value}
	if value is Rect2:
		return {"ok": true, "value": value}
	if typeof(value) == TYPE_DICTIONARY:
		var dict_value: Dictionary = value
		if dict_value.has("position") or dict_value.has("size"):
			var position = _parse_vector2_param(dict_value.get("position", Vector2.ZERO))
			var size = _parse_vector2_param(dict_value.get("size", Vector2.ZERO))
			return {"ok": true, "value": Rect2(position, size)}
		if dict_value.has("x") and dict_value.has("y") and dict_value.has("width") and dict_value.has("height"):
			return {
				"ok": true,
				"value": Rect2(
					float(dict_value.get("x", 0.0)),
					float(dict_value.get("y", 0.0)),
					float(dict_value.get("width", 0.0)),
					float(dict_value.get("height", 0.0))
				),
			}
		return {"ok": false, "error": "Dictionary must include position/size or x/y/width/height"}
	if typeof(value) == TYPE_ARRAY:
		var arr: Array = value
		if arr.size() < 4:
			return {"ok": false, "error": "Array must contain x, y, width, height"}
		return {"ok": true, "value": Rect2(float(arr[0]), float(arr[1]), float(arr[2]), float(arr[3]))}
	return {"ok": false, "error": "Expected Rect2-compatible value"}


func _parse_tilemap_coords(entry: Dictionary) -> Dictionary:
	if entry.has("position"):
		var position_result := _parse_vector2i_with_default(entry.get("position"))
		if not position_result.get("ok", false):
			return position_result
		return {"ok": true, "coords": position_result.get("value")}
	if entry.has("coords"):
		var coords_result := _parse_vector2i_with_default(entry.get("coords"))
		if not coords_result.get("ok", false):
			return coords_result
		return {"ok": true, "coords": coords_result.get("value")}
	if entry.has("x") and entry.has("y"):
		return {"ok": true, "coords": Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))}
	return {"ok": false, "error": "Cell entry requires position, coords, or x/y values"}


func _is_supported_tilemap_node(node: Node) -> bool:
	return node is TileMapLayer or node is TileMap


func _make_tilemap_cell_data(source_id: int, atlas_coords: Vector2i, alternative_tile: int) -> Dictionary:
	return {
		"source_id": source_id,
		"atlas_coords": atlas_coords,
		"alternative_tile": alternative_tile,
	}


func _get_tilemap_cell_data(node: Node, layer: int, coords: Vector2i) -> Dictionary:
	if node is TileMapLayer:
		var tilemap_layer: TileMapLayer = node
		return {
			"source_id": tilemap_layer.get_cell_source_id(coords),
			"atlas_coords": tilemap_layer.get_cell_atlas_coords(coords),
			"alternative_tile": tilemap_layer.get_cell_alternative_tile(coords),
		}

	if node is TileMap:
		var tilemap: TileMap = node
		return {
			"source_id": tilemap.get_cell_source_id(layer, coords),
			"atlas_coords": tilemap.get_cell_atlas_coords(layer, coords),
			"alternative_tile": tilemap.get_cell_alternative_tile(layer, coords),
		}

	return _make_tilemap_cell_data(-1, Vector2i(-1, -1), -1)


func _tilemap_cell_is_empty(cell_data: Dictionary) -> bool:
	return int(cell_data.get("source_id", -1)) < 0


func _tilemap_cell_data_equal(a: Dictionary, b: Dictionary) -> bool:
	var a_source: int = int(a.get("source_id", -1))
	var b_source: int = int(b.get("source_id", -1))
	if a_source != b_source:
		return false

	if a_source < 0:
		return true

	var a_atlas_result := _parse_vector2i_with_default(a.get("atlas_coords", Vector2i(-1, -1)))
	var b_atlas_result := _parse_vector2i_with_default(b.get("atlas_coords", Vector2i(-1, -1)))
	if not a_atlas_result.get("ok", false) or not b_atlas_result.get("ok", false):
		return false
	if a_atlas_result.get("value") != b_atlas_result.get("value"):
		return false

	return int(a.get("alternative_tile", 0)) == int(b.get("alternative_tile", 0))


func _vector2i_to_dict(value: Vector2i) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _vector3i_to_dict(value: Vector3i) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
		"z": value.z,
	}


func _vector2_to_dict(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _vector3_to_dict(value: Vector3) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
		"z": value.z,
	}


func _serialize_tilemap_cell_data(cell_data: Dictionary) -> Dictionary:
	var atlas_result := _parse_vector2i_with_default(cell_data.get("atlas_coords", Vector2i(-1, -1)))
	var atlas_coords: Vector2i = atlas_result.get("value", Vector2i(-1, -1))
	return {
		"source_id": int(cell_data.get("source_id", -1)),
		"atlas_coords": _vector2i_to_dict(atlas_coords),
		"alternative_tile": int(cell_data.get("alternative_tile", 0)),
	}


func _apply_tilemap_set_cell(node: Node, layer: int, coords: Vector2i, cell_data: Dictionary) -> void:
	var source_id: int = int(cell_data.get("source_id", -1))
	var atlas_result := _parse_vector2i_with_default(cell_data.get("atlas_coords", Vector2i(-1, -1)))
	var atlas_coords: Vector2i = atlas_result.get("value", Vector2i(-1, -1))
	var alternative_tile: int = int(cell_data.get("alternative_tile", 0))

	if node is TileMapLayer:
		var tilemap_layer: TileMapLayer = node
		tilemap_layer.set_cell(coords, source_id, atlas_coords, alternative_tile)
	elif node is TileMap:
		var tilemap: TileMap = node
		tilemap.set_cell(layer, coords, source_id, atlas_coords, alternative_tile)

	_refresh_tilemap_node(node)


func _apply_tilemap_erase_cell(node: Node, layer: int, coords: Vector2i) -> void:
	if node is TileMapLayer:
		var tilemap_layer: TileMapLayer = node
		tilemap_layer.erase_cell(coords)
	elif node is TileMap:
		var tilemap: TileMap = node
		tilemap.erase_cell(layer, coords)

	_refresh_tilemap_node(node)


func _apply_gridmap_set_cell_item(node: GridMap, coords: Vector3i, item_id: int, orientation: int) -> void:
	if node == null:
		return
	node.set_cell_item(coords, item_id, orientation)


func _apply_gridmap_clear_cell(node: GridMap, coords: Vector3i) -> void:
	if node == null:
		return
	node.set_cell_item(coords, -1)


func _refresh_tilemap_node(node: Node) -> void:
	if node and node.has_method("notify_runtime_tile_data_update"):
		node.call("notify_runtime_tile_data_update")
	if node and node.has_method("update_internals"):
		node.call("update_internals")


func _capture_property_change(node: Object, property_name: String, desired_value) -> Array:
	if not property_name in node:
		return []

	var current_value = node.get(property_name)
	if current_value == desired_value:
		return []

	return [{
		"target": node,
		"property": property_name,
		"previous": current_value,
		"value": desired_value,
	}]


func _capture_meta_change(node: Object, meta_key: String, desired_value) -> Array:
	var has_previous: bool = node.has_meta(meta_key)
	var current_value = node.get_meta(meta_key) if has_previous else null
	if has_previous and current_value == desired_value:
		return []

	return [{
		"key": meta_key,
		"previous_exists": has_previous,
		"previous": current_value,
		"value": desired_value,
	}]


func _build_signal_flags_from_params(params: Dictionary) -> int:
	var signal_flags := 0
	if bool(params.get("signal_deferred", false)):
		signal_flags |= Object.CONNECT_DEFERRED
	if bool(params.get("signal_one_shot", false)):
		signal_flags |= Object.CONNECT_ONE_SHOT
	if bool(params.get("signal_reference_counted", false)):
		signal_flags |= Object.CONNECT_REFERENCE_COUNTED
	return signal_flags


func _capture_signal_connection_change(
	emitter: Object, signal_name: String, target: Object, method_name: String, flags: int = 0
) -> Array:
	if emitter == null or target == null:
		return []
	if signal_name.strip_edges().is_empty() or method_name.strip_edges().is_empty():
		return []
	if not emitter.has_signal(signal_name):
		return []

	var callable := Callable(target, method_name)
	if emitter.is_connected(signal_name, callable):
		return []

	return [{
		"emitter": emitter,
		"signal_name": signal_name,
		"target": target,
		"method_name": method_name,
		"flags": flags,
	}]


func _connect_signal_safe(
	emitter: Object, signal_name: String, target: Object, method_name: String, flags: int = 0
) -> void:
	if emitter == null or target == null:
		return
	if signal_name.strip_edges().is_empty() or method_name.strip_edges().is_empty():
		return
	if not emitter.has_signal(signal_name):
		return

	var callable := Callable(target, method_name)
	if emitter.is_connected(signal_name, callable):
		return

	emitter.connect(signal_name, callable, flags)


func _connect_signal_change_safe(change: Dictionary) -> void:
	if change.is_empty():
		return
	_connect_signal_safe(
		change.get("emitter"),
		String(change.get("signal_name", "")).strip_edges(),
		change.get("target"),
		String(change.get("method_name", "")).strip_edges(),
		int(change.get("flags", 0))
	)


func _disconnect_signal_safe(emitter: Object, signal_name: String, target: Object, method_name: String) -> void:
	if emitter == null or target == null:
		return
	if signal_name.strip_edges().is_empty() or method_name.strip_edges().is_empty():
		return
	if not emitter.has_signal(signal_name):
		return

	var callable := Callable(target, method_name)
	if not emitter.is_connected(signal_name, callable):
		return

	emitter.disconnect(signal_name, callable)


func _disconnect_signal_change_safe(change: Dictionary) -> void:
	if change.is_empty():
		return
	_disconnect_signal_safe(
		change.get("emitter"),
		String(change.get("signal_name", "")).strip_edges(),
		change.get("target"),
		String(change.get("method_name", "")).strip_edges()
	)


func _resolve_sprite_node_for_movement(body: Node, sprite_path: String) -> Node:
	if not sprite_path.is_empty():
		var explicit_node = _get_editor_node(sprite_path)
		if explicit_node and (explicit_node is Sprite2D or explicit_node is AnimatedSprite2D):
			return explicit_node
		return null

	for child in body.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			return child
	return null


func _configure_control_full_rect(control: Control) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 1.0
	control.anchor_bottom = 1.0
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0


func _has_child_with_name(parent: Node, candidate_name: String, exclude_node: Node = null) -> bool:
	for child in parent.get_children():
		if child == exclude_node:
			continue
		if String(child.name) == candidate_name:
			return true
	return false


func _resolve_unique_child_name(parent: Node, desired_name: String, exclude_node: Node = null) -> String:
	var base_name := desired_name.strip_edges()
	if base_name.is_empty():
		base_name = "Node"

	if not _has_child_with_name(parent, base_name, exclude_node):
		return base_name

	var suffix := 2
	var candidate := "%s%d" % [base_name, suffix]
	while _has_child_with_name(parent, candidate, exclude_node):
		suffix += 1
		candidate = "%s%d" % [base_name, suffix]
	return candidate


func _collect_child_name_set(parent: Node) -> Dictionary:
	var names: Dictionary = {}
	for child in parent.get_children():
		names[String(child.name)] = true
	return names


func _resolve_unique_name_in_set(desired_name: String, reserved_names: Dictionary) -> String:
	var base_name := desired_name.strip_edges()
	if base_name.is_empty():
		base_name = "Node"

	if not reserved_names.has(base_name):
		reserved_names[base_name] = true
		return base_name

	var suffix := 2
	var candidate := "%s%d" % [base_name, suffix]
	while reserved_names.has(candidate):
		suffix += 1
		candidate = "%s%d" % [base_name, suffix]
	reserved_names[candidate] = true
	return candidate


func _join_mcp_path(parent_path: String, child_name: String) -> String:
	if parent_path == "/root":
		return "/root/%s" % child_name
	return "%s/%s" % [parent_path, child_name]


func _collect_node_subtree(node: Node, accumulator: Array, include_root: bool = true) -> void:
	if include_root:
		accumulator.append(node)
	for child in node.get_children():
		if child is Node:
			_collect_node_subtree(child, accumulator, true)


func _query_nodes_recursive(node: Node, filters: Dictionary, results: Array, include_internal: bool, max_results: int) -> void:
	if results.size() >= max_results:
		return

	if _node_matches_query(node, filters):
		results.append({
			"name": String(node.name),
			"type": node.get_class(),
			"path": _to_mcp_path(node),
			"groups": node.get_groups(),
		})
		if results.size() >= max_results:
			return

	for child in node.get_children(include_internal):
		if results.size() >= max_results:
			return
		if child is Node:
			_query_nodes_recursive(child, filters, results, include_internal, max_results)


func _node_matches_query(node: Node, filters: Dictionary) -> bool:
	var name_contains: String = filters.get("name_contains", "")
	var node_type: String = filters.get("node_type", "")
	var group_name: String = filters.get("group_name", "")

	if not name_contains.is_empty():
		var candidate_name := String(node.name).to_lower()
		if not candidate_name.contains(name_contains):
			return false

	if not node_type.is_empty() and not node.is_class(node_type):
		return false

	if not group_name.is_empty() and not node.is_in_group(group_name):
		return false

	return true


func _stringify_node_path(path: NodePath) -> String:
	if typeof(path) == TYPE_STRING:
		return String(path)
	return str(path)


func _to_mcp_path(node: Node) -> String:
	if node == null:
		return "/root"
	if not node.is_inside_tree():
		return "<detached:%s>" % String(node.name)

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if plugin == null:
		return _stringify_node_path(node.get_path())

	var editor_interface = plugin.get_editor_interface()
	if editor_interface == null:
		return _stringify_node_path(node.get_path())

	var edited_scene_root = editor_interface.get_edited_scene_root()
	if edited_scene_root == null:
		return _stringify_node_path(node.get_path())

	if node == edited_scene_root:
		return "/root"

	if edited_scene_root.is_ancestor_of(node):
		return "/root/" + String(edited_scene_root.get_path_to(node))

	return _stringify_node_path(node.get_path())


func _describe_object_path(target_object: Object) -> String:
	if target_object == null:
		return "<null>"
	if target_object is Node:
		return _to_mcp_path(target_object)
	return target_object.get_class()


func _collect_control_nodes(node: Node, depth: int, max_depth: int, include_hidden: bool, accumulator: Array) -> void:
	if node is Control:
		var control: Control = node
		if include_hidden or control.is_visible_in_tree():
			accumulator.append({
				"node": control,
				"path": _stringify_node_path(control.get_path()),
			})

	if max_depth > 0 and depth >= max_depth:
		return

	for child in node.get_children():
		if child is Node:
			_collect_control_nodes(child, depth + 1, max_depth, include_hidden, accumulator)


func _analyze_accessibility(control: Control) -> Array:
	var issues: Array = []
	var accessible_name := ""
	var accessible_description := ""
	var tooltip_text := ""
	var control_text := ""

	if "accessible_name" in control:
		accessible_name = String(control.get("accessible_name"))
	if "accessible_description" in control:
		accessible_description = String(control.get("accessible_description"))
	if "tooltip_text" in control:
		tooltip_text = String(control.get("tooltip_text"))
	if "text" in control:
		control_text = String(control.get("text"))

	var is_interactive := _is_interactive_control(control)

	if is_interactive and control.focus_mode == Control.FOCUS_NONE:
		issues.append("Interactive control has focus disabled")

	var has_descriptor := not accessible_name.strip_edges().is_empty() or not accessible_description.strip_edges().is_empty() or not tooltip_text.strip_edges().is_empty() or not control_text.strip_edges().is_empty()
	if is_interactive and not has_descriptor:
		issues.append("Interactive control is missing accessible name, description, tooltip, or text")

	if control is Label and control_text.strip_edges().is_empty() and accessible_description.strip_edges().is_empty():
		issues.append("Label is missing text or accessible description")

	if control is TextureButton and accessible_description.strip_edges().is_empty() and tooltip_text.strip_edges().is_empty():
		issues.append("TextureButton should provide tooltip or accessible description for icon-only buttons")

	return issues


func _is_interactive_control(control: Control) -> bool:
	if control.focus_mode != Control.FOCUS_NONE:
		return true

	return control is BaseButton or control is LineEdit or control is TextEdit or control is ItemList or control is Tree or control is OptionButton or control is SpinBox or control is Slider or control is ScrollBar or control is ColorPicker or control is ColorPickerButton


func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPNodeCommands",
		"function": function_name,
		"system_section": extra.get("system_section", DEFAULT_SYSTEM_SECTION),
		"line_num": extra.get("line_num", 0),
		"error": (message if is_error else ""),
		"db_phase": extra.get("db_phase", "none"),
		"method": extra.get("method", "NONE"),
		"message": message,
	}

	for key in extra.keys():
		if not payload.has(key):
			payload[key] = extra[key]

	print(JSON.stringify(payload))
