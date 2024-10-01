@tool
extends EditorScript
## this fixes the texture of every texturepolygon in the current scene.


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
	# check for skip property
	if tp.skip_in_tool:
		return
	
	# apply texture shortcut
	if tp.texture_shortcut:
		tp.texture = tp.texture_shortcut
	
	# find min and max coordinates in polygon
	var x_min: float
	var x_max: float
	var y_min: float
	var y_max: float
	for i in tp.polygon:
		if x_min == null or x_min > i.x:
			x_min = i.x
		if x_max == null or x_max < i.x:
			x_max = i.x
		if y_min == null or y_min > i.y:
			y_min = i.y
		if y_max == null or y_max < i.y:
			y_max = i.y
	
	# fix polygon position data
	var new_polygon: Array[Vector2] = []
	for i in tp.polygon:
		new_polygon.append(i - Vector2((x_min + x_max) / 2, (y_min + y_max) / 2))
	tp.polygon = new_polygon
	tp.position.x += (x_min + x_max) / 2
	tp.position.y += (y_min + y_max) / 2
	
	# fix texture data
	if tp.texture:
		if tp.texture.get_height() / (y_max - y_min) > tp.texture.get_width() / (x_max - x_min):
			tp.texture_scale.x = tp.texture.get_width() / (x_max - x_min)
		else:
			tp.texture_scale.x = tp.texture.get_height() / (y_max - y_min)
		tp.texture_scale.y = tp.texture_scale.x
		tp.texture_offset.x = (x_max - x_min) / 2
		tp.texture_offset.y = (y_max - y_min) / 2
	
	# add outline
	if tp.has_node("outline"):
		tp.get_node("outline").free()
	var outline: Line2D = Line2D.new()
	outline.points = tp.polygon + PackedVector2Array([tp.polygon[0]])
	outline.width = 0.75
	outline.default_color = Color(0, 0, 0, 1)
	tp.add_child(outline)
	outline.owner = get_scene()
	outline.name = "outline"
	
	# skip if collision is off
	if not tp.use_collision:
		return
	
	# generate collision
	if tp.has_node("body"):
		tp.get_node("body").free()
	var body: AnimatableBody2D = AnimatableBody2D.new()
	tp.add_child(body)
	body.owner = get_scene()
	body.name = "body"
	var coll: CollisionPolygon2D = CollisionPolygon2D.new()
	coll.polygon = tp.polygon
	coll.visible = false
	body.add_child(coll)
	coll.owner = get_scene()
	coll.name = "collision"
