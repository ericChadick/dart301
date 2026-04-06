extends Node3D

@export var shot := false;
@export var projectileInst : PackedScene;

var holder : Node3D;

@onready var shoot_particle: GPUParticles3D = $Armature/Skeleton3D/GunBone/ShootParticle
@onready var muzzle_flash: OmniLight3D = $Armature/Skeleton3D/GunBone/MuzzleFlash
@onready var shoot_point: Marker3D = $Armature/Skeleton3D/GunBone/ShootPoint
@onready var shoot_sound: AudioStreamPlayer3D = $Armature/Skeleton3D/GunBone/ShootSound

var flashTimer := 0.0;

const BOT_METAL = preload("uid://dan8p38whate8")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_material_to_children(self, BOT_METAL, 1);#5
	shot = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flashTimer -= delta;
	
	if shot:
		var hitInst = projectileInst.instantiate();
		holder.get_parent().add_child(hitInst);
		hitInst.position = shoot_point.global_position;#holder.head.global_position+
		hitInst.direction = -holder.head.transform.basis.z;
		hitInst.creator = holder;
				
		shoot_particle.restart();
		shoot_sound.play();
		flashTimer = .1;
		shot = false;
	
	#gun recoil
	if flashTimer > 0.0:
		holder.rotate_from_vector(Vector2(0.0, -flashTimer*delta*8.0));
		
	muzzle_flash.visible = flashTimer > 0.0;


func apply_material_to_children(root_node: Node, mat:Material, layer : int = 1):
	var stack = [root_node]
	while stack.size() > 0:
		var node = stack.pop_back()
		
		# Apply to MeshInstance3D nodes
		if node is MeshInstance3D:
			node.get_active_material(0).next_pass = mat;
			node.set_layer_mask_value(1, false);
			node.set_layer_mask_value(layer, true);
			
		# Continue searching children
		for child in node.get_children():
			stack.append(child)
