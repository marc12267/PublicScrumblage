extends Node2D

@export var ball:BallBodyBase
func _ready():
	if !ball:
		return
	set_ball(ball)

func set_ball(balll):
	ball=balll
	ball.update_scale.connect(update_scale)
	update_scale()




func update_scale():
	scale=ball.ball_scale*Vector2(1,1)
