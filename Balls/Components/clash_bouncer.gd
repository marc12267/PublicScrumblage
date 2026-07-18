## Component node that controls behaviours like flipping
## Must be parent of children
extends Node
class_name ClashBouncer
@onready var hitbox:Hitbox = get_parent()

@export var ball:BallBodyBase
@export var disable=false

## Cleave makes hitbox not flip from hitting directly
@export var cleave=false

## This makes weapon ignore clashes (doesnt deflect)
## Use sparingly
@export var ignore_clash=false 

## Other weapons will not clash with this by default
@export var ignorable=false 

## Use when we want to deflect projectiles
@export var projectile_deflecter = false

@export var sync_stats:bool=true
@export var stat_name:String="ClashBouncer"

var stat_controller:StatController

## Emitted when rotater should flip
signal flip

## Emits when clash happens
signal clash

## Emits when deflection occurs
signal deflected

func _ready():
	hitbox.hit_weapon.connect(clash_bounce)
	hitbox.hit_ball.connect(ball_hit)
	if ball!=null:
			
		if sync_stats:
			stat_controller=ball.stat_controller
			stat_controller.stat_changed.connect(update_stats)
			
			stat_controller.set_base_stat(stat_name+".disable",disable)
			stat_controller.add_alias("ClashBouncer.disable", "ClashBouncer.disable")
			
			stat_controller.set_base_stat(stat_name + ".cleave", cleave)
			stat_controller.add_alias("ClashBouncer.cleave", "ClashBouncer.cleave")
			
			stat_controller.set_base_stat(stat_name+".ignorable",ignorable)
			stat_controller.add_alias("ClashBouncer.ignorable", "ClashBouncer.ignorable")
			
			stat_controller.set_base_stat(stat_name+".ignore_clash",ignore_clash)
			stat_controller.add_alias("ClashBouncer.ignore_clash", "ClashBouncer.ignore_clash")
			
			stat_controller.set_base_stat(stat_name+".projectile_deflecter",projectile_deflecter)
			stat_controller.add_alias("ClashBouncer.projectile_deflecter", "ClashBouncer.projectile_deflecter")
		
func update_stats(stat,new_val):
	if !sync_stats:
		return
	if stat_name+".disable"==stat:
		disable=new_val
	elif stat_name+".ignore_clash"==stat:
		ignore_clash=new_val
	elif stat_name+".ignorable"==stat:
		hitbox.set_collision_layer_value(6,!new_val)
	elif stat_name+".projectile_deflecter"==stat:
		projectile_deflecter=new_val
		hitbox.set_collision_mask_value(3,new_val)
	
	elif stat == stat_name + ".cleave":
		cleave = new_val

## Called when weapon hitbox clashes with stuff
func clash_bounce(weapon_hitbox:Hitbox):
	if disable:
		return
	var enemy_ball = weapon_hitbox.ball
	if enemy_ball.team==ball.team:
		return
	if ignore_clash:
		return
	var dir = (enemy_ball.global_position.direction_to(ball.global_position)).normalized()
	ball.set_velocity(dir*ball.get_velocity().length())
	SoundQueue.play("res://Sounds/collision-epee_B_minor.wav",1.0,1)
	flip.emit()
	clash.emit()
	
## Called when hitting a ball
func ball_hit(hit_ball:BallBodyBase):
	if disable:
		return
	if hit_ball.team==ball.team:
		return
	if hit_ball.is_in_group("Projectile"):
		if !projectile_deflecter:
			return
		if hit_ball.is_in_group("AntiDeflect"):
			return
		hit_ball.set_team(ball.team)
		PopUpManager.pop_text("DEFLECT!",hit_ball.global_position)
		var dir = (ball.global_position.direction_to(hit_ball.global_position)).normalized()
		hit_ball.set_velocity(dir*hit_ball.get_velocity().length())
		SoundQueue.play("res://Sounds/sound-fx-shot-baseball.wav",1.0,0.75)
		if !ignore_clash:
			flip.emit()
		deflected.emit(hit_ball)
	else:
		if hit_ball.team == ball.team:
			return
		if cleave or hit_ball.auto_cleave:
			return
		flip.emit()
