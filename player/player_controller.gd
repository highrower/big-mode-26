extends RigidBody3D

@onready var rays = get_tree().get_nodes_in_group("Raycasts")

@export var acceleration := 50.0 
@export var max_speed := 40.0
@export var turn_speed := 2.5 # Radians per second
@export var hover_force := 50.0 
@export var jump_force := 20.0

@export_range(0.0, 1.0) var drift_snappiness := 0.9 

func _ready():
	# Optional: Prevents the board from flipping over entirely if you hit a weird bump
	angular_damp = 3.0 

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt = state.step
	
	var is_grounded = false
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			is_grounded = true
			var collision_point = ray.get_collision_point()
			var dist = collision_point.distance_to(ray.global_position)
			
			var force_mag = (hover_force / clamp(dist, 0.1, 2.0))
			var force_dir = state.transform.basis.y 
			var pos_offset = ray.global_position - state.transform.origin
			
			state.apply_force(force_dir * force_mag, pos_offset)


	var turn_input = Input.get_axis("move_right", "move_left") # Inverted for standard turning
	var gas_input = Input.get_axis("brake", "accelerate")
	

	if turn_input != 0:
		var rot_amount = turn_input * turn_speed
		state.angular_velocity.y = (state.transform.basis.y * rot_amount).y
		# Todo: Add some banking (roll) here for visuals

	var local_velocity = state.transform.basis.inverse() * state.linear_velocity
	
	local_velocity.x = lerp(local_velocity.x, 0.0, drift_snappiness)
	
	if gas_input > 0 and local_velocity.z > -max_speed:
		local_velocity.z -= acceleration * dt
	elif gas_input < 0:
		local_velocity.z += acceleration * dt
		
	state.linear_velocity = state.transform.basis * local_velocity

	if Input.is_action_just_pressed("jump") and is_grounded:
		state.apply_central_impulse(state.transform.basis.y * jump_force)
