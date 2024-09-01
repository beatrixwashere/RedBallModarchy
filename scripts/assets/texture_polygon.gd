class_name TexturePolygon
extends Polygon2D
## this node is a modification of the polygon2d node, and automatically fixes the texture and sets collision at runtime.
## to perform the fixes in the editor, open scripts/assets/texture_polygon_tool.gd, and run it.

@export var texture_shortcut: Texture2D ## texture shortcut; applies to the polygon2d texture property.
@export var use_collision: bool = true ## if true, the polygon will have collision.
@export var baked: bool ## if true, the texture and polygon won't be modified. check this if they are already set in the editor (typically through the tool script).
@export var skip_in_tool: bool ## if true, the tool script won't process this node.


# sets up the node at runtime
func _ready() -> void:
	# skip if baked
	if baked:
		return
	
	# apply texture shortcut
	if texture_shortcut:
		texture = texture_shortcut
	
	# get polygon limits
	var x_min: float
	var x_max: float
	var y_min: float
	var y_max: float
	for i in polygon:
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
	for i in polygon:
		new_polygon.append(i - Vector2(x_min, y_min))
	polygon = new_polygon
	position.x += x_min
	position.y += y_min
	
	# fix texture data
	if texture.get_height() / (y_max - y_min) > texture.get_width() / (x_max - x_min):
		texture_scale.x = texture.get_width() / (x_max - x_min)
	else:
		texture_scale.x = texture.get_height() / (y_max - y_min)
	texture_scale.y = texture_scale.x
	
	# add outline
	if has_node("outline"):
		get_node("outline").free()
	var outline: Line2D = Line2D.new()
	outline.points = polygon + PackedVector2Array([polygon[0]])
	outline.width = 0.75
	outline.default_color = Color(0, 0, 0, 1)
	add_child(outline)
	outline.name = "outline"
	
	# skip if collision is off
	if not use_collision:
		return
	
	# generate collision
	if has_node("body"):
		get_node("body").free()
	var body: AnimatableBody2D = AnimatableBody2D.new()
	add_child(body)
	body.name = "body"
	var coll: CollisionPolygon2D = CollisionPolygon2D.new()
	coll.polygon = polygon
	body.add_child(coll)
	coll.name = "collision"
