extends BehaviourScript
# this is just to show what the differences between a boss and normal ball is

const BEANDOG_POOPY = preload("uid://bvmj6bumu5gku")
const BEANDOG_SUPERPOOPY = preload("uid://crd0s4rdwbf0v")

@onready var spawn_animation: AnimationPlayer = $"../SpawnAnimation"

# make sure the following signals and variable are named exactly this. but its okay if they dont have these
# raid mode is coded in a way that you can actually place normal ball characters into the boss res
# but if you want a special intro or a way to shake a camera be sure to use these.
signal intro_finished # lets the gamemode know when to start the round
signal banner_finished
signal shake_camera(amount : float) # shakes the camera

@export var hasIntro : bool = true # the main raid gd checks to see if this variable exists and if it's true or not
# you can turn this off to skip the intro
@onready var contact_damager: Node = $"../ContactDamager"

func _ready():
	super()
	EventManager.won.connect(upd8)
	if !hasIntro || Global.game_mode != 1: # to skip intro
		ball.visible = true

	$Looper.trigger.connect(poop)
	contact_damager.local_hit.connect(edit_damage)

func edit_damage(data):
	var victim = data["VICTIM"]
	if StatusEffectManager.get_effects(victim).has("STINKY"):
		data["CRIT_CHANCE"]=1
		data["DAMAGE"]=10
	EventManager.hit.emit(data)
	return
@onready var after_imager: Node = $AfterImager

var zoomy_check:bool=false
func start_zoomies():
	default.set_visual("Zoomy")
	sc.set_base_stat("Ball.velocity",1300+900*(1.0-health_manager.health_scale()))
	sc.set_base_stat("Ball.dodge_rate",0.5 + 0.35*(1.0-health_manager.health_scale()))
	after_imager.active=true
	zoomy_check=true
	
	await delay(5)
	end_zoomies()

func end_zoomies():
	zoomy_check=false
	default.set_visual("Default")
	sc.set_base_stat("Ball.velocity",750)
	sc.set_base_stat("Ball.dodge_rate",0)
	after_imager.active=false

	
@onready var default: Node2D = $"../Visuals/Default"

func poop():
	if zoomy_check:
		return
	sc.set_base_stat("Ball.velocity",400)
	sc.set_base_stat("Ball.normalizer_speed_down",400)
	
	default.set_visual("Poopy")
	SoundQueue.play("res://Balls/Bosses/BeanDog/bark-fart-sfx_144bpm.wav",1,0.7)
	await delay(0.5)
	sc.set_base_stat("Ball.normalizer_speed_down",20)
	
	default.set_visual("Default")
	sc.set_base_stat("Ball.velocity",750)
	if randf()<0.05 + 0.65 * (1.0-pow(health_manager.health_scale(),0.7)):
		spawn_thing(BEANDOG_SUPERPOOPY)
	else:
		spawn_thing(BEANDOG_POOPY)
	start_zoomies()
	
	
	
	# if anything is set to be invisible for your spawn animation MAKE SURE to set them to visible if the hasIntro is set to false
	# or if the gamemode is different. atm since raidmode just reuses teammode, you'll need to turn off hasIntro for 2v2
@onready var beta_spawn_animation = $"../SpawnAnimationAssets/SpawnAnimation"
@onready var health_manager: HealthManager = $"../HealthManager"

func start_intro(): # plays the animation
	print('intro playing')
	beta_spawn_animation.play('spawn_animation')
	await beta_spawn_animation.animation_finished
	intro_finished.emit() # waits for the animation to finish before beginning the round
	

@onready var description: RichTextLabel = $"../StatsUI/BossDisplay/Box/DescriptionBox/Description"
@onready var description_2: RichTextLabel = $"../StatsUI/BossDisplay/Box/DescriptionBox/Description2"


func upd8():
	return
	
@onready var texture_rect: TextureRect = $"../StatsUI/BallStatDisplay/VsSplash/SPLASHART/TextureRect"

@onready var name_label: Label = $"../StatsUI/BossDisplay/Box/BattleBar/Name"
@onready var icon_abel: TextureRect = $"../StatsUI/BossDisplay/Box/BattleBar/Icon"

func camera_shake(amount : float):
	shake_camera.emit(amount)


	
	
	
	
# USE THE FOLLOWING IF YOU WANT TO HAVE A CUSTOM ARENA
#var arena_size=1.0
#var new_arena_size = 1.0
#
#func shrink_arena(target_size):
	#new_arena_size = target_size
#
#func _process(delta): #replace the $".. with whatever node holds your arena!
	#arena_size = lerpf(arena_size, new_arena_size, 0.5 * delta)
	#$"../DarkWorld/Control".scale = arena_size * Vector2(1,1) 
