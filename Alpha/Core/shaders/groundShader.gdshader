shader_type canvas_item;

uniform vec2 atlas_size = vec2(8.0, 8.0);
uniform sampler2D noise_tex;
uniform float strength = 0.18;

const float Y_OFFSET = 63.0 / 256.0;

void fragment() {
    vec2 tile_uv = fract(UV * atlas_size);
    vec2 tile_id = floor(UV * atlas_size);

    // Remap to actual diamond region
    tile_uv.y = mix(Y_OFFSET, 1.0, tile_uv.y);

    float rand = texture(noise_tex, tile_id / atlas_size).r;

    vec2 offset = vec2(rand, fract(rand * 9.13));
    offset = (offset - 0.5) * strength;

    vec2 new_uv = clamp(tile_uv + offset, Y_OFFSET, 1.0);

    vec2 final_uv = (tile_id + new_uv) / atlas_size;

    COLOR = texture(TEXTURE, final_uv);
}