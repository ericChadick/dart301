extends Node3D

@onready var outlet: Area3D = $Outlet
@onready var rb: RigidBody3D = $RigidBody3D
@onready var no_more_damage: RayCast3D = $NoMoreDamage
@onready var damage_area: Area3D = $RigidBody3D/DamageArea

@export var damage_per_second: float = 5.0
@export var despawn_delay: float = 5.0

var damage_enabled: bool = false
var despawn_started: bool = false
var _detach_grace: float = 0.0
var _touching: Array[Node] = []

func _ready() -> void:
	if rb == null:
		push_error("[PullObject] Missing RigidBody3D at $RigidBody3D. Fix your tree.")
		return
	if damage_area == null:
		push_error("[PullObject] Missing DamageArea at $RigidBody3D/DamageArea. Fix your tree.")
		return

	# Start frozen (attached)
	rb.freeze = true
	rb.sleeping = true
	rb.gravity_scale = 1.0

	damage_enabled = false
	despawn_started = false
	_detach_grace = 0.0

	no_more_damage.enabled = true

	damage_area.body_entered.connect(_on_damage_body_entered)
	damage_area.body_exited.connect(_on_damage_body_exited)

	print("[PullObject] ready path=", get_path())

func on_pulled_detach() -> void:
	if despawn_started or rb == null:
		return

	print("[PullObject] DETACH fired -> unfreeze")

	# Unfreeze so it falls
	rb.freeze = false
	rb.sleeping = false
	rb.gravity_scale = 1.0

	# tiny impulse so you SEE it detach
	rb.apply_impulse(Vector3(0, 2.0, 0))

	damage_enabled = true
	_detach_grace = 0.15

func _physics_process(delta: float) -> void:
	if rb == null:
		return

	# While attached, keep frozen
	if not damage_enabled:
		# outlet.connected is the plug projectile when latched
		if outlet.get("connected") != null:
			rb.freeze = true
			rb.sleeping = true
		return

	_detach_grace = max(0.0, _detach_grace - delta)

	# Stop damage once ray hits ground (after grace)
	if _detach_grace <= 0.0 and no_more_damage.is_colliding():
		print("[PullObject] ground detected -> stop + despawn")
		damage_enabled = false
		_start_despawn()
		return

	# Apply DPS to anything we are overlapping
	if _touching.size() > 0:
		var dmg := damage_per_second * delta
		for n in _touching:
			if n != null:
				_apply_damage(n, dmg)

func _on_damage_body_entered(body: Node) -> void:
	if body == null:
		return
	if not _touching.has(body):
		_touching.append(body)
		print("[PullObject] DamageArea touched:", body.name)

func _on_damage_body_exited(body: Node) -> void:
	_touching.erase(body)

func _apply_damage(target: Node, dmg: float) -> void:
	if target.is_in_group("player") or target.is_in_group("enemy"):
		if target.has_method("take_damage"):
			target.call("take_damage", dmg)
		elif "hp" in target:
			target.set("hp", float(target.get("hp")) - dmg)

func _start_despawn() -> void:
	if despawn_started:
		return
	despawn_started = true

	# freeze on ground
	rb.freeze = true
	rb.sleeping = true

	await get_tree().create_timer(despawn_delay).timeout
	queue_free()
