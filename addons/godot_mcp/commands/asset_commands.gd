@tool
class_name MCPAssetCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"
## Make assets game-ready: 3D model import settings (collision, loops, humanoid retarget,
## animation libraries), collision from meshes and sprites, CSG baking, noise terrain and UI themes.

const MODEL_EXTENSIONS := ["glb", "gltf", "fbx", "blend", "obj", "dae"]
# ResourceImporterScene enums, by word.
const PHYSICS_SHAPES := {"decompose": 0, "convex": 1, "trimesh": 2, "box": 3, "sphere": 4, "cylinder": 5, "capsule": 6, "auto": 7}
const PHYSICS_BODIES := {"static": 0, "rigid": 1, "area": 2}
const LOOP_MODES := {"none": 0, "linear": 1, "pingpong": 2}
# Words that start bone names in common rigs (Mixamo, Rigify, VRM, 3ds Max Biped) and carry no meaning.
const BONE_PREFIX_TOKENS := ["mixamorig", "def", "org", "mch", "j", "bip", "bip01", "bip001", "c", "armature", "valvebiped"]
# Bone name (prefix, side and separators removed) -> SkeletonProfileHumanoid name without its side.
const HUMANOID_ALIASES := {
	"hips": "Hips", "pelvis": "Hips", "spine": "Spine", "spine01": "Spine", "spine1": "Chest", "spine02": "Chest", "chest": "Chest",
	"spine2": "UpperChest", "spine03": "UpperChest", "upperchest": "UpperChest", "neck": "Neck", "neck01": "Neck", "head": "Head",
	"jaw": "Jaw", "eye": "Eye",
	"shoulder": "Shoulder", "clavicle": "Shoulder", "arm": "UpperArm", "upperarm": "UpperArm", "forearm": "LowerArm", "lowerarm": "LowerArm",
	"hand": "Hand", "upleg": "UpperLeg", "upperleg": "UpperLeg", "thigh": "UpperLeg", "leg": "LowerLeg", "lowerleg": "LowerLeg",
	"calf": "LowerLeg", "shin": "LowerLeg", "foot": "Foot", "toebase": "Toes", "toes": "Toes", "toe": "Toes", "ball": "Toes",
}
const CENTER_BONES := ["Hips", "Spine", "Chest", "UpperChest", "Neck", "Head", "Jaw"]
const FINGERS := {"thumb": "Thumb", "index": "Index", "middle": "Middle", "ring": "Ring", "pinky": "Little", "little": "Little"}
const MAX_TERRAIN_RESOLUTION := 512
# Per-item import options worth showing; Godot writes every other option with its default.
const SHOWN_SUBRESOURCE_OPTIONS := ["settings/loop_mode", "generate/physics", "physics/shape_type", "physics/body_type", "retarget/bone_map", "use_external/path"]


func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"inspect_model":
			_inspect_model(client_id, params, command_id)
		"configure_model_import":
			_configure_model_import(client_id, params, command_id)
		"add_animation_library":
			_add_animation_library(client_id, params, command_id)
		"generate_mesh_collision":
			_generate_mesh_collision(client_id, params, command_id)
		"sprite_to_polygon":
			_sprite_to_polygon(client_id, params, command_id)
		"bake_csg":
			_bake_csg(client_id, params, command_id)
		"generate_terrain_3d":
			_generate_terrain_3d(client_id, params, command_id)
		"generate_ui_theme":
			_generate_ui_theme(client_id, params, command_id)
		_:
			return false
	return true


# --- 3D models ------------------------------------------------------------------------------

# "" when path is a model file in the project, else the error.
func _model_path_error(path: String) -> String:
	if _contained_res_path(path).is_empty() or not path.get_extension().to_lower() in MODEL_EXTENSIONS:
		return "model_path must be a %s file in the project: %s" % [", ".join(PackedStringArray(MODEL_EXTENSIONS)), path]
	if not FileAccess.file_exists(path) or not FileAccess.file_exists(path + ".import"):
		return "%s is not imported yet (no %s.import); run rescan_filesystem first" % [path, path.get_file()]
	return ""


# The model as Godot imported it: a scene root, or null when it imports as an animation library.
func _imported_model(path: String) -> Node:
	var resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	return resource.instantiate() if resource is PackedScene else null


# The model as the file describes it, before import options rename or retype anything. Import
# options address nodes by these paths. Falls back to the imported scene for other formats.
func _raw_model(path: String) -> Node:
	var ext := path.get_extension().to_lower()
	var document = null
	if ext in ["glb", "gltf"]:
		document = GLTFDocument.new()
	elif ext == "fbx" and ClassDB.class_exists("FBXDocument"):
		document = ClassDB.instantiate("FBXDocument")
	if document:
		var state = GLTFState.new() if document is GLTFDocument else ClassDB.instantiate("FBXState")
		if document.append_from_file(ProjectSettings.globalize_path(path), state) == OK:
			var scene = document.generate_scene(state)
			if scene:
				return scene
	return _imported_model(path)


func _subresource_path(root: Node, node: Node) -> String:
	return "PATH:" + str(root.get_path_to(node))


func _inspect_model(client_id: int, params: Dictionary, command_id: String) -> void:
	var path := str(params.get("model_path", ""))
	var error := _model_path_error(path)
	if not error.is_empty():
		return _send_error(client_id, error, command_id)
	_send_success(client_id, _describe_model(path), command_id)


func _describe_model(path: String) -> Dictionary:
	var config := ConfigFile.new()
	config.load(path + ".import")
	var importer := str(config.get_value("remap", "importer", "scene"))
	var result := {"model_path": path, "import_as": "animation_library" if importer == "animation_library" else "scene",
		"meshes": [], "materials": [], "animations": [], "skeletons": []}
	var settings := {}
	for key in ["nodes/root_type", "nodes/root_name", "nodes/root_scale", "meshes/light_baking", "animation/fps", "materials/extract"]:
		var value = config.get_value("params", key, null)
		if value != null and str(value) != "" and not (key == "nodes/root_scale" and float(value) == 1.0):
			settings[key] = value
	var subresources: Dictionary = config.get_value("params", "_subresources", {})
	for category in subresources:
		for item in subresources[category]:
			var options: Dictionary = subresources[category][item]
			for option in SHOWN_SUBRESOURCE_OPTIONS:
				if options.has(option) and not (option == "generate/physics" and not options[option]):
					settings["%s/%s/%s" % [category, item, option]] = "BoneMap" if option == "retarget/bone_map" else options[option]
	result["settings"] = settings
	var root := _imported_model(path)
	if root == null:
		var library = ResourceLoader.load(path)
		if library is AnimationLibrary:
			for anim_name in library.get_animation_list():
				result["animations"].append(_animation_summary(anim_name, library.get_animation(anim_name)))
		return result
	result["root"] = "%s (%s)" % [root.name, root.get_class()]
	var materials := {}
	var nodes: Array = [root]
	nodes.append_array(root.find_children("*", "", true, false))
	for node in nodes:
		if node is MeshInstance3D and node.mesh:
			var surfaces: Array = []
			for surface in node.mesh.get_surface_count():
				var material = node.get_active_material(surface)
				var material_name: String = material.resource_name if material and not material.resource_name.is_empty() else ("surface %d" % surface)
				surfaces.append(material_name)
				materials[material_name] = true
			result["meshes"].append({"path": str(root.get_path_to(node)), "materials": surfaces, "skinned": node.skin != null})
		elif node is Skeleton3D:
			result["skeletons"].append({"path": str(root.get_path_to(node)), "bones": node.get_bone_count(), "humanoid": _humanoid_map(node).size()})
		elif node is AnimationPlayer:
			for anim_name in node.get_animation_list():
				result["animations"].append(_animation_summary(anim_name, node.get_animation(anim_name)))
		elif node is CollisionShape3D and node.shape:
			result["meshes"].append({"path": str(root.get_path_to(node)), "collision": node.shape.get_class()})
	result["materials"] = materials.keys()
	root.free()
	return result


func _animation_summary(anim_name: String, animation: Animation) -> Dictionary:
	return {"name": anim_name, "length": snappedf(animation.length, 0.01), "loop": LOOP_MODES.find_key(animation.loop_mode), "tracks": animation.get_track_count()}


# Bone name -> SkeletonProfileHumanoid bone, guessed from common rig naming (Mixamo, Unreal, VRM,
# Rigify, Blender .L/.R). Only names that fit one profile bone are kept.
func _humanoid_map(skeleton: Skeleton3D) -> Dictionary:
	var camel := RegEx.create_from_string("([a-z0-9])([A-Z])")
	var separators := RegEx.create_from_string("[^A-Za-z0-9]+")
	var finger := RegEx.create_from_string("(thumb|index|middle|ring|pinky|little)[a-z]*0?([1-3])$")
	var mapping := {}
	for bone in skeleton.get_bone_count():
		var bone_name := skeleton.get_bone_name(bone)
		var spaced := separators.sub(camel.sub(bone_name, "$1 $2", true), " ", true).to_lower()
		var tokens: Array = Array(spaced.split(" ", false)).filter(func(token): return not token in BONE_PREFIX_TOKENS)
		var side := ""
		for token in tokens.duplicate():
			if token in ["left", "l"]:
				side = "Left"
				tokens.erase(token)
			elif token in ["right", "r"]:
				side = "Right"
				tokens.erase(token)
		var core := "".join(PackedStringArray(tokens))
		for word in ["left", "right"]:
			if core.begins_with(word) and side.is_empty():
				side = word.capitalize()
				core = core.trim_prefix(word)
		var base := ""
		var finger_match := finger.search(core)
		if finger_match:
			var digit := int(finger_match.get_string(2)) - 1
			var finger_name: String = FINGERS[finger_match.get_string(1)]
			var joints := ["Metacarpal", "Proximal", "Distal"] if finger_name == "Thumb" else ["Proximal", "Intermediate", "Distal"]
			base = finger_name + joints[digit]
		elif HUMANOID_ALIASES.has(core):
			base = HUMANOID_ALIASES[core]
		if base.is_empty() or (base in CENTER_BONES) != side.is_empty():
			continue
		var profile_name := side + base
		if not profile_name in mapping.values():
			mapping[bone_name] = profile_name
	return mapping


func _configure_model_import(client_id: int, params: Dictionary, command_id: String) -> void:
	var path := str(params.get("model_path", ""))
	var error := _model_path_error(path)
	if not error.is_empty():
		return _send_error(client_id, error, command_id)
	var config := ConfigFile.new()
	if config.load(path + ".import") != OK:
		return _send_error(client_id, "Failed to read %s.import" % path, command_id)
	var notes: Array = []
	var import_as := str(params.get("import_as", ""))
	if not import_as.is_empty():
		if not import_as in ["scene", "animation_library"]:
			return _send_error(client_id, "import_as must be scene or animation_library", command_id)
		config.set_value("remap", "importer", import_as)
		config.set_value("remap", "type", "PackedScene" if import_as == "scene" else "AnimationLibrary")
	if params.has("root_type"):
		var root_type := str(params["root_type"])
		if not ClassDB.class_exists(root_type) or not ClassDB.is_parent_class(root_type, "Node3D"):
			return _send_error(client_id, "root_type must be a 3D node class, e.g. CharacterBody3D: %s" % root_type, command_id)
		config.set_value("params", "nodes/root_type", root_type)
	if params.has("root_name"):
		config.set_value("params", "nodes/root_name", str(params["root_name"]).validate_node_name())
	if params.has("root_scale"):
		config.set_value("params", "nodes/root_scale", clampf(float(params["root_scale"]), 0.0001, 10000.0))
	if params.has("lightmap_uv"):
		# meshes/light_baking: 1 dynamic (default), 2 static lightmaps (generates UV2).
		config.set_value("params", "meshes/light_baking", 2 if bool(params["lightmap_uv"]) else 1)
	if params.has("animation_fps"):
		config.set_value("params", "animation/fps", clampi(int(params["animation_fps"]), 1, 240))
	if params.has("extract_materials_to"):
		var folder := _contained_res_path(str(params["extract_materials_to"]))
		if folder.is_empty() or _is_protected_path(folder.path_join("x")):
			return _send_error(client_id, "extract_materials_to must be a folder in the project", command_id)
		DirAccess.make_dir_recursive_absolute(folder)
		config.set_value("params", "materials/extract", 1)
		config.set_value("params", "materials/extract_format", 0)
		config.set_value("params", "materials/extract_path", folder)

	var subresources: Dictionary = config.get_value("params", "_subresources", {})
	for category in ["nodes", "animations", "meshes", "materials"]:
		if not subresources.has(category):
			subresources[category] = {}
	var raw := _raw_model(path) if params.has("collision") or params.has("humanoid") else null

	if params.has("collision"):
		var spec = params["collision"]
		if typeof(spec) != TYPE_DICTIONARY:
			return _send_error(client_id, "collision must be {shape, body, meshes}", command_id)
		var shape := str(spec.get("shape", "trimesh"))
		var body := str(spec.get("body", "static"))
		if shape != "none" and not PHYSICS_SHAPES.has(shape):
			return _send_error(client_id, "collision.shape must be none or one of: %s" % ", ".join(PackedStringArray(PHYSICS_SHAPES.keys())), command_id)
		if not PHYSICS_BODIES.has(body):
			return _send_error(client_id, "collision.body must be static, rigid or area", command_id)
		var wanted: Array = spec.get("meshes", [])
		var matched: Array = []
		# Model files load with ImporterMeshInstance3D nodes, the imported scene with MeshInstance3D.
		var raw_meshes: Array = (raw.find_children("*", "", true, false) if raw else []).filter(
			func(found): return found is MeshInstance3D or found.is_class("ImporterMeshInstance3D"))
		for node in raw_meshes:
			var relative := str(raw.get_path_to(node))
			if not wanted.is_empty() and not relative in wanted and not str(node.name) in wanted:
				continue
			var options: Dictionary = subresources["nodes"].get(_subresource_path(raw, node), {})
			options["generate/physics"] = shape != "none"
			if shape != "none":
				options["physics/shape_type"] = PHYSICS_SHAPES[shape]
				options["physics/body_type"] = PHYSICS_BODIES[body]
			subresources["nodes"][_subresource_path(raw, node)] = options
			matched.append(relative)
		if matched.is_empty():
			if raw:
				raw.free()
			return _send_error(client_id, "No mesh matched collision.meshes; use inspect_model to list them", command_id)
		notes.append("collision %s/%s on %s" % [body, shape, ", ".join(PackedStringArray(matched))])

	if params.has("loop"):
		var loop = params["loop"]
		if not (typeof(loop) == TYPE_BOOL or typeof(loop) == TYPE_ARRAY):
			return _send_error(client_id, "loop must be true (all), false (none) or a list of animation names", command_id)
		var known: Array = _describe_model(path)["animations"].map(func(animation): return animation["name"])
		var names: Array = known if typeof(loop) == TYPE_BOOL else loop
		var loop_mode := str(params.get("loop_mode", "linear"))
		if not LOOP_MODES.has(loop_mode):
			return _send_error(client_id, "loop_mode must be linear or pingpong", command_id)
		var mode: int = 0 if typeof(loop) == TYPE_BOOL and not loop else LOOP_MODES[loop_mode]
		for anim_name in names:
			if not anim_name in known:
				return _send_error(client_id, "No animation %s; this model has: %s" % [anim_name, ", ".join(PackedStringArray(known))], command_id)
			var options: Dictionary = subresources["animations"].get(anim_name, {})
			options["settings/loop_mode"] = mode
			subresources["animations"][anim_name] = options
		notes.append("loop %s on %s" % [LOOP_MODES.find_key(mode), ", ".join(PackedStringArray(names))])

	if params.has("humanoid"):
		var skeletons: Array = raw.find_children("*", "Skeleton3D", true, false) if raw else []
		if skeletons.is_empty():
			if raw:
				raw.free()
			return _send_error(client_id, "%s has no Skeleton3D to retarget" % path, command_id)
		var skeleton: Skeleton3D = skeletons[0]
		var key := _subresource_path(raw, skeleton)
		var options: Dictionary = subresources["nodes"].get(key, {})
		if bool(params["humanoid"]):
			var mapping := _humanoid_map(skeleton)
			var bone_map := BoneMap.new()
			bone_map.profile = SkeletonProfileHumanoid.new()
			for bone_name in mapping:
				bone_map.set_skeleton_bone_name(mapping[bone_name], bone_name)
			var missing: Array = []
			for index in bone_map.profile.bone_size:
				if bone_map.profile.is_required(index) and str(bone_map.get_skeleton_bone_name(bone_map.profile.get_bone_name(index))).is_empty():
					missing.append(bone_map.profile.get_bone_name(index))
			options["retarget/bone_map"] = bone_map
			notes.append("humanoid: %d bones mapped%s" % [mapping.size(), "; required but not found: " + ", ".join(PackedStringArray(missing)) if not missing.is_empty() else ", all required bones found"])
		else:
			options.erase("retarget/bone_map")
			notes.append("humanoid retarget off")
		subresources["nodes"][key] = options
	if raw:
		raw.free()

	for category in subresources.keys():
		if (subresources[category] as Dictionary).is_empty():
			subresources.erase(category)
	config.set_value("params", "_subresources", subresources)
	if config.save(path + ".import") != OK:
		return _send_error(client_id, "Failed to write %s.import" % path, command_id)
	EditorInterface.get_resource_filesystem().reimport_files(PackedStringArray([path]))
	var result := _describe_model(path)
	result["changed"] = notes
	_send_success(client_id, result, command_id)


func _add_animation_library(client_id: int, params: Dictionary, command_id: String) -> void:
	var player = _get_editor_node(str(params.get("player_path", "")))
	if not player is AnimationMixer:
		return _send_error(client_id, "player_path must be an AnimationPlayer (or AnimationTree)", command_id)
	var source := _contained_res_path(str(params.get("source", "")))
	if source.is_empty() or not ResourceLoader.exists(source):
		return _send_error(client_id, "source must be an AnimationLibrary file or a model in the project: %s" % params.get("source", ""), command_id)
	var resource = ResourceLoader.load(source)
	var library: AnimationLibrary = null
	var copied := false
	if resource is AnimationLibrary:
		library = resource
	elif resource is PackedScene:
		var scene: Node = resource.instantiate()
		var players: Array = [scene]
		players.append_array(scene.find_children("*", "AnimationPlayer", true, false))
		for found in players:
			if found is AnimationPlayer and found.has_animation_library(""):
				library = found.get_animation_library("").duplicate(true)
				copied = true
				break
		scene.free()
	if library == null or library.get_animation_list().is_empty():
		return _send_error(client_id, "%s holds no animations" % source, command_id)
	var library_name := str(params.get("library_name", source.get_file().get_basename())).validate_node_name().replace(".", "_")
	if player.has_animation_library(library_name):
		return _send_error(client_id, "%s already has a library named \"%s\"; pass another library_name" % [_to_mcp_path(player), library_name], command_id)
	# Count tracks whose node exists from the player's root node, so a skeleton mismatch shows now.
	var root: Node = player.get_node_or_null(player.root_node)
	var resolved := 0
	var total := 0
	var unresolved: Array = []
	for anim_name in library.get_animation_list():
		var animation := library.get_animation(anim_name)
		for track in animation.get_track_count():
			total += 1
			var track_path := animation.track_get_path(track)
			var target: Node = root.get_node_or_null(NodePath(str(track_path).get_slice(":", 0))) if root else null
			if target and (track_path.get_subname_count() == 0 or not target is Skeleton3D or target.find_bone(track_path.get_subname(0)) != -1):
				resolved += 1
			elif unresolved.size() < 5 and not str(track_path) in unresolved:
				unresolved.append(str(track_path))
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Add Animation Library", transaction_id, {"command": "add_animation_library"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	transaction.add_do_method(player, "add_animation_library", [library_name, library])
	transaction.add_undo_method(player, "remove_animation_library", [library_name])
	var opened := _open_instances(transaction, [player])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"player_path": _to_mcp_path(player), "library_name": library_name, "animations": library.get_animation_list(),
		"embedded_copy": copied, "tracks_resolved": resolved, "tracks_total": total, "unresolved_examples": unresolved,
		"editable_children": opened})


# --- collision ------------------------------------------------------------------------------

func _shape_for_mesh(mesh: Mesh, shape: String) -> Array:
	match shape:
		"trimesh":
			return [mesh.create_trimesh_shape()]
		"convex":
			return [mesh.create_convex_shape(true, false)]
		"simplified_convex":
			return [mesh.create_convex_shape(true, true)]
		"multiple_convex":
			# Mesh does not expose the decomposition itself; a throwaway MeshInstance3D builds it.
			var helper := MeshInstance3D.new()
			helper.mesh = mesh
			helper.create_multiple_convex_collisions()
			var shapes: Array = []
			for child in helper.find_children("*", "CollisionShape3D", true, false):
				shapes.append(child.shape)
			helper.free()
			return shapes
	return []


func _generate_mesh_collision(client_id: int, params: Dictionary, command_id: String) -> void:
	var node := _get_editor_node(str(params.get("node_path", "")))
	if not node:
		return _send_error(client_id, "Node not found: %s" % params.get("node_path", ""), command_id)
	var shape := str(params.get("shape", "trimesh"))
	if not shape in ["trimesh", "convex", "simplified_convex", "multiple_convex"]:
		return _send_error(client_id, "shape must be trimesh, convex, simplified_convex or multiple_convex", command_id)
	var meshes: Array = [node] if node is MeshInstance3D else []
	meshes.append_array(node.find_children("*", "MeshInstance3D", true, true))
	meshes = meshes.filter(func(mesh_instance): return mesh_instance.mesh != null)
	if meshes.is_empty() or meshes.size() > 256:
		return _send_error(client_id, "node_path must be a MeshInstance3D with a mesh, or hold 1 to 256 of them", command_id)
	var planned: Array = []
	for mesh_instance in meshes:
		var shapes := _shape_for_mesh(mesh_instance.mesh, shape).filter(func(item): return item != null)
		if not shapes.is_empty():
			planned.append([mesh_instance, shapes])
	if planned.is_empty():
		return _send_error(client_id, "No collision could be made from these meshes", command_id)
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Generate Mesh Collision", transaction_id, {"command": "generate_mesh_collision"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var created: Array = []
	for plan in planned:
		var mesh_instance: MeshInstance3D = plan[0]
		var shapes: Array = plan[1]
		# Under a body already: shapes go next to the mesh. Otherwise a StaticBody3D child holds them,
		# like the editor's Mesh > Create Collision Shape.
		var parent: Node = mesh_instance.get_parent()
		var holder: Node = parent
		var offset: Transform3D = mesh_instance.transform
		if not parent is CollisionObject3D:
			var body := StaticBody3D.new()
			body.name = _unique_child_name(mesh_instance, "StaticBody3D")
			_add_owned(transaction, mesh_instance, body, scene_root)
			holder = body
			offset = Transform3D()
		for index in shapes.size():
			var collision := CollisionShape3D.new()
			collision.shape = shapes[index]
			collision.transform = offset
			collision.name = _unique_child_name(holder, "%sCollision%s" % [mesh_instance.name, "" if shapes.size() == 1 else str(index + 1)]) if holder == parent else "CollisionShape3D%s" % ("" if index == 0 else str(index + 1))
			_add_owned(transaction, holder, collision, scene_root)
		created.append("%s: %d %s" % [_to_mcp_path(mesh_instance), shapes.size(), shapes[0].get_class()])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {"shape": shape, "created": created})


func _sprite_to_polygon(client_id: int, params: Dictionary, command_id: String) -> void:
	var sprite = _get_editor_node(str(params.get("node_path", "")))
	if not sprite is Sprite2D or sprite.texture == null:
		return _send_error(client_id, "node_path must be a Sprite2D with a texture", command_id)
	var output := str(params.get("output", "collision"))
	if not output in ["collision", "occluder", "polygon"]:
		return _send_error(client_id, "output must be collision, occluder or polygon", command_id)
	var image: Image = sprite.texture.get_image()
	if image == null:
		return _send_error(client_id, "Could not read the texture's pixels", command_id)
	if image.is_compressed():
		image.decompress()
	# The drawn area: the region, else one frame of the hframes x vframes sheet.
	var rect := Rect2i(Vector2i.ZERO, image.get_size())
	if sprite.region_enabled:
		rect = Rect2i(sprite.region_rect)
	elif sprite.hframes > 1 or sprite.vframes > 1:
		var frame_size := Vector2i(image.get_width() / sprite.hframes, image.get_height() / sprite.vframes)
		rect = Rect2i(Vector2i(sprite.frame % sprite.hframes, sprite.frame / sprite.hframes) * frame_size, frame_size)
	rect = rect.intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	if rect.size.x < 2 or rect.size.y < 2:
		return _send_error(client_id, "The sprite's drawn area is empty", command_id)
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image.get_region(rect), clampf(float(params.get("alpha_threshold", 0.1)), 0.0, 1.0))
	var grow := clampi(int(params.get("grow", 0)), -16, 16)
	if grow != 0:
		bitmap.grow_mask(grow, Rect2i(Vector2i.ZERO, rect.size))
	var polygons := bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO, rect.size), clampf(float(params.get("simplify", 2.0)), 0.0, 32.0))
	if polygons.is_empty():
		return _send_error(client_id, "No opaque pixels above alpha_threshold", command_id)
	if polygons.size() > 64:
		return _send_error(client_id, "%d separate shapes; raise simplify or alpha_threshold" % polygons.size(), command_id)
	var shift: Vector2 = sprite.offset - (Vector2(rect.size) * 0.5 if sprite.centered else Vector2.ZERO)
	var local_polygons: Array = []
	for polygon in polygons:
		var points := PackedVector2Array()
		for point in polygon:
			var flipped := Vector2(rect.size.x - point.x if sprite.flip_h else point.x, rect.size.y - point.y if sprite.flip_v else point.y)
			points.append(flipped + shift)
		# One flip mirrors the outline and turns its winding around; turn it back.
		if sprite.flip_h != sprite.flip_v:
			points.reverse()
		local_polygons.append(points)
	var parent: Node = sprite.get_parent()
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Sprite To Polygon", transaction_id, {"command": "sprite_to_polygon"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	var created: Array = []
	var holder: Node = parent
	var holder_path := _to_mcp_path(parent)
	if output == "collision" and not parent is CollisionObject2D:
		var body := StaticBody2D.new()
		body.name = _unique_child_name(parent, "%sBody" % sprite.name)
		body.transform = sprite.transform
		_add_owned(transaction, parent, body, scene_root)
		holder = body
		holder_path = _join_path(holder_path, body.name)
		created.append(holder_path)
	var taken: Array = []
	for index in local_polygons.size():
		var node: Node2D
		match output:
			"collision":
				node = CollisionPolygon2D.new()
				node.polygon = local_polygons[index]
			"occluder":
				node = LightOccluder2D.new()
				node.occluder = OccluderPolygon2D.new()
				node.occluder.polygon = local_polygons[index]
			"polygon":
				node = Polygon2D.new()
				node.polygon = local_polygons[index]
				node.texture = sprite.texture
				# UVs are texture pixels; undo the centering shift and the flip, add the region origin.
				var uv := PackedVector2Array()
				for point in local_polygons[index]:
					var pixel: Vector2 = point - shift
					pixel = Vector2(rect.size.x - pixel.x if sprite.flip_h else pixel.x, rect.size.y - pixel.y if sprite.flip_v else pixel.y)
					uv.append(pixel + Vector2(rect.position))
				node.uv = uv
		if holder == parent:
			node.transform = sprite.transform
		var wanted := "%s%s%s" % [sprite.name, {"collision": "Collision", "occluder": "Occluder", "polygon": "Polygon"}[output], "" if local_polygons.size() == 1 else str(index + 1)]
		node.name = _unique_child_name(holder, wanted)
		while str(node.name) in taken:
			node.name = str(node.name) + "_"
		taken.append(str(node.name))
		_add_owned(transaction, holder, node, scene_root)
		created.append("%s (%d points)" % [_join_path(holder_path, node.name), local_polygons[index].size()])
	transaction.register_on_commit(func(): _mark_scene_modified())
	_finish_transaction(client_id, command_id, transaction, transaction_id, {"output": output, "polygons": local_polygons.size(), "created": created})


func _bake_csg(client_id: int, params: Dictionary, command_id: String) -> void:
	var csg = _get_editor_node(str(params.get("node_path", "")))
	if not csg is CSGShape3D or not csg.is_root_shape():
		return _send_error(client_id, "node_path must be a root CSG shape (a CSG node whose parent is not CSG)", command_id)
	if not csg.has_method("bake_static_mesh"):
		return _send_error(client_id, "Baking CSG needs Godot 4.4 or newer (this is %s)" % _godot_version(), command_id)
	var mesh: Mesh = csg.bake_static_mesh()
	if mesh == null or mesh.get_surface_count() == 0:
		return _send_error(client_id, "The CSG shape produced no mesh", command_id)
	var with_collision := bool(params.get("collision", true))
	var keep := bool(params.get("keep_csg", false))
	var save_path := str(params.get("save_mesh_to", ""))
	if not save_path.is_empty():
		save_path = _contained_res_path(save_path)
		if save_path.is_empty() or _is_protected_path(save_path) or not save_path.get_extension() in ["res", "tres", "mesh"]:
			return _send_error(client_id, "save_mesh_to must be a .res, .tres or .mesh file in the project", command_id)
		DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
		if _save_resource_contained(mesh, save_path) != OK:
			return _send_error(client_id, "Failed to save %s" % save_path, command_id)
	var parent: Node = csg.get_parent()
	var scene_root := EditorInterface.get_edited_scene_root()
	var baked := MeshInstance3D.new()
	baked.name = _unique_child_name(parent, str(params.get("name", "%sBaked" % csg.name)))
	baked.mesh = mesh
	baked.transform = csg.transform
	if with_collision:
		var body := StaticBody3D.new()
		body.name = "StaticBody3D"
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		collision.shape = csg.bake_collision_shape()
		body.add_child(collision)
		baked.add_child(body)
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Bake CSG", transaction_id, {"command": "bake_csg"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, parent, baked, scene_root)
	for inner in baked.find_children("*", "", true, false):
		transaction.add_do_method(inner, "set_owner", [scene_root])
	transaction.add_do_method(parent, "move_child", [baked, csg.get_index() + 1])
	if not keep:
		_remove_with_undo(transaction, csg)
	transaction.register_on_commit(func(): _mark_scene_modified())
	var faces := mesh.get_faces().size() / 3
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), baked.name), "triangles": faces, "collision": with_collision,
		"csg_removed": not keep, "mesh_path": save_path})


# --- terrain --------------------------------------------------------------------------------

func _generate_terrain_3d(client_id: int, params: Dictionary, command_id: String) -> void:
	var parent = _get_editor_node(str(params.get("parent_path", "/root")))
	if not parent is Node3D:
		return _send_error(client_id, "parent_path must be a 3D node", command_id)
	var size := clampf(float(params.get("size", 64.0)), 2.0, 4096.0)
	var resolution := clampi(int(params.get("resolution", 64)), 2, MAX_TERRAIN_RESOLUTION)
	var height := clampf(float(params.get("height", 8.0)), 0.0, 1000.0)
	var island := bool(params.get("island", false))
	var noise := FastNoiseLite.new()
	noise.seed = int(params.get("seed", 1))
	noise.frequency = clampf(float(params.get("frequency", 0.02)), 0.0001, 1.0) * 64.0 / size
	noise.fractal_octaves = clampi(int(params.get("octaves", 4)), 1, 9)
	var folder := _contained_res_path(str(params.get("save_dir", "res://terrain")))
	if folder.is_empty() or _is_protected_path(folder.path_join("x")):
		return _send_error(client_id, "save_dir must be a folder in the project", command_id)
	var terrain_name := str(params.get("name", "Terrain")).validate_node_name()
	var cell := size / resolution
	var count := resolution + 1
	var heights := PackedFloat32Array()
	heights.resize(count * count)
	for z in count:
		for x in count:
			var value := noise.get_noise_2d(x * cell, z * cell) * 0.5 + 0.5
			if island:
				# Fade to the edges so the land sits in the middle, with shores all around.
				var from_center := Vector2(x, z) / resolution * 2.0 - Vector2.ONE
				value *= clampf(1.0 - from_center.length_squared() * 0.9, 0.0, 1.0)
			heights[z * count + x] = value * height
	var bands := [[0.15, Color(0.82, 0.76, 0.55)], [0.55, Color(0.33, 0.55, 0.25)], [0.8, Color(0.45, 0.42, 0.38)], [1.01, Color(0.95, 0.95, 0.97)]]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in count:
		for x in count:
			var y: float = heights[z * count + x]
			var level := y / height if height > 0.0 else 0.0
			var color: Color = bands[-1][1]
			for band in bands:
				if level < band[0]:
					color = band[1]
					break
			surface.set_color(color)
			surface.set_uv(Vector2(x, z) / resolution)
			surface.add_vertex(Vector3(x * cell - size * 0.5, y, z * cell - size * 0.5))
	for z in resolution:
		for x in resolution:
			var a := z * count + x
			surface.add_index(a)
			surface.add_index(a + 1)
			surface.add_index(a + count)
			surface.add_index(a + 1)
			surface.add_index(a + count + 1)
			surface.add_index(a + count)
	surface.generate_normals()
	var mesh := surface.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.95
	mesh.surface_set_material(0, material)
	# HeightMapShape3D cells are 1 unit apart; a uniform scale of `cell` spaces them like the mesh.
	var shape := HeightMapShape3D.new()
	shape.map_width = count
	shape.map_depth = count
	var scaled := PackedFloat32Array()
	scaled.resize(heights.size())
	for index in heights.size():
		scaled[index] = heights[index] / cell
	shape.map_data = scaled
	DirAccess.make_dir_recursive_absolute(folder)
	var mesh_path := folder.path_join(terrain_name.to_snake_case() + "_mesh.res")
	var shape_path := folder.path_join(terrain_name.to_snake_case() + "_shape.res")
	if _save_resource_contained(mesh, mesh_path) != OK or _save_resource_contained(shape, shape_path) != OK:
		return _send_error(client_id, "Failed to save the terrain into %s" % folder, command_id)
	var terrain := MeshInstance3D.new()
	terrain.name = _unique_child_name(parent, terrain_name)
	terrain.mesh = mesh
	terrain.position = _coerce_to_vector3(params.get("position", [0, 0, 0])) if params.has("position") else Vector3.ZERO
	var body := StaticBody3D.new()
	body.name = "StaticBody3D"
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	collision.scale = Vector3.ONE * cell
	body.add_child(collision)
	terrain.add_child(body)
	if params.has("water_level"):
		var water := MeshInstance3D.new()
		water.name = "Water"
		var plane := PlaneMesh.new()
		plane.size = Vector2(size, size) * 1.5
		var water_material := StandardMaterial3D.new()
		water_material.albedo_color = Color(0.15, 0.4, 0.6, 0.75)
		water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		water_material.roughness = 0.1
		plane.material = water_material
		water.mesh = plane
		water.position.y = clampf(float(params["water_level"]), 0.0, 1.0) * height
		terrain.add_child(water)
	var scene_root := EditorInterface.get_edited_scene_root()
	var transaction_id := str(params.get("transaction_id", ""))
	var transaction = _transaction("Generate Terrain 3D", transaction_id, {"command": "generate_terrain_3d"})
	if not transaction:
		return _send_error(client_id, "Failed to obtain scene transaction", command_id)
	_add_owned(transaction, parent, terrain, scene_root)
	for inner in terrain.find_children("*", "", true, false):
		transaction.add_do_method(inner, "set_owner", [scene_root])
	transaction.register_on_commit(func(): _mark_scene_modified())
	var lowest := INF
	var highest := -INF
	for value in heights:
		lowest = minf(lowest, value)
		highest = maxf(highest, value)
	_finish_transaction(client_id, command_id, transaction, transaction_id, {
		"node_path": _join_path(_to_mcp_path(parent), terrain.name), "size": size, "cells": resolution,
		"height_range": [snappedf(lowest, 0.01), snappedf(highest, 0.01)], "mesh_path": mesh_path, "shape_path": shape_path,
		"water": params.has("water_level")})


# --- UI theme -------------------------------------------------------------------------------

func _style(fill: Color, border: Color, border_width: int, radius: int, padding: Vector2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = padding.x
	style.content_margin_right = padding.x
	style.content_margin_top = padding.y
	style.content_margin_bottom = padding.y
	return style


func _generate_ui_theme(client_id: int, params: Dictionary, command_id: String) -> void:
	var colors := {}
	for key in [["primary", "#4c8bf5"], ["background", "#1e2230"]]:
		var value = _coerce_value_to_type(params.get(key[0], key[1]), TYPE_COLOR)
		if not value is Color:
			return _send_error(client_id, "%s must be a color" % key[0], command_id)
		colors[key[0]] = value
	var primary: Color = colors["primary"]
	var background: Color = colors["background"]
	var dark := background.get_luminance() < 0.5
	var text = _coerce_value_to_type(params["text"], TYPE_COLOR) if params.has("text") else (Color(0.93, 0.94, 0.96) if dark else Color(0.1, 0.11, 0.14))
	if not text is Color:
		return _send_error(client_id, "text must be a color", command_id)
	var on_primary := Color.WHITE if primary.get_luminance() < 0.6 else Color(0.08, 0.08, 0.1)
	var radius := clampi(int(params.get("corner_radius", 6)), 0, 64)
	var font_size := clampi(int(params.get("font_size", 18)), 8, 96)
	var border := clampi(int(params.get("border_width", 0)), 0, 8)
	var padding := Vector2(font_size * 0.8, font_size * 0.4)
	var surface := background.lightened(0.08) if dark else background.darkened(0.06)
	var outline := surface.lightened(0.15) if dark else surface.darkened(0.2)
	var save_path := _contained_res_path(str(params.get("save_path", "res://ui/theme.tres")))
	if save_path.is_empty() or _is_protected_path(save_path) or not save_path.get_extension() in ["tres", "res"]:
		return _send_error(client_id, "save_path must be a .tres or .res file in the project", command_id)

	var theme := Theme.new()
	theme.default_font_size = font_size
	if params.has("font_path"):
		var font_path := _contained_res_path(str(params["font_path"]))
		var font = ResourceLoader.load(font_path) if not font_path.is_empty() and ResourceLoader.exists(font_path) else null
		if not font is Font:
			return _send_error(client_id, "font_path must be a font file in the project (.ttf, .otf, .woff2): %s" % params["font_path"], command_id)
		theme.default_font = font
	# Button styles also cover OptionButton, MenuButton, CheckBox... through the class chain.
	theme.set_stylebox("normal", "Button", _style(primary, primary.darkened(0.25), border, radius, padding))
	theme.set_stylebox("hover", "Button", _style(primary.lightened(0.12), primary.darkened(0.2), border, radius, padding))
	theme.set_stylebox("pressed", "Button", _style(primary.darkened(0.18), primary.darkened(0.35), border, radius, padding))
	theme.set_stylebox("disabled", "Button", _style(primary.lerp(surface, 0.65), outline, border, radius, padding))
	var focus := _style(Color(0, 0, 0, 0), primary.lightened(0.45), 2, radius + 2, padding)
	focus.draw_center = false
	theme.set_stylebox("focus", "Button", focus)
	for item in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		theme.set_color(item, "Button", on_primary)
	theme.set_color("font_disabled_color", "Button", on_primary.lerp(surface, 0.5))
	for type in ["CheckBox", "CheckButton"]:
		# Check boxes draw their own box; a filled button look would hide it.
		var plain := _style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, radius, Vector2(4, 4))
		plain.draw_center = false
		for state in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
			theme.set_stylebox(state, type, plain)
		for item in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			theme.set_color(item, type, text)
	theme.set_color("font_color", "Label", text)
	var panel := _style(surface, outline, 1 if border == 0 else border, radius, padding)
	for type in ["Panel", "PanelContainer", "PopupPanel", "TooltipPanel", "ItemList", "Tree"]:
		theme.set_stylebox("panel", type, panel)
	theme.set_stylebox("panel", "PopupMenu", panel)
	theme.set_stylebox("hover", "PopupMenu", _style(primary, primary, 0, radius, Vector2(4, 2)))
	theme.set_color("font_color", "PopupMenu", text)
	theme.set_color("font_hover_color", "PopupMenu", on_primary)
	theme.set_color("font_color", "TooltipLabel", text)
	var field := _style(background.darkened(0.15) if dark else Color.WHITE, outline, 1, radius, Vector2(padding.x * 0.6, padding.y))
	var field_focus := _style(field.bg_color, primary, 2, radius, Vector2(padding.x * 0.6, padding.y))
	for type in ["LineEdit", "TextEdit", "SpinBox"]:
		theme.set_stylebox("normal", type, field)
		theme.set_stylebox("focus", type, field_focus)
		theme.set_stylebox("read_only", type, _style(surface, outline, 1, radius, Vector2(padding.x * 0.6, padding.y)))
		theme.set_color("font_color", type, text)
		theme.set_color("caret_color", type, primary.lightened(0.3))
		theme.set_color("selection_color", type, Color(primary, 0.4))
		theme.set_color("font_placeholder_color", type, Color(text, 0.45))
	theme.set_stylebox("background", "ProgressBar", _style(background.darkened(0.2) if dark else surface, outline, 0, radius, Vector2.ZERO))
	theme.set_stylebox("fill", "ProgressBar", _style(primary, primary, 0, radius, Vector2.ZERO))
	theme.set_color("font_color", "ProgressBar", text)
	for type in ["HSlider", "VSlider"]:
		theme.set_stylebox("slider", type, _style(background.darkened(0.2) if dark else surface.darkened(0.1), outline, 0, radius, Vector2(0, 3)))
		theme.set_stylebox("grabber_area", type, _style(primary, primary, 0, radius, Vector2(0, 3)))
		theme.set_stylebox("grabber_area_highlight", type, _style(primary.lightened(0.15), primary, 0, radius, Vector2(0, 3)))
	theme.set_stylebox("panel", "TabContainer", panel)
	theme.set_stylebox("tab_selected", "TabContainer", _style(surface, primary, 0, radius, padding))
	theme.set_stylebox("tab_unselected", "TabContainer", _style(background, outline, 0, radius, padding))
	theme.set_stylebox("tab_hovered", "TabContainer", _style(surface.lerp(primary, 0.2), outline, 0, radius, padding))
	theme.set_color("font_selected_color", "TabContainer", text)
	theme.set_color("font_unselected_color", "TabContainer", Color(text, 0.6))

	DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if _save_resource_contained(theme, save_path) != OK:
		return _send_error(client_id, "Failed to save %s" % save_path, command_id)
	EditorInterface.get_resource_filesystem().update_file(save_path)
	var response := {"save_path": save_path, "dark": dark, "font_size": font_size, "applied_to": []}
	if bool(params.get("apply_to_project", true)):
		ProjectSettings.set_setting("gui/theme/custom", save_path)
		ProjectSettings.save()
		response["applied_to"].append("project (gui/theme/custom)")
	if params.has("node_path"):
		var control = _get_editor_node(str(params["node_path"]))
		if not control is Control:
			return _send_error(client_id, "Saved %s, but node_path is not a Control: %s" % [save_path, params["node_path"]], command_id)
		var transaction = _transaction("Apply UI Theme", "", {"command": "generate_ui_theme"})
		if not transaction:
			return _send_error(client_id, "Failed to obtain scene transaction", command_id)
		transaction.add_do_property(control, "theme", ResourceLoader.load(save_path))
		transaction.add_undo_property(control, "theme", control.theme)
		transaction.register_on_commit(func(): _mark_scene_modified())
		response["applied_to"].append(_to_mcp_path(control))
		return _finish_transaction(client_id, command_id, transaction, "", response)
	_send_success(client_id, response, command_id)
