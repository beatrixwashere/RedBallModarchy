extends RigidBody2D


func _physics_process(delta):
	if get_colliding_bodies():
		freeze = false
	
