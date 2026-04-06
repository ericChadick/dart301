extends Node3D

var watchedTerminal := false;
@onready var watch_light: OmniLight3D = $WatchLight
@onready var cube_006: MeshInstance3D = $Cube_006

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if watchedTerminal:
		watch_light.light_color = Color.RED;
		cube_006.material_override = null;
