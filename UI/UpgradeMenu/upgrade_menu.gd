extends CanvasLayer

@onready var currency: RichTextLabel = $Control/MarginContainer/Currency

@onready var battery_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/BatteryUpgradeMeter
@onready var health_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/HealthUpgradeMeter
@onready var speed_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/SpeedUpgradeMeter
@onready var cord_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/CordUpgradeMeter
@onready var jump_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/JumpUpgradeMeter
@onready var multiplier_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/MultiplierUpgradeMeter

@onready var cycle_sound: AudioStreamPlayer = $Audio/CycleSound

var hoverPrev : TextureButton;
var hoverCurrent : TextureButton;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hoverPrev = null;
	hoverCurrent = null;
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	#update all stat upgrade meters
	#battery
	battery_upgrade_meter.level = Global.batteryLevel;
	battery_upgrade_meter.levelMax = Global.batteryLevelMax;
	battery_upgrade_meter.costMultiplier = 5.0;
	battery_upgrade_meter.calculateCost();
	#health
	health_upgrade_meter.level = Global.hpLevel;
	health_upgrade_meter.levelMax = Global.hpLevelMax;
	health_upgrade_meter.costMultiplier = 3.0;
	health_upgrade_meter.calculateCost();
	#speed
	speed_upgrade_meter.level = Global.spdLevel;
	speed_upgrade_meter.levelMax = Global.spdLevelMax;
	speed_upgrade_meter.costMultiplier = 6.0;
	speed_upgrade_meter.calculateCost();
	#jump
	jump_upgrade_meter.level = Global.jumpSpdLevel;
	jump_upgrade_meter.levelMax = Global.jumpSpdLevelMax;
	jump_upgrade_meter.costMultiplier = 8.0;
	jump_upgrade_meter.calculateCost();
	#jump
	cord_upgrade_meter.level = Global.cordLengthLevel;
	cord_upgrade_meter.levelMax = Global.cordLengthLevelMax;
	cord_upgrade_meter.costMultiplier = 5.0;
	cord_upgrade_meter.calculateCost();
	#multiplier
	multiplier_upgrade_meter.level = Global.dataMultiplierLevel;
	multiplier_upgrade_meter.levelMax = Global.dataMultiplierLevelMax;
	multiplier_upgrade_meter.costMultiplier = 8.0;
	multiplier_upgrade_meter.calculateCost();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	currency.text = str(int(Global.currency));
	
	hoverPrev = hoverCurrent;
	var hoverButton = get_viewport().gui_get_hovered_control();
	if hoverButton != null and hoverButton.get_class() == "TextureButton":
		hoverCurrent = hoverButton;
	#play cycle sound
	if hoverCurrent != hoverPrev:
		cycle_sound.play();

func _on_go_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.mainScene);
	#get_tree().change_scene_to_file("res://World/world.tscn");


func _on_battery_debug_pressed() -> void:
	Global.batteryDecreaseDebug = !Global.batteryDecreaseDebug;
