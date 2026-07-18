extends Control
@onready var ball:BallBodyBase = $"../.."
@onready var hit_processor:HitProcessor=$"../../HitProcessor"
@onready var health_manager:HealthManager=$"../../HealthManager"
@onready var meter_manager:MeterManager=$"../../MeterManager"
@onready var healthbar:Node = $BattleBar/Healthbar
@onready var frailbar:Node = $BattleBar/Healthbar/Frail
@export var meterbar:Node
@export var health_chaser:TextureProgressBar
@onready var status_displayer: Control = $BattleBar/StatusDisplayer
@onready var overhealth: TextureProgressBar = $BattleBar/Healthbar/Overhealth

@onready var armor: TextureProgressBar = $BattleBar/Healthbar/Armor

signal max_health

func group_add():
	add_to_group("BStats")
	
func _ready():
	group_add()
	if !health_manager:
		return
	healthbar.health_manager=health_manager
	meter_manager.meter_change.connect(meter_change)
	health_manager.health_setted.connect(healthbar.health_setted)
	health_manager.hitprocessor.set_damage_scale.connect(update_resistance)
	ball.set_dodge_rate.connect(update_dodge_rate)
	hit_processor.set_immune.connect(healthbar._update_bar_color.unbind(1))
	p_bar.connect(healthbar.purple_bar)
	ball.tree_exiting.connect(queue_free)

func update_resistance(value):
	status_displayer.update_wide("res://Assets/Shield.png",int((1-value)*100))

func update_dodge_rate(value):
	status_displayer.update_wide("res://Assets/Wing.png",int((value)*100))

signal p_bar
func purple_bar(value):
	p_bar.emit(value)

func meter_change(value):
	meterbar.value = value

func status_visual(callable_str, value):
	Callable(self, callable_str).call(value)
