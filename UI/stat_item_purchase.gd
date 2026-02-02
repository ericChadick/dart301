@tool
extends HBoxContainer

@onready var button: TextureButton = $Button
@onready var costTxt: RichTextLabel = $Cost
@onready var purchase_sound: AudioStreamPlayer = $PurchaseSound

@export var iconTexture: Texture2D;
@export var itemCost : float = 100.0;

var unlocked := false;
var purchased := false;
var stat := "";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stat = name.replace("PurchaseButton", "");
	match(stat):
		"Gun": unlocked = Global.gunUnlocked; purchased = Global.gunPurchased;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button.texture_normal = iconTexture;
	costTxt.text = str(itemCost);
	if !unlocked:
		button.modulate = Color.GRAY;
	else:
		if !purchased:
			button.modulate = Color.RED;
		else:
			button.modulate = Color.WHITE;
			costTxt.visible = false;
	queue_redraw();

func _on_button_pressed() -> void:
	if !purchased and Global.currency >= itemCost and unlocked:
		Global.currency -= itemCost
		purchase_sound.play();
		match(stat):
			"Gun":Global.gunPurchased = true; purchased = Global.gunPurchased; 
