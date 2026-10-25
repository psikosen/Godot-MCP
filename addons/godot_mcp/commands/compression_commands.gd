@tool
class_name MCPCompressionCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"

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

func _configure_texture_compression(client_id: int, params: Dictionary, command_id: String) -> void:
	var platform := params.get("platform", "")
	var settings := params.get("settings", {})

	if platform.is_empty():
		return _send_error(client_id, "platform is required", command_id)

	if typeof(settings) != TYPE_DICTIONARY:
		return _send_error(client_id, "settings must be a dictionary", command_id)

	# Godot stores one flat setting per option (vram_compression/import_etc2_astc); a platform
	# override is the same name with a ".<platform>" feature-tag suffix.
	var base := "rendering/textures/vram_compression"
	var platforms := ["android", "ios", "macos", "windows", "linuxbsd", "web"]
	var applied := {}
	for key in settings.keys():
		var path := "%s/%s/%s" % [base, platform, key]
		if not ProjectSettings.has_setting(path):
			var flat := "%s/%s" % [base, key]
			if not ProjectSettings.has_setting(flat):
				return _send_error(client_id, "Unknown compression setting: %s (see list_texture_compression_settings for valid keys)" % flat, command_id)
			if not platform in platforms:
				return _send_error(client_id, "Unknown platform '%s' (expected one of %s)" % [platform, ", ".join(platforms)], command_id)
			path = "%s.%s" % [flat, platform]
		applied[path] = settings[key]
	for path in applied:
		ProjectSettings.set_setting(path, applied[path])

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
		"note": "" if params.get("save", true) else "save=false only skips writing project.godot now; the in-memory values stay and will be written by any later ProjectSettings.save() (including the editor's own).",
	}, command_id)

func _batch_reimport_textures(client_id: int, params: Dictionary, command_id: String) -> void:
	var paths := params.get("paths", [])
	if typeof(paths) != TYPE_ARRAY or paths.is_empty():
		return _send_error(client_id, "paths must be a non-empty array", command_id)

	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem == null:
		return _send_error(client_id, "EditorFileSystem is not available", command_id)

	var existing := PackedStringArray()
	var missing: Array = []
	var image_extensions := ["png", "jpg", "jpeg", "webp", "bmp", "tga", "svg", "svgz", "exr", "hdr", "dds", "ktx", "tif", "tiff"]
	for path in paths:
		if not str(path).get_extension().to_lower() in image_extensions:
			return _send_error(client_id, "Not a texture/image file: %s (expected one of %s)" % [path, ", ".join(image_extensions)], command_id)
		if FileAccess.file_exists(str(path)):
			existing.append(str(path))
		else:
			missing.append(path)
	if existing.is_empty():
		return _send_error(client_id, "None of the paths exist: %s" % str(missing), command_id)

	filesystem.reimport_files(existing)

	_log_event("_batch_reimport_textures", "Triggered texture reimport", {"count": existing.size()})
	_send_success(client_id, {
		"paths": existing,
		"missing": missing,
		"reimported": existing.size(),
	}, command_id)

func _create_texture_import_preset(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset_name = params.get("preset_name", "")
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

	# Settings are stored as individual keys, not one dictionary per section.
	var setting_names: Array = []
	for property in ProjectSettings.get_property_list():
		setting_names.append(str(property.get("name", "")))
	for base_path in categories:
		var section := {}
		var prefix: String = base_path + "/"
		for setting_name in setting_names:
			if setting_name.begins_with(prefix):
				section[setting_name.substr(prefix.length())] = ProjectSettings.get_setting(setting_name)
		result[base_path] = section

	_log_event("_list_texture_compression_settings", "Collected compression settings snapshot", {"categories": result.keys()})
	_send_success(client_id, {
		"settings": result,
	}, command_id)
