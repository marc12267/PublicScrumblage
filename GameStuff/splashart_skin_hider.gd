extends CanvasItem

@export var skin_name:="Summer"
@export var always_flag:bool=false
var ball:BallBodyBase
@export var ball_stat_display: Control

func _ready() -> void:
	EventManager.round_set.connect(set_visual)
	await ball_stat_display.ready
	ball = ball_stat_display.ball
	ball.set_skin.connect(set_visual)
	set_visual()

func set_visual():
	if ball:
		visible=(skin_name==ball.skin) or (always_flag)
	visible=(skin_name==Global.skin_mode) or (always_flag)
