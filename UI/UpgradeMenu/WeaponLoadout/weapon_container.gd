#@tool
extends Button

@export var weaponInd : weaponUnlock;
const WEAPON_EMPTY = preload("uid://b70etp772do5m")

@onready var weapon_icon: TextureRect = $HBoxContainer/MarginContainer/WeaponIcon
@onready var info_container: VBoxContainer = $HBoxContainer/InfoContainer
@onready var weapon_name: RichTextLabel = $HBoxContainer/InfoContainer/WeaponName
@onready var upgrade_confirm: ColorRect = $HBoxContainer/UpgradeConfirm
@onready var upgrade_back: ColorRect = $HBoxContainer/UpgradeConfirm/UpgradeBack
@onready var upgrade_back_2: ColorRect = $HBoxContainer/UpgradeConfirm/UpgradeBack2

@onready var upgrade_bar: ProgressBar = $UpgradeBar

@onready var upgrade_container: HBoxContainer = $HBoxContainer/InfoContainer/UpgradeContainer
@onready var upgrade_cost: RichTextLabel = $HBoxContainer/InfoContainer/UpgradeContainer/UpgradeCost

var heightDefault : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heightDefault = size.y;
	
	var matCopy = upgrade_confirm.material.duplicate();
	upgrade_confirm.material = matCopy;
	upgrade_confirm.material.set("shader_parameter/progress", 0.0);
	upgrade_bar.value = 0.0;
	
	matCopy = upgrade_back.material.duplicate();
	upgrade_back.material = matCopy;
	matCopy = upgrade_back_2.material.duplicate();
	upgrade_back_2.material = matCopy;
	
	#Global.PlayerWeapon.GUN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if weaponInd.weaponInd == Global.PlayerWeapon.FIST: #!=
		if get_parent() == get_viewport().gui_get_focus_owner().get_parent():
			custom_minimum_size.y = lerp(custom_minimum_size.y, heightDefault, delta*10.0);
		else:
			custom_minimum_size.y = lerp(custom_minimum_size.y, 0.0, delta*10.0);
		upgrade_confirm.visible = false;
		info_container.visible = false;
	
	#if get_parent() == get_viewport().gui_get_focus_owner().get_parent():
		
	weapon_icon.texture = weaponInd.weaponIcon;
	weapon_name.text = weaponInd.weaponName;
	
	queue_redraw();
