extends Node2D
@onready var ball_body_base: BallBodyBase = $".."

@onready var pack: Sprite2D = $Pack
@onready var bar: TextureProgressBar = $TextureProgressBar
@onready var area_2d: Area2D = $Pack/Area2D

@export var cooldown:float = 15
var cd:float=0.0

func _ready() -> void:
	pack.visible=false
	bar.value=0.0
	
func _process(delta: float) -> void:
	if HitstopManager.hitstopped:
		return
	bar.rotation_degrees+=(20+(200 * (1.0-pow(cd/cooldown,1.8))))*delta
		
	if pack.visible:
		ball_body_base.stat_controller.set_base_stat("Ball.freeze",true)
		var overlaps = area_2d.get_overlapping_bodies()
		var b_overlaps = []
		for i in overlaps:
			if i is BallBodyBase and i.is_in_group("Main"):
				b_overlaps.append(i)
		if b_overlaps.size()>0:
			var closest = b_overlaps.pop_front()
			for i in b_overlaps:
				if global_position.distance_to(i.global_position)<global_position.distance_to(closest.global_position):
					closest=i
			StatusEffectManager.set_effect(null,closest,"INSTAHEAL",10)
			SoundQueue.play("res://Sounds/medkit.wav",1,0.7)
			cd=0.0
			pack.visible=false
	else:
		ball_body_base.stat_controller.set_base_stat("Ball.velocity",450*(1.0-pow(cd/cooldown,1.2)))
		ball_body_base.stat_controller.set_base_stat("Ball.freeze",false)
		cd+=delta
		bar.value=cd/cooldown * 100.0
		
		if cd>cooldown:
			pack.visible=true
			
