extends BehaviourScript
const BALL_BALTMINION = preload("res://Balls/Bosses/Bmation/bmationminion0.tscn")

var triggered=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.defeated.connect(spawn_guys)

func spawn_guys():
	if !is_instance_valid(creator_script) or triggered:
		return
	triggered=true
	var a =creator_script.spawn_thing(BALL_BALTMINION)
	var b =creator_script.spawn_thing(BALL_BALTMINION)
	var c =creator_script.spawn_thing(BALL_BALTMINION)
	a.global_position=ball.global_position
	b.global_position=ball.global_position
	c.global_position=ball.global_position
	await get_tree().process_frame
	creator_script.ability_start_s.connect(a.behaviour_script.ability_start)
	creator_script.ability_end_s.connect(a.behaviour_script.ability_end)
	creator_script.ability_start_s.connect(b.behaviour_script.ability_start)
	creator_script.ability_end_s.connect(b.behaviour_script.ability_end)
	creator_script.ability_start_s.connect(c.behaviour_script.ability_start)
	creator_script.ability_end_s.connect(c.behaviour_script.ability_end)
	if creator_script.active==true:
		a.behaviour_script.ability_start()
		b.behaviour_script.ability_start()
		c.behaviour_script.ability_start()
	
