class_name LevelBase extends Node2D

export(PackedScene) var Block

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
	
	if Input.is_action_just_pressed("action"):
		$Player.dig()

func throw_block(pos: Vector2, block_type: int) -> void:
	var block = Block.instance()
	var throw : Array = $Player.get_throw_vectors()
	block.initialize(throw[0], throw[1], block_type)
	add_child(block)
	block.connect("body_entered", self, "_on_block_hit_something", [block])

func _on_block_hit_something(body: Node, block) -> void:
	var p_position = block.global_position
	var pos = $TileMap.world_to_map(p_position)
	if $TileMap.get_cellv(pos) == -1:
		$TileMap.set_cellv(pos, block.type)
		$TileMap.update_bitmask_area(pos)
	block.queue_free()


func _on_Player_throw_dirt():
	var p_position = $Player.global_position
	var pos = $TileMap.world_to_map(p_position)
	var block_type = $TileMap.get_cellv(pos)
	if block_type != -1:
		throw_block(pos, block_type)
		$TileMap.set_cellv(pos, -1)
		$TileMap.update_bitmask_area(pos)
