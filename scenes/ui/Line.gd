extends Node2D

var moving = false

func _ready():
	$Label.visible = false

func start_moving():
	visible = true
	$Label.visible = true
	moving = true

func _process(delta):
	if moving:
		$Label.text = "%s" % int(global_position.y / 16)
