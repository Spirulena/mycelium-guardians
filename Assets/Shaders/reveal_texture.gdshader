shader_type canvas_item;

uniform float reveal_amount : hint_range(0, 1) = 1.0;

void fragment() {
    // Coordinates are in the range of 0.0 to 1.0
    vec2 uv = UV;

    // If the UV coordinate is greater than the reveal amount, discard the pixel
    if (uv.y < (1.0 - reveal_amount)) {
        discard;
    }

    // Output the texture
    COLOR = texture(TEXTURE, uv);
}
