shader_type canvas_item;

uniform float blur_amount : hint_range(0, 1) = 0.1;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 pixel_size = vec2(1.0) / SCREEN_PIXEL_SIZE;
    vec4 sum = vec4(0.0);
    vec2 offset;

    // 5x5 Gaussian kernel
    float kernel[5];
    kernel[0] = 0.0625; kernel[1] = 0.25; kernel[2] = 0.375; kernel[3] = 0.25; kernel[4] = 0.0625;

    // Apply horizontal blur
    for (int i = -2; i <= 2; i++) {
        offset = vec2(blur_amount * float(i), 0.0);
        sum += texture(SCREEN_TEXTURE, SCREEN_UV + offset * pixel_size) * kernel[i + 2];
    }

    // Apply vertical blur
    for (int i = -2; i <= 2; i++) {
        offset = vec2(0.0, blur_amount * float(i));
        sum += texture(SCREEN_TEXTURE, SCREEN_UV + offset * pixel_size) * kernel[i + 2];
    }

    COLOR = sum / 2.0;
}
