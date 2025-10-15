@tool
extends SceneTree

func _init():
	print("=== Testing Godot MCP Plugin Load ===")
	
	# Try to load the main plugin components
	var success = true
	
	# Test loading mcp_server
	var mcp_server = load("res://addons/godot_mcp/mcp_server.gd")
	if mcp_server:
		print("✓ mcp_server.gd loaded successfully")
	else:
		print("✗ Failed to load mcp_server.gd")
		success = false
	
	# Test loading command_handler
	var command_handler = load("res://addons/godot_mcp/command_handler.gd")
	if command_handler:
		print("✓ command_handler.gd loaded successfully")
	else:
		print("✗ Failed to load command_handler.gd")
		success = false
	
	# Test loading base_command_processor
	var base_processor = load("res://addons/godot_mcp/commands/base_command_processor.gd")
	if base_processor:
		print("✓ base_command_processor.gd loaded successfully")
	else:
		print("✗ Failed to load base_command_processor.gd")
		success = false
	
	# Test loading SceneTransactionManager
	var transaction_manager = load("res://addons/godot_mcp/utils/scene_transaction_manager.gd")
	if transaction_manager:
		print("✓ scene_transaction_manager.gd loaded successfully")
	else:
		print("✗ Failed to load scene_transaction_manager.gd")
		success = false
	
	# Test loading a command processor (node_commands)
	var node_commands = load("res://addons/godot_mcp/commands/node_commands.gd")
	if node_commands:
		print("✓ node_commands.gd loaded successfully")
	else:
		print("✗ Failed to load node_commands.gd")
		success = false
	
	if success:
		print("\n=== ALL TESTS PASSED ===")
		print("The Godot MCP plugin should now load without errors!")
	else:
		print("\n=== SOME TESTS FAILED ===")
		print("There may still be issues with the plugin.")
	
	quit()
