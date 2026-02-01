extends CharacterBody3D

const bullet = preload("uid://h8nfngcoc7cq")

@onready var shoot_timer: Timer = $ShootTimer
@onready var head: Node3D = $Head
@onready var shoot_point: Marker3D = $Head/ShootPoint

var hp := 3;
var currencyReward := 10;
var target : Node3D;
var sightRange := 15.0;

func _ready() -> void:
	target = get_parent().find_child("Player");
	
func _physics_process(delta: float) -> void:
	head.look_at(target.global_position);
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_shoot_timer_timeout() -> void:
	var bulletInstance = bullet.instantiate();
	get_parent().add_child(bulletInstance);
	bulletInstance.position = shoot_point.global_position;
	bulletInstance.direction = -head.transform.basis.z;
	bulletInstance.creator = self;
	#shoot_particles.restart();
	#shoot_sound.play();
		
	shoot_timer.wait_time = randf_range(3.0, 4.5);
	shoot_timer.start();
