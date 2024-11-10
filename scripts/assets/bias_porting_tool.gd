@tool
extends EditorScript
## this fixes the structure of individual texture polygons to work with bias.


# run script
func _run() -> void:
	# iterates through each node in the scene
	var queue: Array = get_scene().get_children()
	while queue.size() > 0:
		if queue[0] is TexturePolygon:
			runtime_fixes(queue[0])
		queue.append_array(queue[0].get_children())
		queue.pop_front()


# fixes the texture of a node
func runtime_fixes(tp: TexturePolygon) -> void:
	# check if tp already has a b2ibody parent
	if tp.get_parent() is b2iBody:
		return
	
	# create new b2ibody
	var body: b2iBody = b2iBody.new()
	body.density = 0
	tp.get_parent().add_child(body)
	body.owner = get_scene()
	
	# reparent nodes
	tp.reparent(body)
	tp.get_node("body/collision").reparent(body)
	tp.get_node("body").free()
	body.name = tp.name
