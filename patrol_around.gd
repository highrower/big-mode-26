extends Behaviour

@export var updatetimer := 5.0
@export var patrol_radius := 250.0
@onready var target = $Node3D.global_position

func _ready() -> void:
	$Timer.wait_time=updatetimer

func execute(caller,_delta:float):
	pass
			

func _on_timer_timeout() -> void:
	var random_vector := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	target = $Node3D.global_position+random_vector*patrol_radius
