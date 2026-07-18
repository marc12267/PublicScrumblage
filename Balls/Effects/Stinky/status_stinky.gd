extends StatusEffect

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var lose_value = 1
var expiring = false

func set_target(ball, value, data):
	super(ball, value, data)
	set_counter(value)
	gpu_particles_2d.global_position = baller.global_position

func update(value, data):
	set_counter(counter + value)
	return self

func check_apply(ball) -> bool:
	if !super(ball):
		return false
	if ball.is_in_group("AntiStinky"):
		return false
	return true


func scaler():
	return min(1.0, counter / 10.0)

func _process(delta):
	if expiring:
		return

	if is_instance_valid(baller):
		gpu_particles_2d.global_position = baller.global_position

	update_slow()
	gpu_particles_2d.amount_ratio = pow(scaler(), 1.5)*2.0/3.0 + 0.3

	set_counter((lerpf(counter,0.0,0.15*delta))-delta/1.5)
	if counter <= 0.0:
		_expire()

func _expire():
	expiring = true
	gpu_particles_2d.emitting = false
	gpu_particles_2d.one_shot = true
	gpu_particles_2d.restart()
	await gpu_particles_2d.finished
	queue_free()

func update_slow():
	baller.stat_controller.remove_modifier("STINKY_SLOW")
	baller.stat_controller.add_modifier("Ball.velocity", 1, 1.0 - (0.9 * scaler()), "STINKY_SLOW")

func on_leave():
	super()
	if !is_instance_valid(baller):
		return
	baller.stat_controller.remove_modifier("STINKY_SLOW")
