extends Node
class_name GlobalTimer
var timerling = preload("res://GameStuff/timerling.gd")

func delay(seconds: float) -> void:
	var new_timer = timerling.new()
	new_timer.goal_time=seconds
	add_child(new_timer)
	await new_timer.tree_exited
	return

func delay_bs(seconds: float,_script:BehaviourScript) -> void:
	var new_timer = timerling.new()
	new_timer.goal_time=seconds
	new_timer.b_script=_script
	add_child(new_timer)
	await new_timer.tree_exited
	return
