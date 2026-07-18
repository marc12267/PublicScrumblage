extends Control
@export var ball_stat_display:Control
@export var name_sound:AudioStream
@export var name_text:String="Mandalyn"
@onready var alignment_chart = $AlignmentChart
@export var splasharts : Dictionary[String,TextureRect]={}

var ball:BallBodyBase

func _ready():
	add_to_group("SplashArt")
	EventManager.round_set.connect(set_visual)
	await ball_stat_display.ready
	ball = ball_stat_display.ball
	ball.set_skin.connect(set_visual)
	set_visual()

func set_visual():
	var found=false
	for i in splasharts.keys():
		if (i==ball.skin):
			splasharts[i].visible=true
			found=true
		else:
			splasharts[i].visible=false
	
	if found==false:
		splasharts["Default"].visible=true
	
