extends GPUParticles2D

@export var bscript:BehaviourScript
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bscript.activated_fist.connect(toggle.bind(true))
	bscript.deactivated_fist.connect(toggle.bind(false))

func toggle(truefalse):
	if bscript.ball.skin=="Summer":
		emitting=truefalse
		$Grass.emitting=truefalse
