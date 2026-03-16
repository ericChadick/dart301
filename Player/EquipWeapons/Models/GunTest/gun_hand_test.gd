extends Node3D

@export var shot := false;
@export var projectileInst : PackedScene;

var holder : Node3D;

@onready var shoot_particle: GPUParticles3D = $Armature/Skeleton3D/GunBone/ShootParticle
@onready var muzzle_flash: OmniLight3D = $Armature/Skeleton3D/GunBone/MuzzleFlash
@onready var shoot_point: Marker3D = $Armature/Skeleton3D/GunBone/ShootPoint

var flashTimer := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flashTimer -= delta;
	
	if shot:
		var hitInst = projectileInst.instantiate();
		holder.get_parent().add_child(hitInst);
		hitInst.position = shoot_point.global_position;
		hitInst.direction = -holder.head.transform.basis.z;
		hitInst.creator = holder;
				
		shoot_particle.restart();
		flashTimer = .1;
		shot = false;
	
	muzzle_flash.visible = flashTimer > 0.0;
