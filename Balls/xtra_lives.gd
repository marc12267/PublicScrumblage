extends Node2D
@export var stat_controller:Node
var ball:BallBodyBase

@onready var heart: Node2D = $Heart
@onready var label: Label = $Heart/Label
@onready var heartbroken: Sprite2D = $Heartbroken


func _ready() -> void:
	stat_controller.readied.connect(readied)
	visible=false
	EventManager.update_extra_lives.connect(log_updates)
	

func readied():
	ball=stat_controller.ball

func log_updates(baller,count):
	if baller!=ball:
		return
	if count>0:
		visible=true
	label.text=str(count)
	if count==0:
		heart.visible=false
		heartbroken.visible=true
	
