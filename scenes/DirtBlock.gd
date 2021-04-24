extends Area2D

var g : Vector2 = Vector2(0, 4062)
var velocity: Vector2 = Vector2.ZERO
var type: int = 0

func initialize(pos: Vector2, vel: Vector2, block_type: int) -> void:
	global_position = pos
	velocity = vel
	type = block_type

func _physics_process(delta):
	velocity += g * delta
	global_position += velocity * delta
