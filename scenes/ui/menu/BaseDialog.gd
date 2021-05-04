class_name BaseDialog extends Control

signal dialog_closed(id)
signal dialog_opened(id)

onready var title: Label = $VBoxContainer/Control/CenterContainer/HBoxContainer/Title

export(String) var id: String = ""
var frame_opened: int = 0

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("dialog_closed", id)

func cancel_pressed() -> void:
	emit_signal("dialog_closed", id)

func open() -> void:
	frame_opened = OS.get_ticks_msec() + 100
	emit_signal("dialog_opened", id)
	visible = true

func close() -> void:
	visible = false

func _on_Close_pressed():
	emit_signal("dialog_closed", id)
