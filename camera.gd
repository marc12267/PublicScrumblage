extends Camera2D
class_name StageCamera
var focus_zoom := Vector2(1.5, 1.5)
var focus_in_time := 0.5
var focus_out_time := 0.4
var focus_wait := 0.6
var arena_zoom := 1.0

var original_zoom = zoom
var original_pos = position


func _ready():
	EventManager.critted.connect(critshake)
	original_position = position
	EventManager.match_end.connect(critshake)
	EventManager.s_move.connect(special_move)
	special_move_graphic.visible = false
	Global.quake_trigger.connect(add_quake)
	
	EventManager.resize_camera_arena.connect(upd)

func upd(val): 
	if specialing:
		return
	arena_zoom=val 
	zoom = original_zoom/arena_zoom

func critshake(thing):
	Global.quake_trigger.emit(1)
	SoundQueue.play("res://Sounds/critical-punch-sound-effect.ogg")
	
@export var max_offset :float= 12.0   

var quake := 0.0
var original_position: Vector2


func add_quake(amount: float):
	quake = max(quake, amount)

func _physics_process(delta):
	if quake <= 0.0:
		return

	var _offset = Vector2(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)) * max_offset*min(quake,1.5)

	offset=_offset

	quake = max(quake - delta*5, 0.0)
	
	
	
var tween: Tween
@onready var special_move_graphic = $CanvasLayer/SpecialMove

func special_move(target_pos: Vector2,_texture):
	if specialing:
		return
	specialing=true
	special_move_graphic.texture=_texture
	
	
	
	add_quake(1.4)
	
	if tween:
		tween.kill()

	tween = create_tween()

	HitstopManager.set_histop(focus_in_time + focus_wait + focus_out_time)


	##Show graphic
	special_move_graphic.visible = true
	special_move_graphic.modulate.a = 1.0

	##Zoom in
	tween.tween_property(self, "position", target_pos, focus_in_time)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "zoom", focus_zoom, focus_in_time)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_interval(focus_wait)

	##Return camera to position
	tween.tween_property(self, "position", original_pos, focus_out_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "zoom", original_zoom/arena_zoom, focus_out_time)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	##Graphic fade
	tween.parallel().tween_property(special_move_graphic, "modulate:a", 0.0, focus_out_time)
	tween.tween_callback(func(): special_move_graphic.visible = false)
	await tween.finished
	specialing=false

var specialing=false
	
