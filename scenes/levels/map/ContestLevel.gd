extends Level

signal end_of_theard(thread)

var GrenadeScene = preload("res://scenes/player/tools/Grenade.tscn")
var BlockScene = preload("res://scenes/DirtBlock.tscn")

onready var countdown_label: Label = $CanvasLayer/CountdownStart
onready var game_timer_label: Label = $CanvasLayer/Countdown
onready var map: BaseTilemap = $Tilemap
onready var tool_ui: UITool = $CanvasLayer/UITool

onready var startup_timer: Timer = $StartupTimer
onready var game_timer: Timer = $GameTimer
var sec_start: int = 4
var game_start: bool = false
var cursor_last_cell_index = null

func _ready() -> void:
	set_camera_limit(-400, 1800, 16, 1264)
	reset_level()
	start()

func reset_level() -> void:
	game_start = false
	set_player_control(false)
	player.global_position = start.global_position
	sec_start = 4
	startup_timer.stop()
	game_timer.stop()
	countdown_label.hide()
	game_timer_label.hide()

func start() -> void:
	if GameAutoload.DEBUG:
		start_contest()
	else:
		startup_timer.start(1.0)

func start_contest() -> void:
	tool_ui.set_current(player.current_tool.type)
	game_start = true
	set_player_control(true)
	game_timer.start()
	game_timer_label.show()

func _process(_delta: float) -> void:
	if !game_start:
		return
	update_timer_label()
	
	if Input.is_action_just_pressed("action"):
		player.action_start(get_global_mouse_position(), cursor_last_cell_index)
	if Input.is_action_just_released("action"):
		player.action_end(get_global_mouse_position(), cursor_last_cell_index)
	
	if Input.is_action_just_released("action_next_tool"):
		player.next_tool()
	if Input.is_action_just_released("action_previous_tool"):
		player.previous_tool()
	
	if player.has_tool_cursor():
		update_player_reach()

func update_player_reach() -> void:
	if player.is_map_reach_colliding() and player.get_map_reach_collider():
		update_cursor()
	else:
		map.hide_cursor()
		cursor_last_cell_index = null

func update_cursor() -> void:
	var position = player.get_map_reach_collider_point()
	var cell_index = map.world_to_map(position)
	if cursor_last_cell_index != cell_index:
		cursor_last_cell_index = cell_index
		var blocks = map.get_blocks(cell_index, player.current_tool.radius, player.current_tool.filter)
		map.update_cursor(blocks)

func update_timer_label() -> void:
	game_timer_label.text = "%.1f" % game_timer.time_left

func _spawn_blocks(args) -> void:
	for block in args[0]:
		yield(get_tree().create_timer(0.02), "timeout")
		var physics_block = BlockScene.instance()
		map.add_block(physics_block)
		physics_block.initialize(block["position"], block["velocity"], block["type"])
	emit_signal("end_of_theard", args[1])

func _end_of_theard(thread: Thread):
	thread.wait_to_finish()

func _on_StartupTimer_timeout():
	sec_start -= 1
	if sec_start == 0:
		countdown_label.hide()
		startup_timer.stop()
		start_contest()
	else:
		countdown_label.show()
		countdown_label.text = "%s" % sec_start
		startup_timer.start(1.0)

func _on_GameTimer_timeout():
	game_start = false
	set_player_control(false)

func _on_Player_throw_dirt_shovel(cell: Vector2, direction: Vector2, shovel: Shovel):
	player.dig()
	map.hide_cursor()
	var blocks = map.get_blocks(cell, shovel.radius, shovel.filter)
	var blocks_to_spawn = []
	for block in blocks:
		var r = Vector2(randf() * 32.0 - 16.0, randf() * 32.0 - 16.0) * 5
		blocks_to_spawn.append({
			"type": map.get_cellv(block),
			"position": player.throw_position.global_position,
			"velocity": direction + r,
		})
		map.set_cellv(block, -1)
		map.update_bitmask_area(block)
	if len(blocks_to_spawn) == 0:
		return
	var thread = Thread.new()
	thread.start(self, "_spawn_blocks", [blocks_to_spawn, thread])

func _on_Player_empty_bucket(position: Vector2, blocks: Array, bucket: Bucket):
	bucket.empty()
	tool_ui.set_bucket_fullness(false)
	var x = 300 if position.x > player.global_position.x else -300
	var blocks_to_spawn = []
	for block_type in blocks:
		var r = Vector2(randf() * 32.0 - 16.0, randf() * 32.0 - 16.0) * 5
		blocks_to_spawn.append({
			"type": block_type,
			"position": player.throw_position.global_position,
			"velocity": Vector2(x, 200) + r,
		})
	if len(blocks_to_spawn) == 0:
		return
	var thread = Thread.new()
	thread.start(self, "_spawn_blocks", [blocks_to_spawn, thread])

func _on_Player_fill_bucket(cell: Vector2, capacity_left: int, bucket: Bucket):
	var blocks = map.get_blocks(cell, bucket.radius, bucket.filter)
	map.hide_cursor()
	if len(blocks) == 0:
		bucket.force_empty(get_global_mouse_position())
		return
	var i = 0
	for block in blocks:
		if i >= capacity_left:
			break
		i += 1
		bucket.add_block(map.get_cellv(block))
		map.set_cellv(block, -1)
		map.update_bitmask_area(block)
	if bucket.is_full():
		tool_ui.set_bucket_fullness(true)

func _on_Player_spawn_explosive(_position, direction, explosive):
	var grenade = GrenadeScene.instance()
	var throw_position: Vector2 = player.throw_position.global_position
	grenade.initialize(throw_position, direction, explosive.filter)
	map.add_child(grenade)
	grenade.connect("blow_up", self, "_on_Grenade_blowup", [grenade, explosive])

func _on_Grenade_blowup(position, _force, radius: float, grenade: Grenade, explosive: Explosive) -> void:
	explosive.grenade_exploded()
	var cell_index = map.world_to_map(position)
	var blocks = map.get_blocks(cell_index, radius, grenade.filter)
	var blocks_to_spawn = []
	for block in blocks:
		var r = randf()
		if r > .9:
			continue
		elif r > .6:
			var block_position = map.to_global(map.map_to_world(block))
			blocks_to_spawn.append({
				"type": map.get_cellv(block),
				"position": block_position - Vector2(0, 32),
				"velocity": (block_position - position).normalized() * grenade.force,
			})
		else:
			map.set_cellv(block, -1)
			map.update_bitmask_area(block)
	if len(blocks_to_spawn) == 0:
		return
	var thread = Thread.new()
	thread.start(self, "_spawn_blocks", [blocks_to_spawn, thread])

func _on_Player_change_tool(tool_type):
	tool_ui.set_current(tool_type)

func _on_UITool_tool_clicked(tool_type):
	player.change_tool(tool_type)
