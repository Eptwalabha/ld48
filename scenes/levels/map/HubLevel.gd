extends "res://scenes/levels/Level.gd"

onready var context_label: Label = $CanvasLayer/ContextLabel

func _ready() -> void:
	context_label.hide()

func _process(delta) -> void:
	.update_camera($Player)


func show_interact(show: bool) -> void:
	context_label.visible = show

func _on_Shop_entered(body):
	show_interact(true)

func _on_Shop_exited(body):
	show_interact(false)

func _on_Competition_entered(body):
	show_interact(true)

func _on_Competition_exited(body):
	show_interact(false)
