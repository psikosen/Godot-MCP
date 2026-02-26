@tool
extends Node

# Autoload script to ensure MCP WebSocket server starts
# This runs regardless of whether we're in editor or game mode

var mcp_plugin = null
var server_check_timer: Timer = null
var startup_attempts = 0
const MAX_STARTUP_ATTEMPTS = 10

func _ready():
	print("\n=== MCP Autoload Starting ===")
	
	# Only run in editor mode
	if not Engine.is_editor_hint():
		print("Not in editor mode, skipping MCP server start")
		return
	
	# Start checking for the plugin
	server_check_timer = Timer.new()
	server_check_timer.wait_time = 0.5
	server_check_timer.one_shot = false
	server_check_timer.timeout.connect(_check_and_start_server)
	add_child(server_check_timer)
	server_check_timer.start()
	
	print("Started MCP server check timer")

func _check_and_start_server():
	startup_attempts += 1
	
	# Try to get existing plugin instance from Engine metadata
	if Engine.has_meta("GodotMCPPlugin"):
		mcp_plugin = Engine.get_meta("GodotMCPPlugin")
		
		if mcp_plugin and mcp_plugin.has_method("is_server_active"):
			if mcp_plugin.is_server_active():
				print("✓ MCP WebSocket server is active on port ", mcp_plugin.get_port())
				server_check_timer.stop()
				server_check_timer.queue_free()
				print("=== MCP Autoload Complete ===\n")
				return
			else:
				print("Found MCP plugin but server not active, attempting restart...")
				if mcp_plugin.has_method("_enter_tree"):
					mcp_plugin._enter_tree()
	else:
		# Plugin not loaded yet, try to load it manually
		print("MCP plugin not found in Engine metadata (attempt ", startup_attempts, "/", MAX_STARTUP_ATTEMPTS, ")")
		
		if startup_attempts > 3:
			# After a few attempts, try to load the plugin manually
			_load_plugin_manually()
	
	# Stop trying after max attempts
	if startup_attempts >= MAX_STARTUP_ATTEMPTS:
		printerr("✗ Failed to start MCP server after ", MAX_STARTUP_ATTEMPTS, " attempts")
		printerr("Please enable the 'Godot MCP' plugin manually in Project Settings > Plugins")
		server_check_timer.stop()
		server_check_timer.queue_free()

func _load_plugin_manually():
	print("Attempting to load MCP plugin manually...")
	
	var plugin_script = load("res://addons/godot_mcp/mcp_server.gd")
	if not plugin_script:
		printerr("✗ Failed to load plugin script")
		return
	
	print("Loaded plugin script successfully")
	
	# Check if plugin is already instantiated
	if Engine.has_meta("GodotMCPPlugin"):
		return
	
	var plugin_instance = plugin_script.new()
	if not plugin_instance:
		printerr("✗ Failed to create plugin instance")
		return
	
	print("Created plugin instance")
	
	# Store it in Engine metadata
	Engine.set_meta("GodotMCPPlugin", plugin_instance)
	
	# Add to scene tree
	get_tree().root.add_child(plugin_instance)
	
	# Initialize
	if plugin_instance.has_method("_enter_tree"):
		plugin_instance._enter_tree()
		print("Initialized plugin manually")
	
	mcp_plugin = plugin_instance
