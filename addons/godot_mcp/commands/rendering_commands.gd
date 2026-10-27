@tool
class_name MCPRenderingCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"

const LOG_FILENAME := "addons/godot_mcp/commands/rendering_commands.gd"
const DEFAULT_SYSTEM_SECTION := "rendering_commands"
const SHADER_PROBE_UNIFORM := "mcp_compile_probe"
# Godot 4 Environment has no fog_sun_color/fog_sun_amount; sun-scattered fog uses the fog light color/energy.
const SUN_PROPERTY_MAP := {
	"color": "fog_light_color",
	"amount": "fog_light_energy",
	"scatter": "fog_sun_scatter",
}

var SceneTransactionManager = preload("res://addons/godot_mcp/utils/scene_transaction_manager.gd")

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"generate_material_variant":
			_generate_material_variant(client_id, params, command_id)
			return true
		"compile_shader_preview":
			_compile_shader_preview(client_id, params, command_id)
			return true
		"unwrap_lightmap_uv2":
			_unwrap_lightmap_uv2(client_id, params, command_id)
			return true
		"optimize_mesh_lods":
			_optimize_mesh_lods(client_id, params, command_id)
			return true
		"configure_environment":
			_configure_environment(client_id, params, command_id)
			return true
		"preview_environment_sun_settings":
			_preview_environment_sun_settings(client_id, params, command_id)
			return true
		"generate_procedural_planet":
			_generate_procedural_planet(client_id, params, command_id)
			return true
		"generate_procedural_planet_ocean":
			_generate_procedural_planet_ocean(client_id, params, command_id)
			return true
		"create_planet_shell":
			_create_planet_shell(client_id, params, command_id)
			return true
		"create_ocean_tile":
			_create_ocean_tile(client_id, params, command_id)
			return true
		"apply_triplanar_terrain_material":
			_apply_triplanar_terrain_material(client_id, params, command_id)
			return true
		"generate_planet_cloud_layer":
			_generate_planet_cloud_layer(client_id, params, command_id)
			return true
		"create_planet_atmosphere_glow":
			_create_planet_atmosphere_glow(client_id, params, command_id)
			return true
		"scatter_craters_on_sphere":
			_scatter_craters_on_sphere(client_id, params, command_id)
			return true
		"create_ring_system":
			_create_ring_system(client_id, params, command_id)
			return true
		"generate_starfield_skybox":
			_generate_starfield_skybox(client_id, params, command_id)
			return true
		"create_moon_proxy":
			_create_moon_proxy(client_id, params, command_id)
			return true
		"planet_preset_quickstart":
			_planet_preset_quickstart(client_id, params, command_id)
			return true
	return false

func _log(message: String, function_name: String, context: Dictionary = {}, is_error: bool = false) -> void:
	var entry := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(),
		"classname": "MCPRenderingCommands",
		"function": function_name,
		"system_section": context.get("system_section", DEFAULT_SYSTEM_SECTION),
		"line_num": context.get("line_num", 0),
		"error": is_error,
		"db_phase": "none",
		"method": "NONE",
		"message": message,
	}

	if context.has("system_section"):
		context.erase("system_section")
	if context.has("line_num"):
		context.erase("line_num")
	if not context.is_empty():
		entry["context"] = context

	print(JSON.stringify(entry))

func _generate_material_variant(client_id: int, params: Dictionary, command_id: String) -> void:
	var source_path := params.get("source_material", "")
	var overrides := params.get("overrides", {})
	var shader_parameters := params.get("shader_parameters", {})
	var texture_overrides := params.get("texture_overrides", {})
	var save_path := params.get("save_path", "")
	var resource_name := params.get("resource_name", "")
	var metadata := params.get("metadata", {})

	if source_path.is_empty():
		_log("source_material is required", "_generate_material_variant", {"system_section": "material", "line_num": 0}, true)
		return _send_error(client_id, "source_material is required", command_id)

	var source_resource := ResourceUtils.safe_load(source_path)
	if source_resource == null or not (source_resource is Material):
		_log("Failed to load source material", "_generate_material_variant", {
			"system_section": "material",
			"line_num": 0,
			"source_material": source_path,
		}, true)
		return _send_error(client_id, "Unable to load material at %s" % source_path, command_id)

	var variant: Material = (source_resource as Material).duplicate(true)
	if resource_name != "":
		variant.resource_name = resource_name

	if typeof(metadata) == TYPE_DICTIONARY:
		for key in metadata.keys():
			variant.set_meta(key, metadata[key])

	var changes: Array = []

	if typeof(overrides) == TYPE_DICTIONARY:
		for property_name in overrides.keys():
			if _get_property_info(variant, property_name).is_empty():
				return _send_error(client_id, "%s has no property %s" % [variant.get_class(), property_name], command_id)
			# Coerce to the property's type: comparing a Color with a Dictionary errored (20s hang).
			var parsed_value = _convert_property_value(variant, property_name, overrides[property_name])
			var value_error := _property_value_error(variant, property_name, parsed_value)
			if not value_error.is_empty():
				return _send_error(client_id, value_error, command_id)
			var previous_value = variant.get(property_name)
			if typeof(previous_value) != typeof(parsed_value) or previous_value != parsed_value:
				variant.set(property_name, parsed_value)
				changes.append({
					"type": "property",
					"property": property_name,
					"previous": previous_value,
					"value": parsed_value,
				})

	if typeof(shader_parameters) == TYPE_DICTIONARY and not shader_parameters.is_empty():
		if not (variant is ShaderMaterial):
			return _send_error(client_id, "shader_parameters need a ShaderMaterial; %s has no shader uniforms (use overrides)" % variant.get_class(), command_id)
		var shader_material: ShaderMaterial = variant
		# Convert each value to its uniform's type: a raw dict/array for a color uniform was stored as null.
		var uniform_types := {}
		if shader_material.shader != null:
			for uniform in shader_material.shader.get_shader_uniform_list():
				uniform_types[str(uniform.get("name", ""))] = int(uniform.get("type", TYPE_NIL))
		for parameter_name in shader_parameters.keys():
			if not uniform_types.has(str(parameter_name)):
				return _send_error(client_id, "Shader has no uniform %s" % parameter_name, command_id)
			var expected_type: int = uniform_types[str(parameter_name)]
			var parsed: Variant = _coerce_value_to_type(shader_parameters[parameter_name], expected_type)
			var numeric := [TYPE_INT, TYPE_FLOAT]
			if expected_type != TYPE_NIL and typeof(parsed) != expected_type \
					and not (expected_type in numeric and typeof(parsed) in numeric) \
					and not (expected_type == TYPE_OBJECT and (parsed == null or parsed is Object)):
				return _send_error(client_id, "Shader uniform %s expects %s, got %s" % [parameter_name, type_string(expected_type), JSON.stringify(shader_parameters[parameter_name])], command_id)
			var previous = shader_material.get_shader_parameter(parameter_name)
			shader_material.set_shader_parameter(parameter_name, parsed)
			changes.append({
				"type": "shader_parameter",
				"parameter": parameter_name,
				"previous": previous,
				"value": parsed,
			})

	if typeof(texture_overrides) == TYPE_DICTIONARY:
		for slot in texture_overrides.keys():
			var value = texture_overrides[slot]
			var texture: Texture2D = null

			if typeof(value) == TYPE_OBJECT and value is Texture2D:
				texture = value
			elif typeof(value) == TYPE_STRING and value != "":
				var loaded = ResourceUtils.safe_load(value)
				if loaded is Texture2D:
					texture = loaded
			elif typeof(value) == TYPE_DICTIONARY:
				var dict_value: Dictionary = value
				if dict_value.has("path") and typeof(dict_value["path"]) == TYPE_STRING:
					var loaded_value = ResourceUtils.safe_load(dict_value["path"])
					if loaded_value is Texture2D:
						texture = loaded_value

			if texture == null:
				return _send_error(client_id, "texture_overrides.%s is not a loadable Texture2D: %s" % [slot, str(value)], command_id)
			# ShaderMaterial texture slots are sampler uniforms, not properties.
			if variant is ShaderMaterial and _get_property_info(variant, str(slot)).is_empty():
				var uniform_names: Array = []
				if variant.shader != null:
					uniform_names = variant.shader.get_shader_uniform_list().map(func(u): return str(u.get("name", "")))
				if not str(slot) in uniform_names:
					return _send_error(client_id, "Shader has no uniform %s" % slot, command_id)
				var previous_uniform = variant.get_shader_parameter(slot)
				variant.set_shader_parameter(slot, texture)
				changes.append({"type": "texture", "property": slot, "previous": previous_uniform, "value": texture.resource_path})
				continue
			if _get_property_info(variant, str(slot)).is_empty():
				return _send_error(client_id, "%s has no texture slot %s" % [variant.get_class(), slot], command_id)
			if variant.has_method("set"):
				var previous_texture = variant.get(slot)
				variant.set(slot, texture)
				changes.append({
					"type": "texture",
					"property": slot,
					"previous": previous_texture,
					"value": texture.resource_path,
				})

	var saved_path := ""
	var saved := false
	if save_path != "":
		if ResourceUtils.safe_save(variant, save_path):
			saved = true
			saved_path = save_path
		else:
			_log("Failed to save material variant", "_generate_material_variant", {
				"system_section": "material",
				"line_num": 0,
				"save_path": save_path,
			}, true)
			return _send_error(client_id, "Failed to save material variant to %s" % save_path, command_id)

	_log("Generated material variant", "_generate_material_variant", {
		"system_section": "material",
		"source_material": source_path,
		"changes": changes,
		"saved": saved,
		"save_path": saved_path,
	})

	_send_success(client_id, {
		"source_material": source_path,
		"resource_path": variant.resource_path,
		"resource_name": variant.resource_name,
		"saved": saved,
		"save_path": saved_path,
		"changes": changes,
	}, command_id)

func _compile_shader_preview(client_id: int, params: Dictionary, command_id: String) -> void:
	var shader_code := params.get("shader_code", "")
	var shader_path := params.get("shader_path", "")

	if shader_code == "" and shader_path == "":
		_log("shader_code or shader_path is required", "_compile_shader_preview", {"system_section": "shader", "line_num": 0}, true)
		return _send_error(client_id, "Provide shader_code or shader_path", command_id)
	if shader_code == "" and not ResourceLoader.exists(shader_path):
		return _send_error(client_id, "Shader file not found: %s" % shader_path, command_id)

	if shader_code == "":
		var loaded = ResourceLoader.load(shader_path)
		if not (loaded is Shader):
			return _send_error(client_id, "Resource at %s is not a Shader" % shader_path, command_id)
		shader_code = loaded.code

	# The renderer reports compile errors only in the output log (not to scripts or custom
	# Loggers) and then exposes no uniforms, so compile with an extra probe uniform:
	# if it is missing, compilation failed.
	var shader := Shader.new()
	shader.code = "%s\nuniform float %s;\n" % [shader_code, SHADER_PROBE_UNIFORM]
	var compiled := false
	for uniform_dict in shader.get_shader_uniform_list(true):
		if typeof(uniform_dict) == TYPE_DICTIONARY and uniform_dict.get("name", "") == SHADER_PROBE_UNIFORM:
			compiled = true
	if not compiled:
		return _send_error(client_id, "Shader compilation failed; see the Godot output log for the error line", command_id)

	var uniform_list := []
	for uniform_dict in shader.get_shader_uniform_list(true):
		if typeof(uniform_dict) == TYPE_DICTIONARY and uniform_dict.get("name", "") != SHADER_PROBE_UNIFORM:
			uniform_list.append(uniform_dict.duplicate(true))

	var default_textures := []
	for uniform_dict in uniform_list:
		var name = uniform_dict.get("name", "")
		if name != "":
			var texture: Texture = shader.get_default_texture_parameter(name)
			if texture != null:
				default_textures.append({
					"name": name,
					"type": texture.get_class(),
					"resource_path": texture.resource_path,
				})

	var info := {
		"shader_mode": shader.get_mode(),
		"uniforms": uniform_list,
		"default_textures": default_textures,
		"code_preview": shader_code,
	}

	_log("Compiled shader preview", "_compile_shader_preview", {
		"system_section": "shader",
		"uniform_count": uniform_list.size(),
	})

	_send_success(client_id, info, command_id)

func _unwrap_lightmap_uv2(client_id: int, params: Dictionary, command_id: String) -> void:
	var mesh_path := params.get("mesh_path", "")
	var node_path := params.get("node_path", "")
	var texel_size := float(params.get("texel_size", 0.2))
	var transform := Transform3D.IDENTITY
	var mesh: Mesh = null
	var node: Node = null

	if mesh_path != "":
		var loaded = ResourceUtils.safe_load(mesh_path)
		if loaded is Mesh:
			mesh = loaded
		else:
			_log("Resource at path is not a Mesh", "_unwrap_lightmap_uv2", {
				"system_section": "uv2",
				"line_num": 0,
				"mesh_path": mesh_path,
			}, true)
			return _send_error(client_id, "Resource at %s is not a Mesh" % mesh_path, command_id)
	elif node_path != "":
		node = _get_editor_node(node_path)
		if node == null:
			return _send_error(client_id, "Node not found: %s" % node_path, command_id)
		if node is MeshInstance3D:
			mesh = (node as MeshInstance3D).mesh
			transform = (node as MeshInstance3D).global_transform
		else:
			_log("Node is not a MeshInstance3D", "_unwrap_lightmap_uv2", {
				"system_section": "uv2",
				"line_num": 0,
				"node_path": node_path,
			}, true)
			return _send_error(client_id, "Node at %s is not a MeshInstance3D" % node_path, command_id)
	else:
		_log("mesh_path or node_path required", "_unwrap_lightmap_uv2", {"system_section": "uv2", "line_num": 0}, true)
		return _send_error(client_id, "Provide mesh_path or node_path", command_id)

	if mesh == null:
		return _send_error(client_id, "Mesh could not be resolved", command_id)

	var array_mesh := _to_array_mesh(mesh)

	var unwrap_result = array_mesh.lightmap_unwrap(transform, texel_size)
	if unwrap_result != OK:
		_log("ArrayMesh.lightmap_unwrap failed", "_unwrap_lightmap_uv2", {
			"system_section": "uv2",
			"line_num": 0,
			"error_code": unwrap_result,
		}, true)
		return _send_error(client_id, "Failed to unwrap UV2 for mesh", command_id)

	if node is MeshInstance3D:
		var transaction = SceneTransactionManager.begin_inline("Apply Lightmap UV2", {
			"command": "unwrap_lightmap_uv2",
			"node_path": node_path,
			"client_id": client_id,
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for UV2 unwrap", command_id)
		transaction.add_do_property(node, "mesh", array_mesh)
		transaction.add_undo_property(node, "mesh", mesh)
		transaction.register_on_commit(func():
			_mark_scene_modified()
			_log("Applied lightmap UV2 to node", "_unwrap_lightmap_uv2", {
				"system_section": "uv2",
				"node_path": node_path,
				"texel_size": texel_size,
			})
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit UV2 unwrap transaction", command_id)

	var save_path := params.get("save_path", "")
	var saved := false
	if save_path != "":
		if ResourceUtils.safe_save(array_mesh, save_path):
			saved = true
		else:
			_log("Failed to save ArrayMesh", "_unwrap_lightmap_uv2", {
				"system_section": "uv2",
				"line_num": 0,
				"save_path": save_path,
			}, true)
			return _send_error(client_id, "Failed to save mesh to %s" % save_path, command_id)

	_send_success(client_id, {
		"surface_count": array_mesh.get_surface_count(),
		"texel_size": texel_size,
		"saved": saved,
		"save_path": save_path,
	}, command_id)

func _optimize_mesh_lods(client_id: int, params: Dictionary, command_id: String) -> void:
	var mesh_path := params.get("mesh_path", "")
	var node_path := params.get("node_path", "")
	var lod_targets := params.get("lods", [])
	var mesh: Mesh = null
	var node: MeshInstance3D = null

	if mesh_path != "":
		var loaded = ResourceUtils.safe_load(mesh_path)
		if loaded is Mesh:
			mesh = loaded
		else:
			return _send_error(client_id, "Resource at %s is not a Mesh" % mesh_path, command_id)
	elif node_path != "":
		var resolved = _get_editor_node(node_path)
		if resolved is MeshInstance3D:
			node = resolved
			mesh = node.mesh
		else:
			return _send_error(client_id, "Node at %s is not a MeshInstance3D" % node_path, command_id)
	else:
		return _send_error(client_id, "Provide mesh_path or node_path", command_id)

	if mesh == null:
		return _send_error(client_id, "Mesh could not be resolved", command_id)

	var ratios: Array = []
	if typeof(lod_targets) == TYPE_ARRAY:
		ratios = lod_targets.duplicate()
	if ratios.is_empty():
		ratios = [0.5, 0.25]

	var lod_results: Array = []
	var lod_resources: Array = []

	for ratio_value in ratios:
		var ratio = clamp(float(ratio_value), 0.0, 1.0)
		if ratio <= 0.0:
			continue
		var lod_mesh := _generate_lod_mesh(mesh, ratio)
		lod_resources.append(lod_mesh)
		lod_results.append({
			"ratio": ratio,
			"surface_count": lod_mesh.get_surface_count(),
		})

	var save_targets := params.get("save_paths", [])
	if typeof(save_targets) == TYPE_ARRAY:
		for i in range(min(save_targets.size(), lod_resources.size())):
			var target_path = save_targets[i]
			if typeof(target_path) == TYPE_STRING and target_path != "":
				ResourceUtils.safe_save(lod_resources[i], target_path)
				lod_results[i]["save_path"] = target_path

	if node != null and not lod_resources.is_empty():
		var transaction = SceneTransactionManager.begin_inline("Assign Mesh LODs", {
			"command": "optimize_mesh_lods",
			"node_path": node_path,
			"client_id": client_id,
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for LOD assignment", command_id)
		transaction.add_do_property(node, "mesh", lod_resources[0])
		transaction.add_undo_property(node, "mesh", mesh)
		transaction.register_on_commit(func():
			_mark_scene_modified()
			_log("Assigned optimized LOD mesh", "_optimize_mesh_lods", {
				"system_section": "lods",
				"node_path": node_path,
			})
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit LOD assignment", command_id)

	_send_success(client_id, {
		"mesh_path": mesh_path,
		"node_path": node_path,
		"lods": lod_results,
	}, command_id)

# Only ArrayMesh has surface_get_primitive_type; PrimitiveMesh (BoxMesh, ...) surfaces are triangle lists.
func _to_array_mesh(mesh: Mesh) -> ArrayMesh:
	if mesh is ArrayMesh:
		return mesh
	var array_mesh := ArrayMesh.new()
	for surface_index in mesh.get_surface_count():
		array_mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			mesh.surface_get_arrays(surface_index),
			mesh.surface_get_blend_shape_arrays(surface_index)
		)
		array_mesh.surface_set_material(surface_index, mesh.surface_get_material(surface_index))
	return array_mesh

func _generate_lod_mesh(source_mesh: Mesh, ratio: float) -> ArrayMesh:
	var mesh := _to_array_mesh(source_mesh)
	var result := ArrayMesh.new()
	for surface_index in mesh.get_surface_count():
		var arrays: Array = mesh.surface_get_arrays(surface_index)
		if arrays.is_empty():
			continue
		var primitive = mesh.surface_get_primitive_type(surface_index)
		var new_arrays := _decimate_surface_arrays(arrays, ratio)
		result.add_surface_from_arrays(primitive, new_arrays, mesh.surface_get_blend_shape_arrays(surface_index))
	return result

# Channels a mesh does not use (colors, bones, ...) are null in surface arrays.
func _surface_channel(arrays: Array, index: int, empty):
	return arrays[index] if arrays[index] != null else empty

func _decimate_surface_arrays(arrays: Array, ratio: float) -> Array:
	var new_arrays := arrays.duplicate(true)
	var vertices: PackedVector3Array = _surface_channel(new_arrays, Mesh.ARRAY_VERTEX, PackedVector3Array())
	var normals: PackedVector3Array = _surface_channel(new_arrays, Mesh.ARRAY_NORMAL, PackedVector3Array())
	var tangents: PackedFloat32Array = _surface_channel(new_arrays, Mesh.ARRAY_TANGENT, PackedFloat32Array())
	var colors: PackedColorArray = _surface_channel(new_arrays, Mesh.ARRAY_COLOR, PackedColorArray())
	var uv: PackedVector2Array = _surface_channel(new_arrays, Mesh.ARRAY_TEX_UV, PackedVector2Array())
	var uv2: PackedVector2Array = _surface_channel(new_arrays, Mesh.ARRAY_TEX_UV2, PackedVector2Array())
	var bones: PackedInt32Array = _surface_channel(new_arrays, Mesh.ARRAY_BONES, PackedInt32Array())
	var weights: PackedFloat32Array = _surface_channel(new_arrays, Mesh.ARRAY_WEIGHTS, PackedFloat32Array())
	var indices: PackedInt32Array = _surface_channel(new_arrays, Mesh.ARRAY_INDEX, PackedInt32Array())

	if not indices.is_empty():
		var triangle_count := indices.size() / 3
		var keep_triangles := max(1, int(round(float(triangle_count) * ratio)))
		keep_triangles = min(triangle_count, keep_triangles)
		var new_indices := PackedInt32Array()
		new_indices.resize(keep_triangles * 3)
		for i in range(new_indices.size()):
			new_indices[i] = indices[i]
		new_arrays[Mesh.ARRAY_INDEX] = new_indices
	else:
		var vertex_count := vertices.size()
		var keep_vertices := max(3, int(round(float(vertex_count) * ratio)))
		keep_vertices = min(vertex_count, keep_vertices)
		new_arrays[Mesh.ARRAY_VERTEX] = _slice_vector3_array(vertices, keep_vertices)
		if normals.size() == vertex_count:
			new_arrays[Mesh.ARRAY_NORMAL] = _slice_vector3_array(normals, keep_vertices)
		if tangents.size() == vertex_count * 4:
			new_arrays[Mesh.ARRAY_TANGENT] = _slice_float32_array(tangents, keep_vertices * 4)
		if colors.size() == vertex_count:
			new_arrays[Mesh.ARRAY_COLOR] = _slice_color_array(colors, keep_vertices)
		if uv.size() == vertex_count:
			new_arrays[Mesh.ARRAY_TEX_UV] = _slice_vector2_array(uv, keep_vertices)
		if uv2.size() == vertex_count:
			new_arrays[Mesh.ARRAY_TEX_UV2] = _slice_vector2_array(uv2, keep_vertices)
		if bones.size() == vertex_count * 4:
			new_arrays[Mesh.ARRAY_BONES] = _slice_int32_array(bones, keep_vertices * 4)
		if weights.size() == vertex_count * 4:
			new_arrays[Mesh.ARRAY_WEIGHTS] = _slice_float32_array(weights, keep_vertices * 4)

	return new_arrays

func _slice_vector3_array(array: PackedVector3Array, count: int) -> PackedVector3Array:
	var result := PackedVector3Array()
	count = min(count, array.size())
	for i in range(count):
		result.push_back(array[i])
	return result

func _slice_vector2_array(array: PackedVector2Array, count: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	count = min(count, array.size())
	for i in range(count):
		result.push_back(array[i])
	return result

func _slice_float32_array(array: PackedFloat32Array, count: int) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	count = min(count, array.size())
	result.resize(count)
	for i in range(count):
		result[i] = array[i]
	return result

func _slice_int32_array(array: PackedInt32Array, count: int) -> PackedInt32Array:
	var result := PackedInt32Array()
	count = min(count, array.size())
	result.resize(count)
	for i in range(count):
		result[i] = array[i]
	return result

func _slice_color_array(array: PackedColorArray, count: int) -> PackedColorArray:
	var result := PackedColorArray()
	count = min(count, array.size())
	for i in range(count):
		result.push_back(array[i])
	return result

func _generate_procedural_planet(client_id: int, params: Dictionary, command_id: String) -> void:
	var width := max(64, int(params.get("texture_width", 1024)))
	var height := max(32, int(params.get("texture_height", 512)))
	var radius := max(0.1, float(params.get("radius", 1.0)))
	var radial_segments := clampi(int(params.get("radial_segments", 96)), 8, 512)
	var rings := clampi(int(params.get("rings", 64)), 8, 256)
	var seed := int(params.get("seed", randi()))
	var base_frequency := max(0.0001, float(params.get("base_frequency", 2.2)))
	var octaves := clampi(int(params.get("octaves", 6)), 1, 12)
	var lacunarity := max(1.0, float(params.get("lacunarity", 2.0)))
	var persistence := clampf(float(params.get("persistence", 0.5)), 0.05, 1.0)
	var sea_level := clampf(float(params.get("sea_level", 0.0)), -0.95, 0.95)
	var roughness := clampf(float(params.get("roughness", 0.95)), 0.0, 1.0)
	var metallic := clampf(float(params.get("metallic", 0.0)), 0.0, 1.0)
	var specular_intensity := clampf(float(params.get("specular_intensity", 0.8)), 0.0, 1.0)
	var normal_strength := max(0.0, float(params.get("normal_strength", 5.0)))
	var create_node := params.get("create_node", true)
	var parent_path := params.get("parent_path", "/root")
	var node_name := params.get("node_name", "ProceduralPlanet")

	# Check the parent and name before anything is written to disk; failing later left saved
	# textures behind.
	if create_node:
		var early_parent := _get_editor_node(parent_path)
		if early_parent == null:
			return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
		var early_name_error := _sibling_name_error(early_parent, node_name)
		if not early_name_error.is_empty():
			return _send_error(client_id, early_name_error, command_id)

	var elevation_noise := FastNoiseLite.new()
	elevation_noise.seed = seed
	elevation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	elevation_noise.fractal_type = FastNoiseLite.FRACTAL_NONE

	var humidity_noise := FastNoiseLite.new()
	humidity_noise.seed = seed + 7919
	humidity_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	humidity_noise.fractal_type = FastNoiseLite.FRACTAL_NONE

	var albedo_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var height_image := Image.create(width, height, false, Image.FORMAT_RF)
	var specular_image := Image.create(width, height, false, Image.FORMAT_L8)
	var roughness_image := Image.create(width, height, false, Image.FORMAT_L8)

	var height_values := PackedFloat32Array()
	height_values.resize(width * height)
	var humidity_values := PackedFloat32Array()
	humidity_values.resize(width * height)
	var min_elevation := 1000.0
	var max_elevation := -1000.0

	# Pass 1 samples the noise. Fractal noise only spans about -0.2..0.2, so a sea_level outside that
	# gave all land or all ocean and mountains never appeared; pass 2 stretches it to -1..1.
	for y in range(height):
		var v := float(y) / float(height - 1)
		var latitude := (v - 0.5) * PI
		var sin_lat := sin(latitude)
		var cos_lat := cos(latitude)
		for x in range(width):
			var u := float(x) / float(width - 1)
			var longitude := u * TAU
			var sphere_point := Vector3(
				cos_lat * cos(longitude),
				sin_lat,
				cos_lat * sin(longitude)
			)

			var elevation_raw := _fractal_noise_sample(
				elevation_noise,
				sphere_point,
				base_frequency,
				octaves,
				lacunarity,
				persistence
			)
			var humidity_raw := _fractal_noise_sample(
				humidity_noise,
				sphere_point * 1.37,
				base_frequency * 0.7,
				octaves,
				lacunarity,
				persistence
			)
			height_values[y * width + x] = elevation_raw
			humidity_values[y * width + x] = clampf((humidity_raw + 1.0) * 0.5, 0.0, 1.0)
			min_elevation = min(min_elevation, elevation_raw)
			max_elevation = max(max_elevation, elevation_raw)

	var elevation_span: float = max(max_elevation - min_elevation, 0.0001)
	for y in range(height):
		for x in range(width):
			var index: int = y * width + x
			var elevation := (height_values[index] - min_elevation) / elevation_span * 2.0 - 1.0
			height_values[index] = elevation
			var color := _planet_biome_color(elevation, humidity_values[index], sea_level)
			var water_factor := 1.0 - smoothstep(sea_level - 0.08, sea_level + 0.02, elevation)
			var specular_value := water_factor * specular_intensity
			# Godot 4 has no specular map: shiny water is low roughness.
			var roughness_value := lerpf(roughness, 0.08, specular_value)
			albedo_image.set_pixel(x, y, color)
			height_image.set_pixel(x, y, Color((elevation + 1.0) * 0.5, 0.0, 0.0, 1.0))
			specular_image.set_pixel(x, y, Color(specular_value, specular_value, specular_value, 1.0))
			roughness_image.set_pixel(x, y, Color(roughness_value, roughness_value, roughness_value, 1.0))
	min_elevation = -1.0
	max_elevation = 1.0

	var normal_image := _build_planet_normal_map(height_values, width, height, normal_strength)

	var albedo_texture := ImageTexture.create_from_image(albedo_image)
	var normal_texture := ImageTexture.create_from_image(normal_image)
	var height_texture := ImageTexture.create_from_image(height_image)
	var specular_texture := ImageTexture.create_from_image(specular_image)
	var roughness_texture := ImageTexture.create_from_image(roughness_image)

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere_mesh.radial_segments = radial_segments
	sphere_mesh.rings = rings

	var material := StandardMaterial3D.new()
	material.resource_name = "%sMaterial" % node_name
	material.albedo_texture = albedo_texture
	material.normal_enabled = true
	material.normal_texture = normal_texture
	material.heightmap_enabled = true
	material.heightmap_texture = height_texture
	material.roughness_texture = roughness_texture
	material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	material.roughness = 1.0
	material.metallic = metallic

	var mesh_save_path := str(params.get("save_mesh_path", ""))
	var material_save_path := str(params.get("save_material_path", ""))
	var albedo_save_path := str(params.get("save_albedo_path", ""))
	var height_save_path := str(params.get("save_height_path", ""))
	var normal_save_path := str(params.get("save_normal_path", ""))
	var specular_save_path := str(params.get("save_specular_path", ""))
	var roughness_save_path := specular_save_path.get_basename() + "_roughness.png" if specular_save_path != "" else ""
	# Textures that end up in a saved file (the scene, or the saved material) were embedded as
	# megabytes of pixels; save every missing one as a PNG next to the material, or under
	# res://generated/<node_name in snake_case>/, and reference it.
	if create_node or material_save_path != "":
		var folder := material_save_path.get_basename() + "_textures" if material_save_path != "" else "res://generated/%s" % str(node_name).to_snake_case()
		albedo_save_path = albedo_save_path if albedo_save_path != "" else folder + "/albedo.png"
		height_save_path = height_save_path if height_save_path != "" else folder + "/height.png"
		normal_save_path = normal_save_path if normal_save_path != "" else folder + "/normal.png"
		roughness_save_path = roughness_save_path if roughness_save_path != "" else folder + "/roughness.png"

	if mesh_save_path != "" and not ResourceUtils.safe_save(sphere_mesh, mesh_save_path):
		return _send_error(client_id, "Failed to save planet mesh to %s" % mesh_save_path, command_id)
	if albedo_save_path != "" and not _save_image_or_texture(albedo_image, albedo_texture, albedo_save_path):
		return _send_error(client_id, "Failed to save albedo texture to %s" % albedo_save_path, command_id)
	if height_save_path != "" and not _save_image_or_texture(height_image, height_texture, height_save_path):
		return _send_error(client_id, "Failed to save height texture to %s" % height_save_path, command_id)
	if normal_save_path != "" and not _save_image_or_texture(normal_image, normal_texture, normal_save_path):
		return _send_error(client_id, "Failed to save normal texture to %s" % normal_save_path, command_id)
	if specular_save_path != "" and not _save_image_or_texture(specular_image, specular_texture, specular_save_path):
		return _send_error(client_id, "Failed to save specular texture to %s" % specular_save_path, command_id)
	if roughness_save_path != "" and not _save_image_or_texture(roughness_image, roughness_texture, roughness_save_path):
		return _send_error(client_id, "Failed to save roughness texture to %s" % roughness_save_path, command_id)

	# Reference the saved files instead of embedding pixels (an embedded 1.6 MB material, orphaned PNGs).
	var reloaded: Dictionary = await _reload_saved_textures([albedo_save_path, height_save_path, normal_save_path, roughness_save_path])
	for entry in [[albedo_save_path, "albedo_texture"], [height_save_path, "heightmap_texture"],
			[normal_save_path, "normal_texture"], [roughness_save_path, "roughness_texture"]]:
		var saved_texture = reloaded.get(_contained_res_path(entry[0]) if entry[0] != "" else "")
		if saved_texture != null:
			material.set(entry[1], saved_texture)
	if material_save_path != "" and not ResourceUtils.safe_save(material, material_save_path):
		return _send_error(client_id, "Failed to save planet material to %s" % material_save_path, command_id)

	var created_node_path := ""
	if create_node:
		var parent := _get_editor_node(parent_path)
		if parent == null:
			return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var planet_node := MeshInstance3D.new()
		planet_node.name = node_name
		planet_node.mesh = sphere_mesh
		planet_node.material_override = material

		var plugin = Engine.get_meta("GodotMCPPlugin")
		var edited_scene_root = null
		if plugin and plugin.has_method("get_editor_interface"):
			var editor_interface = plugin.get_editor_interface()
			edited_scene_root = editor_interface.get_edited_scene_root()

		var transaction = SceneTransactionManager.begin_inline("Generate Procedural Planet", {
			"command": "generate_procedural_planet",
			"parent_path": parent_path,
			"client_id": client_id,
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for planet node creation", command_id)
		transaction.add_do_method(parent, "add_child", [planet_node])
		if edited_scene_root != null:
			transaction.add_do_method(planet_node, "set_owner", [edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [planet_node])
		transaction.add_undo_method(planet_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit planet node creation", command_id)

		created_node_path = _to_mcp_path(planet_node)

	_log("Generated procedural planet", "_generate_procedural_planet", {
		"system_section": "planet",
		"seed": seed,
		"width": width,
		"height": height,
		"octaves": octaves,
		"sea_level": sea_level,
		"created_node_path": created_node_path,
		"saved_mesh": mesh_save_path,
		"saved_material": material_save_path,
	})

	_send_success(client_id, {
		"seed": seed,
		"resolution": {"width": width, "height": height},
		"radius": radius,
		"noise": {
			"base_frequency": base_frequency,
			"octaves": octaves,
			"lacunarity": lacunarity,
			"persistence": persistence,
		},
		"sea_level": sea_level,
		"elevation_range": {"min": min_elevation, "max": max_elevation},
		"created_node_path": created_node_path,
		"saved_paths": {
			"mesh": mesh_save_path,
			"material": material_save_path,
			"albedo": albedo_save_path,
			"height": height_save_path,
			"normal": normal_save_path,
			"specular": specular_save_path,
		},
	}, command_id)

func _generate_procedural_planet_ocean(client_id: int, params: Dictionary, command_id: String) -> void:
	var mesh_mode := str(params.get("mesh_mode", "planet_shell"))
	var ocean_radius := max(0.1, float(params.get("ocean_radius", 1.03)))
	var radial_segments := clampi(int(params.get("radial_segments", 128)), 8, 512)
	var rings := clampi(int(params.get("rings", 96)), 8, 256)
	var tile_size := max(0.1, float(params.get("tile_size", 2.0)))
	var tile_subdivide_width := clampi(int(params.get("tile_subdivide_width", 24)), 1, 256)
	var tile_subdivide_depth := clampi(int(params.get("tile_subdivide_depth", 24)), 1, 256)
	var wave_scale := max(0.01, float(params.get("wave_scale", 3.0)))
	var wave_speed := max(0.0, float(params.get("wave_speed", 0.35)))
	var wave_height := max(0.0, float(params.get("wave_height", 0.018)))
	var foam_strength := clampf(float(params.get("foam_strength", 0.5)), 0.0, 2.0)
	var fresnel_power := max(0.1, float(params.get("fresnel_power", 5.0)))
	var depth_absorption := max(0.01, float(params.get("depth_absorption", 2.5)))
	var roughness := clampf(float(params.get("roughness", 0.08)), 0.0, 1.0)
	var metallic := clampf(float(params.get("metallic", 0.02)), 0.0, 1.0)
	var alpha := clampf(float(params.get("alpha", 0.7)), 0.0, 1.0)
	var seed := float(params.get("seed", 31.0))
	var create_node := params.get("create_node", true)
	var node_name := str(params.get("node_name", "PlanetOcean"))
	var planet_node_path := str(params.get("planet_node_path", ""))
	var requested_parent_path := str(params.get("parent_path", ""))

	var deep_color = _coerce_to_color(params.get("deep_color", {"r": 0.01, "g": 0.07, "b": 0.18, "a": 1.0}))
	if not (deep_color is Color):
		return _send_error(client_id, "deep_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var shallow_color = _coerce_to_color(params.get("shallow_color", {"r": 0.07, "g": 0.36, "b": 0.62, "a": 1.0}))
	if not (shallow_color is Color):
		return _send_error(client_id, "shallow_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var foam_color = _coerce_to_color(params.get("foam_color", {"r": 0.88, "g": 0.95, "b": 0.99, "a": 1.0}))
	if not (foam_color is Color):
		return _send_error(client_id, "foam_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)

	var shader_code := """
shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.01, 0.07, 0.18, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.07, 0.36, 0.62, 1.0);
uniform vec4 foam_color : source_color = vec4(0.88, 0.95, 0.99, 1.0);
uniform float wave_scale = 3.0;
uniform float wave_speed = 0.35;
uniform float wave_height = 0.018;
uniform float foam_strength = 0.5;
uniform float fresnel_power = 5.0;
uniform float depth_absorption = 2.5;
uniform float alpha = 0.7;
uniform float seed = 31.0;
uniform float metallic = 0.02;
uniform float roughness = 0.08;
uniform float spherical_mapping = 1.0;

float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash31(i + vec3(0.0, 0.0, 0.0));
	float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash31(i + vec3(1.0, 1.0, 1.0));
	float nx00 = mix(n000, n100, f.x);
	float nx10 = mix(n010, n110, f.x);
	float nx01 = mix(n001, n101, f.x);
	float nx11 = mix(n011, n111, f.x);
	float nxy0 = mix(nx00, nx10, f.y);
	float nxy1 = mix(nx01, nx11, f.y);
	return mix(nxy0, nxy1, f.z);
}

float fbm(vec3 p) {
	float v = 0.0;
	float a = 0.5;
	float f = 1.0;
	for (int i = 0; i < 5; i++) {
		v += (noise3(p * f) * 2.0 - 1.0) * a;
		f *= 2.02;
		a *= 0.5;
	}
	return v;
}

varying float v_wave;
varying float v_fresnel;

void vertex() {
	vec3 sample_dir = normalize(VERTEX);
	if (spherical_mapping < 0.5) {
		sample_dir = normalize(vec3(VERTEX.x, 0.0, VERTEX.z) + vec3(0.001, 1.0, 0.001));
	}
	float t = TIME * wave_speed;
	float w = fbm(sample_dir * wave_scale + vec3(t, t * 0.37, seed * 0.01));
	float w2 = fbm(sample_dir * wave_scale * 2.3 + vec3(-t * 0.5, t * 0.83, seed * 0.02));
	float wave = w * 0.7 + w2 * 0.3;
	VERTEX += NORMAL * (wave * wave_height);
	v_wave = wave;
}

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float facing = max(dot(n, v), 0.0);
	float fresnel = pow(1.0 - facing, fresnel_power);
	v_fresnel = fresnel;

	float depth_mix = clamp(facing * depth_absorption, 0.0, 1.0);
	vec3 base = mix(deep_color.rgb, shallow_color.rgb, depth_mix);

	float foam = smoothstep(0.35, 0.95, v_wave) * foam_strength;
	vec3 color = mix(base, foam_color.rgb, clamp(foam + fresnel * 0.25, 0.0, 1.0));

	ALBEDO = color;
	ALPHA = alpha;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = 0.9;
	EMISSION = color * fresnel * 0.08;
}
"""

	var shader := Shader.new()
	shader.code = shader_code

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("deep_color", deep_color)
	material.set_shader_parameter("shallow_color", shallow_color)
	material.set_shader_parameter("foam_color", foam_color)
	material.set_shader_parameter("wave_scale", wave_scale)
	material.set_shader_parameter("wave_speed", wave_speed)
	material.set_shader_parameter("wave_height", wave_height)
	material.set_shader_parameter("foam_strength", foam_strength)
	material.set_shader_parameter("fresnel_power", fresnel_power)
	material.set_shader_parameter("depth_absorption", depth_absorption)
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("seed", seed)
	material.set_shader_parameter("metallic", metallic)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("spherical_mapping", (1.0 if mesh_mode == "planet_shell" else 0.0))

	var save_shader_path := str(params.get("save_shader_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))
	if save_shader_path != "":
		if not ResourceUtils.safe_save(shader, save_shader_path):
			return _send_error(client_id, "Failed to save ocean shader to %s" % save_shader_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save ocean material to %s" % save_material_path, command_id)

	var created_node_path := ""
	if create_node:
		var planet_node: Node = null
		if planet_node_path != "":
			planet_node = _get_editor_node(planet_node_path)
			if planet_node == null:
				return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

		var parent: Node = null
		if requested_parent_path != "":
			parent = _get_editor_node(requested_parent_path)
		elif planet_node != null:
			parent = planet_node.get_parent()
		else:
			parent = _get_editor_node("/root")
		if parent == null:
			return _send_error(client_id, "Parent node not found", command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var ocean_mesh: Mesh = null
		if mesh_mode == "single_tile":
			var plane_mesh := PlaneMesh.new()
			plane_mesh.size = Vector2(tile_size, tile_size)
			plane_mesh.subdivide_width = tile_subdivide_width
			plane_mesh.subdivide_depth = tile_subdivide_depth
			ocean_mesh = plane_mesh
		else:
			var sphere_mesh := SphereMesh.new()
			sphere_mesh.radius = ocean_radius
			sphere_mesh.height = ocean_radius * 2.0
			sphere_mesh.radial_segments = radial_segments
			sphere_mesh.rings = rings
			ocean_mesh = sphere_mesh

		var ocean_node := MeshInstance3D.new()
		ocean_node.name = node_name
		ocean_node.mesh = ocean_mesh
		ocean_node.material_override = material
		if planet_node != null and ocean_node is Node3D and planet_node is Node3D:
			ocean_node.transform = _local_transform_matching(planet_node, parent)

		var plugin = Engine.get_meta("GodotMCPPlugin")
		var edited_scene_root = null
		if plugin and plugin.has_method("get_editor_interface"):
			var editor_interface = plugin.get_editor_interface()
			edited_scene_root = editor_interface.get_edited_scene_root()

		var transaction = SceneTransactionManager.begin_inline("Generate Planet Ocean", {
			"command": "generate_procedural_planet_ocean",
			"planet_node_path": planet_node_path,
			"parent_path": _to_mcp_path(parent),
			"client_id": client_id,
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for ocean node creation", command_id)
		transaction.add_do_method(parent, "add_child", [ocean_node])
		if edited_scene_root != null:
			transaction.add_do_method(ocean_node, "set_owner", [edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [ocean_node])
		transaction.add_undo_method(ocean_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit ocean node creation", command_id)

		created_node_path = _to_mcp_path(ocean_node)

	_log("Generated procedural planet ocean", "_generate_procedural_planet_ocean", {
		"system_section": "ocean",
		"node_path": created_node_path,
		"mesh_mode": mesh_mode,
		"ocean_radius": ocean_radius,
		"wave_scale": wave_scale,
		"wave_speed": wave_speed,
	})

	_send_success(client_id, {
		"created_node_path": created_node_path,
		"planet_node_path": planet_node_path,
		"mesh_mode": mesh_mode,
		"ocean_radius": ocean_radius,
		"tile_size": tile_size,
		"shader_parameters": {
			"wave_scale": wave_scale,
			"wave_speed": wave_speed,
			"wave_height": wave_height,
			"foam_strength": foam_strength,
			"fresnel_power": fresnel_power,
			"depth_absorption": depth_absorption,
			"alpha": alpha,
			"seed": seed,
		},
		"saved_paths": {
			"shader": save_shader_path,
			"material": save_material_path,
		},
	}, command_id)

# add_child would silently rename a colliding node to @Class@N; refuse instead.
func _sibling_name_error(parent: Node, child_name: String) -> String:
	if parent != null and parent.has_node(NodePath(child_name)):
		return "A node named '%s' already exists under %s; choose another node_name" % [child_name, _to_mcp_path(parent)]
	return ""

func _get_edited_scene_root_node() -> Node:
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if plugin and plugin.has_method("get_editor_interface"):
		var editor_interface = plugin.get_editor_interface()
		if editor_interface:
			return editor_interface.get_edited_scene_root()
	return null

func _assign_owner_recursive(node: Node, owner: Node) -> void:
	if node == null or owner == null:
		return
	node.owner = owner
	for child in node.get_children():
		if child is Node:
			_assign_owner_recursive(child, owner)

func _random_unit_vector(rng: RandomNumberGenerator) -> Vector3:
	var z := rng.randf_range(-1.0, 1.0)
	var a := rng.randf_range(0.0, TAU)
	var r := sqrt(max(0.0, 1.0 - z * z))
	return Vector3(r * cos(a), z, r * sin(a)).normalized()

func _basis_from_y_axis(direction: Vector3) -> Basis:
	var y := direction.normalized()
	var x := Vector3.UP.cross(y)
	if x.length_squared() < 0.000001:
		x = Vector3.RIGHT.cross(y)
	x = x.normalized()
	var z := y.cross(x).normalized()
	return Basis(x, y, z)

func _create_solid_texture(color: Color, size: int = 4) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func _build_atmosphere_shader_material(glow_color: Color, fresnel_power: float, intensity: float, alpha: float) -> ShaderMaterial:
	var shader_code := """
shader_type spatial;
render_mode blend_add, cull_front, unshaded, depth_draw_opaque;

uniform vec4 glow_color : source_color = vec4(0.35, 0.62, 1.0, 1.0);
uniform float fresnel_power = 4.0;
uniform float intensity = 1.2;
uniform float alpha = 0.45;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float fresnel = pow(1.0 - max(dot(n, v), 0.0), fresnel_power);
	vec3 c = glow_color.rgb * fresnel * intensity;
	ALBEDO = c;
	EMISSION = c;
	ALPHA = clamp(fresnel * alpha, 0.0, 1.0);
}
"""
	var shader := Shader.new()
	shader.code = shader_code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("glow_color", glow_color)
	material.set_shader_parameter("fresnel_power", fresnel_power)
	material.set_shader_parameter("intensity", intensity)
	material.set_shader_parameter("alpha", alpha)
	return material

func _create_planet_shell(client_id: int, params: Dictionary, command_id: String) -> void:
	var radius := max(0.1, float(params.get("radius", 1.0)))
	var radial_segments := clampi(int(params.get("radial_segments", 64)), 8, 512)
	var rings := clampi(int(params.get("rings", 48)), 8, 256)
	var roughness := clampf(float(params.get("roughness", 0.9)), 0.0, 1.0)
	var metallic := clampf(float(params.get("metallic", 0.0)), 0.0, 1.0)
	var color = _coerce_to_color(params.get("color", {"r": 0.35, "g": 0.38, "b": 0.43, "a": 1.0}))
	if not (color is Color):
		return _send_error(client_id, "color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var node_name := str(params.get("node_name", "PlanetShell"))
	var parent_path := str(params.get("parent_path", "/root"))
	var create_node := params.get("create_node", true)
	var save_mesh_path := str(params.get("save_mesh_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))

	# Check the parent and name before saving files; a bad parent left saved mesh/material behind.
	if create_node:
		var early_parent := _get_editor_node(parent_path)
		if early_parent == null:
			return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
		var early_name_error := _sibling_name_error(early_parent, node_name)
		if not early_name_error.is_empty():
			return _send_error(client_id, early_name_error, command_id)

	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	sphere_mesh.radial_segments = radial_segments
	sphere_mesh.rings = rings

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material.resource_name = "%sMaterial" % node_name

	if save_mesh_path != "":
		if not ResourceUtils.safe_save(sphere_mesh, save_mesh_path):
			return _send_error(client_id, "Failed to save shell mesh to %s" % save_mesh_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save shell material to %s" % save_material_path, command_id)

	var created_node_path := ""
	if create_node:
		var parent := _get_editor_node(parent_path)
		if parent == null:
			return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var shell_node := MeshInstance3D.new()
		shell_node.name = node_name
		shell_node.mesh = sphere_mesh
		shell_node.material_override = material

		var transaction = SceneTransactionManager.begin_inline("Create Planet Shell", {
			"command": "create_planet_shell",
			"parent_path": parent_path,
			"client_id": client_id,
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for planet shell creation", command_id)
		transaction.add_do_method(parent, "add_child", [shell_node])

		var edited_scene_root := _get_edited_scene_root_node()
		if edited_scene_root != null:
			transaction.add_do_method(self, "_assign_owner_recursive", [shell_node, edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [shell_node])
		transaction.add_undo_method(shell_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit planet shell creation", command_id)

		created_node_path = _to_mcp_path(shell_node)

	_send_success(client_id, {
		"created_node_path": created_node_path,
		"radius": radius,
		"segments": {"radial_segments": radial_segments, "rings": rings},
		"saved_paths": {"mesh": save_mesh_path, "material": save_material_path},
	}, command_id)

func _create_ocean_tile(client_id: int, params: Dictionary, command_id: String) -> void:
	var merged_params := params.duplicate(true)
	merged_params["mesh_mode"] = "single_tile"
	if not merged_params.has("node_name"):
		merged_params["node_name"] = "OceanTile"
	if not merged_params.has("create_node"):
		merged_params["create_node"] = true
	_generate_procedural_planet_ocean(client_id, merged_params, command_id)

func _apply_triplanar_terrain_material(client_id: int, params: Dictionary, command_id: String) -> void:
	var node_path := str(params.get("node_path", ""))
	if node_path == "":
		return _send_error(client_id, "node_path is required", command_id)

	var node := _get_editor_node(node_path)
	if node == null:
		return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	if not (node is MeshInstance3D):
		return _send_error(client_id, "Node at %s is %s, not a MeshInstance3D" % [node_path, node.get_class()], command_id)

	var rock_texture_path := str(params.get("rock_texture_path", ""))
	var grass_texture_path := str(params.get("grass_texture_path", ""))
	var snow_texture_path := str(params.get("snow_texture_path", ""))
	var texture_scale := max(0.001, float(params.get("texture_scale", 3.0)))
	var snow_height := clampf(float(params.get("snow_height", 0.75)), 0.0, 1.0)
	var blend_softness := clampf(float(params.get("blend_softness", 0.18)), 0.01, 0.5)
	var roughness := clampf(float(params.get("roughness", 0.95)), 0.0, 1.0)
	var metallic := clampf(float(params.get("metallic", 0.0)), 0.0, 1.0)

	var rock_texture: Texture2D = _create_solid_texture(Color(0.42, 0.39, 0.35, 1.0))
	var grass_texture: Texture2D = _create_solid_texture(Color(0.20, 0.45, 0.18, 1.0))
	var snow_texture: Texture2D = _create_solid_texture(Color(0.92, 0.94, 0.97, 1.0))
	if rock_texture_path != "":
		var loaded_rock = ResourceUtils.safe_load(rock_texture_path)
		if not (loaded_rock is Texture2D):
			return _send_error(client_id, "rock_texture_path is not a loadable Texture2D: %s" % rock_texture_path, command_id)
		rock_texture = loaded_rock
	if grass_texture_path != "":
		var loaded_grass = ResourceUtils.safe_load(grass_texture_path)
		if not (loaded_grass is Texture2D):
			return _send_error(client_id, "grass_texture_path is not a loadable Texture2D: %s" % grass_texture_path, command_id)
		grass_texture = loaded_grass
	if snow_texture_path != "":
		var loaded_snow = ResourceUtils.safe_load(snow_texture_path)
		if not (loaded_snow is Texture2D):
			return _send_error(client_id, "snow_texture_path is not a loadable Texture2D: %s" % snow_texture_path, command_id)
		snow_texture = loaded_snow

	var shader_code := """
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D rock_tex : source_color;
uniform sampler2D grass_tex : source_color;
uniform sampler2D snow_tex : source_color;
uniform float texture_scale = 3.0;
uniform float snow_height = 0.75;
uniform float blend_softness = 0.18;
uniform float roughness = 0.95;
uniform float metallic = 0.0;

vec3 triplanar_sample(sampler2D tex, vec3 wp, vec3 blend) {
	vec3 tx = texture(tex, wp.yz).rgb;
	vec3 ty = texture(tex, wp.xz).rgb;
	vec3 tz = texture(tex, wp.xy).rgb;
	return tx * blend.x + ty * blend.y + tz * blend.z;
}

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 blend = abs(n);
	blend = pow(blend, vec3(4.0));
	blend /= max(blend.x + blend.y + blend.z, 0.0001);
	vec3 wp = world_pos * texture_scale;
	vec3 rock = triplanar_sample(rock_tex, wp, blend);
	vec3 grass = triplanar_sample(grass_tex, wp, blend);
	vec3 snow = triplanar_sample(snow_tex, wp, blend);

	float up = clamp(n.y * 0.5 + 0.5, 0.0, 1.0);
	float snow_f = smoothstep(snow_height - blend_softness, snow_height + blend_softness, up);
	float grass_f = smoothstep(0.20 - blend_softness, 0.62 + blend_softness, up) * (1.0 - snow_f);
	float rock_f = max(0.0, 1.0 - grass_f - snow_f);
	vec3 albedo = rock * rock_f + grass * grass_f + snow * snow_f;

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
}
"""

	var shader := Shader.new()
	shader.code = shader_code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("rock_tex", rock_texture)
	material.set_shader_parameter("grass_tex", grass_texture)
	material.set_shader_parameter("snow_tex", snow_texture)
	material.set_shader_parameter("texture_scale", texture_scale)
	material.set_shader_parameter("snow_height", snow_height)
	material.set_shader_parameter("blend_softness", blend_softness)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("metallic", metallic)

	var mesh_node: MeshInstance3D = node
	var previous_material = mesh_node.material_override
	var transaction = SceneTransactionManager.begin_inline("Apply Triplanar Material", {
		"command": "apply_triplanar_terrain_material",
		"node_path": node_path,
		"client_id": client_id,
	})
	if transaction == null:
		return _send_error(client_id, "Unable to obtain transaction for triplanar material assignment", command_id)
	transaction.add_do_property(mesh_node, "material_override", material)
	transaction.add_undo_property(mesh_node, "material_override", previous_material)
	transaction.register_on_commit(func():
		_mark_scene_modified()
	)
	if not transaction.commit():
		transaction.rollback()
		return _send_error(client_id, "Failed to commit triplanar material assignment", command_id)

	var save_material_path := str(params.get("save_material_path", ""))
	var save_shader_path := str(params.get("save_shader_path", ""))
	if save_shader_path != "":
		if not ResourceUtils.safe_save(shader, save_shader_path):
			return _send_error(client_id, "Failed to save triplanar shader to %s" % save_shader_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save triplanar material to %s" % save_material_path, command_id)

	_send_success(client_id, {
		"node_path": node_path,
		"status": "committed",
		"saved_paths": {"shader": save_shader_path, "material": save_material_path},
	}, command_id)

func _generate_planet_cloud_layer(client_id: int, params: Dictionary, command_id: String) -> void:
	var cloud_radius := max(0.1, float(params.get("cloud_radius", 1.06)))
	var radial_segments := clampi(int(params.get("radial_segments", 96)), 8, 512)
	var rings := clampi(int(params.get("rings", 64)), 8, 256)
	var cloud_density := clampf(float(params.get("cloud_density", 0.45)), 0.0, 1.0)
	var cloud_scale := max(0.01, float(params.get("cloud_scale", 2.4)))
	var cloud_speed := max(0.0, float(params.get("cloud_speed", 0.05)))
	var cloud_alpha := clampf(float(params.get("cloud_alpha", 0.6)), 0.0, 1.0)
	var cloud_color = _coerce_to_color(params.get("cloud_color", {"r": 0.95, "g": 0.97, "b": 1.0, "a": 1.0}))
	if not (cloud_color is Color):
		return _send_error(client_id, "cloud_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var node_name := str(params.get("node_name", "PlanetCloudLayer"))
	var planet_node_path := str(params.get("planet_node_path", ""))
	var parent_path := str(params.get("parent_path", ""))
	var create_node := params.get("create_node", true)


	var material := _cloud_shader_material(cloud_color, cloud_density, cloud_scale, cloud_speed, cloud_alpha)
	var shader: Shader = material.shader

	var save_shader_path := str(params.get("save_shader_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))
	if save_shader_path != "":
		if not ResourceUtils.safe_save(shader, save_shader_path):
			return _send_error(client_id, "Failed to save cloud shader to %s" % save_shader_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save cloud material to %s" % save_material_path, command_id)

	var created_node_path := ""
	if create_node:
		var planet_node: Node = null
		if planet_node_path != "":
			planet_node = _get_editor_node(planet_node_path)
			if planet_node == null:
				return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

		var parent: Node = null
		if parent_path != "":
			parent = _get_editor_node(parent_path)
		elif planet_node != null:
			parent = planet_node.get_parent()
		else:
			parent = _get_editor_node("/root")
		if parent == null:
			return _send_error(client_id, "Parent node not found", command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var cloud_mesh := SphereMesh.new()
		cloud_mesh.radius = cloud_radius
		cloud_mesh.height = cloud_radius * 2.0
		cloud_mesh.radial_segments = radial_segments
		cloud_mesh.rings = rings

		var cloud_node := MeshInstance3D.new()
		cloud_node.name = node_name
		cloud_node.mesh = cloud_mesh
		cloud_node.material_override = material
		if planet_node != null and cloud_node is Node3D and planet_node is Node3D:
			cloud_node.transform = _local_transform_matching(planet_node, parent)

		var transaction = SceneTransactionManager.begin_inline("Generate Planet Cloud Layer", {
			"command": "generate_planet_cloud_layer",
			"client_id": client_id,
			"parent_path": _to_mcp_path(parent),
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for cloud layer creation", command_id)
		transaction.add_do_method(parent, "add_child", [cloud_node])
		var edited_scene_root := _get_edited_scene_root_node()
		if edited_scene_root != null:
			transaction.add_do_method(self, "_assign_owner_recursive", [cloud_node, edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [cloud_node])
		transaction.add_undo_method(cloud_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit cloud layer creation", command_id)

		created_node_path = _to_mcp_path(cloud_node)

	_send_success(client_id, {
		"created_node_path": created_node_path,
		"cloud_radius": cloud_radius,
		"saved_paths": {"shader": save_shader_path, "material": save_material_path},
	}, command_id)

func _create_planet_atmosphere_glow(client_id: int, params: Dictionary, command_id: String) -> void:
	var radius := max(0.1, float(params.get("radius", 1.08)))
	var radial_segments := clampi(int(params.get("radial_segments", 96)), 8, 512)
	var rings := clampi(int(params.get("rings", 64)), 8, 256)
	var glow_color = _coerce_to_color(params.get("glow_color", {"r": 0.35, "g": 0.62, "b": 1.0, "a": 1.0}))
	if not (glow_color is Color):
		return _send_error(client_id, "glow_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var fresnel_power := max(0.1, float(params.get("fresnel_power", 4.0)))
	var intensity := max(0.0, float(params.get("intensity", 1.2)))
	var alpha := clampf(float(params.get("alpha", 0.45)), 0.0, 1.0)
	var node_name := str(params.get("node_name", "PlanetAtmosphere"))
	var planet_node_path := str(params.get("planet_node_path", ""))
	var parent_path := str(params.get("parent_path", ""))
	var create_node := params.get("create_node", true)

	var material := _build_atmosphere_shader_material(glow_color, fresnel_power, intensity, alpha)
	var shader: Shader = material.shader

	var save_shader_path := str(params.get("save_shader_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))
	if save_shader_path != "":
		if not ResourceUtils.safe_save(shader, save_shader_path):
			return _send_error(client_id, "Failed to save atmosphere shader to %s" % save_shader_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save atmosphere material to %s" % save_material_path, command_id)

	var created_node_path := ""
	if create_node:
		var planet_node: Node = null
		if planet_node_path != "":
			planet_node = _get_editor_node(planet_node_path)
			if planet_node == null:
				return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

		var parent: Node = null
		if parent_path != "":
			parent = _get_editor_node(parent_path)
		elif planet_node != null:
			parent = planet_node.get_parent()
		else:
			parent = _get_editor_node("/root")
		if parent == null:
			return _send_error(client_id, "Parent node not found", command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var atmosphere_mesh := SphereMesh.new()
		atmosphere_mesh.radius = radius
		atmosphere_mesh.height = radius * 2.0
		atmosphere_mesh.radial_segments = radial_segments
		atmosphere_mesh.rings = rings

		var atmosphere_node := MeshInstance3D.new()
		atmosphere_node.name = node_name
		atmosphere_node.mesh = atmosphere_mesh
		atmosphere_node.material_override = material
		if planet_node != null and atmosphere_node is Node3D and planet_node is Node3D:
			atmosphere_node.transform = _local_transform_matching(planet_node, parent)

		var transaction = SceneTransactionManager.begin_inline("Create Atmosphere Glow", {
			"command": "create_planet_atmosphere_glow",
			"client_id": client_id,
			"parent_path": _to_mcp_path(parent),
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for atmosphere creation", command_id)
		transaction.add_do_method(parent, "add_child", [atmosphere_node])
		var edited_scene_root := _get_edited_scene_root_node()
		if edited_scene_root != null:
			transaction.add_do_method(self, "_assign_owner_recursive", [atmosphere_node, edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [atmosphere_node])
		transaction.add_undo_method(atmosphere_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit atmosphere creation", command_id)

		created_node_path = _to_mcp_path(atmosphere_node)

	_send_success(client_id, {
		"created_node_path": created_node_path,
		"radius": radius,
		"saved_paths": {"shader": save_shader_path, "material": save_material_path},
	}, command_id)

func _scatter_craters_on_sphere(client_id: int, params: Dictionary, command_id: String) -> void:
	var count := clampi(int(params.get("count", 24)), 1, 2048)
	var planet_radius := max(0.1, float(params.get("planet_radius", 1.0)))
	var crater_min_radius := max(0.001, float(params.get("crater_min_radius", 0.03)))
	var crater_max_radius := float(params.get("crater_max_radius", 0.09))
	if crater_max_radius < crater_min_radius:
		return _send_error(client_id, "crater_min_radius (%s) must not exceed crater_max_radius (%s)" % [crater_min_radius, crater_max_radius], command_id)
	var crater_depth := clampf(float(params.get("crater_depth", 0.35)), 0.05, 1.0)
	var seed := int(params.get("seed", 1337))
	var node_name := str(params.get("node_name", "CraterField"))
	var parent_path := str(params.get("parent_path", ""))
	var planet_node_path := str(params.get("planet_node_path", ""))
	var crater_color = _coerce_to_color(params.get("crater_color", {"r": 0.24, "g": 0.24, "b": 0.25, "a": 1.0}))
	if not (crater_color is Color):
		return _send_error(client_id, "crater_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var create_node := params.get("create_node", true)

	if not create_node:
		return _send_success(client_id, {
			"status": "skipped",
			"reason": "create_node is false",
			"count": count,
		}, command_id)

	var planet_node: Node = null
	if planet_node_path != "":
		planet_node = _get_editor_node(planet_node_path)
		if planet_node == null:
			return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

	var parent: Node = null
	if parent_path != "":
		parent = _get_editor_node(parent_path)
	elif planet_node != null:
		parent = planet_node
	else:
		parent = _get_editor_node("/root")
	if parent == null:
		return _send_error(client_id, "Parent node not found", command_id)
	var name_error := _sibling_name_error(parent, node_name)
	if not name_error.is_empty():
		return _send_error(client_id, name_error, command_id)

	var crater_material := StandardMaterial3D.new()
	crater_material.albedo_color = crater_color
	crater_material.roughness = 1.0
	crater_material.metallic = 0.0

	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var crater_root := Node3D.new()
	crater_root.name = node_name

	for i in range(count):
		var direction := _random_unit_vector(rng)
		var crater_radius := rng.randf_range(crater_min_radius, crater_max_radius)
		var crater_mesh := CylinderMesh.new()
		crater_mesh.top_radius = crater_radius
		crater_mesh.bottom_radius = crater_radius
		crater_mesh.height = crater_radius * 0.16
		crater_mesh.radial_segments = 12

		var crater_node := MeshInstance3D.new()
		crater_node.name = "Crater%03d" % i
		crater_node.mesh = crater_mesh
		crater_node.material_override = crater_material
		# The disc's underside touches the surface, so its rim stands clear of the curving sphere;
		# (planet_radius - crater_radius * depth) buried every crater inside the planet.
		crater_node.transform = Transform3D(_basis_from_y_axis(direction), direction * (planet_radius + crater_mesh.height * crater_depth * 0.5))
		crater_node.scale = Vector3(1.0, crater_depth, 1.0)
		crater_root.add_child(crater_node)

	var transaction = SceneTransactionManager.begin_inline("Scatter Craters", {
		"command": "scatter_craters_on_sphere",
		"client_id": client_id,
		"parent_path": _to_mcp_path(parent),
		"planet_node_path": planet_node_path,
	})
	if transaction == null:
		return _send_error(client_id, "Unable to obtain transaction for crater scatter", command_id)
	transaction.add_do_method(parent, "add_child", [crater_root])
	var edited_scene_root := _get_edited_scene_root_node()
	if edited_scene_root != null:
		transaction.add_do_method(self, "_assign_owner_recursive", [crater_root, edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [crater_root])
	transaction.add_undo_method(crater_root, "queue_free")
	transaction.register_on_commit(func():
		_mark_scene_modified()
	)
	if not transaction.commit():
		transaction.rollback()
		return _send_error(client_id, "Failed to commit crater scatter", command_id)

	_send_success(client_id, {
		"created_node_path": _to_mcp_path(crater_root),
		"count": count,
		"seed": seed,
	}, command_id)

func _create_ring_system(client_id: int, params: Dictionary, command_id: String) -> void:
	var outer_radius := max(0.1, float(params.get("outer_radius", 2.0)))
	var inner_radius := max(0.01, float(params.get("inner_radius", 1.3)))
	if inner_radius >= outer_radius:
		return _send_error(client_id, "inner_radius (%s) must be smaller than outer_radius (%s)" % [inner_radius, outer_radius], command_id)
	var alpha := clampf(float(params.get("alpha", 0.82)), 0.0, 1.0)
	var banding := clampf(float(params.get("banding", 0.35)), 0.0, 1.0)
	var seed := float(params.get("seed", 12.0))
	var ring_color = _coerce_to_color(params.get("ring_color", {"r": 0.76, "g": 0.68, "b": 0.56, "a": 1.0}))
	if not (ring_color is Color):
		return _send_error(client_id, "ring_color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var node_name := str(params.get("node_name", "PlanetRings"))
	var create_node := params.get("create_node", true)
	var planet_node_path := str(params.get("planet_node_path", ""))
	var parent_path := str(params.get("parent_path", ""))
	var tilt_degrees_param = params.get("tilt_degrees", 22.0)

	var tilt_degrees := Vector3(22.0, 0.0, 0.0)
	if typeof(tilt_degrees_param) == TYPE_FLOAT or typeof(tilt_degrees_param) == TYPE_INT:
		tilt_degrees = Vector3(float(tilt_degrees_param), 0.0, 0.0)
	else:
		tilt_degrees = _coerce_to_vector3(tilt_degrees_param)

	var inner_ratio = inner_radius / outer_radius
	var shader_code := """
shader_type spatial;
render_mode blend_mix, cull_back, unshaded, depth_draw_opaque;

uniform vec4 ring_color : source_color = vec4(0.76, 0.68, 0.56, 1.0);
uniform float inner_ratio = 0.65;
uniform float alpha = 0.82;
uniform float banding = 0.35;
uniform float seed = 12.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float ring = smoothstep(inner_ratio, inner_ratio + 0.01, r) * (1.0 - smoothstep(0.99, 1.0, r));
	float stripe = sin((r + seed * 0.013) * 220.0) * 0.5 + 0.5;
	float dust = hash21(p * 90.0 + seed);
	float bands = mix(1.0 - banding, 1.0 + banding, stripe * 0.75 + dust * 0.25);
	vec3 c = ring_color.rgb * bands;
	ALBEDO = c;
	EMISSION = c * 0.04;
	ALPHA = ring * alpha;
}
"""
	var shader := Shader.new()
	shader.code = shader_code
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("ring_color", ring_color)
	material.set_shader_parameter("inner_ratio", inner_ratio)
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("banding", banding)
	material.set_shader_parameter("seed", seed)

	var save_shader_path := str(params.get("save_shader_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))
	if save_shader_path != "":
		if not ResourceUtils.safe_save(shader, save_shader_path):
			return _send_error(client_id, "Failed to save ring shader to %s" % save_shader_path, command_id)
	if save_material_path != "":
		if not ResourceUtils.safe_save(material, save_material_path):
			return _send_error(client_id, "Failed to save ring material to %s" % save_material_path, command_id)

	var created_node_path := ""
	if create_node:
		var planet_node: Node = null
		if planet_node_path != "":
			planet_node = _get_editor_node(planet_node_path)
			if planet_node == null:
				return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

		var parent: Node = null
		if parent_path != "":
			parent = _get_editor_node(parent_path)
		elif planet_node != null:
			parent = planet_node.get_parent()
		else:
			parent = _get_editor_node("/root")
		if parent == null:
			return _send_error(client_id, "Parent node not found", command_id)
		var name_error := _sibling_name_error(parent, node_name)
		if not name_error.is_empty():
			return _send_error(client_id, name_error, command_id)

		var ring_mesh := PlaneMesh.new()
		ring_mesh.size = Vector2(outer_radius * 2.0, outer_radius * 2.0)
		ring_mesh.subdivide_width = 2
		ring_mesh.subdivide_depth = 2

		var ring_node := MeshInstance3D.new()
		ring_node.name = node_name
		ring_node.mesh = ring_mesh
		ring_node.material_override = material
		ring_node.rotation_degrees = tilt_degrees
		if planet_node != null and ring_node is Node3D and planet_node is Node3D:
			ring_node.transform.origin = (planet_node as Node3D).transform.origin

		var transaction = SceneTransactionManager.begin_inline("Create Ring System", {
			"command": "create_ring_system",
			"client_id": client_id,
			"parent_path": _to_mcp_path(parent),
		})
		if transaction == null:
			return _send_error(client_id, "Unable to obtain transaction for ring creation", command_id)
		transaction.add_do_method(parent, "add_child", [ring_node])
		var edited_scene_root := _get_edited_scene_root_node()
		if edited_scene_root != null:
			transaction.add_do_method(self, "_assign_owner_recursive", [ring_node, edited_scene_root])
		transaction.add_undo_method(parent, "remove_child", [ring_node])
		transaction.add_undo_method(ring_node, "queue_free")
		transaction.register_on_commit(func():
			_mark_scene_modified()
		)
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit ring creation", command_id)

		created_node_path = _to_mcp_path(ring_node)

	_send_success(client_id, {
		"created_node_path": created_node_path,
		"inner_radius": inner_radius,
		"outer_radius": outer_radius,
		"saved_paths": {"shader": save_shader_path, "material": save_material_path},
	}, command_id)

func _generate_starfield_skybox(client_id: int, params: Dictionary, command_id: String) -> void:
	var width := clampi(int(params.get("width", 1024)), 64, 4096)
	var height := clampi(int(params.get("height", 512)), 32, 2048)
	var star_count := clampi(int(params.get("star_count", 2200)), 1, 200000)
	var seed := int(params.get("seed", 4242))
	var background_top = _coerce_to_color(params.get("background_top", {"r": 0.01, "g": 0.02, "b": 0.06, "a": 1.0}))
	if not (background_top is Color):
		return _send_error(client_id, "background_top must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var background_bottom = _coerce_to_color(params.get("background_bottom", {"r": 0.0, "g": 0.0, "b": 0.02, "a": 1.0}))
	if not (background_bottom is Color):
		return _send_error(client_id, "background_bottom must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var apply_to_environment := params.get("apply_to_environment", true)
	var environment_path := str(params.get("environment_path", ""))
	var node_path := str(params.get("world_environment", params.get("node_path", "")))

	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		var t := float(y) / float(max(1, height - 1))
		var row_color = background_top.lerp(background_bottom, pow(t, 0.75))  # row 0 is the zenith
		for x in range(width):
			image.set_pixel(x, y, row_color)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for _i in range(star_count):
		var x := rng.randi_range(0, width - 1)
		var y := rng.randi_range(0, height - 1)
		var brightness := pow(rng.randf(), 0.25)
		var tint := Color(1.0, 1.0 - rng.randf() * 0.08, 1.0 - rng.randf() * 0.16, 1.0)
		var c := tint * brightness
		image.set_pixel(x, y, c)
		if rng.randf() > 0.93:
			if x > 0:
				image.set_pixel(x - 1, y, c * 0.4)
			if x < width - 1:
				image.set_pixel(x + 1, y, c * 0.4)
			if y > 0:
				image.set_pixel(x, y - 1, c * 0.4)
			if y < height - 1:
				image.set_pixel(x, y + 1, c * 0.4)

	var panorama_texture := ImageTexture.create_from_image(image)
	var sky_material := PanoramaSkyMaterial.new()
	sky_material.panorama = panorama_texture
	var sky := Sky.new()
	sky.sky_material = sky_material

	var save_image_path := str(params.get("save_image_path", ""))
	var save_material_path := str(params.get("save_material_path", ""))
	var save_sky_path := str(params.get("save_sky_path", ""))
	var save_environment_path := str(params.get("save_environment_path", ""))
	# Saved resources without a saved image embedded the whole panorama (480 KB for 256x128).
	if save_image_path == "":
		for resource_path in [save_environment_path, save_sky_path, save_material_path]:
			if resource_path != "":
				save_image_path = resource_path.get_basename() + "_panorama.png"
				break

	if save_image_path != "":
		if not _save_image_or_texture(image, panorama_texture, save_image_path):
			return _send_error(client_id, "Failed to save starfield image to %s" % save_image_path, command_id)
		# Reference the saved PNG instead of embedding the pixels in every saved .tres (7 MB each).
		var reloaded: Dictionary = await _reload_saved_textures([save_image_path])
		var saved_panorama = reloaded.get(_contained_res_path(save_image_path))
		if saved_panorama != null:
			sky_material.panorama = saved_panorama
	if save_material_path != "":
		if not ResourceUtils.safe_save(sky_material, save_material_path):
			return _send_error(client_id, "Failed to save starfield material to %s" % save_material_path, command_id)
	if save_sky_path != "":
		if not ResourceUtils.safe_save(sky, save_sky_path):
			return _send_error(client_id, "Failed to save sky resource to %s" % save_sky_path, command_id)

	var applied := false
	var resolved_environment_path := environment_path
	if apply_to_environment and (environment_path != "" or node_path != ""):
		var resolve := _resolve_environment({
			"environment_path": environment_path,
			"node_path": node_path,
		})
		var environment: Environment = resolve.get("environment")
		if environment == null:
			return _send_error(client_id, resolve.get("error_message", "Unable to resolve Environment resource"), command_id)

		resolved_environment_path = str(resolve.get("environment_path", ""))
		var resolved_node_path := str(resolve.get("node_path", ""))
		if resolved_node_path != "":
			var transaction = SceneTransactionManager.begin_inline("Apply Starfield Skybox", {
				"command": "generate_starfield_skybox",
				"client_id": client_id,
				"node_path": resolved_node_path,
			})
			if transaction == null:
				return _send_error(client_id, "Unable to obtain transaction for skybox update", command_id)
			var previous_sky = environment.sky
			transaction.add_do_property(environment, "sky", sky)
			transaction.add_undo_property(environment, "sky", previous_sky)
			if environment.background_mode != Environment.BG_SKY:
				transaction.add_do_property(environment, "background_mode", Environment.BG_SKY)
				transaction.add_undo_property(environment, "background_mode", environment.background_mode)
			# A WorldEnvironment without an Environment got a new one that was never assigned.
			var assign_to = resolve.get("assign_to")
			if assign_to != null:
				transaction.add_do_property(assign_to, "environment", environment)
				transaction.add_undo_property(assign_to, "environment", assign_to.environment)
			transaction.register_on_commit(func():
				_mark_scene_modified()
			)
			if not transaction.commit():
				transaction.rollback()
				return _send_error(client_id, "Failed to commit skybox update", command_id)
		else:
			environment.sky = sky
		applied = true

		if save_environment_path != "":
			if not ResourceUtils.safe_save(environment, save_environment_path):
				return _send_error(client_id, "Failed to save environment to %s" % save_environment_path, command_id)
		elif resolved_environment_path != "" and params.get("save_environment", false):
			ResourceUtils.safe_save(environment, resolved_environment_path)

	_send_success(client_id, {
		"status": "success",
		"applied": applied,
		"environment_path": resolved_environment_path,
		"resolution": {"width": width, "height": height},
		"star_count": star_count,
		"seed": seed,
		"saved_paths": {
			"image": save_image_path,
			"material": save_material_path,
			"sky": save_sky_path,
			"environment": save_environment_path,
		},
	}, command_id)

func _create_moon_proxy(client_id: int, params: Dictionary, command_id: String) -> void:
	var radius := max(0.05, float(params.get("radius", 0.28)))
	var distance := max(0.1, float(params.get("distance", 2.5)))
	var orbit_speed := float(params.get("orbit_speed_deg_per_sec", 8.0))
	var inclination_degrees := float(params.get("inclination_degrees", 15.0))
	var node_name := str(params.get("node_name", "Moon"))
	var planet_node_path := str(params.get("planet_node_path", ""))
	var parent_path := str(params.get("parent_path", ""))
	var moon_color = _coerce_to_color(params.get("color", {"r": 0.74, "g": 0.74, "b": 0.78, "a": 1.0}))
	if not (moon_color is Color):
		return _send_error(client_id, "color must be a color (#hex, a color name, [r,g,b(,a)] or {r,g,b,a})", command_id)
	var create_node := params.get("create_node", true)

	if not create_node:
		return _send_success(client_id, {
			"status": "skipped",
			"reason": "create_node is false",
		}, command_id)

	var planet_node: Node = null
	if planet_node_path != "":
		planet_node = _get_editor_node(planet_node_path)
		if planet_node == null:
			return _send_error(client_id, "Planet node not found: %s" % planet_node_path, command_id)

	var parent: Node = null
	if parent_path != "":
		parent = _get_editor_node(parent_path)
	elif planet_node != null:
		parent = planet_node.get_parent()
	else:
		parent = _get_editor_node("/root")
	if parent == null:
		return _send_error(client_id, "Parent node not found", command_id)
	var name_error := _sibling_name_error(parent, "%sPivot" % node_name)
	if not name_error.is_empty():
		return _send_error(client_id, name_error, command_id)

	var pivot := Node3D.new()
	pivot.name = "%sPivot" % node_name
	pivot.rotation_degrees = Vector3(inclination_degrees, 0.0, 0.0)
	pivot.set_meta("orbit_speed_deg_per_sec", orbit_speed)

	if planet_node != null and pivot is Node3D and planet_node is Node3D:
		pivot.transform.origin = (planet_node as Node3D).transform.origin

	var moon_mesh := SphereMesh.new()
	moon_mesh.radius = radius
	moon_mesh.height = radius * 2.0
	moon_mesh.radial_segments = 32
	moon_mesh.rings = 24

	var moon_material := StandardMaterial3D.new()
	moon_material.albedo_color = moon_color
	moon_material.roughness = 1.0

	var moon_node := MeshInstance3D.new()
	moon_node.name = node_name
	moon_node.mesh = moon_mesh
	moon_node.material_override = moon_material
	moon_node.position = Vector3(distance, 0.0, 0.0)
	moon_node.set_meta("orbit_speed_deg_per_sec", orbit_speed)
	pivot.add_child(moon_node)

	var transaction = SceneTransactionManager.begin_inline("Create Moon Proxy", {
		"command": "create_moon_proxy",
		"client_id": client_id,
		"parent_path": _to_mcp_path(parent),
	})
	if transaction == null:
		return _send_error(client_id, "Unable to obtain transaction for moon proxy creation", command_id)
	transaction.add_do_method(parent, "add_child", [pivot])
	var edited_scene_root := _get_edited_scene_root_node()
	if edited_scene_root != null:
		transaction.add_do_method(self, "_assign_owner_recursive", [pivot, edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [pivot])
	transaction.add_undo_method(pivot, "queue_free")
	transaction.register_on_commit(func():
		_mark_scene_modified()
	)
	if not transaction.commit():
		transaction.rollback()
		return _send_error(client_id, "Failed to commit moon proxy creation", command_id)

	_send_success(client_id, {
		"pivot_path": _to_mcp_path(pivot),
		"moon_path": _to_mcp_path(moon_node),
		"radius": radius,
		"distance": distance,
		"orbit_speed_deg_per_sec": orbit_speed,
	}, command_id)

func _planet_preset_quickstart(client_id: int, params: Dictionary, command_id: String) -> void:
	var preset := str(params.get("preset", "earthlike")).to_lower()
	var parent_path := str(params.get("parent_path", "/root"))
	var root_name := str(params.get("node_name", "PlanetPreset"))
	var planet_radius := max(0.1, float(params.get("planet_radius", 1.0)))
	var include_moon := params.get("include_moon", true)

	var config := {
		"planet_color": Color(0.30, 0.42, 0.30, 1.0),
		"ocean": "water",
		"ocean_color": Color(0.08, 0.28, 0.52, 0.72),
		"cloud_alpha": 0.45,
		"atmo_color": Color(0.32, 0.58, 1.0, 1.0),
	}
	match preset:
		"desert":
			config["planet_color"] = Color(0.72, 0.58, 0.36, 1.0)
			config["ocean"] = "none"
			config["ocean_color"] = Color(0.18, 0.30, 0.34, 0.35)
			config["cloud_alpha"] = 0.20
			config["atmo_color"] = Color(0.95, 0.72, 0.45, 1.0)
		"ice":
			config["planet_color"] = Color(0.78, 0.86, 0.92, 1.0)
			config["ocean_color"] = Color(0.55, 0.72, 0.90, 0.45)
			config["cloud_alpha"] = 0.35
			config["atmo_color"] = Color(0.72, 0.86, 1.0, 1.0)
		"lava":
			config["planet_color"] = Color(0.32, 0.19, 0.18, 1.0)
			config["ocean"] = "lava"
			config["ocean_color"] = Color(0.85, 0.25, 0.06, 0.40)
			config["cloud_alpha"] = 0.10
			config["atmo_color"] = Color(1.0, 0.42, 0.18, 1.0)
		_:
			pass

	var parent := _get_editor_node(parent_path)
	if parent == null:
		return _send_error(client_id, "Parent node not found: %s" % parent_path, command_id)
	var name_error := _sibling_name_error(parent, root_name)
	if not name_error.is_empty():
		return _send_error(client_id, name_error, command_id)

	var root := Node3D.new()
	root.name = root_name

	var planet_mesh := SphereMesh.new()
	planet_mesh.radius = planet_radius
	planet_mesh.height = planet_radius * 2.0
	planet_mesh.radial_segments = 64
	planet_mesh.rings = 48
	var planet_material := StandardMaterial3D.new()
	planet_material.albedo_color = config["planet_color"]
	planet_material.roughness = 0.92
	var planet_node := MeshInstance3D.new()
	planet_node.name = "Planet"
	planet_node.mesh = planet_mesh
	planet_node.material_override = planet_material
	root.add_child(planet_node)

	var ocean_mesh := SphereMesh.new()
	ocean_mesh.radius = planet_radius * 1.02
	ocean_mesh.height = ocean_mesh.radius * 2.0
	ocean_mesh.radial_segments = 64
	ocean_mesh.rings = 48
	var ocean_material := StandardMaterial3D.new()
	ocean_material.albedo_color = config["ocean_color"]
	ocean_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ocean_material.roughness = 0.10
	if config["ocean"] == "lava":
		# A glowing lava sea; desert planets have no sea at all (both got a blue-ish ocean sphere).
		ocean_material.emission_enabled = true
		ocean_material.emission = config["ocean_color"]
		ocean_material.emission_energy_multiplier = 1.6
	var ocean_node := MeshInstance3D.new()
	ocean_node.name = "LavaSea" if config["ocean"] == "lava" else "Ocean"
	ocean_node.mesh = ocean_mesh
	ocean_node.material_override = ocean_material
	var has_ocean: bool = config["ocean"] != "none"
	if has_ocean:
		root.add_child(ocean_node)

	var cloud_mesh := SphereMesh.new()
	cloud_mesh.radius = planet_radius * 1.05
	cloud_mesh.height = cloud_mesh.radius * 2.0
	cloud_mesh.radial_segments = 64
	cloud_mesh.rings = 48
	# Noise clouds (the same shader as generate_planet_cloud_layer), not a flat white haze.
	var cloud_material := _cloud_shader_material(Color(0.95, 0.97, 1.0, 1.0), 0.45, 2.4, 0.03, minf(1.0, float(config["cloud_alpha"]) * 1.8))
	var cloud_node := MeshInstance3D.new()
	cloud_node.name = "Clouds"
	cloud_node.mesh = cloud_mesh
	cloud_node.material_override = cloud_material
	root.add_child(cloud_node)

	var atmo_mesh := SphereMesh.new()
	atmo_mesh.radius = planet_radius * 1.08
	atmo_mesh.height = atmo_mesh.radius * 2.0
	atmo_mesh.radial_segments = 64
	atmo_mesh.rings = 48
	var atmo_color: Color = config["atmo_color"]
	var atmo_material := _build_atmosphere_shader_material(atmo_color, 3.6, 1.1, 0.42)
	var atmo_node := MeshInstance3D.new()
	atmo_node.name = "Atmosphere"
	atmo_node.mesh = atmo_mesh
	atmo_node.material_override = atmo_material
	root.add_child(atmo_node)

	var moon_path := ""
	var moon_proxy: MeshInstance3D = null
	if include_moon:
		var moon_pivot := Node3D.new()
		moon_pivot.name = "MoonPivot"
		moon_pivot.rotation_degrees = Vector3(12.0, 0.0, 0.0)
		moon_pivot.set_meta("orbit_speed_deg_per_sec", 8.0)
		var moon_mesh := SphereMesh.new()
		moon_mesh.radius = planet_radius * 0.28
		moon_mesh.height = moon_mesh.radius * 2.0
		moon_mesh.radial_segments = 32
		moon_mesh.rings = 24
		var moon_material := StandardMaterial3D.new()
		moon_material.albedo_color = Color(0.74, 0.74, 0.78, 1.0)
		moon_material.roughness = 1.0
		moon_proxy = MeshInstance3D.new()
		moon_proxy.name = "Moon"
		moon_proxy.mesh = moon_mesh
		moon_proxy.material_override = moon_material
		moon_proxy.position = Vector3(planet_radius * 2.8, 0.0, 0.0)
		moon_pivot.add_child(moon_proxy)
		root.add_child(moon_pivot)

	var transaction = SceneTransactionManager.begin_inline("Planet Preset Quickstart", {
		"command": "planet_preset_quickstart",
		"client_id": client_id,
		"parent_path": parent_path,
		"preset": preset,
	})
	if transaction == null:
		return _send_error(client_id, "Unable to obtain transaction for quickstart preset", command_id)
	transaction.add_do_method(parent, "add_child", [root])
	var edited_scene_root := _get_edited_scene_root_node()
	if edited_scene_root != null:
		transaction.add_do_method(self, "_assign_owner_recursive", [root, edited_scene_root])
	transaction.add_undo_method(parent, "remove_child", [root])
	transaction.add_undo_method(root, "queue_free")
	transaction.register_on_commit(func():
		_mark_scene_modified()
	)
	if not transaction.commit():
		transaction.rollback()
		return _send_error(client_id, "Failed to commit quickstart preset", command_id)

	if moon_proxy != null:
		moon_path = _to_mcp_path(moon_proxy)

	_send_success(client_id, {
		"preset": preset,
		"root_path": _to_mcp_path(root),
		"planet_path": _to_mcp_path(planet_node),
		"ocean_path": _to_mcp_path(ocean_node) if has_ocean else "",  # desert: no sea
		"cloud_path": _to_mcp_path(cloud_node),
		"atmosphere_path": _to_mcp_path(atmo_node),
		"moon_path": moon_path,
	}, command_id)
	if not has_ocean:
		ocean_node.free()  # built but never added (desert)

func _fractal_noise_sample(
	noise: FastNoiseLite,
	direction: Vector3,
	base_frequency: float,
	octaves: int,
	lacunarity: float,
	persistence: float
) -> float:
	var frequency := base_frequency
	var amplitude := 1.0
	var value := 0.0
	var amplitude_sum := 0.0

	for _octave in range(octaves):
		value += noise.get_noise_3d(
			direction.x * frequency,
			direction.y * frequency,
			direction.z * frequency
		) * amplitude
		amplitude_sum += amplitude
		frequency *= lacunarity
		amplitude *= persistence

	if amplitude_sum <= 0.0:
		return 0.0
	return value / amplitude_sum

func _planet_biome_color(elevation: float, humidity: float, sea_level: float) -> Color:
	if elevation <= sea_level:
		var ocean_t := clampf((elevation + 1.0) / (sea_level + 1.0), 0.0, 1.0)
		var deep_water := Color(0.02, 0.10, 0.28, 1.0)
		var shallow_water := Color(0.07, 0.30, 0.52, 1.0)
		return deep_water.lerp(shallow_water, ocean_t)

	var land_height := clampf((elevation - sea_level) / (1.0 - sea_level), 0.0, 1.0)
	if land_height < 0.08:
		return Color(0.85, 0.78, 0.55, 1.0)
	if land_height < 0.55:
		var dry := Color(0.48, 0.44, 0.24, 1.0)
		var humid := Color(0.16, 0.45, 0.17, 1.0)
		return dry.lerp(humid, humidity)
	if land_height < 0.8:
		return Color(0.40, 0.36, 0.32, 1.0)
	return Color(0.92, 0.92, 0.95, 1.0)

func _build_planet_normal_map(height_values: PackedFloat32Array, width: int, height: int, strength: float) -> Image:
	var normal_image := Image.create(width, height, false, Image.FORMAT_RGB8)
	for y in range(height):
		var y_up := max(y - 1, 0)
		var y_down := min(y + 1, height - 1)
		for x in range(width):
			var x_left := x - 1
			if x_left < 0:
				x_left = width - 1
			var x_right := (x + 1) % width

			var left_h := height_values[y * width + x_left]
			var right_h := height_values[y * width + x_right]
			var up_h := height_values[y_up * width + x]
			var down_h := height_values[y_down * width + x]

			var dx := (right_h - left_h) * strength
			var dy := (down_h - up_h) * strength
			var normal := Vector3(-dx, -dy, 1.0).normalized()
			normal_image.set_pixel(
				x,
				y,
				Color(normal.x * 0.5 + 0.5, normal.y * 0.5 + 0.5, normal.z * 0.5 + 0.5, 1.0)
			)
	return normal_image

# Coroutine: a freshly written PNG is only loadable after the editor scans and imports it.
func _reload_saved_textures(paths: Array) -> Dictionary:
	var textures := {}
	var filesystem := EditorInterface.get_resource_filesystem()
	var wanted: Array = []
	for raw_path in paths:
		var path := _contained_res_path(str(raw_path)) if str(raw_path) != "" else ""
		if not path.is_empty():
			wanted.append(path)
	if filesystem == null or wanted.is_empty():
		return textures
	filesystem.scan()
	var deadline := Time.get_ticks_msec() + 5000
	var pending := wanted.duplicate()
	while not pending.is_empty() and Time.get_ticks_msec() < deadline:
		await Engine.get_main_loop().process_frame
		pending = pending.filter(func(path): return filesystem.get_file_type(path) == "")
	var known := PackedStringArray(wanted.filter(func(path): return filesystem.get_file_type(path) != ""))
	if known.is_empty():
		return textures
	filesystem.reimport_files(known)
	for path in known:
		var loaded = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REPLACE)
		if loaded is Texture2D:
			textures[path] = loaded
	return textures

func _save_image_or_texture(image: Image, texture: Texture2D, path: String) -> bool:
	# globalize_path() passes absolute paths through unchanged, so contain first.
	path = _contained_res_path(path)
	if path.is_empty():
		return false
	var extension := path.get_extension().to_lower()
	var global_path := ProjectSettings.globalize_path(path)
	var save_error := ERR_UNAVAILABLE
	var global_dir := global_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(global_dir):
		var mkdir_error := DirAccess.make_dir_recursive_absolute(global_dir)
		if mkdir_error != OK:
			return false

	match extension:
		"png":
			save_error = image.save_png(global_path)
		"jpg", "jpeg":
			save_error = image.save_jpg(global_path)
		"webp":
			save_error = image.save_webp(global_path)
		"exr":
			save_error = image.save_exr(global_path)
		"hdr":
			save_error = image.save_hdr(global_path)
		_:
			return ResourceUtils.safe_save(texture, path)

	return save_error == OK

func _configure_environment(client_id: int, params: Dictionary, command_id: String) -> void:
	var resolve: Dictionary = _resolve_environment(params)
	var environment: Environment = resolve.get("environment")
	if environment == null:
		return _send_error(client_id, resolve.get("error_message", "Unable to resolve Environment resource"), command_id)

	var environment_path: String = resolve.get("environment_path", "")
	var node_path: String = resolve.get("node_path", "")
	var transaction_id := params.get("transaction_id", "")
	var save_changes := params.get("save", true)

	var changes := _collect_environment_changes(environment, params)
	var assign_to = resolve.get("assign_to")
	if not _refused_values.is_empty():
		# Atomic: refuse the whole call before anything is applied.
		var refused := "; ".join(PackedStringArray(_refused_values))
		return _send_error(client_id, "Refused: %s" % refused, command_id)
	if changes.is_empty() and assign_to == null:
		_send_success(client_id, {
			"status": "no_change",
			"environment_path": environment_path,
			"node_path": node_path,
			"changes": [],
		}, command_id)
		return

	var transaction
	if transaction_id == "":
		transaction = SceneTransactionManager.begin_inline("Configure Environment", {
			"command": "configure_environment",
			"node_path": node_path,
			"environment_path": environment_path,
			"client_id": client_id,
		})
	else:
		transaction = SceneTransactionManager.get_transaction(transaction_id)
		if transaction == null:
			transaction = SceneTransactionManager.begin_registered(transaction_id, "Configure Environment", {
				"command": "configure_environment",
				"node_path": node_path,
				"environment_path": environment_path,
				"client_id": client_id,
			})

	if transaction == null:
		return _send_error(client_id, "Unable to acquire transaction for environment configuration", command_id)

	if assign_to != null:
		transaction.add_do_property(assign_to, "environment", environment)
		transaction.add_undo_property(assign_to, "environment", assign_to.environment)
		changes.append({
			"property": "WorldEnvironment.environment",
			"previous": assign_to.environment.resource_path if assign_to.environment != null else null,
			"value": environment.resource_path if environment.resource_path != "" else ("new Environment" if resolve.get("created_environment", false) else "Environment"),
		})
	for change in changes:
		if str(change.property) == "WorldEnvironment.environment":
			continue
		transaction.add_do_property(environment, change.property, change.value)
		transaction.add_undo_property(environment, change.property, change.previous)

	transaction.register_on_commit(func():
		if node_path != "":
			_mark_scene_modified()
		_log("Configured environment", "_configure_environment", {
			"system_section": "environment",
			"environment_path": environment_path,
			"node_path": node_path,
			"changes": changes,
		})
	)

	if transaction_id == "":
		if not transaction.commit():
			transaction.rollback()
			return _send_error(client_id, "Failed to commit environment changes", command_id)

	if save_changes and transaction_id == "" and environment.resource_path != "":
		ResourceUtils.safe_save(environment, environment.resource_path)

	_send_success(client_id, {
		"environment_path": environment_path,
		"node_path": node_path,
		"changes": changes,
		"transaction_id": transaction.transaction_id,
		"status": ("committed" if transaction_id == "" else "pending"),
	}, command_id)

func _preview_environment_sun_settings(client_id: int, params: Dictionary, command_id: String) -> void:
	var resolve: Dictionary = _resolve_environment(params)
	var environment: Environment = resolve.get("environment")
	if environment == null:
		return _send_error(client_id, resolve.get("error_message", "Unable to resolve Environment resource"), command_id)

	var environment_path: String = resolve.get("environment_path", "")
	var node_path: String = resolve.get("node_path", "")
	var overrides := params.get("sun", {})
	var current := {}
	for property_name in SUN_PROPERTY_MAP.values():
		current[property_name] = environment.get(property_name)
	var preview := current.duplicate()

	if typeof(overrides) == TYPE_DICTIONARY:
		for key in overrides.keys():
			var property_name: String = SUN_PROPERTY_MAP.get(key, key if SUN_PROPERTY_MAP.values().has(key) else "")
			if property_name.is_empty():
				return _send_error(client_id, "Unknown sun key: %s (supported: %s)" % [key, ", ".join(SUN_PROPERTY_MAP.keys())], command_id)
			preview[property_name] = _coerce_value_to_match(current[property_name], _parse_property_value(overrides[key]))

	var apply_changes := params.get("apply", false)
	if apply_changes:
		var apply_params := params.duplicate(true)
		apply_params["sun"] = overrides
		_configure_environment(client_id, apply_params, command_id)
		return

	_send_success(client_id, {
		"environment_path": environment_path,
		"node_path": node_path,
		"current": current,
		"preview": preview,
	}, command_id)

func _collect_environment_changes(environment: Environment, params: Dictionary) -> Array:
	var changes: Array = []

	var direct_properties := params.get("properties", {})
	if typeof(direct_properties) == TYPE_DICTIONARY:
		for property_name in direct_properties.keys():
			_append_environment_change(environment, property_name, direct_properties[property_name], changes)

	var ambient := params.get("ambient_light", {})
	if typeof(ambient) == TYPE_DICTIONARY:
		var ambient_map := {
			"color": "ambient_light_color",
			"energy": "ambient_light_energy",
			"sky_contribution": "ambient_light_sky_contribution",
		}
		_merge_environment_section_changes(environment, ambient_map, ambient, changes)

	var fog := params.get("fog", {})
	if typeof(fog) == TYPE_DICTIONARY:
		var fog_map := {
			"enabled": "fog_enabled",
			"color": "fog_light_color",
			"energy": "fog_light_energy",
			"density": "fog_density",
			"height": "fog_height",
			"height_density": "fog_height_density",
			"sun_color": SUN_PROPERTY_MAP["color"],
			"sun_amount": SUN_PROPERTY_MAP["amount"],
			"sun_scatter": SUN_PROPERTY_MAP["scatter"],
		}
		_merge_environment_section_changes(environment, fog_map, fog, changes)

	var sun := params.get("sun", {})
	if typeof(sun) == TYPE_DICTIONARY:
		_merge_environment_section_changes(environment, SUN_PROPERTY_MAP, sun, changes)

	var sky := params.get("sky", {})
	if typeof(sky) == TYPE_DICTIONARY:
		if sky.has("path") and typeof(sky["path"]) == TYPE_STRING:
			var sky_path: String = sky["path"]
			var sky_resource = null
			# A Sky file, a sky material file, or a sky material class such as "ProceduralSkyMaterial".
			# Anything else was ignored without a word before.
			if sky_path.begins_with("res://"):
				sky_resource = ResourceUtils.safe_load(sky_path)
			elif ClassDB.class_exists(sky_path) and ClassDB.is_parent_class(sky_path, "Material") and ClassDB.can_instantiate(sky_path):
				sky_resource = ClassDB.instantiate(sky_path)
			if sky_resource is Material:
				var wrapped := Sky.new()
				wrapped.sky_material = sky_resource
				sky_resource = wrapped
			if sky_path.begins_with("res://") and not ResourceLoader.exists(sky_path):
				_refused_values.append("sky.path %s does not exist; pass a sky material class like ProceduralSkyMaterial instead" % sky_path)
			elif not sky_resource is Sky:
				_refused_values.append("sky.path must be a Sky or sky material file, or a sky material class like ProceduralSkyMaterial (got %s)" % sky_path)
			elif environment.sky != sky_resource:
				changes.append({
					"property": "sky",
					"previous": environment.sky,
					"value": sky_resource,
				})
				# A sky only shows with the sky background.
				var sets_background := changes.any(func(change): return str(change.get("property", "")) == "background_mode")
				if environment.background_mode != Environment.BG_SKY and not sets_background:
					_append_environment_change(environment, "background_mode", Environment.BG_SKY, changes)
		var sky_map := {
			"custom_fov": "sky_custom_fov",
			"rotation": "sky_rotation",
			"energy": "background_energy_multiplier",  # Godot 4 has no sky_energy
		}
		_merge_environment_section_changes(environment, sky_map, sky, changes)

	return changes

func _merge_environment_section_changes(environment: Environment, property_map: Dictionary, values: Dictionary, changes: Array) -> void:
	for key in property_map.keys():
		if values.has(key):
			_append_environment_change(environment, property_map[key], values[key], changes)

func _append_environment_change(environment: Environment, property_name: String, raw_value, changes: Array) -> void:
	if _get_property_info(environment, property_name).is_empty():
		_refused_values.append("Environment has no property %s" % property_name)
		return
	# Two inputs can map to one property (fog.color and sun.color are both fog_light_color);
	# the later one silently won before.
	for existing_change in changes:
		if str(existing_change.get("property", "")) == property_name:
			_refused_values.append("%s is set twice in this call (e.g. fog.color and sun.color both map to it)" % property_name)
			return
	var previous = environment.get(property_name)
	# Coerce JSON input ("#hex", {"r":..}, {"sky_material": {...}}) to the property's declared type, not the
	# current value's: an empty sky is null, so a new Sky was refused. != between mismatched types errors.
	var parsed: Variant = _convert_property_value(environment, property_name, raw_value)
	var value_error := _property_value_error(environment, property_name, parsed)
	if not value_error.is_empty():
		_refused_values.append(value_error)
		return
	if typeof(previous) == typeof(parsed) and previous == parsed:
		return
	changes.append({
		"property": property_name,
		"previous": previous,
		"value": parsed,
	})

func _resolve_environment(params: Dictionary) -> Dictionary:
	var environment_path := params.get("environment_path", "")
	var node_path := params.get("world_environment", params.get("node_path", ""))
	var result := {
		"environment": null,
		"environment_path": environment_path,
		"node_path": node_path,
		"error_message": "Unable to resolve Environment resource",
	}

	if environment_path != "":
		var loaded = ResourceUtils.safe_load(environment_path)
		if loaded is Environment:
			result["environment"] = loaded
			# Both given: the file was edited but never assigned to the node ("no_change"). Assign it.
			if node_path != "":
				var target = _get_editor_node(node_path)
				if not (target is WorldEnvironment):
					result["environment"] = null
					result["error_message"] = ("Node at %s is %s, not a WorldEnvironment" % [node_path, target.get_class()]) if target else ("WorldEnvironment node not found: %s" % node_path)
					return result
				if target.environment != loaded:
					result["assign_to"] = target
			return result
		result["error_message"] = ("Resource at %s is not an Environment" % environment_path) if loaded != null else ("Environment resource not found or not loadable: %s" % environment_path)
		return result

	if node_path != "":
		var node = _get_editor_node(node_path)
		if node and node is WorldEnvironment:
			var world_env: WorldEnvironment = node
			result["environment"] = world_env.environment
			if world_env.environment != null:
				result["environment_path"] = world_env.environment.resource_path
			result["node_path"] = node_path
			if result.get("environment") == null:
				# A fresh WorldEnvironment has none and no tool could create one: make it here.
				result["environment"] = Environment.new()
				result["assign_to"] = world_env
				result["created_environment"] = true
			return result
		result["error_message"] = ("Node at %s is %s, not a WorldEnvironment" % [node_path, node.get_class()]) if node else ("WorldEnvironment node not found: %s" % node_path)
		return result

	return result


# A transform for a new child of parent that puts it exactly where planet is. Copying the planet's
# local transform misplaced layers created under a different parent.
func _local_transform_matching(planet: Node3D, parent: Node) -> Transform3D:
	if parent is Node3D:
		return (parent as Node3D).global_transform.affine_inverse() * planet.global_transform
	return planet.global_transform


const CLOUD_SHADER_CODE := """
shader_type spatial;
render_mode blend_mix, cull_back, unshaded, depth_draw_opaque;

uniform vec4 cloud_color : source_color = vec4(0.95, 0.97, 1.0, 1.0);
uniform float cloud_density = 0.45;
uniform float cloud_scale = 2.4;
uniform float cloud_speed = 0.05;
uniform float cloud_alpha = 0.6;

float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash31(i + vec3(0.0, 0.0, 0.0));
	float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash31(i + vec3(1.0, 1.0, 1.0));
	float nx00 = mix(n000, n100, f.x);
	float nx10 = mix(n010, n110, f.x);
	float nx01 = mix(n001, n101, f.x);
	float nx11 = mix(n011, n111, f.x);
	float nxy0 = mix(nx00, nx10, f.y);
	float nxy1 = mix(nx01, nx11, f.y);
	return mix(nxy0, nxy1, f.z);
}

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec3 p = normalize(local_pos) * cloud_scale;
	float t = TIME * cloud_speed;
	float n = noise3(p + vec3(t, t * 0.7, -t * 0.45));
	float cloud = smoothstep(1.0 - cloud_density, 1.0, n);
	ALBEDO = cloud_color.rgb;
	EMISSION = cloud_color.rgb * 0.05;
	ALPHA = cloud * cloud_alpha;
}
"""


func _cloud_shader_material(color: Color, density: float, scale: float, speed: float, alpha: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = CLOUD_SHADER_CODE
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("cloud_color", color)
	material.set_shader_parameter("cloud_density", density)
	material.set_shader_parameter("cloud_scale", scale)
	material.set_shader_parameter("cloud_speed", speed)
	material.set_shader_parameter("cloud_alpha", alpha)
	return material
