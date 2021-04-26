class_name Explosive extends PlayerTool

signal spawn(position, direction)

var start_position: Vector2 = Vector2.ZERO
var amount: int = 0
var filter: Array = []

func initialize(the_amount: int) -> void:
	filter = get_block_filters(GameAutoload.TOOL_QUALITY.SUPER)
	amount = the_amount

func action_start(position: Vector2) -> void:
	if amount > 0:
		start_position = position

func action_end(position: Vector2) -> void:
	if amount > 0:
		amount -= 1
		emit_signal("spawn", start_position, position, 800)
