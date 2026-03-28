extends Resource
class_name equipPart

@export var partName : String = "PartName";
@export var fileName : String = "part.prt";
@export var partDescription : String = "PartDescription";
@export var partEnum : Global.PlayerParts;
@export var partCost : int = 2;
@export var partIcon : AtlasTexture;

#upgrade menu visuals
@export var partHighlightTexture : AtlasTexture;
@export var partSelectedTexture : AtlasTexture;
@export var partMenuOffset : Vector2 = Vector2.ZERO;
#if we get there, the model of the part that will appear on the player in-game
@export var partHasModel : bool = false;
@export var boneAttach : NodePath;
@export var partModel : PackedScene; #contains offset, extra effects

@export var partMenuModel : PackedScene; #contains offset, extra effects
@export var partMenuPosition : Vector3;
@export var partMenuRotation : Vector3;
@export var partMenuScale : Vector3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
