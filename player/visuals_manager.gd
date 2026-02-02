extends Node

@export var sparks_stage_1 : GPUParticles3D
@export var sparks_stage_2 : GPUParticles3D

func _on_drift_manager_stage_changed(stage: int):
	sparks_stage_1.emitting = false
	sparks_stage_2.emitting = false
	
	if stage == 1:
		sparks_stage_1.emitting = true
	elif stage == 2:
		sparks_stage_2.emitting = true
