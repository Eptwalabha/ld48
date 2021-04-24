class_name Player extends KinematicBody2D


export(float) var j_duration := .5
export(float) var j_tiles := 5.0

var gravity : Vector2 = Vector2(0, 4062);
var velocity: Vector2 = Vector2.ZERO
const speed: float = 16.0 * 20.0
var jump: float = 1015.0

func _init():
	var hj = j_duration / 2.0
	var d = -pow(hj, 2) + hj * j_duration
	var h = j_tiles * 16.0
	gravity.y = 2 * (h / d)
	jump = (h / d) * j_duration

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("move_left"):
		pivot_left(true)
		$Pivot.scale.x = -1
	if Input.is_action_just_pressed("move_right"):
		pivot_left(false)
		$Pivot.scale.x = 1

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
	
	if dir != 0 and $Floor.is_colliding() and $RayStep.is_colliding():
		if not ($RayHead.is_colliding() or $RayStep2.is_colliding()):
			velocity.y -= 200
	
	velocity.x = dir * speed
	
	velocity += gravity * delta
	
	if $Floor.is_colliding() and Input.is_action_just_pressed("move_jump"):
		velocity.y -= jump


	velocity = move_and_slide(velocity, Vector2.UP)
	

