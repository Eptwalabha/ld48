extends Level

var podium = 2

func _ready():
	if GameAutoload.last_results != null:
		podium = GameAutoload.last_results["podium"]
	
	match podium:
		0: player.global_position = $Podium/Podium1.global_position
		1: player.global_position = $Podium/Podium2.global_position
		2: player.global_position = $Podium/Podium3.global_position
		_: player.global_position = $Podium/Podium4.global_position
	
	camera_target = $Player/Position2D
	camera.limit_bottom = 100
	player.set_control(false)
	var success = podium < 3
	$Success.visible = success
	$Failure.visible = !success
	$CanvasLayer/Infos/Info.text = tr("your_rank") % (podium + 1)
	if success:
		var gain = GameAutoload.current_contest["price"][podium]
		$CanvasLayer/Infos/Money.text = tr("your_gain") % gain
	else:
		$CanvasLayer/Infos/Money.text = tr("no_gain")

func _on_GameOverLevel_fadein_end():
	if podium < 3:
		$AnimationPlayer.play("success")
	else:
		$AnimationPlayer.play("failure")

func _on_Continue_pressed():
	var _osef = get_tree().change_scene("res://scenes/levels/map/HubLevel.tscn")
