extends Node2D

@onready var damage_number_scene=load("res://GameStuff/pop_up_effect.tscn")
@onready var image_scene=load("res://GameStuff/pop_up_image.tscn")


func pop_text(str: String, world_pos: Vector2):
	world_pos.y-=30
	var text_pop = damage_number_scene.instantiate()
	text_pop.global_position = world_pos
	add_child(text_pop)
	
	text_pop.set_text(str)
	text_pop.animate()
	return text_pop
	
	
	
func damage_number(amount, world_pos: Vector2, type :String= ""):
	var float_check= amount<1.0
	
	if amount != floor(amount):
		amount=int(amount*10)/10.0
	else:
		amount = int(amount)
	
	world_pos.y-=30
	var text_pop = damage_number_scene.instantiate()
	text_pop.global_position = world_pos
	add_child(text_pop)
	
	var string = str(amount)
	if float_check:
		string=string.erase(0,1)
		
	text_pop.set_text(string)
	if type=="CRIT":
		text_pop.modulate= Color.RED
		text_pop.scale=Vector2(1,1)*1.5
		text_pop.fade_scale=1.3
	elif type =="REDUCED":
		text_pop.modulate= Color.SKY_BLUE
		text_pop.scale=Vector2(1,1)*0.8
		text_pop.fade_scale=1.3
	elif type == "AMPLIFIED":
		text_pop.modulate= Color.ORANGE
		text_pop.scale=Vector2(1,1)*0.8
		text_pop.fade_scale=1.3
	text_pop.animate()
	return text_pop

func emote_effect(ball:BallBodyBase,resource,offset:float=100):
	var image_pop = image_scene.instantiate()
	image_pop.set_image(resource)
	image_pop.set_offset(offset)
	
	ball.add_child(image_pop)
	image_pop.position=Vector2.ZERO
	image_pop.emote()
	return image_pop
	
func image_effect(resource):
	var image_pop = image_scene.instantiate()
	image_pop.set_image(resource)
	image_pop.emote()
	return image_pop
	
