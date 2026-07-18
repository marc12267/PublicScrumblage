extends BehaviourScript
@onready var meter_manager = $"../MeterManager"
@onready var weapon_hitbox = $"../Rotater/WeaponHolder/WeaponFlipper/WeaponHitbox"
@onready var rotater = $"../Rotater"

## Dictionary of summonable stuff
var turret_types:Dictionary = {"Shooter":preload("res://Balls/Fighters/Katie/k_turret.tscn"),
"Cutter":preload("res://Balls/Fighters/Katie/k_cutter.tscn"),
"Healer":preload("res://Balls/Fighters/Katie/k_healer.tscn")
}
## List of turrets we summon
var my_turrets:Array = []

func _ready():
	super()
	turret_pos = randi_range(0,2)
	## Connect signal from our weapon to check what it detects stuff
	## Use this to check to heal our turrets
	weapon_hitbox.hit_ball.connect(hit_turret)

var heal_amount=8

## When we hit a turret, check it's type and tea,
## If valid target, we heal it
func hit_turret(target:BallBodyBase):
	if target.is_in_group("Robot") and target.team==ball.team:
		if target.stat_controller.get_stat("HealthManager.health")==null:
			return
		if target.stat_controller.get_stat("HealthManager.health")< target.stat_controller.get_stat("HealthManager.max_health"):
			StatusEffectManager.set_effect(ball.get_root_creator(),target,"INSTAHEAL",heal_amount)
			rotater.flipper()
			#var dir = (target.global_position.direction_to(ball.global_position)).normalized()

			#ball.set_velocity(dir*ball.get_velocity().length())
			SoundQueue.play("res://Sounds/Tf2 SFX Wrench.wav",1.0,0.5)
	
			HitstopManager.set_histop(0.1)

## Pos is our position within the array as we iterate through
var turret_pos=0
func ability():
	## Iterate through turret types every summon and get the next one to spawn
	var turret_type = ""
	var turr_types=turret_types.keys()
	turret_type=turr_types[turret_pos%turr_types.size()]
	turret_pos+=1
	
	## If our size is past 3, despawn our oldest
	if my_turrets.size()>=3:
		my_turrets.pop_front().queue_free()
	
	## For error in case something goes wrong
	if turret_type=="":
		return
	
	## Clear our meter, and spawn the turret
	## Set it's position to katie
	meter_manager.clear_meter()
	var clone:BallBodyBase = spawn_thing(turret_types[turret_type],false)
	var rand_dir=ball.global_position.direction_to(Global.center)
	rand_dir=-rand_dir
	clone.global_position+=rand_dir*100
	
	## Every time we add turret, calle electricity wall to set the lazer conencter between them
	for i in my_turrets:
		electricity_wall(clone,i)
		
	## Add new turret to our list
	## If it dies remove from list
	my_turrets.append(clone)
	clone.prefreeze_l_velocity=rand_dir
	clone.tree_exiting.connect(func remove_turret():my_turrets.erase(clone))
	clone.hitstop_effect(ball.freezed)
	ball.get_parent().call_deferred("add_child",clone)
	#ball.get_parent().add_child(clone)
	await clone.ready
	clone.set_team(ball.team)
	clone.get_node("TurretScript").katie=ball

## When we collect scrap we increase scrap boost, which increases our meter gain rate
var scrap_boost=0.0
func scrap_meter():
	SoundQueue.play("res://Sounds/Quake_ammo_pickup_remastered.wav")
	scrap_boost+=75
	
func _physics_process(delta):
	if !Global.can_act(ball) or ball.freezed:
		return
		
	if scrap_boost>0.0:
		var boost_amt = 15
		var extra_gain = min(boost_amt*delta,max(0,scrap_boost-boost_amt*delta))
		scrap_boost-=extra_gain
		meter_manager.gain_meter(extra_gain)
		
	meter_manager.gain_meter(7.5*delta) 
	
	if meter_manager.is_full():
		ability()
	
	return
	
	## UNUSED CODE WHICH ALLOWED US TO TOGGLE LAZER WALLS PERIODICALLY
	var wait=5.0
	if toggle!=true:
		wait=1.75
		
	if toggle_timer+sin(wave_pattern)*0.65>wait:
		lazer_toggle.emit(!toggle)
	else:
		lazer_toggle.emit(toggle)
		
	if toggle_timer>=wait:
		toggle=!toggle
		toggle_timer=0.0
		lazer_toggle.emit(toggle)
		
var wave_pattern=0.0
var toggle=true
var toggle_timer=0.0
var wall=preload("res://Balls/Fighters/Katie/electrowall.tscn")
signal lazer_toggle

## This is called when we add a turret, we call this with every turret
## So that they all connect
## We create a lazer wall, and hook it up
func electricity_wall(turret_a,turret_b):
	var new_wall=wall.instantiate()
	lazer_toggle.connect(new_wall.toggle)
	ball.get_parent().call_deferred("add_child",new_wall)
	new_wall.toggle(toggle)
	new_wall.call_deferred("set_wall",turret_a,turret_b)
	new_wall.attacker = ball
