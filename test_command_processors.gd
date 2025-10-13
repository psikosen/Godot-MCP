@tool
extends EditorScript

# Test script to identify which command processor is causing issues
# Run this from Godot Editor: File -> Run Script

func _run():
	print("\n=== COMMAND PROCESSOR TEST ===")
	print("Testing each command processor individually...\n")
	
	var processors = [
		{"name": "MCPNodeCommands", "class": MCPNodeCommands},
		{"name": "MCPScriptCommands", "class": MCPScriptCommands},
		{"name": "MCPSceneCommands", "class": MCPSceneCommands},
		{"name": "MCPProjectCommands", "class": MCPProjectCommands},
		{"name": "MCPEditorCommands", "class": MCPEditorCommands},
		{"name": "MCPEditorScriptCommands", "class": MCPEditorScriptCommands},
		{"name": "MCPNavigationCommands", "class": MCPNavigationCommands},
		{"name": "MCPAnimationCommands", "class": MCPAnimationCommands},
		{"name": "MCPXRCommands", "class": MCPXRCommands},
		{"name": "MCPMultiplayerCommands", "class": MCPMultiplayerCommands},
		{"name": "MCPCompressionCommands", "class": MCPCompressionCommands},
		{"name": "MCPRenderingCommands", "class": MCPRenderingCommands},
	]
	
	var failed = []
	var passed = []
	
	for processor_info in processors:
		var name = processor_info["name"]
		var processor_class = processor_info["class"]
		
		print("Testing %s..." % name)
		
		var instance = null
		var error_occurred = false
		
		# Try to instantiate
		if processor_class == null:
			print("  ✗ FAILED: Class not found!")
			failed.append({"name": name, "error": "Class not found"})
			error_occurred = true
		else:
			instance = processor_class.new()
			
			if instance == null:
				print("  ✗ FAILED: Could not instantiate!")
				failed.append({"name": name, "error": "Could not instantiate"})
				error_occurred = true
			else:
				# Check if it has the required method
				if not instance.has_method("process_command"):
					print("  ✗ FAILED: Missing process_command method!")
					failed.append({"name": name, "error": "Missing process_command method"})
					error_occurred = true
				else:
					print("  ✓ PASSED")
					passed.append(name)
				
				# Clean up
				instance.free()
		
		print("")
	
	# Print summary
	print("\n=== TEST SUMMARY ===")
	print("Passed: %d/%d" % [passed.size(), processors.size()])
	print("Failed: %d/%d" % [failed.size(), processors.size()])
	
	if passed.size() > 0:
		print("\n✓ Working processors:")
		for name in passed:
			print("  - %s" % name)
	
	if failed.size() > 0:
		print("\n✗ Failed processors:")
		for fail_info in failed:
			print("  - %s: %s" % [fail_info["name"], fail_info["error"]])
	
	if failed.size() == 0:
		print("\n🎉 All command processors loaded successfully!")
	else:
		print("\n⚠️  Some command processors failed to load.")
		print("Fix these issues before enabling the plugin.")
	
	print("\n=== TEST COMPLETE ===\n")
