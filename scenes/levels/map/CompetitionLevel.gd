extends Level

signal end_of_theard(thread)

export(PackedScene) var Block
onready var countdown_label: Label = $CanvasLayer/CountdownStart
onready var game_timer_label: Label = $CanvasLayer/Countdown
onready var map: BaseTilemap = $Competion01

onready var startup_timer: Timer = $StartupTimer
onready var game_timer: Timer = $GameTimer
var sec_start: int = 4
var game_start: bool = false
var threads: Array = []

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
	var thread = Thread.new()
	threads.push_back(thread)
	var blocks_type = []
	for block in blocks:
		blocks_type.push_back(map.get_cellv(block))
		map.set_cellv(block, -1)
		map.update_bitmask_area(block)
	thread.start(self, "_spawn_blocks", [blocks_type, throw_position, direction, thread])

func _spawn_blocks(args) -> void:
	var types: Array = args[0]
	var from: Vector2 = args[1]
	var direction: Vector2 = args[2]
	for type in types:
		yield(get_tree().create_timer(0.02), "timeout")
		var physics_block = Block.instance()
		var r = Vector2(randf() * 32.0 - 16.0, randf() * 32.0 - 16.0) * 5
		map.add_block(physics_block)
		physics_block.initialize(from, direction + r, type)
	emit_signal("end_of_theard", args[3])

func _end_of_theard(thread: Thread):
	thread.wait_to_finish()

func _on_Player_empty_bucket(position: Vector2, blocks: Array, bucket: Bucket):
	bucket.empty()
	var x = 300 if position.x > player.global_position.x else -300
	var throw_position: Vector2 = player.throw_position.global_position
	var thread = Thread.new()
	thread.start(self, "_spawn_blocks", [blocks, throw_position, Vector2(x, 200), thread])

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

func _on_Player_throw_grenade(_position, _grenade):
	pass
