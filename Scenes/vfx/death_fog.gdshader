shader_type canvas_item;

uniform int OCTAVE = 6;
uniform sampler2D tiling_noise;
uniform vec2 scale_noise = vec2(1.0, 0.2);
uniform float time_scale = 0.1;
uniform sampler2D opacity_curve;
uniform sampler2D color_curve;

float rand(vec2 input){
	return fract(sin(dot(input,vec2(23.53,44.0)))*42350.45);
}

float perlin(vec2 input){
	vec2 i = floor(input);
	vec2 j = fract(input);
	vec2 coord = smoothstep(0.,1.,j);
	
	float a = rand(i);
	float b = rand(i+vec2(1.0,0.0));
	float c = rand(i+vec2(0.0,1.0));
	float d = rand(i+vec2(1.0,1.0));

	return mix(mix(a,b,coord.x),mix(c,d,coord.x),coord.y);
}

float fbm(vec2 input){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < OCTAVE; i++){
		value += perlin(input)*scale;
		input*=2.0;
		scale*=0.5;
	}
	return value;
}

void fragment() {
	vec2 centerUV = UV*2.0-vec2(1.0);
	vec2 circUV = vec2(mod(atan(centerUV.y, centerUV.x)+TAU, TAU)/TAU, length(centerUV));
	float val = texture(tiling_noise, fract(circUV * scale_noise - TIME * time_scale * vec2(1.0, 1.0)+ fbm(UV + TIME * vec2(0.1, 0.2) + 0.2*fbm(TIME * -0.03 + UV)))).r;
	val *= texture(opacity_curve, vec2(circUV.y)).r;
	val = clamp(val, 0.0, 1.0);
	COLOR = texture(color_curve, vec2(val));
}

