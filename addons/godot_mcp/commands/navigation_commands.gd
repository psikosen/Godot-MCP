@tool
class_name MCPNavigationCommands
extends MCPBaseCommandProcessor

const SceneTransactionManager := MCPSceneTransactionManager
const LOG_FILENAME := "addons/godot_mcp/commands/navigation_commands.gd"
const DEFAULT_SYSTEM_SECTION := "navigation_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"list_navigation_maps":
			_list_navigation_maps(client_id, params, command_id)
			return true
		"list_navigation_agents":
			_list_navigation_agents(client_id, params, command_id)
			return true
		"bake_navigation_region":
			_bake_navigation_region(client_id, params, command_id)
			return true
		"update_navigation_region":
			_update_navigation_region(client_id, params, command_id)
			return true
		"update_navigation_resource":
			_update_navigation_resource(client_id, params, command_id)
			return true
		"update_navigation_agent":
			_update_navigation_agent(client_id, params, command_id)
			return true
		"synchronize_navmesh_with_tilemap":
			_synchronize_navmesh_with_tilemap(client_id, params, command_id)
			return true
	return false

func _list_navigation_maps(client_id: int, params: Dictionary, command_id: String) -> void:
	var dimension := String(params.get("dimension", "both")).to_lower()
	if not ["2d", "3d", "both"].has(dimension):
		return _send_error(client_id, "Invalid dimension filter: %s" % dimension, command_id)

    var plugin = Engine.has_meta("GodotMCPPlugin") ? Engine.get_meta("GodotMCPPlugin") : null
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var root = editor_interface.get_edited_scene_root()
	if not root:
		return _send_error(client_id, "No active scene loaded in the editor", command_id)

	var region_summaries: Array = []
	var queue: Array = [root]
	while not queue.is_empty():
		var node: Node = queue.pop_front()

		if (dimension == "2d" or dimension == "both") and node is NavigationRegion2D:
			region_summaries.append(_summarize_region_2d(node))
		elif (dimension == "3d" or dimension == "both") and node is NavigationRegion3D:
			region_summaries.append(_summarize_region_3d(node))

		for child in node.get_children():
			if child is Node:
				queue.append(child)

	_log("Listed navigation maps", "_list_navigation_maps", {
		"count": region_summaries.size(),
		"dimension": dimension,
	})

	_send_success(client_id, {
		"dimension": dimension,
		"regions": region_summaries,
	}, command_id)

func _list_navigation_agents(client_id: int, params: Dictionary, command_id: String) -> void:
	var dimension := String(params.get("dimension", "both")).to_lower()
	if not ["2d", "3d", "both"].has(dimension):
		return _send_error(client_id, "Invalid dimension filter: %s" % dimension, command_id)

    var plugin = Engine.has_meta("GodotMCPPlugin") ? Engine.get_meta("GodotMCPPlugin") : null
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)

	var editor_interface = plugin.get_editor_interface()
	var root = editor_interface.get_edited_scene_root()
	if not root:
		return _send_error(client_id, "No active scene loaded in the editor", command_id)

	var agent_summaries: Array = []
	var queue: Array = [root]
	while not queue.is_empty():
		var node: Node = queue.pop_front()

		if (dimension == "2d" or dimension == "both") and node is NavigationAgent2D:
			agent_summaries.append(_summarize_agent_2d(node))
		elif (dimension == "3d" or dimension == "both") and node is NavigationAgent3D:
			agent_summaries.append(_summarize_agent_3d(node))

		for child in node.get_children():
			if child is Node:
				queue.append(child)

	_log("Listed navigation agents", "_list_navigation_agents", {
		"count": agent_summaries.size(),
		"dimension": dimension,
	})

	_send_success(client_id, {
		"dimension": dimension,
		"agents": agent_summaries,
	}, command_id)

func _bake_navigation_region(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := params.get("node_path", "")
	var on_thread := params.get("on_thread", true)
	if node_path.is_empty():
		return _send_error(client_id, "Navigation region path cannot be empty", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Navigation region not found: %s" % node_path, command_id)

	if node is NavigationRegion2D:
		node.bake_navigation_polygon(on_thread)
		_log("Triggered 2D navigation bake", "_bake_navigation_region", {
			"node_path": _path_to_string(node),
			"on_thread": on_thread,
		})
		_send_success(client_id, {
			"node_path": _path_to_string(node),
			"dimension": "2d",
			"status": "bake_started",
			"on_thread": on_thread,
		}, command_id)
	elif node is NavigationRegion3D:
		node.bake_navigation_mesh(on_thread)
		_log("Triggered 3D navigation bake", "_bake_navigation_region", {
			"node_path": _path_to_string(node),
			"on_thread": on_thread,
		})
		_send_success(client_id, {
			"node_path": _path_to_string(node),
			"dimension": "3d",
			"status": "bake_started",
			"on_thread": on_thread,
		}, command_id)
	else:
		_send_error(client_id, "Node at path is not a NavigationRegion2D or NavigationRegion3D", command_id)

func _update_navigation_region(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := params.get("node_path", "")
	var properties: Dictionary = params.get("properties", {})
	var transaction_id := params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Navigation region path cannot be empty", command_id)
	if properties.is_empty():
		return _send_error(client_id, "No properties provided for update", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Navigation region not found: %s" % node_path, command_id)
	if not (node is NavigationRegion2D or node is NavigationRegion3D):
		return _send_error(client_id, "Node at path is not a navigation region", command_id)

	var transaction_metadata := {
		"command": "update_navigation_region",
		"node_path": node_path,
		"properties": properties,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Update Navigation Region", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Update Navigation Region", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for navigation region update", command_id)

	var property_changes: Array = []
	for property_name in properties.keys():
		if not _has_property(node, property_name):
			if transaction_id.is_empty():
				transaction.rollback()
			return _send_error(client_id, "Navigation region does not have property: %s" % property_name, command_id)

		var parsed_value = _parse_property_value(properties[property_name])
		var old_value = node.get(property_name)
		property_changes.append({
			"property": property_name,
			"new_value": parsed_value,
			"old_value": old_value,
		})

	for change in property_changes:
		transaction.add_do_property(node, change["property"], change["new_value"])
		transaction.add_undo_property(node, change["property"], change["old_value"])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Updated navigation region", "_update_navigation_region", {
			"node_path": _path_to_string(node),
			"properties": properties.keys(),
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit navigation region update", command_id)

		_send_success(client_id, {
			"node_path": _path_to_string(node),
			"properties": properties,
			"transaction_id": transaction.transaction_id,
			"status": "committed",
		}, command_id)
	else:
			_send_success(client_id, {
				"node_path": node_path,
				"properties": properties,
				"transaction_id": transaction.transaction_id,
				"status": "pending",
			}, command_id)

func _update_navigation_resource(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := params.get("node_path", "")
	var properties: Dictionary = params.get("properties", {})
	var transaction_id := params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Navigation region path is required to access its resource", command_id)
	if properties.is_empty():
		return _send_error(client_id, "No resource properties provided for update", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Navigation region not found: %s" % node_path, command_id)

	var resource
	var dimension := ""
	if node is NavigationRegion2D:
		resource = node.navigation_polygon
		dimension = "2d"
	elif node is NavigationRegion3D:
		resource = node.navigation_mesh
		dimension = "3d"
	else:
		return _send_error(client_id, "Node at path is not a navigation region", command_id)

	if resource == null:
		return _send_error(client_id, "Navigation region has no associated resource", command_id)

	var transaction_metadata := {
		"command": "update_navigation_resource",
		"node_path": node_path,
		"properties": properties,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Update Navigation Resource", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Update Navigation Resource", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for navigation resource update", command_id)

	if not resource.has_method("set"):
		if transaction_id.is_empty():
			transaction.rollback()
		return _send_error(client_id, "Navigation resource does not support property updates", command_id)

	var resource_changes: Array = []
	for property_name in properties.keys():
		if not _has_property(resource, property_name):
			if transaction_id.is_empty():
				transaction.rollback()
			return _send_error(client_id, "Navigation resource does not have property: %s" % property_name, command_id)

		var parsed_value = _parse_property_value(properties[property_name])
		var old_value = resource.get(property_name)
		resource_changes.append({
			"property": property_name,
			"new_value": parsed_value,
			"old_value": old_value,
		})

	transaction.add_do_reference(resource)

	for change in resource_changes:
		transaction.add_do_property(resource, change["property"], change["new_value"])
		transaction.add_undo_property(resource, change["property"], change["old_value"])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Updated navigation resource", "_update_navigation_resource", {
			"node_path": _path_to_string(node),
			"dimension": dimension,
			"properties": properties.keys(),
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit navigation resource update", command_id)

		_send_success(client_id, {
			"node_path": _path_to_string(node),
			"dimension": dimension,
			"properties": properties,
			"transaction_id": transaction.transaction_id,
			"status": "committed",
		}, command_id)
	else:
		_send_success(client_id, {
			"node_path": node_path,
			"dimension": dimension,
			"properties": properties,
			"transaction_id": transaction.transaction_id,
			"status": "pending",
		}, command_id)

func _update_navigation_agent(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := params.get("node_path", "")
	var properties: Dictionary = params.get("properties", {})
	var transaction_id := params.get("transaction_id", "")

	if node_path.is_empty():
		return _send_error(client_id, "Navigation agent path cannot be empty", command_id)
	if properties.is_empty():
		return _send_error(client_id, "No agent properties provided for update", command_id)

	var node = _get_editor_node(node_path)
	if not node:
		return _send_error(client_id, "Navigation agent not found: %s" % node_path, command_id)
	if not (node is NavigationAgent2D or node is NavigationAgent3D):
		return _send_error(client_id, "Node at path is not a navigation agent", command_id)

	var dimension := node is NavigationAgent2D ? "2d" : "3d"

	var transaction_metadata := {
		"command": "update_navigation_agent",
		"node_path": node_path,
		"properties": properties,
		"client_id": client_id,
		"command_id": command_id,
	}

	var transaction
	if transaction_id.is_empty():
		transaction = SceneTransactionManager.begin_inline("Update Navigation Agent", transaction_metadata)
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if not transaction:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Update Navigation Agent", transaction_metadata)

	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction for navigation agent update", command_id)

	var agent_changes: Array = []
	for property_name in properties.keys():
		if not _has_property(node, property_name):
			if transaction_id.is_empty():
				transaction.rollback()
			return _send_error(client_id, "Navigation agent does not have property: %s" % property_name, command_id)

		var parsed_value = _parse_property_value(properties[property_name])
		var old_value = node.get(property_name)
		agent_changes.append({
			"property": property_name,
			"new_value": parsed_value,
			"old_value": old_value,
		})

	for change in agent_changes:
		transaction.add_do_property(node, change["property"], change["new_value"])
		transaction.add_undo_property(node, change["property"], change["old_value"])

	transaction.register_on_commit(func():
		_mark_scene_modified()
		_log("Updated navigation agent", "_update_navigation_agent", {
			"node_path": _path_to_string(node),
			"dimension": dimension,
			"properties": properties.keys(),
			"transaction_id": transaction.transaction_id,
		})
	)

	if transaction_id.is_empty():
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit navigation agent update", command_id)

		_send_success(client_id, {
			"node_path": _path_to_string(node),
			"dimension": dimension,
			"properties": properties,
			"transaction_id": transaction.transaction_id,
			"status": "committed",
		}, command_id)
	else:
		_send_success(client_id, {
			"node_path": node_path,
			"dimension": dimension,
			"properties": properties,
			"transaction_id": transaction.transaction_id,
			"status": "pending",
		}, command_id)



func _synchronize_navmesh_with_tilemap(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_synchronize_navmesh_with_tilemap"
	var tilemap_path := String(params.get("tilemap_path", ""))
	var region_paths_param = params.get("region_paths", [])
	var on_thread := bool(params.get("on_thread", true))

	var context := {
		"command": "synchronize_navmesh_with_tilemap",
		"client_id": client_id,
		"tilemap_path": tilemap_path,
		"on_thread": on_thread,
	}

	if tilemap_path.is_empty():
		_log("TileMap path cannot be empty", function_name, context, true)
		return _send_error(client_id, "TileMap path cannot be empty", command_id)

	var tilemap = _get_editor_node(tilemap_path)
	if not tilemap:
		_log("TileMap node not found", function_name, context, true)
		return _send_error(client_id, "TileMap not found: %s" % tilemap_path, command_id)

	if not (tilemap is TileMap):
		context["node_type"] = tilemap.get_class()
		_log("Node at path is not a TileMap", function_name, context, true)
		return _send_error(client_id, "Node at path is not a TileMap", command_id)

	var requested_region_paths: Array = []
	if params.has("region_paths"):
		if typeof(region_paths_param) == TYPE_ARRAY:
			requested_region_paths = region_paths_param.duplicate()
		else:
			context["region_paths_type"] = Variant.get_type_name(typeof(region_paths_param))
			_log("region_paths must be an array of node paths", function_name, context, true)
			return _send_error(client_id, "region_paths must be an array of node paths", command_id)
	elif region_paths_param is Array:
		requested_region_paths = region_paths_param.duplicate()

	var rebaked_regions: Array = []
	var invalid_regions: Array = []
	var target_regions: Array = []

	if requested_region_paths.is_empty():
		for child in tilemap.get_children():
			if child is NavigationRegion2D or child is NavigationRegion3D:
				target_regions.append(child)
	else:
		for entry in requested_region_paths:
			var region_path := String(entry)
			if region_path.is_empty():
				continue
			var region_node = _get_editor_node(region_path)
			if not region_node:
				invalid_regions.append(region_path)
				continue
			if not (region_node is NavigationRegion2D or region_node is NavigationRegion3D):
				invalid_regions.append(region_path)
				continue
			target_regions.append(region_node)

	for region in target_regions:
		if region is NavigationRegion2D:
			region.bake_navigation_polygon(on_thread)
			rebaked_regions.append(_path_to_string(region))
		elif region is NavigationRegion3D:
			region.bake_navigation_mesh(on_thread)
			rebaked_regions.append(_path_to_string(region))

	var navigation_map_updated := false
	if tilemap.has_method("bake_navigation"):
		tilemap.bake_navigation()
		navigation_map_updated = true
	elif tilemap.has_method("queue_navigation_update"):
		tilemap.queue_navigation_update()
		navigation_map_updated = true
	elif tilemap.has_method("get_navigation_map"):
		var nav_map = tilemap.get_navigation_map()
		if typeof(nav_map) == TYPE_RID:
			var rid: RID = nav_map
			if rid.is_valid():
				NavigationServer2D.map_force_update(rid)
				navigation_map_updated = true

	if tilemap.has_method("update_internals"):
		tilemap.update_internals()

	if rebaked_regions.size() > 0 or navigation_map_updated:
		_mark_scene_modified()

	var result := {
		"tilemap_path": _path_to_string(tilemap),
		"rebaked_regions": rebaked_regions,
		"invalid_regions": invalid_regions,
		"navigation_map_updated": navigation_map_updated,
	}

	_log("Synchronized TileMap navigation", function_name, result)

	_send_success(client_id, result, command_id)

func _summarize_region_2d(region: NavigationRegion2D) -> Dictionary:
	var polygon := region.navigation_polygon
	var summary := {
		"dimension": "2d",
		"node_path": _path_to_string(region),
		"enabled": region.enabled,
		"navigation_layers": region.navigation_layers,
		"travel_cost": region.travel_cost,
		"enter_cost": region.enter_cost,
		"use_edge_connections": region.use_edge_connections,
		"resource": _summarize_navigation_polygon(polygon),
	}
	return summary

func _summarize_region_3d(region: NavigationRegion3D) -> Dictionary:
	var mesh := region.navigation_mesh
	var summary := {
		"dimension": "3d",
		"node_path": _path_to_string(region),
		"enabled": region.enabled,
		"navigation_layers": region.navigation_layers,
		"travel_cost": region.travel_cost,
		"enter_cost": region.enter_cost,
		"use_edge_connections": region.use_edge_connections,
		"resource": _summarize_navigation_mesh(mesh),
	}
	return summary

func _summarize_agent_2d(agent: NavigationAgent2D) -> Dictionary:
	return {
		"dimension": "2d",
		"node_path": _path_to_string(agent),
		"target_position": _vector_to_dict(agent.target_position),
		"position": _vector_to_dict(agent.global_position),
		"velocity": _vector_to_dict(agent.velocity),
		"radius": agent.radius,
		"max_speed": agent.max_speed,
		"max_acceleration": agent.max_acceleration,
		"path_desired_distance": agent.path_desired_distance,
		"target_desired_distance": agent.target_desired_distance,
		"avoidance_enabled": agent.avoidance_enabled,
		"max_neighbors": agent.max_neighbors,
		"neighbor_max_distance": agent.neighbor_max_distance,
	}

func _summarize_agent_3d(agent: NavigationAgent3D) -> Dictionary:
	return {
		"dimension": "3d",
		"node_path": _path_to_string(agent),
		"target_position": _vector_to_dict(agent.target_position),
		"position": _vector_to_dict(agent.global_position),
		"velocity": _vector_to_dict(agent.velocity),
		"radius": agent.radius,
		"height": agent.height,
		"max_speed": agent.max_speed,
		"max_acceleration": agent.max_acceleration,
		"path_desired_distance": agent.path_desired_distance,
		"target_desired_distance": agent.target_desired_distance,
		"avoidance_enabled": agent.avoidance_enabled,
		"max_neighbors": agent.max_neighbors,
		"neighbor_max_distance": agent.neighbor_max_distance,
	}

func _summarize_navigation_polygon(polygon: NavigationPolygon) -> Dictionary:
	if polygon == null:
		return {
			"resource_path": "",
			"vertex_count": 0,
			"polygon_count": 0,
			"is_local": true,
		}

	var vertex_count := polygon.get_vertices().size()
	var polygon_count := polygon.get_polygon_count()
	return {
		"resource_path": polygon.resource_path,
		"vertex_count": vertex_count,
		"polygon_count": polygon_count,
		"is_local": polygon.resource_path.is_empty(),
	}

func _summarize_navigation_mesh(mesh: NavigationMesh) -> Dictionary:
	if mesh == null:
		return {
			"resource_path": "",
			"vertex_count": 0,
			"polygon_count": 0,
			"is_local": true,
		}

	return {
		"resource_path": mesh.resource_path,
		"vertex_count": mesh.get_vertices().size(),
		"polygon_count": mesh.get_polygon_count(),
		"agent_radius": mesh.agent_radius,
		"cell_size": mesh.cell_size,
		"cell_height": mesh.cell_height,
		"is_local": mesh.resource_path.is_empty(),
	}

func _vector_to_dict(value) -> Dictionary:
	match typeof(value):
		TYPE_VECTOR2:
			return {"x": value.x, "y": value.y}
		TYPE_VECTOR3:
			return {"x": value.x, "y": value.y, "z": value.z}
		TYPE_VECTOR2I:
			return {"x": value.x, "y": value.y}
		TYPE_VECTOR3I:
			return {"x": value.x, "y": value.y, "z": value.z}
	return {"value": str(value)}

func _path_to_string(node: Node) -> String:
	var node_path = node.get_path()
	if typeof(node_path) == TYPE_NODE_PATH:
		return String(node_path)
	return str(node_path)

func _has_property(target: Object, property_name: String) -> bool:
	if target == null:
		return false

	var property_list = target.get_property_list()
	for property_info in property_list:
		if typeof(property_info) == TYPE_DICTIONARY and property_info.has("name"):
			if String(property_info["name"]) == property_name:
				return true

	return false

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPNavigationCommands",
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
