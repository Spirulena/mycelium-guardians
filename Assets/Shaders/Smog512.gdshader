shader_type canvas_item;
//render_mode blend_sub;

uniform sampler2D noise_tex_1: repeat_enable;
uniform sampler2D noise_tex_2: repeat_enable;

uniform float speed_multiplier = 1.0;

uniform vec2 wind_direction_1;
uniform vec2 wind_direction_2;

uniform float wind_speed_1 = 0.2;
uniform float wind_speed_2 = 0.2;

uniform float baseline_alpha : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 offset_1 = wind_direction_1 * TIME * wind_speed_1 * speed_multiplier;
	vec2 offset_2 = wind_direction_2 * TIME * wind_speed_2 * speed_multiplier;

	vec2 scaledUV = UV * 0.2;

	vec2 scrolledUV_1 = scaledUV + offset_1;
	vec2 scrolledUV_2 = scaledUV + offset_2 * 0.2 + sin(TIME) * 0.01;

	vec4 noise_color_1 = texture(noise_tex_1, scrolledUV_1);
	vec4 noise_color_2 = texture(noise_tex_2, scrolledUV_2);

	vec4 final_color = mix(noise_color_1, noise_color_2, 0.5);

    // Center of the texture in normalized coordinates (0.5, 0.5 is the center)
    vec2 center = vec2(0.5, 0.5);
    // Normalized coordinates of the current pixel
    vec2 normCoords = UV;
    // Distance from the current pixel to the center
    float dist = distance(normCoords, center);
    // The radius at which the color completely transitions to black (half of the texture)
    float radius = 0.5;
    // Calculate the intensity based on distance
    float intensity = smoothstep(0.0, radius, dist);

	COLOR = final_color;
    COLOR.a *= baseline_alpha * (1.0 - intensity);
}
