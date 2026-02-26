@tool
extends CharacterBody3D

@export var move_speed := 10.0
@export var jump_velocity := 11.5
@export var gravity_multiplier := 2.2
@export var respawn_fall_limit := -20.0
@export var fixed_z := 0.0
@export var auto_play := true
@export var auto_goal_x := 28.0
@export var auto_stop_margin := 0.8
@export var auto_jump_markers := PackedFloat32Array([4.1, 7.1, 10.1, 13.1, 16.1, 19.1, 22.1, 25.1])

var _respawn_position := Vector3.ZERO
var _ai_jump_index := 0

func _ready() -> void:
	_respawn_position = global_position
	global_position.z = fixed_z
	_sync_ai_jump_index()

func _physics_process(delta: float) -> void:
	var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta
	elif _wants_jump():
		velocity.y = jump_velocity

	var axis := _get_horizontal_axis()
	velocity.x = axis * move_speed
	velocity.z = 0.0

	move_and_slide()
	global_position.z = fixed_z

	if global_position.y < respawn_fall_limit:
		respawn()

func set_checkpoint(point: Vector3) -> void:
	_respawn_position = point
	_sync_ai_jump_index()

func respawn() -> void:
	global_position = _respawn_position
	global_position.z = fixed_z
	velocity = Vector3.ZERO
	_sync_ai_jump_index()

func _get_horizontal_axis() -> float:
	if not auto_play:
		return Input.get_axis("ui_left", "ui_right")
	if global_position.x >= auto_goal_x - auto_stop_margin:
		return 0.0
	return 1.0

func _wants_jump() -> bool:
	if not auto_play:
		return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")
	if _ai_jump_index >= auto_jump_markers.size():
		return false
	if global_position.x >= auto_jump_markers[_ai_jump_index]:
		_ai_jump_index += 1
		return true
	return false

func _sync_ai_jump_index() -> void:
	_ai_jump_index = 0
	while _ai_jump_index < auto_jump_markers.size() and auto_jump_markers[_ai_jump_index] < global_position.x - 0.2:
		_ai_jump_index += 1
