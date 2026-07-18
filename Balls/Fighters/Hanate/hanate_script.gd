extends BehaviourScript

@onready var rotater = $"../Rotater"
@onready var lazer_collision = $"../Rotater/LazerArea/CollisionShape2D"
@onready var lazer_area = $"../Rotater/LazerArea"
@onready var danger_zone = $"../ExplosionRadius"
@onready var weapon_hitbox = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox"
@onready var beam_charge_particles = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/CPUParticles2D"

var rot_lock=null

## Max stacks reached
var maxed: bool = false

## Spell related variables
var active: bool = false
var casting: bool = false
var charging: bool = false
var charged_at_time: int = 0
var lazering: bool = false
var starstorming: bool = false

## How many weapon hits were successful
var scale_hits: int = 0;
var random_atk: int = 0;

@export_category("Charge Balance")
## Base damage for the charge attack. It's divided in 2, for direct hit and splash damage.
@export var charge_base_damage: int = 6
## Duration of the charge in seconds.
@export var charge_timer: float = 1.2

@export_category("Laser Balance")
## Base laser duration in seconds.
@export var lazer_duration: float = 1;
## Base width of the laser.
@export var base_width := 0.9

@export_category("Barrage Balance")
## Base amount of stars shot by the barrage attack
@export var star_count : int = 3
## Time between star shots in seconds
@export var shoot_delay: float = 0.3

@export_category("Stack Balance")
## Stack count until Hanate reaches full power.
@export var max_stacks: int = 10

## The texture Hanate switches to when she gets kissed
var kissed_texture: CompressedTexture2D = preload("uid://db0ox72sl8655")
var effects = StatusEffectManager.get_effects(ball)

var initial_team: int = -1;

func _ready():
	super()
	ball.bounce_wall.connect(slam_check_wall)
	ball.bounce_ball.connect(slam_check_ball)
	lazer_area.visible=false
	
	## When status affect is applied, connect to this function
	EventManager.status_effected.connect(status_affected)
	
	ball.data_transfer.connect(kiss_check)
	
	await EventManager.round_start
	initial_team = ball.team
	particle_recolorer()
	
	
	

## When kissed (by Thong), change the textures of the non-hurt sprites.
func kiss_check(data):
	if data.get("ID","")=="KISSED":
		$"../Visuals/Default/Default".texture = kissed_texture
		$"../Visuals/Default/Casting".texture = kissed_texture
		
## If we are afflicted by status effects that disable our behaviour script
## Hide lazer and set some stats
func status_affected(data):
	var victim = data["VICTIM"]
	var strength = data["STRENGTH"]
	effects = StatusEffectManager.get_effects(ball)
	
	if victim==ball:
		if strength != -1:
			if sc.get_stat("BehaviourScript.behaviour_active")==false:
				%BeamParticles.visible=false
				lazer_area.visible=false
				sc.set_base_stat("LazerHitbox.collision_disabled",true)
				lazer_loop.volume_db=-80
		else:
			if sc.get_stat("BehaviourScript.behaviour_active")==true:
				%BeamParticles.visible=lazering
				lazer_area.visible=lazering
				sc.set_base_stat("LazerHitbox.collision_disabled",!lazering)
				lazer_loop.volume_db=5

@onready var autogain: Node = $Autogain

var charge_time: float = 0.0

## Calls when rolled for the dash attack
## Set out active flag to true to indicate we are dashing
func charge():
	if active:
		return
	
	health_manager.add_overhealth(scale_hits)
	if maxed:
		health_manager.add_overhealth(5)
	active = true
	rotater.aiming=true
	rotater.aim_speed= (0.08)
	
	sc.set_base_stat("Rotater.rotation_rate",0.0)
	sc.set_base_stat("Rotater.bounce_spin_boost",0.0)
	sc.set_base_stat("Ball.velocity",200)
	sc.set_base_stat("HitProcessor.knockback_scale",0.9)
	sc.set_base_stat("HitProcessor.damage_scale",0.5)
	sc.set_base_stat("Mood.disabled",true)
	
	$"../Visuals/Default".set_visual("Casting")
	
	%FireGather.emitting=true
	%FireGather.speed_scale = 5.0
	
	%GenericGather.emitting = true
	%GenericGather.speed_scale = 2.0
	
	var particle_speed_scale := create_tween()
	
	particle_speed_scale.tween_property(%FireGather, "speed_scale", 8, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
		
	particle_speed_scale.tween_property(%GenericGather, "speed_scale", 5, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	SoundQueue.play("uid://bsqrxc238b11a",1,0.7)
	## Power up and wait delay before dashing
	await delay(0.6)
	
	ball.set_velocity(ball.get_velocity().normalized())
	%HanateShine.emitting = true
	%FireGather.emitting=false
	%GenericGather.emitting=false
	SoundQueue.play("uid://du7q4whl7sh2k",1,0.8)
	weapon_hitbox.active = false
	
	await delay(0.1)
	
	sc.set_base_stat("Ball.velocity",0)
	%FirePath.emitting = true
	SoundQueue.play("uid://bpc1kcybd8mhr",0.9,0.5)
	
	## Check if we can dash before enabling things
	if !Global.can_act(ball):
		charge_end()
		return

	## Enable and set Hanate's contact damage
	charging = true
	charged_at_time = Time.get_ticks_msec()
	charge_time = 1.2
	
	$Afterimager.active=true
	$"../ContactDamager".contact_damage = roundi((charge_base_damage + scale_hits) / 2)
	#$"../ContactDamager".contact_damage = 4
	$"../ContactDamager".enabled = true

func slam_check_wall(wall):
	if charging and (Time.get_ticks_msec()-charged_at_time)>300:
		explosion()
		sc.set_base_stat("HitProcessor.knockback_scale",1)

func slam_check_ball(chk):
	if charging:
		if chk.team != ball.team:
			explosion()
			sc.set_base_stat("HitProcessor.knockback_scale",1)
		
## Check if the charge has hit
var charge_has_hit: bool = false

## Hit enemies caught in the explosion radius
func explosion():
	%DashBurst.emitting = true
	%DashAftershock.emitting = true
	%DashEndParticles.emitting = true
	
	$"../Boom2".global_position=ball.global_position
	$"../Boom2/AnimationPlayer".play("Boom")
	Global.quake_trigger.emit(2.2)
	SoundQueue.play("uid://bg3c6abvkejm0",1,0.5)
	var bodies = danger_zone.get_overlapping_bodies()
	bodies.erase(ball)
		#await get_tree().process_frame
		
	for i in bodies:
		charge_has_hit = true
		if !i is BallBodyBase:
			continue
		if i.team==ball.team:
			continue
		charge_damage(i)
	charge_end()

## Determines how much damage the explosion from the dash does
func charge_damage(victim):
	var dir = ball.global_position.direction_to(victim.global_position)
	var dmg = roundi((charge_base_damage + scale_hits) / 2)
	#dmg=4
	
	var data_dict={"DAMAGE": dmg,
				"ATTACKER":ball,
				"VICTIM":victim,
				"KNOCKBACK":160,
				"DIRECTION":dir,
				"SELF_KNOCKBACK":(ball.get_velocity().length()/4),
				"CRIT_CHANCE":0.0,
				"CRIT_MULTIPLIER":1,
				"TYPE":["EXPLOSION"],
				"SFX":"",
				"ID":"SHOOTING_STAR",
				"MISC":{}}
	EventManager.hit.emit(data_dict)

## Set stuff back to normal when the charge ends
func charge_end():
	$Afterimager.active=false
	meter_manager.set_meter(0)
	sc.set_base_stat("HitProcessor.knockback_scale",1)
	
	sc.set_base_stat("HitProcessor.damage_scale",1)
	
	rot_lock=null
	rotater.aiming=false
	casting=false
	charging=false
	
	## Disable contact damage
	$"../ContactDamager".enabled = false
	charge_time = 0.0
	
	%FirePath.emitting = false
	
	charge_has_hit = false
	
	sc.set_base_stat("Rotater.rotation_rate",7)
	sc.set_base_stat("Rotater.bounce_spin_boost",10.0)
	sc.set_base_stat("Ball.velocity",650)
	active=false
	
	# so sometimes she takes full damage while charging but not exploded yet and
	# seting the damage scale a bit after it ends fixes it somehow
	await delay(0.1)
	sc.set_base_stat("Mood.disabled",false)
	$"../Visuals/Default".set_visual("Default")
	await delay(0.3)
	weapon_hitbox.active = true
	
## Called when out lazer starts
## Set out active flag to true to indicate we are shooting
func lazer():
	if active:
		return
	active=true
	autogain.enabled=false
	
	sc.set_base_stat("Rotater.rotation_rate",0.0)
	sc.set_base_stat("Rotater.bounce_spin_boost",0.0)
	sc.set_base_stat("Ball.velocity",25)
	sc.set_base_stat("Mood.disabled",true)
	
	lazer_scale = 0.0
	
	$"../Visuals/Default".set_visual("Casting")
	
	beam_charge_particles.emitting=true
	beam_charge_particles.speed_scale = 2.0
	
	%BeamGather.emitting = true
	
	var particle_speed_scale := create_tween()
	
	particle_speed_scale.tween_property(beam_charge_particles, "speed_scale", 4.5, 0.75)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	rotater.aiming=true
	rotater.aim_speed= 0.05
	
	SoundQueue.play("uid://ud5tbqj4o0h0",1.25,0.8)
	
	## Power up and wait delay before releasing lazer
	await delay(0.75)
	
	%CrystalShine.emitting = true
	%BeamReadyParticles.emitting = true
	beam_charge_particles.emitting=false
	%BeamGather.emitting = false
	SoundQueue.play("uid://du7q4whl7sh2k",1,0.8)
	
	await delay(0.25)
	
	## Check if we can fire before enabling things
	if !Global.can_act(ball):
		lazer_end()
		return
	
	%BeamParticles.visible=true
	
	Global.quake_trigger.emit(1.3)
	## Enable our collisions 
	#weapon_hitbox.active = false
	sc.set_base_stat("LazerHitbox.collision_disabled",false)
	
	lazer_sound()
	
	lazering=true
	casting=true
	
	lazer_area.visible=true
	
	lazer_area.scale.y = 0.01
	
	var tween := create_tween()
	tween.tween_property(self, "lazer_scale", 0.1, 0.05)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	%BeamLines.emitting = true
	%BeamCircle.emitting = true
	%BeamWave.emitting = true
	%BeamBurst.emitting = true
	
	tween.tween_property(self, "lazer_scale", 1.2, 0.08)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "lazer_scale", 1.0, 0.05)
	await tween.finished
	
	ball.set_velocity((ball.get_velocity()-Vector2.RIGHT.rotated(rotater.rotation)*500))
		
@onready var lazer_start = $"../LazerStart"
@onready var lazer_loop = $"../LazerLoop"
@onready var lazer_ender = $"../LazerEnd"

## Lazer sfx setip
func lazer_sound():
	lazer_start.play()
	lazer_loop.play()
	await lazer_loop.finished
	lazer_ender.play()

## Function when lazer ends
## Disables everything
func lazer_end():
	#weapon_hitbox.active = true
	%ClashBouncer.projectile_deflecter = false
	autogain.enabled=true
	sc.set_base_stat("LazerHitbox.collision_disabled",true)
	$"../LazerLoop".stop()
	rotater.aiming=false
	lazering=false
	casting=false
	
	$"../Visuals/Default".set_visual("Default")
	%BeamLines.emitting = false
	%BeamCircle.emitting = false
	%BeamWave.emitting = false
	%BeamParticles.visible=false
	
	lazer_collision.disabled=true
	sc.set_base_stat("Rotater.rotation_rate",6)
	sc.set_base_stat("Rotater.bounce_spin_boost",10.0)
	sc.set_base_stat("Ball.velocity",650)
	sc.set_base_stat("Mood.disabled",false)

	lazer_area.visible=false
	active=false

## Amount of stars launched during the star storm attack


## Called when rolled for starstorm
## Set out active flag to true to indicate we are starstorming
func starstorm():
	if active:
		return
	active = true
	
	autogain.enabled=true
	autogain.gain_rate/=2.0
	meter_manager.set_meter(0)
	
	sc.set_base_stat("Ball.velocity",130)
	%BeamGather.emitting = true
	beam_charge_particles.emitting = true
	beam_charge_particles.speed_scale = 3.0
	
	$"../Visuals/Default".set_visual("Casting")
	
	var particle_speed_scale := create_tween()
	
	particle_speed_scale.tween_property(beam_charge_particles, "speed_scale", 6, 0.6)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	SoundQueue.play("uid://8q62vhaxketb")
	
	await delay(0.5)
	
	sc.set_base_stat("Rotater.locked",true)
	sc.set_base_stat("Rotater.bounce_spin_boost",0.0)
	Global.rotate_to(rotater,4.7,0.2)
	
	%CrystalShine.emitting = true
	SoundQueue.play("uid://du7q4whl7sh2k",1,0.8)
	%BeamGather.emitting = false
	beam_charge_particles.emitting = false
	
	await delay(0.2)
	
	starstorming = true
	shoot()

func shoot():
	if !active:
		return
	
	if !Global.can_act(ball):
		shoot_end()
		return
	
	var shoot_amounts=star_count
	for i in range(shoot_amounts):
		shoot_star()
		await delay(shoot_delay)
		if !Global.can_act(ball):
			shoot_end()
			return
	shoot_end()

var star_res = load("res://Balls/Fighters/Hanate/Starstorm.tscn")
var shootPart_res = preload("res://Balls/Fighters/Hanate/Particles/StarStormShoot.tscn")

## Shoot a star and spawn it with different targetting modes
func shoot_star():
	SoundQueue.play("uid://d2l7fdjl003uj", 1.0, 0.5)
	var position = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual".global_position
	ParticleSpawner._spawn_particle_effect(shootPart_res, position)
	await delay(randf_range(0.2,0.3))
	var closest = Global.closest_ball(ball)
	var newb = spawn_thing(star_res)
	
	newb.behaviour_script.hit_gain.meter_manager = meter_manager
	
	 ## 1 = Predicts path, 2 = Spawns directly on top, 3 = Random from pos
	var spawn_mode = randi_range(1,3)
	#print("Star spawn mode: " + str(spawn_mode))
	
	var minDist = 100
	var angle = randf_range(0.0, TAU)
	
	if is_instance_valid(closest):
		if spawn_mode == 1:
		# Will attempt to shoot a star in the opponents path
			var offSet = closest.get_velocity() * 0.25
			var xtra_off = Vector2.from_angle(angle) * minDist
		
			newb.global_position = closest.global_position + offSet + xtra_off
		if spawn_mode == 2:
			newb.global_position = closest.global_position
		if spawn_mode == 3:
			var offSet = Vector2.from_angle(angle) * minDist
			newb.global_position = closest.global_position + offSet
	
	# If outside arena, will just spawn on top of opponent
	if Global.game_mode == Global.GAME_MODES.ONEVONE:
		# there has to be a better way to do this...
		if (newb.global_position.y > 828 or newb.global_position.y < 125) or (newb.global_position.x > 1210 or newb.global_position.x < 90):
			#print("Outside arena, moving to opponent position")
			newb.global_position = closest.global_position
	newb.set_velocity(Vector2(0,0))

## Return stats to normal
func shoot_end():
	
	sc.set_base_stat("Ball.velocity",650)
	active = false
	starstorming = false
	autogain.gain_rate*=2.0
	#autogain.enabled=true
	$"../Visuals/Default".set_visual("Default")
	sc.set_base_stat("Rotater.locked",false)
	sc.set_base_stat("Rotater.bounce_spin_boost",10.0)

var lazer_scale = 0.0

var amplitude := 0.2
var speed := 70.0
@onready var meter_manager = $"../MeterManager"
@onready var health_manager: HealthManager = $"../HealthManager"

var lazer_tick=0.0

var recolored = false

func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	
	## If sequence is active dynamically calculate visual for lazer
	if active:
		var t := Time.get_ticks_msec() / 1000.0
		var width = base_width + sin(t * speed) * amplitude
		width = width * lazer_scale
		lazer_area.scale.y=width
		lazer_tick+=delta
		
		## If lazer beam is firing, lose meter and adjust the aiming strength of rotater.
		## rotater.aim_speed is not tracked by stat_controller so we adjust directly
		if lazering:
			meter_manager.lose_meter((100*delta)/lazer_duration)
			
			rotater.aim_speed=lerpf(rotater.aim_speed,0.003,delta*0.6)
			
			if meter_manager.meter<=0:
				lazer_end()
	else:
		## While not shooting lazer, check if meter is full, if it is, cast a random spell
		if meter_manager.meter==meter_manager.max_meter and !lazering and !casting and rot_lock==null:
			random_spell()

	## If we are shooting lazer, add velocity pushback on ball opposite to direction
	## Of the rotater
	if lazering:
		var dir = -rotater.vec_dir()
		ball.add_velocity(dir*400*delta)
		
	## If charging, move rapidly at the direction of the rotater
	if charging:
		var dir = rotater.vec_dir()
		ball.add_velocity(dir*155)
		
		charge_time -= delta
		
		## When timer hits 0, stops the charge
		if charge_time <= 0:
			charge_end()

var last_atk = -1

func random_spell() -> void:
	random_atk = randi_range(0,2)
	#random_atk = 0
	#if random_atk == last_atk:
		#random_spell()
		#return
	if random_atk == 0:
		charge()
	elif random_atk == 1:
		lazer()
	elif random_atk == 2:
		starstorm()
	#last_atk = random_atk

## Unique hit process so Hanate doesn't scale when she's casting spells
func hit_process(data):
	var attacker = data["ATTACKER"]
	var victim = data["VICTIM"]
	var dmg = data["DAMAGE"]
	var type = data["TYPE"]
	
	var meter_scale = victim.get_value_scale()
	
	if victim.is_in_group("AntiInteract"):
		return
	if attacker == ball:
	### Check if victim has a health manager, and if they do, check if they're alive
		#if victim.has_node("HealthManager"):
			#if victim.stat_controller.get_stat("HealthManager.health") <= 0:
				#return
	## If hit someone with the weapon and dealt at least one damage while also not currently casting spells, scale
		if dmg >= 0.1 && type == ["WEAPON", "CRYSTAL"] && !active:
			## If the main opponent wasn't hit, only gain partial scaling
			if meter_scale<1: partial_scale(meter_scale)
			else: 
				scale(meter_scale)
		

## Gain meter
func meter_gain(meter_scale) -> void:
	if !maxed: meter_manager.gain_meter(7.5 * meter_scale)
	else: meter_manager.gain_meter(12.5 * meter_scale)

## Hit counter for when Hanate hits non main opponents
var partial_scale_hits: float = 0

## Hit three non main balls to scale once
func partial_scale(meter_scale: float = 0.5) -> void:
	partial_scale_hits+=meter_scale
	
	if partial_scale_hits < 1:
		SoundQueue.play("uid://djkl8sbadet4j",1,0.2)
		%EnergyGather.emitting = true
		%GatherShine.emitting = true
	
		partial_scale_hits += meter_scale
		meter_gain(meter_scale)
	elif partial_scale_hits >= 1:
		partial_scale_hits = 0
		scale(1)

var max_stack_color: Color = Color.AQUA

@onready var scale_label = $"../StatsUI/BallStatDisplay/Box/BattleBar/Scale Hits"

## Scaling when hitting enemy ball with weapon, makes spells stronger and meter gain faster
func scale(meter_scale: float) -> void:
	meter_gain(meter_scale)
	
	SoundQueue.play("uid://djkl8sbadet4j",randf_range(1.14, 1.22),0.2)
	%EnergyGather.emitting = true
	%GatherShine.emitting = true
	
	partial_scale_hits = 0
	# Gain meter when hitting an opponent
	
	if initial_team != ball.team:
		return
	
	if maxed:
		return
	
	# Scaling maxes out at a certain amount of hits
	if scale_hits < max_stacks:
		
		scale_hits += 1
		scale_label.text = str(scale_hits)
	
	# Visual Scaling
		%BeamGather.amount += 1
	# Faster Meter Gain
		autogain.gain_rate += 1
	# Starstorm Scaling
		shoot_delay -= (0.1 / max_stacks)
		# Every 3 hits, increase star count by 1
		if scale_hits % 3 == 0:
			star_count += 1
	# Cosmic Cannon Scaling
		lazer_duration += 0.12
		#base_width += (0.7 / max_stacks)
	
	# When you reach max stacks, spells power up even more
	await delay(0.1)
	if scale_hits == max_stacks:
		scale_label.self_modulate = max_stack_color
		maxed = true

		autogain.gain_rate = 25
		
		%HanateShine.emitting = true
		SoundQueue.play("uid://c5x5vh7qcsxym", 1, 0.75)
		SoundQueue.play("uid://cwxtxy1fuqo1f", 1.1, 0.8)
		
		base_width += 0.8
		%BeamCircle.scale_amount_min += 0.35
		%BeamCircle.scale_amount_max += 0.35
		
		%BeamWave.scale_amount_min += 0.8
		%BeamWave.scale_amount_max += 0.8
		
		%BeamBurst.scale_amount_min += 0.8
		%BeamLines.emission_rect_extents.y += 20
		
		lazer_area.tick_wait = 0.08
		star_count += 1
		
## Recolors all of Hanate's particles (and other effects) based on the skin
func particle_recolorer() -> void:
	if ball.skin == "Summer":
		$"../Rotater/LazerArea/ColorRect2".color = Color(0.929, 0.271, 0.686)
		$"../Boom2/Sprite2D".modulate = Color(4.165, 0.965, 3.205, 0.337)
		
		%StarParticles.color_ramp = load("uid://lgy16rtcrr1r")
		%HanateShine.color_ramp = load("uid://bg1g360virnv8")
		%FireGather.color_ramp = load("uid://dsxeyevqe00tl")
		%FirePath.color_ramp = load("uid://0pkh44ryoyca")
		%DashBurst.color_ramp = load("uid://bitdp1by4ok33")
		%DashEndParticles.color_ramp = load("uid://db0m786gdvcjb")
		%EnergyGather.color_ramp = load("uid://b8km8r2cngcgj")
		%GatherShine.color_ramp = load("uid://sw7de4d47dse")
		%BeamReadyParticles.color_ramp = load("uid://d4jjan3o6x3wg")
		%CrystalShine.color_ramp = load("uid://rid4bd123uv1")
		
		kissed_texture = preload("uid://dn0x4kh0vlb64")
		max_stack_color = Color.LIGHT_PINK
		shootPart_res = load("res://Balls/Fighters/Hanate/Particles/StarStormShoot-Summer.tscn")
		
		print("recolored particles for " + ball.skin)
