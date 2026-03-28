extends CharacterBody3D

const explosion = preload("uid://dg8jm24fvq8xv")

@export var enemyClass : enemyType;
var enemyInd : enemyType;

#@export var sightRange := 15.0;
#@export var agroRange := 25.0;
#@export var gravity := 20.0;

@onready var model: Node3D = $shooterBot
@onready var head: Node3D = $Head
@onready var ground_ray: RayCast3D = $GroundRay
@onready var sight_ray: RayCast3D = $Head/SightRay
@onready var hit_particles: Node3D = $HitParticles
@onready var impact_fx: VFXController = $ImpactFX

var target : Node3D;
var animPlayer: AnimationPlayer;
var initPos : Vector3;
var canSee := false;
var active := false;
var prevAnim : String;

const HITFLASH = preload("uid://cgwh17gwt1nra")
var hitflashMat : ShaderMaterial;

func _ready() -> void:
	add_to_group("enemy");
	add_to_group("character");
	target = get_parent().find_child("Player");
	animPlayer = model.get_node("AnimationPlayer");
	animPlayer.play("Idle");
	initPos = global_position;
	
	enemyInd = enemyClass.duplicate();
	enemyInd.eyeNode = head.get_path();
	sight_ray.target_position.z = -enemyInd.sightRange;
	enemyInd.sightRaycastNode = sight_ray.get_path();
	
	hitflashMat = ShaderMaterial.new();
	hitflashMat.shader = HITFLASH.duplicate();
	#enemyInd.partsBreak = model.partsBreak;
	#enemyInd.updatePaths();
	
func _physics_process(delta: float) -> void:
	var targetDist = global_position.distance_to(target.global_position)
	
	canSee = true;
	if targetDist > enemyInd.sightRange:
		canSee = false;
	else:
		if enemyInd.angleVision:
			var forward = -head.global_transform.basis.z#enemyInd.eyeNode
			var to_target = (target.global_position - global_position).normalized()
			var dot_prod = forward.dot(to_target)
			if dot_prod <= cos(deg_to_rad(enemyInd.sightAngle*.5)):
				canSee = false;
			else:
				if enemyInd.raycastVision:
					if !sight_ray.is_colliding():#enemyInd.sightRaycastNode
						canSee = false;
	
	if !active and canSee:
		animPlayer.play("Alert")
		await animPlayer.animation_finished
		active = true;
		animPlayer.play("Shoot");
		
	if active:
		head.look_at(target.global_position);
		model.rotation.y = head.rotation.y;

		await animPlayer.animation_finished #finish shooting
		if targetDist <= enemyInd.agroRange:
			animPlayer.play("Shoot"); #keep shooting
		else:
			animPlayer.play("Idle"); #idle
			active = false;
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= enemyInd.gravity * delta
	
	move_and_slide()
	
	#convert y rotation into a transform 3d
	#var euler_rotation := Vector3(0.0, head.rotation.y+PI, 0.0)
	#var b := Basis.from_euler(euler_rotation)
	#var new_transform := Transform3D(b, position)
	##rotate with surface normal
	#var n = ground_ray.get_collision_normal()
	#var xform = align_with_y(new_transform, n)
	#model.global_transform = model.global_transform.interpolate_with(xform, 10.0 * delta)

#rotate with surface normal
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

#remove part from enemy model
func removePart():
	var parts = model.partsBreak;
	if parts.size() > 0:
		var partSelect = randi_range(0, parts.size()-1);
		parts[partSelect].visible = false;
		parts.remove_at(partSelect);

#func hitflash(duration:float = .05):
	## Enable flash
	#hitflashMat.set("shader_parameter/flash", 1.0)
	#await get_tree().create_timer(duration).timeout
	#hitflashMat.set("shader_parameter/flash", 0.0)
	
func getHit(damage : float, knockback : Vector3):
	#print("HIT");
	
	enemyInd.hp -= damage;
	velocity += knockback;
	
	hit_particles.play();
	
	animPlayer.play("Hit");
	removePart();
	
	#hitflash(.2);
	if enemyInd.hp <= 0:
		Global.currency += enemyInd.currencyReward;
		get_parent().find_child("Player").addCurrency(enemyInd.currencyReward);
		
		var e = explosion.instantiate();
		get_parent().add_child(e);
		e.global_position = global_position;
		queue_free();
