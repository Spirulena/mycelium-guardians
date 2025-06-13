shader_type canvas_item;

// Uniform to control the amount of distortion. Can be adjusted from -10 to 10.
uniform float distortion_amount : hint_range(-100.0, 100.0) = 100;

void vertex() {
    // Calculate distortion based on the sine and cosine function
    float x_distortion = distortion_amount * sin(UV.y * 10.0 + TIME);
    float y_distortion = distortion_amount * cos(UV.x * 10.0 + TIME);
    
    // Apply the distortion to the UV coordinates
    UV.x += x_distortion;
    UV.y += y_distortion;
}

void fragment() {
    COLOR = texture(TEXTURE, UV);
}
