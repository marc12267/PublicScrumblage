## Use to create after image visual effect

extends Node
## Active enables the after images
@export var active:bool=true
@export var ball:BallBodyBase

## Visual node to duplicate for after images
@export var visual:CanvasItem

@export var copy_visiblity:bool=true

## Delay is how long to wait before creating afterimage
@export var delay:float=0.1

## How much to shrink image to as it fades out
@export var shrink_scale:float = 0.5

## How long should afterimages last
@export var duration:float = 0.3

## Starting transparency
@export var starting_a:float = 0.9
@export var ending_a:float=0.0

## Elevation in the after effect, this is saved for super balls
@export var float_up:float = 0.0
var counter=0.0

## Z Index we spawn the aftereffect at
@export var spawn_z_index = -1

func _process(delta: float) -> void:
	if HitstopManager.hitstopped:
		return
	if !active:
		return
	counter+=delta
	
	if counter>delay:
		counter=0.0
		var visual_new=visual.duplicate(0)
		if visual_new.get_node_or_null("HealthLabel")!=null:
			visual_new.get_node("HealthLabel").queue_free()
		if ball==null:
			print("BallMissing")
			get_tree().get_first_node_in_group("Arena").add_child(visual_new)
		else:
			ball.get_parent().add_child(visual_new)
		visual_new.z_index=spawn_z_index
		if copy_visiblity:
			visual_new.visible = visual.is_visible_in_tree()
		else:
			visual_new.visible=true
		visual_new.global_transform=visual.get_global_transform()
		var v_scale = visual_new.scale

		if visual_new is VisualBody:
			visual_new.get_node("AnimationPlayer").queue_free()
			
		var tween=get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		visual_new.modulate.a=starting_a
		tween.tween_property(visual_new, "modulate:a", ending_a, duration)
		tween.parallel().tween_property(visual_new, "scale", v_scale*shrink_scale, duration)
		tween.parallel().tween_property(visual_new, "position:y", visual_new.position.y+float_up, duration)
		tween.finished.connect(visual_new.queue_free)
