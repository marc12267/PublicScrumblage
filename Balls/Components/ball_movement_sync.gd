## THIS NODE SHOULD BE A CHILD OF NODE YOU WANT TO AFFECT
## WILL SYNC ROTATION OF PARENT TO BALL'S VELOCITY
## Used to make non circular bullets rotate to fit velocity
extends Node
@export var ball: BallBodyBase
@export var min_speed: float = 10.0

var base_rotation: float

func _ready():
	#Store whatever rotation the parent already has
	base_rotation = get_parent().rotation

func _process(delta):
	if ball == null or HitstopManager.hitstopped:
		return
	
	var vel: Vector2 = ball.linear_velocity
	
	if vel.length() < min_speed:
		return
	
	var angle = vel.angle()
	
	#Apply velocity rotation + original rotation offset
	get_parent().rotation = angle + base_rotation
