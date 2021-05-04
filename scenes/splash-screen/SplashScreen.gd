extends Control

onready var tween: Tween = $Tween
onready var fade_out: ColorRect = $FadeOut
var loaded = false

func _ready() -> void:
	loaded = false
	fade_out.color = Color(0, 0, 0, 0)
	if GameAutoload.DEBUG:
		load_main_scene()
	else:
		$AnimationPlayer.play("intro")

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		load_main_scene()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	load_main_scene()

func load_main_scene() -> void:
	if loaded:
		return
	loaded = true
	tween.interpolate_property(fade_out, "color", fade_out.color, Color(0, 0, 0, 1), 0.4)
	tween.start()

func _on_Tween_tween_all_completed():
	get_tree().change_scene("res://scenes/levels/map/HubLevel.tscn")
