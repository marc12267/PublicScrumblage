extends BehaviourScript

var level = 1

@onready var meter_manager = $"../MeterManager"
@onready var weapon_hitbox = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox"
@onready var rotater = $"../Rotater"
@onready var hit_processor = $"../HitProcessor"
@onready var clash_bouncer: ClashBouncer = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/ClashBouncer"

var f_res = load("res://Balls/Fighters/Hiro/Fireball.tscn")
var counter: float = 0.0
var fb_dmg = 4


func _ready():
	super()
	sc = ball.stat_controller
	clash_bouncer.clash.connect(mid_gain)
	$Looper.trigger.connect(fire_ball_cast)
	if get_node_or_null("GainHurt")!=null:
		$GainHurt.multiplier = level_scaler()*2.5
		
	

## Calculates how to scale meter gain
## Based off level
func level_scaler() -> float:
	var scale = 1.0
	if level != 3:
		scale = pow(float(3 - level) / 3.0, 1.3)
	return scale

## Check if meter is full to level up
func _physics_process(_delta):
	if HitstopManager.hitstopped:
		return
	if meter_manager.is_full():
		level_up()

## Gain meter off clashes
func mid_gain():
	meter_manager.gain_meter(5 * level_scaler())

## If fireball hits, gain meter
func fhit(amt: float, fball):
	if fball.team == ball.team:
		meter_manager.gain_meter(amt * level_scaler())

func fire_ball_cast():
	var cast_amount = level
	while cast_amount>0:
		cast_amount-=1
		fire_ball()
		await delay(0.1)

## Cast fireball
func fire_ball():
	var dir = Global.dir_closest_ball(ball)
	if dir == Vector2.ZERO or true:
		dir = Vector2.RIGHT.rotated(rotater.rotation)
	var newf = spawn_thing(f_res)
	var fs = newf.get_node("FireballScript")
	fs.connected.connect(fhit.bind(newf))
	newf.set_velocity(dir * 1050)

## Update attributes based off level
func level_up():
	if level >= 3:
		return
	SoundQueue.play("res://Sounds/chiptune-fx-level-up_G_minor.wav", 0.9, 1)
	HitstopManager.set_histop(0.65)
	level += 1
	if %LV:
		%LV.text = "LV:" + str(level)
	if level == 2:
		meter_manager.clear_meter()
		sc.set_base_stat("WeaponHolder.scale", Vector2(1.35, 1.35))
		sc.set_base_stat("HitboxDamager.damage", 6)
		sc.set_base_stat("HitboxDamager.crit_chance", 0.065)
		sc.set_base_stat("Ball.bounce_speed_boost", 380)
		sc.set_base_stat("Rotater.bounce_spin_boost", 6.4)
		sc.set_base_stat("Rotater.rotation_rate", 3.5)
		$GainHit.multiplier = 3.75 * level_scaler()
		if $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/Weapon":
			$"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/Weapon".visible = false
		if $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMid":
			$"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMid".visible = true
		$GainHurt.multiplier = level_scaler() * 4
	if level == 3:
		sc.set_base_stat("WeaponHolder.scale", Vector2(1.85, 1.85))
		sc.set_base_stat("HitboxDamager.damage", 10)
		sc.set_base_stat("HitboxDamager.crit_chance", 0.12)
		sc.set_base_stat("HitboxDamager.self_knockback", 400)
		sc.set_base_stat("HitboxDamager.self_knockback", 0.0)
		sc.set_base_stat("Ball.bounce_speed_boost", 420)
		sc.set_base_stat("Rotater.bounce_spin_boost", 9)
		sc.set_base_stat("Rotater.rotation_rate", 2.2)
		sc.set_base_stat("Rotater.normalizer_rate", 10.6)
		sc.set_base_stat("ClashBouncer.cleave", true)
		sc.set_base_stat("Mood.trigger_chance", 0.3)
		if $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMid":
			$"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMid".visible = false
		if $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMax":
			$"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox/WeaponVisual/WeaponMax".visible = true
		$GainHit.multiplier = 2 * level_scaler()
	
