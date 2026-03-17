extends Node3D

@export var shot := false;
@export var projectileInst : PackedScene;

@onready var shoot_particle: GPUParticles3D = $ShooterArmature/Skeleton3D/arm_r/ShootParticle
@onready var muzzle_flash: OmniLight3D = $ShooterArmature/Skeleton3D/arm_r/MuzzleFlash
@onready var shoot_point: Marker3D = $ShooterArmature/Skeleton3D/arm_r/ShootPoint

var flashTimer := 0.0;

@onready var arm_panel_l: MeshInstance3D = $ShooterArmature/Skeleton3D/arm_l_001/armPanel_l
@onready var side_panel_l: MeshInstance3D = $ShooterArmature/Skeleton3D/sidePanel_l/sidePanel_l
@onready var leg_panel_r: MeshInstance3D = $ShooterArmature/Skeleton3D/leg_r_001/legPanel_r
@onready var side_panel_r: MeshInstance3D = $ShooterArmature/Skeleton3D/sidePanel_r/sidePanel_r
var partsBreak : Array[Node3D];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	partsBreak.append(arm_panel_l);
	partsBreak.append(side_panel_l);
	partsBreak.append(leg_panel_r);
	partsBreak.append(side_panel_r);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flashTimer -= delta;
	
	if shot:
		var hitInst = projectileInst.instantiate();
		get_parent().get_parent().add_child(hitInst);
		hitInst.position = shoot_point.global_position;
		hitInst.look_at();
		#hitInst.direction = -holder.head.transform.basis.z;
		#hitInst.creator = holder;
				
		shoot_particle.restart();
		flashTimer = .1;
		shot = false;
	
	muzzle_flash.visible = flashTimer > 0.0;
