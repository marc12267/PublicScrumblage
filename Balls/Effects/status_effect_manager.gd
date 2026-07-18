## Globally accessible way to apply status effect

extends Node

var effect_list = {
	"BURNING":preload("res://Balls/Effects/Burning/burning.tscn"),
	"FREEZE":preload("res://Balls/Effects/Freeze/freeze.tscn"),
	"TOXIC":preload("res://Balls/Effects/Toxic/toxic.tscn"),
	"ELECTRO":preload("res://Balls/Effects/Electrocute/electrocuted.tscn"),
	"INSTASHOCK":preload("res://Balls/Effects/Electrocute/instashock.tscn"),
	"HEALING":preload("res://Balls/Effects/Healing/healing.tscn"),
	"SLEEPING":preload("res://Balls/Effects/Sleeping/sleeping.tscn"),
	"MARKEDFORDEATH":preload("res://Balls/Effects/MFD/marked_for_death.tscn"),
	"COMBO":preload("res://Balls/Effects/Combo/combo.tscn"),
	"PETRIFY":preload("res://Balls/Effects/Petrify/petrify.tscn"),
	"SPOOKED":preload("res://Balls/Effects/Spooked/spooked.tscn"),
	"SHATTER":preload("res://Balls/Effects/Shatter/shatter.tscn"),
	"INSTAHEAL":preload("res://Balls/Effects/Healing/instant_healing.tscn"),
	"STUNNED":preload("res://Balls/Effects/Stunned/stunned.tscn"),
	"GRAPPLED":preload("res://Balls/Effects/Grappled/grappled.tscn"),
	"CHILLED":preload("res://Balls/Effects/Chilled/chilled.tscn"),
	"FREEZED":preload("res://Balls/Effects/Freeze/freeze.tscn"),
	"STINKY":preload("res://Balls/Effects/Stinky/stinky.tscn")
}

var effected = {
	#"BALL" : {"BURNING":null}
}

func get_balls_with_status(STATUSNAME:String):
	var ball_list=[]
	for i in effected.keys():
		if !is_instance_valid(i):
			continue
		if effected[i].keys().has(STATUSNAME):
			ball_list.append(i)
	return ball_list
	

## Get list of effects applied to a ball
func get_effects(ball:BallBodyBase)->Dictionary:
	var assigned_effects:Dictionary = effected.get(ball,{})
	var e_list = {}
	for i in assigned_effects.keys():
		var _effect = assigned_effects.get(i,null)
		if _effect!=null:
			e_list[i] = _effect
	return e_list

## Apply an effect to the ball
## Type field should match a key in effect_list
func set_effect(applier_ball,ball:BallBodyBase,type:String,strength:float,data:Dictionary={}):
	if !is_instance_valid(ball):
		return
	var _effects = get_effects(ball)
	var _efct = _effects.get(type,null)
	if _efct == null:
		var val =  _create_effect(ball,type,strength,data)
		if !val:
			return null
		val.set_source(applier_ball)
		delay_emit({"APPLIER":applier_ball,"VICTIM":ball,"EFFECT":type,"STRENGTH":strength,"DATA":data})
		return val
	else:
		_efct.set_source(applier_ball)
		var val = _efct.update(strength,data)
		if !val:
			return null
		delay_emit({"APPLIER":applier_ball,"VICTIM":ball,"EFFECT":type,"STRENGTH":strength,"DATA":data})
		return val


func delay_emit(data):
	await get_tree().process_frame
	EventManager.status_effected.emit(data)

func _create_effect(ball:BallBodyBase,type:String,strength:float,data:Dictionary):
	if !is_instance_valid(ball):
		return null
	var effect:StatusEffect = effect_list[type].instantiate()
	if effect.check_apply(ball)==false:
		return null
	
	call_deferred("add_child",effect)
	ball.defeated.connect(effect.queue_free)
	effect.tree_exiting.connect(_remove_thing.bind(ball,type))

	if !effected.has(ball):
		effected[ball] = {}
	effected[ball][type] = effect
	add_delay(effect,ball,strength,data)
	return effect

func add_delay(effect,ball,strength,data):
	await effect.ready
	effect.set_target(ball,strength,data)

func remove_status(ball:BallBodyBase,type:String):
	var e_list:Dictionary = effected.get(ball,{})
	if e_list.size()==0:
		return
	var status:StatusEffect = e_list.get(type,null)
	if status==null:
		return
	status.queue_free()

func _remove_thing(ball,type:String):
	var e_list:Dictionary = effected.get(ball,{})
	if e_list.size()==0:
		return
	e_list.erase(type)
	EventManager.status_effected.emit({"VICTIM":ball,"EFFECT":type,"STRENGTH":-1})
	return
	
