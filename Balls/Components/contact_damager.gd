## Script to deal  contact damage

extends Node
@export var enabled=true
@export var ball:BallBodyBase
## How long to wait before retriggering damage
## Set low since physics based collisions should ideally damage every bounce
@export var tick_wait:float=0.1

@export var stat_name: String = "ContactDamager"

@export_category("Damage Data")
@export var id:String = ""
@export var contact_damage:float=1
@export var knockback:float=1.0
@export var self_knockback:float=1.0
@export var crit_chance:float=0.0
@export var crit_multiplier:float=2.0
@export_range(0,1) var hitstop_scale:float=1.0


@export var hurt_sfx:String="res://Sounds/hurt_sfx.wav"
var ignore_list=[]
var ignore_tick={}

@export_category("Extra")
## In case our attacker isn't the direct ball parent
@export var attacker_export:BallBodyBase=null
## Calculate as normal, but don't emit the damage signal publicly
@export var dont_emit:bool=false

@export var anti_dodge:bool=false
signal local_hit


var stat_controller:StatController

## Connect to ball's bounces to deal damage
func _enter_tree():
	ball.bounce_ball.connect(direct_hit)

func _ready():
	stat_controller=ball.stat_controller
	stat_controller.stat_changed.connect(update_stats)
	stat_controller.set_base_stat(stat_name+".enabled",enabled)
	stat_controller.add_alias(stat_name+".enabled", "ContactDamager.enabled")
	
	stat_controller.set_base_stat(stat_name+".contact_damage",contact_damage)
	stat_controller.add_alias(stat_name+".contact_damage", "ContactDamager.contact_damage")
	
	stat_controller.set_base_stat(stat_name+".knockback",knockback)
	stat_controller.add_alias(stat_name+".knockback", "ContactDamager.knockback")
	
	stat_controller.set_base_stat(stat_name+".self_knockback",self_knockback)
	stat_controller.add_alias(stat_name+".self_knockback", "ContactDamager.self_knockback")
	
	stat_controller.set_base_stat(stat_name+".crit_chance",crit_chance)
	stat_controller.add_alias(stat_name+".crit_chance", "ContactDamager.crit_chance")
	
	stat_controller.set_base_stat(stat_name+".crit_multiplier",crit_multiplier)
	stat_controller.add_alias(stat_name+".crit_multiplier", "ContactDamager.crit_multiplier")
	
	stat_controller.set_base_stat(stat_name+".hitstop_scale",hitstop_scale)
	stat_controller.add_alias(stat_name+".hitstop_scale", "ContactDamager.hitstop_scale")
	
	
func update_stats(_stat_name,new_val):
	if stat_name+".enabled" == _stat_name:
		enabled=new_val
	elif stat_name+".contact_damage" == _stat_name:
		contact_damage=new_val
	elif stat_name+".knockback" == _stat_name:
		knockback=new_val
	elif stat_name+".self_knockback" == _stat_name:
		self_knockback=new_val
	elif stat_name+".crit_chance" == _stat_name:
		crit_chance=new_val
	elif stat_name+".crit_multiplier" == _stat_name:
		crit_multiplier=new_val
	elif stat_name+".hitstop_scale" == _stat_name:
		hitstop_scale=new_val
			
func direct_hit(body:BallBodyBase):
	if body.team==ball.team:
		return
	if ignore_list.has(body) or !enabled or ignore_tick.get(body,0.0)>0.0:
		return
	if !anti_dodge:
		if body.dodges(ball):
			ignore_tick[body]=0.01
			return
	ignore_tick[body]=tick_wait
	var dir = (ball.global_position.direction_to(body.global_position)).normalized()
	var dealt_damage=contact_damage
	var attacker = ball
	if attacker_export!=null:
		attacker=attacker_export
	var data_dict={"DAMAGE":dealt_damage,
		"ATTACKER":attacker,
		"VICTIM":body,
		"KNOCKBACK":knockback,
		"DIRECTION":dir,
		"SELF_KNOCKBACK":self_knockback,
		"CRIT_CHANCE":crit_chance,
		"CRIT_MULTIPLIER":crit_multiplier,
		"TYPE":["CONTACT"],
		"SFX":hurt_sfx,
		"ID":id}
	if hitstop_scale !=-1:
		data_dict["HITSTOP_SCALE"]=hitstop_scale
	await get_tree().physics_frame
	if !dont_emit:
		EventManager.hit.emit(data_dict)
	
	local_hit.emit(data_dict)
	

func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	for i in ignore_tick.keys():
		ignore_tick[i]=ignore_tick[i]-delta
		if ignore_tick[i]<=0:
			ignore_tick.erase(i)
			
