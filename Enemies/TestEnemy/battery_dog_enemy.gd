extends CharacterBody3D

const bullet = preload("uid://h8nfngcoc7cq")
const explosion = preload("uid://dg8jm24fvq8xv")

@export var outlet : Area3D;
var cordLength := 10.0;
@onready var cord: MeshInstance3D = $Cord
@onready var cord_point: Marker3D = $isaacRobot/CordPoint

@onready var shoot_timer: Timer = $ShootTimer
@onready var head: Node3D = $Head
@onready var shoot_point: Marker3D = $Head/ShootPoint

@onready var isaac_robot: Node3D = $isaacRobot
var animPlayer: AnimationPlayer;

var hp := 3;
var currencyReward := 10;
var target : Node3D;
var sightRange := 15.0;
var agroRange := 25.0;
var canSee := false;

var speed := 30.0;
var acc := 20.0;
var gravity := 40.0;

func _ready() -> void:
	target = get_parent().find_child("Player");
	animPlayer = isaac_robot.get_node("AnimationPlayer");
	animPlayer.play("idle_2sec");
	
func _physics_process(delta: float) -> void:
	head.look_at(target.global_position);
	
	var dist = global_position.distance_to(target.global_position)
	if dist <= sightRange:
		canSee = true;
		
	if canSee:
		if target.outlet != null:
			var direction = (target.outlet.global_position-global_position).normalized();
			velocity.x = lerp(velocity.x, direction.x*speed, delta*acc);
			velocity.z = lerp(velocity.z, direction.z*speed, delta*acc);
			if target.outlet.global_position.distance_to(global_position) < 3.0:
				target.outlet.battery -= delta*2.0;
		if dist > agroRange:
			canSee = false;
	else:
		velocity.x = lerp(velocity.x, 0.0, delta*acc);
		velocity.z = lerp(velocity.z, 0.0, delta*acc);
		
	
	isaac_robot.rotation.y = head.rotation.y;

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
