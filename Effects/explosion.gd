extends Node3D

@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var data_particles: GPUParticles3D = $DataParticles

func _ready() -> void:
	explosion_particles.restart();
	data_particles.restart();
	
func _on_explosion_particles_finished() -> void:
	pass;#queue_free();


func _on_timer_timeout() -> void:
	queue_free();
