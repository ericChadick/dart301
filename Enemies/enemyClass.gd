extends Resource
class_name enemyType;

@export_category("Stats")
@export var hp := 3.0;
@export var currencyReward := 50.0;

@export_category("Sight")
@export var eyeNode : NodePath;
@export var sightRange := 15.0;
@export var agroRange := 25.0;
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

#remove part from enemy model
func removePart():
	var parts = partsBreak;
	if parts.size() > 0:
		var partSelect = parts[randi_range(0, parts.size()-1)];
		parts[partSelect].visible = false;
		parts.remove_at(partSelect);
