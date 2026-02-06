extends Node3D

@export var animation_ease: float = 5.0

@onready var player_animations: AnimationPlayer = $PlayerAnimations
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var run_weight_target :Vector2
var current_run_path : String = ""

func _ready() -> void:
	#Sets animation playback to animation set
	current_run_path = "parameters/Hover Pivot/blend_position"

func _process(delta: float) -> void:
	#Move Current animation to next one over time
	animation_smooth(delta)
	#Gets Inputs and gives them to the animation tree
	var input_dir := Input.get_vector("move_right", "move_left", "brake", "accelerate")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		run_weight_target = Vector2(direction.x,direction.z)
	else:
		run_weight_target = Vector2(0,0)
	

func animation_smooth(delta: float) -> void:
	#Left aand Right
	animation_tree[current_run_path].x = move_toward(
		animation_tree[current_run_path].x,
		run_weight_target.x,
		delta * animation_ease
	)
	#Fowards and Backwards
	animation_tree[current_run_path].y = move_toward(
		animation_tree[current_run_path].y,
		-run_weight_target.y,
		delta * animation_ease
	)
