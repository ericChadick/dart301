shader_type spatial;

// https://godotshaders.com/shader/standard-lighting-shader-include/
#define DIFFUSE_LAMBERT
#define SPECULAR_SCHLICK_GGX

uniform int posterize_levels = 16;
uniform sampler2D albedo_map : source_color, filter_nearest_mipmap;
uniform sampler2D normal_map : hint_normal, filter_nearest_mipmap;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform vec2 uv_tiling = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);

// Calculate screen-space displacement from the center of the current texel
vec2 screen_delta(vec2 uv, sampler2D tex) {
	vec2 tex_size = vec2(textureSize(tex, 0));
	vec2 texel_center = (floor(uv * tex_size) + 0.5) / tex_size;
	vec2 offset = texel_center - uv;
	mat2 screen_to_uv = mat2(dFdx(uv), dFdy(uv));
	mat2 uv_to_screen = inverse(screen_to_uv);
	return uv_to_screen * offset;
}

// Snap vec_type to extrapolated value at the center of the current texel
float texel_snap(float v, vec2 delta) {
	return v + dFdx(v) * delta.x + dFdy(v) * delta.y;
}

vec2 texel_snap(vec2 v, vec2 delta) {
	return v + dFdx(v) * delta.x + dFdy(v) * delta.y;
}

vec3 texel_snap(vec3 v, vec2 delta) {
	return v + dFdx(v) * delta.x + dFdy(v) * delta.y;
}

vec4 texel_snap(vec4 v, vec2 delta) {
	return v + dFdx(v) * delta.x + dFdy(v) * delta.y;
}


float D_GGX(float cos_theta_m, float i_alpha) {
	float a = cos_theta_m * i_alpha;
	float k = i_alpha / (1.0 - cos_theta_m * cos_theta_m + a * a);
	return k * k * (1.0 / PI);
}

float V_GGX(float NdotL, float NdotV, float i_alpha) {
	return 0.5 / mix(2.0 * NdotL * NdotV, NdotL + NdotV, i_alpha);
}

float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

vec3 F0(float i_metallic, float i_specular, vec3 i_albedo) {
	float dielectric = 0.16 * i_specular * i_specular;
	return mix(vec3(dielectric), i_albedo, vec3(i_metallic));
}

void light_compute(vec3 i_N, vec3 i_L, vec3 i_V, vec3 i_light_color, float i_attenuation, float i_specular, float i_roughness, float i_metallic, float i_specular_amount, vec3 i_albedo, inout vec3 o_diffuse_light, inout vec3 o_specular_light) {
	vec3 f0 = F0(i_metallic, i_specular, i_albedo);
	float NdotL = min(dot(i_N, i_L), 1.0);
	float cNdotL = max(NdotL, 0.0);
	float NdotV = dot(i_N, i_V);
	float cNdotV = max(NdotV, 1e-4);

	#if defined(DIFFUSE_BURLEY) || defined(SPECULAR_SCHLICK_GGX)
		vec3 H = normalize(i_V + i_L);
		float cLdotH = clamp(dot(i_L, H), 0.0, 1.0);
	#endif

	#if defined(SPECULAR_SCHLICK_GGX)
		float cNdotH = clamp(dot(i_N, H), 0.0, 1.0);
	#endif

	if (i_metallic < 1.0) {
		float diffuse_brdNL = 0.0;

		#if defined(DIFFUSE_BURLEY)
			float FD90_minus_1 = 2.0 * cLdotH * cLdotH * i_roughness - 0.5;
			float FdV = 1.0 + FD90_minus_1 * SchlickFresnel(cNdotV);
			float FdL = 1.0 + FD90_minus_1 * SchlickFresnel(cNdotL);
			diffuse_brdNL = (1.0 / PI) * FdV * FdL * cNdotL;
		#elif defined(DIFFUSE_LAMBERT)
			diffuse_brdNL = cNdotL * (1.0 / PI);
		#elif defined(DIFFUSE_LAMBERT_WRAP)
			diffuse_brdNL = max(0.0, (NdotL + i_roughness) / ((1.0 + i_roughness) * (1.0 + i_roughness))) * (1.0 / PI);
		#elif defined(DIFFUSE_TOON)
			diffuse_brdNL = smoothstep(-i_roughness, max(i_roughness, 0.01), NdotL) * (1.0 / PI);
		#endif

		o_diffuse_light += i_light_color * diffuse_brdNL * i_attenuation;
	}

	if (i_roughness > 0.0) {
		vec3 specular_brdNL = vec3(0.0);

		#if defined(SPECULAR_SCHLICK_GGX)
			float alpha_ggx = i_roughness * i_roughness;
			float D = D_GGX(cNdotH, alpha_ggx);
			float G = V_GGX(cNdotL, cNdotV, alpha_ggx);
			float cLdotH5 = SchlickFresnel(cLdotH);
			float f90 = clamp(50.0 * f0.g, 0.0, 1.0);
			vec3 F = f0 + (f90 - f0) * cLdotH5;
			specular_brdNL = cNdotL * D * F * G;
		#elif defined(SPECULAR_TOON)
			vec3 R = normalize(-reflect(i_L, i_N));
			float RdotV = dot(R, i_V);
			float mid = 1.0 - i_roughness;
			mid *= mid;
			float intensity = smoothstep(mid - i_roughness * 0.5, mid + i_roughness * 0.5, RdotV) * mid;
			specular_brdNL = i_albedo * intensity;
		#elif defined(SPECULAR_DISABLED)
			// none
		#endif

		o_specular_light += specular_brdNL * i_light_color * i_attenuation * i_specular_amount;
	}
}

#define STANDARD_LIGHTING(output_diffuse, output_specular) light_compute(NORMAL, LIGHT, VIEW, LIGHT_COLOR, ATTENUATION, 0.5, ROUGHNESS, METALLIC, SPECULAR_AMOUNT, ALBEDO, output_diffuse, output_specular)

void vertex() {
	UV = (UV + uv_offset) * uv_tiling;
}

void fragment() {
	// Snap LIGHT_VERTEX and NORMAL for pixelated shadows
	vec2 delta = screen_delta(UV, albedo_map);
	LIGHT_VERTEX = texel_snap(VERTEX, delta);
	NORMAL = texel_snap(NORMAL, delta);

	ALBEDO = texture(albedo_map, UV).rgb;
	NORMAL_MAP = texture(normal_map, UV).xyz;
	ROUGHNESS = roughness;
	METALLIC = metallic;

	// Specular reflections produce filtering artifacts with this method, so disable them
	RADIANCE = vec4(vec3(0.0), 1.0);
}

void light() {
	vec3 d = vec3(0.0), s = vec3(0.0);
	STANDARD_LIGHTING(d, s);

	DIFFUSE_LIGHT += ALBEDO * d + s;
	float l = float(posterize_levels);
	SPECULAR_LIGHT = floor(DIFFUSE_LIGHT * l) / l;
	SPECULAR_LIGHT -= ALBEDO * DIFFUSE_LIGHT;
}
