extends Area2D
class_name Hurtbox
## Custom hurtbox thing wip experimental
## Due to the fact I made contact damage detection based on rigidbody contact,
## I need to use this custom hitbox for edgecase stuff

@export var active:bool=true
@export var ball:BallBodyBase
@export var ignore_list:Array

@export var bounce_detect:bool=true
@export var weapon_detect:bool=true

func _ready() -> void:
	body_entered.connect(body_enter)
	set_bounce_detect(bounce_detect)
	set_weapon_detect(bounce_detect)


func set_bounce_detect(truefalse):
	weapon_detect = truefalse
	set_collision_layer_value(5,truefalse)
	
func set_weapon_detect(truefalse):
	weapon_detect = truefalse
	set_collision_layer_value(6,truefalse)

func body_enter(body):
	if !bounce_detect:
		return
	if ignore_list.has(body) or !(body is BallBodyBase) or body==ball:
		return
	body.bounce_ball.emit(ball)
