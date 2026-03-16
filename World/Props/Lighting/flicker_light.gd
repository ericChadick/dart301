@tool
extends OmniLight3D
@onready var light_orb: MeshInstance3D = $LightOrb
@onready var spark_emitter: GPUParticles3D = $SparkEmitter
@onready var light_volume: FogVolume = $LightVolume

@export var lightColor : Color = Color("ff7b00");
@export var lightEnergy : float = 2.5;
@export var lightRange : float = 20.0;
@export var lightAttenuation : float = .6;
@export var shadows : bool = true;
@export var orbSize : float = 1.0;
@export var orbEnergy : float = 8.0;
@export var flickerSpd : float = 5.0;
@export var flickerRandomness : float = .1;
@export var flickerMinEnergy : float = .5;
@export var flickerMaxEnergy : float = 1.0;
@export var canShutOff : bool = true;
@export var shutOffChance : float = .2;
@export var sparks : bool = true;
@export var showBeam : bool = true;
@export var beamLength : float = 8.0;
@export var beamRadius : float = 3.0;
@export var beamDensity : float = .02;

const orbMatLoad := preload("uid://cu1m3yxdrnvci");
var orbMat : StandardMaterial3D;
const beamMatLoad := preload("uid://c5p8jsm7kos8e");
var beamMat : FogMaterial;
var lightC : Color;
var emissC : Color;
var beamC : Color;
var flickerTime := 0.0;
var beamTime := 0.0;

var lightEnergyCurrent : float;
var orbEnergyCurrent : float;
var lightEnergyOffset : float = 1.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orbMat = orbMatLoad.duplicate();
	light_orb.material_override = orbMat;
	
	beamMat = beamMatLoad.duplicate();
	light_volume.material = beamMat;
	
	if !sparks:
		spark_emitter.queue_free();
		
	if !showBeam:
		light_volume.queue_free();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lightC = Color.from_hsv(lightColor.h, max(0.0, lightColor.s-.65), lightColor.v, 1.0)
	emissC = Color.from_hsv(lightColor.h, max(0.0, lightColor.s-.35), lightColor.v, 1.0)
	beamC = Color.from_hsv(lightColor.h, max(0.0, lightColor.s-.75), lightColor.v, 1.0)
	
	#update light parameters
	light_color = lightC;
	orbMat.albedo_color = lightColor;
	orbMat.emission = emissC;
	orbMat.emission_energy_multiplier = orbEnergyCurrent;
	
	light_energy = lightEnergyCurrent;
	omni_range = lightRange;
	omni_attenuation = lightAttenuation;
	shadow_enabled = shadows;
	light_orb.scale = Vector3(orbSize, orbSize, orbSize);
	
	beamTime += delta;
	if showBeam:
		light_volume.material.set("emission", beamC);
		light_volume.material.set("density", beamDensity);
		light_volume.size.y = beamLength;
		light_volume.position.y = -beamLength*.4;
		light_volume.size.x = beamRadius*2.0;
		light_volume.size.z = beamRadius*2.0;
		
	#light flickering
	flickerTime += delta*flickerSpd*randf_range(1.0-flickerRandomness, 1.0+flickerRandomness);
	if flickerTime > 1.0:
		if canShutOff and randf_range(0.0, 1.0) <= shutOffChance and lightEnergyOffset != 0.0:
			lightEnergyOffset = 0.0;
			light_orb.visible = false;
			if showBeam:
				light_volume.visible = false;
			if sparks:
				spark_emitter.restart();
		else:
			light_orb.visible = true;
			if showBeam:
				light_volume.visible = true;
			lightEnergyOffset = randf_range(flickerMinEnergy, flickerMaxEnergy);
		lightEnergyCurrent = lightEnergy*lightEnergyOffset;
		orbEnergyCurrent = orbEnergy*lightEnergyOffset;
		flickerTime = 0.0;
