extends Node

#stats
var currency := 100.0;

enum PlayerWeapon {FIST, GUN, FLAME}

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

#input rebinding


#screen cracks
enum ScreenCracks {SMALL, MED, LARGE}
