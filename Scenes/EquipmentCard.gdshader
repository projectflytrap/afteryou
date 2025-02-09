shader_type canvas_item;
uniform sampler2D border : filter_nearest;
uniform sampler2D inner_border : filter_nearest;
uniform sampler2D background : filter_nearest;

uniform vec4 border_color : source_color; 
uniform vec4 border_glow_color : source_color;
uniform float border_glow_amount : hint_range(0.0, 1.0) = 1.0; 
uniform float border_glow_strength : hint_range(1.0, 10.0) = 1.0; 

uniform vec4 inner_border_color : source_color; 
uniform vec4 background_color : source_color;
uniform float background_opacity : hint_range(0.0, 1.0) = 0.8;
uniform float darken : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	bool is_border = texture(border, UV).a > 0.1;
	bool is_inner_border = texture(inner_border, UV).a > 0.1;
	bool is_background = texture(background, UV).a > 0.1;
	vec3 glow_border = mix(border_color.rgb, border_glow_color.rgb * border_glow_strength, border_glow_amount);
	COLOR.rgb = glow_border * float(is_border) + inner_border_color.rgb * float(is_inner_border) + background_color.rgb * float(is_background);
	COLOR.a = COLOR.a * float(!is_background) + background_opacity * float(is_background);
	COLOR *= darken;
}
