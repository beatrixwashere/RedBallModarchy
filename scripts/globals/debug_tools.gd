extends CanvasLayer
## this script is attached to a global scene, and is not meant to be used like a helper.
# TODO: make this less resource intensive when visible


## updates performance info.
func _physics_process(_delta: float) -> void:
	# toggle debug info visibility
	if InputHelper.pressed[KEY_F1]:
		$info.visible = not $info.visible
		if $info.visible:
			$info/body.text = performance_info()
			performance_update_loop()


## only updates every second.
func performance_update_loop() -> void:
	await get_tree().create_timer(1.0).timeout
	if $info.visible:
		$info/body.text = performance_info()
		performance_update_loop()


## returns formatted performance statistics.
func performance_info() -> String:
	var output:String = ""
	output += "TIME_FPS: " + str(Performance.get_monitor(Performance.TIME_FPS)) + " "
	output += "(" + str(floor(1.0 / (Performance.get_monitor(Performance.TIME_PROCESS) + Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))) + ")\n"
	output += "TIME_PROCESS: " + str(snapped(Performance.get_monitor(Performance.TIME_PROCESS), 0.0001)) + "\n"
	output += "TIME_PHYSICS_PROCESS: " + str(snapped(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS), 0.0001)) + "\n"
	output += "TIME_NAVIGATION_PROCESS: " + str(snapped(Performance.get_monitor(Performance.TIME_NAVIGATION_PROCESS), 0.0001)) + "\n\n"
	if OS.has_feature("editor"):
		output += "MEMORY_STATIC: " + str(snapped(Performance.get_monitor(Performance.MEMORY_STATIC)/1048576, 0.01)) + "\n"
		output += "MEMORY_STATIC_MAX: " + str(snapped(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)/1048576, 0.01)) + "\n"
		output += "MEMORY_MESSAGE_BUFFER_MAX: " + str(snapped(Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX)/1048576, 0.01)) + "\n\n"
	output += "OBJECT_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_COUNT)) + "\n"
	output += "OBJECT_RESOURCE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)) + "\n"
	output += "OBJECT_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) + "\n"
	output += "OBJECT_ORPHAN_NODE_COUNT: " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)) + "\n\n"
	output += "RENDER_TOTAL_OBJECTS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)) + "\n"
	output += "RENDER_TOTAL_PRIMITIVES_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)) + "\n"
	output += "RENDER_TOTAL_DRAW_CALLS_IN_FRAME: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)) + "\n"
	output += "RENDER_VIDEO_MEM_USED: " + str(snapped(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1048576, 0.01)) + "\n"
	output += "RENDER_TEXTURE_MEM_USED: " + str(snapped(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1048576, 0.01)) + "\n"
	output += "RENDER_BUFFER_MEM_USED: " + str(snapped(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED)/1048576, 0.01)) + "\n\n"
	output += "PHYSICS_2D_ACTIVE_OBJECTS: " + str(Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS)) + "\n"
	output += "PHYSICS_2D_COLLISION_PAIRS: " + str(Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)) + "\n"
	output += "PHYSICS_2D_ISLAND_COUNT: " + str(Performance.get_monitor(Performance.PHYSICS_2D_ISLAND_COUNT)) + "\n\n"
	output += "PHYSICS_3D_ACTIVE_OBJECTS: " + str(Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS)) + "\n"
	output += "PHYSICS_3D_COLLISION_PAIRS: " + str(Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS)) + "\n"
	output += "PHYSICS_3D_ISLAND_COUNT: " + str(Performance.get_monitor(Performance.PHYSICS_3D_ISLAND_COUNT)) + "\n\n"
	output += "NAVIGATION_ACTIVE_MAPS: " + str(Performance.get_monitor(Performance.NAVIGATION_ACTIVE_MAPS)) + "\n"
	output += "NAVIGATION_REGION_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_REGION_COUNT)) + "\n"
	output += "NAVIGATION_AGENT_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_AGENT_COUNT)) + "\n"
	output += "NAVIGATION_LINK_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_LINK_COUNT)) + "\n"
	output += "NAVIGATION_POLYGON_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_POLYGON_COUNT)) + "\n"
	output += "NAVIGATION_EDGE_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_EDGE_COUNT)) + "\n"
	output += "NAVIGATION_EDGE_MERGE_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_EDGE_MERGE_COUNT)) + "\n"
	output += "NAVIGATION_EDGE_CONNECTION_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_EDGE_CONNECTION_COUNT)) + "\n"
	output += "NAVIGATION_EDGE_FREE_COUNT: " + str(Performance.get_monitor(Performance.NAVIGATION_EDGE_FREE_COUNT)) + "\n"
	return output
