@tool
class_name MCPNodeCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager

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
	return false  # Command not handled

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
