@tool
extends Node3D

@onready var door_frame: CSGBox3D = $DoorFrame
@onready var door_frame_cutout: CSGBox3D = $DoorFrame/DoorFrameCutout
@onready var door: Node3D = $Door
@onready var door_mesh: MeshInstance3D = $Door/DoorMesh
@onready var static_body_3d: StaticBody3D = $Door/StaticBody3D
@onready var collision_shape_3d: CollisionShape3D = $Door/StaticBody3D/CollisionShape3D
@onready var outlet: Area3D = $Door/Outlet


@export var doorSize : Vector2 = Vector2.ONE*3.0:
	set(value):
		doorSize.x = value.x;
		doorSize.y = value.y;
		setDoorSize();
@export var doorFrameWidth : float = .5:
	set(value):
		doorFrameWidth = value;
		setDoorSize();
		
@export var doorBattery : float = 5.0:
	set(value):
		doorBattery = value;
		setDoorSize();

@export var frameMaterial : Material;
@export var doorMaterial : Material;

var drop := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !drop and outlet.battery <= 0.0:
		drop = true;
		outlet.queue_free();
	if drop:
		door.position.y = move_toward(door.position.y, -doorSize.y-doorFrameWidth*.5, delta*10.0);

func setDoorSize():
	if Engine.is_editor_hint():
		door_frame.size.x = doorSize.x+doorFrameWidth;
		door_frame.size.y = doorSize.y+doorFrameWidth;
		door_frame.position.y = door_frame.size.y*.5;
		door_frame.material_override = frameMaterial;
		
		door_mesh.mesh.size.x = doorSize.x;
		door_mesh.mesh.size.y = doorSize.y+doorFrameWidth*.5;
		door_mesh.position.y = doorSize.y*.5+doorFrameWidth*.25;
		door_mesh.material_override = doorMaterial;
		
		door_frame_cutout.size = door_mesh.mesh.size;
		door_frame_cutout.position.y = -doorFrameWidth*.25;
		
		collision_shape_3d.shape.size = door_mesh.mesh.size;
		collision_shape_3d.position.y = door_mesh.position.y;
		
		outlet.position.y = door_mesh.position.y;
		outlet.setBattery(doorBattery);
