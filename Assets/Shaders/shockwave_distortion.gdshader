shader_type canvas_item;

vec2 toIsoUV(vec2 uv)
{
    return vec2(uv.x + uv.y - 0.5, -uv.x + uv.y + 0.5);
}

vec2 fromIsoUV(vec2 uv)
{
    return vec2(0.5 * (uv.x - uv.y + 1.0), 0.5 * (uv.x + uv.y));
}

vec2 uv_to_region_uv(vec2 uv, vec2 texture_pixel_size) {
	vec2 start = vec2(3.0, 2.0) * vec2(256.0, 128.0);
	vec2 end = vec2(256.0, 128.0);
	return (uv-(start*texture_pixel_size))/(end*texture_pixel_size);
}
vec2 region_uv_to_uv(vec2 region_uv, vec2 texture_pixel_size) {
	vec2 start = vec2(3.0, 2.0) * vec2(256.0, 128.0);
	vec2 end = vec2(256.0, 128.0);
	return (start*texture_pixel_size)+region_uv*(end*texture_pixel_size);
}

void fragment() {


	vec2 pos2d = UV.xy;
	float distance_to_center = distance(pos2d, vec2(0.5, 0.5));
    vec4 distorted_color = texture(TEXTURE, UV);
	distorted_color.r = distorted_color.r * cos(TIME);
    //COLOR = distorted_color;

	vec2 uv = UV;

    uv = toIsoUV(uv);
    //uv -= floor(uv) * sin(TIME); // make it into [0, 1) x [0, 1)
    uv = fromIsoUV(uv);
    COLOR = vec4(texture(TEXTURE, UV).rgb, texture(TEXTURE, UV).a);
	uv = uv_to_region_uv(UV, TEXTURE_PIXEL_SIZE);
	pos2d = uv.xy;
	distance_to_center = distance(pos2d, vec2(0.5, 0.5));

	float sintime = sin(TIME);
	sintime = (sintime + 1.0 ) * 0.5 + 0.55;

	float a = texture(TEXTURE, UV).a / distance_to_center  * sintime * 0.2;
	float aa = clamp(a, texture(TEXTURE, UV).a , 1.0);

	COLOR = vec4(texture(TEXTURE, UV).rgb, aa);
	//COLOR = vec4(uv, 0.5, distance_to_center);
}