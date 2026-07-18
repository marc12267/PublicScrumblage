class_name VSBase
extends Node2D
## IF TRUE, PAUSES GAME FROM RUNNING AUTOMATICALLY
## TOOL TO HELP WITH RECORDING STUFF
@export var space_to_play:bool=false
@export var ball1_res: Resource
@export var ball2_res: Resource

@onready var spawnpos_1 = $Spawnpos1
@onready var spawnpos_2 = $Spawnpos2


@onready var vs_spawn_1 = $VS/VsSpawn1
@onready var vs_spawn_2 = $VS/VsSpawn2

@onready var audio_stream_player = $VS/AudioStreamPlayer
@onready var flame_left = $VS/Left/FlameLeft
@onready var flame_right = $VS/Right/FlameRight

var VERSUS = preload("uid://ckm5fu7oe6brp")
var TTS_WINS = preload("uid://d0xydcb1x07ug")
var TIE = preload("uid://bw808d18mlm0")

var sliding := false

var offsetter := 1000

var quotes = []

var p1: Dictionary = {}
var p2: Dictionary = {}

func loop_pause():
	if space_to_play:
		var loop = true
		while loop:
			await get_tree().create_timer(0.1).timeout
			if Input.is_key_pressed(KEY_SPACE):
				loop=false

func _ready():
	await loop_pause()
	Global.game_mode=Global.GAME_MODES.ONEVONE
	$VS.visible = true
	$Winner.visible = false

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
	if ball1_res==ball2_res:
		Global.team_fight=true
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
		b2.set_team(2)
		p2["BALL"] = b2
	
	

@onready var arena: Node2D = $Arena
func setup_stats():

	var bstatlist = get_tree().get_nodes_in_group("BStats")
	
	%BStatMarker.set_target(bstatlist[0].box)
	%BStatMarker2.set_target(bstatlist[1].box)


func setup_splash_arts(arts):
	if arts.size() < 2:
		return

	arts[0].reparent(flame_left)
	arts[1].reparent(flame_right)

	arts[0].rotation = -flame_left.rotation
	arts[1].rotation = -flame_right.rotation

	arts[0].global_position = vs_spawn_1.global_position
	arts[1].global_position = vs_spawn_2.global_position

	if arts[0].alignment_chart:
		arts[0].alignment_chart.global_position = $VS/Left/ACMarker.global_position
	if arts[1].alignment_chart:
		arts[1].alignment_chart.global_position = $VS/Right/ACMarker.global_position


func setup_names(arts):
	if arts.size() < 2:
		return

	$VS/Left/SplashName.text = arts[0].name_text.to_upper()
	$VS/Right/SplashName.text = arts[1].name_text.to_upper()


func setup_quotes():
	quotes = get_tree().get_nodes_in_group("WinQuote")

	if quotes.size() >= 2:
		quotes[0].global_position = $WinQuoteRight.global_position
		#quotes[0].right_win.visible = false

		quotes[1].global_position = $WinQuoteLeft.global_position
		#quotes[1].left_win.visible = false


func intro_sequence():
	await get_tree().create_timer(0.2).timeout
	Global.quake_trigger.emit(1.8)
	SoundQueue.play("res://Sounds/SSBINTRO.mp3", 0.76, 0.6)

	await get_tree().create_timer(1.16).timeout


	var arts = get_tree().get_nodes_in_group("SplashArt")
	
	if arts[0].alignment_chart:
		arts[0].alignment_chart.visual_effect()
	if arts[1].alignment_chart:
		arts[1].alignment_chart.visual_effect()
		
	if arts.size() >= 2:
		p1["SFX_NAME"] = arts[0].name_sound
		p2["SFX_NAME"] = arts[1].name_sound
		await sound_names()



	slide_out_and_back($VS/Left, $VS/Left.global_position + Vector2(-offsetter, 0))
	slide_out_and_back($VS/Right, $VS/Right.global_position + Vector2(offsetter, 0))
	

	sliding = true
	SoundQueue.play("res://Sounds/short-riser_125bpm.wav", 0.8, 0.8)

	await get_tree().create_timer(0.55).timeout
	sliding = false
	EventManager.start_music()

	await get_tree().create_timer(1.65).timeout

@onready var vs: CanvasLayer = $VS

func winner_display():
	
	var arts = get_tree().get_nodes_in_group("SplashArt")
	if arts[0].alignment_chart:
		arts[0].alignment_chart.visible=false
	if arts[1].alignment_chart:
		arts[1].alignment_chart.visible=false
	
	
	$VS/Right/FlameRight/VS.visible = false
	$VS/Left/FlameLeft/VS.visible = false
#
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

	elif is_p1_winner(winner):
		$VS/Left.visible = true

		if quotes.size() > 0:
			quotes[0].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Left, "global_position", $VS/Left.global_position + Vector2(offsetter, 0), delay)
	
		await get_tree().create_timer(1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p1)

	elif is_p2_winner(winner):
		$VS/Right.visible = true

		if quotes.size() > 1:
			quotes[1].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Right, "global_position", $VS/Right.global_position + Vector2(-offsetter, 0), delay)
		
		await get_tree().create_timer(1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p2)
	
	
	
	await get_tree().create_timer(2.4).timeout
	Global.art_showcase.emit()


func get_winner(nodes):
	if nodes.is_empty():
		return null
	return nodes.front()

func is_p1_winner(winner):
	return winner == p1.get("BALL")

func is_p2_winner(winner):
	return winner == p2.get("BALL")


func winner_audio(p):
	
	audio_stream_player.stream = p["SFX_NAME"]
	audio_stream_player.play()

	await get_tree().create_timer(1).timeout

	audio_stream_player.stream = TTS_WINS
	audio_stream_player.play()


func sound_names():
	audio_stream_player.stream = p1["SFX_NAME"]
	audio_stream_player.play()

	await get_tree().create_timer(1).timeout

	audio_stream_player.stream = VERSUS
	audio_stream_player.play()

	await get_tree().create_timer(1).timeout

	audio_stream_player.stream = p2["SFX_NAME"]
	audio_stream_player.play()
	
	await get_tree().create_timer(1).timeout


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
