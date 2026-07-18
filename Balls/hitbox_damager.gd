## Hitbox damager actually emits the damage data on succesful contact

extends Node
class_name HitboxDamager
@onready var hitbox:Hitbox = get_parent()
@export var ball:BallBodyBase

## Unique specific id for coded interactions
@export var id:String = ""
## Damage value
@export var damage:float=4

## Direction of knockback logic
## DIRECTION BASED is direction to center of hitbox
## VELOCITY BASED is based off velocity of ball's direction
@export_enum("DIRECTION_BASED","VELOCITY_BASED") var knockback_logic = "DIRECTION_BASED"

## Knockback strength forced away from direction
@export var knockback:float=100

## How strong the knockback sends to direction
## By default use 1, if a hit is weak/chippy use lower value
@export_range(0,1) var directional_strength:float = 1.0

## Knocks ball away from target
@export var self_knockback:float=75

## Chance of critting
@export var crit_chance:float=0.065

## If critting, how much damage do we do
@export var crit_multiplier:float=2.0

## If -1 use default hitstop
## Else we can override
## Use for small hits from minions that dont matter as much
@export_range(0,1) var hitstop_scale:float=1.0

## SFX to override
@export var hurt_sfx:String="res://Sounds/hurt_sfx.wav"

## Mute damage numbers 
@export var mute_numbers:bool=false
var stat_controller:StatController

@export var sync_stats:bool=true
@export var stat_name:String="HitboxDamager"
signal hit
signal local_hit

@export_category("Extra")
@export var attacker_export:BallBodyBase=null
@export var dont_emit:bool=false

func _ready():
	hitbox.hit_ball.connect(direct_hit)
	if ball!=null and sync_stats:
		stat_controller=ball.stat_controller
		stat_controller.stat_changed.connect(update_stats)
		stat_controller.set_base_stat(stat_name+".damage",damage)
		stat_controller.add_alias("HitboxDamager.damage", "HitboxDamager.damage")
		
		stat_controller.set_base_stat(stat_name+".knockback",knockback)
		stat_controller.add_alias("HitboxDamager.knockback", "HitboxDamager.knockback")
		
		stat_controller.set_base_stat(stat_name+".self_knockback",self_knockback)
		stat_controller.add_alias("HitboxDamager.self_knockback", "HitboxDamager.self_knockback")
		
		stat_controller.set_base_stat(stat_name+".crit_chance",crit_chance)
		stat_controller.add_alias("HitboxDamager.crit_chance", "HitboxDamager.crit_chance")
		
		stat_controller.set_base_stat(stat_name+".crit_multiplier",crit_multiplier)
		stat_controller.add_alias("HitboxDamager.crit_multiplier", "HitboxDamager.crit_multiplier")
		
		stat_controller.set_base_stat(stat_name+".hitstop_scale",hitstop_scale)
		stat_controller.add_alias("HitboxDamager.hitstop_scale", "HitboxDamager.hitstop_scale")

func update_stats(stat_id,new_val):
	if !sync_stats:
		return
	if stat_id==stat_name+".damage":
		damage=new_val
	elif stat_id==stat_name+".knockback":
		knockback=new_val
	elif stat_id==stat_name+".self_knockback":
		self_knockback=new_val
	elif stat_id==stat_name+".crit_chance":
		crit_chance=new_val
	elif stat_id==stat_name+".crit_multiplier":
		crit_multiplier=new_val
	elif stat_id==stat_name+".hitstop_scale":
		hitstop_scale=new_val

## This function is called when hitting
func direct_hit(body:BallBodyBase):
	if body==null:
		return
	if body.team==ball.team:
		return
	var dir 
	if knockback_logic=="DIRECTION_BASED":
		dir = (ball.global_position.direction_to(body.global_position)).normalized()
	elif knockback_logic=="VELOCITY_BASED":
		dir = ball.get_velocity().normalized()
	var dealt_damage=damage
	var attacker = ball
	if attacker_export!=null:
		attacker=attacker_export
		
	var data_dict={"DAMAGE":dealt_damage,
		"ATTACKER":attacker,
		"VICTIM":body,
		"KNOCKBACK":knockback,
		"DIRECTION":dir,
		"DIR_STRENGTH":directional_strength,
		"SELF_KNOCKBACK":self_knockback,
		"CRIT_CHANCE":crit_chance,
		"CRIT_MULTIPLIER":crit_multiplier,
		"TYPE":hitbox.type,
		"ID":id,
		"SFX":hurt_sfx,
		"MUTE":mute_numbers}
	if hitstop_scale !=-1:
		data_dict["HITSTOP_SCALE"]=hitstop_scale
	if !dont_emit:
		EventManager.hit.emit(data_dict)
	
	local_hit.emit(data_dict)
	
	hit.emit()
	
