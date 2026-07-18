extends BehaviourScript
@onready var meter_manager:MeterManager = $"../MeterManager"
var active = false
var triggered=false
@onready var weapon = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/Weapon"
@onready var weapon_2 = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/Weapon2"
@onready var rotater = $"../Rotater"
@onready var hitbox_damager = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/HitboxDamager"
@onready var weapon_hitbox = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox"
var gain_meter_rate = 7.5
var lost_meter_rate = 30
var kiss_cd=1.0
func _ready():
	super()
	weapon_hitbox.hit_weapon.connect(clash_gain.unbind(1))
	sc=ball.stat_controller
	
	EventManager.status_effected.connect(status_handle)
	ball.bounce_ball.connect(kiss_check)

var kiss_ignore = []

func kiss_check(b:BallBodyBase):
	if !behaviour_active or kiss_cd>0.0:
		return
	if kiss_ignore.has(b) or( !b.is_in_group("Main") and !b.is_in_group("Minion")):
		return
	var chance=0.05
	if active:
		chance*=2
	if randf()<chance:
		kiss(b)

@onready var default: Node2D = $"../Visuals/Default"

func kiss(b:BallBodyBase):
	kiss_cd=2.0
	default.set_visual("Kiss")
	HitstopManager.set_histop(0.2)
	SoundQueue.play("res://Sounds/kiss-sfx.wav")
	
	var kiss_sprite=Sprite2D.new()
	
	kiss_sprite.texture=load("res://Balls/Fighters/Thong/orbkiss.png")
	if b.get_node("Visuals")!=null:
		b.get_node("Visuals").add_child(kiss_sprite)
		var random_dir = Vector2.RIGHT.rotated(randf() * TAU)
		var random_dist = sqrt(randf()) * 60
		var offset = random_dir * random_dist
		kiss_sprite.position=offset
		kiss_sprite.rotation = deg_to_rad(randf_range(-25, 25))
	
	if b.scene_file_path=="res://Balls/Fighters/Phil/ball_phil.tscn":
		b.data_transfer.emit({"ID":"KISSED"})
		kiss_sprite.position=Vector2(50,40)
	await HitstopManager.resume
	
	default.set_visual("Default")
	return

	
func status_handle(data):
	var victim = data["VICTIM"]
	var strength = data["STRENGTH"]
	if victim==ball:

		if strength != -1:
			if sc.get_stat("BehaviourScript.behaviour_active")==false:
				sc.set_base_stat("HitProcessor.immune",false)
		else:
			
			if sc.get_stat("BehaviourScript.behaviour_active")==true:
				sc.set_base_stat("HitProcessor.immune",active)
				

@onready var after_imager: Node = $AfterImager


func clash_gain():
	if active:
		return
	#meter_manager.gain_meter(7.5)

var charge_hit_list=[]

func hit_process(data):
	if data["ID"]!="Trident":
		return
	var attacker=data["ATTACKER"]
	var victim = data["VICTIM"]
	var critcheck = data["CRIT"]
	if attacker==ball:
		var strength=2
		kiss_cd-=0.5
		if critcheck:
			strength=4
		StatusEffectManager.set_effect(ball,victim,"ELECTRO",strength)
		
		
		if victim.is_in_group("AntiInteract"):
			return
		
		if !active:
			return
		else:
			var mul=victim.get_value_scale()
				
	elif victim==ball:
		kiss_cd+=1.0
		
func charge():
	if active==true or triggered==true:
		return
	charge_hit_list.clear()
	triggered=true
	await delay(0.4)
	SoundQueue.play("res://Sounds/acceleration-sfx_G_minor.wav")
	await delay(0.4)
	
	if !Global.can_act(ball):
		return
		
	
	ball.set_velocity(Vector2.RIGHT.rotated(rotater.rotation) * ball.get_velocity().length())
	charge_start()
	
func charge_start():
	
	after_imager.active=true
	$"../Rotater/WeaponHolder".position=Vector2(20,0)
	sc.set_base_stat("HitProcessor.immune",true)
	active=true
	weapon.visible=false
	weapon_2.visible=true
	sc.set_base_stat("Ball.velocity",1250)
	sc.set_base_stat("Ball.normalizer_speed_up",100)
	sc.set_base_stat("Rotater.rotation_rate",0.01)
	sc.set_base_stat("Rotater.normalizer_rate",70)
	sc.set_base_stat("Rotater.bounce_spin_boost",0.0)
	sc.set_base_stat("Rotater.flipper_min",0.0)
	sc.set_base_stat("ClashBouncer.disable",true)
	sc.set_base_stat("ClashBouncer.cleave",true)
	sc.set_base_stat("HitboxDamager.knockback",400.0)
	sc.set_base_stat("HitboxDamager.self_knockback",500.0)
	sc.set_base_stat("HitboxDamager.crit_chance",1)
	
	sc.set_base_stat("Mood.disabled",true)
	
	
func charge_end():
	
	after_imager.active=false
	$"../Rotater/WeaponHolder".position=Vector2(76,0)
	sc.set_base_stat("HitProcessor.immune",false)
	triggered=false
	active=false
	weapon.visible=true
	weapon_2.visible=false
	sc.set_base_stat("Ball.velocity",500)
	sc.set_base_stat("Ball.normalizer_speed_up",20)
	sc.set_base_stat("Rotater.rotation_rate",1)
	sc.set_base_stat("Rotater.normalizer_rate",7)
	sc.set_base_stat("Rotater.bounce_spin_boost",3)
	sc.set_base_stat("Rotater.flipper_min",10)
	sc.set_base_stat("ClashBouncer.cleave",false)
	sc.set_base_stat("ClashBouncer.disable",false)
	sc.set_base_stat("HitboxDamager.self_knockback",150.0)
	sc.set_base_stat("HitboxDamager.knockback",100.0)
	sc.set_base_stat("HitboxDamager.crit_chance",0.0)
	sc.set_base_stat("Mood.disabled",false)


func _physics_process(delta):
	if ball.freezed==true:
		return
	kiss_cd=max(0.0,kiss_cd-delta)
	if active:
		var val = ball.get_velocity().angle()
		
		rotater.rotation = lerp_angle(rotater.rotation, val, 0.125)
		
		meter_manager.lose_meter(lost_meter_rate*delta)
		if meter_manager.meter<=0:
			charge_end()
			
	else:
		
		meter_manager.gain_meter(gain_meter_rate*delta) 

	
	if meter_manager.is_full():
		charge()
	
