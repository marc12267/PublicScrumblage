extends BehaviourScript
@onready var hitbox = $"../Scaler/BulletHitbox"
@onready var hit_gain: Node = $HitGain

signal connected
var fb_dmg=2
var meter_gain :float = 6.5
func _ready():
	super()
	ball.bounce_wall.connect(bounced.unbind(1))
	
func bounced():
	ball.set_wall_collide(false)


		
func hit_process(data):
	var attacker=data["ATTACKER"]
	if attacker==ball:
		delete()
		
		

func delete():
	ball.queue_free()
