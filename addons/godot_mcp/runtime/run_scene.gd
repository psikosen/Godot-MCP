extends SceneTree
## Runs a scene in a real window for some frames, optionally holding input actions, then saves the
## last frame as a PNG and/or prints performance numbers. Started by the MCP server's
## capture_game_frame and profile_game tools:
##   godot --path <project> --script res://addons/godot_mcp/runtime/run_scene.gd -- <scene> <frames> <png or -> [--profile] [action:from:to ...]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := Array(OS.get_cmdline_user_args())
	var profile := args.has("--profile")
	args.erase("--profile")
	if args.size() < 3:
		printerr("run_scene: expected <scene> <frames> <png or -> [--profile] [action:from:to ...]")
		quit(2)
		return
	var packed := load(args[0]) as PackedScene
	if packed == null:
		printerr("run_scene: cannot load scene %s" % args[0])
		quit(2)
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene

	var holds: Array = []
	for spec in args.slice(3):
		var parts: PackedStringArray = str(spec).split(":")
		if parts.size() == 3 and InputMap.has_action(parts[0]):
			holds.append([parts[0], int(parts[1]), int(parts[2])])
		else:
			printerr("run_scene: ignoring %s (unknown action or not action:from:to)" % spec)
	var samples := {"frame_ms": [], "physics_ms": [], "draw_calls": [], "objects": [], "nodes": []}
	# The first frames load the scene and compile shaders; they would swamp the averages.
	var warmup := mini(30, int(args[1]) / 4)
	for frame in range(int(args[1])):
		for hold in holds:
			if frame == hold[1]:
				Input.action_press(hold[0])
			if frame == hold[2]:
				Input.action_release(hold[0])
		# Count physics steps (fixed 1/60 s), not drawn frames: a window can draw hundreds of frames a
		# second, so held actions lasted a blink and the player barely moved.
		await physics_frame
		if profile and frame >= warmup:
			samples["frame_ms"].append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
			samples["physics_ms"].append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
			samples["draw_calls"].append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			samples["objects"].append(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
			samples["nodes"].append(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	await RenderingServer.frame_post_draw
	if profile:
		var report := {"fps": Performance.get_monitor(Performance.TIME_FPS),
			"memory_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, 0.1)}
		for key in samples:
			var values: Array = samples[key]
			if not values.is_empty():
				report[key] = {"avg": snappedf(values.reduce(func(a, b): return a + b, 0.0) / values.size(), 0.01), "max": snappedf(values.max(), 0.01)}
		print("PROFILE_RESULT " + JSON.stringify(report))
	var err := OK
	if args[2] != "-":
		err = root.get_texture().get_image().save_png(args[2])
	quit(0 if err == OK else 1)
