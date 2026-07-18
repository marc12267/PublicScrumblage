extends StatusEffect
var delay=1.0

@export var rank_root:Node2D
@onready var rank_s = $RankRoot/Holder/RankS
@onready var rank_a = $RankRoot/Holder/RankA
@onready var rank_b = $RankRoot/Holder/RankB
@onready var rank_c = $RankRoot/Holder/RankC
@onready var rank_d = $RankRoot/Holder/RankD

signal set_level
var current_rank = 1
var progress:float=0.0
var bump_tween:Tween
@onready var holder = $RankRoot/Holder
var resetter :float=35
var combo_extend=0.0
var combo_length=0.12

func gain_progress(value):
	#print(value)
	value-=(0.85*value*pow((current_rank)/5.0,2))
	#print(value)
	
	combo_extend=combo_length
	progress=min(progress+value,100)
	if current_rank<5 and progress>=100:
		current_rank+=1
		progress=resetter
		update_rank_symbol()
		rank_up_sound()
	update_ranks_visuals()
	baller.data_transfer.emit({"ID":"UPDATE_COMBO","RANK":current_rank})
	
	if bump_tween:
		bump_tween.kill()
	bump_tween=create_tween()
	bump_tween.tween_property(holder,"scale",Vector2(1,1)*1.3,0.08)
	bump_tween.tween_property(holder,"scale",Vector2(1,1),0.16)

func hurted(val):
	combo_extend=0.0
	lose_progress(val)

func lose_progress(value):
	progress-=value
	if progress<=0.0:
		if current_rank > 1:
			current_rank-=1
			
			combo_extend=combo_length
			progress=resetter
			update_rank_symbol()
		else:
			delete()
			return
	update_ranks_visuals()
	baller.data_transfer.emit({"ID":"UPDATE_COMBO","RANK":current_rank})

func rank_up_sound():
	match current_rank:
		1:
			SoundQueue.play("res://Balls/Effects/Combo/demonic.mp3")
			PopUpManager.pop_text("DEMONIC",baller.global_position)
		2:
			SoundQueue.play("res://Balls/Effects/Combo/cathartic.mp3")
			PopUpManager.pop_text("CATHARTIC",baller.global_position)
		3:
			SoundQueue.play("res://Balls/Effects/Combo/BLOODY.mp3")
			PopUpManager.pop_text("BLOODY!",baller.global_position)
		4:
			SoundQueue.play("res://Balls/Effects/Combo/APOCALYTIC.mp3")
			PopUpManager.pop_text("APOCALYPTIC!!",baller.global_position)
		5:
			SoundQueue.play("res://Balls/Effects/Combo/SACRILEGIOUS.mp3")
			PopUpManager.pop_text("SACRILEGIOUS!!!",baller.global_position)
			
func update_rank_symbol():
	match current_rank:
		1:
			rank_d.visible=true
			
			rank_s.visible=false
			rank_a.visible=false
			rank_b.visible=false
			rank_c.visible=false
		2:
			rank_c.visible=true
			
			rank_s.visible=false
			rank_a.visible=false
			rank_b.visible=false
			rank_d.visible=false
		3:
			rank_b.visible=true
			
			rank_s.visible=false
			rank_a.visible=false
			rank_c.visible=false
			rank_d.visible=false
		4:
			rank_a.visible=true
			
			rank_s.visible=false
			rank_b.visible=false
			rank_c.visible=false
			rank_d.visible=false
		5:
			rank_s.visible=true
			
			rank_a.visible=false
			rank_b.visible=false
			rank_c.visible=false
			rank_d.visible=false

func update_ranks_visuals():
	
	rank_s.value=progress
	rank_a.value=progress
	rank_b.value=progress
	rank_c.value=progress
	rank_d.value=progress


func set_target(ball,value,data):
	baller=ball
	#print(ball)
	super(ball,value,data)
	gain_progress(max(value,resetter))
	update_rank_symbol()

func update(value,data):
	gain_progress(value)
	return self
	
func _physics_process(delta):
	if baller==null:
		return
	if baller.freezed:
		return
	if combo_extend > 0.0:
		combo_extend=max(0.0,combo_extend-delta)
		return
	
	lose_progress((0.5+30*pow(current_rank/5.0,1.8))*delta)

func _process(delta):
	
	if baller!=null and is_instance_valid(baller):
		rank_root.global_position=baller.global_position
