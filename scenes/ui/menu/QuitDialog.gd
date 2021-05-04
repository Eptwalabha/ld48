class_name QuitDialog extends BaseDialog

signal quit_game

func _on_Quit_pressed():
	emit_signal("quit_game")
