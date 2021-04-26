class_name GameOverlay extends Node2D

# warning-ignore:unused_signal
signal end_of_count_down

func start() -> void:
	$AnimationPlayer.play("start")
