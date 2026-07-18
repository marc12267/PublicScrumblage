extends Node2D

@onready var cd: TextureProgressBar = $CD
@export var ball:BallBodyBase

var respawn_value:float = 0.0
var default_gain_rate:float=3.5
var player_assist_rate:float = 40

var gain=0.0

func _ready() -> void:
	cd.value=0.0


func _physics_process(delta: float) -> void:
	if HitstopManager.hitstopped:
		return
	respawn_value += delta * default_gain_rate
	var plus = 0.0
	var balls = get_tree().get_nodes_in_group("Main")
	for i in balls:
		if i.team!=ball.team or i.reviving:
			continue
		if i.global_position.distance_to(ball.global_position)<300.0:
			plus+=1
			gain=20
	
	if plus==0:
		var value = max(0.0,min(max(0.0,gain-delta*player_assist_rate),delta*player_assist_rate))
		gain-=delta*player_assist_rate
		respawn_value+=value
		
	else:
		respawn_value+=plus * delta * player_assist_rate
		if respawn_value>=100:
			ball.revive_function()
			queue_free()
	if respawn_value>=100:
		$Heart.visible=true
	cd.value=respawn_value
