@tool
class_name MCPScriptCommands
extends "res://addons/godot_mcp/commands/base_command_processor.gd"

func process_command(client_id: int, command_type: String, params: Dictionary, command_id: String) -> bool:
	match command_type:
		"create_script":
			_create_script(client_id, params, command_id)
			return true
		"edit_script":
			_edit_script(client_id, params, command_id)
			return true
		"get_script":
			_get_script(client_id, params, command_id)
			return true
		"get_script_metadata":
			_get_script_metadata(client_id, params, command_id)
			return true
		"get_current_script":
			_get_current_script(client_id, params, command_id)
			return true
		"create_script_template":
			_create_script_template(client_id, params, command_id)
			return true
	return false  # Command not handled

func _create_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var script_path = params.get("script_path", "")
	var content = params.get("content", "")
	var node_path = params.get("node_path", "")
	
	var overwrite: bool = params.get("overwrite", false)
	
	# Validation
	if script_path.is_empty():
		return _send_error(client_id, "Script path cannot be empty", command_id)
	
	# Bare names get .gd; an explicit other extension is refused rather than becoming "x.txt.gd".
	if script_path.get_extension().is_empty():
		script_path += ".gd"
	elif script_path.get_extension() != "gd":
		return _send_error(client_id, "create_script only creates .gd files: %s" % script_path, command_id)
	
	var requested_path: String = script_path
	script_path = _contained_res_path(script_path)
	if script_path.is_empty():
		return _send_error(client_id, "Script path must stay inside the project (res://): %s" % requested_path, command_id)
	if _is_protected_path(script_path):
		return _send_error(client_id, "%s belongs to the Godot MCP addon and cannot be changed by tools" % script_path, command_id)
	
	var replaced := FileAccess.file_exists(script_path)
	if replaced and not overwrite:
		return _send_error(client_id, "Script already exists: %s (pass overwrite=true to replace it)" % script_path, command_id)
	
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var script_editor = editor_interface.get_script_editor()
	
	# Resolve the target node before writing anything so a bad node_path leaves no stray file.
	var node: Node = null
	if not node_path.is_empty():
		node = _get_editor_node(node_path)
		if not node:
			return _send_error(client_id, "Node not found: %s" % node_path, command_id)
	
	# Create the directory if it doesn't exist
	var dir = script_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			return _send_error(client_id, "Failed to create directory: %s (Error code: %d)" % [dir, err], command_id)
	
	# Create the script file
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file == null:
		return _send_error(client_id, "Failed to create script file: %s" % script_path, command_id)
	
	file.store_string(content)
	file = null  # Close the file
	
	# Refresh the filesystem
	editor_interface.get_resource_filesystem().scan()
	
	var compile_error := _gdscript_compile_error(script_path) if script_path.ends_with(".gd") else ""
	if not compile_error.is_empty():
		return _send_error(client_id, "Script saved to %s but it does not compile%s: %s. Fix it with edit_script." % [
			script_path, " (not attached to %s)" % node_path if node else "", compile_error], command_id)
	
	# Attach the script to a node if specified
	if node:
		# Wait for script to be recognized in the filesystem
		await get_tree().create_timer(0.5).timeout
		
		var script = load(script_path)
		if not script:
			return _send_error(client_id, "Failed to load script: %s" % script_path, command_id)
		
		# Use undo/redo for script assignment
		var undo_redo = _get_undo_redo()
		if not undo_redo:
			# Fallback method if we can't get undo/redo
			node.set_script(script)
			_mark_scene_modified()
		else:
			# Use undo/redo for proper editor integration
			undo_redo.create_action("Assign Script")
			undo_redo.add_do_method(node, "set_script", script)
			undo_redo.add_undo_method(node, "set_script", node.get_script())
			undo_redo.commit_action()
		
		# Mark the scene as modified
		_mark_scene_modified()
	
	# Open the script in the editor
	var script_resource = load(script_path)
	if script_resource:
		editor_interface.edit_script(script_resource)
	
	_send_success(client_id, {
		"script_path": script_path,
		"replaced": replaced,
		"node_path": node_path
	}, command_id)

func _edit_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var script_path = params.get("script_path", "")
	var content = params.get("content", "")
	
	# Validation
	if script_path.is_empty():
		return _send_error(client_id, "Script path cannot be empty", command_id)
	
	if content.is_empty():
		return _send_error(client_id, "Content cannot be empty", command_id)
	
	# Only .gd files: this tool must not rewrite arbitrary project files
	# (e.g. project-manager/permission_escalations.json, which holds human approvals).
	if not script_path.ends_with(".gd"):
		return _send_error(client_id, "edit_script only edits .gd files: %s" % script_path, command_id)
	
	var requested_path: String = script_path
	script_path = _contained_res_path(script_path)
	if script_path.is_empty():
		return _send_error(client_id, "Script path must stay inside the project (res://): %s" % requested_path, command_id)
	if _is_protected_path(script_path):
		return _send_error(client_id, "%s belongs to the Godot MCP addon and cannot be changed by tools" % script_path, command_id)
	
	# Check if the file exists
	if not FileAccess.file_exists(script_path):
		return _send_error(client_id, "Script file not found: %s" % script_path, command_id)
	
	# Edit the script file
	var file = FileAccess.open(script_path, FileAccess.WRITE)
	if file == null:
		return _send_error(client_id, "Failed to open script file: %s" % script_path, command_id)
	
	file.store_string(content)
	file = null  # Close the file
	
	var compile_error := _gdscript_compile_error(script_path)
	if not compile_error.is_empty():
		return _send_error(client_id, "Script saved to %s but it does not compile: %s" % [script_path, compile_error], command_id)
	
	_send_success(client_id, {
		"script_path": script_path
	}, command_id)

func _get_script(client_id: int, params: Dictionary, command_id: String) -> void:
	var script_path = params.get("script_path", "")
	var node_path = params.get("node_path", "")
	
	# Validation - either script_path or node_path must be provided
	if script_path.is_empty() and node_path.is_empty():
		return _send_error(client_id, "Either script_path or node_path must be provided", command_id)
	
	if not script_path.is_empty() and not node_path.is_empty():
		return _send_error(client_id, "Provide either script_path or node_path, not both", command_id)
	
	# If node_path is provided, get the script from the node
	if not node_path.is_empty():
		var node = _get_editor_node(node_path)
		if not node:
			return _send_error(client_id, "Node not found: %s" % node_path, command_id)
		
		var script = node.get_script()
		if not script:
			return _send_error(client_id, "Node does not have a script: %s" % node_path, command_id)
		
		script_path = script.resource_path
	
	var requested_path: String = script_path
	script_path = _contained_res_path(script_path)
	if script_path.is_empty():
		return _send_error(client_id, "Script path must stay inside the project (res://): %s" % requested_path, command_id)
	
	# Check if the file exists
	if not FileAccess.file_exists(script_path):
		return _send_error(client_id, "Script file not found: %s" % script_path, command_id)
	
	# Read the script file
	var file = FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		return _send_error(client_id, "Failed to open script file: %s" % script_path, command_id)
	
	var content = file.get_as_text()
	file = null  # Close the file
	
	_send_success(client_id, {
		"script_path": script_path,
		"content": content
	}, command_id)

func _get_script_metadata(client_id: int, params: Dictionary, command_id: String) -> void:
	var path: String = params.get("path", "")
	
	# Validation
	if path.is_empty():
		return _send_error(client_id, "Script path cannot be empty", command_id)
	
	var requested_path: String = path
	path = _contained_res_path(path)
	if path.is_empty():
		return _send_error(client_id, "Script path must stay inside the project (res://): %s" % requested_path, command_id)
	
	if not FileAccess.file_exists(path):
		return _send_error(client_id, "Script file not found: " + path, command_id)
	
	# Load the script
	var script = load(path)
	if not script:
		return _send_error(client_id, "Failed to load script: " + path, command_id)
	
	# Extract script metadata
	var metadata := {
		"path": path,
		"language": "gdscript" if path.ends_with(".gd") else ("csharp" if path.ends_with(".cs") else "unknown")
	}
	
	# Attempt to get script class info
	var class_name_str = ""
	var extends_class = ""
	
	# Read the file to extract class_name and extends info
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		
		# Extract class_name
		var class_regex = RegEx.new()
		class_regex.compile("class_name\\s+([a-zA-Z_][a-zA-Z0-9_]*)")
		var result = class_regex.search(content)
		if result:
			class_name_str = result.get_string(1)
		
		# Extract extends
		var extends_regex = RegEx.new()
		extends_regex.compile("extends\\s+([a-zA-Z_][a-zA-Z0-9_]*)")
		result = extends_regex.search(content)
		if result:
			extends_class = result.get_string(1)
		
		# Add to metadata
		metadata["class_name"] = class_name_str
		metadata["extends"] = extends_class
		
		# Try to extract methods and signals
		var methods = []
		var signals = []
		
		var method_regex = RegEx.new()
		method_regex.compile("func\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(")
		var method_matches = method_regex.search_all(content)
		
		for match_result in method_matches:
			methods.append(match_result.get_string(1))
		
		var signal_regex = RegEx.new()
		signal_regex.compile("signal\\s+([a-zA-Z_][a-zA-Z0-9_]*)")
		var signal_matches = signal_regex.search_all(content)
		
		for match_result in signal_matches:
			signals.append(match_result.get_string(1))
		
		metadata["methods"] = methods
		metadata["signals"] = signals
	
	_send_success(client_id, metadata, command_id)

func _get_current_script(client_id: int, params: Dictionary, command_id: String) -> void:
	# Get editor plugin and interfaces
	var plugin = Engine.get_meta("GodotMCPPlugin")
	if not plugin:
		return _send_error(client_id, "GodotMCPPlugin not found in Engine metadata", command_id)
	
	var editor_interface = plugin.get_editor_interface()
	var script_editor = editor_interface.get_script_editor()
	var current_script = script_editor.get_current_script()
	
	if not current_script:
		return _send_success(client_id, {
			"script_found": false,
			"message": "No script is currently being edited"
		}, command_id)
	
	var script_path = current_script.resource_path
	
	# Read the script content
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return _send_error(client_id, "Failed to open script file: %s" % script_path, command_id)
	
	var content = file.get_as_text()
	file = null  # Close the file
	
	_send_success(client_id, {
		"script_found": true,
		"script_path": script_path,
		"content": content
	}, command_id)

func _create_script_template(client_id: int, params: Dictionary, command_id: String) -> void:
	var extends_type = params.get("extends_type", "Node")
	var class_name_str = params.get("class_name", "")
	var include_ready = params.get("include_ready", true)
	var include_process = params.get("include_process", false)
	var include_physics = params.get("include_physics", false)
	var include_input = params.get("include_input", false)
	
	# Generate script content
	var content = "extends " + extends_type + "\n\n"
	
	if not class_name_str.is_empty():
		content += "class_name " + class_name_str + "\n\n"
	
	# Add variables section placeholder
	content += "# Member variables here\n\n"
	
	# Add ready function
	if include_ready:
		content += "func _ready():\n\tpass\n\n"
	
	# Add process function
	if include_process:
		content += "func _process(delta):\n\tpass\n\n"
	
	# Add physics process function
	if include_physics:
		content += "func _physics_process(delta):\n\tpass\n\n"
	
	# Add input function
	if include_input:
		content += "func _input(event):\n\tpass\n\n"
	
	_send_success(client_id, {
		"content": content
	}, command_id)
