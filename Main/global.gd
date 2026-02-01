extends Node

#stats
var currency := 10000;

var hpMin := 10.0; #initial unupgraded value of stat
var hpMax := 50.0; #max value of stat after all upgrades
var hpLevel := 0; #current level the stat has been upgraded to
var hpLevelMax := 10; #max level the stat can be upgraded to

var batteryMin := 5.0;
var batteryMax := 15.0;
var batteryLevel := 0;
var batteryLevelMax := 10;

#var batteryDecRate = .4;#.15;

var cordLengthMin := 10.0;
var cordLengthMax := 30.0;
var cordLengthLevel := 0;
var cordLengthLevelMax := 10;

var spdMin := 5.0;
var spdMax := 12.0;
var spdLevel := 0;
var spdLevelMax := 8;

var jumpSpdMin := 5.0;
var jumpSpdMax := 20.0;
var jumpSpdLevel := 0;
var jumpSpdLevelMax := 8;

var dashSpdMin := 20.0;
var dashSpdMax := 60.0;
var dashSpdLevel := 0;
var dashSpdLevelMax := 5;

var dashUnlocked := false;
var jumpUnlocked := false;
var jetUnlocked := false;
var gunUnlocked := false;

#general settings
var screenShake := 1.0;
var brightness := .5;
var musicVolume := .75;

#input rebinding
