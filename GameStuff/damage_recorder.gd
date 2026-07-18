extends Node

@export var enabled:bool=false
var data:Dictionary = {}


func _ready() -> void:
	if enabled:
		EventManager.won.connect(output_data)
		EventManager.attribute_damage.connect(register_damage)

func register_damage(_data):
	if !enabled:
		return
	var attacker=_data["ATTACKER"]
	var victim = _data["VICTIM"]
	var dmg = _data["DAMAGE"]
	if !attacker:
		return
	if victim.is_in_group("AntiInteract"):
		return
	if attacker.team==victim.team:
		return
		
	data[attacker.name+" -> "+victim.name] = dmg

func output_data():
	for i in data.keys():
		print(str(i) + " : " + str(data[i]) + "dmg")
	data.clear()
