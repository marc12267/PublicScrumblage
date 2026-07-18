extends Node
@export var extra_rotation:float = 0.0
@export var anti_rotate_target:Node
@export var anti_base:Node
var rot_track:float=0.0

func _ready() -> void:
	if anti_base==null:
		anti_base = anti_rotate_target.get_parent()

func _process(delta):
	if HitstopManager.hitstopped:
		return
		
	rot_track+=extra_rotation*delta
	anti_rotate_target.rotation = -anti_base.global_rotation +rot_track 
