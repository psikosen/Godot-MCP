@tool
class_name MCPAuthoringCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Authoring the other processors don't cover: TileSets and SpriteFrames cut from a sprite sheet,
## reading and editing saved resource files, and the editor's own Undo/Redo.

const MAX_TILES := 4096
const MAX_FRAMES := 1024
const MAX_UNDO_STEPS := 20
const MAX_LIST_ITEMS := 64
const HEADER_USAGE := PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP

var _menu_cache := {}


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"create_tileset_2d":
			_create_tileset_2d(client_id, params, command_id)
		"create_sprite_frames":
			_create_sprite_frames(client_id, params, command_id)
		"undo_redo":
			_undo_redo(client_id, params, command_id)
		"get_resource_properties":
			_get_resource_properties(client_id, params, command_id)
		"update_resource_properties":
			_update_resource_properties(client_id, params, command_id)
		_:
			return false
	return true


# --- shared helpers -------------------------------------------------------------------------

# {"texture": Texture2D} or {"error": message}.
func _load_texture(requested: String) -> Dictionary:
	var path := _contained_res_path(requested)
	if requested.is_empty() or path.is_empty():
		return {"error": "texture_path must be an image inside the project (res://): %s" % requested}
	if not ResourceLoader.exists(path):
		return {"error": "Texture not found (or not imported yet): %s" % path}
	var texture := ResourceLoader.load(path) as Texture2D
	if texture == null:
		return {"error": "Not a texture: %s" % path}
	return {"texture": texture}


# {"path": res://...tres} or {"error": message}. An empty save_path is allowed when optional.
func _check_save_path(params: Dictionary, optional := false) -> Dictionary:
	var requested := str(params.get("save_path", ""))
	if requested.is_empty():
		return {"path": ""} if optional else {"error": "save_path is required (a .tres file)"}
	var path := _contained_res_path(requested)
	if path.is_empty() or not (path.ends_with(".tres") or path.ends_with(".res")):
		return {"error": "save_path must be a .tres or .res file inside the project (res://): %s" % requested}
	if _is_protected_path(path):
		return {"error": "save_path is protected: %s" % path}
	if FileAccess.file_exists(path) and not bool(params.get("overwrite", false)):
		return {"error": "%s already exists (pass overwrite=true to replace it)" % path}
	return {"path": path}


func _save_new_resource(resource: Resource, path: String) -> int:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var result := _save_resource_contained(resource, path)
	if result == OK:
		EditorInterface.get_resource_filesystem().update_file(path)
	return result


func _positive_vector2i(value) -> Variant:
	var vector = _coerce_to_vector2i(value)
	return vector if vector is Vector2i and vector.x > 0 and vector.y > 0 else null


# JSON-friendly copy: resources become their file path (or "<Class>"), long lists a short note.
func _readable(value, depth := 0):
	var type := typeof(value)
	if type == TYPE_OBJECT:
		if value == null or not is_instance_valid(value):
			return null  # an empty resource slot; JSON would print it as "<Object#null>"
		if value is Resource:
			var file_path: String = value.resource_path
			return file_path if not file_path.is_empty() and not file_path.contains("::") else "<%s>" % value.get_class()
		return "<%s>" % value.get_class()
	if type >= TYPE_PACKED_BYTE_ARRAY and type <= TYPE_PACKED_VECTOR4_ARRAY or type == TYPE_ARRAY:
		if value.size() > MAX_LIST_ITEMS or depth >= 4:
			return "<%s with %d items>" % [type_string(type), value.size()]
		if type == TYPE_ARRAY:
			return value.map(func(item): return _readable(item, depth + 1))
		return value
	if type == TYPE_DICTIONARY:
		if value.size() > MAX_LIST_ITEMS or depth >= 4:
			return "<Dictionary with %d keys>" % value.size()
		var copy := {}
		for key in value:
			copy[str(key)] = _readable(value[key], depth + 1)
		return copy
	return value


# --- create_tileset_2d ----------------------------------------------------------------------

# A TileSet with one atlas source cut from a sprite sheet, so paint tools have tiles to paint.
func _create_tileset_2d(client_id: int, params: Dictionary, command_id: String) -> void:
	var loaded := _load_texture(str(params.get("texture_path", "")))
	if loaded.has("error"):
		return _send_error(client_id, loaded["error"], command_id)
	var texture: Texture2D = loaded["texture"]
	var tile_size = _positive_vector2i(params.get("tile_size"))
	if tile_size == null:
		return _send_error(client_id, "tile_size must be positive whole numbers, e.g. {\"x\": 16, \"y\": 16}", command_id)
	var margins = _coerce_to_vector2i(params.get("margins", Vector2i.ZERO))
	var separation = _coerce_to_vector2i(params.get("separation", Vector2i.ZERO))
	if not (margins is Vector2i and separation is Vector2i) or margins.x < 0 or margins.y < 0 or separation.x < 0 or separation.y < 0:
		return _send_error(client_id, "margins and separation must be zero or positive {x, y}", command_id)
	var checked := _check_save_path(params)
	if checked.has("error"):
		return _send_error(client_id, checked["error"], command_id)
	var layer: Node = null
	if not str(params.get("node_path", "")).is_empty():
		layer = _get_editor_node(str(params.get("node_path")))
		if not (layer is TileMapLayer or layer is TileMap):
			return _send_error(client_id, "node_path must be a TileMapLayer: %s" % params.get("node_path"), command_id)

	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.margins = margins
	source.separation = separation
	source.texture_region_size = tile_size
	var grid := source.get_atlas_grid_size()
	if grid.x <= 0 or grid.y <= 0:
		return _send_error(client_id, "The texture (%dx%d) is smaller than one tile (%dx%d plus margins)" % [
			texture.get_width(), texture.get_height(), tile_size.x, tile_size.y], command_id)
	if grid.x * grid.y > MAX_TILES:
		return _send_error(client_id, "%dx%d tiles is more than %d; use a bigger tile_size" % [grid.x, grid.y, MAX_TILES], command_id)

	var image: Image = null
	if bool(params.get("skip_empty", true)):
		image = texture.get_image()
		if image and image.is_compressed():
			image.decompress()
	var created: Array = []
	var skipped := 0
	for y in grid.y:
		for x in grid.x:
			var coords := Vector2i(x, y)
			if image and image.get_region(Rect2i(margins + coords * (tile_size + separation), tile_size)).is_invisible():
				skipped += 1
				continue
			source.create_tile(coords)
			created.append(coords)
	if created.is_empty():
		return _send_error(client_id, "Every tile in the texture is fully transparent (pass skip_empty=false to keep them)", command_id)

	var tileset := TileSet.new()
	tileset.tile_size = tile_size
	var source_id := tileset.add_source(source)

	var collision = params.get("collision", "none")
	var collision_tiles: Array = []
	if collision is Array:
		for item in collision:
			var coords = _coerce_to_vector2i(item)
			if not (coords is Vector2i and source.has_tile(coords)):
				return _send_error(client_id, "collision tile %s is not a tile in this TileSet (grid %dx%d, empty tiles skipped)" % [JSON.stringify(item), grid.x, grid.y], command_id)
			collision_tiles.append(coords)
	elif str(collision) == "all":
		collision_tiles = created
	elif str(collision) != "none":
		return _send_error(client_id, "collision must be \"none\", \"all\" or a list of tile coordinates [[x, y], ...]", command_id)
	if not collision_tiles.is_empty():
		tileset.add_physics_layer()
		var half := Vector2(tile_size) / 2.0
		var square := PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
		for coords in collision_tiles:
			var data := source.get_tile_data(coords, 0)
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, square)

	var save_path: String = checked["path"]
	var saved := _save_new_resource(tileset, save_path)
	if saved != OK:
		return _send_error(client_id, "Failed to save %s (error %d)" % [save_path, saved], command_id)
	var response := {
		"save_path": save_path,
		"source_id": source_id,
		"tile_size": [tile_size.x, tile_size.y],
		"grid": [grid.x, grid.y],
		"tiles": created.size(),
		"skipped_empty": skipped,
		"collision_tiles": collision_tiles.size(),
	}
	if layer == null:
		return _send_success(client_id, response, command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Assign TileSet", transaction_id, {"command": "create_tileset_2d"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_property(layer, "tile_set", tileset)
	transaction.add_undo_property(layer, "tile_set", layer.tile_set)
	transaction.register_on_commit(func(): _mark_scene_modified())
	response["node_path"] = _to_mcp_path(layer)
	_finish_transaction(client_id, command_id, transaction, transaction_id, response)


# --- create_sprite_frames -------------------------------------------------------------------

# SpriteFrames for AnimatedSprite2D/3D: named animations cut from a grid sprite sheet.
func _create_sprite_frames(client_id: int, params: Dictionary, command_id: String) -> void:
	var loaded := _load_texture(str(params.get("texture_path", "")))
	if loaded.has("error"):
		return _send_error(client_id, loaded["error"], command_id)
	var texture: Texture2D = loaded["texture"]
	var sheet := Vector2i(texture.get_size())
	var frame_size = null
	if params.has("frame_size"):
		frame_size = _positive_vector2i(params.get("frame_size"))
	elif params.has("hframes") or params.has("vframes"):
		var hframes := int(params.get("hframes", 1))
		var vframes := int(params.get("vframes", 1))
		if hframes > 0 and vframes > 0:
			frame_size = _positive_vector2i(Vector2i(sheet.x / hframes, sheet.y / vframes))
	else:
		return _send_error(client_id, "Pass frame_size {x, y} or hframes/vframes", command_id)
	if frame_size == null:
		return _send_error(client_id, "frame_size (or hframes/vframes) must give frames of at least 1x1 pixel", command_id)
	var columns: int = sheet.x / frame_size.x
	var rows: int = sheet.y / frame_size.y
	if columns <= 0 or rows <= 0:
		return _send_error(client_id, "The texture (%dx%d) is smaller than one frame (%dx%d)" % [sheet.x, sheet.y, frame_size.x, frame_size.y], command_id)
	var total := columns * rows

	var checked := _check_save_path(params, true)
	if checked.has("error"):
		return _send_error(client_id, checked["error"], command_id)
	var sprite: Node = null
	if not str(params.get("node_path", "")).is_empty():
		sprite = _get_editor_node(str(params.get("node_path")))
		if not (sprite is AnimatedSprite2D or sprite is AnimatedSprite3D):
			return _send_error(client_id, "node_path must be an AnimatedSprite2D or AnimatedSprite3D: %s" % params.get("node_path"), command_id)
	if checked["path"].is_empty() and sprite == null:
		return _send_error(client_id, "Pass save_path, node_path or both, or the frames are not kept anywhere", command_id)

	var animations = params.get("animations", [])
	if not (animations is Array) or animations.is_empty():
		return _send_error(client_id, "animations must be a list like [{\"name\": \"run\", \"row\": 0, \"fps\": 10}]", command_id)
	var frames := SpriteFrames.new()
	var seen := {}
	var summary: Array = []
	var frame_count := 0
	for animation in animations:
		if not (animation is Dictionary):
			return _send_error(client_id, "Each animation must be an object with a name and frames or row", command_id)
		var name := str(animation.get("name", "")).strip_edges()
		if name.is_empty() or seen.has(name):
			return _send_error(client_id, "Animation names must be set and unique (got %s)" % JSON.stringify(animation.get("name", "")), command_id)
		seen[name] = true
		var indices: Array = []
		if animation.has("frames") and animation["frames"] is Array:
			for index in animation["frames"]:
				indices.append(int(index))
		elif animation.has("row"):
			var row := int(animation["row"])
			if row < 0 or row >= rows:
				return _send_error(client_id, "Animation %s: row %d is outside the sheet (0..%d)" % [name, row, rows - 1], command_id)
			for column in columns:
				indices.append(row * columns + column)
		if indices.is_empty():
			return _send_error(client_id, "Animation %s needs frames (a list of frame numbers) or row" % name, command_id)
		for index in indices:
			if index < 0 or index >= total:
				return _send_error(client_id, "Animation %s: frame %d is outside the sheet (0..%d, numbered left to right, top to bottom)" % [name, index, total - 1], command_id)
		frame_count += indices.size()
		if frame_count > MAX_FRAMES:
			return _send_error(client_id, "More than %d frames in total" % MAX_FRAMES, command_id)
		var fps := float(animation.get("fps", 10.0))
		if fps <= 0.0:
			return _send_error(client_id, "Animation %s: fps must be greater than 0" % name, command_id)
		if not frames.has_animation(name):
			frames.add_animation(name)
		frames.set_animation_speed(name, fps)
		frames.set_animation_loop(name, bool(animation.get("loop", true)))
		for index in indices:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(Vector2((index % columns) * frame_size.x, (index / columns) * frame_size.y), Vector2(frame_size))
			frames.add_frame(name, atlas)
		summary.append({"name": name, "frames": indices.size(), "fps": fps, "loop": frames.get_animation_loop(name)})
	if not seen.has("default"):
		frames.remove_animation("default")  # SpriteFrames.new() starts with an empty "default"

	var autoplay := str(params.get("autoplay", ""))
	if not autoplay.is_empty() and not seen.has(autoplay):
		return _send_error(client_id, "autoplay %s is not one of the animations: %s" % [autoplay, ", ".join(PackedStringArray(seen.keys()))], command_id)

	var save_path: String = checked["path"]
	if not save_path.is_empty():
		var saved := _save_new_resource(frames, save_path)
		if saved != OK:
			return _send_error(client_id, "Failed to save %s (error %d)" % [save_path, saved], command_id)
	var response := {
		"save_path": save_path,
		"frame_size": [frame_size.x, frame_size.y],
		"grid": [columns, rows],
		"animations": summary,
	}
	if sprite == null:
		return _send_success(client_id, response, command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Assign SpriteFrames", transaction_id, {"command": "create_sprite_frames"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_property(sprite, "sprite_frames", frames)
	transaction.add_undo_property(sprite, "sprite_frames", sprite.sprite_frames)
	var first: String = autoplay if not autoplay.is_empty() else str(summary[0]["name"])
	transaction.add_do_property(sprite, "animation", first)
	transaction.add_undo_property(sprite, "animation", sprite.animation)
	if not autoplay.is_empty():
		transaction.add_do_property(sprite, "autoplay", autoplay)
		transaction.add_undo_property(sprite, "autoplay", sprite.autoplay)
	transaction.register_on_commit(func(): _mark_scene_modified())
	response["node_path"] = _to_mcp_path(sprite)
	_finish_transaction(client_id, command_id, transaction, transaction_id, response)


# --- undo_redo ------------------------------------------------------------------------------

# Presses the editor's own Scene > Undo/Redo menu entry. That runs EditorNode's undo, which keeps
# EditorUndoRedoManager's order across the global and scene histories. Calling undo() on one
# history's UndoRedo directly would leave the manager out of step ("UndoRedo history mismatch").
func _undo_redo(client_id: int, params: Dictionary, command_id: String) -> void:
	var action := str(params.get("action", "undo"))
	if not action in ["undo", "redo"]:
		return _send_error(client_id, "action must be \"undo\" or \"redo\"", command_id)
	var steps := int(params.get("steps", 1))
	if steps < 1 or steps > MAX_UNDO_STEPS:
		return _send_error(client_id, "steps must be 1 to %d" % MAX_UNDO_STEPS, command_id)
	# Godot 4.4 has no EditorSettings.get_shortcut, so the menu entry cannot be found there.
	if not EditorInterface.get_editor_settings().has_method("get_shortcut"):
		return _send_error(client_id, "undo_redo needs a newer Godot than %s" % _godot_version(), command_id)
	var item := _main_menu_item("ui_" + action)
	if item.is_empty():
		return _send_error(client_id, "Could not find the editor's %s menu entry" % action.capitalize(), command_id)
	var manager = _get_undo_redo()
	if manager == null:
		return _send_error(client_id, "Editor undo history is not available", command_id)

	var histories: Array = [manager.get_history_undo_redo(EditorUndoRedoManager.GLOBAL_HISTORY)]
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root:
		histories.append(manager.get_history_undo_redo(manager.get_object_history_id(scene_root)))
	var names: Array = []
	for step in steps:
		var before: Array = histories.map(func(history): return [history.get_version(), history.get_current_action_name()])
		item["popup"].id_pressed.emit(item["id"])
		var changed := -1
		for index in histories.size():
			if histories[index].get_version() != before[index][0]:
				changed = index
		if changed == -1:
			break  # nothing left to undo/redo
		names.append(before[changed][1] if action == "undo" else histories[changed].get_current_action_name())
	_send_success(client_id, {
		"action": action,
		"done": names.size(),
		"actions": names,
		"can_undo": histories.any(func(history): return history.has_undo()),
		"can_redo": histories.any(func(history): return history.has_redo()),
	}, command_id)


# {"popup": PopupMenu, "id": item id} for the main menu entry bound to an editor shortcut.
func _main_menu_item(shortcut_name: String) -> Dictionary:
	var cached: Dictionary = _menu_cache.get(shortcut_name, {})
	if not cached.is_empty() and is_instance_valid(cached["popup"]):
		return cached
	var shortcut: Shortcut = EditorInterface.get_editor_settings().call("get_shortcut", shortcut_name)
	if shortcut == null:
		return {}
	var stack: Array = [EditorInterface.get_base_control()]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		# Only the title bar's MenuBar: the script editor's Edit menu uses the same shortcut for text undo.
		if node is PopupMenu and node.get_parent() is MenuBar:
			for index in node.item_count:
				if node.get_item_shortcut(index) == shortcut:
					_menu_cache[shortcut_name] = {"popup": node, "id": node.get_item_id(index)}
					return _menu_cache[shortcut_name]
		stack.append_array(node.get_children(true))
	return {}


# --- get_resource_properties / update_resource_properties -----------------------------------

# {"resource": Resource, "path": res://...} or {"error": message}.
func _load_resource_file(requested: String) -> Dictionary:
	var path := _contained_res_path(requested)
	if requested.is_empty() or path.is_empty():
		return {"error": "path must be a resource file inside the project (res://): %s" % requested}
	if not ResourceLoader.exists(path):
		return {"error": "Resource not found: %s" % path}
	var resource := ResourceLoader.load(path)
	if resource == null:
		return {"error": "Failed to load %s" % path}
	return {"resource": resource, "path": path}


func _get_resource_properties(client_id: int, params: Dictionary, command_id: String) -> void:
	var loaded := _load_resource_file(str(params.get("path", "")))
	if loaded.has("error"):
		return _send_error(client_id, loaded["error"], command_id)
	var resource: Resource = loaded["resource"]
	var script = resource.get_script()
	var properties := {}
	var missing: Array = []
	var wanted = params.get("properties", [])
	if wanted is Array and not wanted.is_empty():
		for name in wanted:
			var key := str(name)
			if key in resource:
				properties[key] = _readable(resource.get(key))
			else:
				missing.append(key)
	else:
		var changed_only := bool(params.get("changed_only", false))
		var script_vars := {}
		if script:
			for info in script.get_script_property_list():
				script_vars[info["name"]] = true
		for info in resource.get_property_list():
			var name: String = info["name"]
			var usage: int = info.get("usage", 0)
			if not (usage & PROPERTY_USAGE_STORAGE) or usage & HEADER_USAGE or name.begins_with("resource_") or name == "script":
				continue
			var value = resource.get(name)
			if changed_only:
				var default_value = script.get_property_default_value(name) if script_vars.has(name) else ClassDB.class_get_property_default_value(resource.get_class(), name)
				if typeof(value) == typeof(default_value) and value == default_value:
					continue
			properties[name] = _readable(value)
	var response := {
		"path": loaded["path"],
		"class": resource.get_class(),
		"script": script.resource_path if script else "",
		"properties": properties,
	}
	if not missing.is_empty():
		response["missing"] = missing
	_send_success(client_id, response, command_id)


# All values are checked before any is set, so one bad value changes nothing. Saved straight to
# the file; this is not on the editor's undo history.
func _update_resource_properties(client_id: int, params: Dictionary, command_id: String) -> void:
	var loaded := _load_resource_file(str(params.get("path", "")))
	if loaded.has("error"):
		return _send_error(client_id, loaded["error"], command_id)
	var resource: Resource = loaded["resource"]
	var path: String = loaded["path"]
	if resource is PackedScene or resource is Script:
		return _send_error(client_id, "%s is a %s; use the scene or script tools for it" % [path, resource.get_class()], command_id)
	if _is_protected_path(path):
		return _send_error(client_id, "%s is protected" % path, command_id)
	var requested = params.get("properties", {})
	if not (requested is Dictionary) or requested.is_empty():
		return _send_error(client_id, "properties must be an object like {\"speed\": 200}", command_id)

	var converted := {}
	var errors: Array = []
	for name in requested:
		var key := str(name)
		if key == "resource_path" or not key in resource:
			errors.append("%s has no property %s" % [resource.get_class(), key])
			continue
		var value = _convert_property_value(resource, key, requested[name])
		var error := _property_value_error(resource, key, value)
		if error.is_empty():
			converted[key] = value
		else:
			errors.append(error)
	if not errors.is_empty():
		return _send_error(client_id, "No changes made: " + "; ".join(PackedStringArray(errors)), command_id)

	var previous := {}
	for key in converted:
		previous[key] = resource.get(key)
		resource.set(key, converted[key])
	var saved := _save_resource_contained(resource, path)
	if saved != OK:
		for key in previous:
			resource.set(key, previous[key])
		return _send_error(client_id, "Failed to save %s (error %d); no changes kept" % [path, saved], command_id)
	EditorInterface.get_resource_filesystem().update_file(path)
	var changes := {}
	for key in converted:
		changes[key] = {"from": _readable(previous[key]), "to": _readable(resource.get(key))}
	_send_success(client_id, {"path": path, "changed": changes}, command_id)
