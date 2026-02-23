extends CharacterBody3D

const bullet = preload("uid://h8nfngcoc7cq")
const explosion = preload("uid://dg8jm24fvq8xv")

@export var outlet : Area3D;
@export var cordLength := 25.0;
@export var sightRange := 15.0;
@export var agroRange := 25.0;

@onready var trash_bot: Node3D = $trashBot

@onready var cord: MeshInstance3D = $Cord
#@onready var cord_point: Marker3D = $Head/CordPoint
var cord_point: Marker3D
var animPlayer: AnimationPlayer;


#if body.is_in_group("enemy"):
	#body.queue_free();
#if body.is_in_group("player"):
	#body.getHit(1.0, Vector3.RIGHT, .2, Global.screenCracks.SMALL);
#
#var part = dirt.instantiate();
#get_parent().add_child(part);
#part.global_position = global_position;
#queue_free();

@onready var shoot_timer: Timer = $ShootTimer
@onready var head: Node3D = $Head
@onready var shoot_point: Marker3D = $Head/ShootPoint
@onready var ground_ray: RayCast3D = $GroundRay

var hp := 3;
var currencyReward := 10;
var target : Node3D;
var initPos : Vector3;

var canSee := false;

var speed := 20.0;
var acc := 3.0;
var gravity := 40.0;

func _ready() -> void:
	cord_point = trash_bot.get_node("Armature/Skeleton3D/Bone/CordPoint");
	target = get_parent().find_child("Player");
	animPlayer = trash_bot.get_node("AnimationPlayer");
	
	animPlayer.play("EatIdle");
	initPos = global_position;
	
	outlet.connected = self;
	outlet.outlet_light.visible = false;
	
func _physics_process(delta: float) -> void:
	head.look_at(target.global_position);
	
	var targetDist = global_position.distance_to(target.global_position)
	var outletDist = global_position.distance_to(outlet.global_position)
	var targetOutletDist = target.global_position.distance_to(outlet.global_position)
	
	if trash_bot.shakeTime > 0.0:
		var ratio = trash_bot.shakeDistance/min(trash_bot.shakeDistance,trash_bot.shakeDistance);
		target.shake = max(target.shake, trash_bot.shakeIntensity*ratio);
	
	if !canSee and targetOutletDist <= sightRange:
		animPlayer.play("Alert_2")
		await get_tree().create_timer(1.0).timeout
		canSee = true;
		
	if canSee:
		animPlayer.play("Charge")
		var direction = (target.global_position-global_position).normalized();
		velocity.x = lerp(velocity.x, direction.x*speed, delta*acc);
		velocity.z = lerp(velocity.z, direction.z*speed, delta*acc);
		
		#trash_bot.rotation.y = head.rotation.y+PI;
		
		if targetDist > agroRange:
			canSee = false;
			
		if outletDist >= cordLength:
			canSee = false;
			animPlayer.play("BiteBakeShit")
			#await get_tree().create_timer(3.0).timeout
			#canSee = false;
	else:
		if animPlayer.current_animation_position >= animPlayer.current_animation_length:
			animPlayer.play("EatIdle")
		velocity.x = lerp(velocity.x, 0.0, delta*acc);
		velocity.z = lerp(velocity.z, 0.0, delta*acc);
	
	if outlet == null:
		cord.visible = false;
	else:
		cord.visible = true;
		cord.global_position = (cord_point.global_position+outlet.global_position)/2;
		cord.look_at(outlet.global_position);
		cord.rotation_degrees.x += 90;
		cord.scale.y = cord_point.global_position.distance_to(outlet.global_position)
		var distOutlet = cord_point.global_position.distance_to(outlet.global_position)
		if distOutlet > cordLength:
			var cordDir = outlet.global_position - cord_point.global_position;
			var tetherVec = cordDir.normalized() * velocity.length();
			velocity.x += tetherVec.x;
			velocity.z += tetherVec.z;
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	#convert y rotation into a transform 3d
	var euler_rotation := Vector3(0.0, head.rotation.y+PI, 0.0)
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

func _on_tree_exited() -> void:
	if outlet != null:
		outlet.connected = null;
		outlet.outlet_light.visible = true;
		outlet.battery *= .5;
