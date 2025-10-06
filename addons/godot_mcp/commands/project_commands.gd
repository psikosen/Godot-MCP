@tool
class_name MCPProjectCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/project_commands.gd"
const DEFAULT_SYSTEM_SECTION := "project_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
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
        return false  # Command not handled

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

func _scan_directory(dir: DirAccess, path: String, extensions: Array, files: Array) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir():
			var subdir = DirAccess.open("res://" + path + file_name)
			if subdir:
				_scan_directory(subdir, path + file_name + "/", extensions, files)
		else:
			var file_path = path + file_name
			var has_valid_extension = extensions.is_empty()
			
			for ext in extensions:
				if file_name.ends_with(ext):
					has_valid_extension = true
					break
			
			if has_valid_extension:
				files.append("res://" + file_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

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
	var input_map = ProjectSettings.get_setting("input")
	if input_map:
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
                        "name": String(AudioServer.get_bus_name(bus_index)),
                        "channels": AudioServer.get_bus_channels(bus_index),
                        "volume_db": AudioServer.get_bus_volume_db(bus_index),
                        "solo": AudioServer.is_bus_solo(bus_index),
                        "mute": AudioServer.is_bus_mute(bus_index),
                        "bypass_effects": AudioServer.is_bus_bypassing_effects(bus_index),
                        "send": String(AudioServer.get_bus_send(bus_index)),
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

func _list_input_actions(client_id: int, _params: Dictionary, command_id: String) -> void:
        var actions := []
        for action_name in InputMap.get_actions():
                var events := []
                for event in InputMap.action_get_events(action_name):
                        events.append(_serialize_input_event(event))

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

        if InputMap.has_action(action_name):
                if not overwrite_existing:
                        return _send_error(client_id, "Input action %s already exists" % action_name, command_id)
                InputMap.erase_action(action_name)

        InputMap.add_action(action_name, deadzone)

        var added_events := []
        for event_data in events_param:
                if typeof(event_data) != TYPE_DICTIONARY:
                        continue
                var event = _deserialize_input_event(event_data)
                if event:
                        InputMap.action_add_event(action_name, event)
                        added_events.append(_serialize_input_event(event))

        if persistent:
                ProjectSettings.save()

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
                ProjectSettings.save()

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
                ProjectSettings.save()

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
        var event_index = params.get("event_index", -1)
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

        if event_index is int and event_index >= 0 and event_index < events.size():
                removed_event = events[event_index]
        elif typeof(event_data) == TYPE_DICTIONARY:
                for existing_event in events:
                        if _event_matches(existing_event, event_data):
                                removed_event = existing_event
                                break

        if not removed_event:
                return _send_error(client_id, "No matching input event found for action %s" % action_name, command_id)

        InputMap.action_erase_event(action_name, removed_event)

        if persistent:
                ProjectSettings.save()

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
                data["position"] = event.position
                data["global_position"] = event.global_position
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
                data["relative"] = event.relative
                data["velocity"] = event.velocity
                data["pressed_buttons"] = event.button_mask

        return data

func _deserialize_input_event(data: Dictionary) -> InputEvent:
        var type_name: String = data.get("type", "")
        type_name = type_name.strip_edges()

        match type_name.to_lower():
                "inputeventkey", "key":
                        var key_event := InputEventKey.new()
                        key_event.device = data.get("device", -1)
                        key_event.keycode = data.get("keycode", 0)
                        key_event.physical_keycode = data.get("physical_keycode", 0)
                        key_event.unicode = data.get("unicode", 0)
                        key_event.pressed = data.get("pressed", true)
                        key_event.alt_pressed = data.get("alt_pressed", false)
                        key_event.ctrl_pressed = data.get("ctrl_pressed", false)
                        key_event.shift_pressed = data.get("shift_pressed", false)
                        key_event.meta_pressed = data.get("meta_pressed", false)
                        return key_event
                "inputeventmousebutton", "mouse_button":
                        var mouse_button := InputEventMouseButton.new()
                        mouse_button.device = data.get("device", -1)
                        mouse_button.button_index = data.get("button_index", 0)
                        mouse_button.pressed = data.get("pressed", true)
                        mouse_button.double_click = data.get("double_click", false)
                        mouse_button.position = data.get("position", Vector2.ZERO)
                        mouse_button.global_position = data.get("global_position", Vector2.ZERO)
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
                        mouse_motion.relative = data.get("relative", Vector2.ZERO)
                        mouse_motion.velocity = data.get("velocity", Vector2.ZERO)
                        return mouse_motion

        _log("Unsupported input event type", "_deserialize_input_event", {"type": type_name}, true)
        return null

func _event_matches(event: InputEvent, criteria: Dictionary) -> bool:
        var serialized := _serialize_input_event(event)
        for key in criteria.keys():
                if not serialized.has(key):
                        if key == "type":
                                var event_type := String(serialized.get("type", "")).to_lower()
                                var criteria_type := String(criteria[key]).to_lower()
                                if event_type != criteria_type and not event_type.ends_with(criteria_type):
                                        return false
                                continue
                        return false

                if serialized[key] != criteria[key]:
                        return false

        return true

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
        var payload := {
                "filename": LOG_FILENAME,
                "timestamp": Time.get_datetime_string_from_system(true, true),
                "classname": "MCPProjectCommands",
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
