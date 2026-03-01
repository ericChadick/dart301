extends Resource
class_name weaponUnlock;

#menu
@export var weaponIcon : AtlasTexture;
@export var weaponName : String = "Weapon";
@export var weaponDescription : String = "Description";

#in-game
@export var weaponScene : PackedScene;
@export var ammo : int = 3;
@export var energyCost := .25;
@export var chargeWeapon := false;
@export var chargeTimeMax := 2.0;

@export var slotSize := 1.0; #if we want certain weapons to take up more than 1 weapon slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
