extends Node
## handles level 6 specific mechanics


func _physics_process(_delta: float) -> void:
	# rotate spinners
	#get_node("../../objects/spin").rotation += PI * 0.3 / 31
	#get_node("../../objects/spin").angular_velocity = PI * 0.3 / 31
	#get_node("../../objects/back_ball_1").rotation -= PI * 0.2 / 31
	#get_node("../../objects/back_ball_2").rotation -= PI * 0.2 / 31
	#get_node("../../objects/back_ball_3").rotation -= PI * 0.2 / 31
	
	# check for drop contact
	if get_node("../..")._is_alive:
		for i in get_node("../..").contact_list:
			if "drop" in i.get_parent().name:
				get_node("../../objects/" + get_parent().name).density = 1
				get_node("../../objects/" + get_parent().name).wake_up()
