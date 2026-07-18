extends Node2D
@onready var health_component:HealthManager=get_parent()
@onready var ball: BallBodyBase 
@onready var scaler: Node2D = $Scaler

@onready var health_label: Label = $Scaler/HealthLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball = health_component.ball
	scaler.set_ball(ball)
	visible=false
	health_component.overhealth_changed.connect(update_barrier)
	scaler.update_scale()
	

func _process(delta: float) -> void:
	global_position=ball.global_position


func update_barrier(value):
	health_label.text=str(value)
	visible = value>0.0
