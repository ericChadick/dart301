extends Node3D

@export var trashblockSpawn:= false;
const TRASH_BLOCK = preload("uid://i88uf8p3y2hu")
@onready var block_point: Marker3D = $Armature/Skeleton3D/Bone/BlockPoint
@onready var debris_left_particle: GPUParticles3D = $Armature/Skeleton3D/Bone/DebrisLeftParticle
@onready var debris_right_particle: GPUParticles3D = $Armature/Skeleton3D/Bone/DebrisRightParticle
@onready var mouth_hitbox: Area3D = $Armature/Skeleton3D/Bone/MouthHitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var shakeTime := 0.0;
@export var shakeIntensity := .3;
@export var shakeDistance := 10.0;



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trashblockSpawn = false;
	debris_left_particle.emitting = false;
	debris_right_particle.emitting = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shakeTime -= delta;
	
	var debrisEmit = animation_player.current_animation == "Charge"
	debris_left_particle.emitting = debrisEmit;
	debris_right_particle.emitting = debrisEmit;
	
	if trashblockSpawn:
		var block = TRASH_BLOCK.instantiate();
		get_parent().get_parent().add_child(block);
		block.global_position = block_point.global_position;
		trashblockSpawn = false;

func _on_back_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.shake = .5;
		body.velocity.y = 40.0;

func _on_mouth_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var dist = 40.0;
		var vec = (mouth_hitbox.global_position-body.global_position).normalized();
		body.getHit(1.0, Vector3(-vec.x*dist, dist*.75, -vec.z*dist), .5, Global.ScreenCracks.MED)
