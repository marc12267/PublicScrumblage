extends BehaviourScript
@onready var hit_processor = $"../HitProcessor"
@onready var hitbox = $"../BulletHitbox"
signal connected
#var bounce_count=2
func _ready():
	super()
	#ball.bounce_wall.connect(bounced.unbind(1))
	#
#func bounced():
	#bounce_count-=1
	#if bounce_count<=0:
		#ball.set_collision_mask_value(1,false)

func hit_process(data):
	var attacker=data["ATTACKER"]
	var victim = data["VICTIM"]
	if attacker==ball:
		connected.emit()
		delete()
		

func delete():
	ball.queue_free()
