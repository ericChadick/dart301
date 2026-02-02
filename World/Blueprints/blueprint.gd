@tool
extends Area3D

@export var iconTex: Texture2D;
@export var itemName: String = "Gun";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match(itemName):
		"Gun": if Global.gunUnlocked: queue_free();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
