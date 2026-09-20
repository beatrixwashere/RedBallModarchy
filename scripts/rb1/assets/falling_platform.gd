extends RigidBody2D
## handles the falling platforms in multiple levels


func _physics_process(_delta: float) -> void:
	if get_colliding_bodies():
		freeze = false
