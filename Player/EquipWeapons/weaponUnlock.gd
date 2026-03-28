extends Resource
class_name weaponUnlock;

#menu
@export var weaponIcon : AtlasTexture;
@export var weaponInd : Global.PlayerWeapon;
@export var weaponName : String = "Weapon";
@export var fileName : String = "weapon.wpn";
@export var weaponDescription : String = "Description";

#in-game
@export var weaponScene : PackedScene;

@export var weaponPositionOffset : Vector3;
@export var weaponRotationOffset : Vector3;
@export var weaponScaleOffset : Vector3 = Vector3.ONE;

@export var weaponModelScene : PackedScene;

#@export var projectileInst: PackedScene;

@export var upgradeLevel : int = 1;
@export var upgradeLevelMax : int = 5;
@export var upgradeBaseCost : int = 50;
@export var upgradeGrowthRate : float = .5;
var newUpgradeCost : float = 0.0;

@export var ammoUpgradeRate : float = 1.0; #.5 = 2 levels to increase ammo capacity
@export var energyUpgradeRate : float = .1; #amount to decrease energy cost with each level
@export var damageUpgradeRate : float = .5; #amount to increase damage with each level
#@export var speedUpgradeRate : float = .5; #amount to decrease damage with each level

@export var ammo : int = 3;
var ammoBase := ammo;
var ammoMax := int(ammoBase+upgradeLevelMax*ammoUpgradeRate);

@export var energyCost := .25;
var energyCostBase := energyCost;
var energyCostMax := float(energyCostBase+upgradeLevelMax*energyUpgradeRate)

@export var damage : float = 1.0;
var damageBase := damage;
var damageMax := float(damageBase+upgradeLevelMax*damageUpgradeRate)

@export var chargeWeapon := false;
@export var chargeTimeMax := 2.0;
@export var slotSize := 1.0; #if we want certain weapons to take up more than 1 weapon slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func calculateUpgradeCost():
	newUpgradeCost = upgradeBaseCost*pow(1.0+upgradeGrowthRate, upgradeLevel-1);
