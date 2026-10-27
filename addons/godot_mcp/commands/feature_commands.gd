@tool
class_name MCPFeatureCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Newer Godot features (4.4 to 4.7): skeleton IK, bone constraints, spring bones, stencil
## outlines, touch controls and accessibility info. Also 3D shader effects, paths and GridMap
## mesh libraries. Newer classes are made and set by name (ClassDB, call, set), so this file
## still loads in an older Godot; the tools that need them say which version to get.

# Oldest Godot that has each class; used only to word the "update Godot" error.
const MIN_VERSION := {
	"TwoBoneIK3D": "4.6", "FABRIK3D": "4.6", "CCDIK3D": "4.6", "JacobianIK3D": "4.6", "SplineIK3D": "4.6",
	"AimModifier3D": "4.5", "CopyTransformModifier3D": "4.5", "LookAtModifier3D": "4.4",
	"SpringBoneSimulator3D": "4.4", "SpringBoneCollisionSphere3D": "4.4", "VirtualJoystick": "4.7",
}
const IK_SOLVERS := {"two_bone": "TwoBoneIK3D", "fabrik": "FABRIK3D", "ccdik": "CCDIK3D", "jacobian": "JacobianIK3D", "spline": "SplineIK3D"}
const CONSTRAINTS := {"aim": "AimModifier3D", "copy_transform": "CopyTransformModifier3D", "look_at": "LookAtModifier3D"}
# SkeletonModifier3D.BoneAxis and RotationAxis, by word.
const BONE_AXES := {"+x": 0, "-x": 1, "+y": 2, "-y": 3, "+z": 4, "-z": 5}
const ROTATION_AXES := {"x": 0, "y": 1, "z": 2, "all": 3}
const LIMB_ENDS := ["hand", "foot", "wrist", "ankle"]
const MAX_PLACED := 500
const TOUCH_ONLY_SCRIPT := """extends CanvasLayer

# Touch controls show only on touch screens.
func _ready() -> void:
	visible = DisplayServer.is_touchscreen_available()
"""
const SPATIAL_EFFECTS := {
	"toon": """shader_type spatial;
// Cel shading: light falls into a few hard bands, with a rim of light on the edges.
uniform vec4 albedo : source_color = vec4(0.85, 0.55, 0.4, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform int bands : hint_range(1, 8) = 3;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.55;
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_amount : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
}

void light() {
	float lit = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float stepped = floor(lit * float(bands) + 0.5) / float(bands);
	float shade = mix(1.0 - shadow_strength, 1.0, stepped);
	float rim = smoothstep(1.0 - rim_amount, 1.0, 1.0 - dot(NORMAL, VIEW)) * lit;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR / PI * shade + rim_color.rgb * rim;
}
""",
	"rim_glow": """shader_type spatial;
// Glowing edges (fresnel): power-ups, selected objects, ghosts.
uniform vec4 albedo : source_color = vec4(0.2, 0.25, 0.35, 1.0);
uniform vec4 glow_color : source_color = vec4(0.3, 0.8, 1.0, 1.0);
uniform float glow_power : hint_range(0.5, 8.0) = 3.0;
uniform float glow_strength : hint_range(0.0, 8.0) = 2.0;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), glow_power);
	ALBEDO = albedo.rgb;
	EMISSION = glow_color.rgb * fresnel * glow_strength;
}
""",
	"hologram": """shader_type spatial;
render_mode blend_add, unshaded, cull_disabled;
// See-through hologram: scan lines move up, edges glow, it flickers a little.
uniform vec4 color : source_color = vec4(0.2, 0.9, 1.0, 1.0);
uniform float line_density = 60.0;
uniform float scroll_speed = 1.5;
uniform float flicker : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float lines = 0.5 + 0.5 * sin((world.y - TIME * scroll_speed * 0.1) * line_density);
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	float shimmer = 1.0 - flicker * step(0.97, fract(sin(floor(TIME * 20.0)) * 43758.5453));
	ALBEDO = color.rgb;
	ALPHA = clamp((0.25 + 0.5 * lines + fresnel) * shimmer, 0.0, 1.0) * color.a;
}
""",
	"dissolve": """shader_type spatial;
// Dissolve: animate progress from 0 (whole) to 1 (gone); the burning edge glows.
uniform vec4 albedo : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.45, 0.1, 1.0);
uniform float noise_scale = 6.0;

float hash(vec3 p) {
	return fract(sin(dot(p, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
}

float value_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	vec3 u = f * f * (3.0 - 2.0 * f);
	float a = mix(mix(hash(i), hash(i + vec3(1, 0, 0)), u.x), mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), u.x), u.y);
	float b = mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), u.x), mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), u.x), u.y);
	return mix(a, b, u.z);
}

varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float n = value_noise(local_position * noise_scale);
	if (n < progress) {
		discard;
	}
	ALBEDO = albedo.rgb * texture(albedo_texture, UV).rgb;
	EMISSION = edge_color.rgb * 4.0 * (1.0 - step(progress + edge_width, n)) * step(0.001, progress);
}
""",
	"wind_sway": """shader_type spatial;
render_mode cull_disabled;
// Foliage sway: the top of the mesh moves in the wind, the base (y = 0) stays put.
uniform vec4 albedo : source_color = vec4(0.35, 0.65, 0.25, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform float strength = 0.15;
uniform float speed = 1.5;
uniform float height = 1.0;
uniform vec2 direction = vec2(1.0, 0.3);

void vertex() {
	float bend = clamp(VERTEX.y / max(height, 0.001), 0.0, 1.0);
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wave = sin(TIME * speed + world.x * 0.7 + world.z * 0.5) + 0.4 * sin(TIME * speed * 2.3 + world.x * 1.7);
	VERTEX.xz += normalize(direction) * wave * strength * bend * bend;
}

void fragment() {
	vec4 base = texture(albedo_texture, UV);
	ALBEDO = albedo.rgb * base.rgb;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALPHA = base.a;
}
""",
}


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"describe_skeleton":
			_describe_skeleton(client_id, params, command_id)
		"add_skeleton_bones":
			_add_skeleton_bones(client_id, params, command_id)
		"setup_ik_chain":
			_setup_ik_chain(client_id, params, command_id)
		"add_bone_constraint":
			_add_bone_constraint(client_id, params, command_id)
		"setup_spring_bones":
			_setup_spring_bones(client_id, params, command_id)
		"set_stencil_effect":
			_set_stencil_effect(client_id, params, command_id)
		"create_spatial_shader":
			_create_spatial_shader(client_id, params, command_id)
		"add_touch_controls":
			_add_touch_controls(client_id, params, command_id)
		"set_accessibility_info":
			_set_accessibility_info(client_id, params, command_id)
		"create_path":
			_create_path(client_id, params, command_id)
		"place_along_path":
			_place_along_path(client_id, params, command_id)
		"build_mesh_library":
			_build_mesh_library(client_id, params, command_id)
		"snap_to_ground":
			_snap_to_ground(client_id, params, command_id)
		_:
			return false
	return true


# "" when the class exists, else a message that names the Godot version to get.
func _missing_class(cls: String) -> String:
	if ClassDB.class_exists(cls):
		return ""
	var needs := " It needs Godot %s or newer." % MIN_VERSION[cls] if MIN_VERSION.has(cls) else " Update Godot to use it."
	return "%s is not in this Godot (%s).%s" % [cls, _godot_version(), needs]


# --- skeletons ------------------------------------------------------------------------------

# "" if every named bone exists, else an error that lists some real bone names.
func _bones_error(skeleton: Skeleton3D, names: Array) -> String:
	for bone in names:
		if skeleton.find_bone(str(bone)) == -1:
			var known: Array = []
			for index in mini(skeleton.get_bone_count(), 24):
				known.append(skeleton.get_bone_name(index))
			return "Bone \"%s\" is not in %s. Some bones: %s (describe_skeleton lists all)" % [bone, skeleton.name, ", ".join(PackedStringArray(known))]
	return ""


func _is_bone_ancestor(skeleton: Skeleton3D, ancestor: int, bone: int) -> bool:
	var current := skeleton.get_bone_parent(bone)
	while current != -1:
		if current == ancestor:
			return true
		current = skeleton.get_bone_parent(current)
	return false


# Where new target markers go: next to the skeleton, or under it when it is the scene root.
func _marker_holder(skeleton: Skeleton3D) -> Node3D:
	var parent := skeleton.get_parent() as Node3D
	return parent if skeleton != EditorInterface.get_edited_scene_root() and parent else skeleton


# NodePath from a modifier (a child of skeleton) to a node under holder that may not exist yet.
func _path_from_modifier(skeleton: Skeleton3D, holder: Node, child_name: String) -> NodePath:
	var to_holder := "" if holder == skeleton else str(skeleton.get_path_to(holder)) + "/"
	return NodePath("../" + to_holder + child_name)


func _bone_world_position(skeleton: Skeleton3D, bone: int) -> Vector3:
	return skeleton.global_transform * skeleton.get_bone_global_pose(bone).origin


# TwoBoneIK3D does nothing without a pole node. The pole sits on the side the middle joint
# already bends to; a straight limb bends the usual way: knees forward (+Z, the way imported
# models face), elbows back.
func _pole_position(skeleton: Skeleton3D, root: int, middle: int, end: int) -> Vector3:
	var a := _bone_world_position(skeleton, root)
	var b := _bone_world_position(skeleton, middle)
	var c := _bone_world_position(skeleton, end)
	var line := (c - a).normalized()
	var bend := (b - a) - line * (b - a).dot(line)
	var length := a.distance_to(b) + b.distance_to(c)
	var direction := bend.normalized()
	if bend.length() < length * 0.01:
		var end_name := skeleton.get_bone_name(end).to_lower()
		direction = skeleton.global_basis.z.normalized() * (-1.0 if "hand" in end_name or "wrist" in end_name else 1.0)
		if absf(direction.dot(line)) > 0.95:
			direction = skeleton.global_basis.x.normalized()
	return b + direction * length * 0.5


func _new_marker(holder: Node3D, wanted: String, world_position: Vector3) -> Marker3D:
	var marker := Marker3D.new()
	marker.name = _unique_child_name(holder, wanted.validate_node_name())
	marker.position = holder.global_transform.affine_inverse() * world_position
	return marker


# A new marker whose name is unique among holder's children and the markers made so far.
func _add_marker(markers: Array, holder: Node3D, wanted: String, world_position: Vector3) -> Marker3D:
	var marker := _new_marker(holder, wanted, world_position)
	var taken := markers.map(func(other): return str(other.name))
	var suffix := 2
	while str(marker.name) in taken or holder.has_node(NodePath(str(marker.name))):
		marker.name = "%s%d" % [wanted.validate_node_name(), suffix]
		suffix += 1
	markers.append(marker)
	return marker


# Builds a rig from scratch: the rigging tools before this only worked on skeletons from imported models.
func _add_skeleton_bones(client_id: int, params: Dictionary, command_id: String) -> void:
	var path := str(params.get("skeleton_path", ""))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	var bones: Array = params.get("bones", [])
	if bones.is_empty() or bones.size() > 256:
		return _send_error(client_id, "bones must hold 1 to 256 bones", command_id)
	var before := _skeleton_bones(skeleton)
	var after := before.duplicate(true)
	var index_of := {}
	for index in after.size():
		index_of[after[index]["name"]] = index
	var previous := ""
	for i in bones.size():
		var bone = bones[i]
		if typeof(bone) != TYPE_DICTIONARY or str(bone.get("name", "")).is_empty():
			return _send_error(client_id, "bones[%d] needs a name" % i, command_id)
		var bone_name := str(bone["name"])
		if index_of.has(bone_name):
			return _send_error(client_id, "bones[%d]: %s is already a bone in %s" % [i, bone_name, skeleton.name], command_id)
		var parent_name := str(bone.get("parent", previous))
		if not parent_name.is_empty() and not index_of.has(parent_name):
			return _send_error(client_id, "bones[%d].parent %s is not a bone; list parents before their children" % [i, parent_name], command_id)
		var parent: int = index_of.get(parent_name, -1)
		var origin = _coerce_to_vector3(bone.get("position", Vector3(0, 1, 0) if parent != -1 else Vector3.ZERO))
		if not origin is Vector3:
			return _send_error(client_id, "bones[%d].position must be {x, y, z} or [x, y, z]" % i, command_id)
		index_of[bone_name] = after.size()
		var rest := Transform3D(Basis(), origin)
		after.append({"name": bone_name, "parent": parent, "rest": rest, "pose": rest})
		previous = bone_name
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Add Skeleton Bones", transaction_id, {"command": "add_skeleton_bones"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_method(self, "_set_skeleton_bones", [skeleton, after])
	transaction.add_undo_method(self, "_set_skeleton_bones", [skeleton, before])
	transaction.register_on_commit(func(): _mark_scene_modified())
	var lines: Array = []
	var depth := {-1: -1}
	for index in mini(after.size(), 64):
		depth[index] = depth.get(after[index]["parent"], -1) + 1
		lines.append("  ".repeat(depth[index]) + after[index]["name"])
	if after.size() > 64:
		lines.append("(%d more)" % (after.size() - 64))
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"skeleton_path": _to_mcp_path(skeleton), "bone_count": after.size(), "outline": "\n".join(PackedStringArray(lines))})


func _skeleton_bones(skeleton: Skeleton3D) -> Array:
	var data: Array = []
	for index in skeleton.get_bone_count():
		data.append({"name": skeleton.get_bone_name(index), "parent": skeleton.get_bone_parent(index),
			"rest": skeleton.get_bone_rest(index), "pose": skeleton.get_bone_pose(index)})
	return data


# Skeleton3D cannot remove one bone, so do and undo both rebuild the whole bone list.
func _set_skeleton_bones(skeleton: Skeleton3D, data: Array) -> void:
	skeleton.clear_bones()
	for bone in data:
		skeleton.add_bone(bone["name"])
		var index := skeleton.get_bone_count() - 1
		skeleton.set_bone_rest(index, bone["rest"])
		var pose: Transform3D = bone["pose"]
		skeleton.set_bone_pose_position(index, pose.origin)
		skeleton.set_bone_pose_rotation(index, pose.basis.get_rotation_quaternion())
		skeleton.set_bone_pose_scale(index, pose.basis.get_scale())
	for index in data.size():
		skeleton.set_bone_parent(index, data[index]["parent"])


func _describe_skeleton(client_id: int, params: Dictionary, command_id: String) -> void:
	var path := str(params.get("node_path", "/root"))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	var lines: Array = []
	var stack: Array = []
	var roots := skeleton.get_parentless_bones()
	for root_index in range(roots.size() - 1, -1, -1):
		stack.push_front([roots[root_index], 0])
	while not stack.is_empty() and lines.size() < 512:
		var entry: Array = stack.pop_front()
		lines.append("  ".repeat(entry[1]) + skeleton.get_bone_name(entry[0]))
		var children := skeleton.get_bone_children(entry[0])
		for child_index in range(children.size() - 1, -1, -1):
			stack.push_front([children[child_index], entry[1] + 1])
	var limbs: Array = []
	for bone in skeleton.get_bone_count():
		var lower := skeleton.get_bone_name(bone).to_lower()
		var middle := skeleton.get_bone_parent(bone)
		var root := skeleton.get_bone_parent(middle) if middle != -1 else -1
		if root != -1 and LIMB_ENDS.any(func(word): return word in lower) and not LIMB_ENDS.any(func(word): return word in skeleton.get_bone_name(middle).to_lower()):
			limbs.append({"root": skeleton.get_bone_name(root), "middle": skeleton.get_bone_name(middle), "end": skeleton.get_bone_name(bone)})
	var modifiers: Array = []
	for child in skeleton.get_children():
		if child is SkeletonModifier3D:
			modifiers.append("%s (%s)" % [child.name, child.get_class()])
	_send_success(client_id, {
		"skeleton_path": _to_mcp_path(skeleton), "bone_count": skeleton.get_bone_count(),
		"outline": "\n".join(PackedStringArray(lines)), "limbs": limbs, "modifiers": modifiers}, command_id)


func _setup_ik_chain(client_id: int, params: Dictionary, command_id: String) -> void:
	var solver := str(params.get("solver", "two_bone"))
	if not IK_SOLVERS.has(solver):
		return _send_error(client_id, "solver must be one of: %s" % ", ".join(PackedStringArray(IK_SOLVERS.keys())), command_id)
	var cls: String = IK_SOLVERS[solver]
	var missing := _missing_class(cls)
	if not missing.is_empty():
		return _send_error(client_id, missing, command_id)
	var path := str(params.get("skeleton_path", "/root"))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	var chains: Array = params.get("chains", [])
	if chains.is_empty() or chains.size() > 16:
		return _send_error(client_id, "chains must hold 1 to 16 chains", command_id)
	var holder := _marker_holder(skeleton)
	var scene_root := EditorInterface.get_edited_scene_root()
	var ik: Node = ClassDB.instantiate(cls)
	ik.name = _unique_child_name(skeleton, str(params.get("name", cls)).validate_node_name())
	ik.call("set_setting_count", chains.size())
	var markers: Array = []
	var summary: Array = []
	for index in chains.size():
		var chain = chains[index]
		if typeof(chain) != TYPE_DICTIONARY or str(chain.get("end_bone", "")).is_empty():
			return _send_error(client_id, "chains[%d] needs end_bone" % index, command_id)
		var end_name := str(chain["end_bone"])
		var bones_error := _bones_error(skeleton, [end_name])
		if not bones_error.is_empty():
			return _send_error(client_id, bones_error, command_id)
		var end := skeleton.find_bone(end_name)
		var middle := -1
		var root := -1
		if solver == "two_bone":
			middle = skeleton.find_bone(str(chain["middle_bone"])) if chain.has("middle_bone") else skeleton.get_bone_parent(end)
			root = skeleton.find_bone(str(chain["root_bone"])) if chain.has("root_bone") else (skeleton.get_bone_parent(middle) if middle != -1 else -1)
			if middle == -1 or root == -1 or not _is_bone_ancestor(skeleton, middle, end) or not _is_bone_ancestor(skeleton, root, middle):
				return _send_error(client_id, "chains[%d]: two_bone needs root -> middle -> end bones in one line (e.g. UpperArm, LowerArm, Hand)" % index, command_id)
			ik.call("set_middle_bone_name", index, skeleton.get_bone_name(middle))
		else:
			if not chain.has("root_bone"):
				return _send_error(client_id, "chains[%d] needs root_bone for the %s solver" % [index, solver], command_id)
			root = skeleton.find_bone(str(chain["root_bone"]))
			if root == -1 or not _is_bone_ancestor(skeleton, root, end):
				var unknown := _bones_error(skeleton, [chain["root_bone"]])
				return _send_error(client_id, unknown if not unknown.is_empty() else "chains[%d]: root_bone must be a parent (or grandparent...) of end_bone" % index, command_id)
		ik.call("set_root_bone_name", index, skeleton.get_bone_name(root))
		ik.call("set_end_bone_name", index, end_name)
		if solver == "spline":
			var curve_node := _get_editor_node(str(chain.get("path_3d", "")))
			if not curve_node is Path3D:
				return _send_error(client_id, "chains[%d] needs path_3d, a Path3D the bones follow" % index, command_id)
			ik.call("set_path_3d", index, NodePath("../" + str(skeleton.get_path_to(curve_node))))
			summary.append({"root": skeleton.get_bone_name(root), "end": end_name, "path_3d": _to_mcp_path(curve_node)})
			continue
		var target_path := ""
		var pole_path := ""
		if chain.has("target_path"):
			var target := _get_editor_node(str(chain["target_path"]))
			if not target is Node3D:
				return _send_error(client_id, "chains[%d].target_path must be a 3D node: %s" % [index, chain["target_path"]], command_id)
			ik.call("set_target_node", index, NodePath("../" + str(skeleton.get_path_to(target))))
			target_path = _to_mcp_path(target)
		else:
			var marker := _add_marker(markers, holder, end_name + "Target", _bone_world_position(skeleton, end))
			ik.call("set_target_node", index, _path_from_modifier(skeleton, holder, marker.name))
			target_path = _join_path(_to_mcp_path(holder), marker.name)
		if solver == "two_bone":
			if chain.has("pole_path"):
				var pole := _get_editor_node(str(chain["pole_path"]))
				if not pole is Node3D:
					return _send_error(client_id, "chains[%d].pole_path must be a 3D node" % index, command_id)
				ik.call("set_pole_node", index, NodePath("../" + str(skeleton.get_path_to(pole))))
				pole_path = _to_mcp_path(pole)
			else:
				var pole_marker := _add_marker(markers, holder, skeleton.get_bone_name(middle) + "Pole", _pole_position(skeleton, root, middle, end))
				ik.call("set_pole_node", index, _path_from_modifier(skeleton, holder, pole_marker.name))
				pole_path = _join_path(_to_mcp_path(holder), pole_marker.name)
		summary.append({"root": skeleton.get_bone_name(root), "middle": skeleton.get_bone_name(middle) if middle != -1 else "",
			"end": end_name, "target": target_path, "pole": pole_path})
	if params.has("max_iterations") and "max_iterations" in ik:
		ik.set("max_iterations", clampi(int(params["max_iterations"]), 1, 1000))
	if params.has("influence"):
		ik.set("influence", clampf(float(params["influence"]), 0.0, 1.0))
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Setup IK Chain", transaction_id, {"command": "setup_ik_chain"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	for marker in markers:
		_add_owned(transaction, holder, marker, scene_root)
	_add_owned(transaction, skeleton, ik, scene_root)
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(skeleton), ik.name), "solver": cls, "chains": summary})


func _add_bone_constraint(client_id: int, params: Dictionary, command_id: String) -> void:
	var kind := str(params.get("type", ""))
	if not CONSTRAINTS.has(kind):
		return _send_error(client_id, "type must be one of: %s" % ", ".join(PackedStringArray(CONSTRAINTS.keys())), command_id)
	var cls: String = CONSTRAINTS[kind]
	var missing := _missing_class(cls)
	if not missing.is_empty():
		return _send_error(client_id, missing, command_id)
	var path := str(params.get("skeleton_path", "/root"))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	var bone := str(params.get("bone", ""))
	var bones_error := _bones_error(skeleton, [bone])
	if bone.is_empty() or not bones_error.is_empty():
		return _send_error(client_id, bones_error if not bone.is_empty() else "bone is required (the bone that moves)", command_id)
	var target_bone := str(params.get("target_bone", ""))
	var target: Node = _get_editor_node(str(params["target_path"])) if params.has("target_path") else null
	if params.has("target_path") and not target is Node3D:
		return _send_error(client_id, "target_path must be a 3D node: %s" % params["target_path"], command_id)
	if (target == null) == target_bone.is_empty():
		return _send_error(client_id, "Pass exactly one of target_path (a node) or target_bone", command_id)
	if kind == "look_at" and target == null:
		return _send_error(client_id, "look_at follows a node; pass target_path", command_id)
	if not target_bone.is_empty():
		bones_error = _bones_error(skeleton, [target_bone])
		if not bones_error.is_empty():
			return _send_error(client_id, bones_error, command_id)
	var forward := str(params.get("forward_axis", "+y")).to_lower()
	if not BONE_AXES.has(forward):
		return _send_error(client_id, "forward_axis must be one of: %s" % ", ".join(PackedStringArray(BONE_AXES.keys())), command_id)
	var modifier: Node = ClassDB.instantiate(cls)
	modifier.name = _unique_child_name(skeleton, str(params.get("name", "%s%s" % [bone, cls.trim_suffix("Modifier3D")])).validate_node_name())
	var target_node_path := NodePath("../" + str(skeleton.get_path_to(target))) if target else NodePath()
	if kind == "look_at":
		modifier.set("bone_name", bone)
		modifier.set("target_node", target_node_path)
		modifier.set("forward_axis", BONE_AXES[forward])
		if params.has("duration"):
			modifier.set("duration", clampf(float(params["duration"]), 0.0, 10.0))
	else:
		modifier.call("set_setting_count", 1)
		modifier.call("set_apply_bone_name", 0, bone)
		modifier.call("set_amount", 0, clampf(float(params.get("amount", 1.0)), 0.0, 1.0))
		if target:
			modifier.call("set_reference_type", 0, 1)
			modifier.call("set_reference_node", 0, target_node_path)
		else:
			modifier.call("set_reference_type", 0, 0)
			modifier.call("set_reference_bone_name", 0, target_bone)
		if kind == "aim":
			modifier.call("set_forward_axis", 0, BONE_AXES[forward])
		else:
			var copy: Array = params.get("copy", ["position", "rotation", "scale"])
			for part in ["position", "rotation", "scale"]:
				modifier.call("set_copy_" + part, 0, part in copy)
			modifier.call("set_relative", 0, bool(params.get("relative", false)))
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Add Bone Constraint", transaction_id, {"command": "add_bone_constraint"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, skeleton, modifier, EditorInterface.get_edited_scene_root())
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(skeleton), modifier.name), "type": cls, "bone": bone,
		"target": _to_mcp_path(target) if target else "bone " + target_bone})


func _setup_spring_bones(client_id: int, params: Dictionary, command_id: String) -> void:
	var missing := _missing_class("SpringBoneSimulator3D")
	if not missing.is_empty():
		return _send_error(client_id, missing, command_id)
	var path := str(params.get("skeleton_path", "/root"))
	var skeleton := _find_skeleton(path)
	if not skeleton:
		return _send_error(client_id, _skeleton_error(path), command_id)
	var chains: Array = params.get("chains", [])
	var colliders: Array = params.get("colliders", [])
	if chains.is_empty() or chains.size() > 32 or colliders.size() > 32:
		return _send_error(client_id, "chains must hold 1 to 32 chains; colliders at most 32", command_id)
	var springs: Node = ClassDB.instantiate("SpringBoneSimulator3D")
	springs.name = _unique_child_name(skeleton, str(params.get("name", "SpringBones")).validate_node_name())
	springs.call("set_setting_count", chains.size())
	var summary: Array = []
	for index in chains.size():
		var chain = chains[index]
		if typeof(chain) != TYPE_DICTIONARY or not chain.has("root_bone") or not chain.has("end_bone"):
			return _send_error(client_id, "chains[%d] needs root_bone and end_bone" % index, command_id)
		var bones_error := _bones_error(skeleton, [chain["root_bone"], chain["end_bone"]])
		if not bones_error.is_empty():
			return _send_error(client_id, bones_error, command_id)
		var root := skeleton.find_bone(str(chain["root_bone"]))
		var end := skeleton.find_bone(str(chain["end_bone"]))
		if root != end and not _is_bone_ancestor(skeleton, root, end):
			return _send_error(client_id, "chains[%d]: root_bone must be a parent (or grandparent...) of end_bone" % index, command_id)
		springs.call("set_root_bone_name", index, str(chain["root_bone"]))
		springs.call("set_end_bone_name", index, str(chain["end_bone"]))
		# A tip bone has no child to aim at; extending it lets the last bone swing too.
		springs.call("set_extend_end_bone", index, bool(chain.get("extend_end_bone", true)))
		for setting in ["stiffness", "drag", "gravity", "radius"]:
			if chain.has(setting):
				springs.call("set_" + setting, index, clampf(float(chain[setting]), 0.0, 100.0))
		if chain.has("gravity_direction"):
			springs.call("set_gravity_direction", index, _coerce_to_vector3(chain["gravity_direction"]))
		summary.append("%s -> %s (stiffness %.2f, drag %.2f, gravity %.2f)" % [chain["root_bone"], chain["end_bone"],
			springs.call("get_stiffness", index), springs.call("get_drag", index), springs.call("get_gravity", index)])
	var spheres: Array = []
	for index in colliders.size():
		var spec = colliders[index]
		if typeof(spec) != TYPE_DICTIONARY or not spec.has("bone"):
			return _send_error(client_id, "colliders[%d] needs bone (and radius)" % index, command_id)
		var bones_error := _bones_error(skeleton, [spec["bone"]])
		if not bones_error.is_empty():
			return _send_error(client_id, bones_error, command_id)
		var sphere: Node3D = ClassDB.instantiate("SpringBoneCollisionSphere3D")
		sphere.name = ("%sCollider" % spec["bone"]).validate_node_name()
		for other in spheres:
			if other.name == sphere.name:
				sphere.name = "%s%d" % [sphere.name, index + 1]
		sphere.set("bone_name", str(spec["bone"]))
		sphere.set("radius", clampf(float(spec.get("radius", 0.1)), 0.001, 100.0))
		if spec.has("offset"):
			sphere.set("position_offset", _coerce_to_vector3(spec["offset"]))
		spheres.append(sphere)
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Setup Spring Bones", transaction_id, {"command": "setup_spring_bones"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, skeleton, springs, scene_root)
	for sphere in spheres:
		_add_owned(transaction, springs, sphere, scene_root)
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(skeleton), springs.name), "chains": summary,
		"colliders": spheres.map(func(sphere): return str(sphere.name))})


# --- 3D looks -------------------------------------------------------------------------------

func _mesh_instances(node: Node) -> Array:
	var found: Array = [node] if node is MeshInstance3D else []
	found.append_array(node.find_children("*", "MeshInstance3D", true, true))
	return found


# Outline or x-ray through the stencil buffer (Godot 4.5+). Each surface gets its own copy of
# its material as an override, so shared or imported materials stay untouched.
func _set_stencil_effect(client_id: int, params: Dictionary, command_id: String) -> void:
	if not "stencil_mode" in StandardMaterial3D.new():
		return _send_error(client_id, "Stencil effects need Godot 4.5 or newer (this is %s)" % _godot_version(), command_id)
	var effect := str(params.get("effect", "outline"))
	var modes := {"none": 0, "outline": 1, "xray": 2}
	if not modes.has(effect):
		return _send_error(client_id, "effect must be outline, xray or none", command_id)
	var node := _get_editor_node(str(params.get("node_path", "")))
	if not node:
		return _send_error(client_id, "Node not found: %s" % params.get("node_path", ""), command_id)
	var meshes := _mesh_instances(node)
	if meshes.is_empty() or meshes.size() > 256:
		return _send_error(client_id, "node_path must be a MeshInstance3D or hold 1 to 256 of them", command_id)
	var color = _coerce_value_to_type(params.get("color", "#ffcc33" if effect == "outline" else "#4dc3ff"), TYPE_COLOR)
	if not color is Color:
		return _send_error(client_id, "color must be a color", command_id)
	var changes: Array = []
	var skipped: Array = []
	for mesh_instance in meshes:
		if mesh_instance.mesh == null:
			skipped.append("%s (no mesh)" % mesh_instance.name)
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var source = mesh_instance.get_active_material(surface)
			if source != null and not source is BaseMaterial3D:
				skipped.append("%s surface %d (%s)" % [mesh_instance.name, surface, source.get_class()])
				continue
			if effect == "none" and (source == null or int(source.get("stencil_mode")) == 0):
				continue
			var material: BaseMaterial3D = source.duplicate() if source else StandardMaterial3D.new()
			material.set("stencil_mode", modes[effect])
			if effect != "none":
				material.set("stencil_color", color)
				# Outline and x-ray objects in one view hide each other when they share a reference value.
				material.set("stencil_reference", modes[effect])
			if effect == "outline":
				material.set("stencil_outline_thickness", clampf(float(params.get("thickness", 0.02)), 0.0, 1.0))
			changes.append([mesh_instance, surface, material])
	if changes.is_empty():
		var reason := "No surface has a stencil effect to remove." if effect == "none" else "No surface took the effect."
		return _send_error(client_id, reason + (" Skipped: " + ", ".join(PackedStringArray(skipped)) if not skipped.is_empty() else ""), command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Set Stencil Effect", transaction_id, {"command": "set_stencil_effect"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	for change in changes:
		transaction.add_do_method(change[0], "set_surface_override_material", [change[1], change[2]])
		transaction.add_undo_method(change[0], "set_surface_override_material", [change[1], change[0].get_surface_override_material(change[1])])
	var opened := _open_instances(transaction, changes.map(func(change): return change[0]))
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _to_mcp_path(node), "effect": effect, "surfaces": changes.size(), "skipped": skipped,
		"editable_children": opened})


func _create_spatial_shader(client_id: int, params: Dictionary, command_id: String) -> void:
	var effect := str(params.get("effect", ""))
	if not SPATIAL_EFFECTS.has(effect):
		return _send_error(client_id, "effect must be one of: %s" % ", ".join(PackedStringArray(SPATIAL_EFFECTS.keys())), command_id)
	var node = _get_editor_node(str(params.get("node_path", "")))
	if not node is GeometryInstance3D:
		return _send_error(client_id, "node_path must be a 3D mesh, CSG shape or MultiMesh (GeometryInstance3D)", command_id)
	var requested := str(params.get("shader_path", "res://shaders/%s_3d.gdshader" % effect))
	var shader_path := _contained_res_path(requested)
	if shader_path.is_empty() or not shader_path.ends_with(".gdshader") or _is_protected_path(shader_path):
		return _send_error(client_id, "shader_path must be a .gdshader file inside the project: %s" % requested, command_id)
	if not FileAccess.file_exists(shader_path):
		DirAccess.make_dir_recursive_absolute(shader_path.get_base_dir())
		var file := FileAccess.open(shader_path, FileAccess.WRITE)
		if file == null:
			return _send_error(client_id, "Failed to write %s" % shader_path, command_id)
		file.store_string(SPATIAL_EFFECTS[effect])
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
		if not known.has(name):
			return _send_error(client_id, "Unknown uniform %s; %s has: %s" % [name, effect, ", ".join(PackedStringArray(known.keys()))], command_id)
		var wanted_type := int(known[name]["type"])
		var value = _coerce_value_to_type(uniforms[name], wanted_type)
		if typeof(value) != wanted_type and not (typeof(value) in [TYPE_INT, TYPE_FLOAT] and wanted_type in [TYPE_INT, TYPE_FLOAT]):
			return _send_error(client_id, "Uniform %s expects %s, got %s" % [name, type_string(wanted_type), JSON.stringify(uniforms[name])], command_id)
		material.set_shader_parameter(name, value)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Create Spatial Shader", transaction_id, {"command": "create_spatial_shader"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_property(node, "material_override", material)
	transaction.add_undo_property(node, "material_override", node.material_override)
	var opened := _open_instances(transaction, [node])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _to_mcp_path(node), "effect": effect, "shader_path": shader_path,
		"uniforms": known.keys(), "set": uniforms.keys(), "editable_children": opened})


# --- UI -------------------------------------------------------------------------------------

func _circle_texture(size: int, alpha: float) -> GradientTexture2D:
	var texture := GradientTexture2D.new()
	texture.width = size
	texture.height = size
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	var gradient := Gradient.new()
	gradient.set_offset(0, 0.0)
	gradient.set_color(0, Color(1, 1, 1, alpha))
	gradient.set_offset(1, 0.97)
	gradient.set_color(1, Color(1, 1, 1, alpha))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	texture.gradient = gradient
	return texture


func _add_touch_controls(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	var use_joystick := bool(params.get("joystick", true))
	if use_joystick and not _missing_class("VirtualJoystick").is_empty():
		return _send_error(client_id, _missing_class("VirtualJoystick") + " Pass joystick: false to add only buttons.", command_id)
	var buttons: Array = params.get("buttons", [])
	if buttons.size() > 8 or (buttons.is_empty() and not use_joystick):
		return _send_error(client_id, "Add a joystick or 1 to 8 buttons", command_id)
	var actions = params.get("joystick_actions", {})
	if typeof(actions) != TYPE_DICTIONARY:
		return _send_error(client_id, "joystick_actions must be {left, right, up, down}", command_id)
	var screen := Vector2(ProjectSettings.get_setting("display/window/size/viewport_width", 1152), ProjectSettings.get_setting("display/window/size/viewport_height", 648))
	var size := clampf(float(params.get("button_size", 96.0)), 32.0, 400.0)
	var show_on_desktop := bool(params.get("show_on_desktop", false))
	var layer := CanvasLayer.new()
	layer.name = _unique_child_name(parent, "TouchControls")
	layer.layer = 10
	# The layer hides itself on desktop: TouchScreenButton's own touch-only mode leaves the labels
	# and the joystick showing.
	if not show_on_desktop:
		var script := GDScript.new()
		script.source_code = TOUCH_ONLY_SCRIPT
		script.reload()
		layer.set_script(script)
	var children: Array = []
	var used_actions: Array = []
	if use_joystick:
		var stick: Control = ClassDB.instantiate("VirtualJoystick")
		stick.name = "Joystick"
		for direction in ["left", "right", "up", "down"]:
			var action := str(actions.get(direction, "ui_" + direction))
			stick.set("action_" + direction, StringName(action))
			used_actions.append(action)
		var stick_size := clampf(float(params.get("joystick_size", 200.0)), 60.0, 500.0)
		stick.set("joystick_size", stick_size)
		stick.set("joystick_mode", {"fixed": 0, "dynamic": 1, "following": 2}.get(str(params.get("joystick_mode", "dynamic")), 1))
		# Dynamic and following sticks appear where the thumb lands: the lower left of any screen size.
		stick.anchor_top = 0.4
		stick.anchor_right = 0.5
		stick.anchor_bottom = 1.0
		children.append(stick)
	var released := _circle_texture(int(size), 0.35)
	var pressed := _circle_texture(int(size), 0.65)
	var shape := CircleShape2D.new()
	shape.radius = size * 0.5
	for index in buttons.size():
		var spec = buttons[index]
		if typeof(spec) != TYPE_DICTIONARY or str(spec.get("action", "")).is_empty():
			return _send_error(client_id, "buttons[%d] needs an action" % index, command_id)
		var button := TouchScreenButton.new()
		button.name = _unique_child_name(layer, str(spec.get("name", str(spec["action"]).to_pascal_case() + "Button")))
		button.action = StringName(str(spec["action"]))
		button.texture_normal = released
		button.texture_pressed = pressed
		button.shape = shape
		button.shape_centered = true
		# Bottom-right, right to left, in one row above the edge margin.
		var spot := Vector2(screen.x - (index + 1) * (size + 24.0), screen.y - size - 32.0)
		button.position = _coerce_to_vector2(spec["position"]) if spec.has("position") else spot
		var label := Label.new()
		label.name = "Label"
		label.text = str(spec.get("label", str(spec["action"]).trim_prefix("ui_").capitalize()))
		label.size = Vector2(size, size)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.add_child(label)
		children.append(button)
		used_actions.append(str(spec["action"]))
	var undefined: Array = []
	for action in used_actions:
		if not action.begins_with("ui_") and not ProjectSettings.has_setting("input/" + action) and not action in undefined:
			undefined.append(action)
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Add Touch Controls", transaction_id, {"command": "add_touch_controls"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, parent, layer, scene_root)
	for child in children:
		_add_owned(transaction, layer, child, scene_root)
		for inner in child.get_children():
			transaction.add_do_method(inner, "set_owner", [scene_root])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), layer.name), "joystick": use_joystick,
		"buttons": children.filter(func(child): return child is TouchScreenButton).map(func(child): return str(child.name)),
		"undefined_actions": undefined})


# Screen-reader names and descriptions (Godot 4.5+). auto_fill_root names the interactive controls
# a screen reader cannot name on its own: no text, no accessibility name.
func _set_accessibility_info(client_id: int, params: Dictionary, command_id: String) -> void:
	if not ClassDB.class_has_method("Control", "set_accessibility_name"):
		return _send_error(client_id, "Accessibility names need Godot 4.5 or newer (this is %s)" % _godot_version(), command_id)
	var entries: Array = params.get("entries", [])
	var auto_root_path := str(params.get("auto_fill_root", ""))
	if entries.size() > 200 or (entries.is_empty() and auto_root_path.is_empty()):
		return _send_error(client_id, "Pass 1 to 200 entries, or auto_fill_root", command_id)
	var staged: Array = []
	for index in entries.size():
		var entry = entries[index]
		if typeof(entry) != TYPE_DICTIONARY:
			return _send_error(client_id, "entries[%d] must be an object" % index, command_id)
		var control := _get_editor_node(str(entry.get("node_path", ""))) as Control
		if not control:
			return _send_error(client_id, "entries[%d]: no Control at %s" % [index, entry.get("node_path", "")], command_id)
		for key in ["name", "description"]:
			if entry.has(key):
				staged.append([control, "accessibility_" + key, str(entry[key])])
	if not auto_root_path.is_empty():
		var auto_root := _get_editor_node(auto_root_path)
		if not auto_root:
			return _send_error(client_id, "auto_fill_root not found: %s" % auto_root_path, command_id)
		var controls: Array = [auto_root] if auto_root is Control else []
		controls.append_array(auto_root.find_children("*", "Control", true, true))
		for control in controls:
			var interactive: bool = control is BaseButton or control is Range or control is LineEdit or control is TextEdit or control is ItemList or control is Tree
			var has_text: bool = "text" in control and not str(control.get("text")).strip_edges().is_empty()
			if not interactive or has_text or not str(control.get("accessibility_name")).is_empty():
				continue
			var tooltip := str(control.tooltip_text).strip_edges()
			staged.append([control, "accessibility_name", tooltip if not tooltip.is_empty() else str(control.name).capitalize()])
	if staged.is_empty():
		return _send_success(client_id, {"applied": []}, command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Set Accessibility Info", transaction_id, {"command": "set_accessibility_info"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var applied: Array = []
	for change in staged:
		transaction.add_do_property(change[0], change[1], change[2])
		transaction.add_undo_property(change[0], change[1], change[0].get(change[1]))
		applied.append("%s %s = \"%s\"" % [_to_mcp_path(change[0]), change[1].trim_prefix("accessibility_"), change[2]])
	var opened := _open_instances(transaction, staged.map(func(change): return change[0]))
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {"applied": applied, "editable_children": opened})


# --- paths ----------------------------------------------------------------------------------

func _create_path(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent := _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent:
		return _send_error(client_id, "Parent node not found: %s" % params.get("parent_path", "/root"), command_id)
	var points: Array = params.get("points", [])
	if points.size() < 2 or points.size() > 1000:
		return _send_error(client_id, "points must hold 2 to 1000 points", command_id)
	var is_3d: bool = parent is Node3D or (not parent is CanvasItem and (points[0] is Array and points[0].size() >= 3 or points[0] is Dictionary and points[0].has("z")))
	var coerced: Array = []
	for point in points:
		var value = _coerce_to_vector3(point) if is_3d else _coerce_to_vector2(point)
		if not (value is Vector3 if is_3d else value is Vector2):
			return _send_error(client_id, "Each point must be [x, y]%s: %s" % [", z] for 3D" if is_3d else "", JSON.stringify(point)], command_id)
		coerced.append(value)
	var closed := bool(params.get("closed", false))
	if closed and coerced[0] != coerced[-1]:
		coerced.append(coerced[0])
	var smooth := bool(params.get("smooth", false))
	var curve = Curve3D.new() if is_3d else Curve2D.new()
	var count := coerced.size()
	for index in count:
		# Catmull-Rom style handles: each point's tangent runs parallel to its neighbours' chord.
		var tangent = coerced[0] * 0.0
		if smooth:
			var before = coerced[index - 1] if index > 0 else (coerced[count - 2] if closed else coerced[index])
			var after = coerced[index + 1] if index < count - 1 else (coerced[1] if closed else coerced[index])
			tangent = (after - before) * 0.25
		curve.add_point(coerced[index], -tangent, tangent)
	var path: Node = Path3D.new() if is_3d else Path2D.new()
	path.name = _unique_child_name(parent, str(params.get("name", "Path")))
	path.curve = curve
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Create Path", transaction_id, {"command": "create_path"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, parent, path, EditorInterface.get_edited_scene_root())
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), path.name), "type": path.get_class(),
		"points": curve.point_count, "length": snappedf(curve.get_baked_length(), 0.01)})


func _place_along_path(client_id: int, params: Dictionary, command_id: String) -> void:
	var path = _get_editor_node(str(params.get("path_path", "")))
	if not (path is Path2D or path is Path3D) or path.curve == null or path.curve.point_count < 2:
		return _send_error(client_id, "path_path must be a Path2D or Path3D with at least 2 points", command_id)
	var scene_path := _contained_res_path(str(params.get("scene_path", "")))
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path, "PackedScene"):
		return _send_error(client_id, "scene_path must be a scene in the project: %s" % params.get("scene_path", ""), command_id)
	if scene_path == scene_root.scene_file_path:
		return _send_error(client_id, "A scene cannot hold copies of itself", command_id)
	var packed := ResourceLoader.load(scene_path, "PackedScene") as PackedScene
	var curve = path.curve
	var length: float = curve.get_baked_length()
	var closed: bool = curve.get_point_position(0).is_equal_approx(curve.get_point_position(curve.point_count - 1))
	var offsets: Array = []
	if params.has("spacing"):
		var spacing := float(params["spacing"])
		if spacing <= 0.0 or length / spacing > MAX_PLACED:
			return _send_error(client_id, "spacing must be above 0 and give at most %d copies (path length %.1f)" % [MAX_PLACED, length], command_id)
		var offset := 0.0
		while offset <= length + 0.001 and not (closed and offset > length - spacing * 0.5 and offset > 0.0):
			offsets.append(minf(offset, length))
			offset += spacing
	else:
		var count := int(params.get("count", 10))
		if count < 1 or count > MAX_PLACED:
			return _send_error(client_id, "count must be 1 to %d" % MAX_PLACED, command_id)
		var gaps := count if closed else maxi(count - 1, 1)
		for index in count:
			offsets.append(length * index / gaps if count > 1 else length * 0.5)
	var align := bool(params.get("align", true))
	var container: Node = Node3D.new() if path is Path3D else Node2D.new()
	container.name = _unique_child_name(path, str(params.get("name", scene_path.get_file().get_basename().to_pascal_case() + "Row")))
	for index in offsets.size():
		var copy := packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
		if not (copy is Node3D if path is Path3D else copy is Node2D):
			var root_class := copy.get_class()
			copy.free()
			container.free()
			return _send_error(client_id, "%s has a %s root; a %s needs a scene with a %s root" % [scene_path, root_class, path.get_class(), "Node3D" if path is Path3D else "Node2D"], command_id)
		copy.name = "%s%d" % [copy.name, index + 1]
		var placed = curve.sample_baked_with_rotation(offsets[index], true, true) if path is Path3D else curve.sample_baked_with_rotation(offsets[index], true)
		# The scene root's own transform stays as an offset from the path point.
		if align:
			copy.transform = placed * copy.transform
		else:
			copy.position += placed.origin
		container.add_child(copy)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Place Along Path", transaction_id, {"command": "place_along_path"})
	if not transaction:
		container.free()
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, path, container, scene_root)
	for copy in container.get_children():
		transaction.add_do_method(copy, "set_owner", [scene_root])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(path), container.name), "count": offsets.size(), "path_length": snappedf(length, 0.01)})


# Like the editor's Snap Object to Floor: a physics ray from above each node finds the ground
# (any collision body: terrain, floors, blockouts) and the node moves onto it.
func _snap_to_ground(client_id: int, params: Dictionary, command_id: String) -> void:
	var nodes: Array = []
	for path in params.get("node_paths", []):
		var node = _get_editor_node(str(path))
		if not node is Node3D:
			return _send_error(client_id, "Not a 3D node: %s" % path, command_id)
		nodes.append(node)
	if params.has("parent_path"):
		var parent = _get_editor_node(str(params["parent_path"]))
		if not parent:
			return _send_error(client_id, "parent_path not found: %s" % params["parent_path"], command_id)
		nodes.append_array(parent.get_children().filter(func(child): return child is Node3D))
	if nodes.is_empty() or nodes.size() > 2000:
		return _send_error(client_id, "Pass node_paths and/or parent_path naming 1 to 2000 3D nodes", command_id)
	var scene_root := EditorInterface.get_edited_scene_root()
	var world := scene_root.get_viewport().find_world_3d() if scene_root else null
	if world == null:
		return _send_error(client_id, "The open scene has no 3D world to cast rays in", command_id)
	var space := world.direct_space_state
	var offset := float(params.get("offset", 0.0))
	var rise := clampf(float(params.get("max_rise", 50.0)), 0.0, 10000.0)
	var align := bool(params.get("align_to_normal", false))
	var mask := int(params.get("collision_mask", 0xFFFFFFFF))
	var remove_below := float(params.get("remove_below", -INF))
	var remove_above := float(params.get("remove_above", INF))
	var moves: Array = []
	var missed: Array = []
	var removals: Array = []
	for node in nodes:
		# The node's own bodies would be the first thing the ray hits.
		var exclude: Array[RID] = []
		var bodies: Array = [node]
		bodies.append_array(node.find_children("*", "CollisionObject3D", true, false))
		for body in bodies:
			if body is CollisionObject3D:
				exclude.append(body.get_rid())
		var origin: Vector3 = node.global_position
		var query := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * rise, origin + Vector3.DOWN * 10000.0, mask, exclude)
		var hit := space.intersect_ray(query)
		if hit.is_empty():
			missed.append(_to_mcp_path(node))
			continue
		# Scattered props that land in the sea or on a peak go away (undo brings them back).
		if hit["position"].y < remove_below or hit["position"].y > remove_above:
			removals.append(node)
			continue
		var target: Transform3D = node.global_transform
		var up: Vector3 = hit["normal"] if align else Vector3.UP
		target.origin = hit["position"] + up * offset
		if align:
			var forward := target.basis.z.slide(up).normalized()
			if forward.is_zero_approx():
				forward = Vector3.BACK.slide(up).normalized()
			var node_scale := target.basis.get_scale()
			target.basis = Basis(up.cross(forward), up, forward).orthonormalized() * Basis.from_scale(node_scale)
		var parent_inverse: Transform3D = node.get_parent().global_transform.affine_inverse() if node.get_parent() is Node3D else Transform3D()
		moves.append([node, parent_inverse * target, snappedf(target.origin.y - origin.y, 0.01)])
	if moves.is_empty() and removals.is_empty():
		return _send_error(client_id, "No ground under any node (rays found no collision body). Missed: %s" % ", ".join(PackedStringArray(missed.slice(0, 10))), command_id)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Snap To Ground", transaction_id, {"command": "snap_to_ground"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var summary: Array = []
	for move in moves:
		transaction.add_do_property(move[0], "transform", move[1])
		transaction.add_undo_property(move[0], "transform", move[0].transform)
		if summary.size() < 20:
			summary.append("%s %+.2f m" % [move[0].name, move[2]])
	for node in removals:
		_remove_with_undo(transaction, node)
	var opened := _open_instances(transaction, moves.map(func(move): return move[0]))
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"moved": moves.size(), "changes": summary, "missed": missed.slice(0, 20), "removed": removals.size(),
		"editable_children": opened})


# --- GridMap mesh library -------------------------------------------------------------------

# Same rules as the editor's Scene > Export As > MeshLibrary: each MeshInstance3D child is one
# item; StaticBody3D children give its collision shapes; NavigationRegion3D children its navmesh.
func _build_mesh_library(client_id: int, params: Dictionary, command_id: String) -> void:
	var source := str(params.get("source", ""))
	var root: Node = null
	var loaded: Node = null
	if source.begins_with("res://"):
		var packed: PackedScene = ResourceLoader.load(_contained_res_path(source), "PackedScene") if ResourceLoader.exists(_contained_res_path(source), "PackedScene") else null
		if packed == null:
			return _send_error(client_id, "source scene not found: %s" % source, command_id)
		loaded = packed.instantiate()
		root = loaded
	else:
		root = _get_editor_node(source)
		if root == null:
			return _send_error(client_id, "source must be a res:// scene or a node in the open scene: %s" % source, command_id)
	var save_path := _contained_res_path(str(params.get("save_path", "")))
	if save_path.is_empty() or _is_protected_path(save_path) or not save_path.get_extension() in ["tres", "res", "meshlib"]:
		if loaded:
			loaded.free()
		return _send_error(client_id, "save_path must be a .tres, .res or .meshlib file in the project", command_id)
	var library := MeshLibrary.new()
	var items: Array = []
	for child in root.get_children():
		if not child is MeshInstance3D or child.mesh == null:
			continue
		var id := items.size()
		var mesh = child.mesh.duplicate()
		for surface in mesh.get_surface_count():
			var material = child.material_override if child.material_override else child.get_surface_override_material(surface)
			if material == null:
				continue
			if mesh is PrimitiveMesh:
				mesh.material = material
			elif mesh is ArrayMesh:
				mesh.surface_set_material(surface, material)
		library.create_item(id)
		library.set_item_name(id, str(child.name))
		library.set_item_mesh(id, mesh)
		# Like the editor's default (no "Apply MeshInstance Transforms"), but rotation and scale are kept;
		# the position is dropped because tiles usually sit side by side in their scene.
		library.set_item_mesh_transform(id, Transform3D(child.basis, Vector3.ZERO))
		var shapes: Array = []
		for body in child.get_children():
			if body is StaticBody3D:
				for collision in body.get_children():
					if collision is CollisionShape3D and collision.shape:
						shapes.append(collision.shape)
						shapes.append(body.transform * collision.transform)
			elif body is NavigationRegion3D and body.navigation_mesh:
				library.set_item_navigation_mesh(id, body.navigation_mesh)
				library.set_item_navigation_mesh_transform(id, body.transform)
		library.set_item_shapes(id, shapes)
		items.append("%d %s%s" % [id, child.name, " (collision)" if not shapes.is_empty() else ""])
	if loaded:
		loaded.free()
	if items.is_empty():
		return _send_error(client_id, "%s has no MeshInstance3D children with meshes" % source, command_id)
	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if _save_resource_contained(library, save_path) != OK:
		return _send_error(client_id, "Failed to save %s" % save_path, command_id)
	EditorInterface.get_resource_filesystem().update_file(save_path)
	var response := {"save_path": save_path, "items": items}
	if params.has("gridmap_path"):
		var gridmap := _get_editor_node(str(params["gridmap_path"])) as GridMap
		if not gridmap:
			return _send_error(client_id, "Saved %s, but gridmap_path is not a GridMap: %s" % [save_path, params["gridmap_path"]], command_id)
		var transaction = _transaction("Assign Mesh Library", "", {"command": "build_mesh_library"})
		if not transaction:
			return _send_error(client_id, "Failed to obtain scene transaction", command_id)
		transaction.add_do_property(gridmap, "mesh_library", ResourceLoader.load(save_path))
		transaction.add_undo_property(gridmap, "mesh_library", gridmap.mesh_library)
		transaction.register_on_commit(func(): _mark_scene_modified())
		response["gridmap_path"] = _to_mcp_path(gridmap)
		return _finish_transaction(client_id, command_id, transaction, "", response)
	_send_success(client_id, response, command_id)
