extends Node2D
## this script handles an rb1 level

const deathpartscene: PackedScene = preload("res://scenes/rb1/assets/deathpart.tscn")

var funcs: Dictionary = {
	"redball_move": _redball_move,
	"redball_die": _redball_die,
	"camera_update": _camera_update,
	"finish_level": _finish_level,
}
var loop: Array[String] = [
	"redball_move",
	"camera_update",
]
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
var speed_cap_floor: float = 150
var speed_cap_air: float = 75
var speed_accel_floor: float = 15
var speed_accel_air: float = 7.5
var jump_velocity: float = -165
var jump_slowfall: float = -2.5
var point0: Vector2 = Vector2(-6, 11.4)
var point1: Vector2 = Vector2(0, 12)
var point2: Vector2 = Vector2(6, 11.4)

var _is_alive: bool = true
var _can_land: bool = false

@onready var redball: RigidBody2D = get_node("redball")
@onready var camera: Camera2D = get_node("camera")
@onready var rbhitbox: CollisionShape2D = get_node("redball/hitbox/collision")


# sets up the scene
func _ready() -> void:
	# set red ball's and the camera's position to the first checkpoint
	redball.position = $entities/checkpoints.get_child(0).position
	camera.position = $entities/checkpoints.get_child(0).position
	
	# connect signals
	redball.get_node("hitbox").connect("area_entered", _redball_area_entered)
	
	# load audio and play music
	for i in audio.keys():
		AudioHelper.load_audio(i, audio[i], "music" if i in music else "sfx", not i in music)
	AudioHelper.change_volume("rb1_flag", 9)
	AudioHelper.change_volume("rb1_music", -3)
	AudioHelper.play("rb1_music", false)


# loops every physics frame (31 fps)
func _physics_process(_delta: float) -> void:
	# call the game loop functions
	for i in loop:
		funcs[i].call()
	
	# check death barrier
	if redball.position.y > 550 and _is_alive:
		funcs["redball_die"].call()
	if InputHelper.pressed[KEY_R]:
		get_tree().reload_current_scene()
	
	# window modes
	if InputHelper.pressed[KEY_F1]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if InputHelper.pressed[KEY_F2]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# checks if a point is inside a body
func is_body_at_point(point: Vector2) -> bool:
	# create raycast at point argument
	var rc0: RayCast2D = RayCast2D.new()
	rc0.target_position = Vector2(0, 0)
	rc0.hit_from_inside = true
	rc0.position = point
	add_child(rc0)
	
	# update raycast and return true if it hit a body
	rc0.force_raycast_update()
	rc0.queue_free()
	return rc0.is_colliding()


# controls red ball's movement
func _redball_move() -> void:
	# check if red ball is on a surface
	#$redball/floorchecks.rotation = -redball.rotation
	var check0: bool = is_body_at_point(redball.position + point0)
	var check1: bool = is_body_at_point(redball.position + point1)
	var check2: bool = is_body_at_point(redball.position + point2)
	var on_floor: bool = check0 or check1 or check2
	#$redball/floorchecks/check0.visible = check0
	#$redball/floorchecks/check1.visible = check1
	#$redball/floorchecks/check2.visible = check2
	
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
func _redball_die() -> void:
	# generate death parts
	_is_alive = false
	AudioHelper.play("rb1_death")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	redball.freeze = true
	redball.get_node("collision").disabled = true
	redball.get_node("sprite").visible = false
	for i in 8:
		var dpart: RigidBody2D = deathpartscene.instantiate()
		redball.add_child(dpart)
		dpart.position = Vector2(10 * rng.randf(), 10 * rng.randf())
		dpart.linear_velocity = redball.linear_velocity / 3
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()


# controls the scene camera
func _camera_update() -> void:
	# tween to red ball
	#camera.position = redball.position
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position", redball.position, 1.0)


# runs when hitting an ending flag
func _finish_level(area: Area2D) -> void:
	AudioHelper.play("rb1_flag")
	area.call_deferred("set_monitorable", false)
	area.get_parent().play("raise")
	redball.linear_damp = 3
	redball.angular_damp = 3
	InputHelper.reset_all_inputs()
	await get_tree().create_timer(2.871).timeout
	get_tree().reload_current_scene()


# receives hitbox signals
func _redball_area_entered(area: Area2D) -> void:
	if area.get_node("../..").name == "flags":
		print("yippee!")
		funcs["finish_level"].call(area)
