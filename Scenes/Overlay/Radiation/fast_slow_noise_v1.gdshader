shader_type canvas_item;

uniform float fast_noise_intensity: hint_range(0, 1) = 0.5;
uniform float fast_noise_speed: hint_range(0, 10) = 1.0;
uniform float slow_noise_intensity: hint_range(0, 1) = 0.5;
uniform float slow_noise_speed: hint_range(0, 10) = 1.0;
uniform float slow_noise_scale: hint_range(0.1, 10) = 1.0;

// Function to generate pseudo-random noise.
// This is a basic implementation and can be replaced with a more sophisticated noise generator if desired.
float rand(vec2 co){
    return fract(sin(dot(co ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Generate fast noise.
    float fast_noise = rand(UV + TIME * fast_noise_speed);
    float fast_bw_noise = step(0.5, fast_noise);

    // Generate slow noise.
    vec2 slow_scaled_UV = UV / slow_noise_scale;
    float slow_t = 0.5 * sin(TIME * slow_noise_speed) + 0.5; // map sin output to [0, 1]
    float slow_noise = mix(rand(slow_scaled_UV), rand(slow_scaled_UV + vec2(0.5/slow_noise_scale)), slow_t);
    float slow_bw_noise = step(0.5, slow_noise);

    // Combine the fast and slow noise.
    vec3 combined_noise = mix(vec3(fast_bw_noise), vec3(slow_bw_noise), slow_noise_intensity / (fast_noise_intensity + slow_noise_intensity));

    // Mix the original texture with the combined noise.
    COLOR.rgb = mix(tex.rgb, combined_noise, max(fast_noise_intensity, slow_noise_intensity));
}
