shader_type canvas_item;

uniform vec4 outline_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 color = texture(screen_texture,SCREEN_UV);
	vec2 px = SCREEN_PIXEL_SIZE;
	
	float outline = 0.0;
	
	outline = max(outline, texture(screen_texture, SCREEN_UV + vec2(px.x, 0.0)).a);
	outline = max(outline, texture(screen_texture, SCREEN_UV + vec2(-px.x, 0.0)).a);
	outline = max(outline, texture(screen_texture, SCREEN_UV + vec2(0.0, px.y)).a);
	outline = max(outline, texture(screen_texture, SCREEN_UV + vec2(0.0, -px.y)).a);
	
	if (color.a > 0.0) {
		COLOR = color;
	}
	else if (outline > 0.0) {
		COLOR = outline_color;
	}
	else {
		COLOR = vec4(0.0);
	}
	
}