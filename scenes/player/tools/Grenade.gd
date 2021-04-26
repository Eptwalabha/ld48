class_name Grenade extends RigidBody2D

signal blow_up(position, force, radius)

var timeout: int = 4
var force: float = 1000.0
var radius: float = 5.0
var filter: Array = []

func initialize(new_position: Vector2, impulse: Vector2, the_filter: Array) -> void:
	global_position = new_position
	angular_velocity = (randf() - 0.5) * 20
	filter = the_filter
	apply_central_impulse(impulse)

func _on_Timer_timeout():
	timeout -= 1
	if timeout == 0:
		emit_signal("blow_up", global_position, force, radius)
		queue_free()
	else:
		$Timer.start()
