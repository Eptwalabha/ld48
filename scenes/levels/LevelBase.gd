class_name LevelBase extends Node2D


func _ready():
	start_level()


func start_level() -> void:
	$Player.global_position = $Start.global_position


func _on_End_body_entered(body):
	if body == $Player:
		print("super")
		start_level()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("action"):
		var p_position = $Player.global_position
		var pos = $TileMap.world_to_map(p_position)
		print("action on %s" % $TileMap.get_cellv(pos))
