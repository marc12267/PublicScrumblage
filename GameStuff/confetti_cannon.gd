extends Node2D

func _ready():
	EventManager.won.connect(confetti)
	
func confetti():
	for i in get_children():
		i.emitting=true
