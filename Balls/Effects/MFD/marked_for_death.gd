extends StatusEffect
@onready var orbit_effect = $OrbitEffect

var target:BallBodyBase


var icon = preload("res://Balls/Effects/MFD/skull_anti_rot.tscn")

func set_target(ball,value,data):
	target=ball
	counter+=value
	orbit_effect.visible=true
	add_skulls(value)

func update(value,data):
	counter+=value
	add_skulls(value)
	return self
func add_skulls(value):
	for i in range(value):
		orbit_effect.add_orbit_thing(icon.instantiate())


func _process(delta):
	if target==null:
		return
	orbit_effect.global_position=target.global_position
