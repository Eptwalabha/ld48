class_name UIQuitGame extends Control

signal quit_game
signal close_window

func _on_Quit_pressed():
	emit_signal("quit_game")

func process(_delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("close_window")

func _on_Cancel_pressed():
	emit_signal("close_window")

func _on_Close_pressed():
	emit_signal("close_window")

func close():
	hide()
