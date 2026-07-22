extends BehaviourScript

#sprites
@onready var hurt: Sprite2D = $"../Visuals/Hurt/Hurt"
@onready var warp_hurt: Sprite2D = $"../Visuals/Hurt/WarpHurt"
@onready var default_hurt: Sprite2D = $"../Visuals/Hurt/defaultHurt"
@onready var sigil_a: Sprite2D = $"../Look/Marker2D/sigilA"
@onready var sigil_b: Sprite2D = $"../Look/Marker2D/sigilB"
@onready var icon_2: TextureRect = $"../StatsUI/BallStatDisplay/Box/BattleBar/Icon2"

@onready var hones_ball: BallBodyBase = $".."
@onready var rotater: Rotater = $"../Rotater"
@onready var look: Node2D = $"../Look" # aims dragon lightning
@onready var looper: Node = $Looper
@onready var gain_hit: Node = $GainHit
@onready var meter_autogain: Node = $MeterAutogain

@onready var warpCheckTimer: Timer = $warpCheckTimer
@onready var meter_manager: MeterManager = $"../MeterManager"
@onready var aggro_timer: Timer = $aggroTimer
@onready var hitbox_damager: HitboxDamager = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/HitboxDamager"
@onready var weapon_hitbox: Hitbox = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox"

# sounds
@onready var super_cast: AudioStreamPlayer2D = $"../SuperCast"
@onready var super_fire: AudioStreamPlayer2D = $"../SuperFire"
@onready var begin_warp: AudioStreamPlayer2D = $"../BeginWarp"
@onready var warpSound: AudioStreamPlayer2D = $"../Warp"
@onready var hello: AudioStreamPlayer2D = $"../hello"

@onready var description: Label = $"../StatsUI/BallStatDisplay/WinSpeech/WinBubble/Description"

#tooth ui
@onready var tooth_ui: Control = $"../StatsUI/BallStatDisplay/Box/BattleBar/ToothUI"
@onready var progress_bar: TextureProgressBar = $"../StatsUI/BallStatDisplay/Box/BattleBar/ToothUI/ProgressBar"

var isWarping = false;
var isCastingSuper = false

var canWarp = true
var canSuperWarp = true

signal critController(aggroBool)

var aggroMode = false
var aggroModeController = false:
	get:
		return aggroMode
	set(value):
		aggroMode = value
		#print(value) 
		critController.emit(value) # emits when aggromode is true

var rotOffset = 80.0: # the offset rotation applied to hones' weapon when he warps, clamped so it doesn't turn negative.
	set(value):
		rotOffset = clamp(value, 0.0, INF);

func _ready():
	super()
	gain_hit.gained.connect(super_check)
	warpCheckTimer.timeout.connect(warp_check)
	aggro_timer.timeout.connect(endAggro)
	critController.connect(aggro_check) # controls hones' critrate depending on if isAggro is true
	EventManager.status_effected.connect(status_check)

	sigil_a.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sigil_a.scale.y = 0.0
	sigil_b.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sigil_b.scale.y = 0.0
	
	if ball.skin == "Summer":
		description.text =  "\"Aren't we here to relax...?!\""
		$"../Visuals/ShadowAfterImage".texture = preload("uid://bemi784pmetxc")
		
	await delay(0.1)
	warpCheckTimer.start()

func status_check(data):
	var effect = data["EFFECT"] # end crit window early if grappled
	if effect == "GRAPPLED":
		endAggro()

func hit_process(data:Dictionary):
	var attacker = data["ATTACKER"]
	var victim = data["VICTIM"]
	var type = data["TYPE"]
	if !attacker == ball or victim.is_in_group("AntiInteract"):
		return
	
	if aggroMode && type == ["WEAPON"]: # if aggromode is on, turn it off after refunding meter
		meter_manager.gain_meter(20 * victim.get_value_scale())
		aggroModeController = false

func _physics_process(_delta: float) -> void:
	
	var dir = Global.dir_closest_ball(ball)
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT.rotated(rotater.rotation)
	else:
		look.look_at(Global.closest_ball(ball).global_position)
		
	if meter_manager.meter >= meter_manager.max_meter && !isCastingSuper:
		castSuper()
	
	if spawn_list.size()>0:
		meter_manager.clear_meter()

func super_check(meter_value):
	if meter_value >= 100 && !isCastingSuper && !isWarping:
		castSuper()

func warp_check():
	if !isWarping && !isCastingSuper:
		beginWarp()
		
@onready var shadow_after_image: CPUParticles2D = $"../Visuals/ShadowAfterImage"

func aggro_check(isAggro : bool):
	if isAggro:
		shadow_after_image.emitting = true
		#sc.set_base_stat("HitboxDamager.crit_multiplier", 2.5)
		sc.set_base_stat("HitboxDamager.crit_chance", 1.0)
		$"../Visuals/Default".set_visual("Warp")
		#hitbox_damager.crit_chance = 1.0
	elif !isAggro:
		shadow_after_image.emitting = false
		#sc.set_base_stat("HitboxDamager.crit_multiplier", 2.0)
		sc.set_base_stat("HitboxDamager.crit_chance", 0.0)
		
		$"../Visuals/Default".set_visual("Default")
		#hitbox_damager.crit_chance = 0.065

@onready var blade_afterimager: Node = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/Afterimager"
@onready var default: Sprite2D = $"../Visuals/Default/Default"
@onready var visuals: VisualBody = $"../Visuals"

func beginWarp(): # begins casting the warp, tween and everything
	canWarp = false
	isWarping = true
	
	$"../Visuals/Default".set_visual("Warp")
	hurt.texture = warp_hurt.texture

	sc.set_base_stat("HitProcessor.damage_scale", 0.5)
	begin_warp.play()
	var tween = get_tree().create_tween()
	tween.tween_property(visuals, 'modulate', Color(0, 0, 0, 0), 1.0)
	tween.tween_callback(func():
		var dir = Global.dir_closest_ball(ball)
		if dir == Vector2.ZERO:
			PopUpManager.pop_text("?",ball.global_position+Vector2(0,-60))
			
			warp(ball)
		else:
			var closestBody = Global.closest_ball(ball)
			if is_instance_valid(closestBody):
				warp(closestBody)
		)
	tween.tween_property(visuals, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 0.1)
	await tween.finished
	
	isWarping = false
	hurt.texture = default_hurt.texture
	warpCheckTimer.start()
	
	HitstopManager.set_histop(0.3)
	
func warp(enemy : BallBodyBase): #the actual teleport
	aggroModeController = true # begin critWindow
	aggroMode = true
	blade_afterimager.active=true
	aggro_timer.start()
	var minDist = 196
	if ball == enemy:
		minDist=0
	var angle = ball.global_position.direction_to(enemy.global_position)
	
	var offSet = angle * minDist
	
	
	ball.stat_controller.set_base_stat("Ball.freeze", true)
	await get_tree().physics_frame
	if is_instance_valid(enemy):
		ball.global_position = enemy.global_position + offSet
	%WeaponHitbox.ignore_tick.clear()
	ball.stat_controller.set_base_stat("Ball.freeze", false)
	
	# change weapon angle to cone | commented out
	var dir
	if is_instance_valid(enemy):
		dir = ball.global_position.direction_to(enemy.global_position)
	else:
		dir = ball.global_position.direction_to(Vector2(652.0, 512.0))

	#var enemyDir = rad_to_deg(dir.angle())
	#var randAngle = randf_range(enemyDir - rotOffset, enemyDir + rotOffset)
	#rotater.set_rotation_degrees(randAngle)
	
	#print("rotater rotation is ", rotater.rotation," randAngle is ", randAngle)
	#print("rotater rotation in degrees is ", rotater.rotation_degrees,)
	#print("rotation range is currently ", enemyDir - rotOffset, 'to' , enemyDir + rotOffset)
	#meter_manager.lose_meter(25)

	var randomNum = randi_range(1, 100)
	if randomNum == 5:
		hello.play()
	else:
		warpSound.pitch_scale = randf_range(0.9, 1.1)
		warpSound.play()

	# reset dmg reduction if doing normal warp
	sc.set_base_stat("HitProcessor.damage_scale", 1.0)

	if is_instance_valid(enemy) and enemy!=ball:
		# head along enemy
		ball.set_velocity((enemy.get_velocity().normalized()*enemy.get_velocity().length()))
	
func endAggro(): # ends the crit window
	aggroModeController = false
	blade_afterimager.active=false
	$"../Visuals/Default".set_visual("Default")

func castSuper():
	if isCastingSuper:
		return
	var fired = false
	canWarp = false
	isCastingSuper = true
	super_cast.play()
	var closestBody = Global.closest_ball(ball)
	var tween = get_tree().create_tween()
	var target : Vector2
	tween.tween_property(sigil_a, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 1.0)
	tween.parallel().tween_property(sigil_a, 'scale:y', 2.0, 1.0)
	tween.parallel().tween_property(sigil_b, 'modulate', Color(1.0, 1.0, 1.0, 1.0), 1.0)
	tween.parallel().tween_property(sigil_b, 'scale:y', 3.0, 1.0)
	await delay(1.0)
	if fired == false:
		await delay(1.0)
		sigil_a.modulate = Color(1.0, 1.0, 1.0, 0.0)
		sigil_a.scale.y = 0.0
		sigil_b.modulate = Color(1.0, 1.0, 1.0, 0.0)
		sigil_b.scale.y = 0.0
		shoot()
		meter_manager.clear_meter()
		
		var guardDir = Global.dir_closest_ball(ball,rotater.vec_dir())
		if guardDir == Vector2.ZERO:
			guardDir = Vector2.RIGHT.rotated(rotater.rotation)
		else:
			if is_instance_valid(closestBody):
				target = closestBody.global_position
			else:
				target = Vector2.ZERO

		var dir = (target - ball.global_position).normalized()
		ball.set_velocity(-dir * (ball.get_velocity().length()))
		canWarp = true
		isCastingSuper = false
		fired = true

var dragonLightning = preload("uid://dd4urna6skyxl")

func shoot():
	super_fire.play()
	var dir = Vector2.RIGHT.rotated(look.global_rotation)
	var newd = spawn_thing(dragonLightning)
	var dl = newd.get_node("dragonScript")
	#dl.dl_dmg = randi_range(1, 8)
	dl.connected.connect(dragonHit.bind(newd))
	newd.set_velocity(dir * 1500)
	newd.global_position = $"../Look/Marker2D".global_position

func dragonHit(amt: float, enemy : BallBodyBase, dragon):
	warp(enemy)
	if dragon.team == ball.team:
		meter_manager.gain_meter(amt)
