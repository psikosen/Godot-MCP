@tool
class_name MCPSceneTransactionManager
extends RefCounted

const LOG_FILENAME := "addons/godot_mcp/utils/scene_transaction_manager.gd"
const DEFAULT_SYSTEM_SECTION := "scene_transaction"

static var _transactions: Dictionary = {}
static var _id_counter: int = 0
# Ids of committed transactions; their undo actions live in the editor history, so rollback is refused.
static var _committed_ids: Dictionary = {}

class SceneTransaction extends RefCounted:
	var transaction_id: String
	var action_name: String
	var metadata: Dictionary
	var _undo_redo: EditorUndoRedoManager
	var _do_methods: Array = []
	var _undo_methods: Array = []
	var _do_properties: Array = []
	var _undo_properties: Array = []
	var _do_references: Array = []
	var _commit_callbacks: Array = []
	var _rollback_callbacks: Array = []
	var _is_active: bool = false
	var _is_committed: bool = false
	# MCP paths ("/root/...") of nodes this transaction will create, rename or move, so later steps of
	# the same transaction can address them before commit (they reported "Node not found").
	var pending_paths: Dictionary = {}
	# Why the last commit() returned false, for the commit tool's error message.
	var commit_error: String = ""

	func _init(action_name: String, metadata: Dictionary = {}):
		transaction_id = MCPSceneTransactionManager._generate_transaction_id()
		self.action_name = action_name
		self.metadata = metadata.duplicate(true)
		self.metadata["transaction_id"] = transaction_id
		_undo_redo = MCPSceneTransactionManager._get_undo_redo()
		if _undo_redo:
			_is_active = true
			MCPSceneTransactionManager._log(
				"Scene transaction began",
				"SceneTransaction._init",
				{
					"transaction_id": transaction_id,
					"action_name": action_name,
					"metadata": self.metadata,
				}
			)
		else:
			MCPSceneTransactionManager._log(
				"EditorUndoRedoManager unavailable, transaction cannot start",
				"SceneTransaction._init",
				{
					"transaction_id": transaction_id,
					"action_name": action_name,
				},
				true
			)

	func is_ready() -> bool:
		return _is_active and _undo_redo != null

	func add_do_method(target: Object, method: StringName, args: Array = []) -> void:
		if not is_ready():
			return
		_do_methods.append({"target": target, "method": method, "args": args})

	func add_undo_method(target: Object, method: StringName, args: Array = []) -> void:
		if not is_ready():
			return
		_undo_methods.append({"target": target, "method": method, "args": args})

	func add_do_property(target: Object, property: StringName, value) -> void:
		if not is_ready():
			return
		_do_properties.append({"target": target, "property": property, "value": value})

	func add_undo_property(target: Object, property: StringName, value) -> void:
		if not is_ready():
			return
		_undo_properties.append({"target": target, "property": property, "value": value})

	func add_do_reference(target: Object) -> void:
		if not is_ready():
			return
		if target and not _do_references.has(target):
			_do_references.append(target)

	func register_on_commit(callback: Callable) -> void:
		_commit_callbacks.append(callback)

	func register_on_rollback(callback: Callable) -> void:
		_rollback_callbacks.append(callback)

	func has_operations() -> bool:
		return _do_methods.size() > 0 or _undo_methods.size() > 0 or _do_properties.size() > 0 or _undo_properties.size() > 0

	func commit() -> bool:
		if not is_ready():
			MCPSceneTransactionManager._log(
				"Attempted to commit inactive transaction",
				"SceneTransaction.commit",
				{"transaction_id": transaction_id},
				true
			)
			return false

		if not has_operations():
			MCPSceneTransactionManager._log(
				"No operations recorded for transaction; skipping commit",
				"SceneTransaction.commit",
				{"transaction_id": transaction_id, "action_name": action_name}
			)
			_is_active = false
			_is_committed = false
			return true

		# A named transaction stays open between calls. If its nodes were freed meanwhile (the scene
		# was closed or reloaded), committing would replay steps on dead objects and run on-commit
		# callbacks that read them, so the whole transaction is dropped instead.
		var freed := 0
		for entry in _do_methods + _undo_methods + _do_properties + _undo_properties:
			if not is_instance_valid(entry.target):
				freed += 1
		if freed > 0:
			commit_error = "Transaction '%s' cannot commit: %d of its steps target nodes that no longer exist (deleted, or the scene was closed or reloaded). Nothing was applied; redo the edits in a new transaction." % [transaction_id, freed]
			MCPSceneTransactionManager._log(commit_error, "SceneTransaction.commit", {"transaction_id": transaction_id}, true)
			_is_active = false
			return false

		# Pin the action to the edited scene's history. Without a context Godot picks the history from
		# the first object touched; resource edits (animations) then logged "UndoRedo history mismatch".
		var scene_root = EditorInterface.get_edited_scene_root()
		if scene_root != null:
			_undo_redo.create_action(action_name, UndoRedo.MERGE_DISABLE, scene_root)
		else:
			_undo_redo.create_action(action_name)
		if metadata.size() > 0:
			# Godot EditorUndoRedoManager does not expose metadata APIs in every version.
			# Preserve compatibility by applying metadata only when the method exists.
			if _undo_redo.has_method("set_action_metadata"):
				_undo_redo.set_action_metadata(metadata)
			else:
				MCPSceneTransactionManager._log(
					"Skipping action metadata; set_action_metadata unavailable",
					"SceneTransaction.commit",
					{
						"transaction_id": transaction_id,
						"action_name": action_name,
					}
				)

		for entry in _do_methods:
			var args = entry.args
			match args.size():
				0: _undo_redo.add_do_method(entry.target, entry.method)
				1: _undo_redo.add_do_method(entry.target, entry.method, args[0])
				2: _undo_redo.add_do_method(entry.target, entry.method, args[0], args[1])
				3: _undo_redo.add_do_method(entry.target, entry.method, args[0], args[1], args[2])
				4: _undo_redo.add_do_method(entry.target, entry.method, args[0], args[1], args[2], args[3])
				_: push_warning("Too many arguments for undo/redo method")
		for entry in _undo_methods:
			var args = entry.args
			match args.size():
				0: _undo_redo.add_undo_method(entry.target, entry.method)
				1: _undo_redo.add_undo_method(entry.target, entry.method, args[0])
				2: _undo_redo.add_undo_method(entry.target, entry.method, args[0], args[1])
				3: _undo_redo.add_undo_method(entry.target, entry.method, args[0], args[1], args[2])
				4: _undo_redo.add_undo_method(entry.target, entry.method, args[0], args[1], args[2], args[3])
				_: push_warning("Too many arguments for undo/redo method")
		for entry in _do_properties:
			_undo_redo.add_do_property(entry.target, entry.property, entry.value)
		for entry in _undo_properties:
			_undo_redo.add_undo_property(entry.target, entry.property, entry.value)
		for reference in _do_references:
			_undo_redo.add_do_reference(reference)

		_undo_redo.commit_action()
		_is_active = false
		_is_committed = true

		for callback in _commit_callbacks:
			callback.call_deferred()

		MCPSceneTransactionManager._log(
			"Scene transaction committed",
			"SceneTransaction.commit",
			{
				"transaction_id": transaction_id,
				"action_name": action_name,
				"metadata": metadata,
			}
		)

		return true

	func rollback() -> bool:
		if not is_ready():
			MCPSceneTransactionManager._log(
				"Attempted to rollback inactive transaction",
				"SceneTransaction.rollback",
				{"transaction_id": transaction_id},
				true
			)
			return false

		if _is_active:
			for callback in _rollback_callbacks:
				callback.call_deferred()

			MCPSceneTransactionManager._log(
				"Scene transaction rolled back before commit",
				"SceneTransaction.rollback",
				{
					"transaction_id": transaction_id,
					"action_name": action_name,
				}
			)
			_is_active = false
			return true

		if _is_committed and _undo_redo:
			_undo_redo.undo()
			MCPSceneTransactionManager._log(
				"Scene transaction rolled back after commit",
				"SceneTransaction.rollback",
				{
					"transaction_id": transaction_id,
					"action_name": action_name,
				}
			)
			return true

		MCPSceneTransactionManager._log(
			"Rollback requested but transaction already inactive",
			"SceneTransaction.rollback",
			{
				"transaction_id": transaction_id,
				"action_name": action_name,
			}
		)
		return false


static func begin_inline(action_name: String, metadata: Dictionary = {}) -> SceneTransaction:
	var transaction := SceneTransaction.new(action_name, metadata)
	if transaction.is_ready():
		return transaction
	return null

static func begin_registered(transaction_id: String, action_name: String, metadata: Dictionary = {}) -> SceneTransaction:
	if transaction_id.is_empty():
		transaction_id = _generate_transaction_id()
	if _transactions.has(transaction_id):
		_log(
			"Transaction ID already exists",
			"MCPSceneTransactionManager.begin_registered",
			{"transaction_id": transaction_id},
			true
		)
		return null

	var transaction := SceneTransaction.new(action_name, metadata)
	if transaction.is_ready():
			transaction.transaction_id = transaction_id
			transaction.metadata["transaction_id"] = transaction_id
			_transactions[transaction_id] = transaction
			_log(
				"Registered new scene transaction",
				"MCPSceneTransactionManager.begin_registered",
				{
					"transaction_id": transaction_id,
					"action_name": action_name,
					"metadata": transaction.metadata,
				}
			)
			return transaction
	return null

static func get_transaction(transaction_id: String) -> SceneTransaction:
	return _transactions.get(transaction_id)

static func commit_registered(transaction_id: String) -> bool:
	var transaction: SceneTransaction = get_transaction(transaction_id)
	if not transaction:
		_log(
			"Attempted to commit unknown transaction",
			"MCPSceneTransactionManager.commit_registered",
			{"transaction_id": transaction_id},
			true
		)
		return false

	var result := transaction.commit()
	_transactions.erase(transaction_id)
	if result:
		_committed_ids[transaction_id] = true
	return result

static func rollback_registered(transaction_id: String) -> bool:
	var transaction: SceneTransaction = get_transaction(transaction_id)
	if not transaction:
		_log(
			"Attempted to rollback unknown transaction",
			"MCPSceneTransactionManager.rollback_registered",
			{"transaction_id": transaction_id},
			true
		)
		return false

	var result := transaction.rollback()
	_transactions.erase(transaction_id)
	return result

# Node staged under `path` by any open registered transaction, or null.
static func find_pending_node(path: String) -> Node:
	for transaction in _transactions.values():
		var node = transaction.pending_paths.get(path)
		if node != null and is_instance_valid(node):
			return node
	return null

static func is_committed(transaction_id: String) -> bool:
	return _committed_ids.has(transaction_id)

static func has_active(transaction_id: String) -> bool:
	return _transactions.has(transaction_id)

static func list_transactions() -> Array:
	return _transactions.keys()

static func _generate_transaction_id() -> String:
	_id_counter += 1
	return "txn_%d_%d" % [Time.get_ticks_msec(), _id_counter]

static func _get_undo_redo():
	if not Engine.has_meta("GodotMCPPlugin"):
		_log(
			"GodotMCPPlugin not found in Engine metadata",
			"MCPSceneTransactionManager._get_undo_redo",
			{},
			true
		)
		return null

	var plugin = Engine.get_meta("GodotMCPPlugin")
	if plugin and plugin.has_method("get_undo_redo"):
		var undo_redo = plugin.get_undo_redo()
		if undo_redo:
			return undo_redo

	if plugin and plugin.has_method("get_editor_interface"):
		var editor_interface = plugin.get_editor_interface()
		if editor_interface:
			return editor_interface.get_undo_redo()

	_log(
		"EditorUndoRedoManager unavailable",
		"MCPSceneTransactionManager._get_undo_redo",
		{},
		true
	)
	return null

static func _log(message: String, function_name: String, extra: Dictionary = {}, is_error: bool = false) -> void:
	var payload := {
		"filename": LOG_FILENAME,
		"timestamp": Time.get_datetime_string_from_system(true, true),
		"classname": "MCPSceneTransactionManager",
		"function": function_name,
		"system_section": extra.get("system_section", DEFAULT_SYSTEM_SECTION),
		"line_num": extra.get("line_num", 0),
		"error": message if is_error else "",
		"db_phase": extra.get("db_phase", "none"),
		"method": extra.get("method", "NONE"),
		"message": message,
	}

	for key in extra.keys():
		if not payload.has(key):
			payload[key] = extra[key]

	print(JSON.stringify(payload))
