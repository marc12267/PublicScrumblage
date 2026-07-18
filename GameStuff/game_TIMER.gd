extends Label
var time:float=99
var start=false

func _ready():
	EventManager.round_start.connect(start_timer)
	
func start_timer():
	start=true

func _process(delta):
	text=str(int(round(EventManager.round_time)))
