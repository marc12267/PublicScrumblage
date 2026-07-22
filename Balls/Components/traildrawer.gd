extends Line2D
@export var target: Node2D
var queue : Array
@export var MAX_LENGTH : int
##If goes invisible, reset trail length
@export var invis_reset:bool=true

func _ready() -> void:
	global_position=Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible= target.is_visible_in_tree()
	if visible==false:
		queue.clear()
		clear_points()
	else:
		var pos = target.global_position
		queue.push_front(pos)
		if queue.size() > MAX_LENGTH:
			queue.pop_back()
		clear_points()
		for point in queue:
			add_point(point)
