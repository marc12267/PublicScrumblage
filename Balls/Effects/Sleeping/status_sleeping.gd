extends StatusEffect
var delay=1.0

@export var gpu_particles_2d:GPUParticles2D

func damage_check(data:Dictionary):
	var victim=data["VICTIM"]
	var dmg=data["DAMAGE"]
	var type=data["TYPE"]
	if type.has("STATUS_EFFECT") or type.has("THROUGHSLEEP"):
		return
	if victim==baller:
		set_counter(0)
	return

func check_apply(ball)->bool:
	
	if !super(ball):
		return false
	if ball.is_in_group("AntiSleep"):
		return false
	return true

func set_target(ball,value,data):
	super(ball,value,data)
	EventManager._successfully_damaged_.connect(damage_check)
	set_counter(value)
	baller=ball
	baller.stat_controller.add_modifier("ContactDamager.enabled",2,false,"SLEEPING")
	
	baller.stat_controller.add_modifier("HitProcessor.immune",2,false,"SLEEPING")
	baller.stat_controller.add_modifier("Hitbox.collision_disabled",2,true,"SLEEPING")
	baller.stat_controller.add_modifier("BehaviourScript.behaviour_active",2,false,"SLEEPING")
	baller.stat_controller.add_modifier("Rotater.bounce_spin_boost",1,0.1,"SLEEPING")
	
	baller.stat_controller.add_modifier("Mood.disabled",2,true,"SLEEPING")
	
	baller.stat_controller.add_modifier("Rotater.aiming",2,false,"SLEEPING")
	baller.stat_controller.add_modifier("Rotater.rotation_rate",1,(0.1),"SLEEPING")
	baller.stat_controller.add_modifier("Rotater.normalizer_rate",2,30,"SLEEPING")
	baller.stat_controller.add_modifier("Ball.velocity",1,0.1,"SLEEPING")
	baller.stat_controller.add_modifier("Ball.dodge_rate",2,0,"SLEEPING")
	baller.stat_controller.add_modifier("Ball.normalizer_speed_down",2,100,"SLEEPING")
	baller.stat_controller.add_modifier("Ball.bounce_speed_boost",1,0.0,"SLEEPING")
	
	if gpu_particles_2d.emitting!=true:
		gpu_particles_2d.emitting=true
	
	EventManager._successfully_damaged_.connect(hit_process)
	

func hit_process(data):
	var victim = data["VICTIM"]
	if victim==baller:
		set_counter(counter-1)
		
	
func wakeup():
	gpu_particles_2d.amount_ratio=0.0
	await STimer.delay(0.15)
	if counter>0.0:
		gpu_particles_2d.amount_ratio=1
		return
	if is_instance_valid(baller):
		baller.stat_controller.remove_modifier("SLEEPING")
	queue_free()
	
var done=false
func update(value,data):
	gpu_particles_2d.amount_ratio=1
	set_counter(counter+value)
	return self

func _physics_process(delta):
	if baller==null or !is_instance_valid(baller):
		return
	gpu_particles_2d.global_position=baller.global_position
	if done:
		return
	
	set_counter(counter-delta)
	
	if counter<=0:
		wakeup()
		
