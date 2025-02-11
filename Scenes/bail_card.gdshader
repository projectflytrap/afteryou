shader_type canvas_item;
uniform sampler2D border; //filter_nearest;

uniform vec4 border_color : source_color; 
uniform vec4 border_glow_color : source_color;
uniform float border_glow_amount : hint_range(0.0, 1.0) = 1.0; 
uniform float border_glow_strength : hint_range(1.0, 10.0) = 1.0; 

uniform float darken : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	bool is_border = texture(border, UV).a > 0.1;
	vec3 glow_border = mix(border_color.rgb, border_glow_color.rgb * border_glow_strength, border_glow_amount);
	COLOR.rgb = glow_border * float(is_border) + COLOR.rgb * float(!is_border);
	COLOR *= darken;
}
