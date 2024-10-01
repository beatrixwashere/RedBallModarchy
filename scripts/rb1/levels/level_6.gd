extends Node
## handles level 6 specific mechanics

var drop_1_active: bool = false
var drop_2_active: bool = false
var drop_3_active: bool = false


func _physics_process(_delta: float) -> void:
	# rotate spinners
	get_node("../../objects/spin").rotation += PI * 0.3 / 31
	get_node("../../objects/spin/body").rotation += 0
	get_node("../../objects/back_ball_1").rotation -= PI * 0.2 / 31
	get_node("../../objects/back_ball_1/body").rotation -= 0
	get_node("../../objects/back_ball_2").rotation -= PI * 0.2 / 31
	get_node("../../objects/back_ball_2/body").rotation -= 0
	get_node("../../objects/back_ball_3").rotation -= PI * 0.2 / 31
	get_node("../../objects/back_ball_3/body").rotation -= 0
	
	# check for drop contact
	if get_node("../..").redball.contact_monitor:
		for i in get_node("../..").redball.get_colliding_bodies():
			if i.get_parent().name == "drop_1":
				drop_1_active = true
			if i.get_parent().name == "drop_2":
				drop_2_active = true
			if i.get_parent().name == "drop_3":
				drop_3_active = true
	
	# 
