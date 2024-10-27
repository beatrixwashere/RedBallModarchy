extends Window
## this script is used for viewing performance statistics and using console commands.

## stores each command available in the console; add to this using [code]DebugTools.commands[NAME] = CALLABLE[/code]
var commands: Dictionary = {
	"list": _cmd_list,
	"pos": _cmd_pos,
	"vel": _cmd_vel,
	"kill": _cmd_kill,
}


## updates performance info.
func _physics_process(_delta: float) -> void:
	# toggle debug info visibility
	if InputHelper.pressed[KEY_F1]:
		visible = not visible
		if visible:
			$tabs/performance/body.text = performance_info()
			performance_update_loop()
	InputHelper.locked = $tabs/console/typing/edit.has_focus()


## runs a command in the console.
func run_command(cmd: String) -> void:
	# print command to console
	output_message("> " + cmd)
	
	# reset lineedit
	$tabs/console/typing/edit.release_focus()
	InputHelper.locked = false
	$tabs/console/typing/edit.text = ""
	
	# separate command and arguments
	var args: PackedStringArray = cmd.split(" ")
	var cmd_name: String = args[0]
	args.remove_at(0)
	
	# run command if it exists
	for i in commands.keys():
		if cmd_name == i:
			commands[i].call(args)
			return
	
	# if it doesn't exist, print a message
	output_message("command not found")


## append a message to the console.
func output_message(msg: String) -> void:
	var new_label: RichTextLabel = $tabs/console/container/vbox/label.duplicate()
	new_label.text = " " + msg
	$tabs/console/container/vbox.add_child(new_label)
	await get_tree().create_timer(0.25).timeout
	$tabs/console/container.set_deferred("scroll_vertical", 1_000_000_000)


# list available commands
func _cmd_list(_args: PackedStringArray) -> void:
	var list: String = ""
	for i in commands.keys():
		list += i + ", "
	list = list.substr(0, list.length() - 2)
	output_message(list)


# edit red ball's position
func _cmd_pos(args: PackedStringArray) -> void:
	if args.size() == 2:
		get_tree().current_scene.redball.position = Vector2(float(args[0]), float(args[1]))
		output_message("changed position to (" + str(float(args[0])) + ", " + str(float(args[1])) + ")")
	else:
		output_message("invalid arguments (format is pos x y)")


# edit red ball's position
func _cmd_vel(args: PackedStringArray) -> void:
	if args.size() == 2:
		get_tree().current_scene.redball.linear_velocity = Vector2(float(args[0]), float(args[1]))
		output_message("changed velocity to (" + str(float(args[0])) + ", " + str(float(args[1])) + ")")
	else:
		output_message("invalid arguments (format is vel x y)")


# kill red ball
func _cmd_kill(_args: PackedStringArray) -> void:
	get_tree().current_scene.funcs["redball_die"].call()
	output_message("killed red ball")


## only updates every second.
func performance_update_loop() -> void:
	await get_tree().create_timer(1.0).timeout
	if visible:
		$tabs/performance/body.text = performance_info()
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
