class_name BaseTilemap extends TileMap

func solidify_block(block) -> void:
	solidify_block_at(block.global_position, block.type)
	block.queue_free()

func add_block(physics_block: RigidBody2D) -> void:
	add_child(physics_block)
	physics_block.connect("body_entered", self, "_on_block_hit_something", [physics_block])
	physics_block.connect("sleeping_state_changed", self, "_on_block_sleep", [physics_block])

func solidify_block_at(block_position: Vector2, type: int) -> void:
	var cell_index = world_to_map(block_position)
	var is_cell_bellow_empty = get_cell(cell_index.x, cell_index.y + 1) == -1
	if is_cell_bellow_empty:
		_set_tile(cell_index.x, cell_index.y + 1, type)
	else:
		if get_cellv(cell_index) == -1:
			_set_tile(cell_index.x, cell_index.y, type)
		else:
			var limit = 5
			var i = 1
			while get_cell(cell_index.x, cell_index.y - i) != -1 and i < limit:
				i += 1
			if i < limit:
				_set_tile(cell_index.x, cell_index.y - i, type)

func get_blocks(position: Vector2, radius: float, filter: Array) -> Array:
	var p = world_to_map(position)
	var list = []
	var neighbors = [Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2.RIGHT]
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var d = Vector2(x, y)
			if float(abs(d.x) + abs(d.y)) > radius:
				continue
			var p2 = p + d
			var m = get_cellv(p2)
			if filter.has(m):
				list.push_back(p2)
	return list

func _set_tile(x: int, y: int, type: int) -> void:
	set_cell(x, y, type)
	update_bitmask_area(Vector2(x, y))

func hole_depth(a: int, b: int, zero: int) -> int:
	var points_id_visited = []
	var points = []
	for i in range(0, b - a):
		var p = Vector2(a + i, zero)
		if get_cellv(p) == -1:
			points.append(p)
	
	var rect: Rect2 = get_used_rect()
	var width: int = int(rect.size.x)
	var neighbors = [Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2.RIGHT]
	var lowest_yet = zero
	while len(points):
		var p = points.pop_back()
		var p_id = point_id(p, width)
		points_id_visited.append(p_id)
		if p.y > lowest_yet:
			lowest_yet = p.y
		for neighbor in neighbors:
			var point_b = p + neighbor
			if get_cellv(p) != -1:
				continue
			if !rect.has_point(point_b) || point_b.y < zero:
				continue
			var point_b_id = point_id(point_b, width)
			if !points_id_visited.has(point_b_id):
				points.push_back(point_b)
	return lowest_yet - zero

func point_id(point: Vector2, width: int) -> int:
	return int(point.y * width + point.x)

func _on_block_hit_something(_body: Node, block) -> void:
	solidify_block(block)

func _on_block_sleep(block) -> void:
	if block.is_sleeping():
		solidify_block(block)
