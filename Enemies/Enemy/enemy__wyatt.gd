extends CharacterBody3D

@export var player: CharacterBody3D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300
@export var ROTATION_SPEED: float = 5.0

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var drone: Node3D = $Drone

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3 = Vector3.RIGHT
var right_bounds: float
var left_bounds: float
var facing_right: bool = true

enum States{
	WANDER,
	CHASE
}

var current_state = States.WANDER

func _ready():
	# Set up patrol bounds (125 units left and right from starting position)
	left_bounds = self.position.x - 125
	right_bounds = self.position.x + 125

	# Initialize raycast
	#ray_cast.target_position = Vector3(125, 0, 0)
	ray_cast.enabled = true


func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	change_direction()
	handle_movement(delta)
	handle_rotation(delta)
	look_for_player()
	
	#test vision cone
	var viewer_pos = global_transform.origin
	var target_pos = player.global_transform.origin
	var view_direction = -global_transform.basis.z
	var dir_to_target = (target_pos - viewer_pos).normalized()
	var dot_prod = view_direction.dot(dir_to_target)
	var cone_angle = 0.707 
	if dot_prod > cone_angle:
		print("Player is within view cone!")
	

func look_for_player():
	ray_cast.look_at(player.global_position);
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()


func chase_player() -> void:
		timer.stop()
		current_state = States.CHASE

func stop_chase() -> void:
		if timer.time_left <=0:
			timer.start()
	
func handle_movement(delta: float) -> void:
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(direction * CHASE_SPEED, ACCELERATION * delta )
	move_and_slide()
	
func change_direction() -> void:
	if current_state == States.WANDER:
		if facing_right:
			direction = Vector3.RIGHT
			# Check if we've reached the right bound
			if self.position.x >= right_bounds:
				facing_right = false
		else:
			direction = Vector3.LEFT
			# Check if we've reached the left bound
			if self.position.x <= left_bounds:
				facing_right = true
	else:
		# Chase state - move toward player
		#var to_player = player.position - self.position
		#to_player.y = 0  # Keep movement horizontal
		#direction = to_player.normalized()
		
		navigation_agent_3d.target_position = player.global_position;
		drone.look_at(navigation_agent_3d.get_next_path_position());
		drone.rotation.y += 90;
		direction = (navigation_agent_3d.get_next_path_position()-global_position).normalized();
		#velocity = dir*spd*delta;
		

func handle_rotation(delta: float) -> void:
	# Only rotate if we're actually moving
	if direction.length() > 0.1:
		# Create a target position to look at
		var target_pos = self.position + direction
		target_pos.y = self.position.y  # Keep rotation only on Y axis

		# Smoothly rotate to face the movement direction
		var target_transform = self.global_transform.looking_at(target_pos, Vector3.UP)
		self.global_transform = self.global_transform.interpolate_with(target_transform, ROTATION_SPEED * delta)

		# Update raycast to point forward
		#ray_cast.target_position = -self.global_transform.basis.z * 125


func handle_gravity(delta: float) -> void:
	pass;
	#if not is_on_floor():
	#	velocity.y -= gravity * delta
		
func _on_timer_timeout():
	current_state = States.WANDER
			
