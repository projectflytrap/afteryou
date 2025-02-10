shader_type canvas_item;

uniform float shrink_y : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float mody = (0.5-UV.y)*2.0;
	mody = 1.0 - abs(mody);
	COLOR.a *= float(mody > 1.0-shrink_y);
}