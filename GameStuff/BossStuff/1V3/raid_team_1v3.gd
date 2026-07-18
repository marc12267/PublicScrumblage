class_name TeamRaid_1v3
extends Node
@export var team_name:String="Team Name"
@export var team_audio:AudioStream

@export var ball1:BallBodyBase
@export var ball2:BallBodyBase
@export var ball3:BallBodyBase

@onready var win_bubble = $WinBubble

func _ready():
	win_bubble.add_to_group("TeamWinQuote")
