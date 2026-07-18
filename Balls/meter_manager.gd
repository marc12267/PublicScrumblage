## Manages meter
## Mostly used for tracking fighter's meter
## But can also use for general cooldowns

extends Node
class_name MeterManager
var max_meter=100
@export var meter=0

## These signals are called when meter changes, is empty, and is full
## Connect to em for functionality
signal meter_change
signal meter_empty
signal meter_full
var meter_disabled=false

func _ready():
	EventManager.round_end.connect(disable_meter)

func disable_meter():
	meter_disabled=true

func gain_meter(val):
	if meter_disabled:
		return
	set_meter(meter+val)

func is_full():
	return meter>=max_meter

func scale_value():
	return meter/max_meter


func is_empty():
	return meter==0.0

func set_meter(val):
	if meter_disabled:
		return
	meter=max(min(val,max_meter),0)
	meter_change.emit(meter)
	
	if meter==0.0:
		meter_empty.emit()
	elif meter>=max_meter:
		meter_full.emit()

func clear_meter():
	if meter_disabled:
		return
	set_meter(0.0)

func lose_meter(val):
	if meter_disabled:
		return
	set_meter(meter-val)
	
