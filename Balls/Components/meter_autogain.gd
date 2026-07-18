## Gaining meter when dealing damage

extends Node
@onready var behaviour_script:BehaviourScript=get_parent()
@export var meter_manager:MeterManager
@export var enabled:bool=true
@export var gain_rate:float = 1

signal meter_full

func _physics_process(delta: float) -> void:
	if HitstopManager.hitstopped or !enabled:
		return
	if gain_rate<0.0:
		meter_manager.lose_meter(abs(gain_rate))
	else:
		meter_manager.gain_meter(gain_rate*delta)
		if meter_manager.meter>=meter_manager.max_meter:
			meter_full.emit()
