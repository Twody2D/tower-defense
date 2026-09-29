shader_type canvas_item;
// Enemy horde in a MultiMesh (one per pest type) over the pest's EnemyAtlas:
// a row per animation, square cells. INSTANCE_CUSTOM: x = frame (column),
// y = hit flash 0..1, z = slowed 0/1, w = row (animation).

uniform int columns = 4;
uniform int rows = 1;

varying vec4 custom;

void vertex() {
	UV = (UV + INSTANCE_CUSTOM.xw) / vec2(float(columns), float(rows));
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	c.rgb = mix(c.rgb, vec3(1.0, 0.4, 0.4), custom.y * 0.7);
	c.rgb = mix(c.rgb, vec3(0.43, 0.78, 1.0), custom.z * 0.4);
	COLOR = c * COLOR;
}
