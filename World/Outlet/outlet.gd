extends Area3D

@export var unlimited := false;
@export var battery := 20.0;
var batteryMax := 1.0;
var dead := false;
var flashTimer := 0.0;
var pulled := false;
var unplugged := false;
@export var connected : Node3D;

@onready var outlet_light: MeshInstance3D = $LightModels/OutletLight
@onready var light: OmniLight3D = $Light
@onready var spark_particle: GPUParticles3D = $SparkParticle

@onready var light_models: Node3D = $LightModels

const OUTLET_GLOW = preload("uid://c0uh2y7lgbtc4")
var mat : StandardMaterial3D;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setBattery(battery);
	mat = OUTLET_GLOW.duplicate();
	#outlet_light.material_override = mat;
	
	for i in light_models.get_children():
		i.set_surface_override_material(0, mat);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !dead and connected != null and connected.is_in_group("player") and !unlimited:
		battery -= delta;
		if battery <= 0.0:
			mat.emission = Color("ff4400");
			light.light_color = Color("ff4400");
			dead = true;
			
	if pulled:
		#effect for unplugging
		pulled = false;
		
	if unplugged:
		#effect for unplugging
		unplugged = false;
		
	if dead:
		flashTimer += delta*2.0;
		if int(flashTimer) % 2 == 0:
			light_models.visible = false;
		else:
			light_models.visible = true;


func setBattery(value : float):
	battery = value;
	batteryMax = value;
