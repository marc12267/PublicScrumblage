extends "res://GameStuff/icon_skin_swapper.gd"
@onready var hones_ball: BallBodyBase = $"../../../../.."

func _process(delta: float) -> void:
	#if hones_script.behaviour_active == false:
		#visible = true
	#else:
		#visible = false
	if !is_instance_valid(hones_ball):
		return
	if StatusEffectManager.get_effects(hones_ball).has("GRAPPLED"):
		visible = true
	else:
		visible = false
