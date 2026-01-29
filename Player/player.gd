extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var shoot_point: Marker3D = $Head/shootPoint
@onready var cord: MeshInstance3D = $Cord
@onready var outlet_ray: RayCast3D = $Head/outletRay
@onready var step_sound: AudioStreamPlayer3D = $StepSound
var progress_bar: ProgressBar;
var crosshair: TextureRect;
var circle_bar: ColorRect;
var outlet_crosshair: TextureRect;
var currency_text: RichTextLabel;

@export var playerUI : CanvasLayer;
@export var baseSpd := 15.0;
@export var jumpSpd := 20;
@export var dashSpd := 80;
@export var groundAccel := 6.0;
@export var groundFric := 10.0;
@export var airAccel := 1.0;
@export var airFric := 1.0;
@export var gravity := 25;
@export var cordLength := 30.0;
var speed = baseSpd;

var stepTimerStep := .25;
var stepTimer := stepTimerStep;

var power := 1.0;
var powerDecRate = .15;

var hp := 100.0;
var hpMax = hp;

var outlet : Area3D;
var outletSelect := Area3D;
var cordProjectile : Node3D;

var dashCooldown := 0.0;
var dashCooldownAmnt := 1.0;
var dashInputBuffer := 0.0;

var jumpBuffer := 0.0;
var groundBuffer := 0.0;

var shootBuffer := 0.0;
var shootBufferTime := .2;
var releaseTime := 0.0;
var releaseTimeMax := .3;
var releasing := false;

#Camera variables
var invertCamMov := true;
@export var cameraSensitivity := 0.004;
@export var chAccel := 4;
@export var cvAccel := 3;
#fov variables
const BASE_FOV := 75.0
const FOV_CHANGE := .4
#bob variables
const BOB_FREQ := 2.0
const BOB_AMP := 0.06
var t_bob := 0.0
var shake := 0.0;
var targY := 0.0;

const bullet = preload("uid://du7sfa2nmsgo7");

const crosshairIcon = preload("uid://dxo87ctx1s615")
const powerIcon = preload("uid://fcmbc0c6wtwk")

var circleBarMat : Resource;

func _ready() -> void:
	outlet = null;
	cordProjectile = null;
	circleBarMat = preload("uid://f4lyx4wwc4mt");
	outlet_ray.target_position = Vector3(0.0,0.0, -cordLength);
	targY = head.position.y;
	
	progress_bar = playerUI.get_node("Control/MarginContainer/StatBars/BatteryBar");
	crosshair = playerUI.get_node("Control/MarginContainer/Crosshair");
	circle_bar = playerUI.get_node("Control/MarginContainer/Crosshair/CircleBar");
	outlet_crosshair = playerUI.get_node("Control/OutletCrosshair");
	currency_text = playerUI.get_node("$Control/MarginContainer/Currency");
	

#move camera with controller r stick
func _process(delta):
	var rstickDir = Input.get_vector("camLeft", "camRight", "camUp", "camDown");
	rotate_from_vector(rstickDir * delta * Vector2(chAccel, cvAccel));
	
	# FOV and headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	var velocity_clamped = clamp(velocity.length(), 0.5, speed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped;
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	shake = move_toward(shake, 0.0, delta*2.0);
	var shakeOffset := Vector3(randf_range(-shake, shake)*Global.screenShake,randf_range(-shake, shake)*Global.screenShake,randf_range(-shake, shake)*Global.screenShake);
	camera.transform.origin = headbob(t_bob)+shakeOffset;
	
	if outlet == null:
		power -= delta*powerDecRate;
		cord.visible = false;
		
		if cordProjectile != null:
			cord.visible = true;
			cord.global_position = (global_position+cordProjectile.global_position)/2;
			cord.look_at(cordProjectile.global_position);
			cord.rotation_degrees.x += 90;
			cord.scale.y = global_position.distance_to(cordProjectile.global_position);
	else:
		power = 1.0;
		cord.visible = true;
		cord.global_position = (global_position+outlet.global_position)/2;
		cord.look_at(outlet.global_position);
		cord.rotation_degrees.x += 90;
		cord.scale.y = global_position.distance_to(outlet.global_position);
		
	progress_bar.value = power;
	
	if Input.is_action_just_pressed("plug"):
		shootBuffer = shootBufferTime;
	
	crosshair.texture = crosshairIcon;
	if outlet != null:
		if Input.is_action_just_pressed("plug"):
			releasing = true;
		if Input.is_action_just_released("plug"):
			releasing = false;
			
		if releasing && Input.is_action_pressed("plug"):
			releaseTime += delta;
			crosshair.texture = powerIcon;
		else:
			releaseTime = 0.0;

		if releaseTime >= releaseTimeMax:
			releaseTime = 0.0;
			outlet = null;
	else:
		releasing = false;
		
	circleBarMat.set_shader_parameter("progress", releaseTime/releaseTimeMax);
		
	shootBuffer -= delta;
	if outlet == null and cordProjectile == null and shootBuffer > 0.0:
		#shoot_sound.play();
		#shake = shakeShootAmnt;
		#shoot_particles.emitting = true;
		var bulletInstance = bullet.instantiate();
		#here we add the bullet as a child of the world, not the player
		get_parent().add_child(bulletInstance);
		#use the rotation and position of the camera to define the forward vector of the bullet
		bulletInstance.position = shoot_point.global_position;
		bulletInstance.direction = -head.transform.basis.z;
		bulletInstance.creator = self;
		cordProjectile = bulletInstance;
		shootBuffer = 0.0;
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit();

#move camera with mouse
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative*cameraSensitivity);
	
func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down");
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	#input buffers for platforming
	jumpBuffer -= delta;
	groundBuffer -= delta;
	if Input.is_action_just_pressed("jump"):
		jumpBuffer = .25;
	if is_on_floor(): 
		groundBuffer = .2;
		
	var inc := 0.0;
	if groundBuffer > 0.0:
		if jumpBuffer > 0.0: #handle jump
			velocity.y = jumpSpd;
			jumpBuffer = 0.0;
			groundBuffer = 0.0;
			shake = .4;
		#set accelerations ground
		if input_dir.length() < .5:
			inc = groundFric;
		else:
			inc = groundAccel;
	else:
		velocity.y -= gravity * delta #handle gravity
		#set accelerations air
		if input_dir.length() < .5:
			inc = airFric;
		else:
			inc = airAccel;
	
	velocity.x = lerp(velocity.x, direction.x * speed, delta * inc)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * inc)
	
	#play step sounds
	if velocity.length() > 1.0 and groundBuffer > 0.0:
		stepTimer -= delta;
	else:
		stepTimer = stepTimerStep;
	if stepTimer <= 0.0:
		step_sound.play();
		shake = .1;
		stepTimer = stepTimerStep;
	
	dashCooldown -= delta;
	dashInputBuffer -= delta;
	if Input.is_action_just_pressed("dash"):
		dashInputBuffer = .2;
	if dashInputBuffer > 0.0 and dashCooldown <= 0.0:
		velocity.x = direction.x * dashSpd
		velocity.z = direction.z * dashSpd
		dashCooldown = dashCooldownAmnt;
		dashInputBuffer = 0.0;
	
	#tether to outlet
	if outlet != null:
		var dist = global_position.distance_to(outlet.global_position)
		if dist > cordLength:
			var cordDir = outlet.global_position - global_position;
			velocity += cordDir.normalized() * velocity.length();
	
	#if power runs out or hp drops below 0	
	if power <= 0.0 or hp <= 0.0:
		get_tree().reload_current_scene();
		
	if outlet_ray.is_colliding():
		var coll = outlet_ray.get_collider()
		if coll != null and coll.is_in_group("outlet"):
			outletSelect = coll;
	else:
		outletSelect = null;
			
	if outletSelect != null:
		if camera.is_position_in_frustum(outletSelect.global_position):
			outlet_crosshair.show()
			#offscreen_reticle.hide()
			var crossPos = camera.unproject_position(outletSelect.global_position);
			outlet_crosshair.global_position = crossPos*4.0-outlet_crosshair.size*.5;
	else:
		outlet_crosshair.hide();
		
	move_and_slide()


func rotate_from_vector(v: Vector2):
	if v.length() == 0: return

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	if !invertCamMov:
		head.rotation.y += v.x;
		head.rotation.x += v.y;
	else:
		head.rotation.y -= v.x;
		head.rotation.x -= v.y;
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(75));

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
