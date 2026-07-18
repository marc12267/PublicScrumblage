## Use for lazerbeam which shoots out in a certain direction
extends Line2D
## Is lazer active
@export var lazer_active: bool = false
## How far lazers can go
@export var max_length: float = 9999
@export var ball: BallBodyBase
@export var id: String
@export var damage: float = 1
@export var knockback: float = 1
@export var lazer_width: float = 10

## Chance of critting
@export var crit_chance:float=0.0

## If critting, how much damage do we do
@export var crit_multiplier:float=2.0
## Time must pass before you can take damage from lazer
## After getting hit
@export var tick_wait: float = 0.075
@export_range(0,1) var directional_strength:float = 1.0
## Knock away or along the beam
@export var dir_modifier: int = 1
@export_range(0,1) var hitstop_scale:float=0.1
@export var hurt_sfx: String = "res://Sounds/hurt_sfx.wav"
## How many times the laser bounces off walls (0 = no bouncing)
@export var max_bounces: int = 0

@export var mute_numbers:bool=false

@export var anti_dodge:bool=false
var ignore_tick: Dictionary = {}

## Each segment stored as {start, dir, distance}
var _segments: Array = []

signal detected
signal bounce_point

func _ready() -> void:
	EventManager.status_effected.connect(status_check)


func status_check(data):
	var victim = data["VICTIM"]
	var strength = data["STRENGTH"]
	if victim==ball:
		if strength != -1:
			if ball.behaviour_script.behaviour_active==false:
				visible=false
		else:
			
			if ball.behaviour_script.behaviour_active==true:
				visible=lazer_active

func update_laser() -> void:
	clear_points()
	width = lazer_width
	_segments.clear()

	var space := ball.get_world_2d().direct_space_state
	var start := global_position
	var dir := Vector2.RIGHT.rotated(global_rotation).normalized()
	var remaining_length := max_length
	
	add_point(to_local(start))

	for _bounce in range(max_bounces + 1):
		var query := PhysicsRayQueryParameters2D.create(start, start + dir * remaining_length)
		query.exclude = [ball]
		query.collision_mask = 1 | (1 << 16)

		var result := space.intersect_ray(query)
		var end_point: Vector2
		var hit_wall := false

		if result:
			end_point = result.position
			hit_wall = true
		else:
			end_point = start + dir * remaining_length

		var seg_distance := start.distance_to(end_point)
		_segments.append({ "start": start, "dir": dir, "distance": seg_distance })
		add_point(to_local(end_point))
		
		bounce_point.emit(end_point)
		if not hit_wall or _bounce == max_bounces:
			break

		dir = dir.bounce(result.normal).normalized()
		remaining_length -= seg_distance
		start = end_point + dir * 0.5

func _process(delta: float) -> void:
	if HitstopManager.hitstopped:
		return
	visible = lazer_active
	if ball.behaviour_script!=null:
		visible=ball.behaviour_script.behaviour_active and lazer_active
	if visible:
		update_laser()
		lazer_process()

	for i in ignore_tick.keys():
		ignore_tick[i] -= delta
		if ignore_tick[i] <= 0:
			ignore_tick.erase(i)

## Sweeps each segment for entity hits
func lazer_process() -> void:
	var space := ball.get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = lazer_width

	for seg in _segments:
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0, seg["start"])
		query.motion = seg["dir"] * seg["distance"]
		query.exclude = [ball]
		query.collision_mask = 1 << 6

		var results := space.intersect_shape(query)

		for result in results:
			var body = result
			if body is Hurtbox:
				if body.active==false:
					continue
				body=body.ball
			else:
				body = result.collider
		
			
			detected.emit(body)
			if ignore_tick.get(body, 0.0) > 0.0:
				continue
			if !anti_dodge:
				if body.dodges(ball):
					ignore_tick[body] = max(Global.DODGE_DURATION, ignore_tick.get(body, 0.0))
					continue

			ignore_tick[body] = max(tick_wait, ignore_tick.get(body, 0.0))
			lazer_hit(body, seg["dir"])

## dir is now passed per-segment so knockback follows the bounce direction
func lazer_hit(body, seg_dir: Vector2) -> void:
	if body is BallBodyBase and body != ball:
		if body.team == ball.team:
			return
			
		var dir := seg_dir * dir_modifier
		
		var data_dict := {
			"ATTACKER":ball,
			"VICTIM":body,
			"KNOCKBACK":knockback,
			"DAMAGE":damage,
			"DIRECTION":dir,
			"DIR_STRENGTH":directional_strength,
			"CRIT_CHANCE":crit_chance,
			"CRIT_MULTIPLIER":crit_multiplier,
			"TYPE":["LAZER"],
			"HITSTOP_SCALE":hitstop_scale,
			"ID":id,
			"SFX":hurt_sfx,
			"MUTE":mute_numbers
		}

		EventManager.hit.emit(data_dict)
