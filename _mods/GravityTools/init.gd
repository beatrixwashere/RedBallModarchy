extends Node
## gravity helper functions

var gravity: float ## stores current gravity


# add functions
func _ready() -> void:
	# initialize gravity variable
	gravity = PhysicsServer2D.area_get_param(
			get_viewport().find_world_2d().space,
			PhysicsServer2D.AREA_PARAM_GRAVITY
	)
	set_gravity(300)
	
	# call mod api
	ModAPI.add_function("switch_gravity", switch_gravity)
	ModAPI.add_to_loop("switch_gravity")


## set physics gravity
func set_gravity(val: float) -> void:
	# set the gravity
	PhysicsServer2D.area_set_param(
			get_viewport().find_world_2d().space,
			PhysicsServer2D.AREA_PARAM_GRAVITY,
			val
	)
	
	# change gravity variable to new value
	gravity = val


## switch gravity when space is pressed
func switch_gravity() -> void:
	if InputHelper.pressed[KEY_SPACE]:
		# set gravity
		set_gravity(-gravity)
		
		# invert jump related variables
		get_tree().current_scene.jump_velocity *= -1
		get_tree().current_scene.jump_slowfall *= -1
		get_tree().current_scene.point0.y *= -1
		get_tree().current_scene.point1.y *= -1
		get_tree().current_scene.point2.y *= -1
