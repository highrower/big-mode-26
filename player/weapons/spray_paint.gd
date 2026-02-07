extends Node3D

@onready var raycast = $RayCast3D
var paint_scene = preload("res://player/weapons/biggy_spray.tscn")
const normal_tests : Array[Vector3] = [Vector3(0,0,1),Vector3(0,1,0),Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,-1,0),Vector3(-1,0,0)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spray"):
		spray()

func _input(event):
	if event.is_action_pressed("spray"):
		$GPUParticles3D.emitting=true
	if event.is_action_released("spray"):
		$GPUParticles3D.emitting=false

func spray():
	if raycast.is_colliding():
		var spray_point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
	
		var biggie_spray = paint_scene.instantiate()
		get_tree().root.add_child(biggie_spray)
		biggie_spray.global_position = spray_point
		biggie_spray.look_at(spray_point+normal)
