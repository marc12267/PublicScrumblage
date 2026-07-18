extends Sprite2D
var looper=0.0

func _process(delta):
	looper += delta

	if looper >= 1.0 / 30.0:
		looper -= 1.0 / 30.0

		if frame >= hframes * vframes-1:
			frame = 0
		else:
			
			frame += 1
