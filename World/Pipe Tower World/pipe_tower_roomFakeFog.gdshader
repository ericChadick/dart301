shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, diffuse_burley, specular_disabled;

uniform vec4 fog_color : source_color = vec4(0.45, 0.7, 1.0, 1.0);
uniform float base_alpha : hint_range(0.0, 2.0) = 0.12;
uniform float light_strength : hint_range(0.0, 8.0) = 2.5;
uniform float fresnel_power : hint_range(0.1, 8.0) = 2.0;
uniform float noise_scale = 2.5;
uniform float scroll_speed = 0.25;
uniform float vertical_fade = 1.2;
uniform float edge_softness = 1.5;

varying vec3 world_pos;
varying vec3 local_pos;
varying vec3 local_normal;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float n000 = hash(i + vec3(0.0, 0.0, 0.0));
	float n100 = hash(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash(i + vec3(1.0, 1.0, 1.0));

	float nx00 = mix(n000, n100, f.x);
	float nx10 = mix(n010, n110, f.x);
	float nx01 = mix(n001, n101, f.x);
	float nx11 = mix(n011, n111, f.x);

	float nxy0 = mix(nx00, nx10, f.y);
	float nxy1 = mix(nx01, nx11, f.y);

	return mix(nxy0, nxy1, f.z);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);

	// Fresnel makes the volume read better from angles.
	float fresnel = pow(1.0 - max(dot(normalize(NORMAL), view_dir), 0.0), fresnel_power);

	// Animated 3D noise so it feels foggy instead of like a box.
	vec3 p = world_pos * noise_scale;
	p.x += TIME * scroll_speed;
	float n = noise(p);
	float fog_mask = smoothstep(0.35, 0.8, n);

	// Fade upward/downward inside the mesh.
	float height_mask = 1.0 - clamp(UV.y * vertical_fade, 0.0, 1.0);

	// Soften edges a bit.
	float edge = pow(1.0 - abs(dot(normalize(local_normal), vec3(0.0, 1.0, 0.0))), edge_softness);
	float density = max(fog_mask * height_mask + fresnel * 0.35, 0.0);

	ALBEDO = fog_color.rgb;
	ALPHA = fog_color.a * base_alpha * density;
	EMISSION = fog_color.rgb * density * 0.15;
}

// This is the important part.
// Each light adds brightness into the fake fog mesh.
void light() {
	float ndotl = max(dot(normalize(NORMAL), LIGHT), 0.0);
	float scatter = pow(ndotl, 0.5);

	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * scatter * light_strength * ALBEDO * ALPHA;
	SPECULAR_LIGHT = vec3(0.0);
}