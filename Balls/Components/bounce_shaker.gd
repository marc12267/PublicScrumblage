## USE THIS NODE TO MAKE BALL SHAKE SCREEN ON BOUNCE
extends Node
@export var enabled = true
@export var strength = 0.25
@onready var ball = get_parent().get_parent()

func _ready() -> void:
	ball.bounce.connect(shake)
	
func shake():
	if !enabled:
		return
	Global.quake_trigger.emit(0.25)
