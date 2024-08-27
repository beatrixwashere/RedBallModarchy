extends Node
## this script is used extensively for loading mods, and can be accessed from anywhere.


## adds a function to the level.
func add_function(func_name: String, func_callable: Callable) -> void:
	get_tree().current_scene.funcs[func_name] = func_callable


## adds a function to the loop.
func add_to_loop(func_name: String) -> void:
	get_tree().current_scene.loop.append(func_name)


## adds audio to load into the level.
func add_audio(audio_name: String, audio_path: String) -> void:
	get_tree().current_scene.audio[audio_name] = audio_path


## tags audio as music.
func add_to_music(audio_name: String) -> void:
	get_tree().current_scene.music.append(audio_name)
