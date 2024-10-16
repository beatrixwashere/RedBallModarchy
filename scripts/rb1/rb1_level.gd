extends Node2D
## this script handles an rb1 level

const deathpartscene: PackedScene = preload("res://scenes/rb1/assets/deathpart.tscn")

var funcs: Dictionary = {
	"redball_move": _redball_move,
	"redball_die": _redball_die,
	"redball_reset": _redball_reset,
	"camera_update": _camera_update,
	"checkpoint_hit": _checkpoint_hit,
	"finish_level": _finish_level,
	"press_button": _press_button,
}
var loop: Array[String] = [
	"redball_move",
	"camera_update",
]
var entities_enter: Dictionary = {
	"checkpoints": "checkpoint_hit",
	"flags": "finish_level",
	"spikes": "redball_die",
	"buttons": "press_button"
}
var entities_exit: Dictionary = {
	
}
var audio: Dictionary = {
	"rb1_bouncepad": "res://audio/rb1/bouncepad.mp3",
	"rb1_car": "res://audio/rb1/car.mp3",
	"rb1_checkbox": "res://audio/rb1/checkbox.mp3",
	"rb1_death": "res://audio/rb1/death.mp3",
	"rb1_flag": "res://audio/rb1/flag.mp3",
	"rb1_jump": "res://audio/rb1/jump.mp3",
	"rb1_landing": "res://audio/rb1/landing.mp3",
	"rb1_music": "res://audio/rb1/music.mp3",
	"rb1_train": "res://audio/rb1/train.mp3",
}
var music: Array[String] = [
	"rb1_music",
]

@export_group("redball_constants")
@export var speed_cap_floor: float = 150
@export var speed_cap_air: float = 75
@export var speed_accel_floor: float = 15
@export var speed_accel_air: float = 7.5
@export var jump_velocity: float = -165
@export var jump_slowfall: float = -2.5
@export_group("floor_points")
@export var point0: Vector2 = Vector2(-6, 11.4)
@export var point1: Vector2 = Vector2(0, 12)
@export var point2: Vector2 = Vector2(6, 11.4)
@export_group("misc")
@export var death_barrier: float = 550
@export var load_next: String = ""

var on_floor: bool = false

var _is_alive: bool = true
var _can_land: bool = false

@onready var redball: RigidBody2D = get_node("redball")
@onready var camera: Camera2D = get_node("camera")
@onready var rbhitbox: CollisionShape2D = get_node("redball/hitbox/collision")


# sets up the scene
func _ready() -> void:
	# set up datahelper values
	if not DataHelper.data.has("cp_index"):
		DataHelper.data["cp_index"] = 0
	if not DataHelper.data.has("music_volume"):
		DataHelper.data["music_volume"] = 10
	if not DataHelper.data.has("sfx_volume"):
		DataHelper.data["sfx_volume"] = 10
	
	# set red ball's and the camera's position
	redball.position = $entities/checkpoints.get_child(DataHelper.data["cp_index"]).position
	camera.position = $entities/checkpoints.get_child(DataHelper.data["cp_index"]).position
	
	# connect signals
	redball.get_node("hitbox").connect("area_entered", _redball_area_entered)
	redball.get_node("hitbox").connect("area_exited", _redball_area_exited)
	
	# load audio and play music
	for i in audio.keys():
		AudioHelper.load_audio(i, audio[i], "music" if i in music else "sfx", not i in music)
	AudioHelper.change_volume("rb1_flag", 9)
	AudioHelper.change_volume("rb1_music", -3)
	AudioHelper.play("rb1_music", false)
	
	# set up ui buttons
	var audio_function: Callable = func _audio_function(s: Sprite2D, bus_idx: int) -> void:
		AudioHelper.toggle_bus_audio(bus_idx)
		s.texture = load("res://images/rb1/sprites/sound" + ("off" if AudioServer.is_bus_mute(bus_idx) else "on") + ".png")
		s.get_node("button").release_focus()
	var open_pause_menu: Callable = func _open_pause_menu() -> void:
		get_tree().paused = true
		$ui/pause.visible = true
	$ui/music/button.connect("button_down", audio_function.bind($ui/music, 1))
	$ui/sfx/button.connect("button_down", audio_function.bind($ui/sfx, 2))
	$ui/menu/button.connect("button_down", open_pause_menu)
	for i in $ui/pause/buttons.get_children():
		i.connect("button_down", _pause_menu.bind(i.name))
	$ui/pause/base/music.text = "Music volume: -- " + str(DataHelper.data["music_volume"] * 10) + "% ++"
	$ui/pause/base/sfx.text = "Sfx volume: -- " + str(DataHelper.data["sfx_volume"] * 10) + "% ++"
	if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
		$ui/pause/base/window.text = "Window mode: Fullscreen"
	else:
		$ui/pause/base/window.text = "Window mode: Windowed"
	if has_node("ui/touch") and (OS.has_feature("android")):
		$ui/touch.visible = true
		$ui/touch/left.connect("pressed", InputHelper.manual_input.bind(KEY_A, true))
		$ui/touch/right.connect("pressed", InputHelper.manual_input.bind(KEY_D, true))
		$ui/touch/up.connect("pressed", InputHelper.manual_input.bind(KEY_W, true))
		$ui/touch/left.connect("released", InputHelper.manual_input.bind(KEY_A, false))
		$ui/touch/right.connect("released", InputHelper.manual_input.bind(KEY_D, false))
		$ui/touch/up.connect("released", InputHelper.manual_input.bind(KEY_W, false))
	
	# load global modules
	ModAPI.load_global_modules()
	
	# contact skin testing
	var queue: Array = get_tree().current_scene.get_children()
	while queue.size() > 0:
		if queue[0] is StaticBody2D or queue[0] is AnimatableBody2D:
			RapierPhysicsServer2D.body_set_extra_param(queue[0].get_rid(), 0, 0.5)
		queue.append_array(queue[0].get_children())
		queue.pop_front()


# loops every physics frame (31 fps)
func _physics_process(_delta: float) -> void:
	# call the game loop functions
	for i in loop:
		funcs[i].call()
	
	# check for death barrier
	if redball.position.y > death_barrier and _is_alive:
		funcs["redball_die"].call()
	
	# check for kill objects
	if redball.contact_monitor:
		for i in redball.get_colliding_bodies():
			if "-kill" in i.get_parent().name:
				funcs["redball_die"].call()
	
	# reset function
	if InputHelper.pressed[KEY_R]:
		funcs["redball_reset"].call()
	
	# pause keybinds
	if InputHelper.pressed[KEY_P] or InputHelper.pressed[KEY_ESCAPE]:
		get_tree().paused = true
		$ui/pause.visible = true
		InputHelper.pressed[KEY_P] = false
		InputHelper.pressed[KEY_ESCAPE] = false


# checks if a point is inside a body
func is_body_at_point(point: Vector2) -> bool:
	# create raycast at point argument
	var rc: RayCast2D = RayCast2D.new()
	rc.target_position = Vector2(0, 0)
	rc.hit_from_inside = true
	rc.position = point
	add_child(rc)
	
	# update raycast and return true if it hit a body
	rc.force_raycast_update()
	rc.queue_free()
	return rc.is_colliding()


# controls red ball's movement
func _redball_move() -> void:
	# check if red ball is on a surface
	#redball.get_node("floorchecks").rotation = -redball.rotation
	var check0: bool = is_body_at_point(redball.position + point0)
	var check1: bool = is_body_at_point(redball.position + point1)
	var check2: bool = is_body_at_point(redball.position + point2)
	on_floor = check0 or check1 or check2
	#redball.get_node("floorchecks/check0").visible = check0
	#redball.get_node("floorchecks/check1").visible = check1
	#redball.get_node("floorchecks/check2").visible = check2
	
	# process inputs
	if _can_land and on_floor and redball.get_contact_count() > 0:
		AudioHelper.play("rb1_landing")
		_can_land = false
	if (InputHelper.keys[KEY_D] or InputHelper.keys[KEY_RIGHT]):
		if on_floor and redball.linear_velocity.x < speed_cap_floor:
			redball.linear_velocity += Vector2(speed_accel_floor, 0)
		elif redball.linear_velocity.x < speed_cap_air:
			redball.linear_velocity += Vector2(speed_accel_air, 0)
	if (InputHelper.keys[KEY_A] or InputHelper.keys[KEY_LEFT]):
		if on_floor and redball.linear_velocity.x > -speed_cap_floor:
			redball.linear_velocity += Vector2(-speed_accel_floor, 0)
		elif redball.linear_velocity.x > -speed_cap_air:
			redball.linear_velocity += Vector2(-speed_accel_air, 0)
	if (InputHelper.keys[KEY_W] or InputHelper.keys[KEY_UP]) and on_floor and redball.get_contact_count() > 0:
		redball.linear_velocity += Vector2(0, jump_velocity)
		AudioHelper.play("rb1_jump")
		_can_land = true
	if (InputHelper.keys[KEY_W] or InputHelper.keys[KEY_UP]) and redball.linear_velocity.y < 0:
		redball.linear_velocity += Vector2(0, jump_slowfall)
	
	# adjust hitbox to rotation
	rbhitbox.rotation = -redball.rotation
	var hitboxsize: float = 21 * ((sqrt(2) - 1) * abs(sin(2 * redball.rotation)) + 1)
	rbhitbox.shape.size = Vector2(hitboxsize, hitboxsize)


# kills red ball
func _redball_die(_area: Area2D = null) -> void:
	# stop red ball
	AudioHelper.play("rb1_death")
	_is_alive = false
	redball.freeze = true
	redball.contact_monitor = false
	redball.get_node("collision").disabled = true
	redball.get_node("sprite").visible = false
	redball.get_node("hitbox").set_deferred("monitoring", false)
	
	# generate death parts
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for i in 8:
		var dpart: RigidBody2D = deathpartscene.instantiate()
		redball.add_child(dpart)
		dpart.position = Vector2(10 * rng.randf(), 10 * rng.randf())
		dpart.linear_velocity = redball.linear_velocity / 3
	
	# wait and respawn player
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		get_tree().paused = false
		get_tree().reload_current_scene()


# reset key function
func _redball_reset() -> void:
	get_tree().reload_current_scene()


# controls the scene camera
func _camera_update() -> void:
	# tween to red ball
	var strength: float = 0.1 # 0 < strength < 1 // lower is slower
	camera.position = redball.position * strength + camera.position * (1 - strength)
	# mirrors nondeterministic tweener
	#var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	#tween.tween_property(camera, "position", redball.position, 1.0)


# runs when hitting a checkpoint
func _checkpoint_hit(area: Area2D) -> void:
	# disable collision of every collected checkpoint and set new cp_index
	for i in area.get_parent().get_index() + 1:
		area.get_node("../..").get_child(i).get_node("hitbox").call_deferred("set_monitorable", false)
		if area.get_node("../..").get_child(i).frame == 0:
			area.get_node("../..").get_child(i).play("raise")
	DataHelper.data["cp_index"] = area.get_parent().get_index()


# runs when hitting an ending flag
func _finish_level(area: Area2D) -> void:
	# play audio and disable flag collision
	AudioHelper.play("rb1_flag")
	area.call_deferred("set_monitorable", false)
	area.get_parent().play("raise")
	
	# slow down red ball and reset input
	redball.linear_damp = 3
	redball.angular_damp = 3
	InputHelper.reset_all_inputs()
	
	# wait and load next scene
	DataHelper.data["cp_index"] = 0
	await get_tree().create_timer(2.871).timeout
	if is_inside_tree():
		get_tree().paused = false
		if load_next != "":
			get_tree().change_scene_to_file(load_next)
		else:
			get_tree().reload_current_scene()


# runs when pressing a button
func _press_button(area: Area2D) -> void:
	# play audio and disable button collision
	AudioHelper.play("rb1_checkbox")
	area.call_deferred("set_monitorable", false)
	
	# replace button sprite with empty button
	area.get_parent().texture = load("res://images/rb1/sprites/emptybutton.png")
	
	# disable linked object
	var link_name: String = area.get_parent().name
	get_tree().current_scene.get_node("objects/" + link_name).visible = false
	get_tree().current_scene.get_node("objects/" + link_name + "/body/collision").disabled = true


# pause functions
func _pause_menu(btn: String) -> void:
	match btn:
		"return":
			get_tree().paused = false
			$ui/pause.visible = false
		"menu":
			get_tree().paused = false
			ModAPI.unload_global_modules()
			get_tree().change_scene_to_file("res://scenes/rb1/main.tscn")
		"modmenu":
			get_tree().paused = false
			ModAPI.unload_global_modules()
			AudioHelper.unload_all_audio()
			get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
		"music_minus":
			if DataHelper.data["music_volume"] > 0:
				DataHelper.data["music_volume"] -= 1
				$ui/pause/base/music.text = "Music volume: -- " + str(DataHelper.data["music_volume"] * 10) + "% ++"
				AudioServer.set_bus_volume_db(1, 6 * log(max(DataHelper.data["music_volume"], 0.01) / 10.0) / log(2))
		"music_plus":
			if DataHelper.data["music_volume"] < 10:
				DataHelper.data["music_volume"] += 1
				$ui/pause/base/music.text = "Music volume: -- " + str(DataHelper.data["music_volume"] * 10) + "% ++"
				AudioServer.set_bus_volume_db(1, 6 * log(max(DataHelper.data["music_volume"], 0.01) / 10.0) / log(2))
		"sfx_minus":
			if DataHelper.data["sfx_volume"] > 0:
				DataHelper.data["sfx_volume"] -= 1
				$ui/pause/base/sfx.text = "Sfx volume: -- " + str(DataHelper.data["sfx_volume"] * 10) + "% ++"
				AudioServer.set_bus_volume_db(2, 6 * log(max(DataHelper.data["sfx_volume"], 0.01) / 10.0) / log(2))
		"sfx_plus":
			if DataHelper.data["sfx_volume"] < 10:
				DataHelper.data["sfx_volume"] += 1
				$ui/pause/base/sfx.text = "Sfx volume: -- " + str(DataHelper.data["sfx_volume"] * 10) + "% ++"
				AudioServer.set_bus_volume_db(2, 6 * log(max(DataHelper.data["sfx_volume"], 0.01) / 10.0) / log(2))
		"window":
			if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				$ui/pause/base/window.text = "Window mode: Windowed"
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				$ui/pause/base/window.text = "Window mode: Fullscreen"
		_:
			push_error("invalid argument")


# receives hitbox enter signals
func _redball_area_entered(area: Area2D) -> void:
	# iterate through entities
	for i in entities_enter.keys():
		if area.get_node("../..").name == i:
			funcs[entities_enter[i]].call(area)


# receives hitbox exitsignals
func _redball_area_exited(area: Area2D) -> void:
	# iterate through entities
	for i in entities_exit.keys():
		if area.get_node("../..").name == i:
			funcs[entities_exit[i]].call(area)
