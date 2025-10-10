@tool
class_name MCPAnimationCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/animation_commands.gd"
const DEFAULT_SYSTEM_SECTION := "animation_commands"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
        match command_type:
                "list_animation_players":
                        _list_animation_players(client_id, params, command_id)
                        return true
                "describe_animation_tracks":
                        _describe_animation_tracks(client_id, params, command_id)
                        return true
                "describe_animation_state_machines":
                        _describe_animation_state_machines(client_id, params, command_id)
                        return true
        return false

func _list_animation_players(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_list_animation_players"
        var include_tracks := params.get("include_tracks", false)
        var include_keys := params.get("include_keys", false)
        var node_path := params.get("node_path", "")
        var root := _resolve_search_root(node_path)
        if root == null:
                _log("Unable to resolve animation search root", function_name, {
                        "requested_path": node_path,
                        "system_section": "animation_player_enumeration",
                }, true)
                return _send_error(client_id, "Unable to resolve animation search root", command_id)

        var players: Array = []
        var queue: Array = [root]
        var visited_paths := {}
        while not queue.is_empty():
                var current: Node = queue.pop_front()
                if current == null:
                        continue

                var serialized_path := _path_to_string(current)
                if visited_paths.has(serialized_path):
                        continue
                visited_paths[serialized_path] = true

                if current is AnimationPlayer:
                        players.append(_serialize_animation_player(current, include_tracks, include_keys))
                for child in current.get_children():
                        if child is Node:
                                queue.append(child)

        _log("Enumerated AnimationPlayer nodes", function_name, {
                "count": players.size(),
                "include_tracks": include_tracks,
                "include_keys": include_keys,
                "root_path": node_path,
        })

        _send_success(client_id, {
                "players": players,
                "include_tracks": include_tracks,
                "include_keys": include_keys,
        }, command_id)

func _describe_animation_tracks(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_describe_animation_tracks"
        var node_path := params.get("node_path", "")
        var include_keys := params.get("include_keys", true)
        var include_tracks := true
        var target_root := _resolve_search_root(node_path)
        if target_root == null:
                _log("Unable to resolve animation track root", function_name, {
                        "requested_path": node_path,
                        "system_section": "animation_track_description",
                }, true)
                return _send_error(client_id, "Unable to resolve animation track root", command_id)

        var payload := _collect_animation_players(target_root, include_tracks, include_keys)
        _log("Described animation tracks", function_name, {
                "player_count": payload.size(),
                "include_keys": include_keys,
                "root_path": node_path,
        })

        _send_success(client_id, {
                "players": payload,
                "include_keys": include_keys,
        }, command_id)

func _describe_animation_state_machines(client_id: int, params: Dictionary, command_id: String) -> void:
        var function_name := "_describe_animation_state_machines"
        var node_path := params.get("node_path", "")
        var include_nested := params.get("include_nested", true)
        var include_graph := params.get("include_graph", true)
        var include_transitions := params.get("include_transitions", true)
        var root := _resolve_search_root(node_path)
        if root == null:
                _log("Unable to resolve animation tree root", function_name, {
                        "requested_path": node_path,
                        "system_section": "animation_state_machine_description",
                }, true)
                return _send_error(client_id, "Unable to resolve animation tree root", command_id)

        var state_machines: Array = []
        var queue: Array = [root]
        var visited_paths := {}
        while not queue.is_empty():
                var current: Node = queue.pop_front()
                if current == null:
                        continue

                var serialized_path := _path_to_string(current)
                if visited_paths.has(serialized_path):
                        continue
                visited_paths[serialized_path] = true

                if current is AnimationTree:
                        state_machines.append(_serialize_animation_tree(current, include_nested, include_graph, include_transitions))
                for child in current.get_children():
                        if child is Node:
                                queue.append(child)

        _log("Described animation state machines", function_name, {
                "tree_count": state_machines.size(),
                "include_nested": include_nested,
                "include_graph": include_graph,
                "include_transitions": include_transitions,
                "root_path": node_path,
        })

        _send_success(client_id, {
                "animation_trees": state_machines,
                "include_nested": include_nested,
                "include_graph": include_graph,
                "include_transitions": include_transitions,
        }, command_id)

func _collect_animation_players(root: Node, include_tracks: bool, include_keys: bool) -> Array:
        var players: Array = []
        var queue: Array = [root]
        var visited_paths := {}
        while not queue.is_empty():
                var current: Node = queue.pop_front()
                if current == null:
                        continue

                var serialized_path := _path_to_string(current)
                if visited_paths.has(serialized_path):
                        continue
                visited_paths[serialized_path] = true

                if current is AnimationPlayer:
                        players.append(_serialize_animation_player(current, include_tracks, include_keys))
                for child in current.get_children():
                        if child is Node:
                                queue.append(child)
        return players

func _serialize_animation_player(player: AnimationPlayer, include_tracks: bool, include_keys: bool) -> Dictionary:
        var animations: Array = []
        for animation_name in player.get_animation_list():
                var animation: Animation = player.get_animation(animation_name)
                if animation == null:
                        continue

                var entry := {
                        "name": String(animation_name),
                        "length": animation.length,
                        "loop_mode": animation.loop_mode,
                        "tracks": [],
                        "track_count": animation.get_track_count(),
                }

                if include_tracks:
                        entry["tracks"] = _serialize_animation_tracks(animation, include_keys)

                animations.append(entry)

        return {
                "node_path": _path_to_string(player),
                "name": String(player.name),
                "autoplay": player.autoplay,
                "process_mode": player.process_mode,
                "playback_speed": player.playback_speed,
                "animation_count": animations.size(),
                "animations": animations,
        }

func _serialize_animation_tracks(animation: Animation, include_keys: bool) -> Array:
        var tracks: Array = []
        var track_count := animation.get_track_count()
        for track_index in track_count:
                var track_type := animation.track_get_type(track_index)
                var track := {
                        "index": track_index,
                        "type": _animation_track_type_to_string(track_type),
                        "path": _serialize_node_path(animation.track_get_path(track_index)),
                        "key_count": animation.track_get_key_count(track_index),
                        "loop_wrap": animation.track_get_wrap_mode(track_index),
                }

                if animation.has_method("track_is_enabled"):
                        track["enabled"] = animation.track_is_enabled(track_index)

                if include_keys:
                        var keys: Array = []
                        for key_index in animation.track_get_key_count(track_index):
                                var key_data := {
                                        "index": key_index,
                                        "time": animation.track_get_key_time(track_index, key_index),
                                        "transition": animation.track_get_key_transition(track_index, key_index),
                                        "value": _serialize_variant(animation.track_get_key_value(track_index, key_index)),
                                }
                                if animation.has_method("track_get_key_value_tangent"): # Godot 4 specific tangents
                                        key_data["in_tangent"] = _serialize_variant(animation.track_get_key_value_tangent(track_index, key_index, true))
                                        key_data["out_tangent"] = _serialize_variant(animation.track_get_key_value_tangent(track_index, key_index, false))
                                keys.append(key_data)
                        track["keys"] = keys

                tracks.append(track)
        return tracks

func _serialize_animation_tree(tree: AnimationTree, include_nested: bool, include_graph: bool, include_transitions: bool) -> Dictionary:
        var parameters_value = {}
        if tree.has_method("get"):
                parameters_value = tree.get("parameters")
        var anim_player_path = ""
        if tree.has_method("get"):
                anim_player_path = _serialize_node_path(tree.get("anim_player"))

        var data := {
                "node_path": _path_to_string(tree),
                "name": String(tree.name),
                "active": tree.active,
                "process_mode": tree.process_mode,
                "parameters": _serialize_variant(parameters_value),
                "animation_player": anim_player_path,
                "root_type": tree.tree_root.get_class() if tree.tree_root else "",
                "state_machines": [],
        }

        if tree.tree_root and tree.tree_root is AnimationNodeStateMachine:
                data["state_machines"].append(_serialize_state_machine(tree.tree_root, "root", include_nested, include_graph, include_transitions))
        elif tree.tree_root:
                data["state_machines"] = _collect_nested_state_machines(tree.tree_root, include_nested, include_graph, include_transitions)

        return data

func _collect_nested_state_machines(node: AnimationNode, include_nested: bool, include_graph: bool, include_transitions: bool) -> Array:
        var machines: Array = []
        if node is AnimationNodeStateMachine:
                machines.append(_serialize_state_machine(node, node.resource_name, include_nested, include_graph, include_transitions))
        if not include_nested:
                return machines

        if node.has_method("_get_child_nodes"):
                var children = node.call("_get_child_nodes")
                if typeof(children) == TYPE_DICTIONARY:
                        for child_name in children.keys():
                                var child_node: AnimationNode = children[child_name]
                                if child_node:
                                        machines += _collect_nested_state_machines(child_node, include_nested, include_graph, include_transitions)
        return machines

func _serialize_state_machine(state_machine: AnimationNodeStateMachine, label, include_nested: bool, include_graph: bool, include_transitions: bool) -> Dictionary:
        var machine := {
                "name": String(label if typeof(label) == TYPE_STRING and not String(label).is_empty() else state_machine.resource_name),
                "start_node": String(state_machine.get("start_node")) if state_machine else "",
                "states": [],
                "transitions": [],
                "allow_transition_to_self": state_machine.is_allow_transition_to_self() if state_machine.has_method("is_allow_transition_to_self") else false,
        }

        var state_names := []
        if state_machine.has_method("get_node_list"):
                state_names = state_machine.get_node_list()

        for state_name in state_names:
                var animation_node: AnimationNode = state_machine.get_node(state_name)
                if animation_node == null:
                        continue

                var state_entry := {
                        "name": String(state_name),
                        "type": animation_node.get_class(),
                }

                if include_graph:
                        state_entry["graph_position"] = _serialize_variant(state_machine.get_node_position(state_name))

                if animation_node is AnimationNodeAnimation:
                        state_entry["animation"] = animation_node.animation
                elif animation_node is AnimationNodeBlendSpace1D:
                        state_entry["blend_space_type"] = "BlendSpace1D"
                elif animation_node is AnimationNodeBlendSpace2D:
                        state_entry["blend_space_type"] = "BlendSpace2D"
                elif animation_node is AnimationNodeBlendTree:
                        state_entry["blend_tree"] = _serialize_variant(animation_node.get("nodes"))

                if include_nested and animation_node is AnimationNodeStateMachine:
                        state_entry["sub_state_machine"] = _serialize_state_machine(animation_node, state_name, include_nested, include_graph, include_transitions)

                machine["states"].append(state_entry)

        if include_transitions and state_machine.has_method("get_transition_count"):
                var transition_count := state_machine.get_transition_count()
                for transition_index in transition_count:
                        var transition_info := {
                                "index": transition_index,
                                "from": String(state_machine.get_transition_from(transition_index)),
                                "to": String(state_machine.get_transition_to(transition_index)),
                        }
                        if state_machine.has_method("get_transition"):
                                var transition_resource: AnimationNodeStateMachineTransition = state_machine.get_transition(transition_index)
                                if transition_resource:
                                        transition_info["properties"] = _serialize_resource_properties(transition_resource)
                        machine["transitions"].append(transition_info)

        return machine

func _serialize_resource_properties(resource: Resource) -> Dictionary:
        if resource == null:
                return {}
        var data := {}
        for property_info in resource.get_property_list():
                if typeof(property_info) != TYPE_DICTIONARY or not property_info.has("name"):
                        continue
                var property_name: String = property_info["name"]
                if ["resource_path", "script", "resource_local_to_scene", "resource_name"].has(property_name):
                        continue
                var usage := property_info.get("usage", PROPERTY_USAGE_DEFAULT)
                if (usage & PROPERTY_USAGE_STORAGE) == 0 and (usage & PROPERTY_USAGE_EDITOR) == 0:
                        continue
                data[property_name] = _serialize_variant(resource.get(property_name))
        return data

func _resolve_search_root(node_path: String) -> Node:
        var plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
        if not plugin:
                return null
        var editor_interface = plugin.get_editor_interface()
        var edited_scene_root = editor_interface.get_edited_scene_root()
        if edited_scene_root == null:
                        return null
        if node_path.is_empty():
                return edited_scene_root
        var node := _get_editor_node(node_path)
        return node

func _animation_track_type_to_string(track_type: int) -> String:
        match track_type:
                Animation.TYPE_VALUE:
                        return "value"
                Animation.TYPE_TRANSFORM2D:
                        return "transform_2d"
                Animation.TYPE_TRANSFORM3D:
                        return "transform_3d"
                Animation.TYPE_BLEND_SHAPE:
                        return "blend_shape"
                Animation.TYPE_METHOD:
                        return "method"
                Animation.TYPE_BEZIER:
                        return "bezier"
                Animation.TYPE_AUDIO:
                        return "audio"
                Animation.TYPE_ANIMATION:
                        return "animation"
                Animation.TYPE_SCALE_3D:
                        return "scale_3d"
                _:
                        return "unknown"

func _serialize_node_path(path) -> String:
        if typeof(path) == TYPE_NODE_PATH:
                return String(path)
        if typeof(path) == TYPE_STRING:
                return path
        return String(path)

func _serialize_variant(value):
        match typeof(value):
                TYPE_NIL:
                        return null
                TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
                        return value
                TYPE_VECTOR2:
                        return {"x": value.x, "y": value.y}
                TYPE_VECTOR3:
                        return {"x": value.x, "y": value.y, "z": value.z}
                TYPE_VECTOR2I:
                        return {"x": value.x, "y": value.y}
                TYPE_VECTOR3I:
                        return {"x": value.x, "y": value.y, "z": value.z}
                TYPE_QUAT:
                        return {"x": value.x, "y": value.y, "z": value.z, "w": value.w}
                TYPE_BASIS:
                        return {"x": _serialize_variant(value.x), "y": _serialize_variant(value.y), "z": _serialize_variant(value.z)}
                TYPE_TRANSFORM3D:
                        return {"basis": _serialize_variant(value.basis), "origin": _serialize_variant(value.origin)}
                TYPE_TRANSFORM2D:
                        return {"x": _serialize_variant(value.x), "y": _serialize_variant(value.y), "origin": _serialize_variant(value.origin)}
                TYPE_COLOR:
                        return {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
                TYPE_ARRAY:
                        var result: Array = []
                        for element in value:
                                result.append(_serialize_variant(element))
                        return result
                TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY:
                        var packed_result: Array = []
                        for element in value:
                                packed_result.append(_serialize_variant(element))
                        return packed_result
                TYPE_DICTIONARY:
                        var dict_result := {}
                        for key in value.keys():
                                dict_result[String(key)] = _serialize_variant(value[key])
                        return dict_result
                TYPE_OBJECT:
                        if value is Node or value is Resource:
                                if value.has_method("serialize"):
                                        return value.serialize()
                                if value is Resource:
                                        return value.resource_path if value.resource_path != "" else value.resource_name
                                if value is Node:
                                        return _path_to_string(value)
                        return String(value)
                _:
                        return String(value)

func _path_to_string(node: Node) -> String:
        if node == null:
                return ""
        var node_path = node.get_path()
        if typeof(node_path) == TYPE_NODE_PATH:
                return String(node_path)
        return str(node_path)

func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
        var payload := {
                "filename": LOG_FILENAME,
                "timestamp": Time.get_datetime_string_from_system(true, true),
                "classname": "MCPAnimationCommands",
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
