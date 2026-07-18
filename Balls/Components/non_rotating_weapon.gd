## Script to make a weapon follow a node around rotater while keeping it's rotation

extends Sprite2D
@export var ball:BallBodyBase
var stat_controller:StatController

func _ready():
	stat_controller=ball.stat_controller
	stat_controller.stat_changed.connect(update_stats)
	stat_controller.set_base_stat("FloatWeapon.scale",scale)
	top_level=true


func update_stats(stat_name,new_val):
	match stat_name:
		"FloatWeapon.scale":
			scale=new_val
			
func _process(delta):
	global_position=get_parent().global_position
