extends Node
@export var loop_count:int=-1
@export var loop_rounds : bool = false
var count:int=0

func _ready() -> void:
	EventManager.winners.connect(check_winner)
	EventManager.round_time = 100.0
	get_tree().paused = false
	

func check_winner(winners):
	if loop_rounds==false:
		return
	EventManager.winners.disconnect(check_winner)
	if !winners.is_empty():
		var winner = str(winners[0].name)
		for i in range(10):
			if winner.contains(str(i)):
				winner = winner.replace(str(i), "X")
		if winners[0].get_node("HealthManager").health<=0:
			print("Tie")
		else:
			print(str(winner, " Wins (",winners[0].get_node("HealthManager").health,"HP left)"))
	else:
		print("Tie")
		
	if loop_rounds:
		if loop_count!=-1:
			count+=1
			if count >= loop_count:
				return
		get_tree().paused = true
		HitstopManager.clear_hitstop()
		HitstopManager.hitstopped=true
		get_tree().call_deferred("reload_current_scene")
