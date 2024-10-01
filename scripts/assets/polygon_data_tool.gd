@tool
extends EditorScript
## this adds a polygon in the scene using an array of data.

var data: String = "[[[100,0],[100,20],[0,20],[0,0]]]"


# run script
func _run() -> void:
	var points: Array[Vector2]
	data = data.replace("[", "")
	var pointstrs: PackedStringArray = data.split("]", false)
	for i in pointstrs:
		var pointdata: PackedStringArray = i.split(",", false)
		var newpoint: Vector2 = Vector2(pointdata[0].to_float(), pointdata[1].to_float())
		if not newpoint in points:
			points.append(newpoint)
	var coll: CollisionPolygon2D = CollisionPolygon2D.new()
	coll.polygon = PackedVector2Array(points)
	get_scene().add_child(coll)
	coll.owner = get_scene()
	coll.name = "polygon_data"
