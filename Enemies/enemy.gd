class_name Enemy
extends CharacterBody3D

@export var health_bar: ProgressBar
@export var max_health: int = 100
@export var speed: float = 8.0
@export var accel: float = 12.0
@export var eye_height: float = 1.5
@export var vision_range: float = 25.0
@export var vision_fov_degrees: float = 90.0
@export var vision_mask: int = 1  


@onready var nav: NavigationAgent3D = $NavigationAgent3D

# Behavior tree writes this (desired direction)
var move_direction: Vector3 = Vector3.ZERO

# internal health storage (your setter was recursive and broken)
var _health: int = 0
var health: int:
	get: return _health
	set(value):
		_health = clamp(value, 0, max_health)
		if health_bar:
			health_bar.value = _health
		if _health <= 0:
			queue_free()

func _ready() -> void:
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	add_to_group("enemies")

	# NavigationAgent defaults can be trash; set something sane
	if nav:
		nav.path_desired_distance = 0.3
		nav.target_desired_distance = 1.2
		nav.avoidance_enabled = true

func _physics_process(delta: float) -> void:
	# Convert BT direction into velocity with acceleration smoothing
	var desired := move_direction * speed
	velocity = velocity.lerp(desired, 1.0 - exp(-accel * delta))

	# CharacterBody3D handles collisions here
	move_and_slide()
