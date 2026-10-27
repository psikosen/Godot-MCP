extends Logger
## Keeps the most recent errors and warnings Godot reports (engine, script and shader errors), so
## MCP tools can show an agent what the editor's Output panel shows a person. Needs Godot 4.5+
## (the Logger class); mcp_server.gd installs it with OS.add_logger.

const MAX_ENTRIES := 200
const TYPE_NAMES: Array[String] = ["error", "warning", "script", "shader"]

var _entries: Array = []
var _next_id := 1
var _mutex := Mutex.new()


# Godot can call this from any thread, so the buffer is guarded and nothing here prints.
func _log_error(function: String, file: String, line: int, code: String, rationale: String,
		_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	var entry := {
		"type": TYPE_NAMES[clampi(error_type, 0, TYPE_NAMES.size() - 1)],
		"message": rationale if not rationale.is_empty() else code,
		"file": file,
		"line": line,
		"function": function,
	}
	_mutex.lock()
	entry["id"] = _next_id
	_next_id += 1
	_entries.append(entry)
	if _entries.size() > MAX_ENTRIES:
		_entries.pop_front()
	_mutex.unlock()


## The id the next entry will get. Entries with an id at or above a mark were logged after it.
func mark() -> int:
	_mutex.lock()
	var id := _next_id
	_mutex.unlock()
	return id


func entries_since(id: int) -> Array:
	_mutex.lock()
	var found := _entries.filter(func(entry): return entry["id"] >= id)
	_mutex.unlock()
	return found
