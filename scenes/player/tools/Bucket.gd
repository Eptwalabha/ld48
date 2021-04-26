class_name Bucket extends PlayerTool

signal fill(position, capacity)
signal empty(position, blocks)

var cooldown: bool = false

var reach: float = 5.0

var blocks: Array = []
var capacity: int = 10

func initialize(quality: int) -> void:
	.initialize(quality)
	type = GameAutoload.TOOL_TYPE.BUCKET
	radius = _block_radius(quality)
	capacity = _block_capacity(quality)

func is_full() -> bool:
	return len(blocks) >= capacity

func empty() -> void:
	blocks = []

func force_empty(position: Vector2) -> void:
	emit_signal("empty", position, blocks)

func add_block(new_block: int) -> void:
	blocks.append(new_block)

func _block_radius(quality: int) -> float:
	match quality:
		QUALITY.BASIC: return 2.0
		QUALITY.NICE: return 3.0
		QUALITY.SUPER: return 4.0
		_: return 0.5

func _block_capacity(quality: int) -> int:
	match quality:
		QUALITY.BASIC: return 3
		QUALITY.NICE: return 6
		QUALITY.SUPER: return 12
		_: return 2

func action_start(mouse: Vector2, cell) -> void:
	if cooldown:
		return
	if len(blocks) < capacity and cell != null:
		emit_signal("fill", cell, capacity - len(blocks))
	else:
		emit_signal("empty", mouse, blocks)
	$Cooldown.start()
	cooldown = true

func _on_Cooldown_timeout():
	cooldown = false
	$Cooldown.stop()
