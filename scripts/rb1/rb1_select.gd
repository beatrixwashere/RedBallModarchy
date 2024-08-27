extends Control
## handles the rb1 level select.

const level_tab: PackedScene = preload("res://scenes/menu/level_tab.tscn")
const level_button: PackedScene = preload("res://scenes/menu/level_button.tscn")


# do everything here lmao
func _ready() -> void:
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
		for j in DirAccess.open("res://_mods/" + i + "/levels").get_files():
			var _level_button: Control = level_button.instantiate()
			_level_button.get_node("label").text = j.get_basename()
			_level_button.get_node("button").connect(
					"button_down",
					get_tree().change_scene_to_file.bind("res://_mods/" + i + "/levels/" + j)
			)
			$packs.get_node(i + "/list").add_child(_level_button)
	
	# handle vanilla levels
	for i in DirAccess.open("res://scenes/rb1/levels").get_files():
		var _level_button: Control = level_button.instantiate()
		_level_button.get_node("label").text = i.get_basename()
		_level_button.get_node("button").connect(
				"button_down",
				get_tree().change_scene_to_file.bind("res://scenes/rb1/levels/" + i)
		)
		$packs/RB1/list.add_child(_level_button)
	
	# connect back button
	$back.connect("button_down", get_tree().change_scene_to_file.bind("res://scenes/menu/menu.tscn"))
