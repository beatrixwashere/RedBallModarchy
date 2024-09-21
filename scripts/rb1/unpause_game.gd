extends Control
## keybinds for unpausing the game


func _physics_process(_delta: float) -> void:
	if InputHelper.pressed[KEY_P] or InputHelper.pressed[KEY_ESCAPE]:
		get_tree().paused = false
		get_parent().visible = false
		InputHelper.pressed[KEY_P] = false
		InputHelper.pressed[KEY_ESCAPE] = false
