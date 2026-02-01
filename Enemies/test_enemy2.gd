extends CharacterBody3D

var hp := 3;
var currencyReward := 10;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
