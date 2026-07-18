extends BehaviourScript

var attached:BallBodyBase
@export var superpoop:bool=false
func _ready():
	super()
	$"../hitbox".hit_ball.connect(trap)
	$"../GPUParticles2D".emitting=false
	if superpoop:
		stacks+=12
		scale_dec=0.025
	
var delaay_tick = 0.2
var stacks = 12
var scale=1.0
var scale_dec=0.05
func trap(victim):
	if victim.team==ball.team:
		return
	if victim.is_in_group("AntiInteract") or !victim.is_in_group("Main"):
		return
	SoundQueue.play("res://Sounds/squash.wav",1,0.4)
	stacks-=1
	scale-=scale_dec
	sc.set_base_stat("Ball.ball_scale",scale)
	StatusEffectManager.set_effect(ball.get_root_creator(),victim,"STINKY",1)

		
	if stacks==0:
		ball.queue_free()
	

var planted=false

func _physics_process(delta: float) -> void:
		
	if attached!=null:
		ball.global_position = attached.global_position
		return
	
	if planted:
		return
	if ball.get_velocity().length()<=10:
		planted=true
		ball.set_collision_layer_value(3,false)
		
		await delay(1)
		$"../GPUParticles2D".emitting=true
		await delay(0.15)
		sc.set_base_stat("Hitbox.active",true)
		
	
	
	
	
	return
