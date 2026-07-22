extends "res://Balls/Fighters/Mandalyn/mandalyn_script.gd"
var growth_amount=0.03

func _ready():
	super()
	
	$"../Rotater/WeaponHolder/WeaponHitbox/ClashBouncer".deflected.connect(inc.unbind(1))
	$"../FistBall/FistBall/Scaler/WeaponHitbox/ClashBouncer".deflected.connect(inc.unbind(1))

func inc():
	increase_stack(1)

func increase_stack(val):
	stacks+=val
	update_scale()
	$"../Rotater/WeaponHolder/WeaponHitbox/WeaponVisual/Weapon/Count".text=str(display_val())
	$"../FistBall/FistBall/Visuals/Count".text=str(display_val())
	
	upd()

func hit_process(data):
	var attacker=data["ATTACKER"]
	var victim = data["VICTIM"]
	var type = data["TYPE"]
	var id = data["ID"]
	
	if victim.is_in_group("AntiInteract"):
		return
	var val=1.0*victim.get_value_scale()
		
	if attacker==ball:
		if type.has("WEAPON") and fist_active==false:
			increase_stack(val)
		if id == "MandaMelee":
			StatusEffectManager.set_effect(ball,victim,"STUNNED",1,{"SFXMUTE":true})
	elif attacker==fist_ball:
		if id == "FIST":
			StatusEffectManager.set_effect(ball,victim,"STUNNED",0.5,{"SFXMUTE":true})
	if attacker==fist_ball  and fist_active==true:
		increase_stack(val)
	
		
		
func display_val():
	var val = min(int(stacks*10)/10.0,10)
	
	if stacks==round(stacks):
		return int(val)
	return val
	
func upd():
	
	sc.set_base_stat("WeaponHolder.scale",Vector2(1,1)*(1+(growth_amount*max(0,stacks-max_stack))))
	fist_ball.stat_controller.set_base_stat("Ball.ball_scale",(1+(growth_amount*max(0,stacks-max_stack))*ball.ball_scale))

func update_scale():
	if fist_active:
		sc.set_base_stat("Ball.velocity",850)
	else:
		sc.set_base_stat("Ball.velocity",max(400,650-300*pow(max(0,stacks-10)/10.0,2)))
	
	sc.set_base_stat("HitboxDamager.damage",min(max(int(stacks),1),10))
	sc.set_base_stat("Rotater.rotation_rate",max(0.75,3.0-1.5*(stacks/10.0)))
	sc.set_base_stat("Rotater.bounce_speed_boost",2.75+min(0.75,0.75*((stacks-10.0)/10.0)))
	var velo=600.0+stacks*35
	fist_ball.stat_controller.set_base_stat("HitboxDamager.damage",min(max(int(stacks),1),10))
	fist_ball.stat_controller.set_base_stat("HitboxDamager.knockback",300+stacks*15)
	fist_ball.stat_controller.set_base_stat("Ball.velocity",900-min(0,400*pow(max(0,stacks-10.0)/10.0,1.5)))
	print(900-min(350,200*pow((stacks-10.0)/10.0,2)))
	print(stacks)
