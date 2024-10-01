extends Node
## handles level 3 specific mechanics

var move_platform_direction_1: int = 1
var move_platform_direction_2: int = 1

func _physics_process(_delta: float) -> void:
	# moving platforms
	if get_node("../../objects/movePlatform1").position.y < 270:
		move_platform_direction_1 = 1
	if get_node("../../objects/movePlatform1").position.y > 425:
		move_platform_direction_1 = -1
	if get_node("../../objects/movePlatform2").position.y < 116:
		move_platform_direction_2 = 1
	if get_node("../../objects/movePlatform2").position.y > 271:
		move_platform_direction_2 = -1
	get_node("../../objects/movePlatform1").position.y += 3 * move_platform_direction_1
	get_node("../../objects/movePlatform1/body").position.y += 0
	get_node("../../objects/movePlatform2").position.y += 3 * move_platform_direction_2
	get_node("../../objects/movePlatform2/body").position.y += 0
