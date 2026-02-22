extends RigidBody3D

@onready var kick_timer: Timer = $KickTimer
@onready var trail_particle: GPUParticles3D = $TrailParticle
const DEBRIS_PARTICLE = preload("uid://075if75cnruv")

var kicked := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var vec = (global_position - body.global_position).normalized();
		var dist = 80.0;
		vec.x *= dist;
		vec.z *= dist;
		vec.y = dist*.5;
		apply_force(vec);
		apply_torque(vec.normalized());
		trail_particle.restart();
		kicked = true;
		kick_timer.start();
	else:
		if kicked and kick_timer.time_left <= 0.0:
			var part = DEBRIS_PARTICLE.instantiate();
			get_parent().add_child(part);
			part.global_position = global_position;
			queue_free();
		#play trail particle
		#check for collision with wall and explode particle
