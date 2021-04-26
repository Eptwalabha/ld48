class_name Explosive extends PlayerTool

signal spawn(position, direction)

var start_position: Vector2 = Vector2.ZERO
var amount: int = 0

func initialize(the_amount: int) -> void:
	.initialize(GameAutoload.TOOL_QUALITY.SUPER)
	amount = the_amount
	radius = 0.0
	has_cursor = false

func action_start(position: Vector2, _cell) -> void:
	if amount > 0:
		start_position = position

func action_end(position: Vector2, _cell) -> void:
	if amount > 0:
		amount -= 1
		emit_signal("spawn", start_position, position, 800)
