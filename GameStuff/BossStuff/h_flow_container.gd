extends ScrollContainer

@export var slideLeft : bool = true

func _process(delta: float) -> void:
	var horizontalMovement
	if slideLeft == true:
		horizontalMovement = 100
		if scroll_horizontal >= $HBoxContainer/RichTextLabel.size.x:
			scroll_horizontal = 0
	else:
		horizontalMovement = -100
		if scroll_horizontal <= 0:
			scroll_horizontal = $HBoxContainer/RichTextLabel.size.x
	scroll_horizontal += 5 * horizontalMovement * delta
