## Base node for status effects

extends Node
class_name StatusEffect

var counter = 0

## Flag that must be enabled for the status to show up in the character's ui
@export var have_icon :bool=false
## Icon of the ui element
@export var icon_effect = "res://Balls/Effects/Burning/Flame.png"

## FLag for special effects for ball stat ui
@export var have_bstat_effect:bool=false
@export var bstat_callable = "callable_name"

## The ball which applied the status, ownership
var ball_source = null
## The ball being affected
var baller:BallBodyBase

func _enter_tree():
	tree_exiting.connect(on_leave)
	
func set_counter(val):
	counter=val
	if have_icon:
		set_icon(icon_effect,ceil(counter))
	if have_bstat_effect:
		bstat_effect(bstat_callable,counter)
		

func set_source(source):
	ball_source=source
	
func on_leave():
	if have_icon:
		set_icon(icon_effect,-1)
		
	if have_bstat_effect:
		bstat_effect(bstat_callable,-1)
	

func update(value,data:Dictionary)->StatusEffect:
	counter=value
	return self

func set_icon(icon_path:String,value:int):
	if !get_tree():
		return
	var displayers = get_tree().get_nodes_in_group("STATUS_DISPLAY")
	for i in displayers:
		if i.get_ball()==baller:
			i.update(icon_path,value)

func bstat_effect(callable_str,value):
	if !get_tree():
		return
	var bstats = get_tree().get_nodes_in_group("BStats")
	for i in bstats:
		if i.hit_processor.ball==baller:
			i.status_visual(callable_str,value)

func check_apply(ball)->bool:
	if ball.is_in_group("AntiStatus"):
		return false
	return true
	
func set_target(ball,value,data):
	if !is_instance_valid(ball):
		return
	baller=ball
	ball.tree_exiting.connect(queue_free)

func delete():
	queue_free()
