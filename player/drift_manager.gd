extends Node

signal drift_stage_changed(stage: int) 
signal boost_ready(force_amount: float)

@export var stage_1_time := 1.5
@export var stage_2_time := 3.0
@export var boost_force_1 := 50.0
@export var boost_force_2 := 100.0

var drift_timer := 0.0
var current_stage := 0
var is_drifting := false

func start_drift():
	is_drifting = true
	drift_timer = 0.0
	current_stage = 0
	drift_stage_changed.emit(1)

func stop_drift():
	is_drifting = false

	if current_stage == 2:
		boost_ready.emit(boost_force_1)
	elif current_stage == 3:
		boost_ready.emit(boost_force_2)
	
	current_stage = 0
	drift_stage_changed.emit(0)

func _process(delta):
	if is_drifting:
		drift_timer += delta
		
		var old_stage = current_stage
		if drift_timer > stage_2_time:
			current_stage = 3
		elif drift_timer > stage_1_time:
			current_stage = 2
			
		if old_stage != current_stage:
			drift_stage_changed.emit(current_stage)
