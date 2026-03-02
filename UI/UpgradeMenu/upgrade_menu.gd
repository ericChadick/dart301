extends CanvasLayer

@onready var currency: RichTextLabel = $Control/MarginContainer/Currency

@onready var battery_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/BatteryUpgradeMeter
@onready var health_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/HealthUpgradeMeter
@onready var speed_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/SpeedUpgradeMeter
@onready var cord_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/CordUpgradeMeter
@onready var jump_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/JumpUpgradeMeter
@onready var multiplier_upgrade_meter: HBoxContainer = $Control/MarginContainer/HBoxContainer/StatUpgradeContainer/MultiplierUpgradeMeter

@onready var cycle_sound: AudioStreamPlayer = $Audio/CycleSound
@onready var equip_sound: AudioStreamPlayer = $Audio/EquipSound
@onready var weapon_equip_sound: AudioStreamPlayer = $Audio/WeaponEquipSound

var hoverPrev : TextureButton;
var hoverCurrent : TextureButton;

@onready var battery_debug: TextureButton = $Control/MarginContainer/HBoxContainer2/BatteryDebug
@onready var cord_debug: HSlider = $Control/MarginContainer/HBoxContainer2/CordDebug

@onready var focus_debug: TextureRect = $FocusDebug
#default focus owner
@onready var weapon_loadout_slot: TextureRect = $Control/MarginContainer/HBoxContainer/WeaponLoadout/WeaponLoadoutSlot


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hoverPrev = null;
	hoverCurrent = null;
	
	#set debug
	cord_debug.value = Global.cordLengthMin;
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	#update all stat upgrade meters
	
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
		
	Global.cordLengthMin = cord_debug.value;
	
	
	
	
	#weapon_loadout_slot.call_deferred("grab_focus")
	#var focused = get_viewport().gui_get_focus_owner();
	#print(focused);
	#if focused != null:
	#	focus_debug.global_position = focused.global_position;

func _on_go_button_pressed() -> void:
	get_tree().change_scene_to_file(Global.mainScene);
	#get_tree().change_scene_to_file("res://World/world.tscn");


func _on_battery_debug_pressed() -> void:
	Global.batteryDecreaseDebug = !Global.batteryDecreaseDebug;
	if Global.batteryDecreaseDebug:
		battery_debug.modulate = Color.YELLOW;
	else:
		battery_debug.modulate = Color.WHITE;


func _on_control_focus_entered() -> void:
	print("Focus node");
