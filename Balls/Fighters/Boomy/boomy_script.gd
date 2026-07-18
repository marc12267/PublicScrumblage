## Boomy behaviour script
## Shows how to spawn minions as well as send data between them

extends BehaviourScript
@onready var meter_manager = $"../MeterManager"
@onready var gain_hurt: Node = $GainHurt

var countering=false

## Resource of entities
const BOOMYBOOMER = preload("uid://bgn5xccv5trxv")

func _ready():
	super()
	gain_hurt.gained.connect(spawn)

## Gain_hurt gives meter when taking damage
## Connecting the gained signal lets us check if our meter is every full from it
## To trigger a spawn. We use spawn_thing
## Check boomyboomer to see what boomer's code looks like
func spawn(value):
	if meter_manager.is_full():
		var new_thing = spawn_thing(BOOMYBOOMER)
		meter_manager.clear_meter()

## HitProcess is called whenever damage is dealt
## We filter it as being from our ball by getting the "ATTACKER" key
func hit_process(data):
	var attacker=data["ATTACKER"]
	if attacker==ball:
		## Get every entity in our spawn_list and transfer data to it
		for i in spawn_list:
			i.data_transfer.emit({
				"BOOM":true
			})
	
