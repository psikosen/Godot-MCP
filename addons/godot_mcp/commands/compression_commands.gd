@tool
class_name MCPCompressionCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/compression_commands.gd"
const DEFAULT_SYSTEM_SECTION := "compression_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"configure_texture_compression":
			_configure_texture_compression(client_id, params, command_id)
			return true
		"batch_reimport_textures":
			_batch_reimport_textures(client_id, params, command_id)
			return true
		"create_texture_import_preset":
			_create_texture_import_preset(client_id, params, command_id)
			return true
		"list_texture_compression_settings":
			_list_texture_compression_settings(client_id, command_id)
			return true
	return false

func _log_event(action: String, message: String, context := {}):
	var entry := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(),
		"classname": "MCPCompressionCommands",
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

func _configure_texture_compression(client_id: int, params: Dictionary, command_id: String) -> void:
	var platform := params.get("platform", "")
	var settings := params.get("settings", {})

	if platform.is_empty():
		return _send_error(client_id, "platform is required", command_id)

	if typeof(settings) != TYPE_DICTIONARY:
		return _send_error(client_id, "settings must be a dictionary", command_id)

	var applied := {}
	for key in settings.keys():
		var path := "rendering/textures/vram_compression/%s/%s" % [platform, key]
		ProjectSettings.set_setting(path, settings[key])
		applied[path] = settings[key]

	if params.get("save", true):
		ProjectSettings.save()

	_log_event("_configure_texture_compression", "Updated compression settings", {
		"platform": platform,
		"count": applied.size(),
	})
	_send_success(client_id, {
		"platform": platform,
		"applied": applied,
		"saved": params.get("save", true),
	}, command_id)

func _batch_reimport_textures(client_id: int, params: Dictionary, command_id: String) -> void:
	var paths := params.get("paths", [])
	if typeof(paths) != TYPE_ARRAY or paths.is_empty():
		return _send_error(client_id, "paths must be a non-empty array", command_id)

	var filesystem := EditorFileSystem.get_singleton()
	if filesystem == null:
		return _send_error(client_id, "EditorFileSystem is not available", command_id)

	filesystem.reimport_files(paths)

	_log_event("_batch_reimport_textures", "Triggered texture reimport", {"count": paths.size()})
	_send_success(client_id, {
		"paths": paths,
		"reimported": paths.size(),
	}, command_id)

func _create_texture_import_preset(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset_name := params.get("preset_name", "")
	var importer := params.get("importer", "texture")
	var options := params.get("options", {})

	if preset_name.is_empty():
		return _send_error(client_id, "preset_name is required", command_id)

	if typeof(options) != TYPE_DICTIONARY:
		return _send_error(client_id, "options must be a dictionary", command_id)

	var preset_path := "import/presets/%s/%s" % [importer, preset_name]
	ProjectSettings.set_setting(preset_path, options)

	if params.get("save", true):
		ProjectSettings.save()

	_log_event("_create_texture_import_preset", "Registered texture import preset", {
		"preset": preset_name,
		"importer": importer,
	})
	_send_success(client_id, {
		"preset": preset_name,
		"importer": importer,
		"saved": params.get("save", true),
	}, command_id)

func _list_texture_compression_settings(client_id: int, command_id: String) -> void:
	var result := {}
	var categories := ["rendering/textures/vram_compression", "import/presets/texture"]

	for base_path in categories:
		var section := {}
		var section_keys := ProjectSettings.get_setting(base_path, null)
		if typeof(section_keys) == TYPE_DICTIONARY:
			section = section_keys.duplicate(true)
		result[base_path] = section

	_log_event("_list_texture_compression_settings", "Collected compression settings snapshot", {"categories": result.keys()})
	_send_success(client_id, {
		"settings": result,
	}, command_id)
