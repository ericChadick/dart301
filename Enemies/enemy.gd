class_name Enemy
extends Node3D

@export var health_bar: ProgressBar
@export var max_health: int = 100
@export var speed: float = 1.0

var health: int = 100:
	set(value):
		health = value
		if health_bar:
			health_bar.value = health
		if health <= 0:
			queue_free()

var move_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	add_to_group("enemies")

func _process(delta: float) -> void:
	position += move_direction * speed * delta
