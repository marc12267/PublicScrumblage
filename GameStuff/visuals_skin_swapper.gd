## Use this script to swap a sprite2d's skin based off ball's skin
## Must be child of visual_node_controller

extends Sprite2D
var ball:BallBodyBase


## If the visual is locked in the animationplayer won't play anims that change it
## Mostly use for sprites that don't switch to hurtsprite when taking damage
## Does nothing on hurt sprites
@export var locked_visual:bool=false
## Pair skin name, with texture to swap
## Default is universal
@export var dict_skin:Dictionary[String,Texture]={}


func _ready() -> void:
	ball=$"../..".ball
	dict_skin["Default"]=texture
	ball.set_skin.connect(set_visual)


func set_visual():
	texture=dict_skin.get(ball.skin,dict_skin["Default"])
