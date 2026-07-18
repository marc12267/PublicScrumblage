extends BehaviourScript

var katie
var res = preload("res://Balls/Fighters/Katie/scrap_powerup.tscn")
func _ready():
	super()
	ball.tree_exiting.connect(drop_powerup)
	

func drop_powerup():
	
	if !is_instance_valid(katie):
		return
	var pu=res.instantiate()
	pu.team = ball.team
	pu.katie=katie
	pu.global_position=ball.global_position
	
	ball.get_parent().call_deferred("add_child",pu)
	#ball.get_parent().add_child(pu)
