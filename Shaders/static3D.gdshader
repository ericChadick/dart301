shader_type spatial;

uniform float gridSize = 300.0;
uniform float noiseSpd = 12.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 rand(vec2 co) {
    return vec3(fract(sin(dot(co.xy, vec2(12.9898+floor(TIME*noiseSpd), 78.233))) * 43758.5453));
}

void fragment() {
	vec2 grid_uv = round(UV * float(gridSize)) / float(gridSize);
	
	ALBEDO = rand(grid_uv);
	SPECULAR = .8;
	ROUGHNESS = .2;
	METALLIC = .2;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
