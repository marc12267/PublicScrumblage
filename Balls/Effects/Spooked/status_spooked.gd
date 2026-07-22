extends StatusEffect
var delay=1.0

@onready var sprite_2d = $Sprite2D

	
func set_target(ball,value,data):
	super(ball,value,data)
	counter=value
	baller=ball
	
	$Sprite2D.visible=true
	baller.stat_controller.add_modifier("Mood.disabled",2,true,"SPOOKED")
	#baller.stat_controller.add_modifier("Ball.velocity",1,0.75,"SPOOKED")

	
	baller.stat_controller.add_modifier("ContactDamager.enabled",2,false,"SPOOKED")
	baller.stat_controller.add_modifier("Hitbox.collision_disabled",2,true,"SPOOKED")
	baller.stat_controller.add_modifier("BehaviourScript.behaviour_active",2,false,"SPOOKED")
	baller.stat_controller.add_modifier("Rotater.bounce_spin_boost",1,0.1,"SPOOKED")
	
	baller.stat_controller.add_modifier("Mood.disabled",2,true,"SPOOKED")
	
	baller.stat_controller.add_modifier("Rotater.rotation_rate",1,0.5,"SPOOKED")


func check_apply(ball)->bool:
	
	if !super(ball):
		return false
	if ball.is_in_group("AntiSpooked"):
		return false
	return true
	
func wakeup():
	var done=true
	
	await STimer.delay(0.15)
	queue_free()
	
var done=false
func update(value,data):
	counter +=value
	return self
	
var wave_progress=0.0
func _physics_process(delta):
	if baller==null or !is_instance_valid(baller):
		return
	if done or HitstopManager.hitstopped:
		return
	counter-=delta
	
	wave_progress+=delta
	sprite_2d.scale=Vector2(0.2,0.2)*(1.0+(0.2*sin(wave_progress*15)))
	sprite_2d.global_position=baller.global_position+Vector2(0,-85)
	tt_track+=delta
	if tt_track>trigger_time:
		run()
		tt_track=0.0
	
	if counter<=0:
		wakeup()

var trigger_time = 0.65
var tt_track=0.0

func run():
	var dir = Global.dir_closest_ball(baller)
	if dir == Vector2.ZERO:
		return
		
	baller.set_velocity(-dir*(baller.get_velocity().length()))
	

func on_leave():
	super()
	if is_instance_valid(baller):
		baller.stat_controller.remove_modifier("SPOOKED")
	
