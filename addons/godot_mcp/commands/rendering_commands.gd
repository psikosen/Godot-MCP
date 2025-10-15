@tool
class_name MCPRenderingCommands
extends MCPBaseCommandProcessor

const LOG_FILENAME := "addons/godot_mcp/commands/rendering_commands.gd"
const DEFAULT_SYSTEM_SECTION := "rendering_commands"

const SceneTransactionManager := MCPSceneTransactionManager

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
	print("[Continuous skepticism (Sherlock Protocol)]", message)

func _generate_material_variant(client_id: int, params: Dictionary, command_id: String) -> void:
	var source_path := params.get("source_material", "")
	var overrides := params.get("overrides", {})
	var shader_parameters := params.get("shader_parameters", {})
	var texture_overrides := params.get("texture_overrides", {})
	var save_path := params.get("save_path", "")
	var resource_name := params.get("resource_name", "")
	var metadata := params.get("metadata", {})

	if source_path.is_empty():
		_log("source_material is required", "_generate_material_variant", {"system_section": "material", "line_num": __LINE__}, true)
		return _send_error(client_id, "source_material is required", command_id)

	var source_resource := ResourceUtils.safe_load(source_path)
	if source_resource == null or not (source_resource is Material):
		_log("Failed to load source material", "_generate_material_variant", {
			"system_section": "material",
			"line_num": __LINE__,
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
			var parsed_value = _parse_property_value(overrides[property_name])
			var previous_value = variant.get(property_name)
			if previous_value != parsed_value:
				variant.set(property_name, parsed_value)
				changes.append({
					"type": "property",
					"property": property_name,
					"previous": previous_value,
					"value": parsed_value,
				})

	if typeof(shader_parameters) == TYPE_DICTIONARY and variant is ShaderMaterial:
		var shader_material: ShaderMaterial = variant
		for parameter_name in shader_parameters.keys():
			var parsed = _parse_property_value(shader_parameters[parameter_name])
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

			if texture != null and variant.has_method("set"):
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
				"line_num": __LINE__,
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

	var shader: Shader = null
	if shader_code != "":
		shader = Shader.new()
		shader.code = shader_code
	elif shader_path != "":
		var loaded = ResourceUtils.safe_load(shader_path)
		if loaded is Shader:
			shader = loaded
			shader_code = shader.code
	if shader == null:
		_log("shader_code or shader_path is required", "_compile_shader_preview", {"system_section": "shader", "line_num": __LINE__}, true)
		return _send_error(client_id, "Provide shader_code or shader_path", command_id)

	var uniform_list := []
	for uniform_dict in shader.get_shader_uniform_list(true):
		if typeof(uniform_dict) == TYPE_DICTIONARY:
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
				"line_num": __LINE__,
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
				"line_num": __LINE__,
				"node_path": node_path,
			}, true)
			return _send_error(client_id, "Node at %s is not a MeshInstance3D" % node_path, command_id)
	else:
		_log("mesh_path or node_path required", "_unwrap_lightmap_uv2", {"system_section": "uv2", "line_num": __LINE__}, true)
		return _send_error(client_id, "Provide mesh_path or node_path", command_id)

	if mesh == null:
		return _send_error(client_id, "Mesh could not be resolved", command_id)

	var array_mesh: ArrayMesh = null
	if mesh is ArrayMesh:
		array_mesh = mesh
	else:
		array_mesh = ArrayMesh.new()
		for surface_index in mesh.get_surface_count():
			var arrays = mesh.surface_get_arrays(surface_index)
			var blend_shapes = mesh.surface_get_blend_shape_arrays(surface_index)
			array_mesh.add_surface_from_arrays(mesh.surface_get_primitive_type(surface_index), arrays, blend_shapes)

	var unwrap_result = array_mesh.lightmap_unwrap(transform, texel_size)
	if unwrap_result != OK:
		_log("ArrayMesh.lightmap_unwrap failed", "_unwrap_lightmap_uv2", {
			"system_section": "uv2",
			"line_num": __LINE__,
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
				"line_num": __LINE__,
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

func _generate_lod_mesh(mesh: Mesh, ratio: float) -> ArrayMesh:
	var result := ArrayMesh.new()
	for surface_index in mesh.get_surface_count():
		var arrays: Array = mesh.surface_get_arrays(surface_index)
		if arrays.is_empty():
			continue
		var primitive := mesh.surface_get_primitive_type(surface_index)
		var new_arrays := _decimate_surface_arrays(arrays, ratio)
		result.add_surface_from_arrays(primitive, new_arrays, mesh.surface_get_blend_shape_arrays(surface_index))
	return result

func _decimate_surface_arrays(arrays: Array, ratio: float) -> Array:
	var new_arrays := arrays.duplicate(true)
	var vertices: PackedVector3Array = new_arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = new_arrays[Mesh.ARRAY_NORMAL]
	var tangents: PackedFloat32Array = new_arrays[Mesh.ARRAY_TANGENT]
	var colors: PackedColorArray = new_arrays[Mesh.ARRAY_COLOR]
	var uv: PackedVector2Array = new_arrays[Mesh.ARRAY_TEX_UV]
	var uv2: PackedVector2Array = new_arrays[Mesh.ARRAY_TEX_UV2]
	var bones: PackedInt32Array = new_arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = new_arrays[Mesh.ARRAY_WEIGHTS]
	var indices: PackedInt32Array = new_arrays[Mesh.ARRAY_INDEX]

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
	if changes.is_empty():
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

	for change in changes:
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
		"status": transaction_id == "" ? "committed" : "pending",
	}, command_id)

func _preview_environment_sun_settings(client_id: int, params: Dictionary, command_id: String) -> void:
	var resolve: Dictionary = _resolve_environment(params)
	var environment: Environment = resolve.get("environment")
	if environment == null:
		return _send_error(client_id, resolve.get("error_message", "Unable to resolve Environment resource"), command_id)

	var environment_path: String = resolve.get("environment_path", "")
	var node_path: String = resolve.get("node_path", "")
	var overrides := params.get("sun", {})
	var preview := {
		"fog_sun_color": environment.get("fog_sun_color"),
		"fog_sun_amount": environment.get("fog_sun_amount"),
		"fog_sun_scatter": environment.get("fog_sun_scatter"),
	}

	if typeof(overrides) == TYPE_DICTIONARY:
		for key in overrides.keys():
			var property_name := ""
			match key:
				"color":
					property_name = "fog_sun_color"
				"amount":
					property_name = "fog_sun_amount"
				"scatter":
					property_name = "fog_sun_scatter"
				_:
					if key is String:
						property_name = key
			if property_name != "":
				preview[property_name] = _parse_property_value(overrides[key])

	var apply_changes := params.get("apply", false)
	if apply_changes:
		var apply_params := params.duplicate(true)
		apply_params["sun"] = overrides
		_configure_environment(client_id, apply_params, command_id)
		return

	_send_success(client_id, {
		"environment_path": environment_path,
		"node_path": node_path,
		"current": {
			"fog_sun_color": environment.get("fog_sun_color"),
			"fog_sun_amount": environment.get("fog_sun_amount"),
			"fog_sun_scatter": environment.get("fog_sun_scatter"),
		},
		"preview": preview,
	}, command_id)

func _collect_environment_changes(environment: Environment, params: Dictionary) -> Array:
	var changes: Array = []

	var direct_properties := params.get("properties", {})
	if typeof(direct_properties) == TYPE_DICTIONARY:
		for property_name in direct_properties.keys():
			var parsed = _parse_property_value(direct_properties[property_name])
			var previous = environment.get(property_name)
			if previous != parsed:
				changes.append({
					"property": property_name,
					"previous": previous,
					"value": parsed,
				})

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
			"color": "fog_color",
			"density": "fog_density",
			"height": "fog_height",
			"height_range": "fog_height_max",
			"sun_color": "fog_sun_color",
			"sun_amount": "fog_sun_amount",
			"sun_scatter": "fog_sun_scatter",
		}
		_merge_environment_section_changes(environment, fog_map, fog, changes)

	var sun := params.get("sun", {})
	if typeof(sun) == TYPE_DICTIONARY:
		var sun_map := {
			"color": "fog_sun_color",
			"amount": "fog_sun_amount",
			"scatter": "fog_sun_scatter",
		}
		_merge_environment_section_changes(environment, sun_map, sun, changes)

	var sky := params.get("sky", {})
	if typeof(sky) == TYPE_DICTIONARY:
		if sky.has("path") and typeof(sky["path"]) == TYPE_STRING:
			var sky_resource = ResourceUtils.safe_load(sky["path"])
			if sky_resource is Sky:
				var previous_sky = environment.sky
				if previous_sky != sky_resource:
					changes.append({
						"property": "sky",
						"previous": previous_sky,
						"value": sky_resource,
					})
		var sky_map := {
			"custom_fov": "sky_custom_fov",
			"rotation": "sky_rotation",
			"energy": "sky_energy",
		}
		_merge_environment_section_changes(environment, sky_map, sky, changes)

	return changes

func _merge_environment_section_changes(environment: Environment, property_map: Dictionary, values: Dictionary, changes: Array) -> void:
	for key in property_map.keys():
			if values.has(key):
				var property_name: String = property_map[key]
				var parsed = _parse_property_value(values[key])
				var previous = environment.get(property_name)
				if previous != parsed:
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
			return result
		result["error_message"] = "Resource at %s is not an Environment" % environment_path
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
				result["error_message"] = "WorldEnvironment at %s has no Environment resource" % node_path
			return result
		result["error_message"] = "Node at %s is not a WorldEnvironment" % node_path
		return result

	return result
