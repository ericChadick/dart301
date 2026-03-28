extends CharacterBody3D

const bullet = preload("uid://h8nfngcoc7cq")
const explosion = preload("uid://dg8jm24fvq8xv")

@export var enemyClass : enemyType;
var enemyInd : enemyType;

@export var sightRange := 15.0;

@onready var trash_bot: Node3D = $trashBot
@onready var ground_ray: RayCast3D = $GroundRay
@onready var head: Node3D = $Head

var hp := 3;
var currencyReward := 10;
var target : Node3D;
var animPlayer: AnimationPlayer;
var initPos : Vector3;

var canSee := false;
var stalling := false;
var stallTime := 0.0;
var chargeTime := 0.0
var lookDir := 0.0;

var speed := 32.0;
var walkSpd := 6.0;
var returnSpawn := false;
var acc := 3.0;
var fric = 6.0;
var gravity := 40.0;

func _ready() -> void:
	enemyInd = enemyClass.duplicate();
	
	target = get_parent().find_child("Player");
	animPlayer = trash_bot.get_node("AnimationPlayer");
		
	animPlayer.play("EatIdle");
	initPos = global_position;
	
func _physics_process(delta: float) -> void:
	var targetDist = global_position.distance_to(target.global_position)
	
	#if trash_bot.shakeTime > 0.0:
	#	var ratio = 1.0 - clamp(targetDist / trash_bot.shakeDistance, 0.0, 1.0)
	#	target.shake = max(target.shake, trash_bot.shakeIntensity*ratio);
	
	if !canSee and targetDist <= sightRange:
		animPlayer.play("Alert_2")
		await animPlayer.animation_finished
		canSee = true;
		
	if canSee:
		if stalling:
			velocity.x = lerp(velocity.x, 0.0, delta*fric);
			velocity.z = lerp(velocity.z, 0.0, delta*fric);
			
			stallTime += delta;
			chargeTime = 0.0;
			
			if stallTime > 5.0:
				stallTime = 0.0;
				stalling = false;
		else:
			head.look_at(target.global_position);
			lookDir = lerp_angle(lookDir, head.rotation.y, delta*3.0);
			
			animPlayer.play("Charge")
			
			var direction = Vector3.FORWARD.rotated(Vector3.UP, lookDir);
			#(target.global_position-global_position).normalized();
			
			velocity.x = lerp(velocity.x, direction.x*speed, delta*acc);
			velocity.z = lerp(velocity.z, direction.z*speed, delta*acc);
			
			stallTime = 0.0;
			chargeTime += delta;
			
			if chargeTime > 5.0:
				stalling = true;
				animPlayer.play("BiteBakeShit")
				await animPlayer.animation_finished
				animPlayer.play("EatIdle");
				chargeTime = 0.0;
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	
	#convert y rotation into a transform 3d
	var euler_rotation := Vector3(0.0, lookDir+PI, 0.0)
	var basis := Basis.from_euler(euler_rotation)
	var new_transform := Transform3D(basis, position)
	#rotate with surface normal
	var n = ground_ray.get_collision_normal()
	var xform = align_with_y(new_transform, n)
	trash_bot.global_transform = trash_bot.global_transform.interpolate_with(xform, 10.0 * delta)

#rotate with surface normal
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func getHit(damage : float, knockback : Vector3):
	enemyInd.hp -= damage;
	velocity += knockback;
	#hit_particles.play();
	
	#animPlayer.play("Hit");
	#removePart();
	
	if enemyInd.hp <= 0:
		Global.currency += enemyInd.currencyReward;
		var e = explosion.instantiate();
		get_parent().add_child(e);
		e.global_position = global_position;
		queue_free();
