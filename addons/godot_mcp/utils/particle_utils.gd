@tool
extends RefCounted
## Particle building blocks shared by configure_particles_3d and build_vfx_effect: over-life curves
## and gradients, soft procedural textures, and the draw material for 3D particles.

const SUB_EMITTER_MODES := {"disabled": 0, "constant": 1, "at_end": 2, "at_collision": 3, "at_start": 4}
const COLLISION_MODES := {"disabled": 0, "rigid": 1, "hide_on_contact": 2}
const MESH_SHAPES := ["quad", "sphere", "box", "prism"]


static func is_compatibility_renderer() -> bool:
	return str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "forward_plus")) == "gl_compatibility"


# [1, 0.5, 0] spreads the values evenly over the particle's life; [[0, 1], [0.8, 0.6], [1, 0]]
# places each one. Returns null for anything else.
static func curve_texture(points):
	if not points is Array or points.size() < 2:
		return null
	var placed: Array = []
	var top := 1.0
	for i in points.size():
		var point = points[i]
		var at: Vector2
		if point is float or point is int:
			at = Vector2(float(i) / float(points.size() - 1), float(point))
		elif point is Array and point.size() == 2:
			at = Vector2(clampf(float(point[0]), 0.0, 1.0), float(point[1]))
		elif point is Dictionary and point.has("x") and point.has("y"):
			at = Vector2(clampf(float(point["x"]), 0.0, 1.0), float(point["y"]))
		else:
			return null
		if at.y < 0.0:
			return null
		top = maxf(top, at.y)
		placed.append(at)
	# Scale curves may go above 1 (grow); add_point clamps to max_value, so raise it first.
	var curve := Curve.new()
	curve.max_value = top
	for at in placed:
		curve.add_point(at)
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


# Colors spread evenly over life. HDR so values above 1 glow when the environment has glow on.
static func gradient_texture(colors: Array) -> GradientTexture1D:
	var gradient := Gradient.new()
	var offsets := PackedFloat32Array()
	for i in colors.size():
		offsets.append(float(i) / float(maxi(colors.size() - 1, 1)))
	gradient.offsets = offsets
	gradient.colors = PackedColorArray(colors)
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	texture.use_hdr = true
	return texture


# A soft white sprite drawn by a radial gradient (no pixels stored in the scene): "glow" is a soft
# dot (an ellipse when size is not square), "ring" a shockwave ring.
static func soft_texture(kind: String, size := Vector2i(64, 64)) -> GradientTexture2D:
	var gradient := Gradient.new()
	match kind:
		"ring":
			gradient.offsets = PackedFloat32Array([0.0, 0.62, 0.84, 1.0])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.05), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		_:
			gradient.offsets = PackedFloat32Array([0.0, 0.2, 1.0])
			gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = size.x
	texture.height = size.y
	return texture


# The draw-pass mesh for a GPUParticles3D: a camera-facing quad (texture and flipbook frames
# optional) or a solid shape for chunks. align_to_velocity leaves billboarding to the particles
# node (transform_align) so the quad stretches along the motion.
static func draw_mesh(shape: String, size: Vector2, texture: Texture2D, additive: bool, h_frames: int, v_frames: int,
		loop: bool, align_to_velocity: bool) -> Mesh:
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	# Colors read like the color picker (and like 2D) on normal particles; additive ones stay linear
	# so HDR values above 1 glow instead of exploding through the sRGB curve.
	material.vertex_color_is_srgb = not additive
	material.albedo_texture = texture
	var mesh: PrimitiveMesh
	match shape:
		"sphere":
			var sphere := SphereMesh.new()
			sphere.radius = size.x * 0.5
			sphere.height = size.x
			sphere.radial_segments = 12
			sphere.rings = 6
			mesh = sphere
		"box":
			var box := BoxMesh.new()
			box.size = Vector3(size.x, size.y, size.x)
			mesh = box
		"prism":
			var prism := PrismMesh.new()
			prism.size = Vector3(size.x, size.y, size.x)
			mesh = prism
		_:
			var quad := QuadMesh.new()
			quad.size = size
			mesh = quad
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.cull_mode = BaseMaterial3D.CULL_DISABLED
			if not align_to_velocity:
				material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
				material.particles_anim_h_frames = maxi(h_frames, 1)
				material.particles_anim_v_frames = maxi(v_frames, 1)
				material.particles_anim_loop = loop
	if texture or additive or mesh is QuadMesh:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if additive:
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mesh.material = material
	return mesh


# A soft, lumpy smoke or flame puff: a radial falloff broken up by noise. Small and gray+alpha
# because a text scene stores every byte as text (64 px RGBA was 104 KB per effect).
static func smoke_texture(seed_value: int) -> ImageTexture:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.09
	noise.fractal_octaves = 3
	var image := Image.create(32, 32, false, Image.FORMAT_LA8)
	for y in 32:
		for x in 32:
			var falloff := clampf(1.0 - Vector2(x - 15.5, y - 15.5).length() / 16.0, 0.0, 1.0)
			var detail := noise.get_noise_2d(x, y) * 0.5 + 0.5
			image.set_pixel(x, y, Color(1, 1, 1, smoothstep(0.0, 1.0, clampf(falloff * (0.4 + 1.2 * detail) * 1.4, 0.0, 1.0))))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
