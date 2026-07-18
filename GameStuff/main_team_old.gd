extends VSBase

@export var team_1_res: Resource
@export var team_2_res: Resource

var team_1:TeamDuo
var team_2:TeamDuo

@onready var spawnpos_1a = $Spawnpos1a
@onready var spawnpos_1b = $Spawnpos1b
@onready var spawnpos_2a = $Spawnpos2a
@onready var spawnpos_2b = $Spawnpos2b

@onready var vs_spawn_1a = $VS/VsSpawn1a
@onready var vs_spawn_1b = $VS/VsSpawn1b
@onready var vs_spawn_2a = $VS/VsSpawn2a
@onready var vs_spawn_2b = $VS/VsSpawn2b

var p1a: Dictionary = {}
var p1b: Dictionary = {}
var p2a: Dictionary = {}
var p2b: Dictionary = {}
var team_duration=0.7

var TEAM = load("res://Sounds/TeamAudio/team.wav")



func winner_display():
	$VS/Left/FlameLeft/VS.visible = false

	SoundQueue.play("res://Sounds/victory-sound_130bpm_F_major.wav", 1, 0.7)
	
	await get_tree().create_timer(0.8).timeout
	EventManager.win_stinger()
	await get_tree().create_timer(2.65).timeout
	
	var nodes = get_tree().get_nodes_in_group("Main")
	var winner = get_winner(nodes)

	var delay = 0.85

	$Winner.visible = true
	$Winner.modulate.a = 0.0
	var wtween = get_tree().create_tween()
	wtween.tween_property($Winner, "modulate:a", 1.0, delay).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	Global.credit_scroller.emit()
	if winner == null:
		$Winner/Label.text = "TIE"
		audio_stream_player.stream = TIE
		audio_stream_player.play()

	elif is_p1_winner(winner):
		$VS/Left.visible = true

		quotes[0].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Left, "global_position", $VS/Left.global_position + Vector2(offsetter, 0), delay)

		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p1)

	elif is_p2_winner(winner):
		$VS/Right.visible = true

		quotes[1].fade_in()

		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property($VS/Right, "global_position", $VS/Right.global_position + Vector2(-offsetter, 0), delay)

		await get_tree().create_timer(1.1).timeout
		SoundQueue.play("res://Sounds/children-yay-sfx.wav", 1, 0.5)
		await get_tree().create_timer(1.5).timeout
		winner_audio(p2)
	
	await get_tree().create_timer(3.2).timeout
	Global.art_showcase.emit()





func _ready():
	
	Global.game_mode=Global.GAME_MODES.DUO
	EventManager.round_time=123
	hor_offseter+=75
	offseter+=15
	Global.team_fight = true
	team_1=team_1_res.instantiate()
	add_child(team_1)
	team_2=team_2_res.instantiate()
	add_child(team_2)
	
	TTS_WINS=load("res://Sounds/TeamAudio/wins.wav")
	VERSUS=load("res://Sounds/TeamAudio/versus.wav")
	TIE=load("res://Sounds/TeamAudio/tie.wav")
	
	
	$VS.visible = true
	$Winner.visible = false

	EventManager.won.connect(winner_display)

	setup_teams()
	setup_stats()
	
	var arts = get_tree().get_nodes_in_group("SplashArt")
	setup_splash_arts(arts)
	setup_names(arts)
	setup_quotes()

	await intro_sequence()

	EventManager.start_round()
	

func setup_quotes():
	quotes = get_tree().get_nodes_in_group("TeamWinQuote")
	
	for i in quotes:
		i.reparent(self)
	
	
	quotes[0].global_position = $WinQuoteRight.global_position

	quotes[1].global_position = $WinQuoteLeft.global_position
		
		
	
func winner_audio(p):
	
	audio_stream_player.stream = TEAM
	audio_stream_player.play()
	await get_tree().create_timer(team_duration).timeout
	audio_stream_player.stream = p["SFX_NAME"]
	audio_stream_player.play()

	await get_tree().create_timer(1.2).timeout

	audio_stream_player.stream = TTS_WINS
	audio_stream_player.play()

func intro_sequence():
	await get_tree().create_timer(0.2).timeout

	$Camera2D.add_quake(1.8)
	SoundQueue.play("res://Sounds/SSBINTRO.mp3", 0.76, 0.6)

	await get_tree().create_timer(1.16).timeout


	p1["SFX_NAME"] = team_1.team_audio
	p2["SFX_NAME"] = team_2.team_audio
	await sound_names(team_1.team_audio, team_2.team_audio)


	slide_out_and_back($VS/Left, $VS/Left.global_position + Vector2(-offsetter, 0))
	slide_out_and_back($VS/Right, $VS/Right.global_position + Vector2(offsetter, 0))


	sliding = true
	SoundQueue.play("res://Sounds/short-riser_125bpm.wav", 0.8, 0.8)

	await get_tree().create_timer(0.55).timeout
	sliding = false

	EventManager.start_music()

	await get_tree().create_timer(1.65).timeout
	
	
	
	
func sound_names(s1, s2):
	
	audio_stream_player.stream = TEAM
	audio_stream_player.play()
	await get_tree().create_timer(team_duration).timeout
	
	audio_stream_player.stream = s1
	audio_stream_player.play()

	await get_tree().create_timer(1.2).timeout

	audio_stream_player.stream = VERSUS
	audio_stream_player.play()

	await get_tree().create_timer(1).timeout

	audio_stream_player.stream = TEAM
	audio_stream_player.play()
	await get_tree().create_timer(team_duration).timeout
	audio_stream_player.stream = s2
	audio_stream_player.play()
	
	await get_tree().create_timer(1.1).timeout



func setup_teams():
	var b1a = team_1.ball1
	b1a.global_position = spawnpos_1a.global_position
	
	b1a.set_team(1)
	p1a["BALL"] = b1a

	var b1b = team_1.ball2
	b1b.global_position = spawnpos_1b.global_position

	b1b.set_team(1)
	p1b["BALL"] = b1b

	var b2a = team_2.ball1
	b2a.global_position = spawnpos_2a.global_position

	b2a.set_team(2)
	p2a["BALL"] = b2a

	var b2b = team_2.ball2
	b2b.global_position = spawnpos_2b.global_position
	
	b2b.set_team(2)
	p2b["BALL"] = b2b


func is_p1_winner(winner):
	return winner == p1a.get("BALL") or winner == p1b.get("BALL")

func is_p2_winner(winner):
	return winner == p2a.get("BALL") or winner == p2b.get("BALL")


func setup_splash_arts(arts):

	arts[0].reparent(flame_left)
	arts[1].reparent(flame_left)
	arts[2].reparent(flame_right)
	arts[3].reparent(flame_right)

	arts[0].rotation = -flame_left.rotation
	arts[1].rotation = -flame_left.rotation
	arts[2].rotation = -flame_right.rotation
	arts[3].rotation = -flame_right.rotation

	arts[0].global_position = vs_spawn_1a.global_position
	arts[1].global_position = vs_spawn_1b.global_position
	arts[2].global_position = vs_spawn_2a.global_position
	arts[3].global_position = vs_spawn_2b.global_position

	for art in arts:
		if art.alignment_chart:
			art.alignment_chart.queue_free()


func setup_names(arts):
	
	$VS/Left/SplashName.text = team_1.team_name.to_upper()

	$VS/Right/SplashName.text = team_2.team_name.to_upper()


func setup_stats():
	var counter := 0

	for i in get_tree().get_nodes_in_group("BStats"):
		i.get_node("DescriptionBox").visible = false

	for i in get_tree().get_nodes_in_group("BStats"):
		i.scale=Vector2(1,1)*1.1
		i.position = b_stat_marker.position + Vector2(
			(counter / 2) * hor_offseter,
			floor(counter % 2) * offseter
		)
		counter += 1
