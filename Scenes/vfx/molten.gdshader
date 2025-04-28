shader_type canvas_item;

uniform float sections = 5.0;
uniform float timeScale = 0.03;
uniform sampler2D noise1;
uniform float pow1 : hint_range(0.0, 2.0) = 1.0;
uniform float roundness : hint_range(0.0, 1.0) = 1.0;
uniform float width : hint_range(-0.5, 1.0) = 1.0;
uniform sampler2D moltenGroundLUT;
uniform float maxWidth : hint_range(0.0, 1.0) = 1.0;
uniform vec4 ground : source_color;
uniform float alpha : hint_range(0.0, 1.0) = 0.7;
uniform float moltenAlpha : hint_range(0.0, 1.0) = 0.2;


float rand(vec2 input){
	return fract(sin(dot(input,vec2(23.53,44.0)))*23578.547);
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
	float value = perlin(input)*0.66;
	return value + perlin(input * 2.0)*0.34;
}

vec2 n22(vec2 p){
	vec3 a = fract(p.xyx*vec3(123.34,234.34,345.65));
	a+=dot(a, a+34.45);
	return fract(vec2(a.x*a.y,a.y*a.z));
}

vec2 rand_vec2(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec2 voronoi(vec2 uv){
	vec2 st = uv*sections;
	vec2 i_st = floor(st);
    vec2 f_st = fract(st);
	vec2 m_dist = vec2(8.0);
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			// Neighbor place in the grid
			vec2 neighbor = vec2(float(x),float(y));
			// Random position from current + neighbor place in the grid
			vec2 point = rand_vec2(i_st + neighbor);
			point = texture(noise1, fract(point+TIME*timeScale)).xy;
			point = smoothstep(vec2(0.0), vec2(1.0), point);
			point = smoothstep(vec2(0.0), vec2(1.0), point);
			vec2 diff = neighbor + point - f_st;
			float dist = dot(diff, diff);
			if(dist < m_dist.x){
				m_dist.y = m_dist.x;
				m_dist.x = dist;
			} else if (dist < m_dist.y){
				m_dist.y = dist;
			}
			
		}
	}
	m_dist = pow(m_dist, vec2(roundness));
	return m_dist;
}

float getBorder(vec2 p, float widthMod){
	float dis = p.y - p.x;
	return step(1.0-dis, max(maxWidth,width+widthMod));
}

float getBorder2(vec2 p, float widthMod){
	float dis = p.y - p.x;
	return max(0.0,0.4*dis+2.0*widthMod-2.0);
}


void fragment() {
	vec2 v = voronoi(UV);
	float dist = 2.0*length(UV-0.5);
	float b = getBorder(v, pow(dist, pow1));
	vec2 fbmM = vec2(fbm(vec2(TIME*0.4 + 4.0*UV.x, -TIME*0.6-5.0*UV.y)),fbm(3.0*UV+vec2(-TIME*0.3, TIME*0.4)));
	float fbmBomb = fbm(12.0*UV + TIME * 0.2 - fbmM);
	vec4 molten = texture(moltenGroundLUT, vec2(fract(fbmBomb),dist),1.0);
	COLOR.rgb = molten.rgb*(1.0-b);
	COLOR.rgb += (b*ground).rgb;
	COLOR.a = min(1.0,step(dist+getBorder2(v, pow(dist, pow1)), 1.0)*(alpha+moltenAlpha*(1.0-b)));
}
