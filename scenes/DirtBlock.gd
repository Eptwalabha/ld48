extends RigidBody2D

var type : int = 0
var motionless : int = 0
var first_impulse : Vector2 = Vector2.ZERO

func initialize(new_position: Vector2, impulse: Vector2, block_type: int) -> void:
	global_position = new_position
	type = block_type
	# apply_torque_impulse does not work for some reason.
	apply_torque_impulse(randf() * 360.0 - 180.0)
	apply_central_impulse(impulse)
	$SandParticle.emitting = true

func _physics_process(_delta):
	if linear_velocity.length() < 20:
		motionless += 1
		if motionless > 20:
			sleeping = true
			emit_signal("sleeping_state_changed")

func _on_Timer_timeout():
	print("yo")
	set_collision_mask_bit(5, true)
