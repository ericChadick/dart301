extends Resource
class_name equipPart

@export var partName : String = "PartName";
@export var partEnum : Global.PlayerParts;
@export var partIcon : AtlasTexture;
#upgrade menu visuals
@export var partHighlightTexture : AtlasTexture;
@export var partSelectedTexture : AtlasTexture;
@export var partMenuOffset : Vector2 = Vector2.ZERO;
#if we get there, the model of the part that will appear on the player in-game
@export var partHasModel : bool = false;
@export var boneAttach : NodePath;
@export var partModel : PackedScene; #contains offset, extra effects

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
