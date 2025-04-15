shader_type canvas_item;

uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude_y = 50.0;
uniform float amplitude_x = 25.0;
uniform float inclination = 50.0;
uniform sampler2D noise;
uniform vec4 shadow_col : source_color;

vec2 get_distortion(vec2 uv){
	vec2 distortion = vec2(0.0);
	distortion.y = sin((uv.x - TIME * speed) * frequency_y) * amplitude_y * uv.x;
	distortion.x = cos((uv.y - TIME * speed) * frequency_x) * amplitude_x * uv.x;
	distortion.x += texture(noise, -vec2(speed * TIME) + uv * vec2(0.5, 0.4)).r * uv.x * 20.0;
	distortion.y += texture(noise, vec2(speed * TIME) + uv * vec2(0.5, 0.4)).r * uv.x * 20.0;
	return distortion;
}

void vertex() {
	vec2 distortion = get_distortion(UV);
	float inclination_v = inclination + 35.0 - 70.0*texture(noise, -vec2(speed * TIME) + UV).r;
	distortion.y += inclination_v * UV.x;
	VERTEX += distortion;
	VERTEX.x *= 1.0-(inclination_v/50.0);
}

void fragment(){
	float apply_shadow = float(get_distortion(UV).x > get_distortion(UV + vec2(0.01, 0.00)).y);
	COLOR = COLOR * (1.0-apply_shadow) + COLOR * shadow_col * apply_shadow;
}