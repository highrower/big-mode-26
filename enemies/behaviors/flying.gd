extends Behaviour

@export var height := 20.0
@onready var down_ray := $RayCast3D
@export var speed := 10.0

func _ready():
		down_ray.add_exception(owner)

func execute(caller,_delta: float):
	down_ray.target_position = down_ray.to_local(down_ray.global_position + (Vector3.DOWN * height))
	down_ray.force_raycast_update()
	if down_ray.is_colliding():
		if down_ray.get_collision_point().distance_to(down_ray.global_position)<height:
			caller.apply_force(Vector3.UP*speed)
	else:
		caller.apply_force(Vector3.DOWN*speed)
	caller.apply_force(-caller.get_gravity())
