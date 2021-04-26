class_name PlayerTool extends Node2D

var QUALITY = GameAutoload.TOOL_QUALITY
var BLOCK = GameAutoload.BLOCK_TYPE

func initialize(_quality: int) -> void:
	pass

func action_start(_position: Vector2) -> void:
	pass

func action_end(_position: Vector2) -> void:
	pass

func get_block_filters(quality: int) -> Array:
	match quality:
		QUALITY.BASIC: return [BLOCK.SAND]
		QUALITY.NICE: return [BLOCK.SAND, BLOCK.DIRT]
		QUALITY.SUPER: return [BLOCK.SAND, BLOCK.DIRT, BLOCK.STONE]
		_: return []
