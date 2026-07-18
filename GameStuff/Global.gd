## Contains utility functions and other doo dads

extends Node
## Default scaling value of hitting minions vs main enemies
const ALT_SCALE:float=0.25
## Default dodge duration
const DODGE_DURATION:float=0.7
## Center of map
var center :Vector2
## Team fight flag to enable team colors
var team_fight=false
var round_remaining:int=0
signal dodge_event
signal quake_trigger
signal credit_scroller
signal art_showcase

var game_mode:GAME_MODES = GAME_MODES.ONEVONE

var skin_mode = "Default"
enum GAME_MODES {ONEVONE,DUO,FFA}

var hitstop:float=0.15
var critstop:float=0.45

## Rotates a rotater to an angle over a duration
## Used to aimed shooting
func rotate_to(rotater:Rotater,target_angle: float, duration: float):
	var start_angle = rotater.rotation
	var tween = create_tween()
	tween.tween_method(
		func(t):
			if !is_instance_valid(rotater):
				return
			rotater.rotation = lerp_angle(start_angle, target_angle, t),
		0.0,
		1.0,
		duration
	)
	await tween.finished
	return
	
func get_random_position_in_arena(starting_position: Vector2) -> Vector2:
	var max_bounces: int = 5
	var path_segments: Array = _calculate_path(starting_position, Global.get_random_direction(), max_bounces)

	if not path_segments.is_empty():
		# Return a random point along the last calculated segment
		var last_segment_start: Vector2 = path_segments[-1][0]
		var last_segment_end: Vector2 = path_segments[-1][1]
		var random_factor: float = randf()
		return last_segment_start.lerp(last_segment_end, random_factor)
	else:
		# Fallback if no path could be calculated
		print("Warning: Path calculation failed, returning starting position.")
		return starting_position
		
func _calculate_path(start_point: Vector2, initial_direction: Vector2, max_bounces: int) -> Array:
	var path_segments: Array = []
	var current_position: Vector2 = start_point
	var current_direction: Vector2 = initial_direction.normalized()
	var world = get_viewport().world_2d
	var space = world.direct_space_state
	var ray_length: float = 1500.0
	for _i in range(max_bounces + 1):
		var ray_end: Vector2 = current_position + current_direction * ray_length
		var query := PhysicsRayQueryParameters2D.create(current_position, ray_end)
		query.collision_mask = (1 << 16) | (1 << 0)
		var result = space.intersect_ray(query)

		if result:
			var hit_point: Vector2 = result.position
			var normal: Vector2 = result.normal

			var towards_center = (Global.center - hit_point).normalized()
			var wall_bias_factor = abs(normal.dot(towards_center))
			var offset_strength = 12.0 * wall_bias_factor

			var biased_point = hit_point + towards_center * offset_strength
			if (biased_point - hit_point).dot(normal) < 0.0:
				biased_point = hit_point + normal * 4.0
			hit_point = biased_point
			path_segments.append([current_position, hit_point])
			current_direction = current_direction.bounce(normal).normalized()
			current_position = hit_point + current_direction * 0.5
		else:
			path_segments.append([current_position, current_position])
			break
	return path_segments


## Get closest ball aligned with a given direction from a global position
func closest_to_dir(_ball,dir,world_position,ignore_teammates=true):
	if get_tree()==null:
		return null
	dir = dir.normalized()
	var group = get_tree().get_nodes_in_group("Main").duplicate()
	group.erase(_ball)
	var best = null
	var best_dot = -INF
	for b:BallBodyBase in group:
		if !is_instance_valid(b):
			continue
		if b.is_in_group("Invisible") or b.is_in_group("Petrified") or b.enabled==false or b.reviving:
			continue
		if ignore_teammates and b.team == _ball.team:
			continue
		var to_ball = b.global_position - world_position
		if to_ball.length_squared() == 0:
			continue
		var d = to_ball.normalized().dot(dir)
		if d > best_dot:
			best_dot = d
			best = b
	return best

## Check if a ball can act/trigger it's behaviour
## Not used currently since disables stop running behaviour for me
func can_act(ball:BallBodyBase):
	if !is_instance_valid(ball):
		return false
	return ball.enabled

## Get direction to closest ball
func dir_closest_ball(ball,default_val =Vector2.ZERO):
	if get_tree()==null:
		return default_val
	var group = get_tree().get_nodes_in_group("Main").duplicate()
	group.erase(ball)

	if group.is_empty():
		return default_val
	var closest = null
	var closest_dist = INF

	for b:BallBodyBase in group:
		if b.team == ball.team or b.is_in_group("Invisible")or b.is_in_group("Petrified") or b.enabled==false or b.reviving:
			continue

		var d = ball.global_position.distance_to(b.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = b

	if closest == null:
		return default_val

	var future_pos = closest.global_position

	return ball.global_position.direction_to(future_pos)

## Get closest ball to ball
func closest_ball(ball):
	if get_tree()==null:
		return null
	var group = get_tree().get_nodes_in_group("Main").duplicate()
	group.erase(ball)

	if group.is_empty():
		return null
	var closest = null
	var closest_dist = INF

	for b:BallBodyBase in group:
		if b.team == ball.team or b.is_in_group("Invisible")or b.is_in_group("Petrified") or b.enabled==false or b.reviving:
			continue

		var d = ball.global_position.distance_to(b.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = b
	return closest

func unsorted_closest(ball,ignore_teammates=true):
	if get_tree()==null:
		return null
	var group = get_tree().get_nodes_in_group("Main").duplicate()
	group.erase(ball)

	if group.is_empty():
		return null
	var closest = null
	var closest_dist = INF

	for b:BallBodyBase in group:
		if ignore_teammates:
			if b.team == ball.team:
				continue
		var d = ball.global_position.distance_to(b.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = b
	return closest

func array_unique(array: Array) -> Array:
	var unique: Array = []

	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func get_random_direction() -> Vector2:
	var dir = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)
	return dir.normalized()
