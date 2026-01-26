extends CharacterBody3D


@onready var head: Node3D = $Head
@onready var shoot_point: Marker3D = $Head/shootPoint
@onready var cord: MeshInstance3D = $Cord
var progress_bar: ProgressBar;# = playerUI.get_node();#$CanvasLayer/Control/MarginContainer/ProgressBar
var crosshair: TextureRect;# = playerUI.get_node();#$CanvasLayer/Control/MarginContainer/Crosshair
var circle_bar: ColorRect;# = playerUI.get_node();#$CanvasLayer/Control/MarginContainer/Crosshair/CircleBar

@export var playerUI : CanvasLayer;
@export var baseSpd = 8.0;
@export var jumpSpd = 20;
@export var dashSpd = 80;
@export var groundAccel = 10.0;
@export var airAccel = 2.0;
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity := 25;
var speed = baseSpd;

var power := 1.0;
var powerDecRate = .15;

var outlet : Area3D;
var cordLength := 10.0;
var cordProjectile : Node3D;

var dashCooldown := 0.0;
var dashCooldownAmnt := 1.0;
var dashInputBuffer := 0.0;


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
const BASE_FOV = 75.0
const FOV_CHANGE = .8
#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.06
var t_bob = 0.0

const bullet = preload("uid://du7sfa2nmsgo7");

const crosshairIcon = preload("uid://dxo87ctx1s615")
const powerIcon = preload("uid://fcmbc0c6wtwk")

var circleBarMat : Resource;

func _ready() -> void:
	outlet = null;
	cordProjectile = null;
	circleBarMat = preload("uid://f4lyx4wwc4mt");
	
	progress_bar = playerUI.get_node("Control/MarginContainer/StatBars/BatteryBar");
	crosshair = playerUI.get_node("Control/MarginContainer/Crosshair");
	circle_bar = playerUI.get_node("Control/MarginContainer/Crosshair/CircleBar");
	

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

#move camera with controller r stick
func _process(delta):
	var rstickDir = Input.get_vector("camLeft", "camRight", "camUp", "camDown");
	rotate_from_vector(rstickDir * delta * Vector2(chAccel, cvAccel));
	
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
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jumpSpd;
		velocity.x = lerp(velocity.x, direction.x * speed, delta * groundAccel)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * groundAccel)
	else:
		velocity.y -= gravity * delta
		velocity.x = lerp(velocity.x, direction.x * speed, delta * airAccel)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * airAccel)
		
	dashCooldown -= delta;
	dashInputBuffer -= delta;
	if Input.is_action_just_pressed("dash"):
		dashInputBuffer = .2;
	if dashInputBuffer > 0.0 and dashCooldown <= 0.0:
		velocity.x = direction.x * dashSpd
		velocity.z = direction.z * dashSpd
		dashCooldown = dashCooldownAmnt;
		dashInputBuffer = 0.0;
		
	if outlet != null:
		var dist = global_position.distance_to(outlet.global_position)
		if dist > cordLength:
			var cordDir = outlet.global_position - global_position;
			#apply_central_impulse(cordDir.normalized() * (dist - cordLength));
			#var required_movement = direction_to_target * speed * delta
			velocity += cordDir.normalized() * velocity.length();
			
	if power <= 0.0:
		get_tree().reload_current_scene();

	move_and_slide()
