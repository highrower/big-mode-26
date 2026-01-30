extends RigidBody3D

@export var kick := 150.0
@export var turn_speed :=5.0
@export var brake_strength := 2.0
@export var traction := 0.1
@export var jump_force := 500.0
@onready var facing_direction:= -transform.basis.z
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_damp = traction
	angular_damp = traction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var turn = Input.get_axis("move_left","move_right")
	if turn:
		facing_direction=facing_direction.rotated(Vector3.UP,turn*turn_speed*delta)
	
	if Input.is_action_just_pressed("jump"):
		apply_central_force(Vector3.UP*jump_force)
	if Input.is_action_pressed("accelerate"):
		apply_torque(facing_direction*kick)
	if Input.is_action_pressed("brake"):
		linear_damp = brake_strength
		angular_damp = brake_strength
	else:
		linear_damp = traction
		angular_damp = traction
