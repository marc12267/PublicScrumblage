## Flipper that flips weapon sprite + hitbox when clashing

extends Node2D

@export var disable:bool=false
@export var rotater:Node2D

var tween:Tween
func _ready():
	rotater.angulize.connect(flip)
	
func flip(dir):
	if disable==true:
		return
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "scale:y",dir, 0.175*2)
