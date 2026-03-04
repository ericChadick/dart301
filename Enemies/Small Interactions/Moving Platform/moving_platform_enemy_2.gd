extends AnimatableBody3D

## How far the platform moves from its starting position on each axis (0 = no movement on that axis)
@export var wander_distance: Vector3 = Vector3(0, 0, 10)
@export var SPEED: float = 1.0

var start_position: Vector3
var wander_target: Vector3
var moving_to_end: bool = true
var is_ready: bool = false


func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	await get_tree().physics_frame
	start_position = global_position
	wander_target = start_position + wander_distance
	is_ready = true


func _physics_process(delta: float) -> void:
	if not is_ready:
		return

	var to_target = wander_target - global_position
	if to_target.length() < 0.1:
		if moving_to_end:
			wander_target = start_position - wander_distance
		else:
			wander_target = start_position + wander_distance
		moving_to_end = !moving_to_end
		to_target = wander_target - global_position

	move_and_collide(to_target.normalized() * SPEED * delta)
