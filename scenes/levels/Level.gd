extends Node2D

export(bool) var can_use_tools = false
export(bool) var can_control_player = true
export(NodePath) var map: NodePath

onready var start = $Start

func _ready():
	$Camera2D.current = true
	$Player.global_position = $Start.global_position
	if ! get_node(map) is TileMap:
		can_use_tools = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	update_camera($Player)

func update_camera(target: Node2D) -> void:
	$Camera2D.position = target.global_position

