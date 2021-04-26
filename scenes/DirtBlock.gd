extends RigidBody2D

var type : int = 0
var motionless : int = 0

func initialize(new_position: Vector2, impulse: Vector2, block_type: int) -> void:
	global_position = new_position
	type = block_type
	angular_velocity = (randf() - 0.5) * 20
	apply_central_impulse(impulse)
	$SandParticle.emitting = true

func _physics_process(_delta):
	if linear_velocity.length() < 20:
		motionless += 1
		if motionless > 20:
			sleeping = true
			emit_signal("sleeping_state_changed")

func _on_Timer_timeout():
	set_collision_mask_bit(5, true)
