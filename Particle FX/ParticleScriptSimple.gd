extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().emitting=true
	await get_parent().finished
	await get_tree().create_timer(1).timeout
	get_parent().queue_free()
