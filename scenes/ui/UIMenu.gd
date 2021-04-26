class_name UIMenu extends Control

signal close_menu()

func open() -> void:
	visible = true

func is_open() -> bool:
	return visible

func _on_Close_pressed():
	visible = false
	emit_signal("close_menu")
