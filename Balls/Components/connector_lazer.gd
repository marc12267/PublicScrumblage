## Creates lazer beam between 2 points

extends ShapeCast2D
## Base node where lazer starts
## This is repurposed from katie's turret lazers so you may
## need to make your own for what you need
var ball:BallBodyBase

## Ending node where lazer ends
var ball_2:BallBodyBase
var active=false

## Attacker to attribute to lazer
@export var attacker:BallBodyBase

## Id to give to damage
@export var damage_id:String = ""

## Visual effect of lazer
@export var line_2d :Line2D
var ignore_tick:Dictionary={}

## Damage dealt per tick
@export var damage:float=1

## Wait time before trigger damage tick
@export var tick_wait:float=0.1

## SFX when damaging
@export var hurt_sfx:String="res://Sounds/hurt_sfx.wav"

@export_range(0,1) var hitstop_scale:float=0.1
@export var knockback:float=100

## How much knockback is towards dir
@export_range(0,1) var directional_strength:float = 1.0

## Knock away or towards the bell base
@export var dir_modifier:int=1

## Flag to make knockback perpendicular to lazer instead of away/towards it
@export var knockaway : bool = false

@export var anti_dodge:bool=false
## Emits thing we detected, regardless of team
signal detected

## Turn lazer on and off
func toggle(truefalse):
	line_2d.visible=truefalse
	active=truefalse
	
func set_lazer_width(val):
	line_2d.width=val
	shape.radius = val/2.0

## Set our wall between 2 ball objects
func set_wall(ball1,ball2):
	ball=ball1
	ball_2=ball2
	wall_setted=true

## Once we have setted we enable flag for behaviour
var wall_setted=false
	
func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	if !wall_setted:
		visible=false
		return
	if !is_instance_valid(ball) or !is_instance_valid(ball_2):
		toggle(false)
		queue_free()
		return
	if !active:
		visible=false
		return
	visible=true
	
	for i in ignore_tick.keys():
		ignore_tick[i]=ignore_tick[i]-delta
		if ignore_tick[i]<=0:
			ignore_tick.erase(i)

	force_shapecast_update()
	for i in range(get_collision_count()):
		if ignore_tick.get(get_collider(i),0.0)>0.0:
			continue
		if !anti_dodge:
			if get_collider(i).dodges(ball):
				ignore_tick[get_collider(i)]=Global.DODGE_DURATION
				continue
		ignore_tick[get_collider(i)]=tick_wait
		tick_to_damage(get_collider(i))
	
	var p1 = ball.global_position 
	var p2 = ball_2.global_position 
	
	line_2d.clear_points()
	line_2d.add_point(p1)
	line_2d.add_point(p2)
	
	global_position= p1
	target_position=to_local(p2)

func tick_to_damage(body):
	if body==ball:
		return
	if !is_instance_valid(ball) or !is_instance_valid(ball_2):
		return
	
	
	if body is Hurtbox:
		if body.active==false:
			return
		body = body.ball
	
	if body is BallBodyBase:
		
		var dir = dir_modifier * ball.global_position.direction_to(ball_2.global_position)
		if knockaway:
			dir =get_knockback_dir(ball.global_position,ball_2.global_position,body.global_position)
	
		if body.team==ball.team:
			detected.emit(body)
			return
		var atker = attacker
		if attacker==null:
			atker = ball
		var data_dict={"DAMAGE":damage,
			"ATTACKER":atker,
			"VICTIM":body,
			"HITSTOP_SCALE":hitstop_scale,
			"TYPE":["LAZER"],
			"ID":damage_id,
			"KNOCKBACK":knockback,
			"DIR_STRENGTH":directional_strength,
			"DIRECTION":dir,
			"SFX":hurt_sfx
			}
		
		EventManager.hit.emit(data_dict)


func get_knockback_dir(point_a:Vector2, point_b:Vector2, obj_pos:Vector2):
	## Laser direction from point_a and point_b
	var laser_vec = point_b - point_a
	
	## T is projection for the direction onto the line
	var t = (obj_pos - point_a).dot(laser_vec) / laser_vec.length_squared()
	t = clamp(t, 0.0, 1.0)

	## Closest point on segment
	var closest = point_a + laser_vec * t

	## Direction away from lasers
	var knock_dir = (obj_pos - closest).normalized()

	return knock_dir
