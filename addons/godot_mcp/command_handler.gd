@tool
class_name MCPCommandHandler
extends Node

const LOG_FILENAME := "addons/godot_mcp/command_handler.gd"
const LOG_SECTION := "command_handler"

var _websocket_server
var _command_processors: Array[MCPBaseCommandProcessor] = []

func _ready():
	await get_tree().process_frame
	_websocket_server = get_parent()
	_initialize_processors()
	_log("Command handler ready", "_ready", 18, {
		"processor_count": _command_processors.size()
	})

func _initialize_processors() -> void:
	var processor_classes: Array = [
		MCPNodeCommands,
		MCPScriptCommands,
		MCPSceneCommands,
		MCPProjectCommands,
		MCPEditorCommands,
		MCPEditorScriptCommands,
		MCPNavigationCommands,
		MCPAnimationCommands,
		MCPXRCommands,
		MCPMultiplayerCommands,
		MCPCompressionCommands,
		MCPRenderingCommands,
	]

	for processor_class in processor_classes:
		if processor_class == null:
			_log("Processor class unavailable", "_initialize_processors", 35, {
				"warning": true
			}, true)
			continue

		var processor: MCPBaseCommandProcessor = processor_class.new()
		if processor == null:
			_log("Failed to instantiate processor", "_initialize_processors", 42, {
				"processor_class": str(processor_class)
			}, true)
			continue

		processor._websocket_server = _websocket_server
		processor.name = processor.get_class()
		add_child(processor)
		processor.command_completed.connect(func(client_id, command_type, result, command_id):
			_on_command_completed(client_id, command_type, result, command_id, processor)
		)
		_command_processors.append(processor)

func _handle_command(client_id: int, command: Dictionary) -> void:
	var command_type: String = command.get("type", "")
	var params: Dictionary = command.get("params", {})
	var command_id_value = command.get("commandId", "")
	var command_id := ""
	if typeof(command_id_value) == TYPE_STRING:
		command_id = command_id_value
	else:
		command_id = str(command_id_value) if command_id_value != null else ""

	if command_type.is_empty():
		_log("Missing command type", "_handle_command", 64, {
			"client_id": client_id,
			"command": command
		}, true)
		_send_error(client_id, "Command type is required", command_id)
		return

	if typeof(params) != TYPE_DICTIONARY:
		_log("Coercing parameters to dictionary", "_handle_command", 73, {
			"client_id": client_id,
			"command_id": command_id
		})
		params = {}

	_log("Routing command", "_handle_command", 79, {
		"client_id": client_id,
		"command_type": command_type,
		"command_id": command_id
	})

	var handled := false
	for processor in _command_processors:
		if processor == null:
			continue

		if not processor.has_method("process_command"):
			_log("Processor missing process_command", "_handle_command", 90, {
				"processor": processor.name
			}, true)
			continue

		var result = processor.process_command(client_id, command_type, params, command_id)
		if result:
			handled = true
			break

	if not handled:
		_log("No processor handled command", "_handle_command", 101, {
			"client_id": client_id,
			"command_type": command_type,
			"command_id": command_id
		}, true)
		_send_error(client_id, "Unsupported command: %s" % command_type, command_id)

func _on_command_completed(client_id: int, command_type: String, result: Dictionary, command_id: String, processor: MCPBaseCommandProcessor) -> void:
	_log("Processor completed command", "_on_command_completed", 110, {
		"client_id": client_id,
		"command_type": command_type,
		"command_id": command_id,
		"processor": processor.name
	})

func _send_success(client_id: int, result: Dictionary, command_id: String) -> void:
	var response = {
		"status": "success",
		"result": result
	}

	if not command_id.is_empty():
		response["commandId"] = command_id

	if _websocket_server:
		_websocket_server.send_response(client_id, response)
		_log("Sent success response", "_send_success", 124, {
			"client_id": client_id,
			"command_id": command_id
		})

func _send_error(client_id: int, message: String, command_id: String) -> void:
	var response = {
		"status": "error",
		"message": message
	}

	if not command_id.is_empty():
		response["commandId"] = command_id

	if _websocket_server:
		_websocket_server.send_response(client_id, response)
	_log("Error response sent", "_send_error", 137, {
		"client_id": client_id,
		"command_id": command_id,
		"message": message
	}, true)

func _log(message: String, function_name: String, line_number: int, extra: Dictionary = {}, is_error: bool = false) -> void:
	var log_entry := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(),
		"classname": "MCPCommandHandler",
		"function": function_name,
		"system_section": LOG_SECTION,
		"line_num": line_number,
		"error": is_error,
		"db_phase": "none",
		"method": "NONE",
		"message": message
	}

	for key in extra.keys():
		log_entry[key] = extra[key]

	print(JSON.stringify(log_entry))
	var derived_message := "[Continuous skepticism (Sherlock Protocol)] %s" % message
	if extra.size() > 0:
		derived_message += " | " + JSON.stringify(extra)
	print(derived_message)
