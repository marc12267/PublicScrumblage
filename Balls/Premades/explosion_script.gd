extends BehaviourScript
@onready var danger_zone = $"../DangerZone"
@onready var animation_player: AnimationPlayer = $"../DangerZone/Boom/AnimationPlayer"
##EXPLOSIONS SPAWNED AS A SEPARATE ENTITY SO THAT IT CAN PERSIST
##AFTER SPAWNER'S DEATH

func _ready():
	await get_tree().physics_frame
	danger_zone.detect_tick()
	animation_player.play("Boom")
	await animation_player.animation_finished
	ball.queue_free()
