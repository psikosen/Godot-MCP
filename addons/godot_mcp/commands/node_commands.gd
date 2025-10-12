@tool
class_name MCPNodeCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager
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

                var updated_path = node.get_path()
                var path_string = updated_path if typeof(updated_path) == TYPE_STRING else updated_path.to_string()
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
                        "line_num": __LINE__,
                }, true)
                return _send_error(client_id, "limits must be a dictionary of Camera2D properties", command_id)

        var smoothing_input = params.get("smoothing", null)
        if smoothing_input != null and typeof(smoothing_input) != TYPE_DICTIONARY:
                _log("smoothing must be provided as a dictionary", "_configure_camera2d_limits", {
                        "node_path": node_path,
                        "system_section": "camera2d",
                        "line_num": __LINE__,
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
                        "line_num": __LINE__,
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
                        "line_num": __LINE__,
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
                        "line_num": __LINE__,
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
                                "line_num": __LINE__,
                        }, true)
                        return _send_error(client_id, "Failed to commit Camera2D limit configuration", command_id)

                var updated_path = node.get_path()
                var path_string = updated_path if typeof(updated_path) == TYPE_STRING else updated_path.to_string()
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
        )

        if transaction_id.is_empty():
                if not transaction.commit():
                        transaction.rollback()
                        return _send_error(client_id, "Failed to commit node creation", command_id)
                _send_success(client_id, {
                        "node_path": parent_path + "/" + node_name,
                        "transaction_id": transaction.transaction_id,
                        "status": "committed"
                }, command_id)
        else:
                _send_success(client_id, {
                        "node_path": parent_path + "/" + node_name,
                        "transaction_id": transaction.transaction_id,
                        "status": "pending"
                }, command_id)

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
        )

        if transaction_id.is_empty():
                if not transaction.commit():
                        transaction.rollback()
                        return _send_error(client_id, "Failed to commit node deletion", command_id)
                _send_success(client_id, {
                        "deleted_node_path": node_path,
                        "transaction_id": transaction.transaction_id,
                        "status": "committed"
                }, command_id)
        else:
                _send_success(client_id, {
                        "deleted_node_path": node_path,
                        "transaction_id": transaction.transaction_id,
                        "status": "pending"
                }, command_id)

func _update_node_property(client_id: int, params: Dictionary, command_id: String) -> void:
        var node_path = params.get("node_path", "")
        var property_name = params.get("property", "")
        var property_value = params.get("value")
        var transaction_id = params.get("transaction_id", "")
	
	# Validation
	if node_path.is_empty():
		return _send_error(client_id, "Node path cannot be empty", command_id)
	
	if property_name.is_empty():
		return _send_error(client_id, "Property name cannot be empty", command_id)
	
	if property_value == null:
		return _send_error(client_id, "Property value cannot be null", command_id)
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	# Get the node using the editor node helper
	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	
	# Check if the property exists
	if not property_name in node:
		return _send_error(client_id, "Property %s does not exist on node %s" % [property_name, node_path], command_id)
	
	# Parse property value for Godot types
	var parsed_value = _parse_property_value(property_value)
	
	# Get current property value for undo
	var old_value = node.get(property_name)
	
        var transaction_metadata := {
                "command": "update_node_property",
                "node_path": node_path,
                "property": property_name,
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

        transaction.add_do_property(node, property_name, parsed_value)
        transaction.add_undo_property(node, property_name, old_value)
        transaction.register_on_commit(func():
                _mark_scene_modified()
        )

        if transaction_id.is_empty():
                if not transaction.commit():
                        transaction.rollback()
                        return _send_error(client_id, "Failed to commit property update", command_id)
                _send_success(client_id, {
                        "node_path": node_path,
                        "property": property_name,
                        "value": property_value,
                        "parsed_value": str(parsed_value),
                        "transaction_id": transaction.transaction_id,
                        "status": "committed"
                }, command_id)
        else:
                _send_success(client_id, {
                        "node_path": node_path,
                        "property": property_name,
                        "value": property_value,
                        "parsed_value": str(parsed_value),
                        "transaction_id": transaction.transaction_id,
                        "status": "pending"
                }, command_id)

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
			"line_num": __LINE__,
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
			"line_num": __LINE__,
		}, true)
		return _send_error(client_id, "Failed to obtain scene transaction for theme override", command_id)

	_register_theme_override_transaction(transaction, control, override_type, override_name, parsed_value, previous_state)

	var serialized_value := _serialize_theme_override_value(parsed_value, override_type)
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

	# Reload resource so Godot picks up file edits before connecting
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
			"line_num": __LINE__,
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
			"line_num": __LINE__,
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
		var target_width := uniform_size.x if uniform_size.x > 0.0 else max(current_size.x, minimum.x)
		var target_height := uniform_size.y if uniform_size.y > 0.0 else max(current_size.y, minimum.y)
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
		"line_num": __LINE__,
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

func _coerce_color(value) -> Color:
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
				var a := float(arr[3]) if arr.size() > 3 else 1.0
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
			return value.to_html(true) if value is Color else value
		"font", "stylebox", "icon":
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
	regex.compile("func\s+%s\s*\(" % method_name)
	var matches = regex.search(content)
	if matches:
		return {"ok": true, "stub_created": false}

	var stub_arguments := argument_names.join(", ")
	var stub_line := "
func %s(%s):
	pass
" % [method_name, stub_arguments]
	var updated_content := content
	if not updated_content.ends_with("
"):
		updated_content += "
"

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

func _stringify_node_path(path: NodePath) -> String:
	if typeof(path) == TYPE_STRING:
		return String(path)
	return path.to_string()

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
			"line_num": __LINE__,
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
			"line_num": __LINE__,
		}, true)
		return _send_error(client_id, "Failed to obtain scene transaction for theme override", command_id)

	_register_theme_override_transaction(transaction, control, override_type, override_name, parsed_value, previous_state)

	var serialized_value := _serialize_theme_override_value(parsed_value, override_type)
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
			"line_num": __LINE__,
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
			"line_num": __LINE__,
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
		var target_width := uniform_size.x if uniform_size.x > 0.0 else max(current_size.x, minimum.x)
		var target_height := uniform_size.y if uniform_size.y > 0.0 else max(current_size.y, minimum.y)
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
		"line_num": __LINE__,
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


func _coerce_color(value) -> Color:
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
				var a := float(arr[3]) if arr.size() > 3 else 1.0
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
			return value.to_html(true) if value is Color else value
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
	regex.compile("func\s+%s\s*\(" % method_name)
	var matches = regex.search(content)
	if matches:
		return {"ok": true, "stub_created": false}

	var stub_arguments := argument_names.join(", " )
	var stub_line := "
func %s(%s):
	pass
" % [method_name, stub_arguments]
	var updated_content := content
	if not updated_content.ends_with("
"):
		updated_content += "
"

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


func _stringify_node_path(path: NodePath) -> String:
	if typeof(path) == TYPE_STRING:
		return String(path)
	return path.to_string()


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
