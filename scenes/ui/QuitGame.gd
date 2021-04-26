class_name UIQuitGame extends Control

signal quit_game


func _on_Quit_pressed():
	emit_signal("quit_game")


func _on_Cancel_pressed():
	hide()

func _on_Close_pressed():
	hide()
