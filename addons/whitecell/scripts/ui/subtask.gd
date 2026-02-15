@tool
extends ColorRect
## handles subtask completion


func complete_subtask() -> void:
	queue_free()


func move_subtask(diff: int) -> void:
	get_parent().move_child(self, min(max(get_index() + diff, 0), get_parent().get_child_count() - 2))
