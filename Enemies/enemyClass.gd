extends Resource
class_name enemyType;

@export_category("Stats")
@export var hp := 3.0;
@export var currencyReward := 50.0;

@export_category("Sight")
@export var eyeNode : NodePath;
@export var sightRange := 25.0;
@export var agroRange := 50.0;
@export var distanceKeepRange := 20.0;
@export var sightAngle := 60.0;
@export var angleVision := false;
@export var sightRaycastNode : NodePath;
@export var raycastVision := false;

@export_category("Movement")
@export var walkSpeed := 8.0;
@export var runSpeed := 15.0;
@export var gravity := 20.0;

@export_category("Visual")
@export var partsBreak : Array;

var eye : Node3D;
var sightRay : Node3D;

func updatePaths():
	pass;#eye.get_node()
	#eye = get_node(eyeNode);
