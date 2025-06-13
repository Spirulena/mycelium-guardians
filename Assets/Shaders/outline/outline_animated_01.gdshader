shader_type canvas_item;

uniform bool enabled = true;
uniform float brightness = 0.04;

void fragment() {

  vec4 texture_color = texture(TEXTURE, UV);
	if (enabled) {
		// Make more opaque areas brighter
		float alpha = texture_color.a;
		alpha = smoothstep(0.0, 1.0, alpha);
		vec3 brighter_color = texture_color.rgb * mix(1.0, brightness, alpha) * 20.0;
		texture_color.rgb = brighter_color;
		COLOR = vec4(brighter_color, texture_color.a);
	}
	COLOR = texture_color;
}