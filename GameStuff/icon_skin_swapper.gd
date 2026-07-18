## Use this script to swap a sprite2d's skin based off ball's skin

extends TextureRect
@onready var ball_stat_display: Control = $"../../.."

var ball:BallBodyBase
## Pair skin name, with texture to swap
## Default is universal
@export var dict_skin:Dictionary[String,Texture]={}

func _ready() -> void:
	dict_skin["Default"]=texture
	EventManager.round_set.connect(set_visual)
	await ball_stat_display.ready
	ball = $"../../..".ball

	if ball:
		ball.set_skin.connect(set_visual)

func set_visual():
	if ball:
		texture=dict_skin.get(ball.skin,dict_skin["Default"])
