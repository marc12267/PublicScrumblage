extends Node2D

const FPS = 60

@export var lifetime = 1.0

var emitting = true
var enabled = true
var tick = 0
signal finished



func _process(delta):
	if tick / 60.0 >= lifetime:
		return
		
	tick += 1
	if tick / 60.0 >= lifetime:
		finished.emit()
		await get_tree().create_timer(2).timeout
		queue_free()
