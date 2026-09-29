shader_type canvas_item;
// Enemy horde in a MultiMesh (one per pest type). The sheet is one row of
// frames. INSTANCE_CUSTOM: x = frame index, y = hit flash 0..1, z = slowed 0/1.

uniform int hframes = 4;

varying vec4 custom;

void vertex() {
	UV.x = (UV.x + INSTANCE_CUSTOM.x) / float(hframes);
	custom = INSTANCE_CUSTOM;
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	c.rgb = mix(c.rgb, vec3(1.0, 0.4, 0.4), custom.y * 0.7);
	c.rgb = mix(c.rgb, vec3(0.43, 0.78, 1.0), custom.z * 0.4);
	COLOR = c * COLOR;
}
