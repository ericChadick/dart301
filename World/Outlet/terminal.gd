extends Node3D

@onready var attach_cylinder: MeshInstance3D = $attachCylinder
@onready var outlet: Area3D = $attachCylinder/Outlet
var target : Node3D;

@export var unlimited := false;
@export var battery := 20.0;
@export var connected : Node3D;

@onready var battery_fill: MeshInstance3D = $BatteryFill
var batteryFillY : float;
var batteryHeight : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_parent().find_child("Player");
	outlet.unlimited = unlimited;
	outlet.battery = battery;
	outlet.connected = connected;
	
	batteryFillY = battery_fill.position.y;
	batteryHeight = battery_fill.mesh.height;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if outlet.connected != null:
		attach_cylinder.look_at(outlet.connected.global_position);
	else:
		attach_cylinder.look_at(target.global_position);
		
	attach_cylinder.rotation_degrees.y += 90;
	attach_cylinder.rotation.x = 0.0;
	attach_cylinder.rotation.z = 0.0;
	
	battery_fill.position.y = batteryFillY-(1.0-(outlet.battery/outlet.batteryMax))*batteryHeight;
