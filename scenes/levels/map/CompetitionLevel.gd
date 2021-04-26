extends Level

signal end_of_theard(thread)

var GrenadeScene = preload("res://scenes/player/tools/Grenade.tscn")
var BlockScene = preload("res://scenes/DirtBlock.tscn")

onready var countdown_label: Label = $CanvasLayer/CountdownStart
onready var game_timer_label: Label = $CanvasLayer/Countdown
onready var map: BaseTilemap = $Competion01

onready var startup_timer: Timer = $StartupTimer
onready var game_timer: Timer = $GameTimer
var sec_start: int = 4
var game_start: bool = false

func _ready() -> void:
	set_camera_limit(-400, 1800, 16, 1264)
	reset_level()
	start()

func reset_level() -> void:
	game_start = false
	can_control_player = false
	player.global_position = start.global_position
	sec_start = 4
	startup_timer.stop()
	game_timer.stop()
	countdown_label.hide()
	game_timer_label.hide()

func start() -> void:
#	startup_timer.start(1.0)
	start_competition() # TODO remove

func start_competition() -> void:
	game_start = true
	can_control_player = true
	game_timer.start()
	game_timer_label.show()

func _process(_delta: float) -> void:
	if !game_start:
		return
	update_timer_label()
	
	if Input.is_action_just_pressed("action"):
		player.action_start(get_global_mouse_position())
	if Input.is_action_just_released("action"):
		player.action_end(get_global_mouse_position())

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
		start_competition()
	else:
		countdown_label.show()
		countdown_label.text = "%s" % sec_start
		startup_timer.start(1.0)

func _on_GameTimer_timeout():
	game_start = false
	can_control_player = false

func _on_Player_throw_dirt_shovel(position: Vector2, direction: Vector2, shovel: Shovel):
	player.dig()
	var blocks = map.get_blocks(position, shovel.radius, shovel.filter)
	var throw_position: Vector2 = player.throw_position.global_position
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

func _on_Player_fill_bucket(position: Vector2, capacity_left: int, bucket: Bucket):
	var blocks = map.get_blocks(position, bucket.radius, bucket.filter)
	if len(blocks) == 0:
		bucket.force_empty(position)
		return
	var i = 0
	for block in blocks:
		if i >= capacity_left:
			break
		i += 1
		bucket.add_block(map.get_cellv(block))
		map.set_cellv(block, -1)
		map.update_bitmask_area(block)

func _on_Player_spawn_explosive(position, direction, explosive):
	var grenade = GrenadeScene.instance()
	var throw_position: Vector2 = player.throw_position.global_position
	grenade.initialize(throw_position, direction, explosive.filter)
	map.add_child(grenade)
	grenade.connect("blow_up", self, "_on_Grenade_blowup", [grenade])

func _on_Grenade_blowup(position, force, radius, grenade: Grenade) -> void:
	var blocks = map.get_blocks(position, radius, grenade.filter)
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
