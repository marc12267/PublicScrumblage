## Node used to display icons for status effects and damage reductions/dodge chances

extends Control
@onready var ball_stat_display = $"../../.."
@onready var h_box_container = $HBoxContainer

const STATUS_ICON = preload("uid://c75tekt7pawnr")
const STATUS_ICON_WIDE = preload("res://Balls/Effects/status_icon_wide.tscn")

var status_dict = {}

func get_ball():
	if !ball_stat_display.hit_processor:
		return
	return ball_stat_display.hit_processor.ball

func _ready():
	add_to_group("STATUS_DISPLAY")
	
func update(icon_path,value):
	if status_dict.keys().has(icon_path):
		if value<=0:
			var icon = status_dict[icon_path]
			status_dict.erase(icon_path)
			icon.queue_free()
		else:
			status_dict[icon_path].update_value(value)
	elif value>0:
		var new_icon = STATUS_ICON.instantiate()
		h_box_container.add_child(new_icon)
		status_dict[icon_path]=new_icon
		status_dict[icon_path].update_value(value)
		new_icon.texture = load(icon_path)

func update_wide(icon_path,value):
	if status_dict.keys().has(icon_path):
		if value<=0:
			var icon = status_dict[icon_path]
			status_dict.erase(icon_path)
			icon.queue_free()
		else:
			status_dict[icon_path].update_value(value)
	elif value>0:
		var new_icon = STATUS_ICON_WIDE.instantiate()
		h_box_container.add_child(new_icon)
		status_dict[icon_path]=new_icon
		status_dict[icon_path].update_value(value)
		new_icon.texture = load(icon_path)
