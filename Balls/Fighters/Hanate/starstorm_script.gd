extends BehaviourScript

@onready var danger_zone = $"../ExplosionRadius"
@onready var hit_gain: Node = $HitGain

signal connected
var fb_dmg=2
var meter_gain :float = 6.5
func _ready():
	super()
	attack()
	
	if ball.skin == "Summer":
		$"../Boom2/Sprite2D".modulate = Color(4.165, 0.965, 3.205, 0.337)
		%Burst.color_ramp = load("uid://bitdp1by4ok33")
		$"../AreaCircle".color = Color("f24cff28")
		$"../AreaDotted".color = Color("ffdbeeff")
		#%Spread.color_ramp = load("uid://db0m786gdvcjb")

func hit_process(data:Dictionary):
	var attacker = data["ATTACKER"]
	var victim = data["VICTIM"]
	var dmg = data["DAMAGE"]
	var type = data["TYPE"]
	
	if victim.is_in_group("AntiInteract"):
		return
	if attacker == ball:
		
		if !creator_script.maxed:
			StatusEffectManager.set_effect(ball.get_root_creator(),victim,"STUNNED",0.3,{"SFXMUTE":true})
		else:
			StatusEffectManager.set_effect(ball.get_root_creator(),victim,"STUNNED",0.6,{"SFXMUTE":true})

		
func attack():
	var rand_trail = str(randi_range(1,2))
	SoundQueue.play("res://Balls/Fighters/Hanate/Sounds/starstorm_trail_" + rand_trail + ".wav", 1.0, 0.45)
	$"../AreaCircle".emitting = true
	$"../AreaDotted".emitting = true
	
	await delay(0.7)
	var rand_explode = str(randi_range(1,4))
	SoundQueue.play("res://Balls/Fighters/Hanate/Sounds/starstorm_explode_" + rand_explode + ".wav", 1.0, 0.45)
	SoundQueue.play("res://Balls/Fighters/Hanate/Sounds/starstorm_land.wav", 1.3, 0.3)
	Global.quake_trigger.emit(0.8)
	
	$"../AreaCircle".visible = false
	$"../AreaDotted".visible = false
	
	check()
	
	await delay(1)
	
	ball.queue_free()

func check():
	var bodies = danger_zone.get_overlapping_bodies()
	bodies.erase(ball)
		#await get_tree().process_frame
	
	$"../Boom2".global_position=ball.global_position
	$"../Boom2/AnimationPlayer".play("Boom")
	%Burst.emitting = true
	
	for i in bodies:
		if !i is BallBodyBase:
			continue
		if i.team==ball.team:
			continue
		damage(i)
	return

func damage(victim):
	var dir = ball.global_position.direction_to(victim.global_position)
	
	var data_dict={"DAMAGE": 3,
				"ATTACKER":ball,
				"VICTIM":victim,
				"KNOCKBACK":60,
				"DIRECTION":dir,
				"CRIT_CHANCE":0.0,
				"CRIT_MULTIPLIER":1,
				"TYPE":["EXPLOSION"],
				"SFX":"",
				"ID":"STARSTORM",
				"HITSTOP_SCALE":0.8,
				"MISC":{}}
	EventManager.hit.emit(data_dict)
