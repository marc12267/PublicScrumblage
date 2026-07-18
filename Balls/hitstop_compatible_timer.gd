## Automatically pauses while HitstopManager.hitstopped is true.
class_name HitstopTimer
extends Timer

var _time_left_cached: float = 0.0
var _was_paused_by_hitstop: bool = false


func _process(delta: float) -> void:
	_handle_hitstop()


func _handle_hitstop() -> void:
	if not is_inside_tree():
		return

	if HitstopManager.hitstopped and not paused:
		paused = true
		_was_paused_by_hitstop = true

	elif not HitstopManager.hitstopped and paused and _was_paused_by_hitstop:
		paused = false
		_was_paused_by_hitstop = false
