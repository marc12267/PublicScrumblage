extends StatusEffect
var delay=1.0

func check_apply(ball)->bool:
	if ball.is_in_group("AntiGrapple"):
		return false
	return true

func set_target(ball:BallBodyBase,value,data):
	super(ball,value,data)
	set_counter(value)
	baller=ball
	var grappler = data["GRAPPLER"]
	grappler.tree_exiting.connect(clear_grapple)
	ball.stat_controller.add_modifier("Ball.collision_disabled",2,true,"GRAPPLED")
	ball.stat_controller.add_modifier("HitProcessor.damage_scale",2,1.0,"GRAPPLED")
	ball.stat_controller.add_modifier("Global.Enabled",2,false,"GRAPPLED")

func clear_grapple():
	ungrapple()

func hit_process(data):
	var victim = data["VICTIM"]
	if victim==baller:
		set_counter(counter-1)

func ungrapple():
	if is_instance_valid(baller):
		baller.stat_controller.remove_modifier("GRAPPLED")
	queue_free()
