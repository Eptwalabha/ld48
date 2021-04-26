class_name Level extends Node2D

export(bool) var can_use_tools = false

onready var camera := $Camera2D
onready var player := $Player as Player
onready var camera_target := $Player

onready var start = $Start

func _ready():
	camera.current = true
	player.global_position = $Start.global_position

func set_player_control(control: bool) -> void:
	player.can_move = control

func set_camera_limit(top: int, bottom: int, left: int, right: int) -> void:
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom

func _process(delta: float) -> void:
	if GameAutoload.DEBUG and Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	update_camera()
	if player.can_move:
		player.process(delta)

func update_camera() -> void:
	camera.position = camera_target.global_position
