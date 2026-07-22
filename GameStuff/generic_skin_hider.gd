## Use this script to hide/show stuff depending on Global, or Ball's skin.
## If youre using this for a ball, make sure the ball export field is connected

extends CanvasItem

@export var skin_name:="Summer"
@export var ball:BallBodyBase

func _ready() -> void:
	EventManager.round_set.connect(set_visual)
	if ball:
		ball.set_skin.connect(set_visual)

func set_visual():
	if ball:
		visible=skin_name==ball.skin
	else:
		visible=skin_name==Global.skin_mode
