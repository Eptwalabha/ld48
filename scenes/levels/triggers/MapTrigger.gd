class_name MapTrigger extends Node2D

signal body_entered(body)
signal body_exited(body)

export(String) var trigger_name
export(bool) var active = true
export(bool) var is_interactible = false

func _ready() -> void:
	$Label.text = tr(trigger_name)
	$Label.visible = false

func _on_Area2D_body_entered(body):
	if active:
		$Label.visible = true
		emit_signal("body_entered", body)

func _on_Area2D_body_exited(body):
	if active:
		$Label.visible = false
		emit_signal("body_exited", body)
