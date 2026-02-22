@tool
extends HBoxContainer

@onready var button: TextureButton = $Button
@onready var costTxt: RichTextLabel = $Cost
@onready var levelTxt: RichTextLabel = $Level
@onready var progress_bar: ProgressBar = $Level/ProgressBar
@onready var purchase_sound: AudioStreamPlayer = $PurchaseSound

@export var iconTexture: Texture2D;
var level := 0;
var levelMax := 8;
#var initCost := 10;
var levelCost := 0;
var costMultiplier := 5.0;

var stat = "";

func calculateCost():
	levelCost = int(pow(level+1, 2)*costMultiplier);
	#if level == 0:
	#	return int(initCost);
	#else:
	#	return int(level*level*costMultiplier);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stat = name.replace("UpgradeMeter", "");
	match(stat):
		"Battery": levelMax = Global.batteryLevelMax;
		"Health": levelMax = Global.hpLevelMax;
		"Speed": levelMax = Global.spdLevelMax;
		"Jump": levelMax = Global.jumpSpdLevelMax;
		"Cord": levelMax = Global.cordLengthLevelMax;
		"Multiplier": levelMax = Global.dataMultiplierLevelMax;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button.texture_normal = iconTexture;
	costTxt.text = str(levelCost);
	levelTxt.text = str(level) + "/" + str(levelMax);
	progress_bar.value = float(level)/float(levelMax);
	
	queue_redraw();


func _on_button_pressed() -> void:
	if Global.currency >= levelCost and level < levelMax:
		Global.currency -= levelCost
		purchase_sound.play();
		#stat = name.replace("UpgradeMeter", "");
		match(stat):
			"Battery":Global.batteryLevel+=1; level = Global.batteryLevel;
			"Health":Global.hpLevel+=1; level = Global.hpLevel;
			"Speed":Global.spdLevel+=1; level = Global.spdLevel;
			"Jump":Global.jumpSpdLevel+=1; level = Global.jumpSpdLevel;
			"Cord":Global.cordLengthLevel+=1; level = Global.cordLengthLevel;
			"Multiplier":Global.dataMultiplierLevel+=1; level = Global.dataMultiplierLevel;
		calculateCost();
