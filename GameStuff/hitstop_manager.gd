## Manager of hitstops
## Set hitstops here to freeze on hit
extends Node

signal set_stop
signal resume
var timer:float
var hitstopped=true

func _ready():
	EventManager.round_start.connect(rs)
	
func rs():
	hitstopped=false
	set_stop.emit(false)

func clear_hitstop():
	timer=0
	hitstopped=false
	set_stop.emit(false)

func set_histop(val:float):
	if Global.team_fight:
		val=val*0.6
	timer=max(timer,val)
	if timer==0:
		hitstopped=false
		set_stop.emit(false)
	else:
		set_stop.emit(true)
		hitstopped=true
	

func _physics_process(delta):
	if timer>0.0:
		timer=max(0,timer-delta)
		if timer==0:
			hitstopped=false
			set_stop.emit(false)
			resume.emit()
