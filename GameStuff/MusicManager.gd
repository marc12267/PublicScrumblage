extends Node

## Two players for crossfading
var player_a: AudioStreamPlayer
var player_b: AudioStreamPlayer

var active_player: AudioStreamPlayer
var inactive_player: AudioStreamPlayer

var current_track: AudioStream = null
var fade_tween: Tween = null


func _ready():
	player_a = AudioStreamPlayer.new()
	player_b = AudioStreamPlayer.new()

	add_child(player_a)
	add_child(player_b)

	player_a.bus = "Music"
	player_b.bus = "Music"

	player_a.volume_db = 0
	player_b.volume_db = -80

	active_player = player_a
	inactive_player = player_b



func play_music(track: AudioStream, fade_time: float = 1.0, loop: bool = true):
	if track == null:
		return

	if current_track == track and active_player.playing:
		return

	current_track = track

	inactive_player.stream = track
	inactive_player.volume_db = -80
	inactive_player.play()

	inactive_player.stream_paused = false
	inactive_player.stream.loop = loop

	if fade_tween != null:
		fade_tween.kill()

	fade_tween = create_tween()

	fade_tween.tween_property(active_player, "volume_db", -80, fade_time)
	fade_tween.tween_property(inactive_player, "volume_db", 0, fade_time)

	fade_tween.finished.connect(_swap_players)


func stop_music(fade_time: float = 1.0):
	if fade_tween != null:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(active_player, "volume_db", -80, fade_time)

	await fade_tween.finished
	active_player.stop()
	current_track = null


func pause_music():
	active_player.stream_paused = true


func resume_music():
	active_player.stream_paused = false


func is_playing() -> bool:
	return active_player.playing



func _swap_players():
	active_player.stop()

	var temp = active_player
	active_player = inactive_player
	inactive_player = temp
