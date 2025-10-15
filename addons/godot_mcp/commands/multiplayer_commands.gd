@tool
class_name MCPMultiplayerCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/multiplayer_commands.gd"
const DEFAULT_SYSTEM_SECTION := "multiplayer_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"get_multiplayer_state":
			_get_multiplayer_state(client_id, command_id)
			return true
		"create_multiplayer_peer":
			_create_multiplayer_peer(client_id, params, command_id)
			return true
		"teardown_multiplayer_peer":
			_teardown_multiplayer_peer(client_id, command_id)
			return true
		"spawn_multiplayer_scene":
			_spawn_multiplayer_scene(client_id, params, command_id)
			return true
	return false

func _log_event(action: String, message: String, context := {}):
	var entry := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(),
		"classname": "MCPMultiplayerCommands",
		"function": action,
		"system_section": DEFAULT_SYSTEM_SECTION,
		"line_num": 0,
		"error": false,
		"db_phase": "none",
		"method": "NONE",
		"message": message,
		"context": context,
	}
	print(JSON.stringify(entry))
	print("[Continuous skepticism (Sherlock Protocol)]", message)

func _get_scene_multiplayer() -> MultiplayerAPI:
	return get_tree().get_multiplayer()

func _get_multiplayer_state(client_id: int, command_id: String) -> void:
	var api := _get_scene_multiplayer()
	var has_peer := api.has_multiplayer_peer()
		var peer := has_peer ? api.get_multiplayer_peer() : null

	var connected := []
	if has_peer and api.has_method("get_peers"):
		for peer_id in api.get_peers():
			connected.append(int(peer_id))

	var allow_join := true
	if has_peer and peer != null and peer.has_method("get_refuse_new_connections"):
		allow_join = not peer.get_refuse_new_connections()

	var state := {
		"unique_id": api.get_unique_id(),
		"has_peer": has_peer,
		"connected_peers": connected,
		"is_server": api.is_server(),
		"accepts_new_connections": allow_join,
	}

		if has_peer and peer != null:
				state["peer_class"] = peer.get_class()
				state["transfer_mode"] = peer.has_method("get_transfer_mode") ? peer.get_transfer_mode() : null

	_log_event("_get_multiplayer_state", "Captured multiplayer snapshot", state)
	_send_success(client_id, state, command_id)

func _create_multiplayer_peer(client_id: int, params: Dictionary, command_id: String) -> void:
	var peer_type := String(params.get("peer_type", "enet")).to_lower()
	var mode := String(params.get("mode", "server")).to_lower()
	var api := _get_scene_multiplayer()
	var peer: MultiplayerPeer = null
	var error_code := OK

	match peer_type:
		"enet":
			var enet_peer := ENetMultiplayerPeer.new()
			if mode == "server":
				var port := int(params.get("port", 8910))
				var max_clients := int(params.get("max_clients", 32))
				error_code = enet_peer.create_server(port, max_clients)
			else:
				var address := String(params.get("address", "127.0.0.1"))
				var port := int(params.get("port", 8910))
				error_code = enet_peer.create_client(address, port)
			peer = enet_peer
		"websocket":
			var ws_peer := WebSocketMultiplayerPeer.new()
			if mode == "server":
				var port := int(params.get("port", 9080))
				var protocols := PackedStringArray(params.get("protocols", []))
				error_code = ws_peer.create_server(port, protocols)
			else:
				var url := String(params.get("url", "ws://127.0.0.1:9080"))
				error_code = ws_peer.create_client(url)
			peer = ws_peer
		"webrtc":
			var rtc_peer := WebRTCMultiplayerPeer.new()
			peer = rtc_peer
		_:
			return _send_error(client_id, "Unsupported peer_type: %s" % peer_type, command_id)

	if error_code != OK:
		return _send_error(client_id, "Failed to configure multiplayer peer (code %d)" % error_code, command_id)

	api.multiplayer_peer = peer
	if mode == "server" and peer != null and peer.has_method("set_refuse_new_connections"):
		peer.set_refuse_new_connections(false)

		_log_event("_create_multiplayer_peer", "Configured multiplayer peer", {
				"peer_type": peer_type,
				"mode": mode,
				"class": peer != null ? peer.get_class() : "",
		})
		_send_success(client_id, {
				"peer_type": peer_type,
				"mode": mode,
				"class": peer != null ? peer.get_class() : "",
		}, command_id)

func _teardown_multiplayer_peer(client_id: int, command_id: String) -> void:
	var api := _get_scene_multiplayer()
	var peer := api.get_multiplayer_peer()
	if peer != null and peer.has_method("close"):
		peer.close()
	api.multiplayer_peer = null

	_log_event("_teardown_multiplayer_peer", "Cleared multiplayer peer", {})
	_send_success(client_id, {
		"status": "cleared",
	}, command_id)

func _spawn_multiplayer_scene(client_id: int, params: Dictionary, command_id: String) -> void:
	var scene_path := params.get("scene_path", "")
	if scene_path.is_empty():
		return _send_error(client_id, "scene_path is required", command_id)

	var packed: PackedScene = load(scene_path)
	if packed == null:
		return _send_error(client_id, "Failed to load scene: %s" % scene_path, command_id)

	var instance := packed.instantiate()
	if instance == null:
		return _send_error(client_id, "Failed to instantiate scene: %s" % scene_path, command_id)

	var parent_path := params.get("parent_path", "/root")
	var parent := _get_editor_node(parent_path)
	if parent == null:
		parent = get_tree().root

	parent.add_child(instance)

	if params.has("owner_peer_id") and instance.has_method("set_multiplayer_authority"):
		instance.set_multiplayer_authority(int(params.get("owner_peer_id")))

	_mark_scene_modified()

	var instance_path := instance.get_path()
	_log_event("_spawn_multiplayer_scene", "Spawned multiplayer scene", {
		"scene": scene_path,
		"node_path": String(instance_path),
	})
	_send_success(client_id, {
		"scene": scene_path,
		"node_path": String(instance_path),
	}, command_id)
