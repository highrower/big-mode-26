extends Camera3D

@export var move_target: Node3D
@export var look_target: Node3D

@export var move_speed: float = 10.0 
@export var look_speed: float = 10.0 

var internal_look_pos: Vector3

func _ready():
	set_as_top_level(true)
	
	if look_target:
		internal_look_pos = look_target.global_position

func _physics_process(delta):
	if not move_target or not look_target:
		return
		
	var target_pos = move_target.global_position
	global_position = global_position.lerp(target_pos, move_speed * delta)
	
	internal_look_pos = internal_look_pos.lerp(look_target.global_position, look_speed * delta)
	
	look_at(internal_look_pos, Vector3.UP)
