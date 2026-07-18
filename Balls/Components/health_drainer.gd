##Will decrease health component health over time

extends Node
@export var active:bool=true
@export var drain_per_second:float=1

var drain_counter:float=0.0
@onready var health_manager = get_parent()

func _physics_process(delta):
	if HitstopManager.hitstopped or !active or !EventManager.round_ongoing:
		return
	drain_counter+=delta
	if drain_counter>(1.0/drain_per_second):
		health_manager.decrease_health(1)
		drain_counter=0.0
