extends StatusEffect
@onready var bubble_collision = $BubbleCollision
@onready var damager = $BubbleCollision/WeaponHitbox/HitboxDamager
	
func _ready():
	bubble_collision.tree_exiting.connect(queue_free)

func update_stats(stat_name,new_val):
	match stat_name:
		"Global.Enabled":
			bubble_collision.update_stats(stat_name,new_val)
			
		"Ball.ball_scale":
			bubble_collision.update_stats(stat_name,new_val)
		
		"Ball.collision_disabled":
			bubble_collision.update_stats(stat_name,new_val)
		
		"ContactDamager.damage":
			bubble_collision.update_stats("HitboxDamager.damage",new_val)

func set_target(_ball,value,data):
	super(_ball,value,data)

	baller.stat_controller.stat_changed.connect(update_stats)

	bubble_collision.set_team(_ball.team)
	
	damager.attacker_export=_ball
	bubble_collision.stat_controller.set_base_stat("ContactDamager.damage",_ball.stat_controller.get_stat("ContactDamager.damage"))
	await get_tree().process_frame
	bubble_collision.visible=true
	
func check_apply(ball)->bool:
	if !super(ball):
		return false
	return true

func _process(delta):
	if baller!=null and is_instance_valid(baller) and is_instance_valid(bubble_collision):
		bubble_collision.global_position=baller.global_position
		
		
