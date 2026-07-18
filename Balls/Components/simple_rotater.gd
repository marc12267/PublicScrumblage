extends Node2D
@export var other_target:Node2D
@export var ball:BallBodyBase
@export var enabled:bool=true
@export var rotation_rate:float=60.0

func _physics_process(delta):
	if ball.freezed or !enabled:
		return
	if other_target:
		other_target.rotation_degrees+=rotation_rate*delta
	else:
		rotation_degrees+=rotation_rate*delta
