shader_type canvas_item;

uniform float noise_intensity: hint_range(0, 1) = 0.5;
uniform float speed: hint_range(0, 10) = 1.0;

// Function to generate pseudo-random noise.
// This is a basic implementation and can be replaced with a more sophisticated noise generator if desired.
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float noise = rand(UV * TIME * speed);
    // Convert the noise to black and white.
    float bw_noise = step(0.5, noise);

    // Mix the original texture with the noise.
    // This uses the noise_intensity uniform to control the amount of noise.
    COLOR.rgb = mix(tex.rgb, vec3(bw_noise), noise_intensity);
}