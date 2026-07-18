extends Control
@export var star_point:Control


	
func visual_effect():
	#var tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.tween_property(star_point, "move_interval", 0.5, 0.25)
	star_point.disable_rand_move=true
	star_point.move_marker()
