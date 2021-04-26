extends Control

func _ready() -> void:
	$AnimationPlayer.play("fade-in")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		load_main_scene()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	load_main_scene()

func load_main_scene() -> void:
	get_tree().change_scene("res://scenes/levels/map/HubLevel.tscn")
