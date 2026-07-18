extends CPUParticles2D

func _ready() -> void:
	emitting=true
	get_parent().finished.connect(func(): emitting = false)
