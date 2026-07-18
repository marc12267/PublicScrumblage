extends CanvasItem

@export var color_a:Color
@export var color_b:Color
@export var cycle_duration: float = 1

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	var blend: float = abs(sin(_t*PI/cycle_duration))
	modulate = lerp(color_a, color_b, blend)
