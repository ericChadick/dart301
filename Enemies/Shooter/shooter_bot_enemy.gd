extends CharacterBody3D

const explosion = preload("uid://dg8jm24fvq8xv")

@export var enemyClass : enemyType;
var enemyInd : enemyType;

#@export var sightRange := 15.0;
#@export var agroRange := 25.0;
#@export var gravity := 20.0;

@onready var model: Node3D = $shooterBot
@onready var head: Node3D = $Head
@onready var ground_ray: RayCast3D = $GroundRay
@onready var sight_ray: RayCast3D = $Head/SightRay
@onready var hit_particles: Node3D = $HitParticles
#@onready var impact_fx: VFXController = $ImpactFX
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var plug_into_timer: Timer = $PlugIntoTimer
@onready var run_away_timer: Timer = $RunAwayTimer

var target : Node3D;
var animPlayer: AnimationPlayer;
var initPos : Vector3;
var canSee := false;
var active := false;
var prevAnim : String;
var canCord := false;
var connected := false;
var canShoot := true;

const HITFLASH = preload("uid://cgwh17gwt1nra")
var hitflashMat : ShaderMaterial;

func _ready() -> void:
	add_to_group("enemy");
	add_to_group("character");
	target = get_parent().find_child("Player");
	animPlayer = model.get_node("AnimationPlayer");
	animPlayer.play("idle");
	initPos = global_position;
	
	enemyInd = enemyClass.duplicate();
	enemyInd.eyeNode = head.get_path();
	sight_ray.target_position.z = -enemyInd.sightRange;
	enemyInd.sightRaycastNode = sight_ray.get_path();
	
	navigation_agent_3d.radius = collision_shape_3d.shape.radius;
	navigation_agent_3d.height = collision_shape_3d.shape.height;
	
	hitflashMat = ShaderMaterial.new();
	hitflashMat.shader = HITFLASH.duplicate();
	#enemyInd.partsBreak = model.partsBreak;
	#enemyInd.updatePaths();
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor():
		velocity.y -= enemyInd.gravity * delta
	
	if run_away_timer.time_left > 0.0:#animPlayer.current_animation == "running":
		animPlayer.play("running");
		velocity += enemyInd.runSpeed*(navigation_agent_3d.get_next_path_position()-global_position).normalized()*delta;
		head.look_at(navigation_agent_3d.get_next_path_position());
		model.rotation.y = head.rotation.y;
	else:
		velocity.x = lerp(velocity.x, 0.0, 8.0*delta);
		velocity.z = lerp(velocity.z, 0.0, 8.0*delta);
	
	move_and_slide()
	
	#
	var targetDist = global_position.distance_to(target.global_position)
	
	#when shooting the arm can be plugged into
	canCord = false;
	if animPlayer.current_animation == "fire":
		canCord = true;
	
	var connectedPrev = connected;
	
	connected = false;
	if target.outlet != null and target.outlet == model.connect_area:
		if plug_into_timer.time_left <= 0.0:
			plug_into_timer.start();
		connected = true;
	
	#apply unplug effect
	if connectedPrev and !connected:
		model.arm_r.visible = false;
		canShoot = false;
		
	if connected and enemyInd.hp > 0:
		animPlayer.speed_scale = 0.0;
		
	else:
		animPlayer.speed_scale = 1.0;
	
	canSee = true;
	if targetDist > enemyInd.sightRange:
		canSee = false;
	else:
		if enemyInd.angleVision:
			var forward = -head.global_transform.basis.z#enemyInd.eyeNode
			var to_target = (target.global_position - global_position).normalized()
			var dot_prod = forward.dot(to_target)
			if dot_prod <= cos(deg_to_rad(enemyInd.sightAngle*.5)):
				canSee = false;
			else:
				if enemyInd.raycastVision:
					if !sight_ray.is_colliding():#enemyInd.sightRaycastNode
						canSee = false;
	
	if !active and canSee:
		animPlayer.play("alert>fire")
		await animPlayer.animation_finished
		active = true;
		if canShoot:
			animPlayer.play("fire");
		else:
			animPlayer.play("idle");
		
	if active:
		if animPlayer.current_animation == "fire":
			head.look_at(target.global_position);
			model.rotation.y = head.rotation.y;
			await animPlayer.animation_finished #finish shooting
			if targetDist <= enemyInd.agroRange:
				if targetDist < enemyInd.distanceKeepRange or !canShoot:
					animPlayer.play("running"); #run away to get distance
					if run_away_timer.time_left <= 0.0:
						run_away_timer.start();
						
						var distNeeded = enemyInd.sightRange - targetDist;
						var awayVec = (global_position-target.global_position).normalized();
						awayVec.y = 0.0;
						awayVec = awayVec.normalized();
						navigation_agent_3d.target_position = target.global_position+awayVec*distNeeded;
				else:
					animPlayer.play("fire"); #keep shooting
			else:
				animPlayer.play("idle"); #idle
				active = false;
				canSee = false;
		
	
	#convert y rotation into a transform 3d
	#var euler_rotation := Vector3(0.0, head.rotation.y+PI, 0.0)
	#var b := Basis.from_euler(euler_rotation)
	#var new_transform := Transform3D(b, position)
	##rotate with surface normal
	#var n = ground_ray.get_collision_normal()
	#var xform = align_with_y(new_transform, n)
	#model.global_transform = model.global_transform.interpolate_with(xform, 10.0 * delta)
	

#rotate with surface normal
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

#remove part from enemy model
func removePart():
	var parts = model.partsBreak;
	if parts.size() > 0:
		var partSelect = randi_range(0, parts.size()-1);
		parts[partSelect].visible = false;
		parts.remove_at(partSelect);

#func hitflash(duration:float = .05):
	## Enable flash
	#hitflashMat.set("shader_parameter/flash", 1.0)
	#await get_tree().create_timer(duration).timeout
	#hitflashMat.set("shader_parameter/flash", 0.0)
	
func getHit(damage : float, knockback : Vector3):
	#print("HIT");
	
	enemyInd.hp -= damage;
	velocity += knockback;
	
	hit_particles.play();
	
	animPlayer.play("damaged_stunned");
	removePart();
	
	#hitflash(.2);
	
	if enemyInd.hp <= 0:
		
		animPlayer.play("death");
		await animPlayer.animation_finished
		
		Global.currency += enemyInd.currencyReward;
		target.addCurrency(enemyInd.currencyReward);
		var e = explosion.instantiate();
		get_parent().add_child(e);
		e.global_position = global_position;
		queue_free();


func _on_plug_into_timer_timeout() -> void:
	target.unplugOutlet(model.connect_point.global_position);

func _on_run_away_timer_timeout() -> void:
	active = false;
	#replay alert and loop into fire animation
