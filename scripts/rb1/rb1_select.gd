extends Control
## handles the rb1 level select.

const level_tab: PackedScene = preload("res://scenes/menu/level_tab.tscn")
const level_button: PackedScene = preload("res://scenes/menu/level_button.tscn")


# do (almost) everything here lmao
func _ready() -> void:
	# set up audio
	AudioHelper.unload_all_audio()
	AudioHelper.load_audio("rb1_hover", "res://audio/rb1/hover.mp3", "sfx")
	AudioHelper.load_audio("rb1_click", "res://audio/rb1/click.mp3", "sfx")
	
	# get mod folders with levels
	var mods_with_levels: Array[String] = []
	var mods_dir: DirAccess = DirAccess.open("res://_mods")
	for i in mods_dir.get_directories():
		if mods_dir.dir_exists(i + "/levels"):
			mods_with_levels.append(i)
	
	# set up level select
	for i in mods_with_levels:
		# instantiate tabs
		var _level_tab: Control = level_tab.instantiate()
		_level_tab.name = i
		$packs.add_child(_level_tab)
		
		# instantiate buttons
		# note: get_basename is used an extra time in exported builds to remove the .remap extension
		for j in DirAccess.open("res://_mods/" + i + "/levels").get_files():
			# safeguard for nonlevel files
			if j.get_extension() == "tscn" or j.get_basename().get_extension() == "tscn":
				var _level_button: Control = level_button.instantiate()
				
				# set properties
				_level_button.get_node("label").text = \
						j.get_basename() if OS.has_feature("editor") else j.get_basename().get_basename()
				_level_button.get_node("button").connect(
						"button_down",
						get_tree().change_scene_to_file.bind(
								"res://_mods/" + i + "/levels/" + (j if OS.has_feature("editor") else j.get_basename())
						)
				)
				
				# connect audio
				_level_button.get_node("button").connect("mouse_entered", AudioHelper.play.bind("rb1_hover"))
				_level_button.get_node("button").connect("button_down", AudioHelper.play.bind("rb1_click"))
				
				$packs.get_node(i + "/list").add_child(_level_button)
	
	# handle vanilla levels
	# note: get_basename is used an extra time in exported builds to remove the .remap extension
	for i in DirAccess.open("res://scenes/rb1/levels").get_files():
		var _level_button: Control = level_button.instantiate()
		
		# set properties
		_level_button.get_node("label").text = \
				i.get_basename() if OS.has_feature("editor") else i.get_basename().get_basename()
		_level_button.get_node("button").connect(
				"button_down",
				get_tree().change_scene_to_file.bind(
						"res://scenes/rb1/levels/" + (i if OS.has_feature("editor") else i.get_basename())
				)
		)
		
		# connect audio
		_level_button.get_node("button").connect("mouse_entered", AudioHelper.play.bind("rb1_hover"))
		_level_button.get_node("button").connect("button_down", AudioHelper.play.bind("rb1_click"))

		$packs/RB1/list.add_child(_level_button)
	
	# connect back button
	$back.connect("button_down", get_tree().change_scene_to_file.bind("res://scenes/menu/menu.tscn"))
	
	# set up datahelper variables
	DataHelper.data["cp_index"] = 0


# load pack info when switching tabs
func load_pack_info(packidx: int) -> void:
	# get new pack name
	var packname: String = $packs.get_tab_title(packidx)
	
	# remove previous pack info node
	if $info_container.get_child_count() > 0:
		$info_container.remove_child($info_container.get_child(0))
	
	# get path for new pack
	var packpath: String = ""
	if packname == "RB1":
		packpath = "res://scenes/rb1/pack_info.tscn"
	elif FileAccess.file_exists("res://_mods/" + packname + "/pack_info.tscn" + ("" if OS.has_feature("editor") else ".remap")):
		packpath = "res://_mods/" + packname + "/pack_info.tscn"
	
	# instantiate new pack info scene
	if packpath != "":
		$info_container.add_child(load(packpath).instantiate())
