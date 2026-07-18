shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.5;
uniform float speed;

void fragment () {
	COLOR = (texture(TEXTURE, vec2(UV.x + TIME * speed, UV.y))) * darkness;
}