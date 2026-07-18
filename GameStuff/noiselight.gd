extends PointLight2D

func _process(delta):
	texture.noise.offset.y += 25*delta
