@tool
extends Node3D

@onready var _player: CharacterBody3D = $Player
@onready var _status_label: Label = $CanvasLayer/StatusLabel

var _won := false

func _ready() -> void:
	_ensure_restart_action()
	var auto_enabled := _player != null and "auto_play" in _player and bool(_player.get("auto_play"))
	if auto_enabled:
		_set_status("AI autoplay enabled. Reach green goal. Press R to restart.")
	else:
		_set_status("Arrows/A-D move, Space jump. Reach green goal. Avoid red hazards.")
	if _player != null and _player.has_method("set_checkpoint"):
		_player.set_checkpoint(_player.global_position)
	_connect_world_triggers()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		get_tree().reload_current_scene()

func _connect_world_triggers() -> void:
	for hazard in get_tree().get_nodes_in_group("hazard"):
		if hazard is Area3D:
			(hazard as Area3D).body_entered.connect(_on_hazard_body_entered.bind(hazard))

	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		if checkpoint is Area3D:
			(checkpoint as Area3D).body_entered.connect(_on_checkpoint_body_entered.bind(checkpoint))

	for goal in get_tree().get_nodes_in_group("goal"):
		if goal is Area3D:
			(goal as Area3D).body_entered.connect(_on_goal_body_entered.bind(goal))

func _on_hazard_body_entered(body: Node, _hazard: Area3D) -> void:
	if _won:
		return
	if body != _player:
		return
	_set_status("Hazard hit! Respawning at checkpoint...")
	if _player.has_method("respawn"):
		_player.respawn()

func _on_checkpoint_body_entered(body: Node, checkpoint: Area3D) -> void:
	if _won:
		return
	if body != _player:
		return
	if _player.has_method("set_checkpoint"):
		_player.set_checkpoint(checkpoint.global_position + Vector3(0.0, 1.2, 0.0))
	_set_status("Checkpoint reached")

func _on_goal_body_entered(body: Node, _goal: Area3D) -> void:
	if _won:
		return
	if body != _player:
		return
	_won = true
	_set_status("Level complete! Press R to restart.")

func _set_status(text: String) -> void:
	if _status_label:
		_status_label.text = text

func _ensure_restart_action() -> void:
	const RESTART_ACTION := "restart_level"
	if not InputMap.has_action(RESTART_ACTION):
		InputMap.add_action(RESTART_ACTION)

	var has_r := false
	for event in InputMap.action_get_events(RESTART_ACTION):
		if event is InputEventKey and event.keycode == KEY_R:
			has_r = true
			break

	if not has_r:
		var restart_event := InputEventKey.new()
		restart_event.keycode = KEY_R
		InputMap.action_add_event(RESTART_ACTION, restart_event)
