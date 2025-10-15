@tool
class_name MCPCommandHandler
extends Node

const LOG_FILENAME := "addons/godot_mcp/command_handler.gd"
const LOG_SECTION := "command_handler"

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
var _command_processors: Array[MCPBaseCommandProcessor] = []

func _ready():
        await get_tree().process_frame
        _websocket_server = get_parent()
        _load_processor_classes()
        _initialize_processors()
        _log("Command handler ready", "_ready", 29, {
                "processor_count": _command_processors.size()
        })

func _load_processor_classes() -> void:
        var class_specs := [
                {"name": "MCPNodeCommands", "path": "res://addons/godot_mcp/commands/node_commands.gd"},
                {"name": "MCPScriptCommands", "path": "res://addons/godot_mcp/commands/script_commands.gd"},
                {"name": "MCPSceneCommands", "path": "res://addons/godot_mcp/commands/scene_commands.gd"},
                {"name": "MCPProjectCommands", "path": "res://addons/godot_mcp/commands/project_commands.gd"},
                {"name": "MCPEditorCommands", "path": "res://addons/godot_mcp/commands/editor_commands.gd"},
                {"name": "MCPEditorScriptCommands", "path": "res://addons/godot_mcp/commands/editor_script_commands.gd"},
                {"name": "MCPNavigationCommands", "path": "res://addons/godot_mcp/commands/navigation_commands.gd"},
                {"name": "MCPAnimationCommands", "path": "res://addons/godot_mcp/commands/animation_commands.gd"},
                {"name": "MCPXRCommands", "path": "res://addons/godot_mcp/commands/xr_commands.gd"},
                {"name": "MCPMultiplayerCommands", "path": "res://addons/godot_mcp/commands/multiplayer_commands.gd"},
                {"name": "MCPCompressionCommands", "path": "res://addons/godot_mcp/commands/compression_commands.gd"},
                {"name": "MCPRenderingCommands", "path": "res://addons/godot_mcp/commands/rendering_commands.gd"},
        ]

        var loaded_count := 0
        for class_spec in class_specs:
                var script: Script = load(class_spec["path"])
                if script == null:
                        _log("Failed to load command processor class", "_load_processor_classes", 53, {
                                "class_name": class_spec["name"],
                                "path": class_spec["path"]
                        }, true)
                        self.set(class_spec["name"], null)
                        continue

                self.set(class_spec["name"], script)
                loaded_count += 1

        _log("Loaded command processor classes", "_load_processor_classes", 63, {
                "loaded_count": loaded_count,
                "requested_count": class_specs.size()
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
                        _log("Processor class unavailable", "_initialize_processors", 86, {
                                "warning": true
                        }, true)
                        continue

                var processor: MCPBaseCommandProcessor = processor_class.new()
                if processor == null:
                        _log("Failed to instantiate processor", "_initialize_processors", 93, {
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
                command_id = command_id_value != null ? str(command_id_value) : ""

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

func _on_command_completed(client_id: int, command_type: String, result: Dictionary, command_id: String, processor: MCPBaseCommandProcessor) -> void:
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
        var derived_message := "[Continuous skepticism (Sherlock Protocol)] %s" % message
        if extra.size() > 0:
                derived_message += " | " + JSON.stringify(extra)
        print(derived_message)
