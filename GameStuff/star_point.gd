extends Control

var chart_size: float=145

@export var grid_value :Vector2=Vector2(0,0)
@export var disable_rand_move:bool=true
@export var move_speed:float=20
@export var move_interval:float=0.1

var target_pos: Vector2 = Vector2.ZERO
var timer: float = -0.01
var target_value:Vector2

func _ready():
	target_value=grid_value
	position=Vector2(0,0)

func _process(delta):
	timer += delta

	if timer >= move_interval and !disable_rand_move:
		timer = 0.0
		pick_new_target()
	
	position = position.lerp(target_pos, move_speed * delta)
	
var last_dir: Vector2 = Vector2.ZERO
var min_distance := 0.5

func pick_new_target():
	var candidate: Vector2

	while true:
		var x = randf_range(-1.0, 1.0)
		#x = sign(x) * pow(abs(x), 0.3)

		var y = randf_range(-1.0, 1.0)
		#y = sign(y) * pow(abs(y), 0.3)

		if abs(x) + abs(y) > 1.0:
			continue

		candidate = Vector2(x, -y)

		if last_dir != Vector2.ZERO:
			if candidate.distance_to(last_dir) < min_distance:
				continue

			candidate = candidate.lerp(-last_dir, 0.5)

		break

	last_dir = candidate.normalized()
	target_pos = candidate * chart_size
	
func move_marker():
	var x = target_value.x
	var y = target_value.y
	x = clamp(x, -1.0, 1.0)
	y = clamp(y, -1.0, 1.0)
	disable_rand_move=true
	#var manhattan = abs(x) + abs(y)
	#if manhattan > 1.0:
		#x /= manhattan
		#y /= manhattan

	target_pos = Vector2(x, y) * chart_size
