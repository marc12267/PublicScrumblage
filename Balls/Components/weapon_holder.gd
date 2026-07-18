## Base node to hold weapon
## Generic
extends Node2D
@export var ball:BallBodyBase
var stat_controller:StatController

@export var stat_name:String="WeaponHolder"
func _ready():
	
	stat_controller=ball.stat_controller
	stat_controller.stat_changed.connect(update_stats)
	
	stat_controller.set_base_stat(stat_name+".scale",scale)
	stat_controller.add_alias("WeaponHolder.scale", "WeaponHolder.scale")

func update_stats(stat,new_val):
	if stat_name+".scale"==stat:
		scale=new_val
