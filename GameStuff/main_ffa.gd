extends "res://GameStuff/main.gd"

@export var ball3_res: Resource
@export var ball4_res: Resource

@onready var spawnpos_3 = $Spawnpos1b
@onready var spawnpos_4 = $Spawnpos2b

@onready var vs_spawn_3 = $VS/VsSpawn1b
@onready var vs_spawn_4 = $VS/VsSpawn2b

@onready var flame_left2 = $VS/LeftLower/FlameLeft
@onready var flame_right2 = $VS/RightUp/FlameRight

var p3: Dictionary = {}
var p4: Dictionary = {}

func _ready():
	
	await loop_pause()
	Global.game_mode=Global.GAME_MODES.FFA
	Global.team_fight = true
	
	EventManager.round_time=123
	
	$VS.visible = true

	EventManager.won.connect(winner_display)

	setup_players()
	setup_stats()
	
	var arts = get_tree().get_nodes_in_group("SplashArt")
	setup_splash_arts(arts)
	setup_names(arts)
	setup_quotes()

	await intro_sequence()
	EventManager.start_round()


		
		
func setup_players():
	if ball1_res:
		var b1 = ball1_res.instantiate()
		b1.global_position = spawnpos_1.global_position
		add_child(b1)
		b1.set_team(1)
		p1["BALL"] = b1

	if ball2_res:
		var b2 = ball2_res.instantiate()
		b2.global_position = spawnpos_2.global_position
		add_child(b2)
		b2.set_team(3)
		p2["BALL"] = b2
	
	if ball3_res:
		var b3 = ball3_res.instantiate()
		b3.global_position = spawnpos_3.global_position
		add_child(b3)
		b3.set_team(4)
		p3["BALL"] = b3
	
	if ball4_res:
		var b4 = ball4_res.instantiate()
		b4.global_position = spawnpos_4.global_position
		add_child(b4)
		b4.set_team(2)
		p4["BALL"] = b4


func setup_stats():
	var counter := 0

	for i in get_tree().get_nodes_in_group("BStats"):
		i.box.get_node("DescriptionBox").visible = false
		
	var bstatlist = get_tree().get_nodes_in_group("BStats")
	
	%BStatMarker.set_target(bstatlist[0].box)
	%BStatMarker2.set_target(bstatlist[1].box)
	%BStatMarker3.set_target(bstatlist[2].box)
	%BStatMarker4.set_target(bstatlist[3].box)

func setup_splash_arts(arts):
	if arts.size() < 2:
		return
	arts[0].reparent(flame_left)
	arts[1].reparent(flame_left2)
	arts[2].reparent(flame_right2)
	arts[3].reparent(flame_right)

	arts[0].rotation = -flame_left.rotation
	arts[1].rotation = -flame_right.rotation
	arts[2].rotation = -flame_left.rotation
	arts[3].rotation = -flame_right.rotation

	arts[0].global_position = vs_spawn_1.global_position
	arts[1].global_position = vs_spawn_2.global_position
	arts[2].global_position = vs_spawn_3.global_position
	arts[3].global_position = vs_spawn_4.global_position
	
	
	for art in arts:
		if art.alignment_chart:
			art.alignment_chart.queue_free()

func setup_names(arts):
	return


func setup_quotes():
	quotes = get_tree().get_nodes_in_group("WinQuote")
	
	if quotes.size() >= 2:
		quotes[0].global_position = $WinQuoteRight.global_position
		quotes[1].global_position = $WinQuoteRightDown.global_position
		quotes[2].global_position = $WinQuoteLeft.global_position
		quotes[3].global_position = $WinQuoteLeftDown.global_position

func intro_sequence():
	await get_tree().create_timer(0.2).timeout

	Global.quake_trigger.emit(1.8)
	SoundQueue.play("res://Sounds/SSBINTRO.mp3", 0.76, 0.6)

	await get_tree().create_timer(1.16).timeout
	

	var arts = get_tree().get_nodes_in_group("SplashArt")
	
	p1["SFX_NAME"] = arts[0].name_sound
	p2["SFX_NAME"] = arts[1].name_sound
	p3["SFX_NAME"] = arts[3].name_sound
	p4["SFX_NAME"] = arts[2].name_sound

	await sound_names()
	slide_out_and_back($VS/Left, $VS/Left.global_position + Vector2(-offsetter,0))
	slide_out_and_back($VS/LeftLower, $VS/LeftLower.global_position + Vector2(0,offsetter))
	slide_out_and_back($VS/Right, $VS/Right.global_position + Vector2(offsetter,0))
	slide_out_and_back($VS/RightUp, $VS/RightUp.global_position + Vector2(0,-offsetter))
	

	sliding = true
	SoundQueue.play("res://Sounds/short-riser_125bpm.wav", 0.8, 0.8)

	await get_tree().create_timer(0.55).timeout
	sliding = false

	EventManager.start_music()

	await get_tree().create_timer(1.65).timeout


func winner_display():
	$VS/Left/FlameLeft/VS.visible = false

	SoundQueue.play("res://Sounds/victory-sound_130bpm_F_major.wav", 1, 0.7)
	
	await get_tree().create_timer(0.8).timeout
	EventManager.win_stinger()
	await get_tree().create_timer(2.65).timeout
	var nodes = get_tree().get_nodes_in_group("Main")
	var winner = get_winner(nodes)

	var delay = 0.85

	vs.winner_display(winner)
	if winner == null:
		audio_stream_player.stream = TIE
		audio_stream_player.play()

	elif winner == p1.get("BALL"):
		$VS/Left.visible = true

		if quotes.size() > 0:
			quotes[0].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Left, "global_position", $VS/Left.global_position + Vector2(offsetter, 0), delay)
	
		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p1)

	elif winner == p2.get("BALL"):
		$VS/LeftLower.visible = true

		if quotes.size() > 1:
			quotes[1].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/LeftLower, "global_position", $VS/LeftLower.global_position + Vector2(0,-offsetter), delay)
		
		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p2)
	
	elif winner == p3.get("BALL"):
		$VS/RightUp.visible = true

		if quotes.size() > 1:
			quotes[2].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/RightUp, "global_position", $VS/RightUp.global_position + Vector2(0, offsetter), delay)
		
		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p3)
	
	elif winner == p4.get("BALL"):
		$VS/Right.visible = true

		if quotes.size() > 1:
			quotes[3].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Right, "global_position", $VS/Right.global_position + Vector2(-offsetter,0), delay)
		
		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p4)
	
	await get_tree().create_timer(2.7).timeout
	Global.art_showcase.emit()


func get_winner(nodes):
	if nodes.is_empty():
		return null
	return nodes.front()



func winner_audio(p):
	print(p)
	
	audio_stream_player.stream = p["SFX_NAME"]
	audio_stream_player.play()

	await get_tree().create_timer(1).timeout

	audio_stream_player.stream = TTS_WINS
	audio_stream_player.play()


func sound_names():
	#audio_stream_player.stream = p1["SFX_NAME"]
	#audio_stream_player.play()
	#await get_tree().create_timer(1).timeout
	#audio_stream_player.stream = VERSUS
	#audio_stream_player.play()
	#await get_tree().create_timer(0.8).timeout
	#
	#audio_stream_player.stream = p2["SFX_NAME"]
	#audio_stream_player.play()
	#await get_tree().create_timer(1).timeout
	#audio_stream_player.stream = VERSUS
	#audio_stream_player.play()
	#await get_tree().create_timer(0.8).timeout
	#
	#audio_stream_player.stream = p3["SFX_NAME"]
	#audio_stream_player.play()
	#await get_tree().create_timer(1).timeout
	#audio_stream_player.stream = VERSUS
	#audio_stream_player.play()
	#await get_tree().create_timer(0.8).timeout
	#
	#audio_stream_player.stream = p4["SFX_NAME"]
	#audio_stream_player.play()
	#await get_tree().create_timer(1.1).timeout
	
	await get_tree().create_timer(0.4).timeout
	audio_stream_player.stream = FFA
	audio_stream_player.play()
	await get_tree().create_timer(1.8).timeout
const FFA = preload("uid://dnq054dwobmnj")


	
func _process(delta):
	
	if !sliding:
		return
	Global.quake_trigger.emit(3)


func slide_out_and_back(node, target: Vector2):
	node.visible = true

	var tween = get_tree().create_tween()
	tween.tween_interval(0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(node, "global_position", target, 0.65)
	tween.tween_callback(func(): node.visible = false)
