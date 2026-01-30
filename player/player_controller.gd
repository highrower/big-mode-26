extends RigidBody3D
@onready var rays = get_tree().get_nodes_in_group("Raycasts")
@export var speed := 15000.0
@export var turn_speed := 2000.0
@export var reverse_speed := 1000.0
@export var hover_force := 1000.0
@export var jump_force := 100.0
func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	var can_jump = false
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			can_jump=true
			var collision_point = ray.get_collision_point()
			
			var distance = collision_point.distance_to(ray.global_position)
			
			apply_force(delta*(Vector3.UP*hover_force)/clamp(distance,0.1,10),ray.global_transform.origin - global_transform.origin)
	
	var turn = Input.get_axis("move_left","move_right")
	if turn:
		apply_torque(-transform.basis.y*turn*turn_speed*delta)
	
	if Input.is_action_pressed("accelerate"):
		apply_central_force(-transform.basis.z*speed*delta)
	if Input.is_action_pressed("brake"):
		apply_central_force(transform.basis.z*reverse_speed*delta)
	if Input.is_action_just_pressed("jump") and can_jump:
		apply_impulse(transform.basis.y*jump_force)
