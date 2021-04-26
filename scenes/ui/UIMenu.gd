class_name UIMenu extends Control

signal close_menu()

func open() -> void:
	visible = true

func is_open() -> bool:
	return visible

func close() -> void:
	visible = false
	emit_signal("close_menu")

func _on_Close_pressed():
	close()
