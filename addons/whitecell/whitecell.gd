@tool
extends EditorPlugin
## initializes main screen button

const main_scene: PackedScene = preload("res://addons/whitecell/scenes/main.tscn")

var main_instance: Control


func _enter_tree():
	main_instance = main_scene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_instance)
	_make_visible(false)


func _exit_tree():
	if main_instance:
		main_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_instance:
		main_instance.visible = visible


func _get_plugin_name():
	return "whitecell"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("EditorPlugin", "EditorIcons")
