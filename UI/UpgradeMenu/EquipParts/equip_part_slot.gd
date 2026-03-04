@tool
extends TextureButton

@export var partInd : equipPart;

var topRow := false;
var bottomRow := false;

@onready var equipped_icon: TextureRect = $EquippedIcon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	texture_normal = partInd.partIcon;
	queue_redraw();
