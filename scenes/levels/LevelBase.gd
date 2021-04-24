class_name LevelBase extends Node2D

export(PackedScene) var Block
onready var cursor: BlockSelector = $TileMap/BlockSelector

func _ready():
	start_level()

func start_level() -> void:
	$Player.global_position = $Start.global_position


func _on_End_body_entered(body):
	if body == $Player:
		start_level()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_pressed("action"):
		$Player.dig()

func throw_block(pos: Vector2, block_type: int) -> void:
	var block = Block.instance()
	var throw : Array = $Player.get_throw_vectors()
	add_child(block)
	var direction = (get_global_mouse_position() - throw[0]).normalized() * 800
	block.initialize(throw[0], direction, block_type)
	block.connect("body_entered", self, "_on_block_hit_something", [block])
	block.connect("sleeping_state_changed", self, "_on_block_sleep", [block])

func solidify_block(block) -> void:
	var block_position = block.global_position
	var cell_index = $TileMap.world_to_map(block_position)
	if $TileMap.get_cellv(cell_index) == -1:
		$TileMap.set_cellv(cell_index, block.type)
		$TileMap.update_bitmask_area(cell_index)
	block.queue_free()

#func update_block_selector(cell_index: Vector2, type: int = 0) -> void:
#	var cell_pos = $TileMap.map_to_world(cell_index)
#	cursor.update_cursor($TileMap.to_global(cell_pos), type)

func _on_block_hit_something(body: Node, block) -> void:
	solidify_block(block)

func _on_block_sleep(block) -> void:
	if block.is_sleeping():
		solidify_block(block)

func _on_Player_throw_dirt():
	var p_position = $Player.global_position + Vector2(0.0, 8.0)
	var cell_index = get_next_available_block(p_position, get_global_mouse_position(), 0)
	var cell_id = $TileMap.get_cellv(cell_index)
	if cell_id != -1:
		throw_block(cell_index, cell_id)
		$TileMap.set_cellv(cell_index, -1)
		$TileMap.update_bitmask_area(cell_index)

func get_next_available_block(world_position: Vector2, world_mouse: Vector2, spade_type: int) -> Vector2:
	var cell_index = $TileMap.world_to_map(world_position)
	var mouse_position = $TileMap.world_to_map(world_mouse)
	var left = world_mouse.x > world_position.x
	for y in range(-2, 1):
		for x in range(0, $Player.max_range):
			var x2 = x if left else -x
			var cell = cell_index + Vector2(x2, y)
			var cell_id = $TileMap.get_cellv(cell)
			if cell_id != -1 and is_shovel_strong_enough(spade_type, cell_id):
				return cell
	return cell_index

func is_shovel_strong_enough(spade_type: int, cell_id: int) -> bool:
	var name = $TileMap.tile_set.tile_get_name(cell_id)
	match spade_type:
		0: return ["sand"].has(name)
		1: return ["sand", "dirt"].has(name)
		2: return ["sand", "dirt", "stone"].has(name)
		_: return false
