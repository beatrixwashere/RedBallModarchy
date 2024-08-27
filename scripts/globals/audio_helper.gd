extends Node
## this script is always running ingame, and can be used to play audio.


## loads audio. if the name already exists, it will be overwritten. you can opt out of this behavior with a parameter.
func load_audio(aname: String, apath: String, abus: String, overwrite: bool = true) -> void:
	# prevent overwriting
	if not overwrite and has_node(aname):
		return
	
	# remove possible duplicate
	unload_audio(aname)
	
	# create audio node and add as child
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.name = aname
	audio.stream = load(apath) as AudioStream
	audio.bus = abus
	add_child(audio)


## unloads audio.
func unload_audio(aname: String) -> void:
	# remove audio node
	if has_node(aname):
		remove_child(get_node(aname))


## plays audio.
func play(aname: String, restart: bool = true) -> void:
	# play audio node if it exists
	if has_node(aname):
		# prevent restarting if the parameter is passed
		if get_node(aname).playing and not restart:
			return
		get_node(aname).play()


## stops audio.
func stop(aname: String) -> void:
	# stop audio node if it exists
	if has_node(aname):
		get_node(aname).stop()


## changes audio volume in decibels.
func change_volume(aname: String, avol: float) -> void:
	if has_node(aname):
		get_node(aname).volume_db = avol
