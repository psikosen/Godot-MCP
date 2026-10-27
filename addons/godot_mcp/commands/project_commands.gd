@tool
class_name MCPProjectCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"

const LOG_FILENAME := "addons/godot_mcp/commands/project_commands.gd"
const DEFAULT_SYSTEM_SECTION := "project_commands"
const PROJECT_SETTING_PREFIX_ALLOWLIST := [
	"application/config/",
	"application/run/",
	"display/window/",
	"input/",
	"physics/2d/",
	"physics/3d/",
	"rendering/",
	"audio/",
	"gui/",
]
const PROJECT_SETTING_DENYLIST := [
	"network/remote/",
	"network/ssl/",
	"network/proxy/",
	"autoload/",
	"editor_plugins/",
]

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"delete_project_file":
			_delete_project_file(client_id, params, command_id)
			return true
		"move_project_file":
			_move_project_file(client_id, params, command_id)
			return true
		"check_project":
			_check_project(client_id, params, command_id)
			return true
		"find_unused_files":
			_find_unused_files(client_id, params, command_id)
			return true
		"replace_in_project":
			_replace_in_project(client_id, params, command_id)
			return true
		"get_project_info":
			_get_project_info(client_id, params, command_id)
			return true
		"list_project_files":
			_list_project_files(client_id, params, command_id)
			return true
		"get_project_structure":
			_get_project_structure(client_id, params, command_id)
			return true
		"get_project_settings":
			_get_project_settings(client_id, params, command_id)
			return true
		"list_project_resources":
			_list_project_resources(client_id, params, command_id)
			return true
		"list_input_actions":
			_list_input_actions(client_id, params, command_id)
			return true
		"add_input_action":
			_add_input_action(client_id, params, command_id)
			return true
		"remove_input_action":
			_remove_input_action(client_id, params, command_id)
			return true
		"add_input_event_to_action":
			_add_input_event_to_action(client_id, params, command_id)
			return true
		"remove_input_event_from_action":
			_remove_input_event_from_action(client_id, params, command_id)
			return true
		"list_audio_buses":
			_list_audio_buses(client_id, params, command_id)
			return true
		"configure_audio_bus":
			_configure_audio_bus(client_id, params, command_id)
			return true
		"configure_input_action_context":
			_configure_input_action_context(client_id, params, command_id)
			return true
		"configure_project_setting":
			_configure_project_setting(client_id, params, command_id)
			return true
	return false  # Command not handled

func _configure_project_setting(client_id: int, params: Dictionary, command_id: String) -> void:
	var function_name := "_configure_project_setting"
	var setting_path: String = params.get("setting", "")
	var persist: bool = params.get("persist", false)
	var allow_new: bool = params.get("allow_new", false)
	var log_context := {
		"system_section": "project_settings",
		"line_num": 0,
		"setting": setting_path,
		"persist": persist,
		"allow_new": allow_new,
	}

	if setting_path.is_empty():
		log_context["line_num"] = 0
		_log("Project setting path is required", function_name, log_context, true)
		return _send_error(client_id, "Project setting path is required", command_id)

	if not _is_setting_path_permitted(setting_path):
		log_context["line_num"] = 0
		_log("Requested project setting is outside the supported allowlist", function_name, log_context, true)
		return _send_error(client_id, "Requested project setting is not available for automation", command_id)

	var has_existing := ProjectSettings.has_setting(setting_path)
	if not has_existing and not allow_new:
		log_context["line_num"] = 0
		_log("Project setting does not exist and creation has not been approved", function_name, log_context, true)
		return _send_error(client_id, "Project setting does not exist. Set allow_new=true to create it explicitly.", command_id)

	var new_value = params.get("value", null)
	log_context["line_num"] = 0
	if typeof(new_value) == TYPE_NIL:
		_log("New project setting value must be supplied", function_name, log_context, true)
		return _send_error(client_id, "A value field must be supplied for configure_project_setting", command_id)

	var previous_value = null
	if has_existing:
		previous_value = ProjectSettings.get_setting(setting_path)
	var coerced_value = _coerce_project_setting_value(previous_value, new_value, params)
	var type_hint: String = params.get("type_hint", "")
	if not type_hint.is_empty():
		log_context["type_hint"] = type_hint

	log_context["line_num"] = 0
	log_context["previous_type"] = typeof(previous_value)
	log_context["new_type"] = typeof(coerced_value)

	if typeof(coerced_value) == TYPE_NIL and typeof(previous_value) != TYPE_NIL:
		log_context["line_num"] = 0
		_log("Unable to coerce supplied value to the expected project setting type", function_name, log_context, true)
		return _send_error(client_id, "Unable to coerce supplied value to the expected project setting type", command_id)

	if has_existing and typeof(previous_value) != TYPE_NIL and typeof(coerced_value) != typeof(previous_value):
		log_context["line_num"] = 0
		_log("Project setting type mismatch after coercion", function_name, log_context, true)
		return _send_error(client_id, "Project setting type mismatch after coercion", command_id)

	if has_existing and _are_variants_equal(previous_value, coerced_value):
		log_context["line_num"] = 0
		_log("Project setting already matches requested value", function_name, log_context)
		return _send_success(client_id, {
			"setting": setting_path,
			"previous_value": previous_value,
			"new_value": coerced_value,
			"persisted": false,
			"changed": false,
		}, command_id)

	ProjectSettings.set_setting(setting_path, coerced_value)
	var persisted := false
	if persist:
		var save_err := ProjectSettings.save()
		log_context["line_num"] = 0
		if save_err != OK:
			_log("Failed to persist project settings to disk", function_name, log_context, true)
			return _send_error(client_id, "Failed to persist project settings to disk", command_id)
		persisted = true

	log_context["line_num"] = 0
	log_context["previous_value"] = previous_value
	log_context["new_value"] = coerced_value
	_log("Configured project setting", function_name, log_context)
	_send_success(client_id, {
		"setting": setting_path,
		"previous_value": previous_value,
		"new_value": coerced_value,
		"persisted": persisted,
		"changed": true,
	}, command_id)

func _get_project_info(client_id: int, _params: Dictionary, command_id: String) -> void:
	var project_name = ProjectSettings.get_setting("application/config/name", "Untitled Project")
	var project_version = ProjectSettings.get_setting("application/config/version", "1.0.0")
	var project_path = ProjectSettings.globalize_path("res://")
	
	# Get Godot version info and structure it as expected by the server
	var version_info = Engine.get_version_info()
	print("Raw Godot version info: ", version_info)
	
	# Create structured version object with the expected properties
	var structured_version = {
		"major": version_info.get("major", 0),
		"minor": version_info.get("minor", 0),
		"patch": version_info.get("patch", 0)
	}
	
	_send_success(client_id, {
		"project_name": project_name,
		"project_version": project_version,
		"project_path": project_path,
		"godot_version": structured_version,
				"current_scene": get_tree().edited_scene_root.scene_file_path if get_tree().edited_scene_root else ""
	}, command_id)

func _list_project_files(client_id: int, params: Dictionary, command_id: String) -> void:
	var extensions = params.get("extensions", [])
	var files = []
	
	# Get all files with the specified extensions
	var dir = DirAccess.open("res://")
	if dir:
		_scan_directory(dir, "", extensions, files)
	else:
		return _send_error(client_id, "Failed to open res:// directory", command_id)
	
	_send_success(client_id, {
		"files": files
	}, command_id)

func _get_project_structure(client_id: int, params: Dictionary, command_id: String) -> void:
	var structure = {
		"directories": [],
		"file_counts": {},
		"total_files": 0
	}
	
	var dir = DirAccess.open("res://")
	if dir:
		_analyze_project_structure(dir, "", structure)
	else:
		return _send_error(client_id, "Failed to open res:// directory", command_id)
	
	_send_success(client_id, structure, command_id)

func _analyze_project_structure(dir: DirAccess, path: String, structure: Dictionary) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			var dir_path = path + file_name + "/"
			if _is_ignored_dir(path + file_name, file_name):
				file_name = dir.get_next()
				continue
			structure["directories"].append("res://" + dir_path)
			
			var subdir = DirAccess.open("res://" + dir_path)
			if subdir:
				_analyze_project_structure(subdir, dir_path, structure)
		else:
			structure["total_files"] += 1
			
			var extension = file_name.get_extension()
			if extension in structure["file_counts"]:
				structure["file_counts"][extension] += 1
			else:
				structure["file_counts"][extension] = 1
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _get_project_settings(client_id: int, params: Dictionary, command_id: String) -> void:
	# Get relevant project settings
	var settings = {
		"project_name": ProjectSettings.get_setting("application/config/name", "Untitled Project"),
		"project_version": ProjectSettings.get_setting("application/config/version", "1.0.0"),
		"display": {
			"width": ProjectSettings.get_setting("display/window/size/viewport_width", 1024),
			"height": ProjectSettings.get_setting("display/window/size/viewport_height", 600),
			"mode": ProjectSettings.get_setting("display/window/size/mode", 0),
			"resizable": ProjectSettings.get_setting("display/window/size/resizable", true)
		},
		"physics": {
			"2d": {
				"default_gravity": ProjectSettings.get_setting("physics/2d/default_gravity", 980)
			},
			"3d": {
				"default_gravity": ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
			}
		},
		"rendering": {
			"quality": {
				"msaa": ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_2d", 0)
			}
		},
		"input_map": {}
	}
	
	# Get input mappings
	# Actions are stored as separate "input/<name>" settings; there is no single "input" setting.
	var input_map := {}
	for property in ProjectSettings.get_property_list():
		var key := str(property.get("name", ""))
		if key.begins_with("input/"):
			var action := key.trim_prefix("input/")
			var setting = ProjectSettings.get_setting(key)
			var events: Array = []
			if typeof(setting) == TYPE_DICTIONARY:
				for event in setting.get("events", []):
					if event is InputEvent:
						events.append(_serialize_input_event(event))
			input_map[action] = {"deadzone": (setting.get("deadzone", 0.5) if typeof(setting) == TYPE_DICTIONARY else 0.5), "events": events}
	settings["input_map"] = input_map
	
	_send_success(client_id, settings, command_id)

func _list_project_resources(client_id: int, params: Dictionary, command_id: String) -> void:
	var resources = {
		"scenes": [],
		"scripts": [],
		"textures": [],
		"audio": [],
		"models": [],
		"resources": []
	}

	var dir = DirAccess.open("res://")
	if dir:
		_scan_resources(dir, "", resources)
	else:
		return _send_error(client_id, "Failed to open res:// directory", command_id)

	_send_success(client_id, resources, command_id)

func _list_audio_buses(client_id: int, _params: Dictionary, command_id: String) -> void:
	var bus_count := AudioServer.get_bus_count()
	var buses: Array = []

	for bus_index in range(bus_count):
		var bus_data := {
			"index": bus_index,
			"name": str(AudioServer.get_bus_name(bus_index)),
			"channels": AudioServer.get_bus_channels(bus_index),
			"volume_db": AudioServer.get_bus_volume_db(bus_index),
			"solo": AudioServer.is_bus_solo(bus_index),
			"mute": AudioServer.is_bus_mute(bus_index),
			"bypass_effects": AudioServer.is_bus_bypassing_effects(bus_index),
			"send": str(AudioServer.get_bus_send(bus_index)),
			"effects": []
		}

		var effect_count := AudioServer.get_bus_effect_count(bus_index)
		var effects: Array = []

		for effect_index in range(effect_count):
			var effect := AudioServer.get_bus_effect(bus_index, effect_index)
			var effect_data := {
				"index": effect_index,
				"type": effect.get_class() if effect else "Unknown",
				"enabled": AudioServer.is_bus_effect_enabled(bus_index, effect_index)
			}

			if effect and effect is Resource:
				effect_data["resource_path"] = effect.resource_path
				effect_data["resource_name"] = effect.resource_name

			effects.append(effect_data)

		bus_data["effects"] = effects

		buses.append(bus_data)

	var layout := {
		"bus_count": bus_count,
		"buses": buses
	}

	_log("Enumerated audio buses", "_list_audio_buses", {"bus_count": bus_count})
	_send_success(client_id, layout, command_id)

func _configure_audio_bus(client_id: int, params: Dictionary, command_id: String) -> void:
	var bus_name := str(params.get("bus_name", ""))
	var bus_index := int(params.get("bus_index", -1))

	if not bus_name.is_empty():
		bus_index = AudioServer.get_bus_index(bus_name)
	elif bus_index >= 0 and bus_index < AudioServer.get_bus_count():
		bus_name = AudioServer.get_bus_name(bus_index)

	if bus_index < 0 or bus_index >= AudioServer.get_bus_count():
		var context := {
			"bus_name": bus_name,
			"bus_index": bus_index,
		}
		_log("Invalid audio bus reference", "_configure_audio_bus", context, true)
		_send_error(client_id, "Invalid audio bus reference", command_id)
		return

	var applied_changes := {}
	# Check the send target before changing anything: an unknown bus name was stored and listed.
	if params.has("send"):
		var requested_send := str(params["send"])
		if not requested_send.is_empty() and AudioServer.get_bus_index(requested_send) == -1:
			_send_error(client_id, "Audio bus not found for send: %s" % requested_send, command_id)
			return
	var change_count := 0

	if params.has("new_name"):
		var new_name := str(params["new_name"])
		if new_name.is_empty():
			_log("New audio bus name cannot be empty", "_configure_audio_bus", {"bus_index": bus_index}, true)
			_send_error(client_id, "New audio bus name cannot be empty", command_id)
			return
		AudioServer.set_bus_name(bus_index, new_name)
		applied_changes["name"] = new_name
		change_count += 1
		bus_name = new_name

	if params.has("volume_db"):
		var volume_db := float(params["volume_db"])
		AudioServer.set_bus_volume_db(bus_index, volume_db)
		applied_changes["volume_db"] = volume_db
		change_count += 1

	if params.has("solo"):
		var solo := bool(params["solo"])
		AudioServer.set_bus_solo(bus_index, solo)
		applied_changes["solo"] = solo
		change_count += 1

	if params.has("mute"):
		var mute := bool(params["mute"])
		AudioServer.set_bus_mute(bus_index, mute)
		applied_changes["mute"] = mute
		change_count += 1

	if params.has("bypass_effects"):
		var bypass_effects := bool(params["bypass_effects"])
		AudioServer.set_bus_bypass_effects(bus_index, bypass_effects)
		applied_changes["bypass_effects"] = bypass_effects
		change_count += 1

	if params.has("send"):
		var target_send := str(params["send"])
		AudioServer.set_bus_send(bus_index, target_send)
		applied_changes["send"] = target_send
		change_count += 1

	if params.has("effects"):
		var effects = params["effects"]
		if typeof(effects) != TYPE_ARRAY:
			_log("effects parameter must be an array", "_configure_audio_bus", {"bus_index": bus_index}, true)
			_send_error(client_id, "effects parameter must be an array", command_id)
			return

		var effect_updates: Array = []

		for effect_dict in effects:
			if typeof(effect_dict) != TYPE_DICTIONARY:
				continue

			var effect_index := int(effect_dict.get("index", -1))
			if effect_index < 0 or effect_index >= AudioServer.get_bus_effect_count(bus_index):
				_log("Invalid effect index for audio bus", "_configure_audio_bus", {"bus_index": bus_index, "effect_index": effect_index}, true)
				_send_error(client_id, "Invalid effect index for audio bus", command_id)
				return

			var effect_change := {"index": effect_index}
			var effect_modified := false

			if effect_dict.has("enabled"):
				var enabled := bool(effect_dict["enabled"])
				AudioServer.set_bus_effect_enabled(bus_index, effect_index, enabled)
				effect_change["enabled"] = enabled
				effect_modified = true
				change_count += 1

			if effect_modified:
				effect_updates.append(effect_change)

		if not effect_updates.is_empty():
			applied_changes["effects"] = effect_updates

	if change_count == 0:
		_log("No audio bus configuration changes were requested", "_configure_audio_bus", {"bus_index": bus_index}, true)
		_send_error(client_id, "No audio bus configuration changes were requested", command_id)
		return

	var persist := bool(params.get("persist", false))
	var persisted_path := ""

	if persist:
		var bus_layout := AudioServer.generate_bus_layout()
		var layout_path := str(ProjectSettings.get_setting("audio/bus_layout/path", "res://default_bus_layout.tres"))
		var save_error := _save_resource_contained(bus_layout, layout_path)
		if save_error != OK:
			_log("Failed to persist audio bus layout", "_configure_audio_bus", {
				"bus_index": bus_index,
				"layout_path": layout_path,
				"error_code": save_error
			}, true)
			_send_error(client_id, "Failed to persist audio bus layout", command_id)
			return
		persisted_path = layout_path
		applied_changes["persisted_path"] = persisted_path

	var response := {
		"bus_index": bus_index,
		"bus_name": AudioServer.get_bus_name(bus_index),
		"changes_applied": applied_changes,
	}

	_log("Configured audio bus", "_configure_audio_bus", {
		"bus_index": bus_index,
		"bus_name": response["bus_name"],
		"change_count": change_count
	})
	_send_success(client_id, response, command_id)

func _list_input_actions(client_id: int, _params: Dictionary, command_id: String) -> void:
	var actions := []
	for action_name in InputMap.get_actions():
		var events := []
		for event in InputMap.action_get_events(action_name):
			var serialized: Dictionary = _serialize_input_event(event)
			serialized["text"] = event.as_text()
			events.append(serialized)

		actions.append({
			"name": action_name,
			"deadzone": InputMap.action_get_deadzone(action_name),
			"events": events,
		})

	_log("Listed input actions", "_list_input_actions", {"action_count": actions.size()})
	_send_success(client_id, {
		"actions": actions
	}, command_id)

func _add_input_action(client_id: int, params: Dictionary, command_id: String) -> void:
	var action_name: String = params.get("action_name", "")
	var deadzone: float = params.get("deadzone", 0.5)
	var overwrite_existing: bool = params.get("overwrite", false)
	var persistent: bool = params.get("persistent", true)
	var events_param = params.get("events", [])

	if action_name.is_empty():
		return _send_error(client_id, "Action name cannot be empty", command_id)

	if typeof(events_param) != TYPE_ARRAY:
		return _send_error(client_id, "events must be an array", command_id)

	if InputMap.has_action(action_name) and not overwrite_existing:
		return _send_error(client_id, "Input action %s already exists" % action_name, command_id)

	# Validate every event before touching InputMap so a bad one cannot leave a half-built action.
	var parsed_events := []
	for event_data in events_param:
		if typeof(event_data) != TYPE_DICTIONARY:
			return _send_error(client_id, "Each event definition must be a dictionary", command_id)
		var event = _deserialize_input_event(event_data)
		if not event:
			return _send_error(client_id, "Unsupported input event definition: %s" % str(event_data.get("type", "")), command_id)
		parsed_events.append(event)

	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	InputMap.add_action(action_name, deadzone)

	var added_events := []
	for event in parsed_events:
		InputMap.action_add_event(action_name, event)
		added_events.append(_serialize_input_event(event))

	if persistent:
		_persist_input_action(action_name)

	_log("Added input action", "_add_input_action", {
		"action_name": action_name,
		"deadzone": deadzone,
		"event_count": added_events.size(),
		"persistent": persistent,
	})

	_send_success(client_id, {
		"action_name": action_name,
		"deadzone": deadzone,
		"events": added_events,
		"persistent": persistent,
	}, command_id)

func _remove_input_action(client_id: int, params: Dictionary, command_id: String) -> void:
	var action_name: String = params.get("action_name", "")
	var persistent: bool = params.get("persistent", true)

	if action_name.is_empty():
		return _send_error(client_id, "Action name cannot be empty", command_id)

	if not InputMap.has_action(action_name):
		return _send_error(client_id, "Input action %s does not exist" % action_name, command_id)

	InputMap.erase_action(action_name)

	if persistent:
		_persist_input_action(action_name)

	_log("Removed input action", "_remove_input_action", {
		"action_name": action_name,
		"persistent": persistent,
	})

	_send_success(client_id, {
		"action_name": action_name,
		"persistent": persistent,
	}, command_id)

func _add_input_event_to_action(client_id: int, params: Dictionary, command_id: String) -> void:
	var action_name: String = params.get("action_name", "")
	var event_data = params.get("event", {})
	var persistent: bool = params.get("persistent", true)

	if action_name.is_empty():
		return _send_error(client_id, "Action name cannot be empty", command_id)

	if not InputMap.has_action(action_name):
		return _send_error(client_id, "Input action %s does not exist" % action_name, command_id)

	if typeof(event_data) != TYPE_DICTIONARY:
		return _send_error(client_id, "Event definition must be a dictionary", command_id)

	var event = _deserialize_input_event(event_data)
	if not event:
		return _send_error(client_id, "Unsupported input event definition", command_id)

	InputMap.action_add_event(action_name, event)

	if persistent:
		_persist_input_action(action_name)

	var serialized_event = _serialize_input_event(event)
	_log("Added input event", "_add_input_event_to_action", {
		"action_name": action_name,
		"event": serialized_event,
		"persistent": persistent,
	})

	_send_success(client_id, {
		"action_name": action_name,
		"event": serialized_event,
		"persistent": persistent,
	}, command_id)

func _remove_input_event_from_action(client_id: int, params: Dictionary, command_id: String) -> void:
	var action_name: String = params.get("action_name", "")
	# JSON numbers arrive as float, so accept any number.
	var event_index_raw = params.get("event_index", -1)
	var event_index: int = int(event_index_raw) if (event_index_raw is int or event_index_raw is float) else -1
	var event_data = params.get("event", null)
	var persistent: bool = params.get("persistent", true)

	if action_name.is_empty():
		return _send_error(client_id, "Action name cannot be empty", command_id)

	if not InputMap.has_action(action_name):
		return _send_error(client_id, "Input action %s does not exist" % action_name, command_id)

	var events = InputMap.action_get_events(action_name)
	if events.is_empty():
		return _send_error(client_id, "Input action %s has no events to remove" % action_name, command_id)

	var removed_event: InputEvent = null

	if event_index >= events.size():
		return _send_error(client_id, "event_index %d out of range: action %s has %d event(s)" % [event_index, action_name, events.size()], command_id)

	if event_index >= 0:
		removed_event = events[event_index]
	elif typeof(event_data) == TYPE_DICTIONARY:
		for existing_event in events:
			if _event_matches(existing_event, event_data):
				removed_event = existing_event
				break

	if not removed_event:
		return _send_error(client_id, "No matching input event found for action %s" % action_name, command_id)

	InputMap.action_erase_event(action_name, removed_event)
	if InputMap.action_get_events(action_name).has(removed_event):
		# action_erase_event can miss some event types (e.g. mouse motion); rebuild the list instead.
		var keep := InputMap.action_get_events(action_name).filter(func(e): return e != removed_event)
		InputMap.action_erase_events(action_name)
		for kept_event in keep:
			InputMap.action_add_event(action_name, kept_event)
		if InputMap.action_get_events(action_name).has(removed_event):
			return _send_error(client_id, "Failed to remove input event from action %s" % action_name, command_id)

	if persistent:
		_persist_input_action(action_name)

	var serialized = _serialize_input_event(removed_event)
	_log("Removed input event", "_remove_input_event_from_action", {
		"action_name": action_name,
		"event": serialized,
		"persistent": persistent,
	})

	_send_success(client_id, {
		"action_name": action_name,
		"event": serialized,
		"persistent": persistent,
	}, command_id)

func _scan_resources(dir: DirAccess, path: String, resources: Dictionary) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			var subdir = DirAccess.open("res://" + path + file_name)
			if subdir:
				_scan_resources(subdir, path + file_name + "/", resources)
		else:
			var file_path = "res://" + path + file_name
			
			# Categorize by extension
			if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
				resources["scenes"].append(file_path)
			elif file_name.ends_with(".gd") or file_name.ends_with(".cs"):
				resources["scripts"].append(file_path)
			elif file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
				resources["textures"].append(file_path)
			elif file_name.ends_with(".wav") or file_name.ends_with(".ogg") or file_name.ends_with(".mp3"):
				resources["audio"].append(file_path)
			elif file_name.ends_with(".obj") or file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
				resources["models"].append(file_path)
			elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
				resources["resources"].append(file_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _vec2_dict(v: Vector2) -> Dictionary:
	return {"x": v.x, "y": v.y}

func _serialize_input_event(event: InputEvent) -> Dictionary:
	var data := {
		"type": event.get_class(),
		"device": event.device,
	}

	if event is InputEventKey:
		data["keycode"] = event.keycode
		data["physical_keycode"] = event.physical_keycode
		data["unicode"] = event.unicode
		data["pressed"] = event.pressed
		data["alt_pressed"] = event.alt_pressed
		data["ctrl_pressed"] = event.ctrl_pressed
		data["shift_pressed"] = event.shift_pressed
		data["meta_pressed"] = event.meta_pressed
	elif event is InputEventMouseButton:
		data["button_index"] = event.button_index
		data["pressed"] = event.pressed
		data["double_click"] = event.double_click
		data["position"] = _vec2_dict(event.position)
		data["global_position"] = _vec2_dict(event.global_position)
		data["alt_pressed"] = event.alt_pressed
		data["ctrl_pressed"] = event.ctrl_pressed
		data["shift_pressed"] = event.shift_pressed
		data["meta_pressed"] = event.meta_pressed
	elif event is InputEventJoypadButton:
		data["button_index"] = event.button_index
		data["pressed"] = event.pressed
		data["pressure"] = event.pressure
	elif event is InputEventJoypadMotion:
		data["axis"] = event.axis
		data["axis_value"] = event.axis_value
	elif event is InputEventMouseMotion:
		data["position"] = _vec2_dict(event.position)
		data["global_position"] = _vec2_dict(event.global_position)
		data["relative"] = _vec2_dict(event.relative)
		data["velocity"] = _vec2_dict(event.velocity)
		data["pressed_buttons"] = event.button_mask

	return data

# InputMap is runtime state; project.godot stores actions as "input/<name>" settings, so saving
# without mirroring them wrote nothing. Copy the action into its setting (or clear it), then save.
func _persist_input_action(action_name: String, save: bool = true) -> void:
	var key := "input/" + action_name
	if InputMap.has_action(action_name):
		ProjectSettings.set_setting(key, {
			"deadzone": InputMap.action_get_deadzone(action_name),
			"events": InputMap.action_get_events(action_name),
		})
	else:
		ProjectSettings.set_setting(key, null)
	if save:
		ProjectSettings.save()

# A Key value from a number or a key name ("Space", "A", "Left", "Escape").
func _keycode_from(value) -> int:
	if typeof(value) == TYPE_STRING:
		return OS.find_keycode_from_string(value)
	return int(value)


func _deserialize_input_event(data: Dictionary) -> InputEvent:
	var type_name: String = data.get("type", "")
	type_name = type_name.strip_edges()

	match type_name.to_lower():
		"inputeventkey", "key":
			var key_event := InputEventKey.new()
			key_event.device = data.get("device", -1)
			key_event.keycode = _keycode_from(data.get("keycode", 0))
			key_event.physical_keycode = _keycode_from(data.get("physical_keycode", 0))
			key_event.unicode = data.get("unicode", 0)
			key_event.pressed = data.get("pressed", true)
			key_event.alt_pressed = data.get("alt_pressed", false)
			key_event.ctrl_pressed = data.get("ctrl_pressed", false)
			key_event.shift_pressed = data.get("shift_pressed", false)
			key_event.meta_pressed = data.get("meta_pressed", false)
			return key_event
		"inputeventmousebutton", "mouse_button":
			# JSON sends Vector2 fields as {"x":..,"y":..} or [x, y]; coerce before assigning.
			var mouse_button := InputEventMouseButton.new()
			mouse_button.device = data.get("device", -1)
			mouse_button.button_index = data.get("button_index", 0)
			mouse_button.pressed = data.get("pressed", true)
			mouse_button.double_click = data.get("double_click", false)
			mouse_button.position = _coerce_to_vector2(data.get("position", Vector2.ZERO))
			mouse_button.global_position = _coerce_to_vector2(data.get("global_position", Vector2.ZERO))
			mouse_button.alt_pressed = data.get("alt_pressed", false)
			mouse_button.ctrl_pressed = data.get("ctrl_pressed", false)
			mouse_button.shift_pressed = data.get("shift_pressed", false)
			mouse_button.meta_pressed = data.get("meta_pressed", false)
			return mouse_button
		"inputeventjoypadbutton", "joypad_button":
			var joypad_button := InputEventJoypadButton.new()
			joypad_button.device = data.get("device", -1)
			joypad_button.button_index = data.get("button_index", 0)
			joypad_button.pressed = data.get("pressed", true)
			joypad_button.pressure = data.get("pressure", 0.0)
			return joypad_button
		"inputeventjoypadmotion", "joypad_motion":
			var joypad_motion := InputEventJoypadMotion.new()
			joypad_motion.device = data.get("device", -1)
			joypad_motion.axis = data.get("axis", 0)
			joypad_motion.axis_value = data.get("axis_value", 0.0)
			return joypad_motion
		"inputeventmousemotion", "mouse_motion":
			var mouse_motion := InputEventMouseMotion.new()
			mouse_motion.device = data.get("device", -1)
			mouse_motion.position = _coerce_to_vector2(data.get("position", Vector2.ZERO))
			mouse_motion.global_position = _coerce_to_vector2(data.get("global_position", Vector2.ZERO))
			mouse_motion.relative = _coerce_to_vector2(data.get("relative", Vector2.ZERO))
			mouse_motion.velocity = _coerce_to_vector2(data.get("velocity", Vector2.ZERO))
			return mouse_motion

	_log("Unsupported input event type", "_deserialize_input_event", {"type": type_name}, true)
	return null

func _normalize_event_type(type_name: String) -> String:
	return type_name.strip_edges().to_lower().trim_prefix("inputevent").replace("_", "")

func _event_matches(event: InputEvent, criteria: Dictionary) -> bool:
	var serialized := _serialize_input_event(event)
	for key in criteria.keys():
		if key == "type":
			# Serialized type is the class name; accept aliases like "key" / "mouse_button".
			if _normalize_event_type(str(serialized["type"])) != _normalize_event_type(str(criteria[key])):
				return false
			continue
		if not serialized.has(key):
			return false

		if serialized[key] != criteria[key]:
			return false

	return true

func _configure_input_action_context(client_id: int, params: Dictionary, command_id: String) -> void:
	var context_name: String = params.get("context_name", "")
	var actions_param = params.get("actions", [])
	var persistent: bool = params.get("persistent", true)
	var replace_existing: bool = params.get("replace_existing", true)
	var remove_missing: bool = params.get("remove_missing", false)

	if context_name.is_empty():
		return _send_error(client_id, "Context name cannot be empty", command_id)

	if typeof(actions_param) != TYPE_ARRAY:
		return _send_error(client_id, "Actions must be provided as an array", command_id)

	var context_setting_path := "mcp/input_contexts/%s" % context_name
	var stored_state := {}
	if ProjectSettings.has_setting(context_setting_path):
		var existing_state = ProjectSettings.get_setting(context_setting_path)
		if typeof(existing_state) == TYPE_DICTIONARY:
			stored_state = existing_state.duplicate(true)

	var context_state: Dictionary = stored_state
	var created_actions: Array = []
	var updated_actions: Array = []
	var removed_actions: Array = []
	var events_added: Array = []
	var events_removed: Array = []
	var processed_actions: Dictionary = {}

	# Validate everything first so a bad entry cannot leave InputMap half-modified.
	for action_entry in actions_param:
		if typeof(action_entry) != TYPE_DICTIONARY:
			return _send_error(client_id, "Each action definition must be a dictionary", command_id)
		if str(action_entry.get("name", "")).is_empty():
			return _send_error(client_id, "Action definitions require a name", command_id)
		var check_events = action_entry.get("events", [])
		if typeof(check_events) == TYPE_ARRAY and not action_entry.get("remove", false):
			for check_event in check_events:
				if typeof(check_event) != TYPE_DICTIONARY:
					return _send_error(client_id, "Event definitions must be dictionaries", command_id)
				if not _deserialize_input_event(check_event):
					return _send_error(client_id, "Unsupported input event definition", command_id)

	for action_entry in actions_param:
		if typeof(action_entry) != TYPE_DICTIONARY:
			return _send_error(client_id, "Each action definition must be a dictionary", command_id)

		var action_name: String = action_entry.get("name", "")
		var remove_action: bool = action_entry.get("remove", false)
		var replace_events: bool = action_entry.get("replace_events", replace_existing)
		var events_param = action_entry.get("events", [])

		if action_name.is_empty():
			return _send_error(client_id, "Action definitions require a name", command_id)

		processed_actions[action_name] = true

		if remove_action:
			if InputMap.has_action(action_name):
				InputMap.erase_action(action_name)
				removed_actions.append(action_name)
			context_state.erase(action_name)
			continue

		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name, 0.5)  # same default deadzone as add_input_action
			created_actions.append(action_name)

		var desired_events: Array = []
		if typeof(events_param) == TYPE_ARRAY:
			for event_data in events_param:
				if typeof(event_data) != TYPE_DICTIONARY:
					return _send_error(client_id, "Event definitions must be dictionaries", command_id)
				var event_instance = _deserialize_input_event(event_data)
				if not event_instance:
					return _send_error(client_id, "Unsupported input event definition", command_id)
				desired_events.append({"event": event_instance, "serialized": _serialize_input_event(event_instance)})

		var existing_events: Array = InputMap.action_get_events(action_name)
		var serialized_existing: Array = []
		for existing_event in existing_events:
			serialized_existing.append(_serialize_input_event(existing_event))

		if replace_events:
			for existing_event in existing_events:
				InputMap.action_erase_event(action_name, existing_event)
				events_removed.append({"action": action_name, "event": _serialize_input_event(existing_event)})
			serialized_existing.clear()

		for desired in desired_events:
			var serialized_event: Dictionary = desired["serialized"]
			var already_present := false
			for existing_serialized in serialized_existing:
				if existing_serialized == serialized_event:
					already_present = true
					break
			if already_present:
				continue
			InputMap.action_add_event(action_name, desired["event"])
			serialized_existing.append(serialized_event)
			events_added.append({"action": action_name, "event": serialized_event})

		if not created_actions.has(action_name) and not updated_actions.has(action_name):
			updated_actions.append(action_name)

		context_state[action_name] = {
			"events": serialized_existing,
			"replace_events": replace_events,
		}

	if remove_missing:
		var to_remove: Array = []
		for existing_action in context_state.keys():
			if not processed_actions.has(existing_action):
				to_remove.append(existing_action)

		for action_name in to_remove:
			if InputMap.has_action(action_name):
				InputMap.erase_action(action_name)
				removed_actions.append(action_name)
			context_state.erase(action_name)

	if persistent:
		for persisted_name in processed_actions.keys():
			_persist_input_action(str(persisted_name), false)
		for persisted_name in removed_actions:
			_persist_input_action(str(persisted_name), false)
		ProjectSettings.set_setting(context_setting_path, context_state)
		ProjectSettings.save()

	var response := {
		"context_name": context_name,
		"created_actions": created_actions,
		"updated_actions": updated_actions,
		"removed_actions": removed_actions,
		"events_added": events_added,
		"events_removed": events_removed,
		"persistent": persistent,
		"remove_missing": remove_missing,
	}

	_log("Configured input action context", "_configure_input_action_context", {
		"context_name": context_name,
		"created": created_actions,
		"updated": updated_actions,
		"removed": removed_actions,
		"events_added": events_added.size(),
		"events_removed": events_removed.size(),
		"persistent": persistent,
		"system_section": "project_input",
		"line_num": 0,
	})

	_send_success(client_id, response, command_id)


func _is_setting_path_permitted(setting_path: String) -> bool:
	for denied in PROJECT_SETTING_DENYLIST:
		if setting_path.begins_with(denied):
			return false

	for allowed in PROJECT_SETTING_PREFIX_ALLOWLIST:
		if setting_path.begins_with(allowed):
			return true

	return false


func _coerce_project_setting_value(previous_value, new_value, params: Dictionary):
	var expected_type := typeof(previous_value)
	var provided_type := typeof(new_value)
	var type_hint: String = params.get("type_hint", "")

	if typeof(previous_value) == TYPE_NIL:
		if not type_hint.is_empty():
			return _coerce_with_hint(new_value, type_hint)
		return new_value

	if provided_type == expected_type:
		return new_value

	if provided_type == TYPE_STRING and type_hint.is_empty():
		var parsed_value = _parse_property_value(new_value)
		if typeof(parsed_value) == expected_type:
			return parsed_value
		if expected_type == TYPE_INT and new_value.is_valid_int():
			return new_value.to_int()
		if expected_type == TYPE_FLOAT and new_value.is_valid_float():
			return new_value.to_float()
		if expected_type == TYPE_BOOL:
			var lowered = new_value.to_lower()
			if lowered in ["true", "1", "yes", "on"]:
				return true
			if lowered in ["false", "0", "no", "off"]:
				return false

	if not type_hint.is_empty():
		var hinted = _coerce_with_hint(new_value, type_hint)
		if typeof(hinted) != TYPE_NIL and (typeof(hinted) == expected_type or type_hint in ["array", "dictionary"]):
			return hinted

	if expected_type == TYPE_INT and provided_type == TYPE_FLOAT:
		return int(new_value)
	if expected_type == TYPE_FLOAT and provided_type in [TYPE_INT, TYPE_FLOAT]:
		return float(new_value)
	if expected_type == TYPE_BOOL and provided_type in [TYPE_INT, TYPE_FLOAT]:
		return abs(float(new_value)) > 0.0
	if expected_type == TYPE_PACKED_STRING_ARRAY and provided_type == TYPE_ARRAY:
		var psa := PackedStringArray()
		for entry in new_value:
			psa.append(str(entry))
		return psa
	if expected_type == TYPE_ARRAY and provided_type == TYPE_PACKED_STRING_ARRAY:
		return new_value
	if expected_type == TYPE_STRING:
		return str(new_value)

	return new_value


func _coerce_with_hint(new_value, type_hint: String):
	match type_hint:
		"int":
			return int(new_value)
		"float":
			return float(new_value)
		"bool":
			if typeof(new_value) == TYPE_STRING:
				var lowered = new_value.to_lower()
				if lowered in ["true", "1", "yes", "on"]:
					return true
				if lowered in ["false", "0", "no", "off"]:
					return false
			if typeof(new_value) in [TYPE_INT, TYPE_FLOAT]:
				return abs(float(new_value)) > 0.0
			return bool(new_value)
		"string":
			return str(new_value)
		"array":
			if typeof(new_value) == TYPE_ARRAY:
				return new_value
			if typeof(new_value) == TYPE_PACKED_STRING_ARRAY:
				return Array(new_value)
			if typeof(new_value) == TYPE_STRING:
				var parsed = _parse_property_value(new_value)
				if typeof(parsed) == TYPE_ARRAY:
					return parsed
			return null
		"dictionary":
			if typeof(new_value) == TYPE_DICTIONARY:
				return new_value
			if typeof(new_value) == TYPE_STRING:
				var parsed_dict = _parse_property_value(new_value)
				if typeof(parsed_dict) == TYPE_DICTIONARY:
					return parsed_dict
			return null
	return new_value


func _are_variants_equal(a, b) -> bool:
	if typeof(a) != typeof(b):
		return false
	if typeof(a) == TYPE_FLOAT:
		return is_equal_approx(float(a), float(b))
	if typeof(a) in [TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY]:
		return Array(a) == Array(b)
	if typeof(a) == TYPE_DICTIONARY:
		return Dictionary(a) == Dictionary(b)
	return a == b


func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPProjectCommands",
		"function": function_name,
		"system_section": extra.get("system_section", DEFAULT_SYSTEM_SECTION),
		"line_num": extra.get("line_num", 0),
"error": message if is_error else "",
		"db_phase": extra.get("db_phase", "none"),
		"method": extra.get("method", "NONE"),
		"message": message,
	}

	for key in extra.keys():
		if not payload.has(key):
			payload[key] = extra[key]

	print(JSON.stringify(payload))



# Moves one project file (plus its .import/.uid sidecars) to the system Trash, so it can be
# restored. Reports the files that still refer to it, since Godot does not fix those up.
func _delete_project_file(client_id: int, params: Dictionary, command_id: String) -> void:
	var requested := str(params.get("path", ""))
	var path := _contained_res_path(requested)
	if path.is_empty():
		return _send_error(client_id, "Path must stay inside the project (res://): %s" % requested, command_id)
	if _is_protected_path(path):
		return _send_error(client_id, "%s is protected and cannot be deleted" % path, command_id)
	if DirAccess.dir_exists_absolute(path):
		return _send_error(client_id, "%s is a folder; delete the files in it one at a time" % path, command_id)
	if not FileAccess.file_exists(path):
		return _send_error(client_id, "File not found: %s" % path, command_id)
	var edited := EditorInterface.get_edited_scene_root()
	if edited and edited.scene_file_path == path:
		return _send_error(client_id, "%s is the open scene; open another scene first" % path, command_id)

	var needles: Array = [path]
	var uid: int = ResourceLoader.get_resource_uid(path)
	if uid != ResourceUID.INVALID_ID:
		needles.append(ResourceUID.id_to_text(uid))
	var candidates: Array = []
	_scan_directory(DirAccess.open("res://"), "", [".tscn", ".tres", ".gd", ".gdshader", ".cfg", "project.godot"], candidates)
	var referenced_by: Array = []
	for candidate in candidates:
		if candidate == path or referenced_by.size() >= 20:
			continue
		var text := FileAccess.get_file_as_string(candidate)
		for needle in needles:
			if text.contains(needle):
				referenced_by.append(candidate)
				break

	var trashed: Array = []
	for file_path in [path, path + ".import", path + ".uid"]:
		if FileAccess.file_exists(file_path):
			var err := OS.move_to_trash(ProjectSettings.globalize_path(file_path))
			if err != OK:
				return _send_error(client_id, "Could not move %s to the Trash: %s (moved so far: %s)" % [file_path, error_string(err), trashed], command_id)
			trashed.append(file_path)
	EditorInterface.get_resource_filesystem().scan()
	_send_success(client_id, {
		"path": path,
		"trashed": trashed,
		"still_referenced_by": referenced_by,
	}, command_id)


# Moves or renames one file with its .import/.uid sidecars, then rewrites quoted references to the
# old path in scenes, resources, scripts and project.godot (UIDs alone miss preload("res://...")).
func _move_project_file(client_id: int, params: Dictionary, command_id: String) -> void:
	var from := _contained_res_path(str(params.get("from_path", "")))
	var to := _contained_res_path(str(params.get("to_path", "")))
	if from.is_empty() or to.is_empty():
		return _send_error(client_id, "from_path and to_path must stay inside the project (res://)", command_id)
	if _is_protected_path(from) or _is_protected_path(to):
		return _send_error(client_id, "MCP-critical paths cannot be moved: %s -> %s" % [from, to], command_id)
	if DirAccess.dir_exists_absolute(from):
		return _send_error(client_id, "%s is a folder; move the files in it one at a time" % from, command_id)
	if not FileAccess.file_exists(from):
		return _send_error(client_id, "File not found: %s" % from, command_id)
	if FileAccess.file_exists(to) or DirAccess.dir_exists_absolute(to):
		return _send_error(client_id, "%s already exists" % to, command_id)
	if from.get_extension().to_lower() != to.get_extension().to_lower():
		return _send_error(client_id, "Keep the file extension (.%s); Godot picks the loader from it" % from.get_extension(), command_id)
	var edited := EditorInterface.get_edited_scene_root()
	if edited and edited.scene_file_path == from:
		return _send_error(client_id, "%s is the open scene; open another scene first" % from, command_id)

	DirAccess.make_dir_recursive_absolute(to.get_base_dir())
	var uid: int = ResourceLoader.get_resource_uid(from)
	var moved: Array = []
	for suffix in ["", ".import", ".uid"]:
		if FileAccess.file_exists(from + suffix):
			var err := DirAccess.rename_absolute(from + suffix, to + suffix)
			if err != OK:
				return _send_error(client_id, "Could not move %s: %s (moved so far: %s)" % [from + suffix, error_string(err), moved], command_id)
			moved.append(to + suffix)

	var candidates: Array = []
	_scan_directory(DirAccess.open("res://"), "", [".tscn", ".tres", ".gd", ".gdshader", ".cfg", ".import", "project.godot"], candidates)
	var updated: Array = []
	for candidate in candidates:
		var text := FileAccess.get_file_as_string(candidate)
		# A reference is the full path right before a closing quote: path="...", preload('...').
		var rewritten := text.replace(from + "\"", to + "\"").replace(from + "'", to + "'")
		if rewritten == text:
			continue
		var file := FileAccess.open(candidate, FileAccess.WRITE)
		if file == null:
			continue
		file.store_string(rewritten)
		updated.append(candidate)
	if uid != ResourceUID.INVALID_ID:
		ResourceUID.set_id(uid, to)
	if ResourceLoader.has_cached(from):
		ResourceLoader.load(from).take_over_path(to)
	EditorInterface.get_resource_filesystem().scan()
	_send_success(client_id, {"from_path": from, "to_path": to, "moved": moved, "updated_references": updated}, command_id)


const ASSET_EXTENSIONS := [".png", ".jpg", ".jpeg", ".webp", ".svg", ".wav", ".ogg", ".mp3", ".ttf", ".otf", ".woff2",
	".glb", ".gltf", ".obj", ".fbx", ".tscn", ".tres", ".gd", ".gdshader"]
const REFERENCE_EXTENSIONS := [".tscn", ".tres", ".gd", ".gdshader", ".cfg", "project.godot"]


func _project_files(extensions: Array, include_addons: bool) -> Array:
	var files: Array = []
	_scan_directory(DirAccess.open("res://"), "", extensions, files)
	return files if include_addons else files.filter(func(path): return not str(path).begins_with("res://addons/"))


# One pass over the project for what usually breaks a game: missing files behind scene/resource
# links, scripts that do not compile, input actions scripts use but the project does not define.
func _check_project(client_id: int, params: Dictionary, command_id: String) -> void:
	var include_addons: bool = params.get("include_addons", false)
	var issues: Array = []
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.is_empty():
		issues.append("warning: project.godot: no main scene (configure_game_settings main_scene)")
	elif not _resource_exists(main_scene):
		issues.append("error: project.godot: main scene %s is missing" % main_scene)
	for info in ProjectSettings.get_property_list():
		var setting := str(info["name"])
		if setting.begins_with("autoload/"):
			var target := str(ProjectSettings.get_setting(setting)).trim_prefix("*")
			if not _resource_exists(target):
				issues.append("error: project.godot: autoload %s points to missing %s" % [setting.trim_prefix("autoload/"), target])

	var link := RegEx.create_from_string("\\[ext_resource[^\\]]*?(?:uid=\"(uid://[^\"]+)\")?[^\\]]*?path=\"([^\"]+)\"")
	for path in _project_files([".tscn", ".tres"], include_addons):
		for found in link.search_all(FileAccess.get_file_as_string(path)):
			var target := found.get_string(2)
			var uid := found.get_string(1)
			if not _resource_exists(target) and not (not uid.is_empty() and _resource_exists(uid)):
				issues.append("error: %s: links to missing %s" % [path, target])

	var action_call := RegEx.create_from_string("(?:is_action_pressed|is_action_just_pressed|is_action_just_released|is_action_released|get_action_strength|get_action_raw_strength|get_axis|get_vector|action_press|action_release|is_action)\\(([^)]*)\\)")
	var quoted := RegEx.create_from_string("[\"']([A-Za-z0-9_]+)[\"']")
	var missing_actions := {}
	for path in _project_files([".gd"], include_addons):
		var compile_error := _gdscript_compile_error(path, false)
		if not compile_error.is_empty():
			issues.append("error: %s: does not compile: %s" % [path, compile_error])
		for action_match in action_call.search_all(FileAccess.get_file_as_string(path)):
			for name_match in quoted.search_all(action_match.get_string(1)):
				var action := name_match.get_string(1)
				if not action.begins_with("ui_") and not ProjectSettings.has_setting("input/" + action):
					missing_actions[action] = missing_actions.get(action, []) + [path.get_file()]
	for action in missing_actions:
		issues.append("error: input action \"%s\" is used in %s but not defined (add_input_action)" % [action, ", ".join(PackedStringArray(missing_actions[action]))])
	var errors := issues.filter(func(issue): return str(issue).begins_with("error"))
	_send_success(client_id, {"issues": issues.slice(0, 200), "error_count": errors.size(), "warning_count": issues.size() - errors.size()}, command_id)


func _resource_exists(path: String) -> bool:
	if path.begins_with("uid://"):
		var id := ResourceUID.text_to_id(path)
		return ResourceUID.has_id(id) and FileAccess.file_exists(ResourceUID.get_id_path(id))
	return FileAccess.file_exists(path)


# Files nothing points to: no scene, resource, script or project setting names their path or UID.
# Scripts that build paths at runtime ("res://levels/%d.tscn") cannot be seen, so review the list.
func _find_unused_files(client_id: int, params: Dictionary, command_id: String) -> void:
	var include_addons: bool = params.get("include_addons", false)
	var texts := {}
	for path in _project_files(REFERENCE_EXTENSIONS, true):
		texts[path] = FileAccess.get_file_as_string(path)
	var unused: Array = []
	var total_bytes := 0
	var entry_point := RegEx.create_from_string("(?m)^extends\\s+(SceneTree|MainLoop|EditorScript)\\b")
	for path in _project_files(ASSET_EXTENSIONS, include_addons):
		# Test and tool scripts run with --script or from the editor, not through references.
		if path.ends_with(".gd") and entry_point.search(FileAccess.get_file_as_string(path)) != null:
			continue
		var needles: Array = [path]
		var uid: int = ResourceLoader.get_resource_uid(path)
		if uid != ResourceUID.INVALID_ID:
			needles.append(ResourceUID.id_to_text(uid))
		var used := false
		for other in texts:
			if other == path:
				continue
			for needle in needles:
				if texts[other].contains(needle):
					used = true
					break
			if used:
				break
		if not used:
			var bytes := FileAccess.get_file_as_bytes(path).size()
			total_bytes += bytes
			unused.append("%s (%s)" % [path, String.humanize_size(bytes)])
	_send_success(client_id, {"unused": unused, "total": String.humanize_size(total_bytes)}, command_id)


# Find and replace across project text files. Preview by default (dry_run); applying it
# compile-checks every changed script.
func _replace_in_project(client_id: int, params: Dictionary, command_id: String) -> void:
	var find := str(params.get("find", ""))
	if find.is_empty():
		return _send_error(client_id, "find cannot be empty", command_id)
	var replace := str(params.get("replace", ""))
	var dry_run: bool = params.get("dry_run", true)
	var regex: RegEx = null
	if params.get("regex", false):
		regex = RegEx.create_from_string(find)
		if not regex.is_valid():
			return _send_error(client_id, "Invalid regular expression: %s" % find, command_id)
	var extensions: Array = params.get("extensions", [".gd"])
	var changes: Array = []
	var changed_scripts: Array = []
	for path in _project_files(extensions, params.get("include_addons", false)):
		if _is_protected_path(path):
			continue
		var text := FileAccess.get_file_as_string(path)
		var count: int = regex.search_all(text).size() if regex else text.count(find)
		if count == 0:
			continue
		changes.append("%s: %d" % [path, count])
		if dry_run:
			continue
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			return _send_error(client_id, "Failed to write %s (changed so far: %s)" % [path, changes], command_id)
		file.store_string(regex.sub(text, replace, true) if regex else text.replace(find, replace))
		file = null
		if path.ends_with(".gd"):
			changed_scripts.append(path)
	var compile_errors: Array = []
	for path in changed_scripts:
		var compile_error := _gdscript_compile_error(path)
		if not compile_error.is_empty():
			compile_errors.append("%s: %s" % [path, compile_error])
	if not dry_run and not changes.is_empty():
		EditorInterface.get_resource_filesystem().scan()
	_send_success(client_id, {"dry_run": dry_run, "files": changes, "compile_errors": compile_errors}, command_id)
