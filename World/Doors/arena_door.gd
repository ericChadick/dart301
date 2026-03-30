@tool
extends Node3D

@onready var door_frame: CSGBox3D = $DoorFrame
@onready var door_frame_cutout: CSGBox3D = $DoorFrame/DoorFrameCutout
@onready var door: Node3D = $Door
@onready var door_mesh: MeshInstance3D = $Door/DoorMesh
@onready var static_body_3d: StaticBody3D = $Door/StaticBody3D
@onready var collision_shape_3d: CollisionShape3D = $Door/StaticBody3D/CollisionShape3D

@export var doorSize : Vector2 = Vector2.ONE*3.0:
	set(value):
		doorSize.x = value.x;
		doorSize.y = value.y;
		setDoorSize();
@export var doorFrameWidth : float = .5:
	set(value):
		doorFrameWidth = value;
		setDoorSize();
		
@export var frameMaterial : Material;
@export var doorMaterial : Material;

@export var arenaEnemies : Array[Node3D];
@export var enterShape : Area3D;

var drop := true;
var enemies := 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	door.position.y = -doorSize.y-doorFrameWidth*.5;
	enemies = arenaEnemies.size();
	
	if enterShape != null:
		enterShape.body_entered.connect(activateArena);
		print("SIGNAL");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#drop door after 
	var killed := 0;
	for i in enemies:
		if arenaEnemies.get(i) == null:
			killed += 1;
	if killed == enemies:
		drop = true;
	
	if drop:
		door.position.y = move_toward(door.position.y, -doorSize.y-doorFrameWidth*.5, delta*10.0);
	else:
		door.position.y = move_toward(door.position.y, 0.0, delta*10.0);

func activateArena(body : Node3D):
	if body.is_in_group("player"):
		drop = false;
		print("ACTIVATE");
	
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
