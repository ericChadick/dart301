extends Node

#stats
var currency := 100.0;

enum PlayerWeapon {FIST, GUN, FLAME}
enum PlayerParts {EMPTY, WALLASCEND, WALLSTICK, WALLTIMEINCREASE, DOUBLEJUMP, CORDLENGTHEN, CORDFLOAT, 
PROJECTILEBOUNCE, AIRSLIDE, SCREENCRACKREMOVE}

var weaponSlots := 2;
var partSlots := 4;

var weaponsEquipped : Array[weaponUnlock];
var partsEquipped : Array[equipPart];

var weaponsUnlocked : Array[weaponUnlock];
var partsUnlocked : Array[equipPart];

var hpMin := 10.0; #initial unupgraded value of stat
var hpMax := 20.0; #max value of stat after all upgrades
var hpLevel := 0; #current level the stat has been upgraded to
var hpLevelMax := 10; #max level the stat can be upgraded to

var batteryMin := 10.0;
var batteryMax := 15.0;
var batteryLevel := 0;
var batteryLevelMax := 10;

var cordLengthMin := 15.0;#10.0;
var cordLengthMax := 20.0;
var cordLengthLevel := 0;
var cordLengthLevelMax := 10;

var spdMin := 12.0;
var spdMax := 15.0;
var spdLevel := 0;
var spdLevelMax := 8;

var jumpSpdMin := 15.0;
var jumpSpdMax := 25.0;
var jumpSpdLevel := 0;
var jumpSpdLevelMax := 8;

var dashSpdMin := 20.0;
var dashSpdMax := 60.0;
var dashSpdLevel := 0;
var dashSpdLevelMax := 5;

var dataMultiplierMin := 1.0;
var dataMultiplierMax := 4.0;
var dataMultiplierLevel := 0;
var dataMultiplierLevelMax := 10;

var dashUnlocked := false;
var dashPurchased := false;
var jumpUnlocked := false;
var jumpPurchased := false;
var jetUnlocked := false;
var jetPurchased := false;
var gunUnlocked := false;
var gunPurchased := false;

#general settings
var screenShake := 1.0;
var brightness := .5;
var musicVolume := .75;

#debug
var mainScene : NodePath;
var batteryDecreaseDebug := true;

var flipHands := false;

#input rebinding

#screen cracks
enum ScreenCracks {SMALL, MED, LARGE}


func _ready() -> void:
	#for debugging set weapons and parts unlocked by default
	const ENERGY_GUN = preload("uid://uh4d532c1ca7")
	const FLAME_GUN = preload("uid://da1f3cj0g8erj")
	weaponsUnlocked.append(ENERGY_GUN);
	weaponsUnlocked.append(FLAME_GUN);
	
	const DOUBLE_JUMP_PART = preload("uid://ccf2eq1vsqklf")
	const WALL_ASCEND_PART = preload("uid://c3qtj882mefqb")
	const WALL_STICK_PART = preload("uid://b1sjnu3as5j1t")
	partsUnlocked.append(DOUBLE_JUMP_PART);
	partsUnlocked.append(WALL_ASCEND_PART);
	partsUnlocked.append(WALL_STICK_PART);
	#partsUnlocked.append(DOUBLE_JUMP_PART);
