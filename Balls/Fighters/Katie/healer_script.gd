extends BehaviourScript
@onready var healing_zone = $"../HealingZone"
var timer=0.0
var katie
var res = preload("res://Balls/Fighters/Katie/scrap_powerup.tscn")
func _ready():
	super()
	ball.tree_exiting.connect(drop_powerup)
	healing_zone.scale=Vector2(1,1)*0.1


func drop_powerup():
	
	if !is_instance_valid(katie):
		return
	var pu=res.instantiate()
	pu.team = ball.team
	pu.katie=katie
	pu.global_position=ball.global_position
	
	ball.get_parent().call_deferred("add_child",pu)
	#ball.get_parent().add_child(pu)
	
func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	timer+=delta
	if timer>0.2:
		timer=0.0
		heal()
	scale_time= min(5.2,scale_time + delta)
	healing_zone.scale = Vector2(1,1) * lerpf(healing_zone.scale.x,0.1+ scale_time*1.25/5.0,delta*1.5)

var scale_time:float=0.0

func heal():
	
	var bodies = healing_zone.get_overlapping_bodies()
	for i in bodies:
		if i.team == ball.team and i.is_in_group("Main"):
			StatusEffectManager.set_effect(ball.get_root_creator(),i,"HEALING",1)
			scale_time= max(scale_time-1.5,0.0)
