extends Control
## sets up the menu for selecting mods and loading the game

const mod_row: PackedScene = preload("res://scenes/menu/mod_row.tscn")


func _ready() -> void:
	# reload if mods folder exists
	var file: FileAccess = FileAccess.open("user://modsfolder.modarchy", FileAccess.READ)
	if file:
		reload_mods(file.get_line())


## creates a mod row node
func create_mod_row(left: String, right: String = "") -> void:
	# instantiate node
	var row: Control = mod_row.instantiate()
	%modlist.add_child(row)
	
	# visibility toggle lambda function for buttons
	var toggle_visibility: Callable = func _toggle_visibility(c: Control) -> void:
		c.visible = not c.visible
	
	# set up buttons
	row.get_node("left/label").text = left
	row.get_node("left").connect("button_down", toggle_visibility.bind(row.get_node("left/check")))
	if right != "":
		row.get_node("right/label").text = right
		row.get_node("right").connect("button_down", toggle_visibility.bind(row.get_node("right/check")))
	else:
		row.get_node("right").queue_free()


## loads mods and enters the game
func load_game(scene_path: String) -> void:
	# get mods folder path
	var mods_path: String = FileAccess.open("user://modsfolder.modarchy", FileAccess.READ).get_line()
	
	# iterate through modlist to find enabled mods
	for i in %modlist.get_children():
		for j in i.get_children(): # mod_row buttons
			if j.get_node("check").visible:
				ModAPI.load_mod(mods_path + "/" + j.get_node("label").text + ".pck")
	
	print(DirAccess.open("res://_mods").get_directories())
	
	# load red ball scene
	get_tree().change_scene_to_file(scene_path)


## initializes the modlist using the mods folder
func reload_mods(path: String) -> void:
	# iterate through each file in the mods folder
	var dir: DirAccess = DirAccess.open(path)
	var modfiles: Array[String] = []
	for i in dir.get_files():
		# check for pck file extension
		if i.get_extension() == "pck":
			modfiles.append(i)
	
	# iterate through modfiles and generate modlist
	while modfiles.size() > 1:
		create_mod_row(modfiles.pop_front().get_basename(), modfiles.pop_front().get_basename())
	# make single button row if needed
	if modfiles.size() == 1:
		create_mod_row(modfiles.pop_front().get_basename())
	
	# add extra control node to fix scrolling
	%modlist.add_child(Control.new())


## sets the mods folder
func set_mods_folder(path: String) -> void:
	# save path to file and reload
	var file: FileAccess = FileAccess.open("user://modsfolder.modarchy", FileAccess.WRITE)
	file.store_line(path)
	reload_mods(path)
