@tool
class_name MCPCommandHandler
extends Node

var _websocket_server
var _command_processors = []

func _ready():
	print("=== COMMAND HANDLER INITIALIZING ===")
	await get_tree().process_frame
	_websocket_server = get_parent()
	print("WebSocket server reference set")
	print("=== COMMAND HANDLER READY ===")

func _handle_command(client_id: int, command: Dictionary) -> void:
	var command_type = command.get("type", "")
	var params = command.get("params", {})
	var command_id = command.get("commandId", "")
	
	print("Received command: %s with id: %s" % [command_type, command_id])
	
	# Just echo back success for now - we're testing connectivity
	_send_success(client_id, {"message": "Command received", "command": command_type}, command_id)

func _send_success(client_id: int, result: Dictionary, command_id: String) -> void:
	var response = {
		"status": "success",
		"result": result
	}
	
	if not command_id.is_empty():
		response["commandId"] = command_id
	
	if _websocket_server:
		_websocket_server.send_response(client_id, response)
		print("Sent success response for command: %s" % command_id)

func _send_error(client_id: int, message: String, command_id: String) -> void:
	var response = {
		"status": "error",
		"message": message
	}
	
	if not command_id.is_empty():
		response["commandId"] = command_id
	
	if _websocket_server:
		_websocket_server.send_response(client_id, response)
	print("Error: %s" % message)
