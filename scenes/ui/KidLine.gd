class_name KidLine extends Node2D

var kid_name
var depth

func initialize(id: int, the_depth: int) -> void:
	kid_name = "kid #%s" % id
	depth = the_depth
	global_position.y = depth * 16 + 8
	position.x = 100 * id
	$Label.text = kid_name + "(%s)" % depth
