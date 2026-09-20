@tool
extends Control
## handles task completion


func complete_task() -> void:
	queue_free()


func move_task(diff: int) -> void:
	get_parent().move_child(self, min(max(get_index() + diff, 0), get_parent().get_child_count() - 1))


func new_subtask(sname: String = "") -> void:
	var stask_node: Node = load("res://addons/whitecell/scenes/subtask.tscn").instantiate()
	stask_node.get_node("label_edit").text = sname
	$subtasks.add_child(stask_node)
	$subtasks.move_child(stask_node, $subtasks.get_child_count() - 2)
	resize_task()


func resize_task() -> void:
	custom_minimum_size = Vector2(
			300,
			64 + (32 * $subtasks.get_child_count() - 8 if $subtasks.visible else 0) )


func switch_display(editing: bool) -> void:
	if editing:
		$label_edit.text = $label_rich.text
		$label_rich.visible = false
		$placeholder.visible = false
	else:
		$label_rich.text = $label_edit.text
		$label_edit.text = ""
		$label_rich.visible = true
		$placeholder.visible = $label_rich.text == ""


func toggle_subtasks() -> void:
	$subtasks.visible = not $subtasks.visible
	resize_task()
