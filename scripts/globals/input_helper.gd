extends Node
## this script is always running ingame, and can be accessed anywhere to make input handling easier.

## stores a boolean value for every key, which is true if the key is down.[br]use [code]InputHelper.keys[KEY_*][/code] to access, where * is a key name (see globalscope).
var keys: Dictionary
## stores a boolean value for every key, which is true if the key was just pressed.[br]use [code]InputHelper.pressed[KEY_*][/code] to access, where * is a key name (see globalscope).
var pressed: Dictionary
## stores a boolean value for every key, which is true if the key is activated by keyboard repeat.[br]use [code]InputHelper.echo[KEY_*][/code] to access, where * is a key name (see globalscope).
var echo: Dictionary
## on if the script is not currently taking input. (ex: when the player is typing)
var locked: bool = false


# initializes dictionaries
func _init() -> void:
	for i in 168:
		keys[i] = false
		pressed[i] = false
		echo[i] = false
	for i in 144:
		keys[i+4194304] = false
		pressed[i+4194304] = false
		echo[i+4194304] = false
	keys[8388607] = false
	pressed[8388607] = false
	echo[8388607] = false
	process_mode = PROCESS_MODE_ALWAYS


# processes input
func _input(event: InputEvent) -> void:
	if event is InputEventKey and not locked:
		keys[event.keycode] = event.is_pressed()
		pressed[event.keycode] = event.is_pressed() and not event.is_echo()
		echo[event.keycode] = event.is_pressed() and event.is_echo()


# manually sets an key state
func manual_input(key: int, on: bool) -> void:
	keys[key] = on


# loops reset_states
func _physics_process(_delta: float) -> void:
	reset_pressed.call_deferred()


# resets pressed and echo states
func reset_pressed() -> void:
	for i in pressed.keys():
		pressed[i] = false
		echo[i] = false


## sets all key states to false.
func reset_all_inputs() -> void:
	for i in pressed.keys():
		keys[i] = false
		pressed[i] = false
		echo[i] = false
