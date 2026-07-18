@tool
extends TextureRect

@export var star_point: Control
@export var grid_value: Vector2 = Vector2(0, 0)
var chart_size: float

func _ready():
	chart_size = size.x / 2.0

func _process(delta):
	if star_point == null:
		return
	
	grid_value = star_point.position/chart_size
	star_point.grid_value = grid_value
	update_chart_color()
	
func update_chart_color():
	var x = star_point.position.x / chart_size
	var y = -star_point.position.y / chart_size
	x = clamp(x, -1.0, 1.0)
	y = clamp(y, -1.0, 1.0)

	var neutral = Color("888888ff")

	var horiz_color = Color("00dba8ff") if x < 0 else Color("f00800ff")
	var vert_color  = Color("1f1fedff") if y < 0 else Color("f0dc02ff")

	var x_strength = pow(abs(x), 0.25)
	var y_strength = pow(abs(y), 0.25)

	var from_x = neutral.lerp(horiz_color, x_strength)
	var from_y = neutral.lerp(vert_color,  y_strength)

	var total = x_strength + y_strength
	var blended: Color
	if total > 0:
		var wx = x_strength / total
		var wy = y_strength / total
		blended = from_x * wx + from_y * wy
	else:
		blended = neutral

	modulate = blended
