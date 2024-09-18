extends Control
## sets up the menu for selecting mods and loading the game

const mod_row: PackedScene = preload("res://scenes/menu/mod_row.tscn")


func _ready() -> void:
	# verify mods folder integrity, if it doesn't exist then force the user to set a new one
	if FileAccess.file_exists("user://modsfolder.modarchy"):
		var path: String = FileAccess.open("user://modsfolder.modarchy", FileAccess.READ).get_pascal_string()
		if path != "" and DirAccess.dir_exists_absolute(path):
			reload_mods()
		else:
			$mods_folder_popup.visible = true
	else:
		$mods_folder_popup.visible = true
	
	# unload mods (only in exported builds)
	if not OS.has_feature("editor"):
		ModAPI.unload_all_mods()
	
	# clear global modules
	ModAPI.global_modules = []


## creates a mod row node
func create_mod_row(left: String, right: String = "") -> void:
	# instantiate node
	var row: Control = mod_row.instantiate()
	%modlist.add_child(row)
	
	# visibility cycle lambda function for buttons
	var cycle_mode: Callable = func _cycle_mode(c: Control) -> void:
		if c.get_node("check").visible:
			c.get_node("check").visible = false
			c.get_node("global").visible = true
		elif c.get_node("global").visible:
			c.get_node("global").visible = false
		else:
			c.get_node("check").visible = true
	
	# set up buttons
	row.get_node("left/label").text = left
	row.get_node("left").connect("button_down", cycle_mode.bind(row.get_node("left")))
	if right != "":
		row.get_node("right/label").text = right
		row.get_node("right").connect("button_down", cycle_mode.bind(row.get_node("right")))
	else:
		row.get_node("right").queue_free()


## loads mods and enters the game
func load_game(scene_path: String) -> void:
	# get mods folder path
	var mods_path: String = FileAccess.open("user://modsfolder.modarchy", FileAccess.READ).get_pascal_string()
	
	# iterate through modlist to find enabled mods (only in exported builds)
	for i in %modlist.get_children():
		for j in i.get_children(): # mod_row buttons
			if (j.get_node("check").visible or j.get_node("global").visible) and not OS.has_feature("editor"):
				if FileAccess.file_exists(mods_path + "/" + j.get_node("label").text + ".pck"):
					ProjectSettings.load_resource_pack(mods_path + "/" + j.get_node("label").text + ".pck")
					if j.get_node("global").visible:
						ModAPI.add_global_module(j.get_node("label").text)
				else:
					ProjectSettings.load_resource_pack(mods_path + "/" + j.get_node("label").text + ".zip")
					if j.get_node("global").visible:
						ModAPI.add_global_module(j.get_node("label").text)
	
	# load red ball scene
	get_tree().change_scene_to_file(scene_path)


## initializes the modlist using the mods folder
func reload_mods(filter: String = "") -> void:
	# clear modlist
	for i in %modlist.get_children():
		i.free()
	
	# get mods folder path
	var mods_path: String = FileAccess.open("user://modsfolder.modarchy", FileAccess.READ).get_pascal_string()
	
	# iterate through each file in the mods folder
	var dir: DirAccess = DirAccess.open(mods_path)
	var modfiles: Array[String] = []
	for i in dir.get_files():
		# filter out mods when searching and check for pck/zip file extension
		if (filter == "" or filter in i) and (i.get_extension() == "pck" or i.get_extension() == "zip"):
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
	file.store_pascal_string(path)
	file.flush()
	reload_mods()
	$mods_folder_popup.visible = false


## toggle all mods
func toggle_all(check: bool) -> void:
	# iterate through mod buttons
	for i in %modlist.get_children():
		for j in i.get_children():
			j.get_node("check").visible = check
			j.get_node("global").visible = false
