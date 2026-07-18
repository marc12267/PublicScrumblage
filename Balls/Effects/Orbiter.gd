extends Node2D
@export var rotate_orbiters:bool=false
@export var orbit_radius: float = 80
@export var rotation_speed: float = 1.5
var things: Array[Node2D] = []
var angles: Array[float] = []
var angle_offset: float = 0.0

func add_orbit_thing(thing):
	add_child(thing)
	thing.tree_exiting.connect(remove_thing.bind(thing))
	things.append(thing)
	angles.append(0.0)
	update_angle_spacing()
	update_radius_spacing()

func remove_thing(thing):
	var idx = things.find(thing)
	if idx != -1:
		things.remove_at(idx)
		angles.remove_at(idx)

# Recomputes even angular distribution of things, then reapplies radius
func update_angle_spacing():
	var count = things.size()
	if count == 0:
		return
	for i in range(count):
		angles[i] = (TAU * i) / count

# Applies current orbit_radius using existing stored angles
func update_radius_spacing():
	var count = things.size()
	if count == 0:
		return
	for i in range(count):
		things[i].position = Vector2(cos(angles[i]), sin(angles[i])) * orbit_radius
	update_rotates()

func change_radius(val):
	orbit_radius = val
	update_radius_spacing()

func update_rotates():
	if rotate_orbiters:
		for thing in things:
			thing.rotation = thing.position.angle() + PI/2

func _process(delta):
	if HitstopManager.hitstopped:
		return
	rotation += rotation_speed * delta

func _ready() -> void:
	update_radius_spacing()
