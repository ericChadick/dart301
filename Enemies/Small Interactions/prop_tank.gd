extends Node3D

@onready var outlet: Area3D = $Outlet
@onready var rb: RigidBody3D = $RigidBody3D
@onready var explosion_area: Area3D = $RigidBody3D/ExplosionArea

@export var pull_speed: float = 25.0
@export var throw_speed: float = 45.0
@export var explosion_damage: float = 30.0

enum State { IDLE, PRIMED, LAUNCHED }
var state: State = State.IDLE
var _exploded: bool = false

func _ready() -> void:
	rb.freeze = true
	rb.sleeping = true
	rb.gravity_scale = 1.0
	rb.contact_monitor = true
	rb.max_contacts_reported = 4

	explosion_area.monitoring = false
	explosion_area.monitorable = false

	print("[PropTank] ready path=", get_path())

func _process(_delta: float) -> void:
	if outlet.pulled:
		outlet.pulled = false
		match state:
			State.IDLE:
				_pull_toward_player()
			State.PRIMED:
				_launch()

# Required by OutletPull.gd — called when cord disconnects
func on_pulled_detach() -> void:
	pass

func _pull_toward_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	rb.freeze = false
	rb.sleeping = false
	rb.linear_damp = 2.0

	var dir = (player.global_position - global_position).normalized()
	rb.apply_impulse(dir * pull_speed)

	state = State.PRIMED
	print("[PropTank] PRIMED — tank flying toward player")

func _launch() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	rb.freeze = false
	rb.sleeping = false
	rb.linear_damp = 0.0
	rb.linear_velocity = Vector3.ZERO

	var head = player.get_node_or_null("Head")
	var dir: Vector3
	if head:
		dir = -head.global_transform.basis.z
	else:
		dir = (global_position - player.global_position).normalized()

	rb.apply_impulse(dir * throw_speed)
	state = State.LAUNCHED

	rb.body_entered.connect(_on_impact)
	print("[PropTank] LAUNCHED in direction:", dir)

func _on_impact(_body: Node) -> void:
	_explode()

func _explode() -> void:
	if _exploded:
		return
	_exploded = true

	rb.body_entered.disconnect(_on_impact)
	explosion_area.monitoring = true
	explosion_area.monitorable = true

	await get_tree().physics_frame

	for body in explosion_area.get_overlapping_bodies():
		_apply_damage(body)

	queue_free()

func _apply_damage(target: Node) -> void:
	if target.is_in_group("player") or target.is_in_group("enemy"):
		if target.has_method("take_damage"):
			target.call("take_damage", explosion_damage)
		elif "hp" in target:
			target.set("hp", float(target.get("hp")) - explosion_damage)
