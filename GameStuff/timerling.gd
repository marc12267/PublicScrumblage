extends Node
var goal_time=0.0
var tick_time=0.0
var hitstop_check=false
var b_script:BehaviourScript

func _ready():
	hitstop_check=HitstopManager.hitstopped
	HitstopManager.set_stop.connect(update_stop)
	process_mode=Node.PROCESS_MODE_ALWAYS

func update_stop(val):
	hitstop_check=val

func _process(delta):
	if hitstop_check:
		return
	if b_script!=null:
		if !b_script.behaviour_active:
			return
	tick_time+=delta
	if tick_time>goal_time:
		queue_free()
		
