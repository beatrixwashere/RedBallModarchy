extends Control
## keybinds for unpausing the game


func _physics_process(_delta: float) -> void:
	get_tree().paused = true
	get_parent().visible = true
