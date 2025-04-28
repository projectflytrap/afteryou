shader_type canvas_item;

uniform sampler2D noise;
uniform sampler2D text;
uniform vec2 stretch = vec2(1.0);
uniform vec2 stretch2 = vec2(1.0);
uniform float xAdd = 0.0;
uniform float xAdd2 = 0.0;
uniform vec2 randPos = vec2(0.0);
uniform float vanishSpeed = 2.0;
uniform float scrollSpeed = 1.0;
uniform sampler2D colRamp;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform float extend : hint_range(0.0, 1.0) = 1.0;

float stepify(float value, float steps){
	return ceil(value*steps)/steps;
}

void fragment() {
	vec2 stretchUV = (UV + vec2(xAdd-vanishSpeed * TIME,0.0) + randPos) * stretch;
	vec2 sampleUV = (UV + vec2(xAdd2-scrollSpeed*TIME,0.0) + randPos) * stretch2;
	float faded = texture(noise, fract(stretchUV)).r;
	float t = texture(text, fract(sampleUV)).r;
	t = clamp(t + (1.0 - pow(UV.x, 0.3)) * (1.0-pow(2.0 * abs(UV.y-0.5), 1.0)), 0.0, 1.0);
	faded = (1.0-pow(UV.x, 1.9 * extend)) - pow(1.0-faded, 3.0);
	float val = t*faded;
	vec4 colMap = texture(colRamp, vec2(val, 0.5));
	COLOR.rgb = colMap.rgb;
	COLOR.a = opacity*clamp(stepify((val * colMap.a -0.09)* 2.0, 3.0), 0.0, 1.0);
	//COLOR.a = opacity*clamp(val * colMap.a -0.09, 0.0, 1.0);
}
