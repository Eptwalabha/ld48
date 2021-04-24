class_name Player extends KinematicBody2D

signal throw_dirt

export(float) var j_duration := .5
export(float) var j_tiles := 3.0

onready var anim_tree : AnimationTree = $AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0
var is_jumping: bool = false

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

func _process(delta):
	if Input.is_action_just_pressed("move_left"):
		pivot_left(true)
		$Pivot.scale.x = -1
	if Input.is_action_just_pressed("move_right"):
		pivot_left(false)
		$Pivot.scale.x = 1
	
	if is_jumping and Input.is_action_just_released("move_jump"):
		is_jumping = false

func pivot_left(left: bool) -> void:
	var s: float = -1.0 if left else 1.0
	$Pivot.scale.x = s
	$RayStep.scale.x = s
	$RayStep2.scale.x = s
	$RayHead.scale.x = s

func get_throw_vectors() -> Array:
	var p = $Pivot/Dirt.global_position
	var d = $Pivot/Dirt/Throw.global_position - p
	return [p, d.normalized() * 400]

func is_digging() -> bool:
	return state_machine.get_current_node() == "dig"

func _physics_process(delta):
	
	var dir: float = 0.0;
	if !is_digging():
		dir -= float(Input.is_action_pressed("move_left"))
		dir += float(Input.is_action_pressed("move_right"))
		if dir != 0.0:
			state_machine.travel("move")
	
#	if dir != 0 and is_realy_on_floor() and $RayStep.is_colliding():
#		if not ($RayHead.is_colliding() or $RayStep2.is_colliding()):
#			velocity.y -= 200
	
	velocity.x = dir * speed
	
	if is_realy_on_floor() and Input.is_action_just_pressed("move_jump"):
		velocity.y -= jump
	
	if ! is_realy_on_floor():
		velocity += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP)

func is_realy_on_floor() -> bool:
	return is_on_floor() or $FloorL.is_colliding() or $FloorR.is_colliding()

