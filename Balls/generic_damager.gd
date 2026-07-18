extends Node
@export var dmg:float=1
@export var attacker:BallBodyBase
@export var victim:BallBodyBase
@export var knockback:float=0
@export var dir:Vector2
@export var directional_strength:float=0.0
@export var self_knockback:float=0.0
@export var crit_multiplier:float=0.0
@export var crit_chance:float=0.0
@export var type:Array
@export var id:String
@export var hurt_sfx:String
@export var mute_numbers:bool=false
@export var hitstop_scale:float=1.0

func damage():
	var data_dict={"DAMAGE":dmg,
			"ATTACKER":attacker,
			"VICTIM":victim,
			"KNOCKBACK":knockback,
			"DIRECTION":dir,
			"DIR_STRENGTH":directional_strength,
			"SELF_KNOCKBACK":self_knockback,
			"CRIT_CHANCE":crit_chance,
			"CRIT_MULTIPLIER":crit_multiplier,
			"TYPE":type,
			"ID":id,
			"SFX":hurt_sfx,
			"MUTE":mute_numbers}
	if hitstop_scale !=-1:
		data_dict["HITSTOP_SCALE"]=hitstop_scale
	EventManager.hit.emit(data_dict)
		
