shader_type canvas_item;

const float SAMPLES = 71.0;
const float PI2 = 6.28319;

uniform vec2 blur_scale = vec2(0.1, 0.1);

float gaussian(float x) {
    float x_squared = x*x;
    float width = 1.0 / sqrt(PI2 * SAMPLES);

    return width * exp((x_squared / (2.0 * SAMPLES)) * -1.0);
}

void fragment() {
    vec2 scale = TEXTURE_PIXEL_SIZE * blur_scale;

    float weight = 0.0;
    float total_weight = 0.0;
    vec4 color = vec4(0.0);

    for(int i=-int(SAMPLES)/2; i < int(SAMPLES)/2; ++i) {
        weight = gaussian(float(i));
        color.rgb += texture(TEXTURE, UV + scale * vec2(float(i))).rgb * weight;
        total_weight += weight;
    }

    COLOR.rgb = color.rgb / total_weight;
}