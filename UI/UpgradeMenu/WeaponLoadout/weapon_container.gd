#@tool
extends Button

@export var weaponInd : weaponUnlock;
@onready var weapon_icon: TextureRect = $HBoxContainer/WeaponIcon
@onready var weapon_name: RichTextLabel = $HBoxContainer/WeaponName
@onready var weapon_description: RichTextLabel = $HBoxContainer/WeaponName/WeaponDescription
@onready var ammo: RichTextLabel = $HBoxContainer/Ammo
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var equipped_icon: TextureRect = $EquippedIcon

var heightDefault : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	heightDefault = size.y;
	#Global.PlayerWeapon.GUN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if weaponInd.weaponInd != Global.PlayerWeapon.FIST:
		if self == get_viewport().gui_get_focus_owner():
			custom_minimum_size.y = lerp(custom_minimum_size.y, heightDefault*2.0, delta*10.0);
		else:
			custom_minimum_size.y = lerp(custom_minimum_size.y, heightDefault, delta*10.0);
	else:
		if get_parent() == get_viewport().gui_get_focus_owner().get_parent():
		#self == get_viewport().gui_get_focus_owner():
			custom_minimum_size.y = lerp(custom_minimum_size.y, heightDefault, delta*10.0);
		else:
			custom_minimum_size.y = lerp(custom_minimum_size.y, 0.0, delta*10.0);
		ammo.visible = false;
		
	weapon_icon.texture = weaponInd.weaponIcon;
	weapon_name.text = weaponInd.weaponName;
	weapon_description.text = weaponInd.weaponDescription;
	ammo.text = str(weaponInd.ammo);
	queue_redraw();
