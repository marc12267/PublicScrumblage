extends Node2D

func _ready():
	add_to_group("WinQuote")
	modulate.a=0.0


func fade_in():
	modulate.a=0.0
	visible=true
	var tween=create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self,"modulate:a",1.0,1.0)
