extends Control

func plate_display(val:int):
	for i in get_children():
		i.visible = int(i.name)<=val
