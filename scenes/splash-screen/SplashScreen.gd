extends Control

func _ready() -> void:
	if GameAutoload.DEBUG:
		load_main_scene()
	else:
		$AnimationPlayer.play("fade-in")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		load_main_scene()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	load_main_scene()

func load_main_scene() -> void:
	get_tree().change_scene("res://scenes/levels/map/HubLevel.tscn")
