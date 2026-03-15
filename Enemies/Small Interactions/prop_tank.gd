extends Node3D

@onready var rb: RigidBody3D = $RigidBody3D
@onready var explosion_area: Area3D = $RigidBody3D/ExplosionArea
@onready var tank_ex: Node3D = $PropTankEX
@onready var propane_ex: Node3D = $PropaneEX

@export var interact_range: float = 15.0
@export var pull_speed: float = 25.0
@export var throw_speed: float = 20.0
@export var explosion_damage: float = 30.0

enum State { IDLE, PRIMED, LAUNCHED }
var state: State = State.IDLE
var _exploded: bool = false
var _debug_timer: float = 0.0

func _ready() -> void:
	rb.freeze = true
	rb.sleeping = true
	rb.gravity_scale = 1.0
	rb.contact_monitor = true
	rb.max_contacts_reported = 4
	explosion_area.monitoring = false
	explosion_area.monitorable = false
	explosion_area.collision_mask = 1
	tank_ex.visible = false
	propane_ex.visible = false
	print("[PropTank] ready, state=IDLE")

func _process(delta: float) -> void:
	# Print distance every second so you can see when you're in range
	_debug_timer += delta
	if _debug_timer >= 1.0:
		_debug_timer = 0.0
		var p = get_tree().get_first_node_in_group("player")
		if p:
			var d = global_position.distance_to(p.global_position)
			print("[PropTank] dist=", snappedf(d, 0.1), " range=", interact_range, " state=", State.keys()[state])

	var player = get_tree().get_first_node_in_group("player")
	if player and state == State.PRIMED:
		_process_primed(player)

	if not Input.is_action_just_pressed("interact"):
		return
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)

	match state:
		State.IDLE:
			if dist <= interact_range:
				print("[PropTank] E pressed — pulling tank, dist=", dist)
				_pull_toward_player(player)
			else:
				print("[PropTank] E pressed but too far, dist=", dist)
		State.PRIMED:
			print("[PropTank] E pressed — launching tank")
			_launch(player)

func _pull_toward_player(player: Node) -> void:
	state = State.PRIMED
	print("[PropTank] PRIMED — held in front of player")

func _process_primed(player: Node) -> void:
	# Keep tank locked in front of player at chest height
	var head = player.get_node_or_null("Head")
	var forward: Vector3
	if head:
		forward = -head.global_transform.basis.z
	else:
		forward = -player.global_transform.basis.z
	var hold_pos = player.global_position + Vector3(0, 1.0, 0) + forward * 1.5
	rb.freeze = true
	rb.global_position = hold_pos

func _launch(player: Node) -> void:
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
	# Flatten direction so it doesn't shoot into the ground
	dir.y = clampf(dir.y, -0.2, 0.4)
	dir = dir.normalized()

	rb.apply_impulse(dir * throw_speed)
	state = State.LAUNCHED
	rb.body_entered.connect(_on_impact)
	print("[PropTank] LAUNCHED in direction: ", dir)

func _on_impact(_body: Node) -> void:
	if _body.is_in_group("player"):
		return
	print("[PropTank] IMPACT with: ", _body.name)
	_explode()

func _explode() -> void:
	if _exploded:
		return
	_exploded = true
	rb.body_entered.disconnect(_on_impact)
	explosion_area.monitoring = true
	explosion_area.monitorable = true
	await get_tree().physics_frame
	var bodies = explosion_area.get_overlapping_bodies()
	print("[PropTank] EXPLODE — ", bodies.size(), " bodies in range")
	for body in bodies:
		_apply_damage(body)

	# Hide live tank, show destroyed version and particles at impact position
	rb.visible = false
	tank_ex.global_position = rb.global_position
	tank_ex.visible = true
	propane_ex.global_position = rb.global_position
	propane_ex.visible = true
	propane_ex.explode()
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _apply_damage(target: Node) -> void:
	if target.is_in_group("player") or target.is_in_group("enemy"):
		if target.has_method("take_damage"):
			target.call("take_damage", explosion_damage)
		elif "hp" in target:
			target.set("hp", float(target.get("hp")) - explosion_damage)
