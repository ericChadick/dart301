extends Area3D
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound

var speed : float = 80.0;
var direction : Vector3 = Vector3.ZERO;
var creator : Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_sound.play();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = creator.cordLength*8.0;
	
	position += direction * speed * delta;
	
	if global_position.distance_to(creator.global_position) > creator.cordLength:
		destroy();

func _on_body_entered(body: Node3D) -> void:
	if body != creator:
		destroy();
	#if body.is_in_group("enemy"):
		#body.hp -= 1;
		##body.hit_particles.emitting = true;
		#body.hit_sound.play();
		#if body.hp <= 0:
			#body.queue_free();
		#queue_free();

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("outlet"):
		area.get_node("PlugSound").play();
		creator.outlet = area;
		creator.velocity = (area.global_position-creator.global_position).normalized()*area.global_position.distance_to(creator.global_position);
		destroy();
		
func destroy() -> void:
	creator.cordProjectile = null;
	queue_free();
