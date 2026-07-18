extends TextureProgressBar



const UI_TOOTH_EMPTY = preload("uid://dgwoqivlalqn2")
const UI_TOOTH = preload("uid://ddo4uiwafpk68")

var can_warp : bool = false

func _ready() -> void:
	%warpCheckTimer.timeout.connect(make_tooth_appear)
	%HonesScript.critController.connect(tooth_appearance)
	%ToothFull.visible = false

func make_tooth_appear():
	if can_warp:
		%ToothFull.visible = true
		%ToothParticles.emitting = true
	else:
		%ToothFull.visible = false
		%ToothParticles.emitting = false

func tooth_appearance(newbool : bool):
	if !newbool:
		%ToothFull.visible = false
		%ToothParticles.emitting = false
	else:
		%ToothFull.visible = true
		%ToothParticles.emitting = true

func _process(delta: float) -> void:
	if !%warpCheckTimer:
		return
	var fill_ratio = 1.0 - (%warpCheckTimer.time_left / %warpCheckTimer.wait_time)
	
	value = fill_ratio * max_value
	
	#if meter_manager.meter < 25:
		#texture_progress = UI_TOOTH_EMPTY
		#can_warp = false
	#else:
		#can_warp = true
		#texture_progress = UI_TOOTH
