extends Behaviour

@export var updatetimer := 1.0
var target_visible : bool
@onready var last_raycast := $RayCast3D

func _ready() -> void:
	$Timer.wait_time=updatetimer
	last_raycast.add_exception(get_parent())

func execute(caller,_delta:float):
	pass
			

func _on_timer_timeout() -> void:
	var targetables := get_tree().get_nodes_in_group("player_team")
	
	if len(targetables)==0:
		return
	var min_distance = targetables[0].global_position.distance_squared_to(last_raycast.global_position)
	var target = targetables[0]
	for i in targetables:
		if (i.global_position).distance_squared_to(last_raycast.global_position)<min_distance:
			min_distance=(i.global_position).distance_squared_to(last_raycast.global_position)
			target=i
	
	last_raycast.target_position=last_raycast.to_local(target.global_position)
	last_raycast.force_raycast_update()
	
	if last_raycast.get_collider()==target:
		target_visible=true
	else:
		target_visible=false
