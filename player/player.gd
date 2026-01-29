extends CharacterBody3D

@export_group("Hover Settings")
@export var target_hover_height := 1.0
@export var lerp_speed := 10.0

@export_group("Movement")
@export var max_speed := 15.0
@export var turn_speed := 3.0
@export var gravity := 20.0
@export var jump_height := 10.0
@export var drift_traction := 0.5
@export var normal_traction := 5.0
var traction:= 0.0

@onready var ray = %RayCast3D

func _physics_process(delta):
	if ray.is_colliding():
		var dist = ray.get_collision_point().distance_to(global_position)
		var height_diff = target_hover_height - dist
		velocity.y = lerp(velocity.y, height_diff * lerp_speed, delta * 10.0)
	else:
		velocity.y -= gravity * delta
	
	_handle_input(delta)
	move_and_slide()

func _handle_input(delta):
	var turn=Input.get_axis("move_left","move_right")
	var direction=transform.basis.z
	var horizontal_velocity = velocity
	var target_velocity := 0.0
	if turn:
		rotate_y(turn*turn_speed*delta)
	if Input.is_action_just_pressed("jump") and ray.is_colliding():   
		velocity.y+=jump_height
	
	if Input.is_action_pressed("brake"):
		traction = drift_traction
	else:
		traction = normal_traction
	
	if Input.is_action_pressed("accelerate"):
		target_velocity=max_speed
	
	horizontal_velocity = horizontal_velocity.lerp(direction*target_velocity, traction * delta)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
				
