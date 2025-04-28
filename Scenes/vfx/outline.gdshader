shader_type canvas_item;

uniform vec2 size = vec2(64.0);
uniform vec4 outline_color : source_color = vec4(1.0);

void fragment() {
	vec2 pixel_size = vec2(1.0)/size;
	bool within = texture(TEXTURE, UV + pixel_size * vec2(1.0, 0.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(1.0, -1.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(1.0, 1.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, 0.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, 1.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(-1.0, -1.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(0.0, 1.0)).a > 0.0;
	within = within || texture(TEXTURE, UV + pixel_size * vec2(0.0, -1.0)).a > 0.0;
	bool outline = within && texture(TEXTURE, UV).a == 0.0;
	COLOR = COLOR + float(outline) * outline_color * vec4(vec3(1.0), clamp(sin(TIME * 1.5) + 0.7, 0, 1.0));
}

