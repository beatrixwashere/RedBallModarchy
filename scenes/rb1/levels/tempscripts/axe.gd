extends Node2D

var switch_point = 0
var accel = (1/31.0)*2.5
var velocity = 0
@export var direction:int

func _process(delta):
	if direction == 1:
		if self.rotation_degrees > switch_point:
			direction *= -1
		else:
			velocity += (accel*direction)
			self.rotation_degrees += velocity
	else:
		if self.rotation_degrees < switch_point:
			direction *= -1
		else:
			velocity += (accel*direction)
			self.rotation_degrees += velocity
	
	
