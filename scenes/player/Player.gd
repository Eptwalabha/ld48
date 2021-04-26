class_name Player extends KinematicBody2D

# warning-ignore:unused_signal
signal throw_dirt
signal throw_dirt_shovel(from, direction, shovel)
signal fill_bucket(position, bucket)
signal empty_bucket(position, blocks, bucket)

export(float) var j_duration := .5
export(float) var j_tiles := 5.0
export(int) var max_range := 3


var ShovelScene = preload("res://scenes/player/tools/Shovel.tscn")
var BucketScene = preload("res://scenes/player/tools/Bucket.tscn")

var shovel: Shovel = null
var bucket: Bucket = null

onready var anim_tree : AnimationTree = $AnimationTree
onready var throw_position: Position2D = $Pivot/Dirt
var state_machine: AnimationNodeStateMachinePlayback

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0

var is_grounded: bool = false
var is_walking: bool = false
var is_wallriding: bool = false
var is_facing_left: bool = true

var action_jump: bool = false
var action_move_left: bool = false
var action_move_right: bool = false

var current_tool: PlayerTool = null


func _ready():
	initialize_tools()
	state_machine = anim_tree.get("parameters/playback")
	var hj = j_duration / 2.0
	var d = -pow(hj, 2) + hj * j_duration
	var h = j_tiles * 16.0
	gravity.y = 2 * (h / d)
	jump = (h / d) * j_duration

func initialize_tools() -> void:
	if GameAutoload.is_shovel_unlocked:
		shovel = ShovelScene.instance()
		shovel.initialize(GameAutoload.player_tools["shovel"])
		shovel.connect("throw", self, "_on_Shovel_throw")
		add_child(shovel)
		current_tool = shovel
	if GameAutoload.is_bucket_unlocked:
		bucket = BucketScene.instance()
		bucket.initialize(GameAutoload.player_tools["bucket"])
		bucket.connect("fill", self, "_on_Bucket_fill")
		bucket.connect("empty", self, "_on_Bucket_empty")
		add_child(bucket)
		current_tool = bucket

func dig() -> void:
	if is_digging():
		return
	state_machine.travel("dig")

func is_moving() -> bool:
	return is_walking or !is_grounded

func get_tool() -> int:
	return 0

func process(_delat: float) -> void:
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


func pivot_left(left: bool) -> void:
	var s: float = -1.0 if left else 1.0
	$Pivot.scale.x = s

func get_throw_vectors() -> Array:
	var p = $Pivot/Dirt.global_position
	var d = $Pivot/Dirt/Throw.global_position - p
	return [p, d.normalized() * 800]

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

func action_start(mouse: Vector2) -> void:
	if current_tool != null:
		current_tool.action_start(mouse)

func action_end(mouse: Vector2) -> void:
	if current_tool != null:
		current_tool.action_end(mouse)

func _on_Shovel_throw(from: Vector2, to: Vector2, force: int) -> void:
	var direction = (to - $Pivot/Dirt/Throw.global_position).normalized() * force
	emit_signal("throw_dirt_shovel", from, direction, shovel)

func _on_Bucket_fill(position: Vector2, capacity) -> void:
	emit_signal("fill_bucket", position, capacity, bucket)

func _on_Bucket_empty(position: Vector2, blocks: Array) -> void:
	emit_signal("empty_bucket", position, blocks, bucket)
