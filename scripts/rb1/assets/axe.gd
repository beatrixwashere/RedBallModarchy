extends Node2D
## handles the axes present in level 4 and 16

var switch_point: int = 0
var accel: float = (1/31.0)*2.5
var velocity: float = 0
@export var direction: int


func _physics_process(_delta: float) -> void:
	if direction == 1:
		if rotation_degrees > switch_point:
			direction *= -1
		else:
			velocity += (accel*direction)
			rotation_degrees += velocity
	else:
		if rotation_degrees < switch_point:
			direction *= -1
		else:
			velocity += (accel*direction)
			rotation_degrees += velocity
