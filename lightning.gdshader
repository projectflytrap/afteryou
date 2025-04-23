shader_type canvas_item;

render_mode blend_add;

uniform sampler2D scroll_texture : filter_nearest;
uniform sampler2D erosion : filter_nearest;

uniform sampler2D color_gradient;
uniform sampler2D fade_gradient;
uniform float xAdd = 0.0;
uniform vec2 stretch = vec2(1.0);
uniform float speed = 1.0;
uniform float dissipation : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 stretchUV = (UV + vec2(xAdd + TIME * speed,0.0)) * stretch;
	float val = texture(scroll_texture, mod(stretchUV, vec2(1.0))).r;
	//float old_val = val;
	//val = 1.0 - val;
	//val *= dissipation;
	//val = old_val - val;
	val = val * (1.0 - dissipation) + val * dissipation * texture(erosion, mod(UV * vec2(0.3, 0.2) - 0.7 * TIME * speed, vec2(1.0))).r;
	COLOR = texture(color_gradient, vec2(val,0.5));
	COLOR.a *= texture(fade_gradient, UV).r;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
