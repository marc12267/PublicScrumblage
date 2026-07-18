## Utility script to make a child follow their parent's position

extends Node2D

@onready var seeked = get_parent()


func _process(delta):
	global_position=seeked.global_position
