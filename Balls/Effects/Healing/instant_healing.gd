extends StatusEffect
var delay=1.0

var tick_delay=0.5
@export var gpu_particles_2d :GPUParticles2D

func set_target(ball,value,data):
	super(ball,value,data)
	baller = ball
	
	gpu_particles_2d.global_position=baller.global_position
	heal(ball,value)
	
		
func heal(ball,value):
	var sc :StatController=ball.stat_controller
	sc.set_base_stat("HealthManager.health",sc.get_stat("HealthManager.health")+value)
	
	set_counter(counter-1)
	
	if gpu_particles_2d.emitting!=true:
		await get_tree().process_frame
		gpu_particles_2d.emitting=true
	gpu_particles_2d.amount_ratio=clamp(value/6.0,0.1,1)
	await gpu_particles_2d.finished
	if is_instance_valid(self):
		queue_free()
		

func check_apply(ball)->bool:
	if !super(ball):
		return false
	if ball.is_in_group("AntiHeal"):
		return false
	return true

func update(value,data:Dictionary)->StatusEffect:
	heal(baller,value)
	return self
	
func _process(delta):
	if baller!=null:
		gpu_particles_2d.global_position=baller.global_position
