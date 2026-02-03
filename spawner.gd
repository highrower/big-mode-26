extends Node3D

@export_group("Spawn Settings")
@export var spawn_list: Dictionary = {} # {PackedScene: float}
@export var spawn_rate: float = 2.0
@export var max_enemies: int = 10
@export var spawn_bounds: Vector3
@onready var spawn_timer = $Timer
var current_enemy_count: int = 0

func _ready():
	spawn_timer.wait_time = spawn_rate

func _on_timer_timeout():
	if current_enemy_count < max_enemies:
		spawn_enemy()

func spawn_enemy():
	var enemy_scene = get_weighted_enemy()
	if not enemy_scene:
		print(enemy_scene)
		return
	
	var instance = enemy_scene.instantiate()
	add_child(instance)
	
	instance.global_position = global_position + get_random_point_in_bounds()
	
	current_enemy_count += 1
	instance.tree_exited.connect(func(): current_enemy_count -= 1)

func get_random_point_in_bounds() -> Vector3:
	return Vector3(randf_range(0.0,spawn_bounds.x),randf_range(0.0,spawn_bounds.y),randf_range(0.0,spawn_bounds.z))
	

func get_weighted_enemy() -> PackedScene:
	var total_weight = 0.0
	for i in spawn_list.values(): 
		total_weight += i
	var roll = randf() * total_weight
	var cursor = 0.0
	for scene in spawn_list:
		cursor += spawn_list[scene]
		if roll <= cursor: return scene
	return null
