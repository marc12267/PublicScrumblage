extends Control
@onready var mr_pootis_ball: BallBodyBase = $"../.."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position.x = mr_pootis_ball.global_position.x-size.x/2.0
