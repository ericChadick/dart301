extends CharacterBody3D

const bullet = preload("uid://h8nfngcoc7cq")

@onready var shoot_timer: Timer = $ShootTimer
@onready var head: Node3D = $Head
@onready var shoot_point: Marker3D = $Head/ShootPoint

@onready var isaac_robot: Node3D = $isaacRobot
var animPlayer: AnimationPlayer;

var hp := 3;
var currencyReward := 10;
var target : Node3D;
var sightRange := 15.0;

func _ready() -> void:
	target = get_parent().find_child("Player");
	animPlayer = isaac_robot.get_node("AnimationPlayer");
	animPlayer.play("idle_2sec");
	
func _physics_process(delta: float) -> void:
	head.look_at(target.global_position);
	
	isaac_robot.rotation.y = head.rotation.y;
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shoot_timer_timeout() -> void:
	animPlayer.play("fire");
	var bulletInstance = bullet.instantiate();
	get_parent().add_child(bulletInstance);
	bulletInstance.position = shoot_point.global_position;
	bulletInstance.direction = -head.transform.basis.z;
	bulletInstance.creator = self;
	#shoot_particles.restart();
	#shoot_sound.play();
		
	shoot_timer.wait_time = randf_range(3.0, 4.5);
	shoot_timer.start();
