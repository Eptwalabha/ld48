class_name Player extends KinematicBody2D


export(float) var j_duration := .5
export(float) var j_tiles := 3.0

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0
var is_jumping: bool = false

func _init():
	var hj = j_duration / 2.0
	var d = -pow(hj, 2) + hj * j_duration
	var h = j_tiles * 16.0
	gravity.y = 2 * (h / d)
	jump = (h / d) * j_duration

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

func _physics_process(delta):
	
	var dir: float = 0.0;
	dir -= float(Input.is_action_pressed("move_left"))
	dir += float(Input.is_action_pressed("move_right"))
	
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

