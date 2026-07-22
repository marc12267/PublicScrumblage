extends Control

class_name BStatDisplay
@onready var ball:BallBodyBase = $"../.."
@onready var hit_processor:HitProcessor=$"../../HitProcessor"
@onready var health_manager:HealthManager=$"../../HealthManager"
@onready var meter_manager:MeterManager=$"../../MeterManager"
@export var box:Node2D
@export var healthbar:Node
@export var frailbar:Node
@export var meterbar:Node
@export var health_chaser:TextureProgressBar
@export var status_displayer: Control
@export var overhealth: TextureProgressBar 
@export var armor: TextureProgressBar

signal max_health
signal readied

var default_color:Color=Color("00b88a")
func group_add():
	add_to_group("BStats")
	
func _ready():
	group_add()
	if !health_manager:
		return
	meter_manager.meter_change.connect(meter_change)
	health_manager.health_setted.connect(health_setted)
	health_manager.hitprocessor.set_damage_scale.connect(update_resistance)
	ball.set_dodge_rate.connect(update_dodge_rate)
	hit_processor.set_immune.connect(_update_bar_color.unbind(1))
	readied.emit()
	EventManager.deleting_node.connect(deactivate)
	
func deactivate(node):
	if node==ball:
		box.deactivate()
	
	
func update_resistance(value):
	status_displayer.update_wide("res://Assets/Shield.png",int((1-value)*100))

func update_dodge_rate(value):
	status_displayer.update_wide("res://Assets/Wing.png",int((value)*100))

func health_setted():
	var display_max = health_manager.max_health + max(health_manager.overhealth, 0.0)
	healthbar.max_value = display_max
	frailbar.max_value = display_max
	health_chaser.max_value = display_max
	overhealth.max_value = display_max
	health_chaser.value = display_max

func _update_bar_color():
	if not hit_processor.immune:
		healthbar.tint_progress = default_color


func purple_bar(value):
	$Box/BattleBar/Healthbar.purple_bar(value)

func meter_change(value):
	meterbar.value = value

func _process(_delta):
	if ball==null:
		return
	var target = healthbar.value
	health_chaser.value = max(target, health_chaser.value - 0.15)
	
	if hit_processor.immune:
		var hue = fmod(Time.get_ticks_msec() / 300.0 * 0.25, 1.0)
		healthbar.tint_progress = Color.from_hsv(hue, 0.85, 1.0)

func status_visual(callable_str, value):
	Callable(self, callable_str).call(value)
