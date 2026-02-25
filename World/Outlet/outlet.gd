extends Area3D

@export var unlimited := false;
@export var battery := 20.0;
var batteryMax := 1.0;
var dead := false;
var pulled := false;
@export var connected : Node3D;

@onready var outlet_light: MeshInstance3D = $OutletLight
@onready var spark_particle: GPUParticles3D = $SparkParticle

const OUTLET_GLOW = preload("uid://c0uh2y7lgbtc4")
var mat : StandardMaterial3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	batteryMax = battery;
	mat = OUTLET_GLOW.duplicate();
	outlet_light.material_override = mat;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !dead and connected != null and connected.is_in_group("player") and !unlimited:
		battery -= delta;
		if battery <= 0.0:
			mat.emission = Color(1.0, 0.15, 0.0, 1.0);
			#outlet_light.visible = false;
			dead = true;
