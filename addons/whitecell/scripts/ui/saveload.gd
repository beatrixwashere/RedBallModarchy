@tool
extends Node
## saves and loads whitecelldata


func save_lists() -> void:
	var new_data := WhitecellData.new()
	for i in get_node("../listscroll/lists").get_children():
		if i.name != "add":
			new_data.list_names.append(i.get_node("header").text)
			new_data.list_colors.append(i.color)
			var i_items: Array
			for j in i.get_node("scroll/todo").get_children():
				var j_items: Array
				j_items.append(j.get_node("label_rich").text)
				for k in j.get_node("subtasks").get_children():
					if k.name != "add":
						j_items.append(k.get_node("label_edit").text)
				i_items.append(j_items)
			new_data.list_items.append(i_items)
	DirAccess.remove_absolute($savepath.text)
	new_data.take_over_path($savepath.text)
	ResourceSaver.save(new_data, $savepath.text)


func load_lists() -> void:
	if not FileAccess.file_exists($savepath.text):
		print("no save data found at " + $savepath.text)
		return
	for i in get_node("../listscroll/lists").get_children():
		if i.name != "add":
			i.queue_free()
	var loaded_data: WhitecellData = ResourceLoader.load(
			$savepath.text, "",
			ResourceLoader.CACHE_MODE_IGNORE )
	for i in loaded_data.list_names.size():
		var i_list: Node = get_node("../listscroll/lists").new_list(loaded_data.list_names[i], true)
		i_list.color = loaded_data.list_colors[i]
		i_list.get_node("color/picker/dialog").color = loaded_data.list_colors[i]
		for j in loaded_data.list_items[i]:
			if j is String:
				i_list.new_task(j)
			elif j is Array:
				var j_task: Node = i_list.new_task(j[0])
				for k in j.size() - 1:
					j_task.new_subtask(j[k + 1])
