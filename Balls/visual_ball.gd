## Visual node contains visuals for the ball's main body
## Place visuals meant in here, scales off ball_scale

extends Node2D
class_name VisualBody
@export var ball:BallBodyBase
var max_offset :float= 12.0   
var quake := 0.0
var original_position: Vector2
var stat_controller:StatController
var base_scale=Vector2(1,1)
var quake_offset := Vector2.ZERO
var time=0.0
var shake_factor := 0.0

## Stats for shake when taking damage
## No need to touch these
var base_amplitude :float= 0.0
var max_amplitude := 50.0
var base_speed :float= 0.0
var max_speed :float= 50.0
@onready var default: Node2D = $Default
@onready var hurt: Node2D = $Hurt


func _ready():
	stat_controller=ball.stat_controller
	original_position = position
	stat_controller.stat_changed.connect(update_stats)
	
	stat_controller.set_base_stat("Visuals.scale",scale)
	stat_controller.add_alias("Visuals.scale", "Visuals.scale")
	
	ball.update_scale.connect(update_scale)
	ball.pre_defeated.connect(shake_start)
	default.setted.connect(priority_set)
	
func priority_set():
	default.visible=true
	hurt.visible=false
	

## Update stats
func update_stats(stat_name,new_val):
	match stat_name:
		"Visuals.scale":
			base_scale=new_val
			update_scale()
	



func shake_start():
	shake_factor=0.7
	var tween = create_tween()
	tween.tween_property(self,"shake_factor",0.1,1)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)

func _process(delta):
	time += delta
	var amplitude = lerp(base_amplitude, max_amplitude, shake_factor)
	var speed = lerp(base_speed, max_speed, shake_factor)
	var shake_offset = Vector2(sin(time * speed) * amplitude, 0)
	position = original_position + shake_offset + quake_offset  # combine both

func _physics_process(delta):
	if quake <= 0.0:
		quake_offset = Vector2.ZERO
		return
	quake_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * max_offset * min(quake, 1.5)
	quake = max(quake - delta * 10, 0.0)
func update_scale():
	scale=ball.ball_scale*base_scale
	
func add_quake(amount: float):
	quake = max(quake, amount)
