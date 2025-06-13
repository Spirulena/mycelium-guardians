shader_type canvas_item;

uniform sampler2D noise_img: repeat_enable;
uniform float speed = 0.3;

void fragment() {
	float modulatedTime = mod(TIME, 60.0); // Reset TIME every 60 seconds

	// Scale factor for the noise texture
	float scale = 1.2; // Use 0.5 to double the size of the noise features

	// Adjusted UV coordinates for scaled noise texture
	vec2 scaledUV = UV * scale;

	vec2 uv1 = vec2(scaledUV.x + modulatedTime * speed, scaledUV.y) * 4.4;
	vec2 uv2 = vec2(scaledUV.x - modulatedTime * speed, scaledUV.y) * 2.0;
	vec2 uv3 = vec2(scaledUV.x, scaledUV.y + modulatedTime * speed) * 2.0;

	float noise_r = texture(noise_img, uv1).r;
	float noise_g = texture(noise_img, uv2).g;
	float noise_b = texture(noise_img, uv3).b;

	vec3 noise_color = vec3(noise_r, noise_g, noise_b);
	// Calculate new alpha based on the noise
	float new_alpha = noise_r * noise_g * noise_b;

	// Fetch the original texture color and alpha
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 final_color = tex_color.rgb * noise_color; // Combine your noise color with the texture color
	float final_alpha = new_alpha * 10.0 * tex_color.a; // Adjust the final alpha

	// Apply the final color and alpha, ensuring modulate is included
	COLOR.rgb = final_color * COLOR.rgb; // Multiplying by COLOR.rgb includes the modulate effect on color
	COLOR.a = final_alpha * COLOR.a; // Multiplying by COLOR.a includes the modulate effect on alpha
	// Note: Since Godot 4 automatically applies modulate, COLOR before your shader logic contains modulate values.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
