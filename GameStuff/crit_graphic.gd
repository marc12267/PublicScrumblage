extends Node2D

var tween: Tween
var base_pos: Vector2=Vector2(0,-9999)

func _ready():
	EventManager.critted.connect(crit_appear)
	HitstopManager.set_stop.connect(stop_check)
	visible = false
	
func _process(delta):
	if seek!=null and is_instance_valid(seek):
		global_position=seek.global_position+Vector2(0,-offsetter)
var offsetter = 135
func crit_appear(ball:BallBodyBase):
	global_position=ball.global_position+Vector2(0,-offsetter)
	seek=ball
	#base_pos = position
	visible = true
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops(6)
	
	var shake_strength := 6
	
	tween.tween_property(crit_graphic, "position", Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength)), 0.03)
	tween.tween_property(crit_graphic, "position", Vector2(0,0), 0.03)
	
	

var seek:BallBodyBase
@onready var crit_graphic = $CritGraphic

func stop_check(truefalse):
	if visible and !truefalse:
		visible = false
		position = base_pos
		seek=null
