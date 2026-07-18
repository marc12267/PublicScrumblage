extends Mood


@onready var resource = load("res://Balls/Moods/MoodAssets/Thinker.png")

func _ready():
	trigger_behaviour.connect(behaviour)


func behaviour():
	super()
	ball.bounce.emit()
	var speed = (ball.get_velocity().normalized())
	
	ball.set_velocity( speed)

	PopUpManager.emote_effect(ball,resource,scaled_offset())
