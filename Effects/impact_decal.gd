extends Decal

@export var angle : float = 0.0;
@export var normalFadeTime : float = 10.0;
@export var emissionFadeTime : float = 2.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	#normalFadeTime -= delta;
	#emissionFadeTime -= delta;
	#if normalFadeTime <= 0.0 and emissionFadeTime <= 0.0:
	#	queue_free();
