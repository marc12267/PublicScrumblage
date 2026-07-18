##THIS SPRITE NODE SET'S IT'S OUTLINE COLOR DEPENDING ON
##TEAM OF BALL
##USE TO OUTLINE THE "BODIES" OF THE BALL
##(Weapons don't count)
extends Sprite2D
@export var ball:BallBodyBase
@export var visuals:Node2D
@export var dict_skin:Dictionary[String,Texture]={}

func _enter_tree():
	if visuals!=null and ball==null:
		ball=visuals.ball
	
func _ready():
	ball.team_setted.connect(set_team)
	if !Global.team_fight:
		visible=false
	dict_skin["Default"]=texture
	ball.set_skin.connect(set_visual)

func set_visual():
	texture=dict_skin.get(ball.skin,dict_skin["Default"])
	
func set_team(t_id:int):
	match t_id:
		1:
			modulate=Color(0.794, 0.0, 0.167, 1.0)
		2:
			modulate=Color(0.0, 0.336, 0.893, 1.0)
		4:
			modulate=Color(0.86, 0.702, 0.0, 1.0)
		3:
			modulate=Color(0.248, 0.62, 0.0, 1.0)
