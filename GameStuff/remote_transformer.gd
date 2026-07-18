extends Marker2D

@export var target:CanvasItem
	
func set_target(t):
		target=t
		t.node=self


func _process(delta: float) -> void:
	if target==null:
		return
	target.global_scale=global_scale
	target.global_position=global_position
	
