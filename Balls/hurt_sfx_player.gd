

extends Node
@export var ball:BallBodyBase
func _ready():
	EventManager._successfully_damaged_.connect(hurt)


var decay_val=0

func hurt(data):
	if !EventManager.round_ongoing:
		return
	var victim = data["VICTIM"]
	
	if victim != ball:
		return
	var critted = data["CRIT"]
	var dmg = data["DAMAGE"]
	var sfx = data.get("SFX","res://Balls/hurt_sfx_player.gd")
	var type = data["TYPE"]
	
	var volume_mod=1.0
	var pitch_mod=1.0
	var negated_damage = data["NEGATED_DMG"]
	if negated_damage>0.0:
		volume_mod=0.65
		pitch_mod=0.7
	
	var calc_dmg = dmg
	
	if !critted:
		SoundQueue.play(sfx,pitch_mod+0.25*(randf()-0.5),volume_mod)
		
	
	ball.got_hit.emit()

func valid_type(type:Array):
	return type.has("STATUS_EFFECT") or type.has("PIERCING_DAMAGE")
