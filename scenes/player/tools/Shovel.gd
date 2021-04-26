class_name Shovel extends PlayerTool

signal throw(from, to, force)

var reach: float = 5.0

var start_position: Vector2 = Vector2.ZERO
var start_cell: Vector2 = Vector2.ZERO

func initialize(quality: int) -> void:
	.initialize(quality)
	radius = _block_radius(quality)

func _block_radius(quality: int) -> float:
	match quality:
		QUALITY.BASIC: return 1.0
		QUALITY.NICE: return 2.0
		QUALITY.SUPER: return 4.0
		_: return 0.5

func action_start(position: Vector2, cell) -> void:
	if cell != null:
		is_tool_currently_used = true
		start_position = position
		start_cell = cell

func action_end(position: Vector2, _cell) -> void:
	if (position - start_position).length() > 16 and is_tool_currently_used:
		is_tool_currently_used = false
		emit_signal("throw", start_cell, position, 800)
