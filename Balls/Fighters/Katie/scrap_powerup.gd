extends Node2D
@onready var area_2d = $Area2D
var team=-1
var data = {"ID":"HYLAPOWER"}
var active=false
var katie

func _ready():
	await get_tree().physics_frame
	active=true
	
	katie.tree_exiting.connect(queue_free)
	
	if katie.skin=="Summer":
		$Area2D/CollisionShape2D/Default.texture=load("res://Balls/Fighters/Katie/beachkatie_wreckage.png")

func _on_area_2d_body_entered(body):
	if active==false:
		return
	if body is BallBodyBase:
		if body==katie:
			katie.get_node("KatieScript").scrap_meter()
			queue_free()
