extends Node
@export var shrink_amount = 0.1
@onready var arena = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.fighter_count_update.connect(arena_update)


func arena_update(val):
	if val ==3:
		arena.set_size(1.0-shrink_amount)
	elif val ==2:
		arena.set_size(1.0-shrink_amount*2)
