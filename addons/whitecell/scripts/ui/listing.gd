@tool
extends Node
## handles creation/deletion of lists


func new_list(lname: String = "list", empty: bool = false) -> Node:
	var list_node: Node = load("res://addons/whitecell/scenes/list.tscn").instantiate()
	list_node.get_node("header").text = lname
	add_child(list_node)
	move_child(list_node, get_child_count() - 2)
	if empty:
		list_node.get_node("scroll/todo/task").queue_free()
	return list_node
