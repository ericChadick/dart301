extends Area3D

var speed : float = 80.0;
var direction : Vector3 = Vector3.ZERO;
var creator : Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta;

func _on_body_entered(body: Node3D) -> void:
	#if body != creator:
		#destroy();
		#
	if body != creator and body.is_in_group("character"):
		body.hp -= 1;
		var particles = body.get_node("HitParticles").get_children();
		for i in particles:
			i.restart();
		body.get_node("HitSound").play();
		#body.hit_particles.emitting = true;
		#body.hit_sound.play();
		if body.hp <= 0:
			Global.currency += body.currencyReward;
			body.queue_free();
		destroy();

#timer node connected signal to destroy self on timeout
func _on_timer_timeout() -> void:
	destroy();

func _on_area_entered(area: Area3D) -> void:
	if !area.is_in_group("collect"):
		destroy();
		
func destroy() -> void:
	queue_free();
