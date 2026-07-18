extends MarginContainer
@export var bstat:BStatDisplay
var damage:float=0
func _ready() -> void:
	EventManager.attribute_damage.connect(register_damage)
	%Label.text=str(damage)
	await get_tree().process_frame
	visible= Global.team_fight
	
func register_damage(_data):
	if bstat.ball==null:
		return
	var attacker=_data["ATTACKER"]
	var victim = _data["VICTIM"]
	var dmg = _data["DAMAGE"]
	if !attacker:
		return
	if !attacker==bstat.ball:
		return
	if victim.is_in_group("AntiInteract"):
		return
	if attacker.team==victim.team:
		
		return
	damage+=dmg
	if damage<100:
		%Label.text=str(round(damage*10.0)/10.0)
	else:
		%Label.text=str(round(damage))
		
