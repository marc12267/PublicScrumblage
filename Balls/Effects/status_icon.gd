extends TextureRect
@onready var num_val = $NumVal


func update_value(value):
	num_val.text=str(value)
