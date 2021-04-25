class_name Shovel extends PlayerTool

signal throw(from, to, force)

var filter: Array = []
var radius: float = 1.0
var reach: float = 5.0

var start_position: Vector2 = Vector2.ZERO

onready var BLOCK_TYPE = GameAutoload.BLOCK_TYPE
onready var QUALITY = GameAutoload.TOOL_QUALITY

func initialize(quality: int) -> void:
	filter = _block_filters(quality)
	radius = _block_radius(quality)

func _block_filters(quality: int) -> Array:
	match quality:
		GameAutoload.TOOL_QUALITY.BASIC:
			return [GameAutoload.BLOCK_TYPE.SAND]
		GameAutoload.TOOL_QUALITY.NICE:
			return [GameAutoload.BLOCK_TYPE.SAND, GameAutoload.BLOCK_TYPE.DIRT]
		GameAutoload.TOOL_QUALITY.SUPER:
			return [GameAutoload.BLOCK_TYPE.SAND, GameAutoload.BLOCK_TYPE.DIRT, GameAutoload.BLOCK_TYPE.STONE]
		_:
			return []

func _block_radius(quality: int) -> float:
	match quality:
		GameAutoload.TOOL_QUALITY.BASIC:
			return 1.0
		GameAutoload.TOOL_QUALITY.NICE:
			return 1.0
		GameAutoload.TOOL_QUALITY.SUPER:
			return 2.0
		_:
			return 0.5

func action_start(mouse: Vector2) -> void:
	start_position = mouse

func action_end(mouse: Vector2) -> void:
	emit_signal("throw", start_position, mouse, 800)
