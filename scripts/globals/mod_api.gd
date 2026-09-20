extends Node
## this script is used extensively for loading mods, and can be accessed from anywhere.

## stores global modules.
var global_modules: Array[String] = [
	
]


## adds a function to the level.
func add_function(func_name: String, func_callable: Callable) -> void:
	get_tree().current_scene.funcs[func_name] = func_callable


## adds en entity to check for entering in the level. func_name must already be added, and must have an area2d argument.
func add_entity_enter(entity_name: String, func_name: String) -> void:
	get_tree().current_scene.entities_enter[entity_name] = func_name


## adds en entity to check for exiting in the level. func_name must already be added, and must have an area2d argument.
func add_entity_exit(entity_name: String, func_name: String) -> void:
	get_tree().current_scene.entities_exit[entity_name] = func_name


## adds a function to the loop.
func add_to_loop(func_name: String) -> void:
	get_tree().current_scene.loop.append(func_name)


## adds audio to load into the level.
func add_audio(audio_name: String, audio_path: String) -> void:
	get_tree().current_scene.audio[audio_name] = audio_path


## tags audio as music.
func add_to_music(audio_name: String) -> void:
	get_tree().current_scene.music.append(audio_name)


## adds a global module.
func add_global_module(mod_name: String) -> void:
	global_modules.append(mod_name)
	
	# if replace_files.txt exists in the mod, read the file
	if DirAccess.open("res://_mods/" + mod_name).file_exists("replace_files.txt"):
		var file: FileAccess = FileAccess.open("res://_mods/" + mod_name + "/replace_files.txt", FileAccess.READ)
		var next: String = file.get_line()
		while next != "":
			var paths: PackedStringArray = next.split(" -> ")
			ResourceSaver.save(load(paths[1]), paths[0])
			next = file.get_line()


## loads all global modules. these will be deleted after their _ready function is called.
func load_global_modules() -> void:
	for i in global_modules:
		if FileAccess.file_exists("res://_mods/" + i + "/global.tscn" + ("" if OS.has_feature("editor") else ".remap")):
			var n: Node = load("res://_mods/" + i + "/global.tscn").instantiate()
			get_tree().current_scene.get_node("modules").add_child(n)


## unloads all global modules.
func unload_global_modules() -> void:
	for i in get_children():
		i.free()


## unloads all mods from the current instance.
func unload_all_mods(path: String = "res://_mods", rm_root: bool = false) -> void:
	if DirAccess.dir_exists_absolute("res://_mods"):
		var dir: DirAccess = DirAccess.open(path)
		for i in dir.get_files():
			dir.remove(i)
		for i in dir.get_directories():
			unload_all_mods(path + "/" + i, true)
		if rm_root:
			DirAccess.remove_absolute(path)
	global_modules = []
