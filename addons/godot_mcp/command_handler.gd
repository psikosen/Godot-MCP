@tool
class_name MCPCommandHandler
extends Node

const LOG_FILENAME := "addons/godot_mcp/command_handler.gd"
const LOG_SECTION := "command_handler"

## Load command processor scripts at runtime to avoid compile-time preload failures

const COMMAND_PROCESSOR_DEFINITIONS := [
	{
		"name": "MCPNodeCommands",
		"path": "res://addons/godot_mcp/commands/node_commands.gd",
	},
	{
		"name": "MCPScriptCommands",
		"path": "res://addons/godot_mcp/commands/script_commands.gd",
	},
	{
		"name": "MCPSceneCommands",
		"path": "res://addons/godot_mcp/commands/scene_commands.gd",
	},
	{
		"name": "MCPProjectCommands",
		"path": "res://addons/godot_mcp/commands/project_commands.gd",
	},
	{
		"name": "MCPEditorCommands",
		"path": "res://addons/godot_mcp/commands/editor_commands.gd",
	},
	{
		"name": "MCPEditorScriptCommands",
		"path": "res://addons/godot_mcp/commands/editor_script_commands.gd",
	},
	{
		"name": "MCPNavigationCommands",
		"path": "res://addons/godot_mcp/commands/navigation_commands.gd",
	},
	{
		"name": "MCPAnimationCommands",
		"path": "res://addons/godot_mcp/commands/animation_commands.gd",
	},
	{
		"name": "MCPXRCommands",
		"path": "res://addons/godot_mcp/commands/xr_commands.gd",
	},
	{
		"name": "MCPMultiplayerCommands",
		"path": "res://addons/godot_mcp/commands/multiplayer_commands.gd",
	},
	{
		"name": "MCPCompressionCommands",
		"path": "res://addons/godot_mcp/commands/compression_commands.gd",
	},
	{
		"name": "MCPRenderingCommands",
		"path": "res://addons/godot_mcp/commands/rendering_commands.gd",
	},
]

var MCPNodeCommands
var MCPScriptCommands
var MCPSceneCommands
var MCPProjectCommands
var MCPEditorCommands
var MCPEditorScriptCommands
var MCPNavigationCommands
var MCPAnimationCommands
var MCPXRCommands
var MCPMultiplayerCommands
var MCPCompressionCommands
var MCPRenderingCommands

var _websocket_server
var _command_processors: Array = []

var _is_ready := false

# Called by mcp_server.gd immediately after add_child() to ensure
# processors are loaded before any commands arrive
func initialize(server) -> void:
	if _is_ready:
		return  # Already initialized
	_websocket_server = server
	_load_processor_classes()
	_initialize_processors()
	_is_ready = true
	_log("Command handler initialized", "initialize", 29, {
		"processor_count": _command_processors.size()
	})

func _ready():
	# Fallback initialization if initialize() wasn't called
	if not _is_ready:
		_websocket_server = get_parent()
		_load_processor_classes()
		_initialize_processors()
		_is_ready = true
		_log("Command handler ready (fallback)", "_ready", 35, {
			"processor_count": _command_processors.size()
		})

# Load scripts on demand to avoid failing the entire plugin due to one bad script
func _load_processor_classes() -> void:
	var loaded_count := 0
	print("[MCP] Loading processor classes...")
	for class_spec in COMMAND_PROCESSOR_DEFINITIONS:
		var path: String = class_spec.get("path", "")
		var script: Script = null
		print("[MCP] Loading: ", path)
		if path != "":
			script = ResourceLoader.load(path)
		if script == null:
			print("[MCP] FAILED to load: ", path)
			_log("Failed to load command processor class", "_load_processor_classes", 53, {
				"class_name": class_spec["name"],
				"path": class_spec.get("path", "")
			}, true)
			set(class_spec["name"], null)
			continue
		if not script.can_instantiate():
			print("[MCP] FAILED to instantiate (parse/compile issue): ", path)
			_log("Command processor script cannot instantiate", "_load_processor_classes", 61, {
				"class_name": class_spec["name"],
				"path": class_spec.get("path", "")
			}, true)
			set(class_spec["name"], null)
			continue

		print("[MCP] SUCCESS loading: ", path)
		set(class_spec["name"], script)
		loaded_count += 1

	print("[MCP] Loaded ", loaded_count, "/", COMMAND_PROCESSOR_DEFINITIONS.size(), " processor classes")
	_log("Loaded command processor classes", "_load_processor_classes", 63, {
		"loaded_count": loaded_count,
		"requested_count": COMMAND_PROCESSOR_DEFINITIONS.size()
	})

func _initialize_processors() -> void:
	print("[MCP] Initializing processors...")
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
	print("[MCP] Processor classes array has ", processor_classes.size(), " entries")

	for processor_class in processor_classes:
		if processor_class == null:
			_log("Processor class unavailable", "_initialize_processors", 86, {
				"warning": true
			}, true)
			continue

		var processor = null
		if processor_class is Script and processor_class.can_instantiate():
			processor = processor_class.new()
			_log("Created processor instance", "_initialize_processors", 90, {
				"script": processor_class.resource_path if processor_class.resource_path else "unknown"
			})

		if processor == null:
			_log("Failed to instantiate processor - null result", "_initialize_processors", 93, {
				"processor_class": str(processor_class)
			}, true)
			continue

		if not (processor is Node):
			_log("Failed to instantiate processor - not a Node", "_initialize_processors", 97, {
				"processor_class": str(processor_class),
				"actual_type": typeof(processor)
			}, true)
			continue

		processor._websocket_server = _websocket_server
		processor.name = processor_class.resource_path.get_file().get_basename() if processor_class.resource_path else "Processor"
		add_child(processor)
		processor.command_completed.connect(func(client_id, command_type, result, command_id):
			_on_command_completed(client_id, command_type, result, command_id, processor)
		)
		_command_processors.append(processor)
		_log("Added processor", "_initialize_processors", 108, {
			"name": processor.name,
			"total_processors": _command_processors.size()
		})

func _handle_command(client_id: int, command: Dictionary) -> void:
	# Check if command handler is ready
	if not _is_ready:
		var command_id_early = command.get("commandId", "")
		_send_error(client_id, "Command handler not ready yet, please retry", str(command_id_early) if command_id_early != null else "")
		return

	var command_type: String = command.get("type", "")
	var params: Dictionary = command.get("params", {})
	var command_id_value = command.get("commandId", "")
	var command_id := ""
	if typeof(command_id_value) == TYPE_STRING:
		command_id = command_id_value
	else:
		command_id = str(command_id_value) if command_id_value != null else ""

	if command_type.is_empty():
		_log("Missing command type", "_handle_command", 117, {
			"client_id": client_id,
			"command": command
		}, true)
		_send_error(client_id, "Command type is required", command_id)
		return

	if typeof(params) != TYPE_DICTIONARY:
		_log("Coercing parameters to dictionary", "_handle_command", 125, {
			"client_id": client_id,
			"command_id": command_id
		})
		params = {}

	_log("Routing command", "_handle_command", 131, {
		"client_id": client_id,
		"command_type": command_type,
		"command_id": command_id
	})

	var handled := false
	for processor in _command_processors:
		if processor == null:
			continue

		if not processor.has_method("process_command"):
			_log("Processor missing process_command", "_handle_command", 143, {
				"processor": processor.name
			}, true)
			continue

		var result = processor.process_command(client_id, command_type, params, command_id)
		if result:
			handled = true
			break

	if not handled:
		_log("No processor handled command", "_handle_command", 154, {
			"client_id": client_id,
			"command_type": command_type,
			"command_id": command_id
		}, true)
		_send_error(client_id, "Unsupported command: %s" % command_type, command_id)

func _on_command_completed(client_id: int, command_type: String, result: Dictionary, command_id: String, processor) -> void:
	_log("Processor completed command", "_on_command_completed", 162, {
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
		_log("Sent success response", "_send_success", 180, {
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
	_log("Error response sent", "_send_error", 196, {
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
