## Make this script parent to behaviour script
## This will make the ball seek towards the enemy
## T7 seeking logic

extends Node
@onready var behaviour_script:BehaviourScript=get_parent()
@export var enabled:bool=false
@export var rotation_strength:float=5

func _physics_process(delta):
	if HitstopManager.hitstopped or !enabled:
		return
		
	var dir_to_enemy: Vector2 = Global.dir_closest_ball(behaviour_script.ball).normalized()
	var velocity: Vector2 = behaviour_script.ball.get_velocity()
	var speed: float = velocity.length()
	
	var new_dir: Vector2 = velocity.normalized().lerp(dir_to_enemy, rotation_strength * delta).normalized()
	
	behaviour_script.ball.set_velocity(new_dir * speed)
