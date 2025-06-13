shader_type canvas_item;

uniform vec4 modulate_color : source_color;
uniform float tolerance = 0.1; // Tolerance for how close to white

void fragment() {
    vec4 pixel_color = texture(TEXTURE, UV);

    // Convert to grayscale to determine proximity to white
    float gray = (pixel_color.r + pixel_color.g + pixel_color.b) / 3.0;

    // Calculate blend factor based on proximity to white within tolerance
    float blend_factor = smoothstep(1.0 - tolerance, 1.0, gray);

    // Interpolate between original and modulated color based on blend factor
    COLOR = mix(pixel_color, pixel_color * modulate_color, blend_factor);
}