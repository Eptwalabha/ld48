extends Level

signal end_of_theard(thread)

var GrenadeScene = preload("res://scenes/player/tools/Grenade.tscn")
var BlockScene = preload("res://scenes/DirtBlock.tscn")
var KidLineScene = preload("res://scenes/ui/KidLine.tscn")

onready var line = $Line
onready var game_timer_label: Label = $CanvasLayer/Countdown
onready var map: BaseTilemap = $Tilemap
onready var tool_ui: UITool = $CanvasLayer/UITool

onready var game_timer: Timer = $GameTimer
var sec_start: int = 4
var game_start: bool = false
var cursor_last_cell_index = null
var display_line_depth = false
var contestants = []

func _ready() -> void:
	randomize()
	set_camera_limit(-400, 1800, 16, 1264)
	reset_level()
	start()

func reset_level() -> void:
	generate_contestants_results()
	line.visible = false
	tool_ui.visible = false
	game_start = false
	set_player_control(false)
	player.global_position = start.global_position
	sec_start = 4
	game_timer.stop()
	game_timer_label.hide()

func start() -> void:
	if GameAutoload.DEBUG:
		start_contest()
	else:
		$CanvasLayer/GameOverlay.start()

func start_contest() -> void:
	tool_ui.set_current(player.current_tool.type)
	tool_ui.visible = true
	game_start = true
	set_player_control(true)
	game_timer.start(GameAutoload.current_contest["duration"] * 60.0)
	game_timer_label.show()

func generate_contestants_results() -> void:
	contestants = []
	var results = GameAutoload.current_contest["results"]
	var min_r = results[0]
	var diff = results[1] - min_r
	for i in range(0, 5):
		var depth = randi() % diff + min_r
		var kid_name = "kid %s" % i
		contestants.push_back({
			"name": kid_name,
			"depth": depth
		})
		var kid_marker = KidLineScene.instance()
		$KidsLine.add_child(kid_marker)
		kid_marker.initialize(i, depth)

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
		var type = block["type"] if game_start else -1
		physics_block.initialize(block["position"], block["velocity"], type)
	emit_signal("end_of_theard", args[1])

func _end_of_theard(thread: Thread):
	thread.wait_to_finish()

func _on_GameTimer_timeout():
	end_level()

func _on_Player_throw_dirt_shovel(cell: Vector2, direction: Vector2, shovel: Shovel):
	player.dig()
	map.hide_cursor()
	var blocks = map.get_blocks(cell, shovel.radius, shovel.filter)
	var blocks_to_spawn = []
	for block in blocks:
		var r = Vector2(randf() * 32.0 - 16.0, randf() * 32.0 - 16.0) * 5
		var type = -1 if randf() > .7 else map.get_cellv(block)
		blocks_to_spawn.append({
			"type": type,
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
			if game_start:
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

func _on_GameOverlay_end_of_count_down():
	start_contest()

var final_depth: int = 0

func end_level() -> void:
	game_start = false
	set_player_control(false)
	player.hide()
	tool_ui.hide()
	map.end_of_level = true
	var r: Rect2 = map.get_used_rect()
	final_depth = map.hole_depth(0, int(r.size.x - 1), 0)
	line.start_moving()
	camera_target = line
	$Pause.start(1.0)
	yield($Pause, "timeout")
	var line_tween: Tween = $Line/Tween
	var position_end_at = Vector2(line.global_position.x, final_depth * 16)
	display_line_depth = true
	line_tween.interpolate_property(line, "global_position", line.global_position, position_end_at, 3.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	line_tween.start()
	yield(line_tween, "tween_all_completed")
	$Pause.start(2.0)
	yield($Pause, "timeout")
	fade(false)

func _on_CompetitionLevel_fadeout_end():
	if !game_start:
		var podium = 0
		for contestant in contestants:
			if contestant["depth"] > final_depth:
				podium += 1
		GameAutoload.last_results = {
			"id": GameAutoload.current_id,
			"depth": final_depth,
			"contestants": contestants,
			"podium": podium
		}
		var _osef = get_tree().change_scene("res://scenes/levels/map/HubLevel.tscn")
		GameAutoload.save_result()
