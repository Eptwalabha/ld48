class_name Player extends KinematicBody2D

# warning-ignore:unused_signal
signal throw_dirt

export(float) var j_duration := .5
export(float) var j_tiles := 5.0
export(int) var max_range := 3

onready var anim_tree : AnimationTree = $AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0

var is_jump_pressed: bool = false
var is_grounded: bool = false
var is_walking: bool = false
var is_wallriding: bool = false
var is_facing_left: bool = true

func _ready():
	state_machine = anim_tree.get("parameters/playback")
	var hj = j_duration / 2.0
	var d = -pow(hj, 2) + hj * j_duration
	var h = j_tiles * 16.0
	gravity.y = 2 * (h / d)
	jump = (h / d) * j_duration

func dig() -> void:
	if is_digging():
		return
	state_machine.travel("dig")

func is_moving() -> bool:
	return is_walking or !is_grounded

func get_tool() -> int:
	return 0

func _process(_delta):
	if Input.is_action_just_pressed("move_left"):
		pivot_left(true)
		$Pivot.scale.x = -1
	if Input.is_action_just_pressed("move_right"):
		pivot_left(false)
		$Pivot.scale.x = 1

	if is_jump_pressed and Input.is_action_just_released("move_jump"):
		is_jump_pressed = false

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
	if !is_digging():
		dir -= float(Input.is_action_pressed("move_left"))
		dir += float(Input.is_action_pressed("move_right"))
		is_facing_left = dir < 0

	velocity.x = dir * speed

	if (is_realy_on_floor() or is_wallriding) and Input.is_action_just_pressed("move_jump"):
		velocity.y -= jump

	velocity += gravity * delta

	if is_wallriding:
		velocity.y = min(velocity.y, 16 * 3)

	velocity = move_and_slide(velocity, Vector2.UP)

	is_wallriding = $Pivot/Wall.is_colliding() and velocity.y > 0
	is_grounded = is_realy_on_floor()
	is_walking = dir != 0.0
	update_anim_tree()

func update_anim_tree() -> void:
	anim_tree["parameters/conditions/grounded"] = is_grounded
	anim_tree["parameters/conditions/not_grounded"] = !is_grounded
	anim_tree["parameters/conditions/moving"] = is_walking
	anim_tree["parameters/conditions/not_moving"] = !is_walking

func is_realy_on_floor() -> bool:
	return is_on_floor() or $FloorL.is_colliding() or $FloorM.is_colliding() or $FloorR.is_colliding()
