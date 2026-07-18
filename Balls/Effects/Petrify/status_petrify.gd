extends StatusEffect
var delay=1.0

const PETRIFY = preload("uid://c87dv3ms3rggr")

func check_apply(ball)->bool:
	
	if !super(ball):
		return false
	if ball.is_in_group("AntiPetrify"):
		return false
	return true
	
func damage_check(data:Dictionary):
	var victim=data["VICTIM"]
	var dmg=data["DAMAGE"]
	if victim==baller:
		counter=0.0
	return
	
func set_target(ball,value,data):
	super(ball,value,data)
	EventManager._successfully_damaged_.connect(damage_check)
	counter=value
	baller=ball
	apply_effects(baller)
	#baller.stat_controller.add_modifier("Ball.mass",2,999,"PETRIFIED")
	
	apply_shader(ball)

		

func apply_effects(bal):
	bal.add_to_group("Petrified")
	bal.stat_controller.add_modifier("HitProcessor.immune",2,true,"PETRIFIED")
	bal.stat_controller.add_modifier("ContactDamager.enabled",2,false,"PETRIFIED")
	bal.stat_controller.add_modifier("Hitbox.collision_disabled",2,true,"PETRIFIED")
	bal.stat_controller.add_modifier("BehaviourScript.behaviour_active",2,false,"PETRIFIED")
	
	bal.stat_controller.add_modifier("Rotater.bounce_spin_boost",1,0.01,"PETRIFIED")
	bal.stat_controller.add_modifier("Rotater.locked",2,true,"PETRIFIED")
	bal.stat_controller.add_modifier("Ball.freeze",2,true,"PETRIFIED")
	bal.stat_controller.add_modifier("Ball.bounce_speed_boost",1,0.01,"PETRIFIED")
	bal.stat_controller.add_modifier("Ball.velocity",1,0.001,"PETRIFIED")
	bal.stat_controller.add_modifier("Mood.disabled",2,true,"PETRIFIED")


func wakeup():
	var done=true
	
	await STimer.delay(0.15)
	if is_instance_valid(baller):
		remove_shader(baller)
	queue_free()
	
var done=false
func update(value,data):
	counter +=value
	return self
	

func _physics_process(delta):
	if baller==null or !is_instance_valid(baller):
		return
	if done or HitstopManager.hitstopped:
		return
	counter-=delta
	
	if counter<=0:
		wakeup()

func apply_shader(node: Node):
	for child in node.get_children():
		
		if child is Sprite2D:
			
			if child.is_in_group("AntiPetrify"):
				continue
			var mat := ShaderMaterial.new()
			mat.shader = PETRIFY
			child.material = mat
			child.material.set_shader_parameter("overlay_tex", load("res://Assets/Stone.png"))
		elif child is BallBodyBase:
			apply_effects(child)
		apply_shader(child)
		
##Remove shader
func remove_shader(node: Node):
	if node is Sprite2D and node.material is ShaderMaterial:
		if node.material.shader == PETRIFY:
			node.material = null  
	if node is BallBodyBase:
		
		node.stat_controller.remove_modifier("PETRIFIED")
		node.remove_from_group("Petrified")
	
	for child in node.get_children():
		if !child.is_in_group("AntiPetrify"):
			remove_shader(child)
