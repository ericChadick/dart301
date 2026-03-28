extends Area3D

var speed : float = 80.0;
var direction : Vector3 = Vector3.ZERO;
var creator : Node3D;
var damage : float = 1.0;

const VFX_HIT_01 = preload("uid://ri1dspbxt43r")

#const IMPACT_DECAL = preload("uid://ph763b2s41br")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta;

func _on_body_entered(body: Node3D) -> void:
	if body != creator and body.is_in_group("character"):
		#print(body.name);
		#body.get_node("HitSound").play();
		
		if body.is_in_group("player"): #add camera screenshake
			body.getHit(damage, Vector3.ZERO, .1, Global.ScreenCracks.MED);
			
		if body.is_in_group("enemy"): #collect currency from enemies
			#body.enemyInd.hp -= damage;
			body.getHit(damage, Vector3.ZERO);
			#body.impact_fx.global_position = global_position;
			#body.impact_fx.play();
		destroy();
		
	destroy();

#timer node connected signal to destroy self on timeout
func _on_timer_timeout() -> void:
	destroy();

func _on_area_entered(area: Area3D) -> void:
	if !area.is_in_group("collect"):
		destroy();
		
func destroy() -> void:
	
	#call_deferred("effect", global_position)
	
	#var decal = IMPACT_DECAL.instantiate();
	#get_parent().add_child(decal);
	#decal.global_position = global_position;
	#decal.look_at(decal.global_transform.origin - direction, Vector3.UP);
	#decal.rotate_object_local(Vector3(1, 0, 0), 90);
	
	queue_free();


#func effect(p : Vector3):
	#var hit = VFX_HIT_01.instantiate();
	#get_parent().add_child(hit);
	#hit.global_position = p;
