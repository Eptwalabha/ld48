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

	update_block_selector()

func throw_block(block_type: int) -> void:
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
	var is_cell_bellow_empty = $TileMap.get_cell(cell_index.x, cell_index.y + 1) == -1
	if is_cell_bellow_empty:
		set_tile(cell_index.x, cell_index.y + 1, block.type)
	else:
		if $TileMap.get_cellv(cell_index) == -1:
			set_tile(cell_index.x, cell_index.y, block.type)
		else:
			var limit = 5
			var i = 1
			while $TileMap.get_cell(cell_index.x, cell_index.y - i) != -1 and i < limit:
				i += 1
			if i < limit:
				set_tile(cell_index.x, cell_index.y - i, block.type)
	block.queue_free()

func set_tile(x: int, y: int, type: int) -> void:
	$TileMap.set_cell(x, y, type)
	$TileMap.update_bitmask_area(Vector2(x, y))

func update_block_selector() -> void:
	if $Player.is_moving():
		cursor.update_cursor(Vector2.ZERO, 0)
		return

	var p_position = $Player.global_position + Vector2(0.0, 8.0)
	var p_tool = $Player.get_tool()
	match get_next_available_block(p_position, get_global_mouse_position(), p_tool):
		null:
			cursor.update_cursor(Vector2.ZERO, 0)
		var cell_index:
			var cell_position = $TileMap.map_to_world(cell_index)
			cursor.update_cursor($TileMap.to_global(cell_position) + Vector2(8.0, 8.0), 1)
			cursor.cell_index = cell_index

func _on_block_hit_something(_body: Node, block) -> void:
	solidify_block(block)

func _on_block_sleep(block) -> void:
	if block.is_sleeping():
		solidify_block(block)

func _on_Player_throw_dirt():
	var p_position = $Player.global_position + Vector2(0.0, 8.0)
	var p_tool = $Player.get_tool()
	match get_next_available_block(p_position, get_global_mouse_position(), p_tool):
		null: return
		var cell_index:
			var cell_id = $TileMap.get_cellv(cell_index)
			if cell_id != -1:
				throw_block(cell_id)
				$TileMap.set_cellv(cell_index, -1)
				$TileMap.update_bitmask_area(cell_index)

func get_next_available_block(world_position: Vector2, world_mouse: Vector2, spade_type: int):
	var cell_index = $TileMap.world_to_map(world_position)
	var left = world_mouse.x > world_position.x
	for y in range(-2, 1):
		for x in range(0, $Player.max_range):
			var x2 = x if left else -x
			var cell = cell_index + Vector2(x2, y)
			var cell_id = $TileMap.get_cellv(cell)
			var nothing_above = $TileMap.get_cell(cell.x, cell.y - 1) == -1
			var pickable = is_shovel_strong_enough(spade_type, cell_id)
			if cell_id != -1 and pickable and nothing_above:
				return cell
	return null

func is_shovel_strong_enough(spade_type: int, cell_id: int) -> bool:
	match cell_id:
		GameAutoload.BLOCK_TYPE.SAND: return true
		GameAutoload.BLOCK_TYPE.DIRT: return spade_type > 0
		_: return spade_type > 1
