extends Node3D

func _ready():
	set_as_top_level(true)

func _process(delta: float) -> void:
	var parent:Node3D = get_parent()
	self.global_position=parent.global_position
	look_at(parent.facing_direction.rotated(Vector3.UP,-PI/2)*100)
