@tool
extends EditorScript

# Manual script to force-start the MCP WebSocket server
# Run this from Script Editor: File > Run

func _run():
	print("\n=== MANUAL MCP SERVER START ===")
	
	# Try to get existing plugin instance
	var existing_plugin = Engine.get_meta("GodotMCPPlugin") if Engine.has_meta("GodotMCPPlugin") else null
	
	if existing_plugin:
		print("Found existing MCP plugin instance")
		if existing_plugin.has_method("is_server_active"):
			if existing_plugin.is_server_active():
				print("✓ Server is already active on port ", existing_plugin.get_port())
			else:
				print("✗ Server exists but is not active")
				print("Attempting to restart...")
				# Try to restart
				if existing_plugin.has_method("_enter_tree"):
					existing_plugin._enter_tree()
		else:
			print("✗ Plugin exists but doesn't have expected methods")
	else:
		print("✗ No MCP plugin instance found")
		print("Attempting to load plugin manually...")
		
		# Try to load the plugin script directly
		var plugin_script = load("res://addons/godot_mcp/mcp_server.gd")
		if plugin_script:
			print("Loaded plugin script")
			var plugin_instance = plugin_script.new()
			if plugin_instance:
				print("Created plugin instance")
				
				# Store it in Engine metadata
				Engine.set_meta("GodotMCPPlugin", plugin_instance)
				
				# Call _enter_tree to initialize
				if plugin_instance.has_method("_enter_tree"):
					plugin_instance._enter_tree()
					print("Called _enter_tree() to initialize server")
				
				# Check if server started
				if plugin_instance.has_method("is_server_active"):
					if plugin_instance.is_server_active():
						print("✓ Server successfully started!")
					else:
						print("✗ Server failed to start")
			else:
				print("✗ Failed to create plugin instance")
		else:
			print("✗ Failed to load plugin script")
	
	print("=== END MANUAL START ===\n")
