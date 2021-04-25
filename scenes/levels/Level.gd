class_name Level extends Node2D

export(bool) var can_use_tools = false
export(bool) var can_control_player = true
export(NodePath) var map: NodePath

onready var camera := $Camera2D
onready var player := $Player as Player

onready var start = $Start

func _ready():
	print("super")
	camera.current = true
	$Player.global_position = $Start.global_position
	if ! get_node(map) is TileMap:
		can_use_tools = false
	camera.limit_left = $TL.global_position.x
	camera.limit_top = $TL.global_position.y
	camera.limit_right = $BR.global_position.x
	camera.limit_bottom = $BR.global_position.y

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	update_camera($Player)

func update_camera(target: Node2D) -> void:
	camera.position = target.global_position

