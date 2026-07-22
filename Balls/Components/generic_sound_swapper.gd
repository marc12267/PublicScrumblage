extends AudioStreamPlayer2D

@export var ball:BallBodyBase
@export var dict_sound:Dictionary[String,AudioStream]={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dict_sound["Default"] = stream
	stream = dict_sound.get(ball.skin, dict_sound["Default"])
