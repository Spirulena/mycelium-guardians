shader_type canvas_item;

uniform float fast_noise_intensity: hint_range(0, 1) = 0.5;
uniform float fast_noise_speed: hint_range(0, 10) = 1.0;
uniform float slow_noise_intensity: hint_range(0, 1) = 0.5;
uniform float slow_noise_speed: hint_range(0, 10) = 1.0;
uniform float slow_noise_scale: hint_range(0.1, 10) = 1.0;
uniform float blend_factor: hint_range(0, 1) = 0.5;
uniform float blur_amount: hint_range(0, 1) = 0.1;

// Function to generate pseudo-random noise.
// This is a basic implementation and can be replaced with a more sophisticated noise generator if desired.
float rand(vec2 co){
    return fract(sin(dot(co ,vec2(12.9898,78.233))) * 43758.5453);
}

// Function to generate blurred noise.
float blurred_noise(vec2 uv) {
    float sum = 0.0;
    float weight_sum = 0.0;
    float kernel[5];
    kernel[0] = 0.0625; kernel[1] = 0.25; kernel[2] = 0.375; kernel[3] = 0.25; kernel[4] = 0.0625;

    // Apply blur in both x and y directions.
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = blur_amount * vec2(float(i), float(j));
            float weight = kernel[i + 2] * kernel[j + 2];
            sum += rand(uv + offset) * weight;
            weight_sum += weight;
        }
    }

    return sum / weight_sum;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Generate fast noise.
    float fast_noise = blurred_noise(UV + TIME * fast_noise_speed);
    float fast_bw_noise = step(0.5, fast_noise);

    // Generate slow noise.
    vec2 slow_scaled_UV = UV / slow_noise_scale;
    float slow_t = 0.5 * sin(TIME * slow_noise_speed) + 0.5; // map sin output to [0, 1]
    float slow_noise = mix(blurred_noise(slow_scaled_UV), blurred_noise(slow_scaled_UV + vec2(0.5/slow_noise_scale)), slow_t);
    float slow_bw_noise = step(0.5, slow_noise);

    // Combine the fast and slow noise.
    float combined_noise = abs((fast_bw_noise * fast_noise_intensity + slow_bw_noise * slow_noise_intensity) / (fast_noise_intensity + slow_noise_intensity));

    // Mix the original texture with the combined noise.
    COLOR.rgb = mix(tex.rgb, vec3(combined_noise), blend_factor);
}
