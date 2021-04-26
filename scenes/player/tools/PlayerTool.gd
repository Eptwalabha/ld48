class_name PlayerTool extends Node2D

var QUALITY = GameAutoload.TOOL_QUALITY
var BLOCK = GameAutoload.BLOCK_TYPE

var filter: Array = []
var radius: float = 0.0
var is_tool_currently_used: bool = false
var has_cursor: bool = true

func initialize(quality: int) -> void:
	filter = get_block_filters(quality)

func action_start(_position: Vector2, _cell) -> void:
	pass

func action_end(_position: Vector2, _cell) -> void:
	pass

func get_block_filters(quality: int) -> Array:
	match quality:
		QUALITY.BASIC: return [BLOCK.SAND]
		QUALITY.NICE: return [BLOCK.SAND, BLOCK.DIRT]
		QUALITY.SUPER: return [BLOCK.SAND, BLOCK.DIRT, BLOCK.STONE]
		_: return []
