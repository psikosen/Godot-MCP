extends SceneTree

# Headless check: script commands stay inside res:// and create_script won't overwrite by default.
# Run from the repo root: godot --headless --path . --script res://test_script_path_guard.gd
# Exit code 0 = all checks passed.

const TMP_DIR := "res://.mcp_path_guard_test"

var _last: Dictionary = {}
var _failures := 0


func _init() -> void:
	var cmds = load("res://addons/godot_mcp/commands/script_commands.gd").new()
	cmds.command_completed.connect(_on_completed)

	_check(cmds._contained_res_path("scripts/player.gd") == "res://scripts/player.gd", "relative path gets res:// prefix")
	_check(cmds._contained_res_path("res://scripts/../player.gd") == "res://player.gd", "inner .. is simplified")
	_check(cmds._contained_res_path("res:///abs.gd") == "res://abs.gd", "extra slash stays inside res://")

	var outside := ProjectSettings.globalize_path("res://").path_join("../mcp_escape_test.gd").simplify_path()
	for escape_path in ["res://../mcp_escape_test.gd", "res://a/../../mcp_escape_test.gd", "../mcp_escape_test", "res://..\\mcp_escape_test.gd"]:
		_run(cmds, "create_script", {"script_path": escape_path, "content": "extends Node"})
		_expect_error("stay inside the project", "create_script rejects %s" % escape_path)
	_check(not FileAccess.file_exists(outside), "no file was written outside the project")

	_run(cmds, "get_script", {"script_path": "res://../mcp_escape_test.gd"})
	_expect_error("stay inside the project", "get_script rejects paths outside res://")
	_run(cmds, "edit_script", {"script_path": "res://../mcp_escape_test.gd", "content": "x"})
	_expect_error("stay inside the project", "edit_script rejects paths outside res://")
	_run(cmds, "edit_script", {"script_path": "res://project-manager/permission_escalations.json", "content": "{}"})
	_expect_error(".gd files", "edit_script refuses non-.gd files")

	DirAccess.make_dir_recursive_absolute(TMP_DIR)
	var existing := TMP_DIR.path_join("existing.gd")
	var f := FileAccess.open(existing, FileAccess.WRITE)
	f.store_string("original")
	f = null

	_run(cmds, "create_script", {"script_path": existing, "content": "replaced"})
	_expect_error("already exists", "create_script refuses to overwrite by default")
	_check(FileAccess.get_file_as_string(existing) == "original", "existing file is unchanged")

	# With overwrite=true the guard passes; headless has no editor plugin, so the next step fails instead.
	_run(cmds, "create_script", {"script_path": existing, "content": "replaced", "overwrite": true})
	_check(_last.get("status") == "error" and not str(_last.get("result", {}).get("error", "")).contains("already exists"),
		"overwrite=true skips the exists check")

	DirAccess.remove_absolute(existing)
	DirAccess.remove_absolute(TMP_DIR)
	cmds.free()

	print("script path guard: %s" % ("PASS" if _failures == 0 else "%d FAILED" % _failures))
	quit(1 if _failures > 0 else 0)


func _on_completed(_client_id, status, result, _command_id) -> void:
	_last = {"status": status, "result": result}


func _run(cmds, command: String, params: Dictionary) -> void:
	_last = {}
	cmds.process_command(0, command, params, "")


func _expect_error(fragment: String, label: String) -> void:
	var message := str(_last.get("result", {}).get("error", ""))
	_check(_last.get("status") == "error" and message.contains(fragment), "%s (got: %s)" % [label, message])


func _check(ok: bool, label: String) -> void:
	if not ok:
		_failures += 1
	print("%s %s" % ["ok  " if ok else "FAIL", label])
