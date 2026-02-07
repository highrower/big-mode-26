extends Behaviour

@export var speed = 50.0
var target_location
func _ready() -> void:
	target_location = self.position

func execute(caller,_delta:float):
	var current_location = caller.global_position
	var next_location = target_location
	var new_velocity = (next_location-current_location).normalized()*speed
	caller.apply_central_force(new_velocity)

func update_target(target_location):
	self.target_location = target_location
