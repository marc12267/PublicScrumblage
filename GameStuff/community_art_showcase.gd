extends CanvasLayer

@export var active:bool=true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible=true
	$Control.modulate.a =0.0
	
func display():
	if !active:
		return
	var tween =create_tween()
	tween.tween_property($Control,"modulate:a",1.0,1)
	$GPUParticles2D.emitting=true
	SoundQueue.play("res://Sounds/fettisfx.wav")
