#@tool
extends TextureButton

@onready var weapon_icon: TextureRect = $WeaponIcon

@export var weaponInd : weaponUnlock;

var slotIndex := 1;

var topRow := false;
var bottomRow := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if slotIndex <= Global.weaponSlots:
		weapon_icon.texture = weaponInd.weaponIcon;
	else:
		self_modulate.a = 0.0;
		mouse_filter = Control.MOUSE_FILTER_IGNORE;
		
	queue_redraw();
