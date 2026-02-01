@tool
extends Node3D

@export var rayLength = 1

func _ready():
	for c in get_children():
		if c is RayCast3D:
			c.add_exception($"..")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for c in get_children():
		if c is RayCast3D:
			c.target_position = c.to_local(c.global_position + (Vector3.DOWN * rayLength))
