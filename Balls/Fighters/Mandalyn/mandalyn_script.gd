extends BehaviourScript
@onready var meter_manager:MeterManager = $"../MeterManager"
@onready var health_manager = $"../HealthManager"
@onready var fist_ball = $"../FistBall/FistBall"
@onready var rotater = $"../Rotater"


var stacks:float=1
var fist_active=false
var distance_check=false

var magnistrength = 0.01
func upd():
	fist_ball.stat_controller.set_base_stat("Ball.ball_scale",ball.ball_scale)

func _ready():
	super()
	ball.update_scale.connect(upd)
	ball.team_setted.connect(fist_ball.set_team)
	
	$"../FistBall/FistBall".bounce.connect(shake)
	sc.set_base_stat("ContactDamager.enabled",false)
	$"../FistBall/FistBall/Scaler/WeaponHitbox".ignore_list.append(ball)
	await get_tree().process_frame
	upd()
	
	fist_ball.set_team(ball.team)
	deactivate_fist()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	$"../FistBall/FistBall".skin=ball.skin
	$"../FistBall/FistBall".set_skin.emit()
		
		
func shake():
	Global.quake_trigger.emit(0.25)
#
	#sc.stat_changed.connect(check)
#func check(stat_name,new_val):
	#match stat_name:
		#"Global.enabled":
		
			#fist_ball.visible=fist_active and new_val
				#


	
func hit_process(data):
	var attacker=data["ATTACKER"]
	var victim = data["VICTIM"]
	var type = data["TYPE"]
	
	if victim.is_in_group("AntiInteract"):
		return
	var val=1.0*victim.get_value_scale()
		
	if attacker==ball and type.has("WEAPON") and fist_active==false:
		increase_stack(val)
	if attacker==fist_ball  and fist_active==true:
		increase_stack(val)

func increase_stack(val):
		
	#meter_manager.lose_meter(30)
	stacks+=val
	stacks=min(stacks,max_stack)
	update_scale()
	$"../Rotater/WeaponHolder/WeaponHitbox/WeaponVisual/Weapon/Count".text=str(display_val())
	$"../FistBall/FistBall/Visuals/Count".text=str(display_val())
var max_stack = 10

	
func display_val():
	var val = int(stacks*10)/10.0
	
	if stacks==round(stacks):
		return int(val)
	return val


func fist():
	if fist_check==false:
		activate_fist()
		
var fist_check=false

func preset():
	fist_ball.global_position=ball.global_position
	fist_ball.visible=true
	fist_active=true
	fist_check=true
	fist_ball.set_deferred("freeze",false)
	
	
	fist_ball.stat_controller.set_base_stat("Global.Enabled",true)
	fist_ball.stat_controller.set_base_stat("Hitbox.collision_disabled",false)
	sc.set_base_stat("Hitbox.collision_disabled",true)
	
	sc.set_base_stat("Rotater.visible",false)
	
	$"../FistBall/FistBall/Visuals/Default".visible=true

func activate_fist():
	
	activated_fist.emit()
	#$"../FistBall/FistBall".set_collision_layer_value(5,false)
	#$"../FistBall/FistBall".set_collision_mask_value(5,false)
	#$"../ContactDamager".enabled=true
	
	sc.set_base_stat("ContactDamager.enabled",true)
	update_scale()
	fist_check=true
	var velo=600
	
	
	var dir = Vector2.RIGHT.rotated(rotater.rotation)
	
	await delay(0.35)
	fist_active=true
	update_scale()
	if !Global.can_act(ball):
		deactivate_fist()
	fist_ball.visible=true
	
	fist_ball.global_position = ball.global_position
	fist_ball.freeze = false
	fist_ball.set_velocity(dir * velo)
	
	fist_ball.stat_controller.set_base_stat("Global.Enabled",true)
	fist_ball.stat_controller.set_base_stat("Hitbox.collision_disabled",false)
	sc.set_base_stat("Hitbox.collision_disabled",true)
	
	sc.set_base_stat("Rotater.visible",false)
	$"../FistBall/FistBall/Visuals/Default".visible=true
	
	distance_check=false
	
	
	while fist_ball.global_position.distance_to(ball.global_position) <= 65.0:
		if !get_tree():
			continue
		await get_tree().process_frame
	distance_check=true
	
	#$"../FistBall/FistBall".set_collision_layer_value(5,true)
	#$"../FistBall/FistBall".set_collision_mask_value(5,true)
	
func scale_val():
	return min(1.45,1+0.45*(stacks/12.5))

func update_scale():
	
	sc.set_base_stat("HitboxDamager.damage",max(int(stacks),1))
	sc.set_base_stat("Rotater.rotation_rate",3.0-1.5*(stacks/10.0))
	var velo=600.0+stacks*35
	fist_ball.stat_controller.set_base_stat("HitboxDamager.damage",max(int(stacks),1))
	fist_ball.stat_controller.set_base_stat("HitboxDamager.knockback",300+stacks*15)
	
	
signal activated_fist
signal deactivated_fist
func deactivate_fist():
	deactivated_fist.emit()
	sc.set_base_stat("ContactDamager.enabled",false)
	magnistrength=0.01
	fist_active=false
	fist_check=false
	
	update_scale()
	#$"../ContactDamager".enabled=false
	var dir = ball.global_position.direction_to(fist_ball.global_position)
	
	fist_ball.set_deferred("freeze",true)
	fist_ball.set_deferred("global_position",Vector2(9999,9999))
	#fist_ball.visible=false
	fist_active=false
	#fist_ball.stat_controller.set_base_stat("Ball.velocity",0)
	fist_ball.set_velocity(Vector2(0,1))

	fist_ball.stat_controller.set_base_stat("Global.Enabled",false)
	fist_ball.stat_controller.set_base_stat("Hitbox.collision_disabled",true)
	sc.set_base_stat("Rotater.visible",true)
	$"../Rotater".rotation=dir.angle()
	
	
	sc.set_base_stat("Hitbox.collision_disabled",false)
	meter_manager.clear_meter()
	
	rotater.spin_bounce_boost()

var g_meter=7.5
var l_meter=22.5

func _physics_process(delta):

	if ball.freezed:
		return
	if fist_active:
		if meter_manager.meter>0.0:
			meter_manager.lose_meter(l_meter*delta)
		else:
			if fist_ball.global_position.distance_to(ball.global_position)<75*2.0:
				deactivate_fist()
			magnistrength+=0.0008
			var dir_to_mand = fist_ball.global_position.direction_to(ball.global_position)
			var lerped_angle= lerp_angle(fist_ball.get_velocity().normalized().angle(),dir_to_mand.angle(),magnistrength)
			
			fist_ball.set_velocity(Vector2.from_angle(lerped_angle) * fist_ball.get_velocity().length())
	
	else:
		meter_manager.gain_meter(g_meter*delta) 
		fist_ball.visible=false
		fist_ball.global_position = ball.global_position
	
	if meter_manager.is_full():
		fist()
	
