@tool
class_name MCPNodeCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager
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
