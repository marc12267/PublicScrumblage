
extends Sprite2D
@export var ball:BallBodyBase
## Pair skin name, with texture to swap
## Default is universal
@export var dict_skin:Dictionary[String,Texture]={}


func _ready() -> void:
	dict_skin["Default"]=texture
	ball.set_skin.connect(set_visual)


func set_visual():
	texture=dict_skin.get(ball.skin,dict_skin["Default"])
