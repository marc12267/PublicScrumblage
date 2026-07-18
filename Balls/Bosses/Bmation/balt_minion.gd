extends BehaviourScript
var active=false

func ability_start():
	await delay(randf())
	if active==false:
		SoundQueue.play("res://Balls/Bosses/Beta_alt/beta raor.wav",1.7,0.5)
	
		active=true
		
		sc.set_base_stat("Rotater.rotation_rate",12)

		sc.set_base_stat("Ball.velocity",850)
		

		
func ability_end():
	
	active=false
	sc.set_base_stat("Rotater.rotation_rate",3.5)
	
	sc.set_base_stat("Ball.velocity",200)
	
