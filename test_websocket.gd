@tool
extends EditorScript

func _run():
	print("\n=== Testing WebSocket Server ===")
	
	# Try to get the plugin instance
	var editor_interface = get_editor_interface()
	if not editor_interface:
		print("ERROR: Could not get editor interface")
		return
		
	# Check if MCP plugin is active
	if Engine.has_meta("GodotMCPPlugin"):
		var plugin = Engine.get_meta("GodotMCPPlugin")
		print("Found MCP Plugin instance")
		
		if plugin.has_method("is_server_active"):
			var active = plugin.is_server_active()
			print("Server active: ", active)
		
		if plugin.has_method("get_port"):
			var port = plugin.get_port()
			print("Server port: ", port)
	else:
		print("MCP Plugin not found in Engine metadata")
		print("This suggests the plugin is not properly initialized")
		
	# Check if plugin is in enabled plugins list
	var settings = editor_interface.get_editor_settings()
	print("\nPlugin should be at: res://addons/godot_mcp/plugin.cfg")
	
	# Try to manually start the server
	print("\nAttempting to manually initialize the MCP server...")
	var mcp_script = load("res://addons/godot_mcp/mcp_server.gd")
	if mcp_script:
		print("MCP script loaded successfully")
	else:
		print("ERROR: Could not load MCP script")
	
	print("=== Test Complete ===\n")
