extends Area3D

@export var unlimited := false
@export var battery := 20.0
var batteryMax := 1.0
var dead := false

@export var connected: Node3D = null

@onready var outlet_light: MeshInstance3D = $OutletLight2

var _plug: Area3D = null

func _ready() -> void:
	batteryMax = battery
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	print("[Outlet] ready path=", get_path(), " connected=", connected)

func _process(delta: float) -> void:
	# No charge ever while plugged
	if _plug != null and is_instance_valid(_plug):
		battery = 0.0

	if !dead and _plug != null and is_instance_valid(_plug) and !unlimited:
		battery -= delta
		if battery <= 0.0:
			outlet_light.visible = false
			dead = true

func _on_area_entered(area: Area3D) -> void:
	if area.name.contains("OutletProjectile"):
		_plug = area
		connected = area
		print("[Outlet] PLUG CONNECTED:", area.name)

func _on_area_exited(area: Area3D) -> void:
	if _plug != null and area == _plug:
		print("[Outlet] PLUG DETACHED:", area.name)
		_plug = null
		connected = null

		var parent := get_parent()
		if parent != null and parent.has_method("on_pulled_detach"):
			parent.call("on_pulled_detach")
		else:
			push_warning("[Outlet] Parent missing on_pulled_detach() - attach pull_object.gd to PullObject root")	
