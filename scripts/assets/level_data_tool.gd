@tool
extends EditorScript
## adds objects to a level based on exported level data

var datapath: String = "res://lvldata.txt"


# run script
func _run() -> void:
	var f: FileAccess = FileAccess.open(datapath, FileAccess.READ)
	var line: String = f.get_line()
	while line != "":
		var obj: PackedStringArray = line.split(" / ")
		var tp: TexturePolygon = TexturePolygon.new()
		tp.baked = true
		tp.name = obj[0]
		tp.position.x = float(obj[1])
		tp.position.y = float(obj[2])
		var pcoords: PackedStringArray = obj[3].split(",")
		var points: Array[Vector2]
		while pcoords.size() > 1:
			points.append(Vector2(float(pcoords[0]), float(pcoords[1])))
			pcoords.remove_at(0)
			pcoords.remove_at(0)
		tp.polygon = PackedVector2Array(points)
		EditorInterface.get_edited_scene_root().get_node("objects").add_child(tp)
		tp.owner = EditorInterface.get_edited_scene_root()
		line = f.get_line()
	f.close()
