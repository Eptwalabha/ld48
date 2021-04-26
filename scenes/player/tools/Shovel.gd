class_name Shovel extends PlayerTool

signal throw(from, to, force)

var filter: Array = []
var radius: float = 1.0
var reach: float = 5.0

var start_position: Vector2 = Vector2.ZERO

func initialize(quality: int) -> void:
	filter = get_block_filters(quality)
	radius = _block_radius(quality)

func _block_radius(quality: int) -> float:
	match quality:
		QUALITY.BASIC: return 1.0
		QUALITY.NICE: return 1.0
		QUALITY.SUPER: return 2.0
		_: return 0.5

func action_start(mouse: Vector2) -> void:
	start_position = mouse

func action_end(mouse: Vector2) -> void:
	emit_signal("throw", start_position, mouse, 800)
