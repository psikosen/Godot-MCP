@tool
class_name MCPVfxCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Layered one-call effects: a hot core flash, sparks (sub-emitters where they fit), smoke, a short
## light pop and optional camera shake, in 3D or 2D.

const ParticleUtils := preload("res://addons/godot_mcp/utils/particle_utils.gd")

# 2D effects use the 3D numbers (meters, y up) at this many pixels per meter.
const PIXELS_PER_METER := 64.0
const WHITE := Color(1, 1, 1)
const PRESETS := ["explosion", "hit_impact", "muzzle_flash", "magic_burst", "fire", "sparks"]
const TINTS := {
	"explosion": Color(1.0, 0.45, 0.12), "hit_impact": Color(1.0, 0.75, 0.35), "muzzle_flash": Color(1.0, 0.7, 0.3),
	"magic_burst": Color(0.55, 0.35, 1.0), "fire": Color(1.0, 0.45, 0.1), "sparks": Color(1.0, 0.65, 0.25),
}

# Runs in the game: restarts the one-shot particles, pops (or flickers) the light, shakes the camera.
const PLAYER_SCRIPT := """extends {base}
# Built by Godot MCP build_vfx_effect. Call play() to fire the effect again; autoplay fires it
# when the node enters the game.

@export var autoplay := {autoplay}
@export var light_energy := {light_energy}
@export var light_time := {light_time}
@export var flicker := {flicker}
@export var shake_strength := {shake_strength}
@export var shake_time := {shake_time}

var _light: Node
var _camera: Node
var _shake_left := 0.0


func _ready() -> void:
	_light = get_node_or_null("Light")
	if _light and not flicker:
		_light.{energy} = 0.0
	if autoplay:
		play()
	else:
		for particles in find_children("*", "{particles}", true, false):
			if particles.one_shot:
				particles.emitting = false


func play() -> void:
	for particles in find_children("*", "{particles}", true, false):
		if particles.one_shot:
			particles.restart()
	if _light and not flicker:
		_light.{energy} = light_energy
		create_tween().tween_property(_light, "{energy}", 0.0, light_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if shake_strength > 0.0:
		_camera = get_viewport().{camera}()
		_shake_left = shake_time


func _process(delta: float) -> void:
	if flicker and _light:
		_light.{energy} = lerpf(_light.{energy}, light_energy * randf_range(0.65, 1.2), 0.25)
	if _shake_left > 0.0 and is_instance_valid(_camera):
		_shake_left = maxf(_shake_left - delta, 0.0)
		var k := shake_strength * _shake_left / shake_time
		{shake}
"""


# One smoke texture for every effect this editor session builds, so a scene stores it once.
var _smoke_texture: ImageTexture


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"build_vfx_effect":
			_build_vfx_effect(client_id, params, command_id)
		"build_pixel_vfx":
			_build_pixel_vfx(client_id, params, command_id)
		_:
			return false
	return true


# Hot to cold over life. Keep k near 1-2: a little above 1 blooms when the environment has glow
# on, more burns every hue to white.
func _hdr(color: Color, k: float, alpha := 1.0) -> Color:
	return Color(color.r * k, color.g * k, color.b * k, alpha)


# Each preset: tint, default forward (3D), light, shake, and its layers. A layer's numbers are meters
# and seconds; dir is forward (the direction param: a surface normal, a gun barrel; default up) or
# none (all around); offset lifts a layer along forward; flat lays it on the surface; a sub layer is
# a sub-emitter its parent's particles spawn. Additive layers keep alpha below 1 so overlaps add up
# to the hot color instead of white.
func _preset(preset: String, tint: Color) -> Dictionary:
	var hot := tint.lerp(WHITE, 0.55)
	var flash := func(amount: int, life: float, size: float, offset: float) -> Dictionary:
		return {"name": "Flash", "tex": "glow", "amount": amount, "life": life, "size": size, "offset": offset,
			"scale_curve": [[0.0, 0.6], [0.3, 1.0], [1.0, 1.15]], "alpha_curve": [1.0, 0.0],
			"colors": [_hdr(WHITE, 2.0, 0.9), _hdr(hot, 1.6, 0.8), _hdr(tint, 1.2, 0.0)], "add": true}
	var sparks := func() -> Array:
		return [_hdr(hot, 2.0), _hdr(tint, 1.6), _hdr(tint, 1.2, 0.0)]
	var smoke := func(amount: int, life: float, size: float, speed: Array, base: Color, alpha: float) -> Dictionary:
		return {"name": "Smoke", "tex": "smoke", "amount": amount, "life": life, "explosive": 0.85, "radius": size * 0.2,
			"dir": "forward", "spread": 60.0, "speed": speed, "gravity": 0.5, "damping": [0.8, 1.6], "size": size, "spin": true,
			"scale_curve": [[0.0, 0.35], [0.3, 0.9], [1.0, 1.4]], "alpha_curve": [[0.0, 0.0], [0.06, 1.0], [1.0, 0.0]],
			"colors": [Color(base, alpha), Color(base.lightened(0.3), alpha * 0.7), Color(base.lightened(0.45), 0.0)],
			"turbulence": [1.0, 2.5, 0.15], "sort": true}
	match preset:
		"explosion":
			return {"light": [10.0, 8.0, 0.35], "light_height": 1.0, "shake": [0.25, 0.45], "layers": [
				flash.call(4, 0.2, 2.4, 0.6),
				{"name": "Fireball", "tex": "smoke", "amount": 24, "life": 0.9, "explosive": 0.95, "radius": 0.35, "offset": 0.5,
					"dir": "none", "speed": [2.0, 5.0], "gravity": 1.5, "damping": [3.0, 5.0], "size": 1.8, "spin": true,
					"scale_curve": [[0.0, 0.4], [0.2, 1.0], [1.0, 1.3]],
					"colors": [_hdr(hot, 1.5, 0.8), _hdr(tint, 1.3, 0.7), _hdr(tint.darkened(0.5), 0.8, 0.4), Color(0.05, 0.04, 0.04, 0.0)], "add": true},
				{"name": "Sparks", "tex": "glow", "amount": 30, "life": 1.0, "explosive": 0.9, "radius": 0.2, "dir": "forward",
					"spread": 80.0, "speed": [6.0, 12.0], "gravity": -9.8, "damping": [0.5, 1.5], "size": Vector2(0.06, 0.5), "align": true,
					"colors": sparks.call(), "add": true,
					"sub": {"name": "SparkTrails", "mode": "constant", "frequency": 25.0, "tex": "glow", "amount": 400, "life": 0.35,
						"dir": "none", "speed": [0.0, 0.3], "gravity": -2.0, "size": 0.12, "scale_curve": [1.0, 0.0],
						"colors": [_hdr(hot, 1.6, 0.8), _hdr(tint, 1.0, 0.0)], "add": true}},
				smoke.call(18, 2.6, 2.2, [0.6, 1.8], Color(0.1, 0.09, 0.08), 0.85),
				{"name": "Shockwave", "tex": "ring", "amount": 1, "life": 0.4, "size": 6.0, "scale": [1.0, 1.0], "flat": true,
					"scale_curve": [[0.0, 0.15], [1.0, 1.0]], "alpha_curve": [1.0, 0.0],
					"colors": [_hdr(hot, 1.4, 0.7), _hdr(tint, 1.0, 0.0)], "add": true},
			]}
		"hit_impact":
			return {"light": [4.0, 3.0, 0.12], "light_height": 0.3, "shake": [0.06, 0.15], "layers": [
				flash.call(2, 0.1, 0.7, 0.15),
				{"name": "Sparks", "tex": "glow", "amount": 22, "life": 0.4, "radius": 0.02, "dir": "forward", "spread": 50.0,
					"speed": [3.0, 8.0], "gravity": -9.8, "damping": [1.0, 3.0], "size": Vector2(0.035, 0.3), "align": true,
					"colors": sparks.call(), "add": true},
				smoke.call(5, 0.9, 0.6, [0.4, 1.2], Color(0.35, 0.33, 0.3), 0.5),
				{"name": "Ring", "tex": "ring", "amount": 1, "life": 0.18, "size": 1.0, "scale": [1.0, 1.0], "flat": true,
					"scale_curve": [[0.0, 0.2], [1.0, 1.0]], "alpha_curve": [1.0, 0.0],
					"colors": [_hdr(hot, 1.4, 0.8), _hdr(tint, 1.0, 0.0)], "add": true},
			]}
		"muzzle_flash":
			return {"forward": Vector3(0, 0, -1), "light": [6.0, 4.0, 0.08], "light_height": 0.2, "shake": [0.03, 0.08], "layers": [
				flash.call(2, 0.08, 0.4, 0.05),
				{"name": "Flame", "tex": "glow", "amount": 10, "life": 0.1, "dir": "forward", "spread": 25.0, "speed": [3.0, 7.0],
					"damping": [10.0, 20.0], "size": Vector2(0.16, 0.6), "align": true,
					"colors": [_hdr(hot, 1.6, 0.8), _hdr(tint, 1.4, 0.7), _hdr(tint, 1.2, 0.0)], "add": true},
				{"name": "Sparks", "tex": "glow", "amount": 6, "life": 0.25, "dir": "forward", "spread": 15.0, "speed": [8.0, 14.0],
					"gravity": -4.0, "size": Vector2(0.025, 0.25), "align": true,
					"colors": sparks.call(), "add": true},
				smoke.call(6, 1.1, 0.5, [0.6, 1.6], Color(0.5, 0.48, 0.45), 0.35),
			]}
		"magic_burst":
			return {"light": [7.0, 6.0, 0.4], "light_height": 0.5, "shake": [0.12, 0.3], "layers": [
				{"name": "Flash", "tex": "glow", "amount": 3, "life": 0.3, "size": 1.8,
					"scale_curve": [[0.0, 0.6], [0.3, 1.0], [1.0, 1.15]], "alpha_curve": [1.0, 0.0],
					"colors": [_hdr(WHITE, 1.8, 0.9), _hdr(tint, 1.5, 0.8), _hdr(tint, 1.2, 0.0)], "add": true},
				{"name": "Orbs", "tex": "glow", "amount": 14, "life": 0.6, "radius": 0.15, "dir": "none", "speed": [3.0, 5.5],
					"damping": [4.0, 6.0], "size": 0.3, "scale_curve": [1.0, 0.6],
					"colors": [_hdr(tint.lerp(WHITE, 0.5), 1.8), _hdr(tint, 1.5)], "add": true,
					"sub": {"name": "Sparkles", "mode": "at_end", "count": 8, "tex": "glow", "amount": 128, "life": 0.7,
						"dir": "none", "speed": [1.0, 2.5], "gravity": -1.5, "damping": [1.0, 2.0], "size": 0.1, "scale_curve": [1.0, 0.0],
						"colors": [_hdr(WHITE, 1.8), _hdr(tint, 1.6), _hdr(tint, 1.2, 0.0)], "add": true}},
				{"name": "Ring", "tex": "ring", "amount": 1, "life": 0.5, "size": 4.0, "scale": [1.0, 1.0],
					"scale_curve": [[0.0, 0.1], [1.0, 1.0]], "alpha_curve": [1.0, 0.0],
					"colors": [_hdr(tint.lerp(WHITE, 0.4), 1.4, 0.8), _hdr(tint, 1.0, 0.0)], "add": true},
				{"name": "Mist", "tex": "smoke", "amount": 12, "life": 1.4, "explosive": 0.8, "radius": 0.5, "dir": "none",
					"speed": [0.3, 0.9], "gravity": 0.4, "damping": [0.5, 1.0], "size": 1.4, "spin": true,
					"scale_curve": [[0.0, 0.5], [1.0, 1.4]], "alpha_curve": [[0.0, 0.0], [0.2, 1.0], [1.0, 0.0]],
					"colors": [_hdr(tint, 0.8, 0.3), _hdr(tint, 0.6, 0.0)], "add": true, "turbulence": [1.5, 2.0, 0.2]},
			]}
		"fire":
			return {"loop": true, "light": [3.0, 6.0, 0.0], "light_height": 0.6, "flicker": true, "shake": [0.0, 0.0], "layers": [
				{"name": "Glow", "tex": "glow", "amount": 3, "life": 0.6, "explosive": 0.0, "size": 1.3, "offset": 0.3,
					"alpha_curve": [[0.0, 0.0], [0.5, 1.0], [1.0, 0.0]], "colors": [_hdr(tint, 0.6, 0.2), _hdr(tint, 0.5, 0.2)], "add": true},
				# Tongues: puffs stretched along their rise.
				{"name": "Flames", "tex": "smoke", "amount": 40, "life": 0.8, "explosive": 0.0, "radius": 0.25, "dir": "forward",
					"spread": 8.0, "speed": [1.2, 2.2], "gravity": 2.5, "damping": [0.0, 0.5], "size": Vector2(0.5, 1.1), "align": true,
					"scale_curve": [[0.0, 0.5], [0.25, 1.0], [1.0, 0.2]],
					"colors": [_hdr(hot, 1.4, 0.6), _hdr(tint, 1.3, 0.6), _hdr(tint.darkened(0.4), 0.9, 0.45), Color(0.05, 0.03, 0.02, 0.0)],
					"add": true, "turbulence": [0.8, 2.5, 0.15]},
				{"name": "Sparks", "tex": "glow", "amount": 12, "life": 1.8, "explosive": 0.0, "radius": 0.3, "dir": "forward",
					"spread": 30.0, "speed": [1.0, 2.5], "gravity": 1.0, "damping": [0.2, 0.6], "size": 0.06,
					"colors": sparks.call(), "add": true, "turbulence": [2.0, 1.5, 0.3]},
				{"name": "Smoke", "tex": "smoke", "amount": 14, "life": 3.2, "explosive": 0.0, "radius": 0.35, "dir": "forward",
					"spread": 15.0, "speed": [0.6, 1.2], "gravity": 0.5, "size": 1.4, "spin": true, "offset": 1.2,
					"scale_curve": [[0.0, 0.4], [1.0, 1.6]], "alpha_curve": [[0.0, 0.0], [0.2, 1.0], [1.0, 0.0]],
					"colors": [Color(0.07, 0.06, 0.05, 0.7), Color(0.22, 0.22, 0.22, 0.0)], "turbulence": [1.0, 2.0, 0.15], "sort": true},
			]}
		"sparks":
			return {"light": [3.0, 3.0, 0.15], "light_height": 0.3, "shake": [0.04, 0.12], "layers": [
				flash.call(2, 0.08, 0.5, 0.1),
				{"name": "Sparks", "tex": "glow", "amount": 50, "life": 0.8, "explosive": 0.95, "radius": 0.05, "dir": "forward",
					"spread": 70.0, "speed": [3.0, 8.0], "gravity": -9.8, "damping": [0.3, 1.0], "size": Vector2(0.03, 0.3), "align": true,
					"colors": sparks.call(), "add": true,
					"sub": {"name": "SparkPops", "mode": "at_end", "count": 3, "tex": "glow", "amount": 150, "life": 0.25,
						"dir": "none", "speed": [0.5, 1.5], "gravity": -3.0, "size": 0.08, "scale_curve": [1.0, 0.0],
						"colors": [_hdr(hot, 1.8), _hdr(tint, 1.2, 0.0)], "add": true}},
				smoke.call(4, 1.2, 0.4, [0.2, 0.6], Color(0.4, 0.38, 0.35), 0.35),
			]}
	return {}


func _build_vfx_effect(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset := str(params.get("preset", ""))
	if not preset in PRESETS:
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PRESETS), command_id)
	var dimension := str(params.get("dimension", "3d")).to_lower()
	if not dimension in ["2d", "3d"]:
		return _send_error(client_id, "dimension must be 2d or 3d", command_id)
	var is_2d := dimension == "2d"
	var scene_root := EditorInterface.get_edited_scene_root()
	if not scene_root:
		return _send_error(client_id, "No scene is open", command_id)
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	if (is_2d and parent is Node3D) or (not is_2d and parent is CanvasItem):
		return _send_error(client_id, "A %s effect needs a %s parent (or a plain Node); %s is a %s" % [
			dimension, "2D" if is_2d else "3D", _to_mcp_path(parent), parent.get_class()], command_id)
	var tint = TINTS[preset]
	if params.has("color"):
		tint = _coerce_to_color(params["color"])
		if not tint is Color:
			return _send_error(client_id, "color must be a color, e.g. \"#40a0ff\"", command_id)
	var spec := _preset(preset, tint)
	var scale := clampf(float(params.get("scale", 1.0)), 0.05, 100.0)
	var units := scale * (PIXELS_PER_METER if is_2d else 1.0)
	var forward: Vector3 = spec.get("forward", Vector3.UP)
	if params.has("direction"):
		var direction = _coerce_to_vector3(params["direction"]) if not is_2d else _coerce_to_vector2(params["direction"])
		if not (direction is Vector3 or direction is Vector2) or direction.length() < 0.0001:
			return _send_error(client_id, "direction must be a non-zero vector", command_id)
		forward = direction.normalized() if direction is Vector3 else Vector3(direction.x, direction.y, 0.0).normalized()
	elif is_2d:
		# 2D y points down; a 3D forward along z (a gun's -Z) becomes screen right.
		forward = Vector3(1, 0, 0) if absf(forward.z) > 0.5 else Vector3(forward.x, -forward.y, 0.0)
	var loop := bool(params.get("loop", spec.get("loop", false)))
	var light_on := bool(params.get("light", true))
	var shake_on := bool(params.get("camera_shake", preset == "explosion"))
	var context := {"is_2d": is_2d, "units": units, "scale": scale, "forward": forward, "loop": loop, "textures": {}}

	var position = (Vector2.ZERO if is_2d else Vector3.ZERO) if not params.has("position") \
		else (_coerce_to_vector2(params["position"]) if is_2d else _coerce_to_vector3(params["position"]))
	if not (position is Vector2 or position is Vector3):
		return _send_error(client_id, "position must be a vector", command_id)
	var wanted_name := str(params.get("name", "")).strip_edges()

	var root = Node2D.new() if is_2d else Node3D.new()
	root.name = _unique_child_name(parent, wanted_name if not wanted_name.is_empty() else preset.to_pascal_case())
	root.position = position
	var created: Array = []
	var layer_names: Array = []
	var sub_emitters: Array = []
	var notes: Array = []
	# Godot's Compatibility renderer draws no sub-emitters (it warns and drops them).
	var sub_emitters_drawn := not ParticleUtils.is_compatibility_renderer()
	# Normal-blend layers (smoke) first: 2D draws in tree order, and smoke drawn over fire hid it.
	var layers: Array = spec["layers"]
	for layer in layers.filter(func(entry): return not entry.get("add", false)) + layers.filter(func(entry): return entry.get("add", false)):
		var particles = _make_particles(layer, context)
		root.add_child(particles)
		created.append(particles)
		layer_names.append(str(particles.name))
		if layer.has("sub") and not sub_emitters_drawn:
			notes.append("The Compatibility renderer draws no sub-emitters, so %s has none (Forward+ and Mobile draw them)" % particles.name)
		elif layer.has("sub"):
			var sub: Dictionary = layer["sub"]
			var sub_particles = _make_particles(sub, context)
			sub_particles.one_shot = false
			sub_particles.emitting = false
			root.add_child(sub_particles)
			created.append(sub_particles)
			particles.sub_emitter = NodePath("../" + str(sub_particles.name))
			var material: ParticleProcessMaterial = particles.process_material
			material.sub_emitter_mode = ParticleUtils.SUB_EMITTER_MODES[sub["mode"]]
			if sub["mode"] == "constant":
				material.sub_emitter_frequency = float(sub["frequency"])
			else:
				material.sub_emitter_amount_at_end = int(sub["count"])
			sub_emitters.append("%s -> %s (%s)" % [particles.name, sub_particles.name, sub["mode"]])

	var light_settings: Array = spec["light"]
	var light_color: Color = tint.lerp(WHITE, 0.3)
	if light_on:
		# Saved at full strength so the editor shows the pop; the script dims it when the game starts.
		var light: Node
		if is_2d:
			var light_2d := PointLight2D.new()
			light_2d.texture = ParticleUtils.soft_texture("glow")
			light_2d.texture_scale = light_settings[1] * units * 2.0 / 64.0
			light_2d.energy = light_settings[0] * 0.2
			light_2d.color = light_color
			light_2d.position = Vector2(forward.x, forward.y) * float(spec.get("light_height", 0.0)) * units
			light = light_2d
		else:
			var omni := OmniLight3D.new()
			omni.omni_range = light_settings[1] * scale
			omni.light_energy = light_settings[0]
			omni.light_color = light_color
			# Off the surface: a light on the floor lights none of it.
			omni.position = forward * float(spec.get("light_height", 0.0)) * scale
			light = omni
		light.name = "Light"
		root.add_child(light)
		created.append(light)

	var shake_settings: Array = spec["shake"]
	var shake_strength: float = shake_settings[0] * (PIXELS_PER_METER * scale if is_2d else 1.0) if shake_on else 0.0
	var script := GDScript.new()
	script.source_code = PLAYER_SCRIPT.format({
		"base": "Node2D" if is_2d else "Node3D",
		"particles": "GPUParticles2D" if is_2d else "GPUParticles3D",
		"energy": "energy" if is_2d else "light_energy",
		"camera": "get_camera_2d" if is_2d else "get_camera_3d",
		"shake": "_camera.offset = Vector2(randf_range(-k, k), randf_range(-k, k))" if is_2d
			else "_camera.h_offset = randf_range(-k, k)\n\t\t_camera.v_offset = randf_range(-k, k)",
		"autoplay": str(bool(params.get("autoplay", true))).to_lower(),
		"light_energy": "%.3f" % (light_settings[0] * (0.2 if is_2d else 1.0)),
		"light_time": "%.3f" % maxf(light_settings[2], 0.01),
		"flicker": str(bool(spec.get("flicker", false))).to_lower(),
		"shake_strength": "%.3f" % shake_strength,
		"shake_time": "%.3f" % maxf(shake_settings[1], 0.01),
	})
	if script.reload() != OK:
		root.free()
		return _send_error(client_id, "The effect's player script did not compile (addon bug)", command_id)
	root.set_script(script)

	var transaction = _transaction("Build VFX Effect", str(params.get("transaction_id", "")), {"command": "build_vfx_effect", "preset": preset})
	if not transaction:
		return _send_error(client_id, "Failed to obtain a scene transaction", command_id)
	transaction.add_do_method(parent, "add_child", [root, true])
	transaction.add_do_method(root, "set_owner", [scene_root])
	for node in created:
		transaction.add_do_method(node, "set_owner", [scene_root])
	transaction.add_do_reference(root)
	transaction.add_undo_method(parent, "remove_child", [root])

	var root_path := _join_path(_to_mcp_path(parent), str(root.name))
	_finish_transaction(client_id, command_id, transaction, str(params.get("transaction_id", "")), {
		"node_path": root_path,
		"preset": preset,
		"dimension": dimension,
		"layers": layer_names,
		"sub_emitters": sub_emitters,
		"light": light_on,
		"camera_shake": shake_strength > 0.0,
		"loop": loop,
		"notes": notes,
	})


# One GPUParticles node from a layer spec (see _preset). 3D draws a quad from ParticleUtils.draw_mesh;
# 2D draws the texture, sized by the process material's scale.
func _make_particles(layer: Dictionary, context: Dictionary) -> Node:
	var is_2d: bool = context["is_2d"]
	var units: float = context["units"]
	var up := Vector3(0, -1, 0) if is_2d else Vector3.UP
	var align := bool(layer.get("align", false))
	var size = layer.get("size", 1.0)
	var size_2d: Vector2 = Vector2(size, size) if not size is Vector2 else size
	var kind := str(layer.get("tex", "glow"))
	# 2D scales a sprite evenly, so a stretched glow (sparks, flame petals) gets a texture of its shape.
	var texture_size := Vector2i(64, 64)
	if is_2d and kind == "glow" and size_2d.x != size_2d.y:
		texture_size = Vector2i(clampi(roundi(96.0 * size_2d.x / size_2d.y), 8, 96), 96)
	var key := "%s%s" % [kind, texture_size]
	var textures: Dictionary = context["textures"]
	if not textures.has(key):
		if kind == "smoke" and not _smoke_texture:
			_smoke_texture = ParticleUtils.smoke_texture(7)
		textures[key] = _smoke_texture if kind == "smoke" else ParticleUtils.soft_texture(kind, texture_size)
	var texture: Texture2D = textures[key]

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = is_2d
	var radius := float(layer.get("radius", 0.0)) * units
	if radius > 0.0:
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		material.emission_sphere_radius = radius
	var dir := str(layer.get("dir", "none"))
	material.direction = context["forward"] if dir == "forward" else up
	material.spread = float(layer.get("spread", 180.0 if dir == "none" else 30.0))
	var speed: Array = layer.get("speed", [0.0, 0.0])
	material.initial_velocity_min = speed[0] * units
	material.initial_velocity_max = speed[1] * units
	material.gravity = up * float(layer.get("gravity", 0.0)) * units
	var damping: Array = layer.get("damping", [0.0, 0.0])
	material.damping_min = damping[0] * units
	material.damping_max = damping[1] * units
	# 3D sizes the quad; 2D sizes the texture through the particle scale.
	var base_scale: float = 1.0 if not is_2d else size_2d.y * units / float(texture.get_height())
	var random_scale: Array = layer.get("scale", [0.8, 1.2])
	material.scale_min = random_scale[0] * base_scale
	material.scale_max = random_scale[1] * base_scale
	if layer.has("scale_curve"):
		material.scale_curve = ParticleUtils.curve_texture(layer["scale_curve"])
	if layer.has("alpha_curve"):
		material.alpha_curve = ParticleUtils.curve_texture(layer["alpha_curve"])
	var colors: Array = layer["colors"]
	if is_2d:
		# 2D clamps each channel at 1, which turned 1.6x orange into yellow; scale down to keep the hue.
		colors = colors.map(func(color: Color) -> Color:
			var top := maxf(maxf(color.r, color.g), maxf(color.b, 1.0))
			return Color(color.r / top, color.g / top, color.b / top, color.a))
	material.color_ramp = ParticleUtils.gradient_texture(colors)
	if layer.get("spin", false):
		material.angle_min = -180.0
		material.angle_max = 180.0
		material.angular_velocity_min = -40.0
		material.angular_velocity_max = 40.0
	material.particle_flag_align_y = align and is_2d
	# ponytail: no turbulence in 2D; its noise is sampled per unit, so pixel positions turn it into jitter.
	if layer.has("turbulence") and not is_2d:
		var turbulence: Array = layer["turbulence"]
		material.turbulence_enabled = true
		material.turbulence_noise_strength = turbulence[0]
		material.turbulence_noise_scale = turbulence[1]
		material.turbulence_influence_min = turbulence[2] * 0.5
		material.turbulence_influence_max = turbulence[2]

	var particles = GPUParticles2D.new() if is_2d else GPUParticles3D.new()
	particles.name = str(layer["name"])
	particles.amount = int(layer["amount"])
	particles.lifetime = float(layer["life"])
	particles.one_shot = not context["loop"]
	particles.explosiveness = float(layer.get("explosive", 1.0))
	particles.randomness = 0.2
	particles.process_material = material
	particles.emitting = true
	var offset: Vector3 = context["forward"] * float(layer.get("offset", 0.0)) * units
	# Fast sparks leave the default culling box (2D 200 px, 3D 8 m) and blink out.
	var reach := 8.0 * units
	if is_2d:
		particles.texture = texture
		if layer.get("add", false):
			var canvas_material := CanvasItemMaterial.new()
			canvas_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			particles.material = canvas_material
		particles.position = Vector2(offset.x, offset.y)
		particles.visibility_rect = Rect2(-reach, -reach, reach * 2.0, reach * 2.0)
	else:
		particles.draw_pass_1 = ParticleUtils.draw_mesh("quad", size_2d * context["scale"], texture, layer.get("add", false), 1, 1, false, align)
		if align:
			particles.transform_align = GPUParticles3D.TRANSFORM_ALIGN_Z_BILLBOARD_Y_TO_VELOCITY
		var draw_material: StandardMaterial3D = particles.draw_pass_1.material
		if layer.get("flat", false):
			# Lies on the surface (a ground shockwave): a quad facing the node's Y, turned to forward.
			particles.draw_pass_1.orientation = PlaneMesh.FACE_Y
			draw_material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
			particles.basis = _basis_facing(context["forward"])
			offset += context["forward"] * 0.03 * units
		elif not align:
			# Soft particles: quads fade where they meet the floor or a wall instead of cutting a hard line.
			draw_material.proximity_fade_enabled = true
			draw_material.proximity_fade_distance = maxf(size_2d.y * context["scale"] * 0.4, 0.05)
		if layer.get("sort", false):
			particles.draw_order = GPUParticles3D.DRAW_ORDER_VIEW_DEPTH
		particles.position = offset
		particles.visibility_aabb = AABB(Vector3.ONE * -reach, Vector3.ONE * reach * 2.0)
	return particles


# A basis whose Y axis is up_axis (for quads that lie on a surface with that normal).
func _basis_facing(up_axis: Vector3) -> Basis:
	var side := up_axis.cross(Vector3.FORWARD if absf(up_axis.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT).normalized()
	return Basis(side, up_axis, side.cross(up_axis).normalized())


# --- pixel-art effects ----------------------------------------------------------------------

const PIXEL_DIR := "res://addons/godot_mcp/vfx/"
# canvas: art pixels; pivot: the canvas point (0..1) on the node's origin (the ground for ground
# effects); slots: ramp uniforms and how each is coloured; preview: the clock the editor shows.
const PIXEL_PRESETS := {
	"tornado": {"canvas": Vector2i(64, 96), "fps": 12, "frames": 16, "loop": true, "pivot": Vector2(0.5, 0.93),
		"element": "wind", "slots": {"main": "main", "debris": "debris", "dust": "dust"}, "preview": 0.5,
		"light": [0.0, 0.0, 0.0], "shake": 0},
	"explosion": {"canvas": Vector2i(64, 64), "fps": 15, "frames": 18, "loop": false, "pivot": Vector2(0.5, 0.5),
		"element": "fire", "slots": {"main": "main", "smoke": "smoke", "spark": "main"}, "preview": 0.33,
		"light": [4.5, 0.7, 0.15], "shake": 6},
	"lightning": {"canvas": Vector2i(64, 96), "fps": 18, "frames": 16, "loop": false, "pivot": Vector2(0.5, 0.905),
		"element": "lightning", "slots": {"main": "main", "smoke": "smoke", "spark": "main"}, "preview": 0.22,
		"light": [5.0, 0.6, 0.6], "shake": 8},
	"vortex": {"canvas": Vector2i(64, 64), "fps": 12, "frames": 16, "loop": true, "pivot": Vector2(0.5, 0.5),
		"element": "dark", "slots": {"main": "main", "smoke": "shadow"}, "preview": 0.5,
		"light": [2.5, 0.0, 0.2], "shake": 0},
	"heal": {"canvas": Vector2i(48, 64), "fps": 15, "frames": 20, "loop": false, "pivot": Vector2(0.5, 0.95),
		"element": "nature", "slots": {"main": "main"}, "preview": 0.6,
		"light": [3.0, 1.3, 0.0], "shake": 0},
	"slash": {"canvas": Vector2i(64, 64), "fps": 18, "frames": 12, "loop": false, "pivot": Vector2(0.5, 0.5),
		"element": "steel", "slots": {"main": "main", "spark": "main"}, "preview": 0.17,
		"light": [0.0, 0.0, 0.0], "shake": 0},
	"impact": {"canvas": Vector2i(48, 48), "fps": 18, "frames": 10, "loop": false, "pivot": Vector2(0.5, 0.5),
		"element": "holy", "slots": {"main": "main", "spark": "main"}, "preview": 0.11,
		"light": [3.0, 0.3, 0.2], "shake": 3},
	"fireball": {"canvas": Vector2i(64, 32), "fps": 12, "frames": 8, "loop": true, "pivot": Vector2(0.75, 0.5),
		"element": "fire", "slots": {"main": "main", "spark": "main"}, "preview": 0.25,
		"light": [2.5, 0.0, 0.3], "shake": 0},
	"beam": {"canvas": Vector2i(128, 32), "fps": 12, "frames": 12, "loop": true, "pivot": Vector2(0.125, 0.5),
		"element": "arcane", "slots": {"main": "main", "spark": "main"}, "preview": 0.25,
		"light": [3.0, 0.0, 0.25], "shake": 0},
	"portal": {"canvas": Vector2i(64, 64), "fps": 12, "frames": 16, "loop": true, "pivot": Vector2(0.5, 0.5),
		"element": "arcane", "slots": {"main": "main", "spark": "main"}, "preview": 0.5,
		"light": [2.0, 0.0, 0.15], "shake": 0},
	"shield": {"canvas": Vector2i(64, 64), "fps": 12, "frames": 16, "loop": true, "pivot": Vector2(0.5, 0.5),
		"element": "ice", "slots": {"main": "main", "spark": "main"}, "preview": 0.3,
		"light": [1.6, 0.0, 0.1], "shake": 0},
	"flame": {"canvas": Vector2i(32, 48), "fps": 12, "frames": 12, "loop": true, "pivot": Vector2(0.5, 0.92),
		"element": "fire", "slots": {"main": "main", "smoke": "smoke", "spark": "main"}, "preview": 0.5,
		"light": [2.5, 0.0, 0.45], "shake": 0},
	"poof": {"canvas": Vector2i(48, 48), "fps": 15, "frames": 14, "loop": false, "pivot": Vector2(0.5, 0.5),
		"element": "holy", "slots": {"main": "smoke", "spark": "main"}, "preview": 0.25,
		"light": [0.0, 0.0, 0.0], "shake": 0},
	"slam": {"canvas": Vector2i(96, 64), "fps": 15, "frames": 18, "loop": false, "pivot": Vector2(0.5, 0.8),
		"element": "earth", "slots": {"main": "main", "dust": "dust", "debris": "debris"}, "preview": 0.2,
		"light": [0.0, 0.0, 0.0], "shake": 8},
}
# Element colours: OK HSL hue, saturation, and how far highlights swing toward yellow (fire burns
# from crimson to yellow-white); the ramps are built from them (see _pixel_ramp).
const PIXEL_ELEMENTS := {
	"fire": [0.09, 1.0, 1.1], "ice": [0.6, 0.7, 0.1], "lightning": [0.7, 1.0, 0.1], "wind": [0.5, 0.6, 0.2],
	"dark": [0.8, 0.85, 0.05], "holy": [0.2, 0.9, 0.6], "nature": [0.38, 0.8, 0.3], "arcane": [0.9, 0.9, 0.15],
	"poison": [0.33, 0.95, 0.3], "water": [0.64, 0.9, 0.1], "blood": [0.05, 0.85, 0.1], "earth": [0.15, 0.4, 0.3],
	"plasma": [0.95, 1.0, 0.15], "steel": [0.68, 0.2, 0.1],
}

# Plays a pixel effect in the game: steps the shader clock, fades or flickers the light, shakes the
# camera when a one-shot fires.
const PIXEL_PLAYER_SCRIPT := """extends Node2D
# Built by Godot MCP build_pixel_vfx. play() fires the effect again; seek(seconds) shows a moment.

@export var autoplay := {autoplay}
## Seconds between replays of a one-shot; 0 plays it once. Loops repeat by themselves.
@export var replay_every := {replay_every}
@export var light_energy := {light_energy}
## Seconds the light takes to fade after play(); 0 keeps it on.
@export var light_fade := {light_fade}
@export var flicker := {flicker}
## Camera shake in screen pixels, for shake_time seconds after play().
@export var shake := {shake}
@export var shake_time := 0.25

@onready var _fx: CanvasItem = $FX
@onready var _light: Light2D = get_node_or_null("Light")
var _clock := -1.0
var _camera: Camera2D


func _ready() -> void:
	if autoplay:
		play()
	else:
		seek(1.0e6)
		_clock = -1.0


func play() -> void:
	_clock = 0.0
	_camera = get_viewport().get_camera_2d()


func seek(seconds: float) -> void:
	_clock = seconds
	_fx.material.set_shader_parameter("clock", seconds)
	if _light:
		var energy := light_energy
		if light_fade > 0.0:
			energy *= clampf(1.0 - seconds / light_fade, 0.0, 1.0)
		_light.energy = energy * (1.0 - flicker * randf())
	if shake > 0.0 and is_instance_valid(_camera):
		var k := shake * clampf(1.0 - seconds / shake_time, 0.0, 1.0)
		_camera.offset = Vector2(randf_range(-k, k), randf_range(-k, k)).round()


func _process(delta: float) -> void:
	if _clock < 0.0:
		return
	seek(_clock)
	_clock += delta
	if replay_every > 0.0 and _clock >= replay_every:
		play()
"""

# One Shader per preset for every effect this editor session builds, so a scene stores each once.
var _pixel_shaders := {}


# A pixel-art ramp, dark to light: shadows lean toward blue-violet, highlights toward yellow and the
# top step is nearly white, the usual hue-shifting rule of hand-made palettes. Constant
# interpolation, so the shader reads each band as one flat colour.
func _pixel_ramp(hue: float, sat: float, steps: int, low: float, high: float, warm := 0.2) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	for i in steps:
		var t := float(i) / float(steps - 1)
		var h := _hue_toward(_hue_toward(hue, 0.75, (1.0 - t) * (1.0 - t) * 0.25), 0.27, t * t * warm)
		offsets.append(float(i) / float(steps))
		# Warm ramps keep their colour into the highlights (a yellow core); cool ones fade to white.
		var fade := 0.7 - 0.45 * clampf(warm, 0.0, 1.0)
		colors.append(Color.from_ok_hsl(h, sat * (1.0 - pow(t, 4.0) * fade), lerpf(low, high, pow(t, 0.9))))
	gradient.offsets = offsets
	gradient.colors = colors
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	texture.width = 64
	return texture


func _hue_toward(hue: float, target: float, amount: float) -> float:
	var delta := fposmod(target - hue + 0.5, 1.0) - 0.5
	return fposmod(hue + delta * amount, 1.0)


func _pixel_shader(preset: String) -> Shader:
	if _pixel_shaders.has(preset):
		return _pixel_shaders[preset]
	var library := FileAccess.get_file_as_string(PIXEL_DIR + "pixel_vfx.gdshaderinc")
	var source := FileAccess.get_file_as_string(PIXEL_DIR + "pixel_%s.gdshader" % preset)
	if library.is_empty() or source.is_empty():
		return null
	# Pasted in rather than included, so the scene keeps working without this addon.
	var shader := Shader.new()
	shader.code = source.replace('#include "%spixel_vfx.gdshaderinc"' % PIXEL_DIR, library)
	_pixel_shaders[preset] = shader
	return shader


func _build_pixel_vfx(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset := str(params.get("preset", ""))
	if not PIXEL_PRESETS.has(preset):
		return _send_error(client_id, "preset must be one of: %s" % ", ".join(PackedStringArray(PIXEL_PRESETS.keys())), command_id)
	var spec: Dictionary = PIXEL_PRESETS[preset]
	var scene_root := EditorInterface.get_edited_scene_root()
	if not scene_root:
		return _send_error(client_id, "No scene is open", command_id)
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	if parent is Node3D:
		return _send_error(client_id, "build_pixel_vfx makes 2D effects; %s is a %s (use a 2D parent, or build_vfx_effect for 3D)" % [_to_mcp_path(parent), parent.get_class()], command_id)
	var element := str(params.get("element", spec["element"]))
	var hue_sat: Array = PIXEL_ELEMENTS.get(element, [])
	if params.has("color"):
		var tint = _coerce_to_color(params["color"])
		if not tint is Color:
			return _send_error(client_id, "color must be a color, e.g. \"#40a0ff\"", command_id)
		hue_sat = [tint.ok_hsl_h, clampf(tint.ok_hsl_s, 0.15, 1.0), 0.2]
		element = "custom"
	elif hue_sat.is_empty():
		return _send_error(client_id, "element must be one of: %s (or pass color)" % ", ".join(PackedStringArray(PIXEL_ELEMENTS.keys())), command_id)
	var position = _coerce_to_vector2(params.get("position", Vector2.ZERO))
	if not position is Vector2:
		return _send_error(client_id, "position must be a 2D vector", command_id)
	var pixel_scale := clampi(int(params.get("pixel_scale", 4)), 1, 16)
	var shader := _pixel_shader(preset)
	if not shader:
		return _send_error(client_id, "The pixel VFX shaders are missing from %s (addon install is incomplete)" % PIXEL_DIR, command_id)

	var material := ShaderMaterial.new()
	material.shader = shader
	var canvas: Vector2i = spec["canvas"]
	material.set_shader_parameter("canvas", Vector2(canvas))
	material.set_shader_parameter("fps", float(spec["fps"]))
	material.set_shader_parameter("frames", int(spec["frames"]))
	material.set_shader_parameter("looping", bool(spec["loop"]))
	material.set_shader_parameter("seed", int(params.get("seed", 1)))
	material.set_shader_parameter("clock", float(spec["preview"]))
	var hue: float = hue_sat[0]
	var sat: float = hue_sat[1]
	var warm: float = hue_sat[2]
	var slots: Dictionary = spec["slots"]
	for slot in slots:
		var style: String = slots[slot]
		var steps := 6
		var ramp: GradientTexture1D
		match style:
			"smoke":
				ramp = _pixel_ramp(0.72, 0.06, steps, 0.08, 0.8)
			"dust":
				steps = 5
				ramp = _pixel_ramp(hue, sat * 0.15, steps, 0.3, 0.85)
			"debris":
				steps = 4
				ramp = _pixel_ramp(hue, sat * 0.25, steps, 0.45, 1.0)
			"shadow":
				steps = 5
				ramp = _pixel_ramp(hue, sat * 0.4, steps, 0.02, 0.3)
			_:
				steps = 7 if preset in ["explosion", "vortex", "fireball", "portal", "flame"] else 6
				ramp = _pixel_ramp(hue, sat, steps, 0.1, 0.98, warm)
		material.set_shader_parameter(slot + "_ramp", ramp)
		material.set_shader_parameter(slot + "_bands", steps)

	var root := Node2D.new()
	var wanted_name := str(params.get("name", "")).strip_edges()
	root.name = _unique_child_name(parent, wanted_name if not wanted_name.is_empty() else "Pixel" + preset.to_pascal_case())
	root.position = position
	# Facing left: a whole-pixel mirror keeps the pixel grid (any other turn would not).
	if bool(params.get("flip", false)):
		root.scale = Vector2(-1, 1)
	var fx := ColorRect.new()
	fx.name = "FX"
	fx.material = material
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pivot: Vector2 = spec["pivot"]
	var size := Vector2(canvas * pixel_scale)
	fx.position = -(pivot * size).round()
	fx.size = size
	root.add_child(fx)
	var created: Array = [fx]

	var light_spec: Array = spec["light"]
	var light_on := bool(params.get("light", light_spec[0] > 0.0))
	if light_on:
		var light := PointLight2D.new()
		light.name = "Light"
		var glow := GradientTexture2D.new()
		glow.gradient = Gradient.new()
		glow.gradient.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
		glow.fill = GradientTexture2D.FILL_RADIAL
		glow.fill_from = Vector2(0.5, 0.5)
		glow.fill_to = Vector2(1.0, 0.5)
		light.texture = glow
		light.texture_scale = size.length() / 64.0
		light.color = Color.from_ok_hsl(hue, sat * 0.8, 0.7)
		# Saved at full strength so the editor shows it; the script fades it after each play().
		light.energy = maxf(light_spec[0], 1.5)
		light.position = fx.position + size * 0.5
		root.add_child(light)
		created.append(light)
	var shake: float = float(spec["shake"]) if bool(params.get("camera_shake", spec["shake"] > 0)) else 0.0

	var script := GDScript.new()
	script.source_code = PIXEL_PLAYER_SCRIPT.format({
		"autoplay": str(bool(params.get("autoplay", true))).to_lower(),
		"replay_every": "%.3f" % maxf(float(params.get("replay_every", 0.0)), 0.0),
		"light_energy": "%.3f" % maxf(light_spec[0], 1.5),
		"light_fade": "%.3f" % light_spec[1],
		"flicker": "%.3f" % light_spec[2],
		"shake": "%.1f" % (shake * pixel_scale / 4.0),
	})
	if script.reload() != OK:
		root.free()
		return _send_error(client_id, "The effect's player script did not compile (addon bug)", command_id)
	root.set_script(script)

	var transaction = _transaction("Build Pixel VFX", str(params.get("transaction_id", "")), {"command": "build_pixel_vfx", "preset": preset})
	if not transaction:
		root.free()
		return _send_error(client_id, "Failed to obtain a scene transaction", command_id)
	transaction.add_do_method(parent, "add_child", [root, true])
	transaction.add_do_method(root, "set_owner", [scene_root])
	for node in created:
		transaction.add_do_method(node, "set_owner", [scene_root])
	transaction.add_do_reference(root)
	transaction.add_undo_method(parent, "remove_child", [root])
	_finish_transaction(client_id, command_id, transaction, str(params.get("transaction_id", "")), {
		"node_path": _join_path(_to_mcp_path(parent), str(root.name)),
		"preset": preset,
		"element": element,
		"canvas": [canvas.x, canvas.y],
		"pixel_scale": pixel_scale,
		"size": [size.x, size.y],
		"fps": spec["fps"],
		"frames": spec["frames"],
		"loop": spec["loop"],
		"light": light_on,
		"camera_shake": shake > 0.0,
		"ramps": PackedStringArray(slots.keys()),
	})
