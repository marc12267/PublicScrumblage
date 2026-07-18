## This is script of boomer node

extends BehaviourScript
const EXPLOSION = preload("uid://du07hj18sqtx7")

## This script is updated when data is transfered to ball
func _ready():
	super()
	ball.data_transfer.connect(boom)

## We check if it has BOOM flag boomy would send, then spawn an explosion
func boom(data):
	if data.get("BOOM",false):
		
		spawn_thing(EXPLOSION,true,false)
		##EMIT DAMAGE SIGNAL THAT HURTS THEMSELVES WHEN EXPLODING
		var data_dict={"DAMAGE":5,
			"VICTIM":ball,
			"TYPE":["SELF_DAMAGE"],
			"HITSTOP_SCALE":0.0,
			"MUTE":true}
		EventManager.hit.emit(data_dict)
		
