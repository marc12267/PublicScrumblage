
class_name CreditsRoller
extends Control

@export var names: Array[String] = ["Litoll ₍՞..՞₎..3..","AdminFancoeu","m","Syed Zain Haider","Moss","Luke Carpenter","Koi Fyshyerman","Mole","Luggi","D0mUnit","Desire Delta","ZelisinHell","dex","Lyra♡Cat♡","critatonic","SakiFak"]
@export var scroll_speed: float = 1450.0
@export var gap_between_names: int = 50
@export var font_size: int = 54
@export var fade_duration: float = 0.5

@onready var _scroll: ScrollContainer = $ScrollContainer
@onready var _hbox: HBoxContainer = $ScrollContainer/HBoxContainer
@onready var _timer: Timer = $Timer

var _scrolling: bool = false
var _total_width: float = 75.0


func _ready() -> void:
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.vertical_scroll_mode   = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_timer.wait_time = 0.016
	_timer.timeout.connect(_on_tick)
	modulate.a = 0.0


func roll() -> void:
	if _scrolling:
		return

	_scrolling = true
	await _build_labels()
	_hbox.position.x = size.x
	_fade_in()
	_timer.start()


func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)


func _build_labels() -> void:
	for child in _hbox.get_children():
		child.queue_free()


	for name_str in names:
		var lbl := Label.new()
		lbl.text = name_str
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", font_size)

		if _hbox.get_child_count() > 0:
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(gap_between_names, 0)
			spacer.size_flags_vertical = Control.SIZE_FILL
			_hbox.add_child(spacer)
			_total_width += gap_between_names

		_hbox.add_child(lbl)
		await get_tree().process_frame

		if not is_instance_valid(lbl):
			return

		_total_width += lbl.size.x


func _on_tick() -> void:
	if not _scrolling:
		return

	_hbox.position.x -= scroll_speed * _timer.wait_time

	if _hbox.position.x < -_total_width:
		_scrolling = false
		_timer.stop()
		_fade_out()
