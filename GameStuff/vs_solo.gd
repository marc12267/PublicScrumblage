extends CanvasLayer
@onready var community_art: = $CommunityArt

	
var max_offset :float= 12.0   

var quake := 0.0
var original_position: Vector2


func add_quake(amount: float):
	quake = max(quake, amount)

func _physics_process(delta):
	var _offset = Vector2(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)) * max_offset*min(quake,1.5)

	offset=_offset + original_position
	quake = max(quake - delta*5, 0.0)
	
	


@onready var winner: ColorRect = $Winner

var delay = 0.85
func _ready() -> void:
	original_position=offset
	Global.quake_trigger.connect(add_quake)
	
	Global.credit_scroller.connect(slide_winner)
	Global.art_showcase.connect(art_showcase)
	
	winner.visible=false
	
func slide_winner():
	var cs = get_node("CreditScroller")
	if cs != null:
		cs.roll()
	
func art_showcase():
	if !community_art:
		return
	community_art.display()

func winner_display(winner):
	$Winner.visible = true
	$Winner.color = Color("00000000")
	$Winner/Label.modulate.a = 0.0
	
	
	Global.credit_scroller.emit()
	if winner == null:
		$Winner.color = Color("00000080")
		$Winner.modulate.a = 0.0
		var wtween = get_tree().create_tween()
		wtween.tween_property($Winner, "modulate:a", 1.0, delay).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		$Winner/Label.text = "TIE"
		$Winner/Label.modulate.a = 1.0
	else:
		$Winner/WinnerImages.visible = true
		$Winner/WinnerImages/AnimationPlayer.play("Slide")
