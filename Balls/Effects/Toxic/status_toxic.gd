extends StatusEffect
var delay=1.0
var tick_delay=0.5
@export var gpu_particles_2d :GPUParticles2D
func set_target(ball,value,data):
	super(ball,value,data)
	set_counter(value)
	tick_delay = 1.5/float(counter)
	toxic(ball)
	if gpu_particles_2d.emitting!=true:
		gpu_particles_2d.emitting=true
		

func check_apply(ball)->bool:
	
	if !super(ball):
		return false
	if ball.is_in_group("AntiToxic"):
		return false
	return true
	
func update(value,data):
	set_counter(counter+value)
	tick_delay = 1.5/float(counter)
	return self
	
func toxic(ball):
	baller=ball
	if counter<=0:
		queue_free()
	
	await STimer.delay(tick_delay)
	if !is_instance_valid(ball):
		return
	EventManager.hit.emit({"ATTACKER":ball_source,"VICTIM":ball,"TYPE":["STATUS_EFFECT"],"DAMAGE":1,"HITSTOP_SCALE":0.01,"SFX":"res://Sounds/lighter.wav"})

	set_counter(counter-1)
	toxic(ball)
	
func _process(delta):
	if baller!=null:
		gpu_particles_2d.global_position=baller.global_position
