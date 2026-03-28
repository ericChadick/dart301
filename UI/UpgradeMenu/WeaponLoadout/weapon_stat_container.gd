@tool
extends MarginContainer

enum statType {AMMO, ENERGY, DAMAGE} #, FIRERATE

var canAfford := false;

var maxEnergy := 4.0;
var maxDamage := 8.0;

@export var statBarType: statType;
@export var statIcon : Texture2D;
@export var weaponType : weaponUnlock;

@onready var display_stats: HBoxContainer = $DisplayStats
@onready var stat_icon: TextureRect = $DisplayStats/StatIcon

#weapon dependent
@onready var stat_bar: ProgressBar = $DisplayStats/StatBar
@onready var preview_bar: ProgressBar = $DisplayStats/StatBar/PreviewBar
@onready var slider_point: TextureRect = $DisplayStats/StatBar/SliderPoint
@onready var stat_value: RichTextLabel = $DisplayStats/StatValue
@onready var upgrade_new_icon: TextureRect = $DisplayStats/UpgradeNewIcon
@onready var stat_new_value: RichTextLabel = $DisplayStats/StatNewValue
@onready var upgrade_difference_icon: TextureRect = $DisplayStats/UpgradeDifferenceIcon

const WEAPON_EMPTY = preload("uid://b70etp772do5m")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stat_icon.texture = statIcon;
	if weaponType != WEAPON_EMPTY:
		var w = weaponType;
		display_stats.visible = true;
		if !canAfford:
			modulate = Color.GRAY;
			preview_bar.value = 0.0;
		else:
			modulate = Color.WHITE;
		match (statBarType):
			statType.AMMO:
				stat_value.text = str(w.ammo);
				stat_bar.value = float(w.ammo)/float(w.ammoMax);
				preview_bar.value = float(w.ammoBase+w.upgradeLevel*w.ammoUpgradeRate)/float(w.ammoMax);
				
			statType.ENERGY: 
				stat_value.text = str(w.energyCost);
				stat_bar.value = w.energyCost/w.energyCostMax;
				preview_bar.value = w.energyCostBase+float(w.upgradeLevel)*w.energyUpgradeRate/w.energyCostMax;
				
			statType.DAMAGE: 
				stat_value.text = str(w.damage);
				stat_bar.value = w.damage/w.damageMax;
				preview_bar.value = w.damageBase+float(w.upgradeLevel)*w.damageUpgradeRate/w.damageMax;
				
	else:
		#pass;#display_stats.visible = false;
		stat_bar.value = 0.0;
		preview_bar.value = 0.0;
		stat_value.text = "-";
		stat_new_value.text = "-";
