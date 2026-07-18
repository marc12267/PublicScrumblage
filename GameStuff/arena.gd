extends Node2D


@export var arena_size=1.0

var target_size=1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	arena_size=lerpf(arena_size,target_size,0.5*delta)
	scale=arena_size*Vector2(1,1)
	EventManager.resize_camera_arena.emit(arena_size)


func set_size(val):
	target_size=val
	
