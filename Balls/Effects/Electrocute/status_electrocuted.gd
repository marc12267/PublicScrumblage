extends StatusEffect
var delay=1.0
var pot_bol=null
var pot_str
var ongoing_stuns=0

func check_apply(ball)->bool:
	if !super(ball):
		return false
		
	if ball.is_in_group("AntiElectrocuted"):
		return false
	return true
	
func set_target(ball,value,data):
	super(ball,value,data)
	electrocute(ball,value)
	
func update(value,data):
	electrocute(pot_bol,value)
	return self

func electrocute(ball:BallBodyBase,strength:int):
	ongoing_stuns+=1
	pot_bol=ball
	await STimer.delay(1.65)
	if !is_instance_valid(ball):
		ongoing_stuns-=1
		return
	pot_str=strength
	StatusEffectManager.set_effect(ball_source,ball,"INSTASHOCK",strength)
	ongoing_stuns-=1
	if ongoing_stuns<=0:
		queue_free()

func _process(delta):
	if pot_bol!=null:
		set_counter(ongoing_stuns)
