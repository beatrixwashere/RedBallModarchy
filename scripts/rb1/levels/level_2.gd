extends Node
## handles level 2 specific mechanics

var move_platform_direction: int = 1


func _physics_process(_delta: float) -> void:
	# moving platform
	if get_node("../../objects/move_platform").position.x < 0:
		move_platform_direction = 1
	if get_node("../../objects/move_platform").position.x > 160:
		move_platform_direction = -1
	get_node("../../objects/move_platform").linear_velocity = Vector2(60 * move_platform_direction, 0)
	
	# joint line
	get_node("../../objects/kick_ball/line").points = [
		get_node("../../objects/kick_ball/b2iDistanceJoint").position,
		get_node("../../objects/kick_ball/polygon").position
	]
