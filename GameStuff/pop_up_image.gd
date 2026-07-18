extends Node2D

var emote_tween: Tween
@export var emote_node:TextureRect

func set_image(resource):
	emote_node.texture=resource
	
func set_offset(offset:float):
	emote_node.position.y-=offset

func set_emote_scale(size:float):
	emote_tween.scale=Vector2(1,1)*size

func emote():
	if emote_tween and emote_tween.is_running():
		emote_tween.kill()

	emote_node.visible = true
	emote_node.scale = Vector2(0.6, 0.6)
	emote_node.modulate.a = 0.0

	emote_tween = create_tween()
	emote_tween.set_trans(Tween.TRANS_BACK)
	emote_tween.set_ease(Tween.EASE_OUT)

	emote_tween.tween_property(emote_node, "scale", Vector2.ONE, 0.15)
	emote_tween.parallel().tween_property(emote_node, "modulate:a", 1.0, 0.15)

	emote_tween.tween_interval(0.5)

	emote_tween.set_trans(Tween.TRANS_QUAD)
	emote_tween.set_ease(Tween.EASE_IN)
	emote_tween.tween_property(emote_node, "scale", Vector2(0.4, 0.4), 0.12)
	emote_tween.parallel().tween_property(emote_node, "modulate:a", 0.0, 0.15)

	await emote_tween.finished
	queue_free()
	
func _ready() -> void:
	
	light_mask=0
