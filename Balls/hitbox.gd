## Used for hitbox detecting to deal damage
## Mostly used for weapon hitboxes, but can also use to apply aoe damage

extends Area2D
class_name Hitbox
signal hit_weapon
signal hit_ball
signal hit_projectile
signal hit_hitbox_emit
signal hit_ball_emit

## Put things to ignore in here
var ignore_list=[]

## Used to ignore something briefly after hitting something
var ignore_tick={}

@export var ball:BallBodyBase
var stat_controller:StatController

@export var active:bool=true
## Minimum length of time to wait before a hitbox can hit something again
@export var tick_wait:float=0.3

## Weapon damage type
## WEAPON PROJECTILE
## like ball tagging, can include anything for specific interactions
@export var type:Array = ["WEAPON"]

@export var anti_dodge:bool=false

## List of collision objects for dissabling stuff
var collision_list = []
@export var sync_stats:bool=true
@export var stat_name:String="Hitbox"


## Collects our hitboxes and sets base stats
func _enter_tree():
	for i in get_children():
		if i is CollisionShape2D or i is CollisionPolygon2D:
			collision_list.append(i)
	if ball!=null:
		ignore_list.append(ball)
	if sync_stats:
		stat_controller=ball.stat_controller
		stat_controller.stat_changed.connect(update_stats)
		stat_controller.set_base_stat(stat_name+".monitoring",monitoring)
		stat_controller.add_alias(stat_name+".monitoring", "Hitbox.monitoring")
		
		stat_controller.set_base_stat(stat_name+".monitorable",monitorable)
		stat_controller.add_alias(stat_name+".monitorable", "Hitbox.monitorable")

		stat_controller.set_base_stat(stat_name+".tick_wait",tick_wait)
		stat_controller.add_alias(stat_name+".tick_wait", "Hitbox.tick_wait")
		
		stat_controller.set_base_stat(stat_name+".active",active)
		stat_controller.add_alias(stat_name+".active", "Hitbox.active")
		
		if collision_list.size()>0:
			stat_controller.set_base_stat(stat_name+".collision_disabled",collision_list[0].disabled)
			stat_controller.add_alias(stat_name+".collision_disabled", "Hitbox.collision_disabled")
			
			stat_controller.set_base_stat(stat_name+".collision_scale",collision_list[0].scale)
			stat_controller.add_alias(stat_name+".collision_scale", "Hitbox.collision_scale")
	
func update_stats(stat_id,new_val):
	if !sync_stats:
		return
	if stat_id == stat_name+".active":
		active=new_val
	elif stat_id == stat_name+".tick_wait":
		tick_wait=new_val
	elif stat_id == stat_name+".monitoring":
		set_deferred("monitoring",new_val)
	elif stat_id == stat_name+".monitorable":
		set_deferred("monitorable",new_val)
	elif stat_id == stat_name+".collision_disabled":
		for collision in collision_list:
			collision.set_deferred("disabled",new_val)
	elif stat_id == stat_name+".collision_scale":
		for collision in collision_list:
			collision.set_deferred("scale",new_val)

## Detects stuff automatically while active
## Detected things are tracked so we have to wait ticks before hitting
func _physics_process(delta):
	if HitstopManager.hitstopped:
		return
	
	if active==true:
		detect_tick()
		
	for i in ignore_tick.keys():
		ignore_tick[i]=ignore_tick[i]-delta
		if ignore_tick[i]<=0:
			ignore_tick.erase(i)


func area_check(area):
	if ignore_tick.keys().has(area) :
		return
	if ignore_list.has(area):
		return
	if area is Hitbox:
		if area.active==false:
			return
		ignore_tick[area]=tick_wait
		hit_weapon.emit(area)
		hit_hitbox_emit.emit(area)
		
	if area is Hurtbox:
		if area.active==false:
			return
		body_check(area.ball)


func body_check(body):
	if body is BallBodyBase and body!=ball:
		if ignore_tick.keys().has(body) or ignore_list.has(body):
			return
		
		if !anti_dodge:
			if body.dodges(ball):
				ignore_tick[body]=Global.DODGE_DURATION
				return
		ignore_tick[body]=tick_wait
		
		hit_ball.emit(body)
		hit_ball_emit.emit()
		return true
	return false

func _on_body_exited(body):
	return
	
func _on_area_entered(area):
	if HitstopManager.hitstopped:
		return
	if !active:
		return
	area_check(area)

func _on_body_entered(body):
	if HitstopManager.hitstopped:
		return
	if !active:
		return
	body_check(body)

## Function to to check for things and deal damage to things
## Used in process function, but you can MANUALLY call this
## Even if hitbox isnt active!
func detect_tick():
	for i in get_overlapping_areas():
		area_check(i)
	
	for i in get_overlapping_bodies():
		body_check(i)
