extends Node2D
signal setted

func set_visual(node_name:String):
	for i in get_children():
		i.visible=( i.name == node_name)
	setted.emit()
