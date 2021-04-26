class_name Player extends KinematicBody2D

# warning-ignore:unused_signal
signal throw_dirt
signal throw_dirt_shovel(from, direction, shovel)
signal fill_bucket(position, bucket)
signal empty_bucket(position, blocks, bucket)
signal spawn_explosive(position, direction, explosive)
signal change_tool(tool_type)

export(float) var j_duration := .5
export(float) var j_tiles := 5.0
export(int) var max_range := 3


var ShovelScene = preload("res://scenes/player/tools/Shovel.tscn")
var BucketScene = preload("res://scenes/player/tools/Bucket.tscn")
var ExplosiveScene = preload("res://scenes/player/tools/Explosive.tscn")

var shovel: Shovel = null
var bucket: Bucket = null
var explosive: Explosive = null

onready var anim_tree : AnimationTree = $AnimationTree
onready var throw_position: Position2D = $Pivot/Dirt
var state_machine: AnimationNodeStateMachinePlayback

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0

var can_move: bool = true setget set_control

var is_grounded: bool = false
var is_walking: bool = false
var is_wallriding: bool = false
var is_facing_left: bool = true

var action_jump: bool = false
var action_move_left: bool = false
var action_move_right: bool = false

var current_tool: PlayerTool = null
var available_tools: Array = []

func _ready():
	initialize_tools()
	state_machine = anim_tree.get("parameters/playback")
	var hj = j_duration / 2.0
	var d = -pow(hj, 2) + hj * j_duration
	var h = j_tiles * 16.0
	gravity.y = 2 * (h / d)
	jump = (h / d) * j_duration

func initialize_tools() -> void:
	if GameAutoload.unlocked["shovel"]:
		shovel = ShovelScene.instance()
		shovel.initialize(GameAutoload.player_tools["shovel"])
		shovel.connect("throw", self, "_on_Shovel_throw")
		add_child(shovel)
		available_tools.push_back(GameAutoload.TOOL_TYPE.SHOVEL)
		current_tool = shovel
	if GameAutoload.unlocked["bucket"]:
		bucket = BucketScene.instance()
		bucket.initialize(GameAutoload.player_tools["bucket"])
		bucket.connect("fill", self, "_on_Bucket_fill")
		bucket.connect("empty", self, "_on_Bucket_empty")
		add_child(bucket)
		available_tools.push_back(GameAutoload.TOOL_TYPE.BUCKET)
		current_tool = bucket
	if GameAutoload.unlocked["explosive"]:
		explosive = ExplosiveScene.instance()
		explosive.initialize(GameAutoload.player_tools["explosive"])
		explosive.connect("spawn", self, "_on_Explosive_spawn")
		add_child(explosive)
		available_tools.push_back(GameAutoload.TOOL_TYPE.EXPLOSIVE)
		current_tool = explosive

func set_control(control: bool) -> void:
	can_move = control
	if !can_move:
		action_move_left = 0
		action_move_right = 0

func has_tool_cursor() -> bool:
	return current_tool != null and current_tool.has_cursor

func dig() -> void:
	if is_digging():
		return
	state_machine.travel("dig")

func is_moving() -> bool:
	return is_walking or !is_grounded

func get_tool() -> int:
	return 0

func update_map_reach_collider() -> void:
	$MapReach.rotation = $MapReach.global_position.angle_to_point(get_global_mouse_position())

func get_map_reach_collider() -> Object:
	return $MapReach.get_collider()

func get_map_reach_collider_point() -> Vector2:
	return $MapReach.get_collision_point()

func is_map_reach_colliding() -> bool:
	return $MapReach.is_colliding()

func process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_left"):
		pivot_left(true)
		$Pivot.scale.x = -1
	if Input.is_action_just_pressed("move_right"):
		pivot_left(false)
		$Pivot.scale.x = 1

	if Input.is_action_just_pressed("move_jump"):
		action_jump = true

	action_move_left = Input.is_action_pressed("move_left")
	action_move_right = Input.is_action_pressed("move_right")
	update_map_reach_collider()

func pivot_left(left: bool) -> void:
	var s: float = -1.0 if left else 1.0
	$Pivot.scale.x = s

# TODO remove
func get_throw_vectors() -> Array:
	return []

func is_digging() -> bool:
	return state_machine.get_current_node() == "dig"

func _physics_process(delta):
	
	var dir: float = 0.0;
	
	if action_move_left or action_move_right:
		if !is_digging():
			dir -= int(action_move_left)
			dir += int(action_move_right)
			is_facing_left = dir < 0

	velocity.x = dir * speed

	if action_jump:
		action_jump = false
		if (is_realy_on_floor() or is_wallriding):
			velocity.y -= jump
			if is_wallriding:
				velocity.y -= 200
				is_wallriding = false

	velocity += gravity * delta * (.2 if is_wallriding else 1.0)

	velocity = move_and_slide(velocity, Vector2.UP)

	var is_falling_too_fast = velocity.y > 200
	is_grounded = is_realy_on_floor()
	is_walking = dir != 0.0
	is_wallriding = $Pivot/Wall.is_colliding() and velocity.y > 0 and is_walking and !is_falling_too_fast
	update_anim_tree()

func update_anim_tree() -> void:
	anim_tree["parameters/conditions/grounded"] = is_grounded
	anim_tree["parameters/conditions/not_grounded"] = !is_grounded
	anim_tree["parameters/conditions/moving"] = is_walking
	anim_tree["parameters/conditions/not_moving"] = !is_walking
	anim_tree["parameters/conditions/wallriding"] = is_wallriding
	anim_tree["parameters/conditions/not_wallriding"] = !is_wallriding

func is_realy_on_floor() -> bool:
	return is_on_floor() or $FloorL.is_colliding() or $FloorM.is_colliding() or $FloorR.is_colliding()

func action_start(mouse: Vector2, cell) -> void:
	if current_tool != null:
		current_tool.action_start(mouse, cell)

func action_end(mouse: Vector2, cell) -> void:
	if current_tool != null:
		current_tool.action_end(mouse, cell)

func _on_Shovel_throw(cell: Vector2, end_drag: Vector2, force: int) -> void:
	var direction = (end_drag - throw_position.global_position).normalized() * force
	emit_signal("throw_dirt_shovel", cell, direction, shovel)

func _on_Bucket_fill(position: Vector2, capacity) -> void:
	emit_signal("fill_bucket", position, capacity, bucket)

func _on_Bucket_empty(position: Vector2, blocks: Array) -> void:
	emit_signal("empty_bucket", position, blocks, bucket)

func _on_Explosive_spawn(from: Vector2, to: Vector2, force: int) -> void:
	var direction = (to - from).normalized() * force
	emit_signal("spawn_explosive", from, direction, explosive)

func current_tool_index() -> int:
	for i in range(len(available_tools)):
		if available_tools[i] == current_tool.type:
			return i
	return -1

func next_tool() -> void:
	if len(available_tools) == 0:
		return
	var i = wrapi(current_tool_index() + 1, 0, len(available_tools))
	change_tool(available_tools[i])

func previous_tool() -> void:
	if len(available_tools) == 0:
		return
	var i = wrapi(current_tool_index() - 1, 0, len(available_tools))
	change_tool(available_tools[i])

func change_tool(next_tool_type: int) -> void:
	if current_tool and next_tool_type == current_tool.type:
		return
	match next_tool_type:
		GameAutoload.TOOL_TYPE.SHOVEL:
			current_tool = shovel
		GameAutoload.TOOL_TYPE.BUCKET:
			current_tool = bucket
		GameAutoload.TOOL_TYPE.EXPLOSIVE:
			current_tool = explosive
	emit_signal("change_tool", next_tool_type)
