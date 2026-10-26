@tool
class_name MCPBuilderCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Building blocks: physics layers by name, collision shapes fitted to art, 2D shader effects,
## generated sound effects, text-drawn tile levels, 3D blockouts and 2D lighting.

const LAYER_LIMIT := 32
const SHADER_EFFECTS := {
	"outline": """shader_type canvas_item;
// Outline around a textured sprite's opaque pixels.
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float width : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 step_size = TEXTURE_PIXEL_SIZE * width;
	float around = texture(TEXTURE, UV + vec2(step_size.x, 0.0)).a + texture(TEXTURE, UV - vec2(step_size.x, 0.0)).a
		+ texture(TEXTURE, UV + vec2(0.0, step_size.y)).a + texture(TEXTURE, UV - vec2(0.0, step_size.y)).a;
	vec4 outline = vec4(outline_color.rgb, min(around, 1.0) * outline_color.a);
	COLOR = mix(outline, base * COLOR, base.a);
}
""",
	"flash": """shader_type canvas_item;
// Hit flash: animate amount from 1 to 0 (a tween or AnimationPlayer) when something is hurt.
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	COLOR = vec4(mix(base.rgb, flash_color.rgb, amount), base.a);
}
""",
	"dissolve": """shader_type canvas_item;
// Dissolve: animate progress from 0 (whole) to 1 (gone); the edge glows.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.06;
uniform vec4 edge_color : source_color = vec4(1.0, 0.55, 0.1, 1.0);
uniform float noise_scale = 24.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float n = value_noise(UV * noise_scale);
	float cut = step(progress, n);
	float edge = step(progress, n + edge_width) - cut;
	COLOR = vec4(mix(base.rgb, edge_color.rgb, edge), base.a * max(cut, edge * step(0.001, progress)));
}
""",
	"wave": """shader_type canvas_item;
// Sway (grass, flags, underwater): the top of the shape moves, the bottom stays put.
uniform float amplitude = 4.0;
uniform float speed = 2.0;
uniform float frequency = 0.05;

void vertex() {
	VERTEX.x += sin(TIME * speed + VERTEX.y * frequency) * amplitude * (1.0 - UV.y);
}
""",
	"grayscale": """shader_type canvas_item;
// Desaturate: amount 1 is fully gray (paused or defeated look).
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float gray = dot(base.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(mix(base.rgb, vec3(gray), amount), base.a);
}
""",
}
const SFX_PRESETS := ["jump", "coin", "hit", "explosion", "laser", "powerup", "blip", "footstep"]
const SFX_RATE := 22050


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"set_collision_layers":
			_set_collision_layers(client_id, params, command_id)
		"fit_collision_shape":
			_fit_collision_shape(client_id, params, command_id)
		"create_canvas_shader":
			_create_canvas_shader(client_id, params, command_id)
		"generate_sfx":
			_generate_sfx(client_id, params, command_id)
		"paint_tilemap_ascii":
			_paint_tilemap_ascii(client_id, params, command_id)
		"build_blockout_3d":
			_build_blockout_3d(client_id, params, command_id)
		"setup_2d_lighting":
			_setup_2d_lighting(client_id, params, command_id)
		"rescan_filesystem":
			EditorInterface.get_resource_filesystem().scan()
			_send_success(client_id, {"scanned": true}, command_id)
		_:
			return false
	return true


# --- set_collision_layers -------------------------------------------------------------------

# Layer and mask by the names set in Project Settings > Layer Names (or by number), so nobody has
# to work out that "player and enemies" is 2 + 8 = 10.
func _set_collision_layers(client_id: int, params: Dictionary, command_id: String) -> void:
	var node = _get_editor_node(str(params.get("node_path", "")))
	if not (node is CollisionObject2D or node is CollisionObject3D):
		return _send_error(client_id, "node_path must be a physics body or area (CollisionObject2D/3D)", command_id)
	var kind := "2d_physics" if node is CollisionObject2D else "3d_physics"
	var changes := {}
	for property in ["collision_layer", "collision_mask"]:
		var key := "layers" if property == "collision_layer" else "mask"
		if not params.has(key):
			continue
		var bits := 0
		for layer in params[key]:
			var number := _layer_number(kind, layer)
			if number == 0:
				return _send_error(client_id, "Unknown layer %s; named %s layers: %s" % [layer, kind, ", ".join(PackedStringArray(_layer_names(kind)))], command_id)
			bits |= 1 << (number - 1)
		changes[property] = bits
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = null
	if not changes.is_empty():
		transaction = _transaction("Set Collision Layers", transaction_id, {"command": "set_collision_layers"})
		if not transaction:
			return _send_error(client_id, "Failed to obtain scene transaction", command_id)
		for property in changes:
			transaction.add_do_property(node, property, changes[property])
			transaction.add_undo_property(node, property, node.get(property))
		transaction.register_on_commit(func(): _mark_scene_modified())
	var response := {
		"node_path": _to_mcp_path(node),
		"layers": _describe_bits(kind, changes.get("collision_layer", node.collision_layer)),
		"mask": _describe_bits(kind, changes.get("collision_mask", node.collision_mask)),
	}
	if transaction == null:
		response["status"] = "unchanged"
		return _send_success(client_id, response, command_id)
	_finish_transaction(client_id, command_id, transaction, transaction_id, response)


func _layer_number(kind: String, layer) -> int:
	if typeof(layer) in [TYPE_INT, TYPE_FLOAT]:
		return int(layer) if int(layer) >= 1 and int(layer) <= LAYER_LIMIT else 0
	var text := str(layer)
	if text.is_valid_int():
		return _layer_number(kind, text.to_int())
	for number in range(1, LAYER_LIMIT + 1):
		if str(ProjectSettings.get_setting("layer_names/%s/layer_%d" % [kind, number], "")).to_lower() == text.to_lower():
			return number
	return 0


func _layer_names(kind: String) -> Array:
	var names: Array = []
	for number in range(1, LAYER_LIMIT + 1):
		var name := str(ProjectSettings.get_setting("layer_names/%s/layer_%d" % [kind, number], ""))
		if not name.is_empty():
			names.append("%d=%s" % [number, name])
	return names if not names.is_empty() else ["none (name them with configure_game_settings layer_names)"]


func _describe_bits(kind: String, bits: int) -> Array:
	var described: Array = []
	for number in range(1, LAYER_LIMIT + 1):
		if bits & (1 << (number - 1)):
			var name := str(ProjectSettings.get_setting("layer_names/%s/layer_%d" % [kind, number], ""))
			described.append("%d%s" % [number, (" " + name) if not name.is_empty() else ""])
	return described


# --- fit_collision_shape --------------------------------------------------------------------

# Sizes a collision shape to the visible art under a body or area: Sprite2D, AnimatedSprite2D and
# Polygon2D in 2D; meshes, CSG and sprites (anything with an AABB) in 3D.
func _fit_collision_shape(client_id: int, params: Dictionary, command_id: String) -> void:
	var body = _get_editor_node(str(params.get("node_path", "")))
	if not (body is CollisionObject2D or body is CollisionObject3D):
		return _send_error(client_id, "node_path must be a physics body or area (CollisionObject2D/3D)", command_id)
	var is_2d := body is CollisionObject2D
	var shape_kind := str(params.get("shape", "rectangle" if is_2d else "box"))
	var allowed := ["rectangle", "circle", "capsule"] if is_2d else ["box", "sphere", "capsule"]
	if not shape_kind in allowed:
		return _send_error(client_id, "shape must be one of: %s" % ", ".join(PackedStringArray(allowed)), command_id)
	var padding := float(params.get("padding", 0.0))
	var bounds = _visual_bounds_2d(body) if is_2d else _visual_bounds_3d(body)
	if bounds == null:
		return _send_error(client_id, "No visible art found under %s (Sprite2D, AnimatedSprite2D, Polygon2D, or 3D meshes)" % params.get("node_path"), command_id)
	bounds = bounds.grow(padding)

	var shape
	var center
	if is_2d:
		var rect: Rect2 = bounds
		center = rect.get_center()
		if shape_kind == "rectangle":
			shape = RectangleShape2D.new()
			shape.size = rect.size
		elif shape_kind == "circle":
			shape = CircleShape2D.new()
			shape.radius = maxf(rect.size.x, rect.size.y) / 2.0
		else:
			shape = CapsuleShape2D.new()
			shape.radius = minf(rect.size.x, rect.size.y) / 2.0
			shape.height = maxf(rect.size.x, rect.size.y)
	else:
		var box: AABB = bounds
		center = box.get_center()
		if shape_kind == "box":
			shape = BoxShape3D.new()
			shape.size = box.size
		elif shape_kind == "sphere":
			shape = SphereShape3D.new()
			shape.radius = maxf(box.size.x, maxf(box.size.y, box.size.z)) / 2.0
		else:
			shape = CapsuleShape3D.new()
			shape.radius = maxf(box.size.x, box.size.z) / 2.0
			shape.height = maxf(box.size.y, shape.radius * 2.0)

	var collision = null
	for child in body.get_children():
		if child is CollisionShape2D or child is CollisionShape3D:
			collision = child
			break
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Fit Collision Shape", transaction_id, {"command": "fit_collision_shape"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var created := collision == null
	if created:
		collision = CollisionShape2D.new() if is_2d else CollisionShape3D.new()
		collision.name = _unique_child_name(body, "CollisionShape")
		collision.shape = shape
		collision.position = center
		transaction.add_do_method(body, "add_child", [collision, true])
		transaction.add_do_method(collision, "set_owner", [EditorInterface.get_edited_scene_root()])
		transaction.add_do_reference(collision)
		transaction.add_undo_method(body, "remove_child", [collision])
	else:
		transaction.add_do_property(collision, "shape", shape)
		transaction.add_undo_property(collision, "shape", collision.shape)
		transaction.add_do_property(collision, "position", center)
		transaction.add_undo_property(collision, "position", collision.position)
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(body), str(collision.name)), "created": created, "shape": shape.get_class(),
		"size": var_to_str(bounds.size), "position": var_to_str(center)})


func _visual_bounds_2d(body):
	var to_body: Transform2D = body.global_transform.affine_inverse()
	var points: Array = []
	var visuals: Array = body.find_children("*", "", true, false)
	for visual in visuals:
		var rect = null
		if visual is Sprite2D and visual.texture:
			rect = visual.get_rect()
		elif visual is AnimatedSprite2D and visual.sprite_frames and visual.sprite_frames.has_animation(visual.animation) \
				and visual.sprite_frames.get_frame_count(visual.animation) > 0:
			var size: Vector2 = visual.sprite_frames.get_frame_texture(visual.animation, 0).get_size()
			rect = Rect2((-size / 2.0 if visual.centered else Vector2.ZERO) + visual.offset, size)
		elif visual is Polygon2D and visual.polygon.size() > 0:
			for point in visual.polygon:
				points.append(to_body * visual.global_transform * (point + visual.offset))
			continue
		if rect == null:
			continue
		for corner in [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y)]:
			points.append(to_body * visual.global_transform * corner)
	if points.is_empty():
		return null
	var bounds := Rect2(Vector2(points[0]), Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	return bounds


func _visual_bounds_3d(body):
	var to_body: Transform3D = body.global_transform.affine_inverse()
	var bounds = null
	var visuals: Array = body.find_children("*", "VisualInstance3D", true, false)
	for visual in visuals:
		var box: AABB = visual.get_aabb()
		for i in range(8):
			var corner: Vector3 = to_body * visual.global_transform * box.get_endpoint(i)
			bounds = AABB(corner, Vector3.ZERO) if bounds == null else bounds.expand(corner)
	return bounds


# --- create_canvas_shader -------------------------------------------------------------------

func _create_canvas_shader(client_id: int, params: Dictionary, command_id: String) -> void:
	var effect := str(params.get("effect", ""))
	if not SHADER_EFFECTS.has(effect):
		return _send_error(client_id, "effect must be one of: %s" % ", ".join(PackedStringArray(SHADER_EFFECTS.keys())), command_id)
	var node = _get_editor_node(str(params.get("node_path", "")))
	if not node is CanvasItem:
		return _send_error(client_id, "node_path must be a 2D node or Control (CanvasItem)", command_id)
	var requested := str(params.get("shader_path", "res://shaders/%s.gdshader" % effect))
	var shader_path := _contained_res_path(requested)
	if shader_path.is_empty() or not shader_path.ends_with(".gdshader"):
		return _send_error(client_id, "shader_path must be a .gdshader file inside the project: %s" % requested, command_id)
	if not FileAccess.file_exists(shader_path):
		DirAccess.make_dir_recursive_absolute(shader_path.get_base_dir())
		var file := FileAccess.open(shader_path, FileAccess.WRITE)
		if file == null:
			return _send_error(client_id, "Failed to write %s" % shader_path, command_id)
		file.store_string(SHADER_EFFECTS[effect])
		file = null
		EditorInterface.get_resource_filesystem().update_file(shader_path)
	var shader := ResourceLoader.load(shader_path, "Shader", ResourceLoader.CACHE_MODE_REPLACE) as Shader
	if shader == null:
		return _send_error(client_id, "Failed to load %s as a shader" % shader_path, command_id)
	var material := ShaderMaterial.new()
	material.shader = shader
	var uniforms = params.get("uniforms", {})
	var applied: Array = []
	if typeof(uniforms) == TYPE_DICTIONARY:
		var known := {}
		for info in shader.get_shader_uniform_list():
			known[info["name"]] = info
		for name in uniforms:
			if not known.has(name):
				return _send_error(client_id, "Unknown uniform %s; %s has: %s" % [name, effect, ", ".join(PackedStringArray(known.keys()))], command_id)
			var value = _coerce_value_to_type(uniforms[name], int(known[name]["type"]))
			if typeof(value) != int(known[name]["type"]) and not (typeof(value) in [TYPE_INT, TYPE_FLOAT] and int(known[name]["type"]) in [TYPE_INT, TYPE_FLOAT]):
				return _send_error(client_id, "Uniform %s expects %s, got %s" % [name, type_string(int(known[name]["type"])), JSON.stringify(uniforms[name])], command_id)
			material.set_shader_parameter(name, value)
			applied.append(name)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Create Canvas Shader", transaction_id, {"command": "create_canvas_shader"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_property(node, "material", material)
	transaction.add_undo_property(node, "material", node.material)
	transaction.register_on_commit(func(): _mark_scene_modified())
	var uniform_names: Array = shader.get_shader_uniform_list().map(func(info): return str(info["name"]))
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _to_mcp_path(node), "effect": effect, "shader_path": shader_path, "uniforms": uniform_names, "set": applied})


# --- generate_sfx ---------------------------------------------------------------------------

# Small retro sound effects synthesized from square waves, noise and pitch sweeps (no assets
# needed), saved as 16-bit mono WAV files that Godot imports like any other sound.
func _generate_sfx(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset := str(params.get("preset", ""))
	if not preset in SFX_PRESETS:
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PackedStringArray(SFX_PRESETS)), command_id)
	var requested := str(params.get("path", "res://audio/sfx/%s.wav" % preset))
	var path := _contained_res_path(requested)
	if path.is_empty() or not path.ends_with(".wav"):
		return _send_error(client_id, "path must be a .wav file inside the project: %s" % requested, command_id)
	if FileAccess.file_exists(path) and not params.get("overwrite", false):
		return _send_error(client_id, "%s already exists (pass overwrite=true to replace it)" % path, command_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(params.get("seed", hash(preset)))
	var pitch := clampf(float(params.get("pitch", 1.0)), 0.25, 4.0) * (1.0 + (rng.randf() - 0.5) * clampf(float(params.get("variation", 0.0)), 0.0, 1.0))
	var volume := clampf(float(params.get("volume", 0.8)), 0.0, 1.0)
	var samples := _synthesize(preset, pitch, rng)
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in range(samples.size()):
		data.encode_s16(i * 2, int(clampf(samples[i] * volume, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SFX_RATE
	wav.stereo = false
	wav.data = data
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := wav.save_to_wav(path)
	if err != OK:
		return _send_error(client_id, "Failed to write %s: %s" % [path, error_string(err)], command_id)
	EditorInterface.get_resource_filesystem().update_file(path)
	EditorInterface.get_resource_filesystem().scan()
	_send_success(client_id, {"path": path, "preset": preset, "seconds": snappedf(samples.size() / float(SFX_RATE), 0.01)}, command_id)


func _synthesize(preset: String, pitch: float, rng: RandomNumberGenerator) -> PackedFloat32Array:
	# [seconds, start Hz, end Hz, wave, noise mix]; steps play one after another (arpeggios).
	var steps: Array = {
		"jump": [[0.22, 280.0, 720.0, "square", 0.0]],
		"coin": [[0.07, 988.0, 988.0, "square", 0.0], [0.28, 1319.0, 1319.0, "square", 0.0]],
		"hit": [[0.16, 220.0, 60.0, "square", 0.6]],
		"explosion": [[0.85, 120.0, 30.0, "noise", 1.0]],
		"laser": [[0.2, 1400.0, 220.0, "saw", 0.0]],
		"powerup": [[0.07, 523.0, 523.0, "square", 0.0], [0.07, 659.0, 659.0, "square", 0.0], [0.07, 784.0, 784.0, "square", 0.0], [0.22, 1047.0, 1047.0, "square", 0.0]],
		"blip": [[0.06, 880.0, 880.0, "sine", 0.0]],
		"footstep": [[0.07, 90.0, 60.0, "noise", 1.0]],
	}[preset]
	var out := PackedFloat32Array()
	var phase := 0.0
	var smoothed := 0.0
	for index in range(steps.size()):
		var spec: Array = steps[index]
		var count := int(spec[0] * SFX_RATE)
		var last := index == steps.size() - 1
		for i in range(count):
			var t := float(i) / count
			var frequency: float = lerpf(spec[1], spec[2], t) * pitch
			phase = fmod(phase + frequency / SFX_RATE, 1.0)
			var tone := 0.0
			match spec[3]:
				"square": tone = 1.0 if phase < 0.5 else -1.0
				"saw": tone = phase * 2.0 - 1.0
				"sine": tone = sin(phase * TAU)
			var noise := rng.randf_range(-1.0, 1.0)
			# Lower pitches darken the noise (a one-pole low-pass that follows the sweep).
			smoothed = lerpf(smoothed, noise, clampf(frequency / 2000.0, 0.02, 1.0))
			var sample := lerpf(tone * 0.5, smoothed, spec[4])
			var attack := minf(1.0, i / (0.004 * SFX_RATE))
			var decay := (1.0 - t) if last else 1.0
			out.append(sample * attack * decay * decay)
	# Filtered noise comes out much quieter than tones (the explosion peaked at 0.24); normalize so
	# volume means the same for every preset.
	var peak := 0.0
	for value in out:
		peak = maxf(peak, absf(value))
	if peak > 0.0:
		for i in range(out.size()):
			out[i] /= peak
	return out


# --- paint_tilemap_ascii --------------------------------------------------------------------

# Paints a TileMapLayer from text rows, one character per cell, through a legend such as
# {"#": {"source_id": 0, "atlas_coords": [1, 0]}, ".": "erase"}. Spaces leave cells unchanged.
func _paint_tilemap_ascii(client_id: int, params: Dictionary, command_id: String) -> void:
	var layer := _get_editor_node(str(params.get("node_path", ""))) as TileMapLayer
	if layer == null:
		return _send_error(client_id, "node_path must be a TileMapLayer", command_id)
	if layer.tile_set == null:
		return _send_error(client_id, "%s has no TileSet" % params.get("node_path"), command_id)
	var rows: Array = params.get("rows", [])
	var legend = params.get("legend", {})
	if rows.is_empty() or typeof(legend) != TYPE_DICTIONARY or (legend as Dictionary).is_empty():
		return _send_error(client_id, "rows (list of strings) and legend ({char: tile or \"erase\"}) are required", command_id)
	var tiles := {}
	for key in legend:
		var symbol := str(key)
		if symbol.length() != 1:
			return _send_error(client_id, "Legend keys must be single characters: %s" % symbol, command_id)
		var entry = legend[key]
		if str(entry) == "erase":
			tiles[symbol] = [-1, Vector2i(-1, -1), 0]
			continue
		if typeof(entry) != TYPE_DICTIONARY:
			return _send_error(client_id, "Legend %s must be {source_id, atlas_coords, alternative} or \"erase\"" % symbol, command_id)
		var source_id := int(entry.get("source_id", 0))
		var atlas := Vector2i(_coerce_to_vector2(entry.get("atlas_coords", [0, 0])))
		if not layer.tile_set.has_source(source_id):
			return _send_error(client_id, "TileSet has no source %d (legend %s)" % [source_id, symbol], command_id)
		var source := layer.tile_set.get_source(source_id)
		if source is TileSetAtlasSource and not source.has_tile(atlas):
			return _send_error(client_id, "Source %d has no tile at %s (legend %s)" % [source_id, atlas, symbol], command_id)
		tiles[symbol] = [source_id, atlas, int(entry.get("alternative", 0))]
	var origin := Vector2i(_coerce_to_vector2(params.get("origin", [0, 0])))
	var cells: Array = []
	for y in range(rows.size()):
		var row := str(rows[y])
		for x in range(row.length()):
			var symbol := row[x]
			if symbol == " ":
				continue
			if not tiles.has(symbol):
				return _send_error(client_id, "Row %d uses '%s', which is not in the legend" % [y, symbol], command_id)
			cells.append([origin + Vector2i(x, y), tiles[symbol]])
	if cells.size() > 20000:
		return _send_error(client_id, "Too many cells (%d, limit 20000)" % cells.size(), command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Paint Tilemap ASCII", transaction_id, {"command": "paint_tilemap_ascii"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	for cell in cells:
		var coords: Vector2i = cell[0]
		var tile: Array = cell[1]
		transaction.add_do_method(layer, "set_cell", [coords, tile[0], tile[1], tile[2]])
		transaction.add_undo_method(layer, "set_cell", [coords, layer.get_cell_source_id(coords), layer.get_cell_atlas_coords(coords), layer.get_cell_alternative_tile(coords)])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {"node_path": _to_mcp_path(layer), "cells": cells.size(), "rows": rows.size()})


# --- build_blockout_3d ----------------------------------------------------------------------

func _build_blockout_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	var blocks: Array = params.get("blocks", [])
	if blocks.is_empty() or blocks.size() > 500:
		return _send_error(client_id, "blocks must list 1 to 500 blocks", command_id)
	var group := Node3D.new()
	group.name = _unique_child_name(parent, str(params.get("name", "Blockout")))
	var materials := {}
	var scene_root := EditorInterface.get_edited_scene_root()
	var owned: Array = []
	for index in range(blocks.size()):
		var spec = blocks[index]
		if typeof(spec) != TYPE_DICTIONARY:
			group.free()
			return _send_error(client_id, "blocks[%d] must be an object" % index, command_id)
		var kind := str(spec.get("shape", "box"))
		if not kind in ["box", "sphere", "cylinder", "capsule"]:
			group.free()
			return _send_error(client_id, "blocks[%d].shape must be box, sphere, cylinder or capsule" % index, command_id)
		var size = _coerce_to_vector3(spec.get("size", [1, 1, 1]))
		if not size is Vector3 or size.x <= 0 or size.y <= 0 or size.z <= 0:
			group.free()
			return _send_error(client_id, "blocks[%d].size must be {x, y, z} above 0" % index, command_id)
		var color = _coerce_value_to_type(spec.get("color", "#9aa0a6"), TYPE_COLOR)
		if not color is Color:
			group.free()
			return _send_error(client_id, "blocks[%d].color must be a color" % index, command_id)
		var with_collision: bool = spec.get("collision", true)
		var root: Node3D = StaticBody3D.new() if with_collision else Node3D.new()
		root.name = str(spec.get("name", "%s%d" % [kind.capitalize(), index + 1]))
		root.position = _coerce_to_vector3(spec.get("position", [0, 0, 0]))
		root.rotation_degrees = _coerce_to_vector3(spec.get("rotation_degrees", [0, 0, 0]))
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "Mesh"
		var mesh
		var shape
		match kind:
			"box":
				mesh = BoxMesh.new()
				mesh.size = size
				shape = BoxShape3D.new()
				shape.size = size
			"sphere":
				mesh = SphereMesh.new()
				mesh.radius = size.x / 2.0
				mesh.height = size.y
				shape = SphereShape3D.new()
				shape.radius = size.x / 2.0
			"cylinder":
				mesh = CylinderMesh.new()
				mesh.top_radius = size.x / 2.0
				mesh.bottom_radius = size.x / 2.0
				mesh.height = size.y
				shape = CylinderShape3D.new()
				shape.radius = size.x / 2.0
				shape.height = size.y
			"capsule":
				mesh = CapsuleMesh.new()
				mesh.radius = size.x / 2.0
				mesh.height = maxf(size.y, size.x)
				shape = CapsuleShape3D.new()
				shape.radius = size.x / 2.0
				shape.height = maxf(size.y, size.x)
		if not materials.has(color):
			var material := StandardMaterial3D.new()
			material.albedo_color = color
			materials[color] = material
		mesh.material = materials[color]
		mesh_instance.mesh = mesh
		root.add_child(mesh_instance)
		owned.append(mesh_instance)
		if with_collision:
			var collision := CollisionShape3D.new()
			collision.name = "Collision"
			collision.shape = shape
			root.add_child(collision)
			owned.append(collision)
		group.add_child(root)
		owned.append(root)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Build Blockout 3D", transaction_id, {"command": "build_blockout_3d"})
	if not transaction:
		group.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_method(parent, "add_child", [group, true])
	transaction.add_do_method(group, "set_owner", [scene_root])
	for node in owned:
		transaction.add_do_method(node, "set_owner", [scene_root])
	transaction.add_do_reference(group)
	transaction.add_undo_method(parent, "remove_child", [group])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), str(group.name)), "blocks": blocks.size(), "materials": materials.size()})


# --- setup_2d_lighting ----------------------------------------------------------------------

# Darkens the scene with a CanvasModulate and adds PointLight2D glows that share one soft radial
# texture (no image files needed).
func _setup_2d_lighting(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	var darkness = _coerce_value_to_type(params.get("darkness", "#3a3f5c"), TYPE_COLOR)
	if not darkness is Color:
		return _send_error(client_id, "darkness must be a color", command_id)
	var lights: Array = params.get("lights", [])
	if lights.size() > 64:
		return _send_error(client_id, "At most 64 lights per call", command_id)
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Setup 2D Lighting", transaction_id, {"command": "setup_2d_lighting"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var modulate: CanvasModulate = null
	for child in parent.get_children():
		if child is CanvasModulate:
			modulate = child
	if modulate:
		transaction.add_do_property(modulate, "color", darkness)
		transaction.add_undo_property(modulate, "color", modulate.color)
	else:
		modulate = CanvasModulate.new()
		modulate.name = "Darkness"
		modulate.color = darkness
		_add_owned(transaction, parent, modulate, scene_root)
	var glow := GradientTexture2D.new()
	glow.width = 256
	glow.height = 256
	glow.fill = GradientTexture2D.FILL_RADIAL
	glow.fill_from = Vector2(0.5, 0.5)
	glow.fill_to = Vector2(1.0, 0.5)
	glow.gradient = Gradient.new()
	glow.gradient.set_color(0, Color(1, 1, 1, 1))
	glow.gradient.set_color(1, Color(1, 1, 1, 0))
	var names: Array = []
	for index in range(lights.size()):
		var spec = lights[index]
		if typeof(spec) != TYPE_DICTIONARY:
			return _send_error(client_id, "lights[%d] must be an object" % index, command_id)
		var color = _coerce_value_to_type(spec.get("color", "#ffd9a0"), TYPE_COLOR)
		if not color is Color:
			return _send_error(client_id, "lights[%d].color must be a color" % index, command_id)
		var light := PointLight2D.new()
		light.name = _unique_child_name(parent, str(spec.get("name", "Light%d" % (index + 1))))
		light.position = _coerce_to_vector2(spec.get("position", [0, 0]))
		light.color = color
		light.energy = float(spec.get("energy", 1.0))
		light.texture = glow
		light.texture_scale = maxf(float(spec.get("radius", 160.0)), 4.0) / 128.0
		light.shadow_enabled = bool(spec.get("shadows", false))
		_add_owned(transaction, parent, light, scene_root)
		names.append(str(light.name))
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"parent_path": _to_mcp_path(parent), "darkness": var_to_str(darkness), "lights": names})


func _add_owned(transaction, parent: Node, node: Node, owner: Node) -> void:
	transaction.add_do_method(parent, "add_child", [node, true])
	transaction.add_do_method(node, "set_owner", [owner])
	transaction.add_do_reference(node)
	transaction.add_undo_method(parent, "remove_child", [node])
