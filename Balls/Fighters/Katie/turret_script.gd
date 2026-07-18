extends BehaviourScript

@onready var rotater = $"../Rotater"
var counter=0.0
var bullet_res = preload("res://Balls/Fighters/Katie/KatBullet.tscn")
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

func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	counter+=delta
	if counter>3:
		counter=0.0
		var count=3
		while count>0:
			count-=1
			shoot()
			await delay(0.15)
		


func shoot():
	var dir =Vector2.RIGHT.rotated(rotater.rotation)
	var newb = spawn_thing(bullet_res)
	
	newb.global_position=$"../Rotater/WeaponVisual".global_position
	
	
	newb.set_velocity(dir*1950)
