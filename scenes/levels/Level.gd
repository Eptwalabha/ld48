class_name Level extends Node2D

export(bool) var can_use_tools = false
export(bool) var can_control_player = true
export(NodePath) var map: NodePath

onready var camera := $Camera2D
onready var player := $Player as Player

onready var start = $Start

func _ready():
	camera.current = true
	$Player.global_position = $Start.global_position

func set_camera_limit(top: int, bottom: int, left: int, right: int) -> void:
	camera.limit_left = left
	camera.limit_top = top
	camera.limit_right = right
	camera.limit_bottom = bottom

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	update_camera($Player)

func update_camera(target: Node2D) -> void:
	camera.position = target.global_position

