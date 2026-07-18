extends BehaviourScript
signal connected

@onready var hitbox_damager: HitboxDamager = $"../Visuals/BulletHitbox/HitboxDamager"
@onready var after_images: CPUParticles2D = $"../Visuals/afterImages"

var hydra_image = preload("uid://cij4hf6nxr3yr")

var dl_dmg : int = 3
var meter_gain : float = 5.0
var set_dragon_dmg : bool = false

var bounceTimer : float = 2.0

signal timer

var bounce_tick : bool = true
var bounce_tick_controller = false:
	get:
		return bounce_tick
	set(value):
		bounce_tick = value
		#print(value) 
		#critController.emit(value) # emits when aggromode is true

func _ready():
	super()
	if Global.skin_mode == "Summer":
		after_images.texture = hydra_image
	ball.bounce_wall.connect(bounced.unbind(1))

var bounce_count = 4

func bounced():
	bounce_count -= 1
	if bounce_count <= 0:
		ball.set_wall_collide(false)

func hit_process(data):
	if data["ID"]!="EDragContact":
		return
	if (!set_dragon_dmg):
		dl_dmg = randf_range(1.0, 8.0)
		if (!is_instance_valid(ball)):
			return
		sc.set_base_stat("HitboxDamager.damage", dl_dmg)
		#print(dl_dmg)
		set_dragon_dmg = true
	var attacker = data["ATTACKER"]
	var victim = data["VICTIM"]
	if victim.is_in_group("AntiInteract"):
		return
	if attacker == ball:
		StatusEffectManager.set_effect(ball.get_root_creator(),victim,"INSTASHOCK",4)
		connected.emit(meter_gain*victim.get_value_scale(), victim)
	set_dragon_dmg = false

func delete():
	ball.queue_free()
