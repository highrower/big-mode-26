extends RigidBody3D

@onready var rays = get_tree().get_nodes_in_group("Raycasts")
@onready var drift_manager = $DriftManager

@export_group("Movement")
@export var acceleration := 60.0 
@export var max_speed := 50.0
@export var turn_speed := 3.0 
@export var hover_force := 70.0 
@export var jump_force := 25.0
@export var gravity_assist := 2.0
@export var hover_height := 2.5
@export var fall_multiplier := 2.5
@export var drift_min_speed := 5.0

@export var health := 300.0
signal player_health_update(health)

@export_range(0.0, 1.0) var grip_standard := 0.95
@export_range(0.0, 1.0) var grip_drift := 0.01

var pending_boost := 0.0

func _ready():
	angular_damp = 5.0
	drift_manager.boost_ready.connect(_on_boost_ready)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt = state.step
	
	var is_grounded = false
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var dist = ray.get_collision_point().distance_to(ray.global_position)
			if dist < hover_height: 
				is_grounded = true
			
			var force_mag = (hover_force / clamp(dist, 0.1, 2.0))
			var force_dir = state.transform.basis.y 
			state.apply_force(force_dir * force_mag, ray.global_position - state.transform.origin)

	var turn_input = Input.get_axis("move_right", "move_left") # Inverted for standard turning
	var gas_input = Input.get_axis("brake", "accelerate")
	
	var current_grip = handle_drift(state)

	if turn_input != 0:
		var rot_amount = turn_input * turn_speed
		var current_rot = state.transform.basis.inverse() * state.angular_velocity
		current_rot.y = rot_amount 
		state.angular_velocity = state.transform.basis * current_rot
	else:
		# Kill rotation for no unintended drift
		var current_rot = state.transform.basis.inverse() * state.angular_velocity
		current_rot.y = lerp(current_rot.y, 0.0, 0.2)
		state.angular_velocity = state.transform.basis * current_rot

	var local_velocity = state.transform.basis.inverse() * state.linear_velocity
	
	local_velocity.x = lerp(local_velocity.x, 0.0, current_grip)
	
	if is_grounded:
		if gas_input > 0 and local_velocity.z > -max_speed:
			local_velocity.z -= acceleration * dt
		elif gas_input < 0:
			local_velocity.z += acceleration * dt
		if pending_boost > 0:
			local_velocity.z -= pending_boost
			pending_boost = 0
	else:
		var vertical_vel = state.linear_velocity.y
		
		if vertical_vel < 0: 
			# Apply extra force to drag us down faster (more arcade-ey feel)
			var extra_grav = (fall_multiplier - 1.0) * state.total_gravity * mass
			state.apply_central_force(extra_grav)
			
		elif vertical_vel > 0 and not Input.is_action_pressed("jump"):
			var short_hop_mult = 2.0
			var extra_grav = (short_hop_mult - 1.0) * state.total_gravity * mass
			state.apply_central_force(extra_grav)

	state.linear_velocity = state.transform.basis * local_velocity
	
	if Input.is_action_just_pressed("jump") and is_grounded:
		AudioSystem.play_sfx("sfx_hit")
		state.apply_central_impulse(Vector3.UP * jump_force * mass)

func _physics_process(delta: float) -> void:
	player_health_update.emit(health)
	_behaviour_manager(delta)

func _behaviour_manager(delta: float):
	for child in get_children():
		if child is Behaviour and child.enabled:
			child.execute(self,delta)

func take_damage(damage):
	self.health-=damage
	print("PLAYER:"+str(self.health))
		
func handle_drift(state: PhysicsDirectBodyState3D) -> float:
	var curr_speed = state.linear_velocity.length()
	var can_drift = curr_speed > drift_min_speed
	if Input.is_action_just_pressed("drift"):
		if can_drift:
			drift_manager.start_drift()
	if Input.is_action_just_released("drift") or (drift_manager.is_drifting and not can_drift):
		drift_manager.stop_drift()
	return grip_drift if drift_manager.is_drifting else grip_standard
	
func _on_boost_ready(amount):
	pending_boost = amount
