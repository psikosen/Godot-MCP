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
		"property": property_name,
		"previous": current_value,
		"value": desired_value,
	}]


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
