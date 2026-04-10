shader_type fog;

uniform float falloff = 0.0;
uniform float raduis = 1.0;

void fog() {
	float sdf = - SDF;
	float l = length(WORLD_POSITION - OBJECT_POSITION);
	DENSITY = 1.0 - step(raduis, l);
	
	
	
	DENSITY *= smoothstep(0.0, falloff, sdf);
	ALBEDO = vec3(1.0);
	
	
	
}
