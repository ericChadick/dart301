extends Node3D

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles

func _ready() -> void:
	explosion_particles.restart();
	
func _on_explosion_particles_finished() -> void:
	queue_free();
