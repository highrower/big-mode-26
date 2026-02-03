extends Behaviour

@export var speed = 50.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	pass

func execute(caller,_delta:float):
	var current_location = caller.global_position
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location-current_location).normalized()*speed
	caller.apply_central_force(new_velocity)

func update_target(target_location):
	nav_agent.target_position=target_location
