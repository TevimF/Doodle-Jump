shader_type canvas_item;

uniform float speed;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(TEXTURE, UV);
	color.b = 1.0;
	color.g = 0.6;
	color.r = 0.4;
	float color_variation = sin(TIME * 0.4) * 0.2;
	color.rgb += color_variation;
	COLOR = color;
}
