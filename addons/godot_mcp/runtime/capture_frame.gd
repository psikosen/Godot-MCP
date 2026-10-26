extends SceneTree
## Runs a scene in a real window for some frames, optionally holding input actions, then saves the
## last frame as a PNG. Started by the MCP server's capture_game_frame tool:
##   godot --path <project> --script res://addons/godot_mcp/runtime/capture_frame.gd -- <scene> <frames> <png> [action:from:to ...]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		printerr("capture_frame: expected <scene> <frames> <png> [action:from:to ...]")
		quit(2)
		return
	var packed := load(args[0]) as PackedScene
	if packed == null:
		printerr("capture_frame: cannot load scene %s" % args[0])
		quit(2)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene

	var holds: Array = []
	for spec in args.slice(3):
		var parts: PackedStringArray = spec.split(":")
		if parts.size() == 3 and InputMap.has_action(parts[0]):
			holds.append([parts[0], int(parts[1]), int(parts[2])])
		else:
			printerr("capture_frame: ignoring %s (unknown action or not action:from:to)" % spec)
	for frame in range(int(args[1])):
		for hold in holds:
			if frame == hold[1]:
				Input.action_press(hold[0])
			if frame == hold[2]:
				Input.action_release(hold[0])
		await physics_frame
	await RenderingServer.frame_post_draw
	var err := root.get_texture().get_image().save_png(args[2])
	quit(0 if err == OK else 1)
