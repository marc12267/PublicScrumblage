extends Label
@export var disable:bool=false
@export var health_component:HealthManager
var hit_processor:HitProcessor
const OUTLINE_FONT = preload("uid://cup76ope8qaow")
const OVERHEALTHFONT = preload("uid://dsnvdmonkoeq8")
const OUTLINE_INVERT_FONT = preload("uid://bqldsemudjwcs")
const ARMORFONT = preload("uid://1jlg0bquv8ko")


func update_font():
	if health_component.overhealth>0.0:
		label_settings = OVERHEALTHFONT
		return
	if health_component.armor>0:
		label_settings = ARMORFONT
		return
	label_settings = OUTLINE_FONT

func _enter_tree():
	light_mask=0
	if health_component==null:
		queue_free()
		return
	if disable:
		return
	health_component.health_changed.connect(update_health.unbind(1))
	health_component.armor_changed.connect(update_health.unbind(1))
	health_component.overhealth_changed.connect(update_health.unbind(1))
	hit_processor=health_component.hitprocessor
	hit_processor.set_immune.connect(immune_set)

func immune_set(truefalse):
	visible=!truefalse
	if truefalse:
		return


func _ready():
	if health_component==null:
		return
	health_component.armor_changed.connect(update_font.unbind(1))
	health_component.overhealth_changed.connect(update_font.unbind(1))
	health_component.health_changed.connect(update_font.unbind(1))
	update_health()
	update_font()
	await get_tree().process_frame
	visible = !health_component.ball.is_in_group("Boss")
	
func update_health():
	var val = health_component.health
	if health_component.overhealth > 0:
		val = health_component.overhealth
		val = ceil(health_component.overhealth)
			
	elif health_component.armor > 0:
		val = health_component.armor
	
	val = floor(val * 10.0) / 10.0
	if val == floor(val):
		val = int(val)
	
	text = str(val)
