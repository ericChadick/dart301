extends Area3D

var speed : float = 80.0;
var direction : Vector3 = Vector3.ZERO;
var creator : Node3D;
var returning := false;
var creatorDist := 0.0;

@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_sound.play();
	#returning = false;
	
	#if returning:
	#	print("Unplug");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !returning:
		speed = creator.cordLength*8.0;
	else:
		speed = creator.cordLength*4.0;
	
	creatorDist = global_position.distance_to(creator.global_position);
	
	if returning:
		direction = (creator.cord_arm.cord_point.global_position-global_position).normalized();
		if creatorDist < 2.0:
			destroy();
	else:
		if creatorDist >= creator.cordLength:
			position -= direction*(creatorDist-creator.cordLength);
			returning = true;
	
	#print(direction);
	position += direction * speed * delta;

func _on_body_entered(body: Node3D) -> void:
	print("[Projectile] body hit: ", body.name)
	
	#if body != creator:
		#returning = true;
		
		#destroy();
	#if body.is_in_group("enemy"):
		#body.hp -= 1;
		##body.hit_particles.emitting = true;
		#body.hit_sound.play();
		#if body.hp <= 0:
			#body.queue_free();
		#queue_free();

func _on_area_entered(area: Area3D) -> void:
	#print("[Projectile] area hit: ", area.name, " groups=", area.get_groups())
	if area.is_in_group("outlet"):
		#print("[Projectile] outlet found! connected=", area.connected)
		if area.connected == null and !returning:
			connectToOutlet(area);
			
			if area.is_in_group("outletTerminal"):
				if !area.get_parent().watchedTerminal:
					Global.terminalView = true;
					creator.terminal_ui.visible = true;
					creator.terminal_ui.resetTerminalUI();
					area.get_parent().watchedTerminal = true;
					get_tree().paused = true;
				
			#creator.addBullets(1);
			#creator.velocity = (area.global_position-creator.global_position).normalized()*area.global_position.distance_to(creator.global_position)
			destroy();
			
	if area.is_in_group("outletEnemy"):
		if !returning:#area.connected == null and 
			#print("[Projectile] outlet found! connected=", area.connected)
			connectToOutlet(area);
			destroy();
			
func connectToOutlet(area: Area3D):
	if area.is_in_group("outlet"):
		area.get_node("SparkParticle").restart();
		area.get_node("PlugSound").play();
		area.connected = creator;
	creator.outlet = area;
	creator.cordAction = false;
	creator.shake = max(creator.shake, creator.connectShakeAmnt);
	creator.cordTugs = creator.cordTugsMax;
	creator.attachTimer = .25;
			
func destroy() -> void:
	creator.cordProjectile = null;
	queue_free();
