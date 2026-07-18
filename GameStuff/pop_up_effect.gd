extends Node2D
@onready var label:Label = $Label
var float_dir:Vector2= Vector2.UP
var speed:float= 60.0

var fade_scale=1.0

func animate():
	var tween = create_tween()
	tween.tween_property(self,"position",position + float_dir * 85,0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label,"modulate:a",0.0,0.65*fade_scale).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label,"scale",label.scale * 1.2,0.1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)

func set_text(text):
	$Label.text=text

func _ready() -> void:
	
	light_mask=0
