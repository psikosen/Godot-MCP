@tool
class_name MCPXRCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/xr_commands.gd"
const DEFAULT_SYSTEM_SECTION := "xr_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"list_xr_interfaces":
			_list_xr_interfaces(client_id, command_id)
			return true
		"initialize_xr_interface":
			_initialize_xr_interface(client_id, params, command_id)
			return true
		"shutdown_xr_interface":
			_shutdown_xr_interface(client_id, params, command_id)
			return true
		"save_xr_project_settings":
			_save_xr_project_settings(client_id, params, command_id)
			return true
	return false

func _log_event(action: String, message: String, context := {}):
	var entry := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(),
		"classname": "MCPXRCommands",
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

func _list_xr_interfaces(client_id: int, command_id: String) -> void:
	var interfaces := []
	var primary := XRServer.get_primary_interface()

	for idx in range(XRServer.get_interface_count()):
		var xr_interface: XRInterface = XRServer.get_interface(idx)
		if xr_interface == null:
			continue

				var data := {
						"name": String(xr_interface.get_name()),
						"is_initialized": xr_interface.is_initialized(),
						"is_primary": xr_interface == primary,
						"tracking_status": xr_interface.has_method("get_tracking_status") ? xr_interface.get_tracking_status() : "unknown",
						"capabilities": xr_interface.has_method("get_capabilities") ? xr_interface.get_capabilities() : 0,
				}

				if xr_interface.has_method("supports_play_area") and xr_interface.supports_play_area():
						data["play_area"] = xr_interface.has_method("get_play_area") ? xr_interface.get_play_area() : null

		interfaces.append(data)

	_log_event("_list_xr_interfaces", "Enumerated XR interfaces", {"count": interfaces.size()})
	_send_success(client_id, {
		"interfaces": interfaces,
	}, command_id)

func _initialize_xr_interface(client_id: int, params: Dictionary, command_id: String) -> void:
	var interface_name := params.get("interface_name", "")
	var make_primary := params.get("make_primary", false)

	if interface_name.is_empty():
		return _send_error(client_id, "interface_name is required", command_id)

	var xr_interface: XRInterface = XRServer.find_interface(StringName(interface_name))
	if xr_interface == null:
		return _send_error(client_id, "XR interface not found: %s" % interface_name, command_id)

	if not XRServer.initialize_interface(xr_interface):
		return _send_error(client_id, "Failed to initialize XR interface: %s" % interface_name, command_id)

	if make_primary:
		XRServer.set_primary_interface(xr_interface)

	if xr_interface.has_method("start_session") and params.get("start_session", true):
		var session_error := xr_interface.start_session()
		if session_error != OK and session_error != ERR_UNAVAILABLE:
			_log_event("_initialize_xr_interface", "XR session start reported error", {"interface": interface_name, "code": session_error})

	_log_event("_initialize_xr_interface", "Initialized XR interface", {"interface": interface_name, "primary": make_primary})
	_send_success(client_id, {
		"interface": interface_name,
		"primary": make_primary,
	}, command_id)

func _shutdown_xr_interface(client_id: int, params: Dictionary, command_id: String) -> void:
	var interface_name := params.get("interface_name", "")
	if interface_name.is_empty():
		return _send_error(client_id, "interface_name is required", command_id)

	var xr_interface: XRInterface = XRServer.find_interface(StringName(interface_name))
	if xr_interface == null:
		return _send_error(client_id, "XR interface not found: %s" % interface_name, command_id)

	if xr_interface.has_method("end_session"):
		xr_interface.end_session()

	XRServer.shutdown_interface(xr_interface)

	if XRServer.get_primary_interface() == xr_interface:
			XRServer.set_primary_interface(null)

	_log_event("_shutdown_xr_interface", "Shutdown XR interface", {"interface": interface_name})
	_send_success(client_id, {
		"interface": interface_name,
		"status": "shutdown",
	}, command_id)

func _save_xr_project_settings(client_id: int, params: Dictionary, command_id: String) -> void:
	var settings_param = params.get("settings", {})
	var applied := []

	if typeof(settings_param) == TYPE_ARRAY:
		for entry in settings_param:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var path := entry.get("path", "")
			if path.is_empty():
				continue
			ProjectSettings.set_setting(path, entry.get("value"))
			applied.append(path)
	elif typeof(settings_param) == TYPE_DICTIONARY:
		for path in settings_param.keys():
			ProjectSettings.set_setting(String(path), settings_param[path])
			applied.append(String(path))
	else:
		return _send_error(client_id, "settings must be an array of {path, value} or dictionary", command_id)

	if params.get("save", true):
		ProjectSettings.save()

	_log_event("_save_xr_project_settings", "Persisted XR project settings", {"paths": applied})
	_send_success(client_id, {
		"paths": applied,
		"saved": params.get("save", true),
	}, command_id)
