@tool
class_name MCPPolishCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Polish and prototyping: ragdolls, full-screen effects, a day/night cycle, MultiMesh merging,
## texture import presets, sound randomizers and placeholder sprites.

const FINGER_WORDS := ["thumb", "index", "middle", "ring", "pinky", "little", "finger"]
const JOINT_TYPES := {"pin": 1, "cone": 2, "hinge": 3}
# Screen effects read the frame through hint_screen_texture, or (vignette, damage_flash) only draw on top.
const SCREEN_EFFECTS := {
	"vignette": """shader_type canvas_item;
// Darker edges that pull the eye to the middle.
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.6;
uniform float softness : hint_range(0.05, 1.0) = 0.45;

void fragment() {
	float d = distance(SCREEN_UV, vec2(0.5)) * 1.414;
	COLOR = vec4(color.rgb, smoothstep(1.0 - softness, 1.0, d) * strength * color.a);
}
""",
	"damage_flash": """shader_type canvas_item;
// Red edges when hurt: animate amount from 1 to 0 (tween or AnimationPlayer).
uniform vec4 color : source_color = vec4(0.85, 0.05, 0.05, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float d = distance(SCREEN_UV, vec2(0.5)) * 1.414;
	COLOR = vec4(color.rgb, amount * (0.15 + 0.85 * smoothstep(0.35, 1.0, d)));
}
""",
	"crt": """shader_type canvas_item;
// Old TV: bent glass, scan lines, a little color fringing and dark corners.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float curvature : hint_range(0.0, 0.3) = 0.08;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_count = 240.0;
uniform float fringe : hint_range(0.0, 4.0) = 1.0;

void fragment() {
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	uv *= 1.0 + curvature * dot(uv.yx, uv.yx);
	uv = uv * 0.5 + 0.5;
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		vec2 shift = vec2(SCREEN_PIXEL_SIZE.x * fringe, 0.0);
		vec3 color = vec3(texture(screen_texture, uv + shift).r, texture(screen_texture, uv).g, texture(screen_texture, uv - shift).b);
		color *= 1.0 - scanline_strength * (0.5 + 0.5 * sin(uv.y * scanline_count * 6.2832));
		color *= 1.0 - 0.6 * pow(distance(uv, vec2(0.5)) * 1.3, 3.0);
		COLOR = vec4(color, 1.0);
	}
}
""",
	"pixelate": """shader_type canvas_item;
// Big chunky pixels; pixel_size is in screen pixels.
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float pixel_size : hint_range(1.0, 64.0) = 4.0;

void fragment() {
	vec2 cell = SCREEN_PIXEL_SIZE * pixel_size;
	COLOR = vec4(texture(screen_texture, (floor(SCREEN_UV / cell) + 0.5) * cell).rgb, 1.0);
}
""",
	"chromatic_aberration": """shader_type canvas_item;
// Red and blue split apart toward the edges (impacts, dizziness).
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float offset : hint_range(0.0, 20.0) = 3.0;

void fragment() {
	vec2 dir = (SCREEN_UV - vec2(0.5)) * SCREEN_PIXEL_SIZE * offset * 2.0;
	COLOR = vec4(texture(screen_texture, SCREEN_UV + dir).r, texture(screen_texture, SCREEN_UV).g, texture(screen_texture, SCREEN_UV - dir).b, 1.0);
}
""",
	"grayscale": """shader_type canvas_item;
// Drain the color: amount 1 is fully gray (game over, flashbacks).
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	COLOR = vec4(mix(color, vec3(dot(color, vec3(0.299, 0.587, 0.114))), amount), 1.0);
}
""",
	"blur": """shader_type canvas_item;
// Soft blur behind pause menus and dialogs.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	COLOR = vec4(textureLod(screen_texture, SCREEN_UV, amount).rgb, 1.0);
}
""",
	"color_grade": """shader_type canvas_item;
// Brightness, contrast, saturation and a tint over the whole screen.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast : hint_range(0.0, 3.0) = 1.1;
uniform float saturation : hint_range(0.0, 3.0) = 1.15;
uniform vec4 tint : source_color = vec4(1.0, 0.97, 0.92, 1.0);

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb + brightness;
	color = (color - 0.5) * contrast + 0.5;
	color = mix(vec3(dot(color, vec3(0.299, 0.587, 0.114))), color, saturation);
	COLOR = vec4(clamp(color * tint.rgb, 0.0, 1.0), 1.0);
}
""",
}
# Texture import options per preset (ResourceImporterTexture).
const TEXTURE_PRESETS := {
	"pixel_art": {"compress/mode": 0, "mipmaps/generate": false, "process/fix_alpha_border": true, "detect_3d/compress_to": 0},
	"ui": {"compress/mode": 0, "mipmaps/generate": false, "process/fix_alpha_border": true, "detect_3d/compress_to": 0},
	"3d": {"compress/mode": 2, "mipmaps/generate": true, "compress/normal_map": 0, "detect_3d/compress_to": 0},
	"normal_map": {"compress/mode": 2, "mipmaps/generate": true, "compress/normal_map": 1, "detect_3d/compress_to": 0},
}
const COMPRESS_MODES := {"lossless": 0, "lossy": 1, "vram": 2, "uncompressed": 3, "basis": 4}
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg", "tga", "bmp", "exr", "hdr"]
const RANDOM_MODES := {"random_no_repeat": 0, "random": 1, "sequential": 2}
const PLACEHOLDER_COLORS := {
	"circle": "#4c8bf5", "square": "#7a7f8c", "rounded_square": "#5bbf72", "triangle": "#e8a33d", "diamond": "#3fc1c9",
	"star": "#ffd23f", "heart": "#e84a5f", "capsule": "#9b6bd6", "character": "#4cc76b", "coin": "#f5c542",
	"tile": "#8a6f4d", "crate": "#a8743a", "arrow": "#e8e8e8",
}


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"create_ragdoll":
			_create_ragdoll(client_id, params, command_id)
		"add_screen_effect":
			_add_screen_effect(client_id, params, command_id)
		"setup_day_night_cycle":
			_setup_day_night_cycle(client_id, params, command_id)
		"convert_to_multimesh":
			_convert_to_multimesh(client_id, params, command_id)
		"configure_texture_import":
			_configure_texture_import(client_id, params, command_id)
		"create_audio_randomizer":
			_create_audio_randomizer(client_id, params, command_id)
		"generate_placeholder_art":
			_generate_placeholder_art(client_id, params, command_id)
		_:
			return false
	return true


# --- ragdoll --------------------------------------------------------------------------------

# Like Skeleton3D > Create Physical Skeleton: one PhysicalBone3D per bone that has a child, with a
# capsule from the bone to that child. Leaf bones, fingers and tiny bones are skipped.
func _create_ragdoll(client_id: int, params: Dictionary, command_id: String) -> void:
	var path := str(params.get("skeleton_path", "/root"))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	for child in skeleton.get_children():
		if child is PhysicalBoneSimulator3D and child.get_child_count() > 0:
			return _send_error(client_id, "%s already has a ragdoll (%s); delete it first" % [skeleton.name, child.name], command_id)
	var joint := str(params.get("joint_type", "pin"))
	if not JOINT_TYPES.has(joint):
		return _send_error(client_id, "joint_type must be pin, cone or hinge", command_id)
	var skip_fingers := bool(params.get("skip_fingers", true))
	var min_length := maxf(float(params.get("min_length", 0.03)), 0.0)
	var total_mass := clampf(float(params.get("total_mass", 70.0)), 0.1, 100000.0)
	var thickness := clampf(float(params.get("thickness", 1.0)), 0.1, 10.0)
	var plans: Array = []
	var skipped := 0
	for bone in skeleton.get_bone_count():
		var lower := skeleton.get_bone_name(bone).to_lower()
		var children := skeleton.get_bone_children(bone)
		if children.is_empty() or (skip_fingers and FINGER_WORDS.any(func(word): return word in lower)):
			skipped += 1
			continue
		var child_rest := skeleton.get_bone_rest(children[0])
		var length := child_rest.origin.length()
		if length < min_length:
			skipped += 1
			continue
		plans.append([bone, child_rest, length])
	if plans.is_empty():
		return _send_error(client_id, "No bone is long enough for a ragdoll part (min_length %.3f)" % min_length, command_id)
	var length_sum := 0.0
	for plan in plans:
		length_sum += plan[2]
	var simulator := PhysicalBoneSimulator3D.new()
	simulator.name = _unique_child_name(skeleton, "PhysicalBoneSimulator3D")
	var made: Array = []
	for plan in plans:
		var child_rest: Transform3D = plan[1]
		var half_height: float = plan[2] * 0.5
		var capsule := CapsuleShape3D.new()
		capsule.radius = maxf(half_height * 0.2 * thickness, 0.005)
		capsule.height = maxf(half_height * 2.0, capsule.radius * 2.0)
		var shape := CollisionShape3D.new()
		shape.name = "CollisionShape3D"
		shape.shape = capsule
		# The capsule's Y axis runs along the body's -Z, which looks down the bone.
		shape.transform = Transform3D(Basis(Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0)), Vector3.ZERO)
		var up := Vector3.UP if not Vector3.UP.cross(child_rest.origin).is_zero_approx() else Vector3.BACK
		var body_basis := Basis.looking_at(child_rest.origin, up)
		var physical := PhysicalBone3D.new()
		physical.name = ("Physical Bone " + skeleton.get_bone_name(plan[0])).validate_node_name()
		physical.set("bone_name", skeleton.get_bone_name(plan[0]))
		physical.body_offset = Transform3D(body_basis, body_basis * Vector3(0, 0, -half_height))
		physical.joint_offset = Transform3D(Basis(), Vector3(0, 0, half_height))
		physical.joint_type = JOINT_TYPES[joint]
		physical.mass = maxf(total_mass * plan[2] / length_sum, 0.01)
		physical.add_child(shape)
		simulator.add_child(physical)
		made.append(skeleton.get_bone_name(plan[0]))
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Create Ragdoll", transaction_id, {"command": "create_ragdoll"})
	if not transaction:
		simulator.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, skeleton, simulator, scene_root)
	for inner in simulator.find_children("*", "", true, false):
		transaction.add_do_method(inner, "set_owner", [scene_root])
	var opened := _open_instances(transaction, [skeleton])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(skeleton), simulator.name), "bones": made, "skipped": skipped,
		"joint_type": joint, "total_mass": total_mass, "editable_children": opened})


# --- screen effects -------------------------------------------------------------------------

func _add_screen_effect(client_id: int, params: Dictionary, command_id: String) -> void:
	var effect := str(params.get("effect", ""))
	if not SCREEN_EFFECTS.has(effect):
		return _send_error(client_id, "effect must be one of: %s" % ", ".join(PackedStringArray(SCREEN_EFFECTS.keys())), command_id)
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	var shader_path := "res://shaders/screen_%s.gdshader" % effect
	if not FileAccess.file_exists(shader_path):
		DirAccess.make_dir_recursive_absolute(shader_path.get_base_dir())
		var file := FileAccess.open(shader_path, FileAccess.WRITE)
		if file == null:
			return _send_error(client_id, "Failed to write %s" % shader_path, command_id)
		file.store_string(SCREEN_EFFECTS[effect])
		file = null
		EditorInterface.get_resource_filesystem().update_file(shader_path)
	var shader := ResourceLoader.load(shader_path, "Shader", ResourceLoader.CACHE_MODE_REPLACE) as Shader
	if shader == null:
		return _send_error(client_id, "Failed to load %s as a shader" % shader_path, command_id)
	var material := ShaderMaterial.new()
	material.shader = shader
	var known := {}
	for info in shader.get_shader_uniform_list():
		known[info["name"]] = info
	var uniforms = params.get("uniforms", {})
	if typeof(uniforms) != TYPE_DICTIONARY:
		return _send_error(client_id, "uniforms must be an object", command_id)
	for name in uniforms:
		if not known.has(name) or int(known[name]["hint"]) == PROPERTY_HINT_RESOURCE_TYPE:
			return _send_error(client_id, "Unknown uniform %s; %s has: %s" % [name, effect, ", ".join(PackedStringArray(known.keys().filter(func(key): return key != "screen_texture")))], command_id)
		var wanted_type := int(known[name]["type"])
		var value = _coerce_value_to_type(uniforms[name], wanted_type)
		if typeof(value) != wanted_type and not (typeof(value) in [TYPE_INT, TYPE_FLOAT] and wanted_type in [TYPE_INT, TYPE_FLOAT]):
			return _send_error(client_id, "Uniform %s expects %s, got %s" % [name, type_string(wanted_type), JSON.stringify(uniforms[name])], command_id)
		material.set_shader_parameter(name, value)
	# One CanvasLayer per effect, stacked above earlier ones, so each effect sees the ones below it.
	var stacked := 0
	for child in parent.get_children():
		if child is CanvasLayer and str(child.name).begins_with("ScreenEffect"):
			stacked += 1
	var layer := CanvasLayer.new()
	layer.name = _unique_child_name(parent, "ScreenEffect" + effect.to_pascal_case())
	layer.layer = clampi(int(params.get("layer", 100 + stacked)), -128, 128)
	var rect := ColorRect.new()
	rect.name = "Effect"
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.material = material
	layer.add_child(rect)
	layer.visible = bool(params.get("enabled", true))
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Add Screen Effect", transaction_id, {"command": "add_screen_effect"})
	if not transaction:
		layer.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, parent, layer, scene_root)
	transaction.add_do_method(rect, "set_owner", [scene_root])
	transaction.register_on_commit(func(): _mark_scene_modified())
	var layer_path := _join_path(_to_mcp_path(parent), layer.name)
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": layer_path, "rect_path": _join_path(layer_path, "Effect"), "effect": effect, "layer": layer.layer,
		"shader_path": shader_path, "uniforms": known.keys().filter(func(key): return key != "screen_texture")})


# --- day and night --------------------------------------------------------------------------

func _setup_day_night_cycle(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent = _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent is Node3D:
		return _send_error(client_id, "parent_path must be a 3D node", command_id)
	var day_length := clampf(float(params.get("day_length", 120.0)), 1.0, 86400.0)
	var start := fposmod(float(params.get("start_time", 0.0)), 1.0)
	var scene_root := EditorInterface.get_edited_scene_root()
	for existing in parent.find_children("*", "AnimationPlayer", true, true):
		if existing.has_animation("day_night"):
			return _send_error(client_id, "%s already runs a day/night cycle; delete it first (two would fight over the sun)" % _to_mcp_path(existing), command_id)
	var created: Array = []
	var sun: DirectionalLight3D = null
	if params.has("sun_path"):
		sun = _get_editor_node(str(params["sun_path"])) as DirectionalLight3D
		if not sun:
			return _send_error(client_id, "sun_path must be a DirectionalLight3D", command_id)
		if not parent.is_ancestor_of(sun):
			return _send_error(client_id, "sun_path must be under parent_path so the cycle's tracks can reach it", command_id)
	else:
		var suns := parent.find_children("*", "DirectionalLight3D", true, true)
		sun = suns[0] if not suns.is_empty() else null
	var new_nodes: Array = []
	if not sun:
		sun = DirectionalLight3D.new()
		sun.name = _unique_child_name(parent, "Sun")
		sun.shadow_enabled = true
		new_nodes.append(sun)
		created.append("Sun")
	var worlds := parent.find_children("*", "WorldEnvironment", true, true)
	var world: WorldEnvironment = worlds[0] if not worlds.is_empty() else null
	var sky_material: ProceduralSkyMaterial = null
	if not world:
		world = WorldEnvironment.new()
		world.name = _unique_child_name(parent, "WorldEnvironment")
		new_nodes.append(world)
		created.append("WorldEnvironment")
	var environment: Environment = world.environment
	var new_environment := environment == null
	if new_environment:
		environment = Environment.new()
		environment.background_mode = Environment.BG_SKY
		environment.sky = Sky.new()
		environment.sky.sky_material = ProceduralSkyMaterial.new()
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		if new_nodes.has(world):
			world.environment = environment
		else:
			created.append("Environment")
	if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
		sky_material = environment.sky.sky_material
	var player := AnimationPlayer.new()
	player.name = _unique_child_name(parent, "DayNightCycle")
	var sun_path := str(parent.get_path_to(sun)) if not new_nodes.has(sun) else str(sun.name)
	var world_path := str(parent.get_path_to(world)) if not new_nodes.has(world) else str(world.name)
	var animation := Animation.new()
	animation.length = day_length
	animation.loop_mode = Animation.LOOP_LINEAR
	var yaw := sun.rotation.y
	# Fractions of the day: 0 sunrise, 0.25 noon, 0.5 sunset, 0.5-1 night. The sun turns one full
	# circle, so the end matches the start and the loop is seamless.
	_add_track(animation, sun_path + ":rotation", day_length, [
		[0.0, Vector3(deg_to_rad(-5.0), yaw, 0)], [0.25, Vector3(deg_to_rad(-90.0), yaw, 0)],
		[0.5, Vector3(deg_to_rad(-175.0), yaw, 0)], [1.0, Vector3(deg_to_rad(-365.0), yaw, 0)]], start, Vector3(-TAU, 0, 0))
	_add_track(animation, sun_path + ":light_energy", day_length, [
		[0.0, 0.2], [0.08, 1.0], [0.42, 1.0], [0.5, 0.2], [0.54, 0.0], [0.96, 0.0], [1.0, 0.2]], start)
	var warm := Color(1.0, 0.62, 0.38)
	var white := Color(1.0, 0.97, 0.92)
	_add_track(animation, sun_path + ":light_color", day_length, [[0.0, warm], [0.1, white], [0.4, white], [0.5, warm], [1.0, warm]], start)
	var tracks := ["sun rotation", "sun energy", "sun color", "ambient light"]
	# Night is moonlit, not black: dark blue sky with half the ambient light.
	_add_track(animation, world_path + ":environment:ambient_light_energy", day_length, [
		[0.0, 0.8], [0.12, 1.0], [0.42, 1.0], [0.5, 0.8], [0.58, 0.5], [0.92, 0.5], [1.0, 0.8]], start)
	if sky_material:
		var colors := {
			"sky_top_color": [Color(0.32, 0.42, 0.68), Color(0.22, 0.47, 0.88), Color(0.28, 0.27, 0.52), Color(0.04, 0.06, 0.14)],
			"sky_horizon_color": [Color(0.95, 0.62, 0.42), Color(0.68, 0.8, 0.95), Color(0.95, 0.5, 0.32), Color(0.1, 0.12, 0.22)],
			"ground_horizon_color": [Color(0.55, 0.42, 0.36), Color(0.62, 0.68, 0.75), Color(0.5, 0.36, 0.3), Color(0.07, 0.08, 0.12)],
			"ground_bottom_color": [Color(0.12, 0.1, 0.1), Color(0.2, 0.17, 0.13), Color(0.12, 0.09, 0.08), Color(0.03, 0.03, 0.05)],
		}
		for property in colors:
			var c: Array = colors[property]
			_add_track(animation, "%s:environment:sky:sky_material:%s" % [world_path, property], day_length,
				[[0.0, c[0]], [0.25, c[1]], [0.5, c[2]], [0.58, c[3]], [0.92, c[3]], [1.0, c[0]]], start)
		tracks.append("sky colors")
	var library := AnimationLibrary.new()
	library.add_animation("day_night", animation)
	player.add_animation_library("", library)
	player.autoplay = "day_night"
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Setup Day Night Cycle", transaction_id, {"command": "setup_day_night_cycle"})
	if not transaction:
		player.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	for node in new_nodes:
		_add_owned(transaction, parent, node, scene_root)
	if new_environment and not new_nodes.has(world):
		transaction.add_do_property(world, "environment", environment)
		transaction.add_undo_property(world, "environment", null)
	_add_owned(transaction, parent, player, scene_root)
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), player.name), "day_length": day_length, "created": created,
		"tracks": tracks, "sun": sun_path, "sky": sky_material != null, "start_time": start})


# Value track keyed at fractions (0..1) of a day of length seconds, starting the day at start.
# keys must cover 0 and 1; each later day differs by per_day (the sun turns one more full circle).
func _add_track(animation: Animation, path: String, length: float, keys: Array, start := 0.0, per_day = null) -> void:
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(path))
	animation.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
	animation.value_track_set_update_mode(track, Animation.UPDATE_CONTINUOUS)
	var times := {0.0: true, 1.0: true}
	for key in keys:
		times[fposmod(key[0] - start, 1.0)] = true
	var sorted: Array = times.keys()
	sorted.sort()
	for time in sorted:
		animation.track_insert_key(track, time * length, _sample_day(keys, start + time, per_day))


func _sample_day(keys: Array, fraction: float, per_day):
	if fraction > 1.0:
		var later = _sample_day(keys, fraction - 1.0, per_day)
		return later + per_day if per_day != null else later
	for index in range(1, keys.size()):
		if fraction <= keys[index][0]:
			var a: Array = keys[index - 1]
			var b: Array = keys[index]
			return lerp(a[1], b[1], (fraction - a[0]) / maxf(b[0] - a[0], 0.0001))
	return keys[-1][1]


# --- MultiMesh ------------------------------------------------------------------------------

# Many MeshInstance3D copies of one mesh become one MultiMeshInstance3D: one draw call instead of
# one per copy. Meshes with children (collision bodies) or scripts are left alone.
func _convert_to_multimesh(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent = _get_editor_node(str(params.get("parent_path", "")))
	if not parent is Node3D:
		return _send_error(client_id, "parent_path must be a 3D node", command_id)
	var min_count := clampi(int(params.get("min_count", 2)), 2, 100000)
	var candidates: Array = parent.find_children("*", "MeshInstance3D", true, true) if bool(params.get("recursive", false)) \
		else parent.get_children().filter(func(child): return child is MeshInstance3D)
	var groups := {}
	var skipped: Array = []
	var scene_root := EditorInterface.get_edited_scene_root()
	for mesh_instance in candidates:
		# Nodes inside an instanced scene belong to that scene's file; removing them would not save.
		if mesh_instance.mesh == null or mesh_instance.owner != scene_root:
			continue
		if mesh_instance.get_child_count() > 0 or mesh_instance.get_script() != null:
			skipped.append("%s (has children or a script)" % mesh_instance.name)
			continue
		var material: Material = mesh_instance.material_override
		var surface_overrides: Array = []
		for surface in mesh_instance.mesh.get_surface_count():
			if mesh_instance.get_surface_override_material(surface):
				surface_overrides.append(mesh_instance.get_surface_override_material(surface))
		if not surface_overrides.is_empty():
			if mesh_instance.mesh.get_surface_count() > 1 or material:
				skipped.append("%s (per-surface materials)" % mesh_instance.name)
				continue
			material = surface_overrides[0]
		var key := "%d/%d/%d" % [mesh_instance.mesh.get_instance_id(), material.get_instance_id() if material else 0, mesh_instance.cast_shadow]
		if not groups.has(key):
			groups[key] = {"mesh": mesh_instance.mesh, "material": material, "nodes": []}
		groups[key]["nodes"].append(mesh_instance)
	var merges: Array = groups.values().filter(func(group): return group["nodes"].size() >= min_count)
	if merges.is_empty():
		return _send_error(client_id, "No mesh repeats %d or more times under %s%s" % [min_count, _to_mcp_path(parent), "; skipped: " + ", ".join(PackedStringArray(skipped.slice(0, 10))) if not skipped.is_empty() else ""], command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Convert To MultiMesh", transaction_id, {"command": "convert_to_multimesh"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var summary: Array = []
	var removed := 0
	for group in merges:
		var nodes: Array = group["nodes"]
		var to_parent: Transform3D = parent.global_transform.affine_inverse()
		var transforms: Array = nodes.map(func(node): return to_parent * node.global_transform)
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = group["mesh"]
		multimesh.instance_count = transforms.size()
		multimesh.buffer = _multimesh_buffer_3d(transforms)
		var merged := MultiMeshInstance3D.new()
		var base_name: String = group["mesh"].resource_name if not group["mesh"].resource_name.is_empty() else str(nodes[0].name).rstrip("0123456789")
		merged.name = _unique_child_name(parent, (base_name + "MultiMesh").validate_node_name())
		merged.multimesh = multimesh
		merged.material_override = group["material"]
		merged.cast_shadow = nodes[0].cast_shadow
		_add_owned(transaction, parent, merged, scene_root)
		for node in nodes:
			_remove_with_undo(transaction, node)
		removed += nodes.size()
		summary.append("%s: %d copies" % [_join_path(_to_mcp_path(parent), merged.name), nodes.size()])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"merged": summary, "nodes_removed": removed, "multimeshes": merges.size(), "skipped": skipped.slice(0, 20)})


# --- texture import -------------------------------------------------------------------------

func _configure_texture_import(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset := str(params.get("preset", ""))
	if not preset.is_empty() and not TEXTURE_PRESETS.has(preset):
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PackedStringArray(TEXTURE_PRESETS.keys())), command_id)
	var options: Dictionary = TEXTURE_PRESETS.get(preset, {}).duplicate()
	if params.has("compress"):
		if not COMPRESS_MODES.has(str(params["compress"])):
			return _send_error(client_id, "compress must be one of: %s" % ", ".join(PackedStringArray(COMPRESS_MODES.keys())), command_id)
		options["compress/mode"] = COMPRESS_MODES[str(params["compress"])]
	if params.has("mipmaps"):
		options["mipmaps/generate"] = bool(params["mipmaps"])
	if params.has("size_limit"):
		options["process/size_limit"] = clampi(int(params["size_limit"]), 0, 16384)
	if params.has("normal_map"):
		options["compress/normal_map"] = 1 if bool(params["normal_map"]) else 2
	if options.is_empty():
		return _send_error(client_id, "Pass a preset or at least one of compress, mipmaps, size_limit, normal_map", command_id)
	var files: Array = []
	for entry in params.get("paths", []):
		var path := _contained_res_path(str(entry))
		if path.is_empty():
			return _send_error(client_id, "Not a project path: %s" % entry, command_id)
		if DirAccess.dir_exists_absolute(path):
			var dir := DirAccess.open(path)
			var found: Array = []
			_scan_directory(dir, path.trim_prefix("res://").trim_suffix("/") + "/" if path != "res://" else "", IMAGE_EXTENSIONS.map(func(ext): return "." + ext), found)
			files.append_array(found)
		elif FileAccess.file_exists(path) and path.get_extension().to_lower() in IMAGE_EXTENSIONS:
			files.append(path)
		else:
			return _send_error(client_id, "Not an image or folder: %s" % entry, command_id)
	if files.is_empty() or files.size() > 500:
		return _send_error(client_id, "paths must name 1 to 500 images (found %d)" % files.size(), command_id)
	var changed := PackedStringArray()
	var skipped: Array = []
	for path in files:
		var config := ConfigFile.new()
		if config.load(path + ".import") != OK or str(config.get_value("remap", "importer", "")) != "texture":
			skipped.append("%s (%s)" % [path.get_file(), "not imported yet" if not FileAccess.file_exists(path + ".import") else "imported as " + str(config.get_value("remap", "importer", "?"))])
			continue
		for key in options:
			config.set_value("params", key, options[key])
		if config.save(path + ".import") == OK:
			changed.append(path)
	if not changed.is_empty():
		EditorInterface.get_resource_filesystem().reimport_files(changed)
	_send_success(client_id, {"preset": preset, "options": options, "changed": changed.size(),
		"files": Array(changed).slice(0, 20), "skipped": skipped.slice(0, 20)}, command_id)


# --- audio ----------------------------------------------------------------------------------

func _create_audio_randomizer(client_id: int, params: Dictionary, command_id: String) -> void:
	var sounds: Array = params.get("sounds", [])
	if sounds.is_empty() or sounds.size() > 64:
		return _send_error(client_id, "sounds must list 1 to 64 audio files", command_id)
	var mode := str(params.get("mode", "random_no_repeat"))
	if not RANDOM_MODES.has(mode):
		return _send_error(client_id, "mode must be random_no_repeat, random or sequential", command_id)
	var randomizer := AudioStreamRandomizer.new()
	randomizer.playback_mode = RANDOM_MODES[mode]
	randomizer.random_pitch_semitones = clampf(float(params.get("pitch_variation", 1.0)), 0.0, 24.0)
	randomizer.random_volume_offset_db = clampf(float(params.get("volume_variation", 2.0)), 0.0, 40.0)
	for index in sounds.size():
		var path := _contained_res_path(str(sounds[index]))
		var stream = ResourceLoader.load(path) if not path.is_empty() and ResourceLoader.exists(path) else null
		if not stream is AudioStream:
			return _send_error(client_id, "sounds[%d] is not an imported audio file: %s" % [index, sounds[index]], command_id)
		randomizer.add_stream(index, stream, 1.0)
	var default_path := str(sounds[0]).get_base_dir().path_join(str(sounds[0]).get_file().get_basename() + "_random.tres")
	var save_path := _contained_res_path(str(params.get("save_path", default_path)))
	if save_path.is_empty() or _is_protected_path(save_path) or not save_path.get_extension() in ["tres", "res"]:
		return _send_error(client_id, "save_path must be a .tres or .res file in the project", command_id)
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if _save_resource_contained(randomizer, save_path) != OK:
		return _send_error(client_id, "Failed to save %s" % save_path, command_id)
	EditorInterface.get_resource_filesystem().update_file(save_path)
	var response := {"save_path": save_path, "sounds": sounds.size(), "mode": mode,
		"pitch_variation": snappedf(randomizer.random_pitch_semitones, 0.01), "volume_variation": snappedf(randomizer.random_volume_offset_db, 0.01)}
	if params.has("player_path"):
		var player = _get_editor_node(str(params["player_path"]))
		if not (player is AudioStreamPlayer or player is AudioStreamPlayer2D or player is AudioStreamPlayer3D):
			return _send_error(client_id, "Saved %s, but player_path is not an AudioStreamPlayer (2D/3D)" % save_path, command_id)
		var transaction = _transaction("Assign Audio Randomizer", "", {"command": "create_audio_randomizer"})
		if not transaction:
			return _send_error(client_id, "Failed to obtain scene transaction", command_id)
		transaction.add_do_property(player, "stream", randomizer)
		transaction.add_undo_property(player, "stream", player.stream)
		transaction.register_on_commit(func(): _mark_scene_modified())
		response["player_path"] = _to_mcp_path(player)
		return _finish_transaction(client_id, command_id, transaction, "", response)
	_send_success(client_id, response, command_id)


# --- placeholder art ------------------------------------------------------------------------

# Signed distance (pixels; negative inside) from p to a polygon (Inigo Quilez's method).
func _sd_polygon(p: Vector2, points: Array) -> float:
	var d: float = (p - points[0]).length_squared()
	var s := 1.0
	var j := points.size() - 1
	for i in points.size():
		var e: Vector2 = points[j] - points[i]
		var w: Vector2 = p - points[i]
		var b: Vector2 = w - e * clampf(w.dot(e) / e.length_squared(), 0.0, 1.0)
		d = minf(d, b.length_squared())
		var c := [p.y >= points[i].y, p.y < points[j].y, e.x * w.y > e.y * w.x]
		if (c[0] and c[1] and c[2]) or (not c[0] and not c[1] and not c[2]):
			s = -s
		j = i
	return s * sqrt(d)


func _sd_box(p: Vector2, half: Vector2) -> float:
	var q := p.abs() - half
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0)


func _sd_segment(p: Vector2, a: Vector2, b: Vector2, radius: float) -> float:
	var pa := p - a
	var ba := b - a
	var h := clampf(pa.dot(ba) / maxf(ba.length_squared(), 0.0001), 0.0, 1.0)
	return (pa - ba * h).length() - radius


# Distance to the outline of shape, with p measured from the image center.
func _shape_distance(shape: String, p: Vector2, half: Vector2) -> float:
	var r := minf(half.x, half.y)
	match shape:
		"circle", "coin":
			return p.length() - r
		"square", "tile", "crate":
			return _sd_box(p, half)
		"rounded_square":
			return _sd_box(p, half - Vector2.ONE * r * 0.25) - r * 0.25
		"capsule", "character":
			var along := maxf(half.y - half.x, 0.0)
			return _sd_segment(p, Vector2(0, -along), Vector2(0, along), half.x)
		"triangle":
			return _sd_polygon(p, [Vector2(0, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)])
		"diamond":
			return _sd_polygon(p, [Vector2(0, -half.y), Vector2(half.x, 0), Vector2(0, half.y), Vector2(-half.x, 0)])
		"star":
			var points: Array = []
			for i in 10:
				var angle := -PI / 2.0 + i * PI / 5.0
				var radius := 1.0 if i % 2 == 0 else 0.45
				points.append(Vector2(cos(angle) * half.x, sin(angle) * half.y) * radius)
			return _sd_polygon(p, points)
		"heart":
			# Inigo Quilez's exact heart: tip at (0, 0), lobes up to y 1.104, x within +-0.604.
			var unit := minf(half.x / 0.604, half.y * 2.0 / 1.104)
			var q := Vector2(absf(p.x), 1.104 * 0.5 - p.y / unit)
			if q.x + q.y > 1.0:
				return ((q - Vector2(0.25, 0.75)).length() - sqrt(2.0) / 4.0) * unit
			var to_top := (q - Vector2(0.0, 1.0)).length_squared()
			var to_edge := (q - Vector2.ONE * 0.5 * maxf(q.x + q.y, 0.0)).length_squared()
			return sqrt(minf(to_top, to_edge)) * signf(q.x - q.y) * unit
		"arrow":
			return _sd_polygon(p, [Vector2(-half.x, -half.y * 0.3), Vector2(half.x * 0.2, -half.y * 0.3), Vector2(half.x * 0.2, -half.y),
				Vector2(half.x, 0), Vector2(half.x * 0.2, half.y), Vector2(half.x * 0.2, half.y * 0.3), Vector2(-half.x, half.y * 0.3)])
	return 1.0


func _draw_placeholder(shape: String, size: Vector2i, fill: Color, outline: Color, outline_width: float) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	var margin := 0.0 if shape == "tile" else maxf(outline_width, 1.0) + 1.0
	var half := Vector2(size) * 0.5 - Vector2.ONE * margin
	var center := Vector2(size) * 0.5
	var r := minf(half.x, half.y)
	for y in size.y:
		for x in size.x:
			var p := Vector2(x + 0.5, y + 0.5) - center
			var d := _shape_distance(shape, p, half)
			var coverage := clampf(0.5 - d, 0.0, 1.0)
			if coverage <= 0.0:
				continue
			var color := fill.lerp(outline, clampf(d + outline_width + 0.5, 0.0, 1.0)) if outline_width > 0.0 else fill
			match shape:
				"tile":
					# Bevel: light top-left edge, dark bottom-right edge.
					var edge := maxf(2.0, minf(size.x, size.y) * 0.08)
					if x < edge or y < edge:
						color = color.lightened(0.25)
					elif x >= size.x - edge or y >= size.y - edge:
						color = color.darkened(0.3)
				"crate":
					var plank := r * 0.16
					var inner := _sd_box(p, half - Vector2.ONE * plank)
					var diagonal := absf(p.x - p.y * half.x / half.y) / sqrt(2.0)
					if inner > 0.0 or diagonal < plank * 0.5:
						color = color.darkened(0.25)
				"coin":
					if absf(p.length() - r * 0.72) < maxf(r * 0.06, 1.0):
						color = color.darkened(0.25)
					elif (p - Vector2(-r * 0.3, -r * 0.35)).length() < r * 0.14:
						color = color.lightened(0.5)
				"character":
					for side in [-1.0, 1.0]:
						var eye := p - Vector2(side * half.x * 0.38, -half.y * 0.35)
						if eye.length() < r * 0.11:
							color = Color(0.08, 0.08, 0.1)
						elif eye.length() < r * 0.24:
							color = Color.WHITE
			color.a *= coverage
			image.set_pixel(x, y, color)
	return image


func _generate_placeholder_art(client_id: int, params: Dictionary, command_id: String) -> void:
	var sprites: Array = params.get("sprites", [])
	if sprites.is_empty() or sprites.size() > 32:
		return _send_error(client_id, "sprites must list 1 to 32 sprites", command_id)
	var folder := _contained_res_path(str(params.get("folder", "res://art/placeholder")))
	if folder.is_empty() or _is_protected_path(folder.path_join("x")):
		return _send_error(client_id, "folder must be in the project", command_id)
	var made: Array = []
	var paths := PackedStringArray()
	for index in sprites.size():
		var spec = sprites[index]
		if typeof(spec) != TYPE_DICTIONARY:
			return _send_error(client_id, "sprites[%d] must be an object" % index, command_id)
		var shape := str(spec.get("shape", "square"))
		if not PLACEHOLDER_COLORS.has(shape):
			return _send_error(client_id, "sprites[%d].shape must be one of: %s" % [index, ", ".join(PackedStringArray(PLACEHOLDER_COLORS.keys()))], command_id)
		var raw_size = spec.get("size", 64)
		var as_vector = Vector2(raw_size, raw_size) if typeof(raw_size) in [TYPE_INT, TYPE_FLOAT] else _coerce_to_vector2(raw_size)
		if not as_vector is Vector2:
			return _send_error(client_id, "sprites[%d].size must be a number or [width, height]" % index, command_id)
		var size := Vector2i(as_vector)
		if size.x < 4 or size.y < 4 or size.x > 512 or size.y > 512:
			return _send_error(client_id, "sprites[%d].size must be 4 to 512 pixels" % index, command_id)
		var fill = _coerce_value_to_type(spec.get("color", PLACEHOLDER_COLORS[shape]), TYPE_COLOR)
		var outline = _coerce_value_to_type(spec.get("outline_color", "#1a1a1a"), TYPE_COLOR)
		if not fill is Color or not outline is Color:
			return _send_error(client_id, "sprites[%d]: color and outline_color must be colors" % index, command_id)
		var outline_width := clampf(float(spec.get("outline_width", 0.0 if shape == "tile" else 2.0)), 0.0, 32.0)
		var file_name := str(spec.get("name", "%s_%d" % [shape, index + 1])).validate_filename().to_snake_case()
		var path := folder.path_join(file_name + ".png")
		DirAccess.make_dir_recursive_absolute(folder)
		var image := _draw_placeholder(shape, size, fill, outline, outline_width)
		if image.save_png(ProjectSettings.globalize_path(path)) != OK:
			return _send_error(client_id, "Failed to write %s" % path, command_id)
		paths.append(path)
		made.append("%s (%s %dx%d)" % [path, shape, size.x, size.y])
	var imported := await _await_imports(Array(paths))
	_send_success(client_id, {"files": made, "imported": imported}, command_id)
