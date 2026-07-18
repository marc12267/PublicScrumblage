extends StatusEffect
var delay=1.8


func _ready():
	EventManager._successfully_damaged_.connect(hit_process)

func hit_process(data):
	var victim = data["VICTIM"]
	var type = data["TYPE"]
	if victim==baller:
		if !type.has("STATUS_EFFECT"):
			SoundQueue.play("res://Sounds/weird_glass.wav",0.5+0.5*min(1.0,counter/12.0),0.5+0.5*min(1.0,counter/12.0))
			EventManager.hit.emit({"ATTACKER":ball_source,"VICTIM":baller,"TYPE":["STATUS_EFFECT"],"DAMAGE":int(counter),"HITSTOP_SCALE":min(0.3,0.1+counter*0.02),"SFX":"res://Sounds/lighter.wav",
			"ID":"STATUS_FRAGILE","VFX_PARTICLE":"res://Particle FX/ShatterFx.tscn"})
			queue_free()
			
var _apply_time := 0.0

func set_target(ball, value, data):
	super(ball, value, data)
	baller = ball
	_apply_time = Time.get_ticks_msec() / 1000.0
	SoundQueue.play("res://Sounds/arcade-type-fx-dark-stab.wav")
	set_counter(value)



func update(value,data):
	set_counter(counter+value)
	
	SoundQueue.play("res://Sounds/arcade-type-fx-dark-stab.wav",1.0+randf()*0.05,0.4)
	return self
	

func check_apply(ball)->bool:
	if !super(ball):
		return false
	if ball.is_in_group("AntiFrail"):
		return false
	return true
	

func _process(delta):
	if HitstopManager.hitstopped:
		return

	var elapsed = Time.get_ticks_msec() / 1000.0 - _apply_time
	if elapsed < 1.0:
		return

	set_counter(counter - 1.5 * delta)
	if counter <= 0:
		queue_free()
		return
