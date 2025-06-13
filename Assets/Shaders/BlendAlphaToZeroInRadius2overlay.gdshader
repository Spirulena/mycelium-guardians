shader_type canvas_item;

global uniform vec2 wind_direction;
uniform float speed_multiplier : hint_range(0.1, 5.0) = 1.0; // Multiplier for scrolling speed
uniform vec2 v_speed = vec2(0.03, 0.05); // x for horizontal, y for vertical speed

// Baseline alpha value
uniform float baseline_alpha : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // Center of the texture in normalized coordinates (0.5, 0.5 is the center)
    vec2 center = vec2(0.5, 0.5);

    // Normalized coordinates of the current pixel
    vec2 normCoords = UV;

    // Distance from the current pixel to the center
    float dist = distance(normCoords, center);

    // The radius at which the color completely transitions to black (half of the texture)
    float radius = 0.6;

    // Calculate the intensity based on distance
    float intensity = smoothstep(0.0, radius, dist);

	//Vector2 scroll
	//vec2 adjusted_speed = v_speed * speed_multiplier;
	vec2 adjusted_speed = wind_direction * speed_multiplier;
	vec2 offset = mod(vec2(TIME * adjusted_speed.x, TIME * adjusted_speed.y), vec2(1.0, 1.0));
	vec2 scaledUV = UV * 1.4;
    // Adjusted UV coordinates for the scrolling effect
    vec2 scrolledUV = scaledUV + offset;
    vec2 scrolledUV2 = scaledUV * 0.2 + offset;
    // Sample the texture with the adjusted UVs
    vec4 tex1 = texture(TEXTURE, scrolledUV);
    vec4 tex2 = texture(TEXTURE, scrolledUV2);
	vec4 blendedColor = (tex1 + tex2) * 0.5;
	COLOR = blendedColor;
    // Blend between white and black based on intensity
	//COLOR = texture(TEXTURE, UV);
    COLOR.a = baseline_alpha * (1.0 - intensity) ;
}
