shader_type canvas_item;

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
	
	COLOR.rgb = rand(grid_uv);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
