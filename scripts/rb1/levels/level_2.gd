extends Node
## handles level 2 specific mechanics

var move_platform_direction: int = 1

func _physics_process(_delta: float) -> void:
	# moving platform
	if get_node("../../objects/move_platform").position.x < 390:
		move_platform_direction = 1
	if get_node("../../objects/move_platform").position.x > 550:
		move_platform_direction = -1
	get_node("../../objects/move_platform").position.x += 2 * move_platform_direction
	get_node("../../objects/move_platform/body").position.x += 0
	
	# joint line
	get_node("../../objects/kick_ball/joint/line").points = [
		get_node("../../objects/kick_ball/joint").position,
		get_node("../../objects/kick_ball/polygon").position
	]
