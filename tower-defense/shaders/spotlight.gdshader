shader_type canvas_item;
// Tutorial dim with a round hole over what the player should look at.
// `size` is the rect size and `centre`/`radius` are in its pixels.

uniform vec2 size = vec2(1080.0, 1080.0);
uniform vec2 centre = vec2(540.0, 540.0);
uniform float radius = 120.0;
uniform vec4 tint : source_color = vec4(0.169, 0.169, 0.227, 0.5);

void fragment() {
	float d = length(UV * size - centre);
	COLOR = vec4(tint.rgb, tint.a * smoothstep(radius, radius + 5.0, d));
}
