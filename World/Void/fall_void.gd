extends FogVolume

@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape_3d.shape.size = size;
	collision_shape_3d.shape.size.y *= .5;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.battery = 0.0;#queue_free();
	
	if body.is_in_group("enemy"):
		body.queue_free();
