extends CharacterBody3D

@export var player: CharacterBody3D
@export var SPEED: int = 50
@export var CHASE_SPEED: int = 150
@export var ACCELERATION: int = 300

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction: Vector3
var right_bounds: Vector3
var left_bounds: Vector3

enum States{
	WANDER,
	CHASE
}

var current_state = States.WANDER

func _ready():
	left_bounds = self.position + Vector3(125, 10, 125)
	right_bounds = self.position + Vector3(-125, 0, -125)


func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()
	

func look_for_player():
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
		if self.rotation.y == 0:  # Facing right
			#move right
			if self.position.x <= right_bounds.x:
				direction = Vector3(1, 0, 0)
			else:
				#flip move left
				self.rotation.y = PI
				ray_cast.target_position = Vector3(-125, 0, 0)
		else:
			#move left
			if self.position.x >= left_bounds.x:
				direction = Vector3(-1, 0, 0)
			else:
				#flip to move right
				self.rotation.y = 0
				ray_cast.target_position = Vector3(125, 0, 0)
	else:
		#chase state
		direction = (player.position - self.position).normalized()
		if direction.x > 0:
			#facing right
			self.rotation.y = 0
			ray_cast.target_position = Vector3(125, 0, 0)
		else:
			#facing left
			self.rotation.y = PI
			ray_cast.target_position = Vector3(-125, 0, 0)


func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
func _on_timer_timeout():
	current_state = States.WANDER
			
