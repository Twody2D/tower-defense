shader_type canvas_item;
// A closed map zone under the clouds: what is drawn below turns greyer and
// darker (screen texture). The node's modulate alpha fades it out.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
// 0 — colours as they are, 1 — fully grey.
uniform float grey : hint_range(0.0, 1.0) = 0.65;
uniform vec4 tint : source_color = vec4(0.82, 0.84, 0.9, 1.0);

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(mix(c, vec3(l), grey) * tint.rgb, COLOR.a);
}
