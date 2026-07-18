## Used to prevent the target from rotating
extends Node
@export var target:Node

func _process(delta: float) -> void:
	target.global_rotation_degrees=0
