extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var shoot_point: Marker3D = $Head/shootPoint
@onready var shoot_particles: GPUParticles3D = $Head/ShootParticles
@onready var cord: MeshInstance3D = $Cord
@onready var outlet_ray: RayCast3D = $Head/outletRay
@onready var cord_hand_animations: AnimationPlayer = $CordHandAnimations
@onready var weapon_hand_animations: AnimationPlayer = $WeaponHandAnimations

@onready var step_sound: AudioStreamPlayer3D = $StepSound
@onready var hit_sound: AudioStreamPlayer = $HitSound

@onready var shoot_sound: AudioStreamPlayer = $Sounds/ShootSound
@onready var self_destruct_sound: AudioStreamPlayer = $Sounds/SelfDestructSound
@onready var swing_sound: AudioStreamPlayer = $Sounds/SwingSound
@onready var unplug_sound: AudioStreamPlayer = $Sounds/UnplugSound
@onready var charging_sound: AudioStreamPlayer = $Sounds/ChargingSound
@onready var pull_sound: AudioStreamPlayer = $Sounds/PullSound
@onready var slide_sound: AudioStreamPlayer = $Sounds/SlideSound
@onready var punch_sound: AudioStreamPlayer = $Sounds/PunchSound
@onready var jump_sound: AudioStreamPlayer = $Sounds/JumpSound
@onready var land_sound: AudioStreamPlayer = $Sounds/LandSound

@onready var blueprint_timer: Timer = $Timers/BlueprintTimer
@onready var pull_timer: Timer = $Timers/PullTimer
@onready var slide_timer: Timer = $Timers/SlideTimer
@onready var slide_cooldown_timer: Timer = $Timers/SlideCooldownTimer
@onready var punch_timer: Timer = $Timers/PunchTimer

@onready var sub_viewport_container: SubViewportContainer = $"../.."

var battery_bar: ProgressBar;
var health_bar: ProgressBar;
var crosshair: TextureRect;
var circle_bar: ColorRect;
var outlet_crosshair: TextureRect;
var currency_text: RichTextLabel;
var blueprint_text: RichTextLabel;
var outlet_bar: ProgressBar;
var plug_icon: TextureRect;

@export var playerUI : CanvasLayer;

func calculateStat(minValue:float,maxValue:float, statLevel:int, statLevelMax:int) -> float:
	return minValue + (float(statLevel)/float(statLevelMax))*(maxValue-minValue);

#calculate stats based off of their upgraded level
var speed := calculateStat(Global.spdMin, Global.spdMax, Global.spdLevel, Global.spdLevelMax);
var jumpSpd := calculateStat(Global.jumpSpdMin, Global.jumpSpdMax, Global.jumpSpdLevel, Global.jumpSpdLevelMax);
var dashSpd := calculateStat(Global.dashSpdMin, Global.dashSpdMax, Global.dashSpdLevel, Global.dashSpdLevelMax);
var battery := calculateStat(Global.batteryMin, Global.batteryMax, Global.batteryLevel, Global.batteryLevelMax);
var batteryMax := battery;
var hp := calculateStat(Global.hpMin, Global.hpMax, Global.hpLevel, Global.hpLevelMax);
var hpMax := hp;
var cordLength := calculateStat(Global.cordLengthMin, Global.cordLengthMax, Global.cordLengthLevel, Global.cordLengthLevelMax);
var dataMultiplier := calculateStat(Global.dataMultiplierMin, Global.dataMultiplierMax, Global.dataMultiplierLevel, Global.dataMultiplierLevelMax);

var pullSpd := 60.0;

@export var groundAccel := speed*1.25;
@export var groundFric := speed*1.25;
@export var airAccel := speed*.75;
@export var airFric := speed*.75;
@export var gravity := 25.0;#jumpSpd*1.5;

var stepTimerStep := .6;#(1.0-(speed/18.0))*2.0;
var stepTimer := stepTimerStep;

var weapon := Global.PlayerWeapon.FIST;

var outlet : Area3D;
var outletSelect := Area3D;
var cordProjectile : Node3D;

var dashCooldown := 0.0;
var dashCooldownAmnt := 1.0;
var dashInputBuffer := 0.0;

var jumpBuffer := 0.0;
var groundBuffer := 0.0;
var slideBuffer := 0.0;

var outletBuffer := 0.0;
var outletBufferTime := .25;
var chargeSwing := false;

var weaponBuffer := 0.0;
var weaponBufferTime := .2;
var weaponCooldown := 0.0;
var shootShakeAmnt := .2;
var shootOutletAmnt := .3;

var hitboxEnemy : Node3D;

var swingChargeTime := 0.0;

var releaseTime := 0.0;
var releaseTimeMax := 3.0;
var releasing := false;

var canWallRun := false;
var wallRunTime := 0.0;
var wallRunTimeMax := 2.0;

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

var groundedPrev := true;
var groundedCurrent := groundedPrev;

const outletProj = preload("uid://du7sfa2nmsgo7")
const bullet = preload("uid://h8nfngcoc7cq")

const crosshairIcon = preload("uid://dxo87ctx1s615")
const powerIcon = preload("uid://fcmbc0c6wtwk")

var circleBarMat : Resource;

func _ready() -> void:
	outlet = null;
	cordProjectile = null;
	circleBarMat = preload("uid://f4lyx4wwc4mt");
	outlet_ray.target_position = Vector3(0.0,0.0, -cordLength*.8);
	targY = head.position.y;
	
	battery_bar = playerUI.get_node("Control/MarginContainer/StatBars/BatteryBar");
	health_bar = playerUI.get_node("Control/MarginContainer/StatBars/HealthBar");
	crosshair = playerUI.get_node("Control/MarginContainer/Crosshair");
	circle_bar = playerUI.get_node("Control/MarginContainer/Crosshair/CircleBar");
	outlet_crosshair = playerUI.get_node("Control/OutletCrosshair");
	currency_text = playerUI.get_node("Control/MarginContainer/Currency");
	blueprint_text = playerUI.get_node("Control/MarginContainer/BlueprintText");
	outlet_bar = playerUI.get_node("Control/OutletCrosshair/OutletBar")
	plug_icon = playerUI.get_node("PlugIcon")

#move camera with controller r stick
func _process(delta):
	var rstickDir = Input.get_vector("camLeft", "camRight", "camUp", "camDown");
	rotate_from_vector(rstickDir * delta * Vector2(chAccel, cvAccel));
	
	# FOV and headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	var velocity_clamped = clamp(velocity.length(), 0.5, speed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE*(1.0+(slide_timer.time_left/slide_timer.wait_time)*1.0) * velocity_clamped;
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	shake = move_toward(shake, 0.0, delta*2.0);
	var shakeOffset := Vector3(randf_range(-shake, shake)*Global.screenShake,randf_range(-shake, shake)*Global.screenShake,randf_range(-shake, shake)*Global.screenShake);
	camera.transform.origin = headbob(t_bob)+shakeOffset;
	#camera.transform.origin.z  
	
	plug_icon.visible = outlet != null;
	if outlet == null:
		cord.visible = false;
		if cordProjectile != null:
			cord.visible = true;
			cord.global_position = (global_position+cordProjectile.global_position)/2;
			cord.look_at(cordProjectile.global_position);
			cord.rotation_degrees.x += 90;
			cord.scale.y = global_position.distance_to(cordProjectile.global_position);
	else:
		cord.visible = true;
		cord.global_position = (global_position+outlet.global_position)/2;
		cord.look_at(outlet.global_position);
		cord.rotation_degrees.x += 90;
		cord.scale.y = global_position.distance_to(outlet.global_position);
		
	battery_bar.value = (battery/batteryMax);
	health_bar.value = (hp/hpMax);
	currency_text.text = str("%.1f" %Global.currency);
	
	weaponBuffer -= delta;
	weaponCooldown -= delta;
	outletBuffer -= delta;
	if Input.is_action_just_released("RMB"):
		outletBuffer = outletBufferTime;
	if Input.is_action_just_pressed("LMB"):
		weaponBuffer = weaponBufferTime;
	
	if outlet == null and cordProjectile == null and Input.is_action_pressed("RMB"):
		$Head/CordProtoNode.visible = true;
		cord_hand_animations.play("swing");
		chargeSwing = true;
		shake = max(shake, .05);
		if !swing_sound.playing:
			swing_sound.play();
	if chargeSwing:
		swingChargeTime += delta;
	if outletBuffer > 0.0:
		if swingChargeTime > .25:
			chargeSwing = false;
			outletBuffer = 0.0;
			var bulletInstance = outletProj.instantiate();
			get_parent().add_child(bulletInstance);
			bulletInstance.position = shoot_point.global_position;
			bulletInstance.direction = -head.transform.basis.z;
			bulletInstance.creator = self;
			cordProjectile = bulletInstance;
			outletBuffer = 0.0;
			shake = max(shake, shootOutletAmnt);
			
			$Head/CordProtoNode.visible = false
			swing_sound.stop();
			swingChargeTime = 0.0;
			cord_hand_animations.play("RESET");
	
	crosshair.texture = crosshairIcon;
	
	#if outlet == null and cordProjectile == null and outletBuffer > 0.0:
		##shoot_sound.play();
		##shoot_particles.emitting = true;
		#var bulletInstance = outletProj.instantiate();
		#get_parent().add_child(bulletInstance);
		#bulletInstance.position = shoot_point.global_position;
		#bulletInstance.direction = -head.transform.basis.z;
		#bulletInstance.creator = self;
		#cordProjectile = bulletInstance;
		#outletBuffer = 0.0;
		#shake = shootOutletAmnt;
	
	battery -= delta;
	
	if outlet != null:
		
		outlet_bar.visible = true;
		outlet.battery -= delta;
		if outlet.battery > 0:
			battery = batteryMax;
			outlet_bar.modulate = Color.YELLOW;
			battery_bar.modulate = Color.YELLOW;
			if !charging_sound.playing:
				charging_sound.play();
		else:
			outlet_bar.modulate = Color.RED;
			battery_bar.modulate = Color.RED;
			charging_sound.stop();
			
		outlet_bar.value = outlet.battery/outlet.batteryMax;
		#Global.currency += delta*dataMultiplier;
		if Input.is_action_just_pressed("pull"):
			var outletVec = (outlet.global_position-global_position).normalized()*(pullSpd+outlet.global_position.distance_to(global_position));
			var lookVec = -head.transform.basis.z*(pullSpd+outlet.global_position.distance_to(global_position));
			var pullVec = (lookVec+outletVec)/2;
			wallRunTime = 0.0;
			velocity = pullVec;
			pull_sound.play();
			
			pull_timer.start();
			#creator.velocity = (area.global_position-creator.global_position).normalized()*area.global_position.distance_to(creator.global_position);
		if outletBuffer > 0.0: #unplug
			outlet = null;
			unplug_sound.play();
			outletBuffer = 0.0;
	else:
		charging_sound.stop();
		battery_bar.modulate = Color.WHITE;
		outlet_bar.visible = false;
		
	if Input.is_action_pressed("selfDestruct"):
		if !self_destruct_sound.playing:
			self_destruct_sound.play();
		releaseTime += delta;
		if releaseTime >= releaseTimeMax:
			battery = 0.0;
		crosshair.texture = powerIcon;
	else:
		releaseTime = 0.0;
		crosshair.texture = crosshairIcon
		self_destruct_sound.stop();
		
	circleBarMat.set_shader_parameter("progress", releaseTime/releaseTimeMax);
	
	if punch_timer.time_left > 0.0 and hitboxEnemy != null:
		hitboxEnemy.queue_free();
		
	match (weapon):
		Global.PlayerWeapon.FIST:
			if weaponBuffer > 0.0 and weaponCooldown <= 0.0:
				shoot_particles.restart();
				weaponBuffer = 0.0;
				weaponCooldown = .4;
				punch_timer.start();
				punch_sound.play();
				shake = shootShakeAmnt;
		Global.PlayerWeapon.GUN:
			if Global.gunPurchased and weaponBuffer > 0.0:
				var bulletInstance = bullet.instantiate();
				get_parent().add_child(bulletInstance);
				bulletInstance.position = shoot_point.global_position;
				bulletInstance.direction = -head.transform.basis.z;
				bulletInstance.creator = self;
				shoot_particles.restart();
				weaponBuffer = 0.0;
				shake = max(shake, shootShakeAmnt);
				shoot_sound.play();
		
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit();

#move camera with mouse
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative*cameraSensitivity);
	
func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down");
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	var zwobble = -.125*input_dir.x;
	if slide_timer.time_left > 0.0:
		zwobble = -.2;
	head.rotation.z = lerp(head.rotation.z, zwobble, delta*5.0);
		
	#input buffers for platforming
	jumpBuffer -= delta;
	groundBuffer -= delta;
	slideBuffer -= delta;
	if Input.is_action_just_pressed("jump"):
		jumpBuffer = .25;
	if is_on_floor(): 
		groundBuffer = .2;
	if Input.is_action_just_pressed("slide"):
		slideBuffer = .15;
	
	groundedPrev = groundedCurrent;
	groundedCurrent = groundBuffer > 0.0;
	var inc := 0.0;
	if groundBuffer > 0.0:
		if slideBuffer > 0.0 and slide_cooldown_timer.time_left <= 0.0:
			slide_timer.start();
			slide_sound.play();
			velocity.x *= 2.5;
			velocity.z *= 2.5;
			slideBuffer = 0.0;
			
		canWallRun = false;
		wallRunTime = 0.0;
		if jumpBuffer > 0.0: #handle jump
			jump_sound.play();
			velocity.y = jumpSpd;
			jumpBuffer = 0.0;
			groundBuffer = 0.0;
			shake = .4;
			canWallRun = true;
			wallRunTime = wallRunTimeMax;
			slide_timer.stop();
		#set accelerations ground
		if input_dir.length() < .5:
			inc = groundFric;
		else:
			inc = groundAccel;
	else:
		if pull_timer.time_left <= 0.0:
			if !is_on_wall() or wallRunTime <= 0.0:
				velocity.y -= gravity * delta #handle gravity
			#else:
			#	velocity.y -= gravity*.1 * delta
		#set accelerations air
		if input_dir.length() < .5:
			inc = airFric;
		else:
			inc = airAccel;
	
	if velocity.y > 0 and !Input.is_action_pressed("jump"):
		velocity.y *= .9;
			
	#land effects
	if groundedPrev != groundedCurrent:
		land_sound.play();
		shake = .5;
		
	#wall run
	if canWallRun and input_dir.length() > .5:
		if is_on_wall() and wallRunTime > 0.0:
			wallRunTime -= delta;
			var wallN = get_slide_collision(0)
			var d = direction;
			direction = d-wallN.get_normal()*d.dot(wallN.get_normal());
			if jumpBuffer > 0.0: #handle jump
				jump_sound.play();
				velocity = wallN.get_normal()*jumpSpd*2.0;
				velocity.y = jumpSpd*.5;
				jumpBuffer = 0.0;
				groundBuffer = 0.0;
				shake = .4;
				canWallRun = false;
				wallRunTime = 0.0;
				slide_timer.stop();
	
	var pullRatioDir = clamp((pull_timer.time_left/pull_timer.wait_time)*3.0, 1.0, 3.0);
	var pullRatioAcc = clamp((1.0-pull_timer.time_left/pull_timer.wait_time), .5, 1.0);
	var slideRatioAcc = clamp(1.0-slide_timer.time_left/slide_timer.wait_time, .1, 1.0);
	var slideRatioSpd = clamp((slide_timer.time_left/slide_timer.wait_time)*2.0, 1.0, 2.0);
	velocity.x = lerp(velocity.x, direction.x*pullRatioDir * speed*slideRatioSpd, delta * inc * pullRatioAcc * slideRatioAcc);
	velocity.z = lerp(velocity.z, direction.z*pullRatioDir * speed*slideRatioSpd, delta * inc * pullRatioAcc * slideRatioAcc);
	
	#play step sounds
	var wlrn = is_on_wall() and wallRunTime > 0.0;
	if velocity.length() > 1.0 and (groundBuffer > 0.0 or wlrn) and slide_timer.time_left <= 0.0:
		stepTimer -= delta;
	else:
		stepTimer = stepTimerStep;
	if stepTimer <= 0.0:
		step_sound.play();
		shake = .1;
		if wlrn:
			stepTimer = stepTimerStep*.5;
		else:
			stepTimer = stepTimerStep;
	
	dashCooldown -= delta;
	dashInputBuffer -= delta;
	if Input.is_action_just_pressed("dash"):
		dashInputBuffer = .2;
	if Global.dashPurchased and dashInputBuffer > 0.0 and dashCooldown <= 0.0:
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
	if battery <= 0.0 or hp <= 0.0:
		get_tree().change_scene_to_file("res://UI/upgrade_menu.tscn");
		
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
			outlet_crosshair.global_position = crossPos*sub_viewport_container.stretch_shrink-outlet_crosshair.size*.5;
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
	pos.y = sin(time * BOB_FREQ) * BOB_AMP - sin((slide_timer.time_left/slide_timer.wait_time)*PI)
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_collect_radius_area_entered(area: Area3D) -> void:
	if area.is_in_group("blueprint"):
		blueprint_text.text = "Uploading " + str(area.itemName) + " blueprint...";
		blueprint_timer.start();
		match(area.itemName):
			"Gun": Global.gunUnlocked=true;
		area.queue_free();


func _on_blueprint_timer_timeout() -> void:
	blueprint_text.text = "";


func _on_slide_timer_timeout() -> void:
	slide_cooldown_timer.start();

func _on_punch_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		hitboxEnemy = body;
func _on_punch_hitbox_body_exited(body: Node3D) -> void:
	hitboxEnemy = null;
